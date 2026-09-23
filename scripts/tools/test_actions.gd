# res://scripts/tools/test_actions.gd
# Test unitari delle azioni della Milestone 2: legalita', effetto e casi di
# rifiuto di potenziare, restaurare, reclutare, Dinastia, spoliazione, piu'
# sepoltura dei personaggi, ordine di turno e snake.
# Uso:  godot --headless res://scenes/test_actions.tscn   (esce 1 se fallisce)
#
# Le attese si ricavano da CardDB, non da numeri fissi: se i dati cambiano il
# test resta valido (principio 3 del brief).
extends Node

var _passed := 0
var _failed := 0

func _ready() -> void:
	_run("potenziare", _test_upgrade)
	_run("restaurare", _test_restore)
	_run("reclutare", _test_recruit)
	_run("Dinastia", _test_dynasty)
	_run("spoliazione", _test_despoil)
	_run("sepoltura dei personaggi", _test_burial)
	_run("ordine di turno e snake", _test_turn_order)
	_run("un lavoratore per colonna", _test_worker_per_column)
	_run("dispersione dei secoli", _test_disperse)
	_run("il libro mastro degli edifici torna col tabellone", _test_libro_mastro)
	_run("i binari liberi, la prova spenta", _test_binari_liberi)
	_run("la copia dello stato", _test_copia_dello_stato)
	_run("le mosse si valutano dopo l'attivazione", _test_valuta_dopo_attivazione)
	_run("il bot che pianifica l'era", _test_pianificatore)
	_run("la versione vecchia del bot", _test_versione_del_bot)
	_run("i bot con una strategia giocano davvero", _test_strategie)
	print("\n%d superati, %d falliti" % [_passed, _failed])
	get_tree().quit(0 if _failed == 0 else 1)

func _run(name: String, f: Callable) -> void:
	print("\n— %s" % name)
	f.call()

# Ogni edificio si segna quanto ha fruttato. Non e' un conto a parte: sono gli
# stessi punti che finiscono sul tabellone, visti dalla carta invece che dal
# giocatore. Quindi devono tornare, canale per canale, su partite vere.
func _test_libro_mastro() -> void:
	var canali := ["lampo", "rendita", "scavo", "scheletri", "verticalita"]
	var storte := 0
	var esempio := ""
	for g in 8:
		var ctl := _game(3, 500 + g)
		var guard := 0
		while ctl.gs.phase != Enums.Phase.FINE_PARTITA and guard < 10000:
			RandomBot.play_turn(ctl)
			guard += 1
		# Si confrontano i totali del tavolo, non quelli di un giocatore: il
		# libro mastro sta sulla CARTA, e una carta puo' cambiare padrone
		# (un restauro se la prende). I punti che ha fruttato restano suoi
		# anche quando a incassarli e' stato qualcun altro.
		var dal_tabellone := {}
		for p in ctl.gs.players:
			for c in p.vp_breakdown:
				dal_tabellone[c] = int(dal_tabellone.get(c, 0)) + int(p.vp_breakdown[c])
		var dalle_carte := {}
		for b in ctl.gs.grid.buildings:
			for c in b.vp_reso:
				dalle_carte[c] = int(dalle_carte.get(c, 0)) + int(b.vp_reso[c])
		for c in canali:
			var tabellone := int(dal_tabellone.get(c, 0))
			var carte := int(dalle_carte.get(c, 0))
			# NESSUNA TOLLERANZA, nemmeno sulla Verticalita'. Prima ne aveva
			# una di un punto per colonna, perche' la meta' divisa veniva
			# arrotondata carta per carta e la somma non tornava; adesso la
			# quota del giocatore si spezza fra le sue carte col resto piu'
			# grande (Scoring._spezza) e i due conti sono lo stesso numero.
			if tabellone != carte:
				storte += 1
				if esempio == "":
					esempio = "partita %d, %s: tabellone %d, carte %d" % [
						500 + g, c, tabellone, carte]
	_ok("su 8 partite intere ogni canale torna%s" % ("" if esempio == "" else " (%s)" % esempio), storte == 0)

# I bot con strategia devono (a) finire le partite senza incastrarsi, (b)
# battere nettamente chi tira a caso e (c) distinguersi l'uno dall'altro: se
# due strategie fanno gli stessi punti negli stessi canali, sono una sola.
func _test_strategie() -> void:
	var a_caso := 0
	var punti := {}
	var carte := {}
	for strat in StrategyBot.STRATEGIE:
		punti[strat] = 0
		carte[strat] = {"rendita": 0, "lampo": 0, "scavo": 0, "sopra": 0}
	var finite := 0
	for g in 6:
		# stessa partita, stesso seme: cambia solo chi siede al posto 0
		var base := _game(3, 700 + g)
		var guard := 0
		while base.gs.phase != Enums.Phase.FINE_PARTITA and guard < 10000:
			RandomBot.play_turn(base)
			guard += 1
		a_caso += base.gs.players[0].vp
		for strat in StrategyBot.STRATEGIE:
			var ctl := _game(3, 700 + g)
			var giri := 0
			while ctl.gs.phase != Enums.Phase.FINE_PARTITA and giri < 10000:
				if ctl.gs.current_index == 0: StrategyBot.play_turn(ctl, strat)
				else: RandomBot.play_turn(ctl)
				giri += 1
			if ctl.gs.phase == Enums.Phase.FINE_PARTITA: finite += 1
			punti[strat] += ctl.gs.players[0].vp
			var k: Dictionary = carte[strat]
			for b in ctl.gs.grid.buildings:
				if b.owner != 0: continue
				k["rendita"] += int(b.data["rendita"])
				k["lampo"] += int(b.data["lampo"])
				k["scavo"] += int(b.data["scavo"])
				if b.level > 0: k["sopra"] += 1
	_eq("tutte le partite arrivano in fondo", finite, 6 * StrategyBot.STRATEGIE.size())
	for strat in StrategyBot.STRATEGIE:
		_ok("%s batte il caso (%d contro %d PV su 6 partite)" % [strat, punti[strat], a_caso],
			punti[strat] > a_caso)
	# Il segno di una strategia si legge in quello che COSTRUISCE, non nei
	# punti: i punti di un canale dipendono anche da cosa fanno gli altri -
	# lo Scavo lo incassa chi viene sotterrato, e a sotterrare e' l'avversario.
	var sq := func(a: String, b: String, k: String) -> void:
		_ok("%s costruisce piu' %s di %s (%d contro %d)" % [a, k, b,
			int(carte[a][k]), int(carte[b][k])], int(carte[a][k]) > int(carte[b][k]))
	sq.call("rendita", "lampo", "rendita")
	sq.call("lampo", "rendita", "lampo")
	sq.call("scavo", "rendita", "scavo")
	sq.call("verticale", "rendita", "sopra")

