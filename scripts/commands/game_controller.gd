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
var _last_protected: Building = null  # edificio abitato dal lavoratore di questo turno

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
		var cids := CardDB.characters.values().filter(
			func(c): return c.get("era") == e and not c.get("is_dynasty", false)
		).map(func(c): return c["id"])
		_shuffle(cids)
		gs.char_decks[e] = cids
		var uids := CardDB.upgrades.values().filter(func(u): return int(u["era"]) == e).map(func(u): return u["id"])
		_shuffle(uids)
		gs.upg_decks[e] = uids
	gs.dynasties_left = int(CardDB.characters[ActionRules.dynasty_id()].get("copies", 0))

	# "Rivelate tanti Monumenti celebri quanti sono i giocatori meno uno"
	var mons := CardDB.monuments.keys()
	_shuffle(mons)
	for i in max(0, n_players - 1):
		if i < mons.size(): gs.monuments_open.append(mons[i])

	# "distribuite 2 carte Eredita' a testa: ognuno ne tiene una segreta"
	var legs := CardDB.legacies.keys()
	_shuffle(legs)
	for p2 in gs.players:
		var due := []
		for k in 2:
			if not legs.is_empty(): due.append(legs.pop_back())
		if not due.is_empty():
			p2.legacy_id = due[gs.rng.randi_range(0, due.size() - 1)]

	_start_era(1)

func _start_era(era: int) -> void:
	gs.era = era
	gs.market.clear()
	_refill(gs.market, gs.building_decks[era], int(CardDB.constants["market_size"]))
	# "quando un'era finisce, le file non usate si scartano": si riparte da zero.
	gs.char_row.clear()
	gs.upg_row.clear()
	var side := int(CardDB.constants["side_rows"])
	_refill(gs.char_row, gs.char_decks[era], side)
	_refill(gs.upg_row, gs.upg_decks[era], side)

	if era <= 4:
		var evs := CardDB.events_of_era(era)
		gs.current_event = evs[gs.rng.randi_range(0, evs.size() - 1)]
	else:
		gs.current_event = {}

	gs.turn_order = _era_turn_order()
	gs.turn_sequence = _era_turn_sequence()
	gs.turn_pos = -1
	gs.current_index = -1
	for p in gs.players: p.reset_for_era()
	gs.phase = Enums.Phase.PIAZZA
	Conditions.claim_monuments(gs)      # il Pantheon guarda l'inizio dell'era Moderna
	gs.log_line("Inizia l'era %d. Evento: %s" % [era, gs.current_event.get("name", "nessuno")])
	if _advance_to_next_player():
		state_changed.emit()
	else:
		_finish_era()

# "A ogni nuova era parte primo chi ha costruito meno edifici in totale;
# a parita' si mantiene l'ordine precedente."
# Il confronto e' un ordine totale (pareggio risolto dalla posizione precedente),
# quindi il risultato non dipende dalla stabilita' di sort_custom.
func _era_turn_order() -> Array:
	var prev: Array = gs.turn_order.duplicate() if not gs.turn_order.is_empty() else range(gs.n_players)
	var decorated := []
	for pos in prev.size():
		decorated.append({"p": int(prev[pos]), "pos": pos})
	decorated.sort_custom(func(a, b):
		var ba: int = gs.players[a["p"]].buildings_built
		var bb: int = gs.players[b["p"]].buildings_built
		if ba != bb: return ba < bb
		return a["pos"] < b["pos"])
	var out := []
	for d in decorated: out.append(d["p"])
	return out

# "In due giocatori, l'Era 1 si apre a snake - A, B, B, A, A, B."
# Se qualcuno acquista la Dinastia durante l'era, il lavoratore in piu' viene
# servito dal giro normale una volta esaurita la sequenza.
func _era_turn_sequence() -> Array[int]:
	var seq: Array[int] = []
	if gs.n_players == 2 and gs.era == 1:
		var a: int = gs.turn_order[0]
		var b: int = gs.turn_order[1]
		seq = [a, b, b, a, a, b]
	return seq

func _refill(row: Array, deck: Array, size: int) -> void:
	while row.size() < size and not deck.is_empty():
		row.append(deck.pop_back())

