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
signal choice_required(choice: Dictionary)
signal game_ended(winner: int)

var gs: GameState
# La colonna attivata e l'edificio abitato stanno nello STATO
# (gs.colonna_attivata, gs.protetto_uid): vedi il commento in GameState.
var _omaggi_da_piazzare: Array = []   # potenziamenti dell'Eruzione in attesa di bersaglio

# ---- setup ---------------------------------------------------------
func new_game(n_players: int, seed_value: int) -> void:
	gs = GameState.new()
	gs.rng.seed = seed_value
	gs.n_players = n_players
	for i in n_players:
		var p := PlayerState.new(i)
		p.pietra = int(CardDB.constants["start_resources"]["pietra"])
		p.idee = int(CardDB.constants["start_resources"].get("idee", 0))
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
		# Le sagome "da N giocatori in su" (`min_players`, registro 110: i
		# doppioni e le abitazioni di prova a quattro) entrano nel mazzo solo
		# se al tavolo ci sono abbastanza giocatori, come le tessere in piu'.
		var ids := CardDB.buildings_of_era(e).filter(
			func(b): return int(b.get("min_players", 0)) <= n_players
		).map(func(b): return b["id"])
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

	# "Rivelate tanti Monumenti celebri quanti sono i giocatori meno uno":
	# salvo la costante `monumenti_rivelati_by_players` (registro 110, la
	# prova del secondo Monumento a due), assente dove vale la regola.
	var mons := CardDB.monuments.keys()
	_shuffle(mons)
	var quanti_mon: int = max(0, n_players - 1)
	var tab = CardDB.constants.get("monumenti_rivelati_by_players", null)
	if tab is Dictionary and tab.has(str(n_players)): quanti_mon = int(tab[str(n_players)])
	for i in quanti_mon:
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
	# Con il draft (v2) in fila ci sono TUTTI i Personaggi dell'era: si
	# sceglie fra quelli, gli avanzi si scartano a fine era (D7).
	_refill(gs.char_row, gs.char_decks[era], gs.char_decks[era].size() if draft_v2() else side)
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
	# Le tessere si rigirano: ogni effetto vale di nuovo (registro 100).
	gs.tessere_usate.clear()
	for _c in gs.grid.n_cols: gs.tessere_usate.append(false)
	gs.phase = Enums.Phase.PIAZZA
	Conditions.claim_monuments(gs)      # il Pantheon guarda l'inizio dell'era Moderna
	gs.log_line("Inizia l'era %d. Evento: %s" % [era, gs.current_event.get("name", "nessuno")])
	if draft_v2():
		gs.draft_pending.assign(gs.turn_order)
		_prosegui_draft()
		return
	_primo_turno_dell_era()

func _primo_turno_dell_era() -> void:
	if _advance_to_next_player():
		state_changed.emit()
	else:
		_finish_era()

# ---- il draft dei Personaggi (v2) ------------------------------------
# "All'inizio dell'era ogni giocatore a turno sceglie un Personaggio tra
# quelli disponibili" (punto 8 della proposta): gratis, senza lavoratore, in
# ordine di turno (primo chi ha costruito meno). Le Impronte e l'"uno a tua
# scelta" vogliono un edificio: si sceglie prima la carta, poi il bersaglio,
# in due domande. Chi non ha nessuna carta prendibile salta. Reclutare come
# azione non esiste piu'.
func draft_v2() -> bool:
	return bool(CardDB.constants.get("draft_personaggi", false))

func _prosegui_draft() -> void:
	while not gs.draft_pending.is_empty():
		var chi: int = gs.draft_pending[0]
		var opzioni := _opzioni_draft(chi)
		if opzioni.is_empty():
			gs.draft_pending.pop_front()
			continue
		gs.current_index = chi
		gs.pending_choice = {
			"player": chi,
			"kind": "draft",
			"prompt": "Era %d: scegli il tuo Personaggio" % gs.era,
			"options": opzioni,
		}
		choice_required.emit(gs.pending_choice)
		return
	gs.pending_choice = {}
	_primo_turno_dell_era()