# ---- infrastruttura -------------------------------------------------
func _game(n := 2, seed_v := 7) -> GameController:
	var ctl := GameController.new()
	ctl.new_game(n, seed_v)
	return ctl

func _put(gs: GameState, owner: int, card_id: String, col: int,
		level := 0, state := Enums.BuildingState.INTATTO) -> Building:
	var b := Building.new()
	b.uid = gs.new_uid()
	b.data = CardDB.buildings[card_id]
	b.owner = owner
	b.era_built = gs.era
	b.col_from = col
	b.col_to = col + int(b.data["width"])
	b.level = level
	b.state = state
	gs.grid.buildings.append(b)
	return b

func _give(p: PlayerState, pietra: int, oro: int) -> void:
	p.pietra = pietra
	p.oro = oro

func _ok(label: String, cond: bool, detail := "") -> void:
	if cond:
		_passed += 1
		print("  [ok]   %s" % label)
	else:
		_failed += 1
		printerr("  [KO]   %s%s" % [label, ("  — " + detail) if detail != "" else ""])

func _eq(label: String, got, want) -> void:
	_ok(label, got == want, "atteso %s, ottenuto %s" % [want, got])

# ---- potenziare -----------------------------------------------------
func _test_upgrade() -> void:
	var ctl := _game()
	var gs := ctl.gs
	var b := _put(gs, gs.current_index, "ed_capanne", 2)
	gs.upg_row = ["po_palizzata"]
	gs.upg_decks[gs.era] = ["po_idolo"]      # unica carta reintegrabile
	ctl.place_worker(2)
	var p := gs.current_player()
	_give(p, 0, 5)
	var res_before := b.bonus_res
	var cost_oro := int(CardDB.upgrades["po_palizzata"]["cost"].get("oro", 0))

	_ok("potenziamento accettato", ctl.upgrade("po_palizzata", b))
	_eq("  cubetto nero: +1 resistenza", b.bonus_res, res_before + 1)
	_eq("  oro pagato", p.oro, 5 - cost_oro)
	_eq("  carta spesa e fila reintegrata dal mazzo", gs.upg_row, ["po_idolo"])
	_eq("  potenziamento registrato sull'edificio", b.upgrades, ["po_palizzata"])

	var ctl2 := _game()
	var gs2 := ctl2.gs
	var b2 := _put(gs2, gs2.current_index, "ed_capanne", 2)
	b2.upgrades.append("po_idolo")
	gs2.upg_row = ["po_palizzata"]
	ctl2.place_worker(2)
	_give(gs2.current_player(), 0, 5)
	_ok("rifiuta il secondo potenziamento sullo stesso edificio", not ctl2.upgrade("po_palizzata", b2))

	var ctl3 := _game()
	var gs3 := ctl3.gs
	var other := (gs3.current_index + 1) % gs3.n_players
	var b3 := _put(gs3, other, "ed_capanne", 2)
	gs3.upg_row = ["po_palizzata"]
	ctl3.place_worker(2)
	_give(gs3.current_player(), 0, 5)
	_ok("rifiuta il potenziamento su edificio altrui", not ctl3.upgrade("po_palizzata", b3))

	var ctl4 := _game()
	var gs4 := ctl4.gs
	var b4 := _put(gs4, gs4.current_index, "ed_capanne", 2)
	gs4.upg_row = []
	ctl4.place_worker(2)
	_give(gs4.current_player(), 0, 5)
	_ok("rifiuta una carta che non e' nella fila", not ctl4.upgrade("po_palizzata", b4))

	var ctl5 := _game()
	var gs5 := ctl5.gs
	var b5 := _put(gs5, gs5.current_index, "ed_capanne", 4)
	gs5.upg_row = ["po_palizzata"]
	ctl5.place_worker(2)
	_give(gs5.current_player(), 0, 5)
	_ok("rifiuta un edificio fuori dalla colonna attivata", not ctl5.upgrade("po_palizzata", b5))

	var ctl6 := _game()
	var gs6 := ctl6.gs
	var b6 := _put(gs6, gs6.current_index, "ed_capanne", 2)
	gs6.upg_row = ["po_palizzata"]
	ctl6.place_worker(2)
	_give(gs6.current_player(), 0, 0)
	_ok("rifiuta se manca l'oro", not ctl6.upgrade("po_palizzata", b6))

	# decisione del designer (punto 9): solo su edifici intatti
	var ctl9 := _game()
	var gs9 := ctl9.gs
	var rudere := _put(gs9, gs9.current_index, "ed_capanne", 2, 0, Enums.BuildingState.RUDERE)
	gs9.upg_row = ["po_palizzata"]
	ctl9.place_worker(2)
	_give(gs9.current_player(), 0, 5)
	_ok("rifiuta il potenziamento su un rudere", not ctl9.upgrade("po_palizzata", rudere))
	rudere.state = Enums.BuildingState.INTATTO
	_ok("  lo accetta appena l'edificio e' intatto", ctl9.upgrade("po_palizzata", rudere))

	# capienza dichiarata dalla carta: "salvo le carte che ne dichiarano di piu'"
	_eq("capienza base senza campo", ActionRules.upgrade_capacity(CardDB.buildings["ed_capanne"]), 1)
	for id in ["ed_chiesa", "ed_abbazia", "ed_accademia", "ed_duomo"]:
		var want := int(CardDB.buildings[id]["upgrade_slots"])
		_eq("  %s dichiara capienza %d" % [id, want], ActionRules.upgrade_capacity(CardDB.buildings[id]), want)

	# Il Duomo ne accetta 3 e rifiuta il quarto. Si interroga la regola pura:
	# passando dal controller ogni potenziamento consumerebbe il turno e il
	# bersaglio smetterebbe di essere dell'attuale giocatore.
	var ctl7 := _game()
	var gs7 := ctl7.gs
	var me7 := gs7.current_index
	var duomo := _put(gs7, me7, "ed_duomo", 2)
	gs7.upg_row = ["po_palizzata"]
	var legal_at: Array[bool] = []
	for i in 4:
		legal_at.append(ActionRules.quote_upgrade(gs7, me7, "po_palizzata", duomo).legal)
		duomo.upgrades.append("po_palizzata")
	_eq("il Duomo accetta i primi 3 potenziamenti e rifiuta il quarto",
		legal_at, [true, true, true, false] as Array[bool])

	var ctl8 := _game()
	var gs8 := ctl8.gs
	var me8 := gs8.current_index
	var capanne := _put(gs8, me8, "ed_capanne", 2)
	gs8.upg_row = ["po_palizzata"]
	var base_legal := ActionRules.quote_upgrade(gs8, me8, "po_palizzata", capanne).legal
	capanne.upgrades.append("po_palizzata")
	var base_second := ActionRules.quote_upgrade(gs8, me8, "po_palizzata", capanne).legal
	_eq("senza campo la capienza resta 1", [base_legal, base_second], [true, false])