# ---- fase 1+2: piazza e attiva --------------------------------------
func place_worker(col: int, protect: Building = null) -> bool:
	if gs.phase != Enums.Phase.PIAZZA: return false
	if col < 0 or col >= gs.grid.n_cols: return false
	var p := gs.current_player()
	if p.workers_used >= p.workers: return false
	# "Potete avere al massimo un vostro lavoratore per colonna."
	if col in p.worker_cols: return false
	p.workers_used += 1
	p.worker_cols.append(col)
	_last_protected = null
	if protect != null and protect.owner == p.index and protect.covers(col) and protect.is_standing():
		protect.protection += int(CardDB.constants["protection_bonus"])
		protect.protected_by = p.index
		_last_protected = protect
	EraRules.activate(gs, p.index, col)
	_activated_col = col
	gs.phase = Enums.Phase.AZIONE
	state_changed.emit()
	return true

# ---- fase 3: azioni -------------------------------------------------
# Costruire: nella colonna attivata o in una adiacente.
# `despoil` e' il rudere opzionalmente depredato (spoliazione).
func build(card_id: String, col_from: int, above: bool, pay_option: int = 0, despoil: Building = null) -> bool:
	if gs.phase != Enums.Phase.AZIONE: return false
	if abs(col_from - _activated_col) > 1: return false
	if not card_id in gs.market: return false
	var p := gs.current_player()
	var data: Dictionary = CardDB.buildings[card_id]
	var q := BuildRules.quote_above(gs, p.index, data, col_from, despoil) if above \
		else BuildRules.quote_rail(gs, p.index, data, col_from, despoil)
	if not q.legal:
		gs.log_line("Costruzione rifiutata: %s" % q.reason)
		return false
	var opts := BuildRules.flexible_options(data, q.pietra, q.oro)
	var cost: Vector2i = opts[clamp(pay_option, 0, opts.size() - 1)]
	if not p.can_pay(cost.x, cost.y): return false
	p.pay(cost.x, cost.y)
	if q.terrapieno_free_applied:
		p.terrapieno_free_used = true
	if q.terrapieno_pietra > 0:
		p.bump("terrapieno_pietra", q.terrapieno_pietra)

	# La spoliazione si risolve PRIMA di costruire: il rudere e' gia' rovina,
	# e resta del suo proprietario.
	if q.despoiled != null:
		q.despoiled.state = Enums.BuildingState.ROVINA
		q.despoiled.upgrades.clear()
		gs.log_line("%s depredato: diventa rovina" % q.despoiled.data["name"])
		building_changed.emit(q.despoiled)

	# Il cambio di stato tocca le basi su cui si poggia: lo spianamento del
	# proprio intatto, il rudere schiacciato in rovina. Il SOTTERRAMENTO no:
	# e' una condizione di posizione e si ricalcola sotto, quando il nuovo
	# edificio e' gia' sulla griglia (Grid.refresh_buried).
	for base in q.bases:
		if base in q.razed:
			base.was_razed = true
			base.state = Enums.BuildingState.ROVINA
		elif base.state == Enums.BuildingState.RUDERE:
			base.state = Enums.BuildingState.ROVINA
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
	gs.grid.refresh_buried()
	Effects.apply_on_build(gs, p.index, b)
	if above:
		for c in range(b.col_from, b.col_to): gs.grid.risen_this_era[c] = true
	p.buildings_built += 1
	if int(data["lampo"]) > 0: p.add_vp("lampo", int(data["lampo"]))
	gs.market.erase(card_id)
	_refill(gs.market, gs.building_decks[gs.era], int(CardDB.constants["market_size"]))
	building_placed.emit(b)
	_end_turn()
	return true