# Le opzioni sono POSIZIONI nella fila (`char_row`), perche' le scelte
# viaggiano come interi. Una carta che vuole un bersaglio e non ne ha (un'
# Impronta senza edifici) non si offre.
func _opzioni_draft(chi: int) -> Array[int]:
	var out: Array[int] = []
	for i in gs.char_row.size():
		var d: Dictionary = CardDB.characters[gs.char_row[i]]
		if bool(d.get("imprint", false)):
			if ActionRules.imprint_candidates(gs, chi, d).is_empty(): continue
		elif Effects.requires_designation(d):
			if ActionRules.designation_candidates(gs, chi, d).is_empty(): continue
		out.append(i)
	return out

func _draft_scegli(posto: int) -> void:
	var chi := int(gs.pending_choice["player"])
	var char_id: String = gs.char_row[posto]
	var d: Dictionary = CardDB.characters[char_id]
	var candidati: Array[Building] = []
	if bool(d.get("imprint", false)):
		candidati = ActionRules.imprint_candidates(gs, chi, d)
	elif Effects.requires_designation(d):
		candidati = ActionRules.designation_candidates(gs, chi, d)
	if candidati.is_empty():
		_draft_prendi(chi, char_id, null)
		return
	if candidati.size() == 1:
		_draft_prendi(chi, char_id, candidati[0])
		return
	var uids: Array[int] = []
	for b in candidati: uids.append(b.uid)
	gs.pending_choice = {
		"player": chi,
		"kind": "draft_bersaglio",
		"char_id": char_id,
		"prompt": "%s: scegli l'edificio" % d["name"],
		"options": uids,
	}
	choice_required.emit(gs.pending_choice)

func _draft_prendi(chi: int, char_id: String, bersaglio: Building) -> void:
	var p: PlayerState = gs.players[chi]
	var data: Dictionary = CardDB.characters[char_id]
	p.specialized_characters.append(char_id)
	p.recruited_total += 1
	p.bump("draftati")
	if Effects.requires_designation(data) and bersaglio != null:
		p.character_targets[char_id] = bersaglio.uid
		gs.log_line("%s: designato %s" % [data["name"], bersaglio.data["name"]])
	# Senza lavoratore non c'e' un edificio "abitato": i protettori (+1 res,
	# "la sua protezione vale +3") si legano al primo edificio che il
	# giocatore costruisce nell'era (D7), vedi `_protettori_sul_nuovo`.
	Effects.apply_on_acquire(gs, chi, data, bersaglio if bool(data.get("imprint", false)) else null)
	if bool(data.get("imprint", false)):
		bersaglio.imprint = char_id
		p.specialized_characters.erase(char_id)
		gs.log_line("%s: Impronta sotto %s" % [data["name"], bersaglio.data["name"]])
	gs.char_row.erase(char_id)
	gs.log_line("Giocatore %d prende %s" % [chi, data["name"]])
	gs.pending_choice = {}
	gs.draft_pending.pop_front()
	_prosegui_draft()

# Nel draft nessun lavoratore abita un edificio: la carta che parla di "questo
# lavoratore" aspetta il primo edificio costruito nell'era e ci si lega.
func _protettori_sul_nuovo(b: Building, p: PlayerState) -> void:
	for cid in p.specialized_characters:
		if p.character_targets.has(cid): continue
		var data: Dictionary = CardDB.characters[cid]
		var legato := false
		for e in data.get("effects", []):
			if e["hook"] == "on_acquire" and e["op"] == "protection_delta":
				b.protection += int(e["value"])
				legato = true
				gs.log_line("%s: %s protetto meglio (+%d)" % [data["name"], b.data["name"], int(e["value"])])
			elif e.get("condition", {}).get("op", "") == "protected_survived":
				legato = true
		if legato: p.character_targets[cid] = b.uid

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