# ---- restaurare -----------------------------------------------------
func _test_restore() -> void:
	var c: Dictionary = CardDB.buildings["ed_dolmen"]["cost"]
	var want_p := int(ceil(float(int(c["pietra"])) / 2.0))

	var ctl := _game()
	var gs := ctl.gs
	gs.grid.terrains[2] = Enums.Terrain.PIANURA
	var r := _put(gs, gs.current_index, "ed_dolmen", 2, 0, Enums.BuildingState.RUDERE)
	r.vetusta = 2
	ctl.place_worker(2)
	var p := gs.current_player()
	_give(p, 9, 9)

	_ok("restauro accettato", ctl.restore(r))
	_eq("  torna intatto", r.state, Enums.BuildingState.INTATTO)
	_eq("  Vetusta' azzerata", r.vetusta, 0)
	_eq("  meta' del costo, arrotondata per eccesso", p.pietra, 9 - want_p)

	var ctl2 := _game()
	var gs2 := ctl2.gs
	gs2.grid.terrains[2] = Enums.Terrain.PIANURA
	var me := gs2.current_index
	var other := (me + 1) % gs2.n_players
	var r2 := _put(gs2, other, "ed_dolmen", 2, 0, Enums.BuildingState.RUDERE)
	ctl2.place_worker(2)
	_give(gs2.current_player(), 9, 9)
	_ok("restauro del rudere altrui accettato", ctl2.restore(r2))
	_eq("  chi restaura se ne appropria", r2.owner, me)

	var ctl3 := _game()
	var gs3 := ctl3.gs
	gs3.grid.terrains[2] = Enums.Terrain.BOSCO
	var r3 := _put(gs3, gs3.current_index, "ed_dolmen", 2, 0, Enums.BuildingState.RUDERE)
	ctl3.place_worker(2)
	var p3 := gs3.current_player()
	_give(p3, 9, 9)
	ctl3.restore(r3)
	_eq("  nel bosco il restauro costa 1 pietra in meno", p3.pietra, 9 - max(0, want_p - 1))

	var ctl4 := _game()
	var gs4 := ctl4.gs
	var intact := _put(gs4, gs4.current_index, "ed_dolmen", 2)
	ctl4.place_worker(2)
	_give(gs4.current_player(), 9, 9)
	_ok("rifiuta il restauro di un edificio intatto", not ctl4.restore(intact))

	var ctl5 := _game()
	var gs5 := ctl5.gs
	var buried := _put(gs5, gs5.current_index, "ed_dolmen", 2, 0, Enums.BuildingState.RUDERE)
	buried.is_buried = true
	ctl5.place_worker(2)
	_give(gs5.current_player(), 9, 9)
	_ok("rifiuta il restauro di un rudere sotterrato", not ctl5.restore(buried))