# Potenziare: carta dalla fila, sotto un tuo edificio in piedi della colonna attivata.
func upgrade(upg_id: String, target: Building) -> bool:
	if gs.phase != Enums.Phase.AZIONE: return false
	if target == null or not target.covers(_activated_col): return false
	var p := gs.current_player()
	var q := ActionRules.quote_upgrade(gs, p.index, upg_id, target)
	if not q.legal:
		gs.log_line("Potenziamento rifiutato: %s" % q.reason)
		return false
	if not p.can_pay(q.pietra, q.oro): return false
	# Il Vescovo si consuma qui, non nel preventivo: il preventivo viene
	# chiesto anche solo per sapere se l'azione e' legale.
	var vescovo := Effects.player_override(gs, p.index, "free_upgrade_of_class", target)
	if not vescovo.is_empty():
		Effects.consume_override(gs, p.index, vescovo[1])
		gs.log_line("%s: potenziamento gratuito su %s" % [vescovo[1]["name"], target.data["name"]])
	# Artista di corte: il +1 cultura e' una tantum e va a CHI PIAZZA la carta,
	# mentre l'oro a ogni attivazione resta attaccato all'edificio per tutta la
	# partita - anche quando il personaggio, che dura un'era, e' gia' sparito.
	if target.owner != p.index:
		var artista := Effects.player_override(gs, p.index, "upgrade_on_others_building")
		if not artista.is_empty():
			Effects.consume_override(gs, p.index, artista[1])
			var subito := int(artista[0].get("value", 0))
			if subito > 0: p.add_vp("cultura", subito)
			var rendita := int(artista[0].get("oro", 0))
			if rendita > 0:
				target.patrons[p.index] = int(target.patrons.get(p.index, 0)) + rendita
			gs.log_line("%s: giocatore %d firma %s e ne incassa %d oro a ogni attivazione" % [
				artista[1]["name"], p.index, target.data["name"], rendita])
	p.pay(q.pietra, q.oro)
	target.upgrades.append(upg_id)
	# Gli effetti vengono dai dati della carta, con l'edificio ospite come
	# sorgente dei selettori. Prima il cubetto nero dei Struttura era un caso
	# speciale sulla famiglia: ora e' un effetto `resistance` come gli altri.
	Effects.apply_on_acquire(gs, p.index, CardDB.upgrades[upg_id], target)
	p.bump("potenziamenti_piazzati")
	gs.upg_row.erase(upg_id)
	_refill(gs.upg_row, gs.upg_decks[gs.era], int(CardDB.constants["side_rows"]))
	gs.log_line("%s potenziato con %s" % [target.data["name"], CardDB.upgrades[upg_id]["name"]])
	building_changed.emit(target)
	_end_turn()
	return true

# Restaurare: stessa azione del potenziamento. Il rudere torna intatto,
# la Vetusta' si azzera e, se era altrui, cambia proprietario.
func restore(target: Building) -> bool:
	if gs.phase != Enums.Phase.AZIONE: return false
	if target == null or not target.covers(_activated_col): return false
	var p := gs.current_player()
	var q := ActionRules.quote_restore(gs, p.index, target)
	if not q.legal:
		gs.log_line("Restauro rifiutato: %s" % q.reason)
		return false
	if not p.can_pay(q.pietra, q.oro): return false
	p.pay(q.pietra, q.oro)
	target.state = Enums.BuildingState.INTATTO
	target.vetusta = 0
	p.bump("restauri")
	var stolen := target.owner != p.index
	target.owner = p.index
	gs.log_line("%s restaurato%s" % [target.data["name"], " e appropriato" if stolen else ""])
	building_changed.emit(target)
	_end_turn()
	return true

# Reclutare: il lavoratore appena piazzato si specializza fino a fine era.
# `imprint_target` serve solo ai due personaggi Impronta, che si infilano sotto
# un edificio a scelta del giocatore.
func recruit(char_id: String, imprint_target: Building = null) -> bool:
	if gs.phase != Enums.Phase.AZIONE: return false
	var p := gs.current_player()
	var q := ActionRules.quote_recruit(gs, p.index, char_id, _activated_col, imprint_target)
	if not q.legal:
		gs.log_line("Reclutamento rifiutato: %s" % q.reason)
		return false
	if not p.can_pay(q.pietra, q.oro): return false
	p.pay(q.pietra, q.oro)
	p.specialized_characters.append(char_id)
	p.recruited_total += 1
	# Il lavoratore appena piazzato si specializza: l'edificio che abita e' il
	# bersaglio degli effetti che parlano di "questo lavoratore".
	var data: Dictionary = CardDB.characters[char_id]
	var host: Building = imprint_target if data.get("imprint", false) else _last_protected
	if _last_protected != null:
		p.character_targets[char_id] = _last_protected.uid
	Effects.apply_on_acquire(gs, p.index, data, host)
	if data.get("imprint", false):
		# La carta e' gia' infilata sotto l'edificio: non resta in mano al
		# giocatore, quindi non viene sepolta di nuovo a fine era come scheletro.
		imprint_target.imprint = char_id
		p.specialized_characters.erase(char_id)
		gs.log_line("%s: Impronta sotto %s" % [data["name"], imprint_target.data["name"]])
	gs.char_row.erase(char_id)
	_refill(gs.char_row, gs.char_decks[gs.era], int(CardDB.constants["side_rows"]))
	gs.log_line("Reclutato %s" % CardDB.characters[char_id]["name"])
	_end_turn()
	return true