# ---- il turno della v2 ----------------------------------------------
# TURNO V2 (registro 93, costante `turno_v2`, vera nel file v2): niente fasi.
# Ogni turno il giocatore fa UNA cosa e ci mette un lavoratore, che va dove
# agisce (punto 8 della proposta): attiva una colonna; costruisce (il
# lavoratore va sull'edificio nuovo, lo protegge con +2 e attiva solo quello);
# potenzia (il lavoratore resta sotto l'edificio come scheletro); ristruttura
# una propria rovina; recluta; compra la Dinastia; o passa e incassa. Con i
# dati v1.5 la costante non c'e' e il turno e' PIAZZA -> ATTIVA -> AZIONE.
# Le letture adottate dove la proposta tace sono le D9-D14 dell'audit.
func turno_v2() -> bool:
	return bool(CardDB.constants.get("turno_v2", false))

# Un'azione si puo' fare: nella v1.5 dopo aver attivato (fase AZIONE), nella
# v2 all'inizio del turno, con un lavoratore ancora da piazzare.
func _puo_agire() -> bool:
	if turno_v2(): return gs.phase == Enums.Phase.PIAZZA and _has_worker(gs.current_index)
	return gs.phase == Enums.Phase.AZIONE

# Nel turno v2 l'azione E' il piazzamento del lavoratore. Il contatore
# `az_<azione>` si tiene con tutti e due i turni: il torneo conta le azioni
# fatte per giocatore anche a quattro lavoratori.
func _spendi_lavoratore(azione: String) -> void:
	var p := gs.current_player()
	p.bump("az_" + azione)
	if turno_v2(): p.workers_used += 1

# Il lavoratore va sull'edificio (costruito o ristrutturato) e lo protegge
# per l'era, come oggi il lavoratore piazzato sopra un proprio edificio.
func _lavoratore_su(b: Building, p: PlayerState) -> void:
	b.protection += int(CardDB.constants["protection_bonus"])
	b.protected_by = p.index

# ---- fase 1+2: piazza e attiva --------------------------------------
func place_worker(col: int, protect: Building = null) -> bool:
	if not gs.pending_choice.is_empty(): return false
	if gs.phase != Enums.Phase.PIAZZA: return false
	if col < 0 or col >= gs.grid.n_cols: return false
	var p := gs.current_player()
	if p.workers_used >= p.workers: return false
	# "Potete avere al massimo un vostro lavoratore per colonna."
	if col in p.worker_cols: return false
	p.workers_used += 1
	p.worker_cols.append(col)
	gs.protetto_uid = -1
	# V2: il lavoratore sulla colonna non abita nessun edificio (D11: protegge
	# solo chi costruisce).
	if turno_v2(): protect = null
	if protect != null and protect.owner == p.index and protect.covers(col) and protect.is_standing():
		protect.protection += int(CardDB.constants["protection_bonus"])
		protect.protected_by = p.index
		gs.protetto_uid = protect.uid
	EraRules.activate(gs, p.index, col)
	gs.colonna_attivata = col
	p.bump("az_colonna")
	if turno_v2():
		# Attivare la colonna e' l'azione intera del turno.
		_end_turn()
		return true
	gs.phase = Enums.Phase.AZIONE
	state_changed.emit()
	return true