# ---- reclutare ------------------------------------------------------
func _test_recruit() -> void:
	var cid := ""
	for id in CardDB.characters:
		var ch: Dictionary = CardDB.characters[id]
		if ch.get("era") == 1 and ch["class"] == "religione" and not ch.get("is_dynasty", false):
			cid = id
			break
	_ok("trovato un personaggio religione dell'era 1", cid != "")

	var ctl := _game()
	var gs := ctl.gs
	_put(gs, gs.current_index, "ed_dolmen", 2)
	gs.char_row = [cid]
	gs.char_decks[gs.era] = []               # mazzo vuoto: niente reintegro
	ctl.place_worker(2)
	var p := gs.current_player()
	_give(p, 0, 5)
	var cost := int(CardDB.constants["recruit_cost_oro"])

	_ok("reclutamento accettato con la classe presente", ctl.recruit(cid))
	_eq("  oro pagato", p.oro, 5 - cost)
	_eq("  lavoratore specializzato", p.specialized_characters, [cid] as Array[String])
	_eq("  carta spesa, fila vuota col mazzo esaurito", gs.char_row, [])

	var ctl2 := _game()
	var gs2 := ctl2.gs
	_put(gs2, gs2.current_index, "ed_capanne", 2)
	gs2.char_row = [cid]
	ctl2.place_worker(2)
	_give(gs2.current_player(), 0, 5)
	_ok("rifiuta se la classe non e' nella colonna", not ctl2.recruit(cid))

	var ctl3 := _game()
	var gs3 := ctl3.gs
	_put(gs3, gs3.current_index, "ed_dolmen", 2, 0, Enums.BuildingState.RUDERE)
	gs3.char_row = [cid]
	ctl3.place_worker(2)
	_give(gs3.current_player(), 0, 5)
	_ok("rifiuta se l'edificio della classe e' un rudere", not ctl3.recruit(cid))

	var ctl4 := _game()
	var gs4 := ctl4.gs
	_put(gs4, gs4.current_index, "ed_dolmen", 2)
	gs4.char_row = []
	ctl4.place_worker(2)
	_give(gs4.current_player(), 0, 5)
	_ok("rifiuta una carta che non e' nella fila", not ctl4.recruit(cid))

	var ctl5 := _game()
	var gs5 := ctl5.gs
	_put(gs5, gs5.current_index, "ed_dolmen", 2)
	gs5.char_row = [cid]
	ctl5.place_worker(2)
	_give(gs5.current_player(), 0, 0)
	_ok("rifiuta se manca l'oro", not ctl5.recruit(cid))

# ---- Dinastia -------------------------------------------------------
func _test_dynasty() -> void:
	var by_era: Dictionary = CardDB.characters[ActionRules.dynasty_id()]["cost_by_era"]
	for era_key in ["1", "2", "3", "4"]:
		var ctl := _game()
		var gs := ctl.gs
		gs.era = int(era_key)
		ctl.place_worker(1)
		var p := gs.current_player()
		var c: Dictionary = by_era[era_key]
		_give(p, int(c.get("pietra", 0)), int(c.get("oro", 0)))
		var w := p.workers
		_ok("era %s: Dinastia acquistata al costo esatto (%sp %so)" % [era_key, c.get("pietra", 0), c.get("oro", 0)], ctl.buy_dynasty())
		_eq("  quarto lavoratore, subito", p.workers, w + 1)
		_eq("  risorse esaurite dal pagamento", [p.pietra, p.oro], [0, 0])
		_ok("  segnata come posseduta", p.has_dynasty)

	var ctl2 := _game()
	var gs2 := ctl2.gs
	ctl2.place_worker(1)
	var p2 := gs2.current_player()
	p2.has_dynasty = true
	_give(p2, 9, 9)
	_ok("rifiuta la seconda Dinastia", not ctl2.buy_dynasty())

	var ctl3 := _game()
	var gs3 := ctl3.gs
	gs3.era = 5
	ctl3.place_worker(1)
	_give(gs3.current_player(), 9, 9)
	_ok("rifiuta la Dinastia nell'era 5", not ctl3.buy_dynasty())

	var ctl4 := _game()
	var gs4 := ctl4.gs
	gs4.era = 1
	ctl4.place_worker(1)
	_give(gs4.current_player(), 0, 0)
	_ok("rifiuta se le risorse non bastano", not ctl4.buy_dynasty())

# ---- spoliazione ----------------------------------------------------
func _test_despoil() -> void:
	var ctl := _game()
	var gs := ctl.gs
	for i in gs.grid.n_cols: gs.grid.terrains[i] = Enums.Terrain.PIANURA
	var me := gs.current_index
	var other := (me + 1) % gs.n_players
	var ruin := _put(gs, other, "ed_dolmen", 3, 0, Enums.BuildingState.RUDERE)
	gs.market = ["ed_capanne"]
	ctl.place_worker(2)
	_give(gs.current_player(), 9, 9)

	var q_plain := BuildRules.quote_rail(gs, me, CardDB.buildings["ed_capanne"], 2, null)
	var q_desp := BuildRules.quote_rail(gs, me, CardDB.buildings["ed_capanne"], 2, ruin)
	_ok("preventivo con spoliazione legale", q_desp.legal)
	_eq("  sconto pari alla taglia, mai oltre la pietra dovuta", q_desp.pietra,
		max(0, q_plain.pietra - min(ruin.width(), q_plain.pietra)))

	_ok("costruzione con spoliazione accettata", ctl.build("ed_capanne", 2, false, 0, ruin))
	_eq("  il rudere depredato diventa rovina", ruin.state, Enums.BuildingState.ROVINA)
	_eq("  resta del suo proprietario", ruin.owner, other)

	var ctl2 := _game()
	var gs2 := ctl2.gs
	for i in gs2.grid.n_cols: gs2.grid.terrains[i] = Enums.Terrain.PIANURA
	var far := _put(gs2, 0, "ed_dolmen", gs2.grid.n_cols - 1, 0, Enums.BuildingState.RUDERE)
	_ok("rifiuta un rudere non adiacente alla costruzione",
		not BuildRules.quote_rail(gs2, gs2.current_index, CardDB.buildings["ed_capanne"], 0, far).legal)

	var ctl3 := _game()
	var gs3 := ctl3.gs
	for i in gs3.grid.n_cols: gs3.grid.terrains[i] = Enums.Terrain.PIANURA
	var intact := _put(gs3, 0, "ed_dolmen", 1)
	_ok("rifiuta la spoliazione di un edificio intatto",
		not BuildRules.quote_rail(gs3, gs3.current_index, CardDB.buildings["ed_capanne"], 2, intact).legal)

	var ctl4 := _game()
	var gs4 := ctl4.gs
	for i in gs4.grid.n_cols: gs4.grid.terrains[i] = Enums.Terrain.PIANURA
	gs4.grid.terrains[2] = Enums.Terrain.BOSCO   # ed_menhir richiede bosco
	var same_class := _put(gs4, 0, "ed_dolmen", 2, 0, Enums.BuildingState.RUDERE)
	var menhir: Dictionary = CardDB.buildings["ed_menhir"]
	var cont := BuildRules.quote_above(gs4, gs4.current_index, menhir, 2, null)
	var cont_desp := BuildRules.quote_above(gs4, gs4.current_index, menhir, 2, same_class)
	# Senza queste due, il test passerebbe anche se entrambi i preventivi fossero
	# illegali: la continuita' sarebbe 0 per il motivo sbagliato.
	_ok("preventivo sopra il rudere legale", cont.legal, cont.reason)
	_ok("preventivo sopra il rudere legale anche depredandolo", cont_desp.legal, cont_desp.reason)
	_eq("senza spoliazione il rudere di classe uguale da' +1 resistenza", cont.continuity_bonus, 1)
	_eq("  depredandolo la continuita' non si applica", cont_desp.continuity_bonus, 0)