# Dinastia: quarto lavoratore permanente, attivo da subito. Una sola a testa.
func buy_dynasty() -> bool:
	if gs.phase != Enums.Phase.AZIONE: return false
	var p := gs.current_player()
	var q := ActionRules.quote_dynasty(gs, p.index)
	if not q.legal:
		gs.log_line("Dinastia rifiutata: %s" % q.reason)
		return false
	if not p.can_pay(q.pietra, q.oro): return false
	p.pay(q.pietra, q.oro)
	p.has_dynasty = true
	p.workers += 1          # "attivo da subito e per tutte le ere che restano"
	gs.dynasties_left -= 1
	gs.log_line("Giocatore %d acquista la Dinastia" % p.index)
	_end_turn()
	return true

func pass_action() -> void:
	if gs.phase == Enums.Phase.AZIONE: _end_turn()

# Mercante di ossidiana: "per l'era, fino a 2 scambi pietra<->oro alla pari".
# Decisione del designer: alla pari e' 1:1, si scambia durante il proprio
# turno, e le due volte possono andare nella stessa direzione o in direzioni
# opposte. Non e' l'azione dell'era: scambiare non consuma il turno, ne'
# richiede la colonna attivata.
func exchange(pietra_in_oro: bool) -> bool:
	if gs.phase != Enums.Phase.PIAZZA and gs.phase != Enums.Phase.AZIONE: return false
	var p := gs.current_player()
	var e := Effects.player_override(gs, p.index, "resource_exchange")
	if e.is_empty(): return false        # non ce l'ha, o le due volte sono finite
	if pietra_in_oro:
		if p.pietra < 1: return false
		p.pietra -= 1
		p.oro += 1
	else:
		if p.oro < 1: return false
		p.oro -= 1
		p.pietra += 1
	Effects.consume_override(gs, p.index, e[1])
	gs.log_line("%s: giocatore %d scambia 1 %s con 1 %s" % [e[1]["name"], p.index,
		"pietra" if pietra_in_oro else "oro", "oro" if pietra_in_oro else "pietra"])
	return true

# ---- avanzamento ---------------------------------------------------
func _end_turn() -> void:
	# I Monumenti si reclamano nell'istante in cui la condizione e' soddisfatta,
	# quindi vanno controllati dopo ogni azione, non a fine partita.
	Conditions.claim_monuments(gs)
	gs.phase = Enums.Phase.PIAZZA
	if _advance_to_next_player():
		state_changed.emit()
	else:
		_finish_era()

# Sceglie chi gioca ora: prima la sequenza esplicita (snake), poi il giro
# normale fra chi ha ancora lavoratori. false = l'era e' finita.
func _advance_to_next_player() -> bool:
	while not gs.turn_sequence.is_empty():
		var cand: int = gs.turn_sequence.pop_front()
		if _has_worker(cand):
			gs.turn_pos = gs.turn_order.find(cand)
			gs.current_index = cand
			return true
	for _i in gs.n_players:
		gs.turn_pos = (gs.turn_pos + 1) % gs.n_players
		var c: int = gs.turn_order[gs.turn_pos]
		if _has_worker(c):
			gs.current_index = c
			return true
	return false

func _has_worker(i: int) -> bool:
	var p: PlayerState = gs.players[i]
	return p.workers_used < p.workers

func _finish_era() -> void:
	EraRules.end_era(gs)
	Conditions.claim_monuments(gs)      # l'evento puo' aver cambiato la plancia
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
