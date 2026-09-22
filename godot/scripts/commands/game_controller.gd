# res://scripts/commands/game_controller.gd
# STRATO COMANDI: l'unico punto da cui interfaccia e bot modificano lo stato.
# Ogni comando valida con le funzioni pure di rules/ e poi applica.
# Emette segnali che la visualizzazione ascolta: il nucleo non conosce la grafica.
class_name GameController
extends RefCounted

signal state_changed
signal building_placed(b: Building)
signal building_changed(b: Building)
signal era_ended(era: int)
signal game_ended(winner: int)

var gs: GameState
var _activated_col: int = -1      # colonna attivata nel turno corrente

# ---- setup ---------------------------------------------------------
func new_game(n_players: int, seed_value: int) -> void:
	gs = GameState.new()
	gs.rng.seed = seed_value
	gs.n_players = n_players
	for i in n_players:
		var p := PlayerState.new(i)
		p.pietra = int(CardDB.constants["start_resources"]["pietra"])
		p.workers = int(CardDB.constants["workers_base"])
		gs.players.append(p)
	if n_players == 2:
		gs.players[1].oro += int(CardDB.constants["second_player_bonus_2p"]["oro"])

	var mix: Dictionary = CardDB.constants["terrain_mix_by_players"][str(n_players)]
	var terr := []
	for t in mix:
		for k in int(mix[t]): terr.append(Enums.terrain_from_string(t))
	_shuffle(terr)
	gs.grid = Grid.new(terr.size(), terr)

	for e in range(1, 6):
		var ids := CardDB.buildings_of_era(e).map(func(b): return b["id"])
		_shuffle(ids)
		gs.building_decks[e] = ids
	_start_era(1)

func _start_era(era: int) -> void:
	gs.era = era
	gs.market.clear()
	var deck: Array = gs.building_decks[era]
	for i in min(int(CardDB.constants["market_size"]), deck.size()):
		gs.market.append(deck.pop_back())
	if era <= 4:
		var evs := CardDB.events_of_era(era)
		gs.current_event = evs[gs.rng.randi_range(0, evs.size() - 1)]
	else:
		gs.current_event = {}
	# Ordine: prima chi ha costruito meno. TODO: snake in 2 giocatori, era 1.
	gs.turn_order = range(gs.n_players)
	gs.turn_order.sort_custom(func(a, b): return gs.players[a].buildings_built < gs.players[b].buildings_built)
	gs.turn_pos = 0
	gs.phase = Enums.Phase.PIAZZA
	gs.log_line("Inizia l'era %d. Evento: %s" % [era, gs.current_event.get("name", "nessuno")])
	state_changed.emit()

# ---- fase 1+2: piazza e attiva --------------------------------------
func place_worker(col: int, protect: Building = null) -> bool:
	if gs.phase != Enums.Phase.PIAZZA: return false
	var p := gs.current_player()
	if p.workers_used >= p.workers: return false
	p.workers_used += 1
	if protect != null and protect.owner == p.index and protect.covers(col):
		protect.protection += int(CardDB.constants["protection_bonus"])
	EraRules.activate(gs, p.index, col)
	_activated_col = col
	gs.phase = Enums.Phase.AZIONE
	state_changed.emit()
	return true

# ---- fase 3: azioni -------------------------------------------------
func build(card_id: String, col_from: int, above: bool, pay_option: int = 0) -> bool:
	if gs.phase != Enums.Phase.AZIONE: return false
	if abs(col_from - _activated_col) > 1: return false
	if not card_id in gs.market: return false
	var p := gs.current_player()
	var data: Dictionary = CardDB.buildings[card_id]
	var q := BuildRules.quote_above(gs, p.index, data, col_from) if above else BuildRules.quote_rail(gs, p.index, data, col_from)
	if not q.legal:
		gs.log_line("Costruzione rifiutata: %s" % q.reason)
		return false
	var opts := BuildRules.flexible_options(data, q.pietra, q.oro)
	var cost: Vector2i = opts[clamp(pay_option, 0, opts.size() - 1)]
	if not p.can_pay(cost.x, cost.y): return false
	p.pay(cost.x, cost.y)

	for base in q.bases:
		if base in q.razed:
			base.was_razed = true
			base.state = Enums.BuildingState.ROVINA
		elif base.state == Enums.BuildingState.RUDERE:
			base.state = Enums.BuildingState.ROVINA
		base.is_buried = true
		building_changed.emit(base)

	var b := Building.new()
	b.uid = gs.new_uid()
	b.data = data
	b.owner = p.index
	b.era_built = gs.era
	b.col_from = col_from
	b.col_to = col_from + int(data["width"])
	b.level = q.level
	b.bonus_res = q.continuity_bonus
	if gs.grid.terrains[col_from] == Enums.Terrain.COLLINA: b.bonus_res += 1
	b.charges = int(data.get("exhaustible", 0))
	gs.grid.buildings.append(b)
	if above:
		for c in range(b.col_from, b.col_to): gs.grid.risen_this_era[c] = true
	p.buildings_built += 1
	if int(data["lampo"]) > 0: p.add_vp("lampo", int(data["lampo"]))
	gs.market.erase(card_id)
	var deck: Array = gs.building_decks[gs.era]
	if not deck.is_empty(): gs.market.append(deck.pop_back())
	building_placed.emit(b)
	_end_turn()
	return true

func pass_action() -> void:
	if gs.phase == Enums.Phase.AZIONE: _end_turn()

# TODO: upgrade(), restore(), recruit(), buy_dynasty(), despoil()
# Seguire lo stesso schema: validare in rules/, applicare qui, emettere segnali.

# ---- avanzamento ---------------------------------------------------
func _end_turn() -> void:
	gs.phase = Enums.Phase.PIAZZA
	for _i in gs.n_players:
		gs.turn_pos = (gs.turn_pos + 1) % gs.n_players
		var np := gs.current_player()
		if np.workers_used < np.workers:
			state_changed.emit()
			return
	_finish_era()

func _finish_era() -> void:
	# TODO: sepoltura dei personaggi reclutati (ere 1-4) sotto un edificio vivo.
	EraRules.end_era(gs)
	era_ended.emit(gs.era)
	if gs.era >= 5:
		Scoring.final_scoring(gs)
		gs.phase = Enums.Phase.FINE_PARTITA
		game_ended.emit(Scoring.winner(gs))
	else:
		_start_era(gs.era + 1)

func _shuffle(a: Array) -> void:
	for i in range(a.size() - 1, 0, -1):
		var j := gs.rng.randi_range(0, i)
		var tmp = a[i]; a[i] = a[j]; a[j] = tmp