# ---- sepoltura dei personaggi ---------------------------------------
func _test_burial() -> void:
	var cid: String = CardDB.characters.keys().filter(
		func(k): return CardDB.characters[k].get("era") == 1 and not CardDB.characters[k].get("is_dynasty", false))[0]

	var ctl := _game()
	var gs := ctl.gs
	gs.era = 2
	var host := _put(gs, 0, "ed_menhir", 2)
	gs.players[0].specialized_characters = [cid] as Array[String]
	EraRules.bury_characters(gs)
	_eq("il personaggio finisce sotto un edificio in piedi", host.buried_character, cid)
	_eq("  con l'era di sepoltura", host.buried_character_era, 2)

	var ctl2 := _game()
	var gs2 := ctl2.gs
	gs2.era = 2
	var h1 := _put(gs2, 0, "ed_menhir", 1)
	var h2 := _put(gs2, 0, "ed_menhir", 3)
	gs2.players[0].specialized_characters = [cid, cid, cid] as Array[String]
	EraRules.bury_characters(gs2)
	_ok("due edifici ricevono un personaggio ciascuno", h1.buried_character != "" and h2.buried_character != "")

	var ctl3 := _game()
	var gs3 := ctl3.gs
	gs3.era = 5
	var h3 := _put(gs3, 0, "ed_menhir", 2)
	gs3.players[0].specialized_characters = [cid] as Array[String]
	EraRules.bury_characters(gs3)
	_eq("nell'era 5 non si seppellisce nulla", h3.buried_character, "")

# ---- ordine di turno e snake ----------------------------------------
func _test_turn_order() -> void:
	var ctl := _game(2)
	var gs := ctl.gs
	var a: int = gs.turn_order[0]
	var b: int = gs.turn_order[1]
	var seen: Array[int] = []
	for t in 6:
		if gs.era != 1: break
		seen.append(gs.current_index)
		var c := 0
		while c < gs.grid.n_cols and not ctl.place_worker(c): c += 1
		ctl.pass_action()
	_eq("era 1 in due giocatori: sequenza a snake", seen, [a, b, b, a, a, b] as Array[int])

	var ctl2 := _game(3)
	var gs2 := ctl2.gs
	var seen2: Array[int] = []
	for t in 3:
		seen2.append(gs2.current_index)
		var c := 0
		while c < gs2.grid.n_cols and not ctl2.place_worker(c): c += 1
		ctl2.pass_action()
	_eq("tre giocatori: giro normale nell'ordine di turno", seen2,
		[int(gs2.turn_order[0]), int(gs2.turn_order[1]), int(gs2.turn_order[2])] as Array[int])

	var ctl3 := _game(3)
	var gs3 := ctl3.gs
	gs3.turn_order = [2, 0, 1]
	gs3.players[0].buildings_built = 5
	gs3.players[1].buildings_built = 1
	gs3.players[2].buildings_built = 5
	_eq("chi ha costruito meno parte primo", ctl3._era_turn_order(), [1, 2, 0])
	gs3.players[0].buildings_built = 3
	gs3.players[1].buildings_built = 3
	gs3.players[2].buildings_built = 3
	_eq("a parita' resta l'ordine precedente", ctl3._era_turn_order(), [2, 0, 1])

# ---- un lavoratore per colonna --------------------------------------
func _test_worker_per_column() -> void:
	var ctl := _game(2)
	var gs := ctl.gs
	var first := gs.current_index
	_ok("primo lavoratore piazzato", ctl.place_worker(1))
	ctl.pass_action()
	var guard := 0
	while gs.current_index != first and guard < 10:
		var c := 0
		while c < gs.grid.n_cols and not ctl.place_worker(c): c += 1
		ctl.pass_action()
		guard += 1
	_ok("rifiuta un secondo lavoratore nella stessa colonna", not ctl.place_worker(1))
	_ok("accetta una colonna libera", ctl.place_worker(2))


# ---- dispersione dei secoli -----------------------------------------
func _test_disperse() -> void:
	var cap := int(CardDB.constants["resource_cap"])

	# ere 1-4: il tetto si applica
	for era in [1, 2, 3, 4]:
		var ctl := _game()
		var gs := ctl.gs
		gs.era = era
		var p0: PlayerState = gs.players[0]
		_give(p0, cap + 4, 3)
		EraRules.end_era(gs)
		_eq("era %d: le risorse scendono al tetto di %d" % [era, cap], p0.total_resources(), cap)

	# era 5: nessun taglio, le risorse residue servono allo spareggio
	var ctl5 := _game()
	var gs5 := ctl5.gs
	gs5.era = 5
	gs5.current_event = {}          # "L'era Moderna non ha evento"
	var p5: PlayerState = gs5.players[0]
	_give(p5, cap + 4, 3)
	var prima: int = p5.total_resources()
	EraRules.end_era(gs5)
	_eq("era 5: le risorse restano intatte", p5.total_resources(), prima)

	# e lo spareggio le usa davvero
	var ctl6 := _game(3)
	var gs6 := ctl6.gs
	for p in gs6.players:
		p.vp = 10
		_give(p, 0, 0)
	var p2: PlayerState = gs6.players[2]
	p2.pietra = 7
	_eq("a parita' di PV e di edifici vince chi ha piu' risorse", Scoring.winner(gs6), 2)