# ---- fase 3: azioni -------------------------------------------------
# Costruire: nella colonna attivata o in una adiacente.
# `despoil` e' il rudere opzionalmente depredato (spoliazione).
func build(card_id: String, col_from: int, above: bool, pay_option: int = 0, despoil: Building = null) -> bool:
	if not _puo_agire(): return false
	if not gs.pending_choice.is_empty(): return false
	# V2: si costruisce in qualsiasi colonna legale (D9), non solo vicino alla attivata.
	if not turno_v2() and abs(col_from - gs.colonna_attivata) > 1: return false
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
	if not p.can_pay(cost.x, cost.y, q.idee): return false
	p.pay(cost.x, cost.y, q.idee)
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
		# Sopra chi si costruisce: contatori per l'audit (registro 87, "non si
		# spinge troppo a sotterrare i propri?"). Non toccano il gioco.
		p.bump("sopra_propri" if base.owner == p.index else "sopra_altrui")
		if base in q.razed:
			p.bump("spianati")
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
	# Il binario e' quello che il preventivo ha scelto: con ogni era nel suo
	# binario e' l'era stessa, coi binari liberi puo' essere un altro, e da
	# qui in poi lo deve sapere l'edificio - se no la vista lo disegna sul
	# binario sbagliato e il posto risulta libero a chi costruisce dopo.
	b.binario = q.binario
	b.col_from = col_from
	b.col_to = col_from + int(data["width"])
	b.level = q.level
	# Dove si e' riportata terra per poggiarlo: lo sa il preventivo, e da
	# qui in poi deve saperlo l'edificio, se no la vista lo disegna
	# sospeso sopra il vuoto.
	b.terrapieno_cols = q.terrapieno_cols.duplicate()
	# E su chi poggia. Anche questo lo sa il preventivo, e da qui in poi lo
	# deve sapere l'edificio: la sua quota si legge da loro, e se la si
	# ricavasse ogni volta da quel che c'e' in colonna, un edificio nuovo a
	# quota zero in un altro binario gliela sposterebbe sotto i piedi.
	for base in q.bases: b.basi.append(base.uid)
	b.bonus_res = q.continuity_bonus
	if EraRules.tessere_una_volta(gs):
		# V2 (registro 100): la collina da' +1 per l'era al primo edificio
		# costruito qui, la pianura ha scontato la carta larga: le tessere si girano.
		if gs.grid.terrains[col_from] == Enums.Terrain.COLLINA and EraRules.tessera_disponibile(gs, col_from):
			b.protection += 1
			EraRules.usa_tessera(gs, col_from, "+1 resistenza a %s per l'era" % b.data["name"])
		if BuildRules.pianura_discount(gs, data, col_from) > 0:
			EraRules.usa_tessera(gs, col_from, "-1 Costruzione a %s" % b.data["name"])
	elif gs.grid.terrains[col_from] == Enums.Terrain.COLLINA:
		b.bonus_res += 1
	b.charges = int(data.get("exhaustible", 0))
	gs.grid.buildings.append(b)
	# Chi finisce sepolto ADESSO lo ha sepolto questo giocatore: si guarda
	# prima e dopo il ricalcolo, perche' una costruzione puo' completare la
	# copertura anche di un edificio piu' in basso della sua base.
	var sepolti_prima := {}
	for altro in gs.grid.buildings: sepolti_prima[altro.uid] = altro.is_buried
	gs.grid.refresh_buried()
	for altro in gs.grid.buildings:
		if altro.is_buried and not bool(sepolti_prima.get(altro.uid, false)):
			altro.buried_by = p.index
			altro.buried_era = gs.era
			# Il premio di scavo si paga qui, sul momento, come il Lampo: il
			# livello e' quello dell'edificio appena costruito.
			var premio := Scoring.premio_scavo(altro.scavo_value(), b.level, gs.era)
			if premio > 0:
				p.add_vp("scavo", premio)
				altro.rende("scavo", premio)
				p.bump("scavo_scavato", premio)
				if gs.era >= int(CardDB.constants["eras"]): p.bump("scavo_e5", premio)
				gs.log_line("%s seppellisce %s al livello %d: premio di scavo %d" % [
					p.name, altro.data["name"], b.level, premio])
	Effects.apply_on_build(gs, p.index, b)
	if above:
		for c in range(b.col_from, b.col_to): gs.grid.risen_this_era[c] = true
	p.buildings_built += 1
	if int(data["lampo"]) > 0:
		p.add_vp("lampo", int(data["lampo"]))
		b.rende("lampo", int(data["lampo"]))
	gs.market.erase(card_id)
	_refill(gs.market, gs.building_decks[gs.era], int(CardDB.constants["market_size"]))
	_spendi_lavoratore("costruisci")
	if turno_v2():
		# Il lavoratore va sull'edificio nuovo: +2 per l'era, e attiva solo
		# quello (D10: niente base del terreno, niente Centro Urbano).
		_lavoratore_su(b, p)
		EraRules.paga_edificio(gs, b)
	# Con il draft i protettori aspettano il primo edificio costruito nell'era.
	if draft_v2(): _protettori_sul_nuovo(b, p)
	building_placed.emit(b)
	_end_turn()
	return true