# ---- i binari liberi ------------------------------------------------
# Col vincolo per era ogni era ha il suo binario: quando e' pieno, per
# continuare a costruire si deve salire. COI BINARI LIBERI - la regola adottata
# - un edificio puo' finire su qualunque binario ancora libero in quelle
# colonne, riempiendo DAL FONDO.
# Il test prova tutt'e due i mondi accendendo e spegnendo la costante, e la
# rimette com'e' nei dati quando ha finito: i test non lasciano il gioco
# cambiato dietro di se'.
func _test_binari_liberi() -> void:
	var com_era := bool(CardDB.constants.get("binari_liberi", false))
	CardDB.constants["binari_liberi"] = false
	var ctl := _game(3, 21)
	var gs := ctl.gs
	# Una carta dell'era corrente e una colonna dove ci stia: quasi tutte
	# chiedono un terreno, quindi la colonna non si sceglie a caso.
	var posto := _carta_e_colonna(gs)
	_ok("c'e' una carta dell'era corrente da provare", posto["id"] != "")
	if posto["id"] == "": return
	var id: String = posto["id"]
	var col: int = posto["col"]
	var data: Dictionary = CardDB.buildings[id]

	# Con ogni era nel suo binario: occupata la colonna nel binario dell'era,
	# a terra non si puo' piu' costruire li'.
	var occupante := _put(gs, 0, id, col)
	_eq("  l'occupante sta sul binario della sua era",
		occupante.binario_effettivo(), gs.era)
	var q := BuildRules.quote_rail(gs, 0, data, col)
	_ok("col binario per era, la casella occupata rifiuta", not q.legal)
	_eq("  e lo dice", q.reason, "caselle occupate nel binario")

	# Accendendo i binari liberi, lo stesso edificio trova posto su un altro
	# binario: il piu' lontano fra quelli ancora liberi.
	CardDB.constants["binari_liberi"] = true
	var q2 := BuildRules.quote_rail(gs, 0, data, col)
	_ok("coi binari liberi trova posto lo stesso", q2.legal, q2.reason)
	_ok("  e non e' il binario dell'occupante", q2.binario != occupante.binario_effettivo())
	_eq("  ed e' il piu' lontano libero", q2.binario, 1 if gs.era != 1 else 2)

	# Si riempie dal fondo: occupando i binari uno a uno, il preventivo scala
	# sempre al primo libero, e quando non ce n'e' piu' rifiuta.
	var rails := int(CardDB.constants["rails"])
	var presi: Array[int] = []
	for _i in range(rails + 1):
		var q3 := BuildRules.quote_rail(gs, 0, data, col)
		if not q3.legal: break
		presi.append(q3.binario)
		var b := _put(gs, 0, id, col)
		b.binario = q3.binario
	# I binari attesi sono quelli liberi, dal fondo in avanti: tutti tranne
	# quello dove sta gia' l'occupante.
	var attesi: Array[int] = []
	for r in range(1, rails + 1):
		if r != occupante.binario_effettivo(): attesi.append(r)
	_eq("si riempie dal fondo, un binario dopo l'altro", presi, attesi)
	_eq("in colonna ci stanno tutti i binari meno quello gia' occupato",
		presi.size(), rails - 1)
	var q4 := BuildRules.quote_rail(gs, 0, data, col)
	_ok("  e poi la colonna e' piena davvero", not q4.legal)

	# Rispegnendola il gioco torna quello di prima: e' una prova, non una
	# regola.
	CardDB.constants["binari_liberi"] = false
	var altrove := _carta_e_colonna(gs, col)
	var q5 := BuildRules.quote_rail(gs, 0, CardDB.buildings[altrove["id"]], int(altrove["col"]))
	_ok("spenta, si torna a costruire nel binario della propria era",
		q5.legal and q5.binario == gs.era, q5.reason)
	# E nei dati la regola c'e' davvero: se domani la si spegnesse, questo
	# test lo direbbe invece di continuare a provare un mondo che non esiste.
	_ok("nei dati i binari sono liberi", com_era)
	CardDB.constants["binari_liberi"] = com_era

# Una carta dell'era corrente e una colonna dove si possa davvero costruire:
# quasi ogni carta chiede un terreno, e su una strada a caso la colonna giusta
# non e' sempre la stessa. `evita` serve a chiederne una diversa.
func _carta_e_colonna(gs: GameState, evita := -1) -> Dictionary:
	for id in CardDB.buildings:
		var c: Dictionary = CardDB.buildings[id]
		if int(c["era"]) != gs.era or int(c["width"]) != 1: continue
		if int(c["level_required"]) > 0: continue
		for col in gs.grid.n_cols:
			if col == evita: continue
			if BuildRules.quote_rail(gs, 0, c, col).legal:
				return {"id": id, "col": col}
	return {"id": "", "col": 0}

# ---- la copia dello stato -------------------------------------------
# Serve a chi vuole simulare: si copia la partita, ci si gioca sopra col
# codice vero e si guarda com'e' andata. Il contratto e' uno solo e va provato
# per intero: TOCCARE LA COPIA NON DEVE TOCCARE L'ORIGINALE. Una copia che si
# porta dietro un array condiviso e' peggio di nessuna copia, perche' il danno
# si vede lontano da dove e' stato fatto.
func _test_copia_dello_stato() -> void:
	var ctl := _game(3, 77)
	var gs := ctl.gs
	# Una partita gia' avviata: qualche edificio, risorse, un personaggio.
	for i in 6:
		StrategyBot.play_turn(ctl, "bilanciata")
	var copia := gs.duplica()

	_eq("la copia ha gli stessi giocatori", copia.players.size(), gs.players.size())
	_eq("  e gli stessi edifici", copia.grid.buildings.size(), gs.grid.buildings.size())
	_eq("  e la stessa era", copia.era, gs.era)
	_eq("  e lo stesso mercato", copia.market, gs.market)
	var uid_a: Array = gs.grid.buildings.map(func(b): return b.uid)
	var uid_b: Array = copia.grid.buildings.map(func(b): return b.uid)
	_eq("  e gli stessi uid, nello stesso ordine", uid_b, uid_a)

	# Le carte invece SI CONDIVIDONO: sono righe di cards.json, uguali per
	# tutte le istanze e mai modificate dal gioco.
	if not gs.grid.buildings.is_empty():
		_ok("la carta e' la stessa, non una copia",
			copia.grid.buildings[0].data == gs.grid.buildings[0].data)

	# E adesso il contratto.
	var p0: PlayerState = copia.players[0]
	var prima_pietra: int = gs.players[0].pietra
	p0.pietra += 99
	p0.worker_cols.append(99)
	p0.counters["prova"] = 1
	_eq("cambiare le risorse sulla copia non tocca l'originale",
		gs.players[0].pietra, prima_pietra)
	_ok("  ne' i suoi array", not 99 in gs.players[0].worker_cols)
	_ok("  ne' i suoi contatori", not gs.players[0].counters.has("prova"))
	if not gs.grid.buildings.is_empty():
		var b: Building = copia.grid.buildings[0]
		var stato_prima: int = gs.grid.buildings[0].state
		b.state = Enums.BuildingState.ROVINA
		b.basi.append(999)
		b.vp_reso["prova"] = 7
		_eq("cambiare un edificio sulla copia non tocca l'originale",
			gs.grid.buildings[0].state, stato_prima)
		_ok("  ne' le sue basi", not 999 in gs.grid.buildings[0].basi)
		_ok("  ne' il suo libro mastro", not gs.grid.buildings[0].vp_reso.has("prova"))

	# GIOCARCI SOPRA: e' l'uso vero. Una partita intera sulla copia, e
	# l'originale deve restare fermo dov'era.
	var copia2 := gs.duplica()
	var ctl2 := GameController.new()
	ctl2.gs = copia2
	var edifici_prima: int = gs.grid.buildings.size()
	var era_prima: int = gs.era
	var giri := 0
	while copia2.phase != Enums.Phase.FINE_PARTITA and giri < 4000:
		StrategyBot.play_turn(ctl2, "bilanciata")
		giri += 1
	_ok("sulla copia la partita arriva in fondo", copia2.phase == Enums.Phase.FINE_PARTITA)
	_eq("  e l'originale non si e' mosso di un edificio",
		gs.grid.buildings.size(), edifici_prima)
	_eq("  ne' di un'era", gs.era, era_prima)

	# E la copia gioca la STESSA partita dell'originale: il generatore si copia
	# con tutto il suo stato, se no simulare vorrebbe dire tirare altri dadi.
	var a := gs.duplica()
	var b2 := gs.duplica()
	for c in [a, b2]:
		var ct := GameController.new()
		ct.gs = c
		var g2 := 0
		while c.phase != Enums.Phase.FINE_PARTITA and g2 < 4000:
			StrategyBot.play_turn(ct, "bilanciata")
			g2 += 1
	var pv_a: Array = a.players.map(func(p): return p.vp)
	var pv_b: Array = b2.players.map(func(p): return p.vp)
	_eq("due copie della stessa partita finiscono uguali", pv_b, pv_a)

	# A META' TURNO. Piazzato il lavoratore, la colonna attivata decide cosa e'
	# legale: si costruisce li' o accanto. Stava nel controller, e una copia
	# presa a questo punto non sapeva piu' dove si poteva costruire - ogni
	# costruzione simulata falliva in silenzio, e il pianificatore credeva che
	# stare fermi fosse la mossa migliore nel 64% dei turni.
	var ctl4 := _game(3, 91)
	var g4 := ctl4.gs
	var chi4 := g4.current_index
	var trovata := false
	for col in g4.grid.n_cols:
		var prova := g4.duplica()
		var cp := GameController.new()
		cp.gs = prova
		if not cp.place_worker(col): continue
		var lista := StrategyBot.classifica(prova, prova.players[chi4], col, "bilanciata")
		for e in lista:
			if e["mossa"].tipo != "costruisci": continue
			# La copia della copia, con un controller NUOVO: e' esattamente
			# quello che fa chi simula.
			var dentro := prova.duplica()
			var cn := GameController.new()
			cn.gs = dentro
			_eq("la copia a meta' turno sa qual e' la colonna attivata",
				dentro.colonna_attivata, col)
			var prima := dentro.grid.buildings.size()
			_ok("  e ci si costruisce con un controller nuovo",
				StrategyBot._esegui(cn, e["mossa"]) and dentro.grid.buildings.size() == prima + 1)
			trovata = true
			break
		if trovata: break
	_ok("  (c'era una costruzione da provare)", trovata)