# Potenziare: carta dalla fila, sotto un tuo edificio in piedi della colonna attivata.
func upgrade(upg_id: String, target: Building) -> bool:
	if not gs.pending_choice.is_empty(): return false
	if not _puo_agire(): return false
	if target == null: return false
	if not turno_v2() and not target.covers(gs.colonna_attivata): return false
	var p := gs.current_player()
	var q := ActionRules.quote_upgrade(gs, p.index, upg_id, target)
	if not q.legal:
		gs.log_line("Potenziamento rifiutato: %s" % q.reason)
		return false
	if not p.can_pay(q.pietra, q.oro, q.idee): return false
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
	p.pay(q.pietra, q.oro, q.idee)
	target.upgrades.append(upg_id)
	# Gli effetti vengono dai dati della carta, con l'edificio ospite come
	# sorgente dei selettori. Prima il cubetto nero dei Struttura era un caso
	# speciale sulla famiglia: ora e' un effetto `resistance` come gli altri.
	Effects.apply_on_acquire(gs, p.index, CardDB.upgrades[upg_id], target)
	p.bump("potenziamenti_piazzati")
	gs.upg_row.erase(upg_id)
	_refill(gs.upg_row, gs.upg_decks[gs.era], int(CardDB.constants["side_rows"]))
	gs.log_line("%s potenziato con %s" % [target.data["name"], CardDB.upgrades[upg_id]["name"]])
	_spendi_lavoratore("potenzia")
	# LO SCHELETRO DEL POTENZIAMENTO (punto 8 della proposta, registro 95): il
	# lavoratore che piazza il potenziamento resta sotto l'edificio come
	# scheletro, e vale come un Personaggio sepolto, 6 meno l'era, se
	# l'edificio finira' sotterrato. Uno solo per edificio, non nell'era
	# Moderna. Costante `scheletro_potenziamento` (vera nel file v2); nel
	# turno a un'azione era gia' cosi' (D12).
	if turno_v2() or bool(CardDB.constants.get("scheletro_potenziamento", false)):
		if gs.era < int(CardDB.constants["eras"]) and target.buried_character == "":
			target.buried_character = Building.LAVORATORE
			target.buried_character_era = gs.era
			gs.log_line("il lavoratore resta sotto %s come scheletro" % target.data["name"])
	building_changed.emit(target)
	_end_turn()
	return true

# Restaurare: stessa azione del potenziamento. Il rudere torna intatto,
# la Vetusta' si azzera e, se era altrui, cambia proprietario.
func restore(target: Building) -> bool:
	if not gs.pending_choice.is_empty(): return false
	if not _puo_agire(): return false
	if target == null: return false
	if not turno_v2() and not target.covers(gs.colonna_attivata): return false
	var p := gs.current_player()
	var q := ActionRules.quote_restore(gs, p.index, target)
	if not q.legal:
		gs.log_line("Restauro rifiutato: %s" % q.reason)
		return false
	if not p.can_pay(q.pietra, q.oro, q.idee): return false
	var bosco := ActionRules.tessera_bosco(gs, target)
	p.pay(q.pietra, q.oro, q.idee)
	if EraRules.tessere_una_volta(gs) and bosco >= 0 and int(target.data["cost"]["pietra"]) > 0:
		EraRules.usa_tessera(gs, bosco, "-1 Costruzione alla ristrutturazione di %s" % target.data["name"])
	target.state = Enums.BuildingState.INTATTO
	target.vetusta = 0
	p.bump("restauri")
	var stolen := target.owner != p.index
	target.owner = p.index
	gs.log_line("%s restaurato%s" % [target.data["name"], " e appropriato" if stolen else ""])
	# Ristrutturare (D13): la rovina torna attiva, e' di nuovo un edificio
	# intero (anche se era stato spianato).
	if bool(CardDB.constants.get("senza_rudere", false)): target.was_razed = false
	_spendi_lavoratore("ristruttura")
	if turno_v2():
		# Nel turno a un'azione il lavoratore ci resta sopra a proteggerla.
		_lavoratore_su(target, p)
	building_changed.emit(target)
	_end_turn()
	return true