# ---- le mosse si valutano dopo l'attivazione ------------------------
# Piazzare il lavoratore ATTIVA la colonna, e l'attivazione paga: la produzione
# degli edifici che stanno li', le abilita' "quando la attivi", l'oro del
# Centro Urbano. Con quelle risorse in mano le mosse possibili sono altre.
# Il bot guardava lo stato di PRIMA, e quindi contava mosse che non avrebbe
# potuto pagare e ne ignorava altre che avrebbe potuto: qui si prova che
# adesso guarda dopo.
func _test_valuta_dopo_attivazione() -> void:
	# Si cercano partite vere finche' non se ne trova una dove l'attivazione
	# cambia davvero quel che si puo' fare: non sempre succede - se in colonna
	# non produce niente, prima e dopo sono lo stesso stato - e un test che
	# pretendesse che succeda sempre proverebbe una cosa falsa.
	var trovata := false
	var guadagno := 0.0
	var colonna := -1
	for seme in [31, 57, 98, 144, 201]:
		var ctl := _game(3, seme)
		var gs := ctl.gs
		for i in 9:
			StrategyBot.play_turn(ctl, "bilanciata")
		while gs.current_index != 0 and gs.phase != Enums.Phase.FINE_PARTITA:
			StrategyBot.play_turn(ctl, "bilanciata")
		if gs.phase == Enums.Phase.FINE_PARTITA: continue
		var p: PlayerState = gs.players[0]
		var dopo := StrategyBot.classifica_colonne(gs, p, "bilanciata")
		for e in dopo:
			var col := int(e["col"])
			# Lo stesso conto sullo stato di PRIMA, come faceva il bot vecchio.
			var prima := 0.0
			for v in StrategyBot._opzioni(gs, 0, col):
				if not v.pagabile(p): continue
				prima = maxf(prima, StrategyBot._valore(gs, p, v, "bilanciata", col))
			if float(e["mossa"]) > prima + 0.001:
				trovata = true
				guadagno = float(e["mossa"]) - prima
				colonna = col
				break
		if trovata:
			# E l'originale non si e' mosso: la prova si fa su una copia.
			_eq("valutare non tocca i lavoratori veri", p.worker_cols.size(), 0)
			_eq("  ne' gli edifici", gs.grid.buildings.size(), gs.grid.buildings.size())
			break
	_ok("esiste una colonna dove l'attivazione cambia quel che si puo' fare "
		+ ("(col %d, %.1f in piu')" % [colonna, guadagno] if trovata else "(non trovata)"),
		trovata)

# ---- il bot che pianifica l'era -------------------------------------
# Tre cose vanno provate, e nessuna e' "vince": quella la dice il torneo.
# Che PIANIFICARE NON TOCCHI LA PARTITA - si pianifica su copie, e la partita
# vera deve cambiare solo per la mossa che poi si gioca; che la partita arrivi
# in fondo; e che sia deterministica, perche' una misura che non si ripete non
# e' una misura.
func _test_pianificatore() -> void:
	var ctl := _game(3, 55)
	var gs := ctl.gs
	for i in 4:
		StrategyBot.play_turn(ctl, "bilanciata")
	var p := gs.current_player()
	var fotografia := [p.pietra, p.oro, p.workers_used, p.worker_cols.duplicate(),
		gs.grid.buildings.size(), gs.rng.state, gs.current_index, gs.log.size()]
	var piano := PlanningBot.pianifica(gs, p.index, "bilanciata")
	var dopo := [p.pietra, p.oro, p.workers_used, p.worker_cols.duplicate(),
		gs.grid.buildings.size(), gs.rng.state, gs.current_index, gs.log.size()]
	_eq("pianificare non tocca la partita vera", dopo, fotografia)
	_ok("  e produce un piano", not piano.is_empty())
	if not piano.is_empty():
		var passi: Array = piano["passi"]
		_ok("  lungo quanto i lavoratori che restano (%d passi)" % passi.size(),
			passi.size() >= 1 and passi.size() <= p.workers - p.workers_used)
		var primo: Dictionary = passi[0]
		_ok("  e il primo passo e' in una colonna libera per lui",
			not int(primo["col"]) in p.worker_cols)

	# Una partita intera col pianificatore a un posto e gli avidi agli altri.
	var ctl2 := _game(3, 56)
	var giri := 0
	while ctl2.gs.phase != Enums.Phase.FINE_PARTITA and giri < 4000:
		if ctl2.gs.current_index == 0: PlanningBot.play_turn(ctl2, "bilanciata")
		else: StrategyBot.play_turn(ctl2, "bilanciata")
		giri += 1
	_ok("col pianificatore la partita arriva in fondo",
		ctl2.gs.phase == Enums.Phase.FINE_PARTITA)
	var pv1: Array = ctl2.gs.players.map(func(q): return q.vp)

	# E la stessa partita rigiocata finisce identica.
	var ctl3 := _game(3, 56)
	giri = 0
	while ctl3.gs.phase != Enums.Phase.FINE_PARTITA and giri < 4000:
		if ctl3.gs.current_index == 0: PlanningBot.play_turn(ctl3, "bilanciata")
		else: StrategyBot.play_turn(ctl3, "bilanciata")
		giri += 1
	var pv2: Array = ctl3.gs.players.map(func(q): return q.vp)
	_eq("  e rigiocata finisce identica", pv2, pv1)

# ---- la versione vecchia del bot, per separare le cause ---------------
# `--bot 1` rimette in campo il bot che sceglieva la colonna guardando lo stato
# di prima dell'attivazione. Serve a rispondere a "e' merito del bot o delle
# regole?", e risponde solo se il bot vecchio e' davvero quello vecchio: qui si
# fissa che, in versione 1, il valore della colonna e' quello calcolato SENZA
# attivare. (Che riproduca le partite di allora riga per riga e' stato
# verificato su 250 partite quando la manopola e' nata.)
func _test_versione_del_bot() -> void:
	var ctl := _game(3, 31)
	var gs := ctl.gs
	for i in 9:
		StrategyBot.play_turn(ctl, "bilanciata")
	var p := gs.current_player()
	StrategyBot.versione_in_uso = 1
	var v1 := StrategyBot.classifica_colonne(gs, p, "bilanciata")
	StrategyBot.versione_in_uso = StrategyBot.VERSIONE
	var uguali := true
	for e in v1:
		var col := int(e["col"])
		var prima := 0.0
		for v in StrategyBot._opzioni(gs, p.index, col):
			prima = maxf(prima, StrategyBot._valore(gs, p, v, "bilanciata", col))
		if not is_equal_approx(float(e["mossa"]), prima): uguali = false
	_ok("in versione 1 la colonna vale le mosse di PRIMA dell'attivazione", uguali)
	_eq("  e dopo la prova si torna alla versione di serie",
		StrategyBot.versione_in_uso, StrategyBot.VERSIONE)