# Reclutare: il lavoratore appena piazzato si specializza fino a fine era.
# `imprint_target` serve solo ai due personaggi Impronta, che si infilano sotto
# un edificio a scelta del giocatore.
func recruit(char_id: String, imprint_target: Building = null) -> bool:
	if not gs.pending_choice.is_empty(): return false
	if draft_v2(): return false          # i Personaggi si prendono nel draft
	if not _puo_agire(): return false
	var p := gs.current_player()
	# V2: nessuna colonna attivata, la classe si cerca fra i propri edifici.
	var q := ActionRules.quote_recruit(gs, p.index, char_id,
		-1 if turno_v2() else gs.colonna_attivata, imprint_target)
	if not q.legal:
		gs.log_line("Reclutamento rifiutato: %s" % q.reason)
		return false
	if not p.can_pay(q.pietra, q.oro, q.idee): return false
	p.pay(q.pietra, q.oro, q.idee)
	p.specialized_characters.append(char_id)
	p.recruited_total += 1
	# Il lavoratore appena piazzato si specializza: l'edificio che abita e' il
	# bersaglio degli effetti che parlano di "questo lavoratore".
	var data: Dictionary = CardDB.characters[char_id]
	var protetto := _protetto()
	var host: Building = imprint_target if data.get("imprint", false) else protetto
	if protetto != null:
		p.character_targets[char_id] = protetto.uid
	# "Uno a tua scelta": la designazione vince sull'edificio abitato, perche'
	# e' una scelta del giocatore e non una conseguenza di dove ha messo il
	# lavoratore.
	if Effects.requires_designation(data) and imprint_target != null:
		p.character_targets[char_id] = imprint_target.uid
		gs.log_line("%s: designato %s" % [data["name"], imprint_target.data["name"]])
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
	_spendi_lavoratore("recluta")
	_end_turn()
	return true

# Dinastia: quarto lavoratore permanente, attivo da subito. Una sola a testa.
func buy_dynasty() -> bool:
	if not _puo_agire(): return false
	if not gs.pending_choice.is_empty(): return false
	var p := gs.current_player()
	var q := ActionRules.quote_dynasty(gs, p.index)
	if not q.legal:
		gs.log_line("Dinastia rifiutata: %s" % q.reason)
		return false
	if not p.can_pay(q.pietra, q.oro, q.idee): return false
	p.pay(q.pietra, q.oro, q.idee)
	p.has_dynasty = true
	p.workers += 1          # "attivo da subito e per tutte le ere che restano"
	gs.dynasties_left -= 1
	gs.log_line("Giocatore %d acquista la Dinastia" % p.index)
	_spendi_lavoratore("dinastia")
	_end_turn()
	return true

# L'interfaccia deve sapere a quale colonna e' legata l'azione: il regolamento
# dice "sempre legata alla colonna che avete appena attivato".
func colonna_attivata() -> int:
	return gs.colonna_attivata

# L'edificio abitato dal lavoratore di questo turno, cercato per uid nello stato.
func _protetto() -> Building:
	if gs.protetto_uid < 0: return null
	for b in gs.grid.buildings:
		if b.uid == gs.protetto_uid: return b
	return null

func pass_action(scelta := "pietra") -> void:
	if passa_incasso():
		passa(scelta)
		return
	if gs.phase == Enums.Phase.AZIONE:
		gs.current_player().bump("az_passa")
		_end_turn()

# L'INCASSO AL PASSAGGIO (registro 109, costante `passa_incasso`, spenta dove
# manca): anche nel turno della v1.5 chi non fa l'azione dopo l'attivazione
# incassa 1 Costruzione piu' 1 risorsa a scelta. Nasce dalla dodicesima
# misura: a quattro giocatori sedici turni per era contro dodici sagome, e un
# turno a testa a era finiva senza niente da fare. Nel turno a un'azione
# l'incasso c'era gia' (D14).
func passa_incasso() -> bool:
	return turno_v2() or bool(CardDB.constants.get("passa_incasso", false))

# V2, "passare e incassare" (D14): il lavoratore va sulla plancia e si incassa
# 1 Costruzione piu' 1 risorsa a scelta (`passa_incasso_pietra`,
# `passa_incasso_scelta`). Cosi' l'era finisce come sempre, quando finiscono
# i lavoratori, senza una regola "tutti hanno passato".
func passa(scelta := "oro") -> bool:
	if not passa_incasso(): return false
	if not _puo_agire() or not gs.pending_choice.is_empty(): return false
	var p := gs.current_player()
	var base := int(CardDB.constants.get("passa_incasso_pietra", 1))
	var extra := int(CardDB.constants.get("passa_incasso_scelta", 1))
	match scelta:
		"oro": p.gain(base, extra)
		"idee": p.gain(base, 0, extra)
		_: p.gain(base + extra, 0)
	_spendi_lavoratore("passa")
	gs.log_line("Giocatore %d passa e incassa %d pietra e %d %s" % [p.index, base, extra, scelta])
	_end_turn()
	return true

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

# La fine dell'era si interrompe se il gioco deve chiedere qualcosa: il
# potenziamento dell'Eruzione va infilato SUBITO, cioe' prima del censimento,
# ma dove lo decide il giocatore. Percio' la sequenza e' divisa in pezzi e
# puo' sospendersi in mezzo.
func _finish_era() -> void:
	var persi := EraRules.resolve_event(gs)
	_omaggi_da_piazzare = EraRules.draw_gifts(gs, persi)
	_prosegui_fine_era()

func _prosegui_fine_era() -> void:
	while not _omaggi_da_piazzare.is_empty():
		var o: Dictionary = _omaggi_da_piazzare[0]
		var chi := int(o["player"])
		var ospiti := EraRules.possible_hosts(gs, chi)
		if ospiti.is_empty():
			_omaggi_da_piazzare.pop_front()          # nessun posto: si perde
			continue
		if ospiti.size() == 1:
			# un solo bersaglio non e' una scelta: non si disturba nessuno
			EraRules.place_gift(gs, o, ospiti[0])
			_omaggi_da_piazzare.pop_front()
			continue
		var uid_possibili: Array[int] = []
		for b in ospiti: uid_possibili.append(b.uid)
		gs.pending_choice = {
			"player": chi,
			"kind": "ospite_omaggio",
			"prompt": "%s: scegli dove infilare %s" % [gs.current_event["name"],
				CardDB.upgrades[str(o["upg_id"])]["name"]],
			"options": uid_possibili,
		}
		gs.phase = Enums.Phase.FINE_ERA
		choice_required.emit(gs.pending_choice)
		return
	gs.pending_choice = {}
	_completa_fine_era()

# Risolve la scelta in sospeso. Unico modo per farla: come ogni altra cosa,
# passa dal controller.
func choose(uid: int) -> bool:
	if gs.pending_choice.is_empty(): return false
	if not uid in (gs.pending_choice["options"] as Array): return false
	match str(gs.pending_choice.get("kind", "")):
		"draft":
			_draft_scegli(uid)
			return true
		"draft_bersaglio":
			_draft_prendi(int(gs.pending_choice["player"]), str(gs.pending_choice["char_id"]), _per_uid(uid))
			return true
	var o: Dictionary = _omaggi_da_piazzare.pop_front()
	EraRules.place_gift(gs, o, _per_uid(uid))
	gs.pending_choice = {}
	_prosegui_fine_era()
	return true

func _per_uid(uid: int) -> Building:
	for b in gs.grid.buildings:
		if b.uid == uid: return b
	return null

func _completa_fine_era() -> void:
	EraRules.end_era_after_event(gs)
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
