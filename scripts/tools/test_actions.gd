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
	_run("la strategia Obiettivi", _test_obiettivi)
	_run("il Centro Urbano una volta per era", _test_centro_una_volta)
	_run("chi ha sepolto chi, e lo sconto solo sulle rovine altrui", _test_sepolto_da)
	_run("il premio di scavo si paga e torna col libro mastro", _test_premio_in_partita)
	_run("la v2 a tre risorse gira sullo stesso motore", _test_tre_risorse)
	_run("il tetto per risorsa alla dispersione", _test_tetto_per_risorsa)
	_run("il canone delle strategie segue il file dati", _test_canone_v2)
	_run("il turno v2: un'azione per turno, il lavoratore dove agisce", _test_turno_v2)
	_run("il draft dei Personaggi a inizio era (v2)", _test_draft_v2)
	_run("v2: niente scheletri dal draft, niente Vetusta' (registro 95)", _test_senza_vetusta_v2)
	_run("v2: le tre carte che contavano la Vetusta' (registro 99)", _test_tre_carte_v2)
	_run("v2: le tessere una volta per era (registro 100)", _test_tessere_v2)
	_run("l'incasso al passaggio nel turno v1 (registro 109)", _test_passa_incasso)
	_run("i Monumenti rivelati e le sagome da quattro giocatori (registro 110)", _test_monumenti_e_sagome_in_piu)
	_run("v2: le case della riserva, sempre disponibili (registro 116)", _test_riserva)
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

# OBIETTIVI NEL CANONE. Il suo segno non si vede in sei partite contro il bot a
# caso - un Monumento vale 4 o 5 punti, e in sei partite lo prendono tutti
# prima o poi - quindi qui si fissa la preferenza stessa, su un Monumento che
# si soddisfa con un edificio solo: una carta larga 3 lo fa scattare e vale
# i suoi punti, una stretta no, e se il Monumento e' gia' soddisfatto la carta
# larga non e' piu' merito suo.
func _test_obiettivi() -> void:
	_ok("Obiettivi sta nel canone", StrategyBot.STRATEGIE.has("obiettivi"))
	_ok("  e non e' piu' fra le candidate", not StrategyBot.STRATEGIE_CANDIDATE.has("obiettivi"))
	var mon := ""
	for id in CardDB.monuments:
		var c: Dictionary = CardDB.monuments[id]["condition"]
		if str(c["op"]) == "count_matching" and int(c["min"]) == 1 \
				and c["target"].has("width") and c["target"].size() == 2:
			mon = id
	_ok("c'e' un Monumento che scatta con un edificio largo", mon != "")
	if mon == "": return
	var minimo := int(CardDB.monuments[mon]["condition"]["target"]["width"]["min"])
	var larga := ""
	var stretta := ""
	for id in CardDB.buildings:
		var w := int(CardDB.buildings[id]["width"])
		if w >= minimo and larga == "": larga = id
		if w < minimo and stretta == "": stretta = id
	var ctl := _game(3, 5)
	var gs := ctl.gs
	gs.monuments_open = [mon]
	var p: PlayerState = gs.players[0]
	# L'Eredita' segreta pescata a caso conterebbe anche lei: fuori.
	p.legacy_id = ""
	var vp := float(CardDB.monuments[mon]["vp"])
	_eq("la carta larga vale i punti del Monumento", StrategyBot._premio_obiettivi(
		gs, p, CardDB.buildings[larga], 0, {}), vp)
	_eq("  la stretta niente", StrategyBot._premio_obiettivi(
		gs, p, CardDB.buildings[stretta], 0, {}), 0.0)
	_eq("  e la prova non lascia l'edificio finto in tavola", gs.grid.buildings.size(), 0)
	_put(gs, 0, larga, 0)
	_eq("  a Monumento gia' soddisfatto la carta larga non vale piu' niente",
		StrategyBot._premio_obiettivi(gs, p, CardDB.buildings[larga], 4, {}), 0.0)

# LA PROSPERITA' UNA VOLTA PER ERA. Manopola accesa nei dati (punto 86): si
# provano tutte e due le posizioni, forzandole, cosi' il test non dipende da
# come e' girata. Spenta, il Centro paga a ogni attivazione; accesa, paga la
# prima volta in un'era e poi tace in quella colonna fino all'era dopo. I
# contatori sono quelli che leggono le misure: se sbagliano loro, sbaglia il
# documento.
func _test_centro_una_volta() -> void:
	var ctl := _game(3, 11)
	var gs := ctl.gs
	var soglia := int(CardDB.constants["prosperity"]["min_buildings"])
	for i in soglia:
		_put(gs, i % 2, "ed_capanne", 3, i)
	_ok("la colonna e' un Centro Urbano", gs.grid.is_prosperity_center(3))
	_ok("nei dati e' accesa", bool(CardDB.constants["prosperity"]["once_per_era"]))
	var oro := func() -> int: return int(gs.players[1].counters.get("oro_centro", 0))
	var salvate: Dictionary = CardDB.constants["prosperity"]
	var spenta := salvate.duplicate()
	spenta["once_per_era"] = false
	CardDB.constants["prosperity"] = spenta
	EraRules.activate(gs, 0, 3)
	EraRules.activate(gs, 0, 3)
	_eq("spenta: paga a ogni attivazione", oro.call(), 2)
	_eq("  e conta le volte a chi attiva", int(gs.players[0].counters.get("centro_attivato", 0)), 2)
	var accesa := salvate.duplicate()
	accesa["once_per_era"] = true
	CardDB.constants["prosperity"] = accesa
	EraRules.activate(gs, 0, 3)
	EraRules.activate(gs, 0, 3)
	_eq("accesa: nella stessa era paga una volta sola", oro.call(), 3)
	gs.grid.reset_era_flags()
	EraRules.activate(gs, 0, 3)
	_eq("  e all'era dopo paga di nuovo", oro.call(), 4)
	_ok("  e la copia dello stato se lo ricorda", gs.duplica().grid.prosperity_paid.has(3))
	CardDB.constants["prosperity"] = salvate

# Chi seppellisce chi lo registra il controller (Building.buried_by, in che
# era): su partite vere ogni sepolto deve avere uno scavatore e un'era, e
# qualcuno deve essere stato sepolto da un avversario. Poi la manopola
# `sconto_macerie_solo_altrui` (registro 87): sopra una rovina altrui lo
# sconto c'e' sempre, sopra la propria solo con la manopola spenta.
func _test_sepolto_da() -> void:
	var sepolti := 0
	var senza_scavatore := 0
	var da_altri := 0
	for g in 6:
		var ctl := _game(3, 900 + g)
		var guard := 0
		while ctl.gs.phase != Enums.Phase.FINE_PARTITA and guard < 10000:
			RandomBot.play_turn(ctl)
			guard += 1
		for b in ctl.gs.grid.buildings:
			if not b.is_buried: continue
			sepolti += 1
			if b.buried_by < 0 or b.buried_era < 1 or b.buried_era > int(CardDB.constants["eras"]):
				senza_scavatore += 1
			elif b.buried_by != b.owner:
				da_altri += 1
	_ok("su 6 partite ci sono sepolti (%d)" % sepolti, sepolti > 0)
	_eq("  ognuno con il suo scavatore e la sua era", senza_scavatore, 0)
	_ok("  e qualcuno sepolto da un avversario (%d)" % da_altri, da_altri > 0)

	var com_era := bool(CardDB.constants.get("sconto_macerie_solo_altrui", false))
	var ctl2 := _game(3, 31)
	var gs := ctl2.gs
	# Una carta dell'era, larga 1, con pietra da scontare, e una colonna dal
	# terreno giusto: nell'era 1 quasi tutte chiedono un terreno.
	var id := ""
	var col := -1
	for cid in CardDB.buildings:
		var d: Dictionary = CardDB.buildings[cid]
		if int(d["era"]) != gs.era or int(d["width"]) != 1 \
				or int(d["cost"]["pietra"]) < 2 or int(d["level_required"]) > 1:
			continue
		for c in gs.grid.n_cols:
			if BuildRules.terrain_ok(gs, d, c, c + 1, 0):
				id = cid
				col = c
				break
		if id != "": break
	_ok("c'e' una carta da provare", id != "")
	if id == "": return
	var data: Dictionary = CardDB.buildings[id]
	var rovina := _put(gs, 1, id, col)
	rovina.state = Enums.BuildingState.ROVINA
	CardDB.constants["sconto_macerie_solo_altrui"] = false
	var q_tutti := BuildRules.quote_above(gs, 0, data, col)
	CardDB.constants["sconto_macerie_solo_altrui"] = true
	var q_altrui := BuildRules.quote_above(gs, 0, data, col)
	_ok("sopra una rovina altrui il preventivo e' legale", q_tutti.legal and q_altrui.legal, q_tutti.reason)
	_eq("  e lo sconto c'e' con e senza manopola", q_altrui.pietra, q_tutti.pietra)
	rovina.owner = 0
	CardDB.constants["sconto_macerie_solo_altrui"] = false
	var q_mia := BuildRules.quote_above(gs, 0, data, col)
	CardDB.constants["sconto_macerie_solo_altrui"] = true
	var q_mia_senza := BuildRules.quote_above(gs, 0, data, col)
	_eq("sopra la propria rovina, spenta, lo sconto c'e'", q_mia.pietra, q_tutti.pietra)
	_eq("  accesa, costa %d in piu'" % int(CardDB.constants["rubble_discount_pietra"]),
		q_mia_senza.pietra, q_mia.pietra + int(CardDB.constants["rubble_discount_pietra"]))
	CardDB.constants["sconto_macerie_solo_altrui"] = com_era

# Con il premio di scavo acceso, su partite vere qualcuno lo incassa e i punti
# del canale Scavo tornano ancora, carta per carta, con quelli del tabellone:
# il premio si segna sull'edificio sepolto, non si inventa un canale nuovo.
func _test_premio_in_partita() -> void:
	var com_era: String = str(CardDB.constants.get("premio_scavo", "nessuno"))
	CardDB.constants["premio_scavo"] = "per_livello"
	var incassato := 0
	var storte := 0
	for g in 4:
		var ctl := _game(3, 950 + g)
		var guard := 0
		while ctl.gs.phase != Enums.Phase.FINE_PARTITA and guard < 10000:
			RandomBot.play_turn(ctl)
			guard += 1
		var tabellone := 0
		var carte := 0
		for p in ctl.gs.players:
			incassato += int(p.counters.get("scavo_scavato", 0))
			tabellone += int(p.vp_breakdown.get("scavo", 0))
		for b in ctl.gs.grid.buildings: carte += int(b.vp_reso.get("scavo", 0))
		if tabellone != carte: storte += 1
	CardDB.constants["premio_scavo"] = com_era
	_ok("su 4 partite qualcuno incassa il premio (%d punti)" % incassato, incassato > 0)
	_eq("  e il canale Scavo torna col libro mastro", storte, 0)

# `data/cards-v2.json` (generato da tools/genera_cards_v2.py) carica le Idee
# nei costi e nella produzione: su partite vere qualcuno le produce e le
# spende, nessuno va sotto zero, e ricaricando la v1.5 le Idee spariscono.
func _test_tre_risorse() -> void:
	_ok("il file v2 esiste", FileAccess.file_exists("res://data/cards-v2.json"))
	if not FileAccess.file_exists("res://data/cards-v2.json"): return
	CardDB.load_db("res://data/cards-v2.json")
	_eq("il Dolmen costa un'Idea", int(CardDB.buildings["ed_dolmen"]["cost"].get("idee", 0)), 1)
	var prodotte := 0
	var spese := 0
	var sotto_zero := 0
	for g in 3:
		var ctl := _game(3, 970 + g)
		var guard := 0
		while ctl.gs.phase != Enums.Phase.FINE_PARTITA and guard < 10000:
			RandomBot.play_turn(ctl)
			guard += 1
		for p in ctl.gs.players:
			prodotte += int(p.counters.get("idee_prodotte", 0))
			spese += int(p.counters.get("idee_spese", 0))
			if p.pietra < 0 or p.oro < 0 or p.idee < 0: sotto_zero += 1
	_ok("su 3 partite si producono Idee (%d)" % prodotte, prodotte > 0)
	_ok("  e si spendono (%d)" % spese, spese > 0)
	_eq("  nessuno va sotto zero", sotto_zero, 0)
	CardDB.load_db(CardDB.DB_PATH)
	_eq("ricaricata la v1.5, il Dolmen non chiede Idee", int(CardDB.buildings["ed_dolmen"]["cost"].get("idee", 0)), 0)

# "Tetto a tre" (registro 91): alla dispersione ogni risorsa scende a 3, poi
# vale il tetto totale di sempre. Spento (0, i dati v1.5) non cambia niente.
func _test_tetto_per_risorsa() -> void:
	var com_era := int(CardDB.constants.get("resource_cap_per_resource", 0))
	var gs := _game(3, 41).gs
	var p: PlayerState = gs.players[0]
	p.pietra = 4
	p.oro = 4
	p.idee = 4
	CardDB.constants["resource_cap_per_resource"] = 0
	EraRules.disperse(gs)
	_eq("spento: resta il tetto totale (5), si scarta prima la pietra", [p.pietra, p.oro, p.idee], [0, 1, 4])
	p.pietra = 4
	p.oro = 4
	p.idee = 4
	CardDB.constants["resource_cap_per_resource"] = 3
	EraRules.disperse(gs)
	_eq("a 3: ogni risorsa scende a 3, poi il totale a 5", [p.pietra, p.oro, p.idee], [0, 2, 3])
	CardDB.constants["resource_cap_per_resource"] = com_era

# Registro 92: con la v2 caricata il canone e' quello della v2 (niente
# Verticale, la Continuita' dentro), e le sei strategie giocano partite intere.
func _test_canone_v2() -> void:
	_eq("con la v1.5 il canone e' quello di sempre", StrategyBot.canone(), StrategyBot.STRATEGIE)
	if not FileAccess.file_exists("res://data/cards-v2.json"): return
	CardDB.load_db("res://data/cards-v2.json")
	_ok("con la v2 il canone e' quello della v2", StrategyBot.canone() == StrategyBot.STRATEGIE_V2)
	_ok("  senza la Verticale", not StrategyBot.canone().has("verticale"))
	_ok("  con la Continuita'", StrategyBot.canone().has("continuita"))
	var finite := 0
	for strat in StrategyBot.canone():
		var ctl := _game(3, 980)
		var guard := 0
		while ctl.gs.phase != Enums.Phase.FINE_PARTITA and guard < 10000:
			StrategyBot.play_turn(ctl, strat)
			guard += 1
		if ctl.gs.phase == Enums.Phase.FINE_PARTITA: finite += 1
	_eq("  e ogni strategia porta in fondo una partita v2", finite, StrategyBot.canone().size())
	CardDB.load_db(CardDB.DB_PATH)

# Registro 93: nel turno v2 ogni azione consuma un lavoratore e non c'e' la
# fase AZIONE. Si prova sul file v2: costruire all'inizio del turno passa,
# mette il lavoratore sull'edificio (+2) e lo attiva; passare incassa; su
# partite vere del bot casuale si fanno tutte le azioni e le partite finiscono.
func _test_turno_v2() -> void:
	if not FileAccess.file_exists("res://data/cards-v2.json"): return
	CardDB.load_db("res://data/cards-v2.json")
	# Dal registro 94 il file v2 gioca il turno a quattro lavoratori: il turno
	# a un'azione resta una manopola, e qui si accende.
	CardDB.constants["turno_v2"] = true
	_ok("la manopola accende il turno v2", bool(CardDB.constants.get("turno_v2", false)))
	var ctl := _game(3, 990)
	var gs := ctl.gs
	# Prima il draft dei Personaggi (v2): qui si prende il primo che c'e'.
	while not gs.pending_choice.is_empty():
		ctl.choose(int((gs.pending_choice["options"] as Array)[0]))
	var p := gs.current_player()
	var usati := p.workers_used
	# Costruire senza aver attivato: nel turno v2 e' il turno stesso.
	var fatto := false
	var nuovo: Building = null
	for card_id in gs.market.duplicate():
		for c in gs.grid.n_cols:
			if ctl.build(card_id, c, false):
				fatto = true
				for b in gs.grid.buildings:
					if b.owner == p.index: nuovo = b
				break
		if fatto: break
	_ok("si costruisce all'inizio del turno", fatto)
	if fatto:
		_eq("  e costa il lavoratore", p.workers_used, usati + 1)
		_eq("  che resta sull'edificio a proteggerlo", nuovo.protection, int(CardDB.constants["protection_bonus"]))
		_eq("  ed e' ancora fase PIAZZA per il prossimo", gs.phase, Enums.Phase.PIAZZA)
	var p2 := gs.current_player()
	var oro_prima := p2.oro
	var usati2 := p2.workers_used
	_ok("passare e incassare", ctl.passa("oro"))
	_eq("  porta 1 oro", p2.oro, oro_prima + 1)
	_eq("  e costa il lavoratore", p2.workers_used, usati2 + 1)
	var azioni := {}
	var finite := 0
	for g in 4:
		var c2 := _game(3, 995 + g)
		var guard := 0
		while c2.gs.phase != Enums.Phase.FINE_PARTITA and guard < 10000:
			RandomBot.play_turn(c2)
			guard += 1
		if c2.gs.phase == Enums.Phase.FINE_PARTITA: finite += 1
		for pl in c2.gs.players:
			for k in pl.counters:
				if str(k).begins_with("az_"): azioni[k] = int(azioni.get(k, 0)) + int(pl.counters[k])
	_eq("4 partite del bot casuale arrivano in fondo", finite, 4)
	# Il bot casuale non passa mai: una colonna libera c'e' sempre. Passare e'
	# provato sopra, direttamente.
	for k in ["az_colonna", "az_costruisci", "az_potenzia"]:
		_ok("  si fa l'azione %s (%d)" % [k, int(azioni.get(k, 0))], int(azioni.get(k, 0)) > 0)
	CardDB.load_db(CardDB.DB_PATH)

# IL DRAFT (registro 93): a inizio era, in ordine di turno, ogni giocatore
# prende un Personaggio fra tutti quelli dell'era, gratis e senza lavoratore.
# I protettori si legano al primo edificio costruito nell'era.
func _test_draft_v2() -> void:
	if not FileAccess.file_exists("res://data/cards-v2.json"): return
	CardDB.load_db("res://data/cards-v2.json")
	_ok("il file v2 accende il draft", bool(CardDB.constants.get("draft_personaggi", false)))
	var ctl := _game(3, 990)
	var gs := ctl.gs
	_eq("all'inizio dell'era il gioco chiede il draft", str(gs.pending_choice.get("kind", "")), "draft")
	_eq("  in fila ci sono tutti i Personaggi dell'era 1", gs.char_row.size(), 5)
	_eq("  e sceglie per primo il primo dell'ordine", int(gs.pending_choice["player"]), int(gs.turn_order[0]))
	var opzioni: Array = gs.pending_choice["options"]
	var con_impronta := false
	for i in opzioni:
		if bool(CardDB.characters[gs.char_row[int(i)]].get("imprint", false)): con_impronta = true
	_ok("  senza edifici l'Impronta non si offre", not con_impronta)
	var primo: PlayerState = gs.players[int(gs.pending_choice["player"])]
	var pietra := primo.pietra
	var oro := primo.oro
	var usati := primo.workers_used
	var capotribu := gs.char_row.find("pe_capotribu")
	_ok("  il Capotribu' e' fra le opzioni", capotribu in opzioni)
	_ok("  si sceglie", ctl.choose(capotribu))
	_eq("  il Personaggio e' del giocatore", primo.recruited_total, 1)
	_eq("  senza lavoratore", primo.workers_used, usati)
	_ok("  senza pagare (il Capotribu' porta +2 pietra)", primo.pietra == pietra + 2 and primo.oro == oro)
	_eq("  poi tocca al secondo", int(gs.pending_choice["player"]), int(gs.turn_order[1]))
	while not gs.pending_choice.is_empty():
		ctl.choose(int((gs.pending_choice["options"] as Array)[0]))
	_eq("finito il draft si gioca", gs.phase, Enums.Phase.PIAZZA)
	_eq("  e parte il primo dell'ordine", gs.current_index, int(gs.turn_order[0]))
	_eq("  con la fila scesa a 2", gs.char_row.size(), 2)
	_eq("  con quattro lavoratori (registro 94)", primo.workers, 4)
	# Turno v1.5: il lavoratore attiva la colonna, poi si agisce li' o accanto.
	_ok("  il primo drafter attiva la colonna 1", ctl.place_worker(1))
	_ok("  reclutare non e' piu' un'azione", not ctl.recruit(gs.char_row[0], null))
	var costruito: Building = null
	for card_id in gs.market.duplicate():
		for c in range(0, 3):
			if ctl.build(card_id, c, false):
				for b in gs.grid.buildings:
					if b.owner == primo.index: costruito = b
				break
		if costruito != null: break
	_ok("il primo drafter costruisce", costruito != null)
	if costruito != null:
		# Nel turno a quattro lavoratori il +2 lo da' solo il lavoratore messo
		# sopra un proprio edificio in piedi: qui l'edificio e' nuovo, resta il +1.
		_eq("  e il Capotribu' protegge l'edificio nuovo (+1)", costruito.protection, 1)
		_eq("  legato a quell'edificio", int(primo.character_targets.get("pe_capotribu", -1)), costruito.uid)
	var finite := 0
	var draftati := 0
	for g in 3:
		var c2 := _game(3, 995 + g)
		var guard := 0
		while c2.gs.phase != Enums.Phase.FINE_PARTITA and guard < 10000:
			RandomBot.play_turn(c2)
			guard += 1
		if c2.gs.phase == Enums.Phase.FINE_PARTITA: finite += 1
		for pl in c2.gs.players: draftati += int(pl.counters.get("draftati", 0))
	_eq("3 partite del bot casuale arrivano in fondo", finite, 3)
	_ok("  con Personaggi draftati (%d)" % draftati, draftati >= 30)
	CardDB.load_db(CardDB.DB_PATH)


# Registro 95: il Personaggio del draft non si seppellisce a fine era, e la
# Vetusta' non esiste (tetto 0). Con i dati v1.5 tutto come prima.
func _test_senza_vetusta_v2() -> void:
	if not FileAccess.file_exists("res://data/cards-v2.json"): return
	CardDB.load_db("res://data/cards-v2.json")
	_eq("nel file v2 la Vetusta' ha tetto 0", int(CardDB.constants["vetusta_max"]), 0)
	_ok("  e i Personaggi non si seppelliscono", not bool(CardDB.constants.get("personaggi_sepolti", true)))
	var ctl := _game(3, 990)
	var gs := ctl.gs
	while not gs.pending_choice.is_empty():
		ctl.choose(int((gs.pending_choice["options"] as Array)[0]))
	var p := gs.current_player()
	_eq("il primo ha il suo Personaggio", p.specialized_characters.size(), 1)
	_ok("  e attiva la colonna 1", ctl.place_worker(1))
	var costruito: Building = null
	# Si costruisce ACCANTO alla colonna attivata: cosi' piu' tardi, nella
	# stessa era, un altro lavoratore puo' attivare la colonna dell'edificio
	# e potenziarlo (un proprio lavoratore per colonna).
	for card_id in gs.market.duplicate():
		for c in [0, 2]:
			if ctl.build(card_id, c, false):
				for b in gs.grid.buildings:
					if b.owner == p.index: costruito = b
				break
		if costruito != null: break
	_ok("  e costruisce accanto", costruito != null)
	if costruito == null:
		CardDB.load_db(CardDB.DB_PATH)
		return
	costruito.bonus_res += 10                     # regge l'evento di sicuro
	EraRules.resolve_event(gs)
	_eq("regge l'evento senza prendere Vetusta'", costruito.vetusta, 0)
	EraRules.bury_characters(gs)
	_eq("a fine era il Personaggio non finisce sotto l'edificio", costruito.buried_character, "")
	# Lo scheletro lo lascia il potenziamento: il lavoratore resta sotto.
	_ok("il file v2 accende lo scheletro del potenziamento", bool(CardDB.constants.get("scheletro_potenziamento", false)))
	var chi := costruito.owner
	var potenziato := false
	var guard := 0
	while not potenziato and guard < 60 and gs.phase != Enums.Phase.FINE_PARTITA:
		guard += 1
		while not gs.pending_choice.is_empty():
			ctl.choose(int((gs.pending_choice["options"] as Array)[0]))
		var g := gs.current_player()
		if g.index == chi and gs.phase == Enums.Phase.PIAZZA and costruito.is_alive():
			g.pietra = 5; g.oro = 5; g.idee = 5
			if ctl.place_worker(costruito.col_from):
				for upg_id in gs.upg_row.duplicate():
					if ctl.upgrade(upg_id, costruito):
						potenziato = true
						break
				if not potenziato: ctl.pass_action()
				continue
		StrategyBot.play_turn(ctl)
	_ok("il proprietario potenzia l'edificio", potenziato)
	if potenziato:
		_eq("  e il lavoratore resta sotto come scheletro", costruito.buried_character, "lavoratore")
		# Registro 96: `scheletro_conta` "sempre" paga lo scheletro anche se
		# l'edificio sta in piedi; "sotterrato" (la regola di sempre) no.
		var chi_p: PlayerState = gs.players[chi]
		var prima := chi_p.vp
		CardDB.constants["scheletro_conta"] = "sotterrato"
		Scoring._skeletons(gs)
		_eq("in piedi, lo scheletro non paga (sotterrato)", chi_p.vp, prima)
		CardDB.constants["scheletro_conta"] = "sempre"
		Scoring._skeletons(gs)
		_eq("  ma con \"sempre\" paga 6 meno l'era", chi_p.vp, prima + 6 - costruito.buried_character_era)
	CardDB.load_db(CardDB.DB_PATH)
	# Con la v1.5 la sepoltura c'e' ancora.
	var c1 := _game(2, 7)
	var p1 := c1.gs.current_player()
	p1.specialized_characters.append("pe_sciamano")
	_ok("v1.5: si costruisce", c1.place_worker(0) and _costruisci_qualcosa(c1, 0))
	var mio: Building = null
	for b in c1.gs.grid.buildings:
		if b.owner == p1.index: mio = b
	if mio != null:
		EraRules.bury_characters(c1.gs)
		_eq("  e il Personaggio si seppellisce come sempre", mio.buried_character, "pe_sciamano")

func _costruisci_qualcosa(ctl: GameController, col: int) -> bool:
	for card_id in ctl.gs.market.duplicate():
		for c in range(maxi(0, col - 1), mini(ctl.gs.grid.n_cols, col + 2)):
			if ctl.build(card_id, c, false): return true
	return false

# Registro 99: Colosseo, Il Silvicoltore e Speculazione edilizia senza la
# Vetusta'. Si prova sul file v2 con un edificio costruito davvero.
func _test_tre_carte_v2() -> void:
	if not FileAccess.file_exists("res://data/cards-v2.json"): return
	CardDB.load_db("res://data/cards-v2.json")
	var colosseo: Dictionary = CardDB.monuments["mo_colosseo"]["condition"]
	var silvicoltore: Dictionary = CardDB.legacies["er_il_silvicoltore"]["condition"]
	var speculazione: Dictionary = CardDB.events["ev_speculazione_edilizia"]
	_ok("il Colosseo v2 chiede resistenza 7", int(colosseo["target"].get("resistance", {}).get("min", 0)) == 7)
	_ok("Il Silvicoltore v2 chiede il bosco e l'era 1-2", silvicoltore["target"].has("era") and not silvicoltore["target"].has("vetusta"))
	_ok("Speculazione edilizia v2 colpisce i 2+ potenziamenti", int(speculazione["effects"][0]["target"].get("upgrades", {}).get("min", 0)) == 2)
	var ctl := _game(3, 990)
	var gs := ctl.gs
	while not gs.pending_choice.is_empty():
		ctl.choose(int((gs.pending_choice["options"] as Array)[0]))
	var p := gs.current_player()
	_ok("il primo attiva la colonna 1", ctl.place_worker(1))
	var mio: Building = null
	for card_id in gs.market.duplicate():
		for c in range(0, 3):
			if ctl.build(card_id, c, false):
				for b in gs.grid.buildings:
					if b.owner == p.index: mio = b
				break
		if mio != null: break
	_ok("  e costruisce", mio != null)
	if mio == null:
		CardDB.load_db(CardDB.DB_PATH)
		return
	_ok("con la resistenza sotto 7 il Colosseo non scatta", not Conditions.met(gs, p.index, colosseo))
	mio.bonus_res = 7 - int(mio.data["resistance"])
	_ok("  a 7 scatta", Conditions.met(gs, p.index, colosseo))
	# Il Silvicoltore: l'edificio dev'essere su bosco e dell'era 1-2.
	var su_bosco := false
	for c in range(mio.col_from, mio.col_to):
		if gs.grid.terrains[c] == Enums.Terrain.BOSCO: su_bosco = true
	_eq("Il Silvicoltore segue il terreno dell'edificio", Conditions.met(gs, p.index, silvicoltore), su_bosco)
	# Speculazione edilizia: -1 res solo con due potenziamenti sotto.
	gs.current_event = speculazione
	mio.upgrades.clear()
	_eq("senza potenziamenti Speculazione edilizia non tocca", Effects.event_resistance_modifier(gs, mio), 0)
	mio.upgrades.append("po_palizzata")
	mio.upgrades.append("po_idolo")
	_eq("  con due potenziamenti vale -1", Effects.event_resistance_modifier(gs, mio), -1)
	CardDB.load_db(CardDB.DB_PATH)

# Registro 100: l'effetto di ogni tessera scatta una volta per era, poi la
# tessera si gira; a inizio era si rigira. Si prova il fiume (+1 Denaro a chi
# attiva) e la pianura (lo sconto alla carta larga), che non dipendono da
# cosa c'e' nel mercato.
func _test_tessere_v2() -> void:
	if not FileAccess.file_exists("res://data/cards-v2.json"): return
	CardDB.load_db("res://data/cards-v2.json")
	_ok("il file v2 accende le tessere una volta per era", bool(CardDB.constants.get("tessere_una_volta_per_era", false)))
	_ok("  e il disturbo non c'e' piu'", not CardDB.constants.has("disturbo_vp"))
	var ctl := _game(3, 990)
	var gs := ctl.gs
	while not gs.pending_choice.is_empty():
		ctl.choose(int((gs.pending_choice["options"] as Array)[0]))
	_eq("a inizio era nessuna tessera e' girata", gs.tessere_usate.count(true), 0)
	var fiume := gs.grid.terrains.find(Enums.Terrain.FIUME)
	var pianura := gs.grid.terrains.find(Enums.Terrain.PIANURA)
	_ok("c'e' un fiume e una pianura", fiume >= 0 and pianura >= 0)
	if fiume < 0 or pianura < 0:
		CardDB.load_db(CardDB.DB_PATH)
		return
	# Il fiume: +1 Denaro alla prima attivazione dell'era, poi basta.
	var p := gs.current_player()
	var oro := p.oro
	var base: Dictionary = CardDB.terrains["fiume"]["base_production_by_era"]["1"]
	_ok("il primo attiva il fiume", ctl.place_worker(fiume))
	_eq("  e incassa la base piu' 1 Denaro della tessera", p.oro, oro + int(base["oro"]) + 1)
	_ok("  la tessera del fiume e' girata", gs.tessere_usate[fiume])
	ctl.pass_action()
	var p2 := gs.current_player()
	var oro2 := p2.oro
	_ok("il secondo attiva lo stesso fiume", ctl.place_worker(fiume))
	_eq("  e incassa solo la base", p2.oro, oro2 + int(base["oro"]))
	ctl.pass_action()
	# La pianura: lo sconto alla carta larga vale finche' la tessera e' da usare.
	var larga: Dictionary = CardDB.buildings["ed_villaggio_palizzato"]
	_eq("una carta larga in pianura sconta 1", BuildRules.pianura_discount(gs, larga, pianura), 1)
	gs.tessere_usate[pianura] = true
	_eq("  con la tessera girata non sconta", BuildRules.pianura_discount(gs, larga, pianura), 0)
	# Con le tessere permanenti (v1.5) lo sconto non guarda la tessera.
	CardDB.constants["tessere_una_volta_per_era"] = false
	_eq("  con le tessere permanenti sconta comunque", BuildRules.pianura_discount(gs, larga, pianura), 1)
	CardDB.constants["tessere_una_volta_per_era"] = true
	CardDB.load_db(CardDB.DB_PATH)



# Registro 109: con `passa_incasso` acceso, nel turno della v1.5 chi non fa
# l'azione dopo l'attivazione incassa 1 Costruzione piu' 1 risorsa a scelta.
# Spenta, passare non porta niente: cosi' la v1.5 e il file v2 di oggi non
# cambiano.
func _test_passa_incasso() -> void:
	if not FileAccess.file_exists("res://data/cards-v2.json"): return
	CardDB.load_db("res://data/cards-v2.json")
	_ok("nel file v2 la manopola e' spenta", not bool(CardDB.constants.get("passa_incasso", false)))
	var ctl := _game(3, 991)
	var gs := ctl.gs
	while not gs.pending_choice.is_empty():
		ctl.choose(int((gs.pending_choice["options"] as Array)[0]))
	var p := gs.current_player()
	_ok("si attiva una colonna", ctl.place_worker(0))
	var pietra := p.pietra
	var oro := p.oro
	_ok("  spenta, passare non incassa", not ctl.passa("oro"))
	ctl.pass_action()
	_eq("  e le risorse restano", p.pietra + p.oro, pietra + oro)
	_eq("  ma il turno e' passato", int(p.counters.get("az_passa", 0)), 1)

	CardDB.constants["passa_incasso"] = true
	var p2 := gs.current_player()
	_ok("accesa, si attiva", ctl.place_worker(1))
	var pietra2 := p2.pietra
	var idee2 := p2.idee
	_ok("  e passare incassa", ctl.passa("idee"))
	_eq("  1 Costruzione", p2.pietra, pietra2 + 1)
	_eq("  e 1 della risorsa scelta", p2.idee, idee2 + 1)
	_eq("  e il passaggio si conta", int(p2.counters.get("az_passa", 0)), 1)
	var p3 := gs.current_player()
	_ok("  anche dal tasto Passa", ctl.place_worker(2))
	var pietra3 := p3.pietra
	ctl.pass_action()
	_eq("  che senza scelta prende 2 Costruzione", p3.pietra, pietra3 + 2)
	# Il bot con la manopola accesa gioca partite intere e passa incassando.
	var finite := 0
	for g in 3:
		var c2 := _game(4, 996 + g)
		var guard := 0
		while c2.gs.phase != Enums.Phase.FINE_PARTITA and guard < 20000:
			StrategyBot.play_turn(c2, StrategyBot.canone()[g % StrategyBot.canone().size()])
			guard += 1
		if c2.gs.phase == Enums.Phase.FINE_PARTITA: finite += 1
	_eq("il bot finisce le partite con l'incasso acceso", finite, 3)
	CardDB.constants.erase("passa_incasso")
	CardDB.load_db(CardDB.DB_PATH)


# Registro 110: la regola rivela "giocatori meno uno" Monumenti; la costante
# `monumenti_rivelati_by_players` ne prova un altro numero. Le sagome con
# `min_players` entrano nel mazzo solo con abbastanza giocatori, e ricaricare
# un file dati non lascia avanzi del precedente.
func _test_monumenti_e_sagome_in_piu() -> void:
	var g2 := _game(2, 31).gs
	_eq("a due si rivela un Monumento", g2.monuments_open.size(), 1)
	CardDB.constants["monumenti_rivelati_by_players"] = {"2": 2}
	var g2b := _game(2, 31).gs
	_eq("  con la costante, due", g2b.monuments_open.size(), 2)
	var g3 := _game(3, 31).gs
	_eq("  e a tre restano due: la costante vale per il suo numero", g3.monuments_open.size(), 2)
	CardDB.constants.erase("monumenti_rivelati_by_players")

	if FileAccess.file_exists("res://data/proposte/cards-v2-abitazioni.json"):
		CardDB.load_db("res://data/proposte/cards-v2-abitazioni.json")
		_eq("il file delle abitazioni ha 84 sagome (60, 14 case in riserva, 10 abitazioni)", CardDB.buildings.size(), 84)
		var in_piu := 0
		for b in CardDB.buildings.values():
			if int(b.get("min_players", 0)) == 4: in_piu += 1
		_eq("  dieci da quattro giocatori", in_piu, 10)
		var c3 := _game(3, 32)
		var c4 := _game(4, 32)
		var mazzo3 := 0
		var mazzo4 := 0
		for e in range(1, 6):
			mazzo3 += (c3.gs.building_decks[e] as Array).size() + (c3.gs.market.size() if e == 1 else 0)
			mazzo4 += (c4.gs.building_decks[e] as Array).size() + (c4.gs.market.size() if e == 1 else 0)
		_eq("  a tre nei mazzi ce ne sono 60 (le case della riserva non ci stanno)", mazzo3, 60)
		_eq("  a quattro 70", mazzo4, 70)
		CardDB.load_db("res://data/cards-v2.json")
		_eq("ricaricando il file v2 le abitazioni non restano", CardDB.buildings.size(), 74)
	CardDB.load_db(CardDB.DB_PATH)


# Registro 116: le case non stanno nel mazzo dell'era, stanno nella riserva,
# tutte scoperte con le loro copie; si comprano come dal mercato, senza
# rimpiazzo; a fine era la riserva e' quella dell'era nuova. Nella v1.5 la
# riserva e' vuota.
func _test_riserva() -> void:
	var g1 := _game(3, 41).gs
	_ok("nella v1.5 la riserva e' vuota", g1.riserva.is_empty())
	if not FileAccess.file_exists("res://data/cards-v2.json"): return
	CardDB.load_db("res://data/cards-v2.json")
	var ctl := _game(3, 41)
	var gs := ctl.gs
	while not gs.pending_choice.is_empty():
		ctl.choose(int((gs.pending_choice["options"] as Array)[0]))
	_eq("nella v2 la riserva dell'era 1 ha sei voci: tre case per due copie", gs.riserva.size(), 6)
	var tipi := {}
	for id in gs.riserva: tipi[id] = int(tipi.get(id, 0)) + 1
	_eq("  tre tipi", tipi.size(), 3)
	_ok("  due copie ciascuno", tipi.values().all(func(n): return int(n) == 2))
	var nel_mazzo := 0
	for e in range(1, 6):
		for id in gs.building_decks[e]:
			if bool(CardDB.buildings[id].get("riserva", false)): nel_mazzo += 1
	for id in gs.market:
		if bool(CardDB.buildings[id].get("riserva", false)): nel_mazzo += 1
	_eq("  e nessuna casa sta nel mazzo o nel mercato", nel_mazzo, 0)
	_eq("  in vendita c'e' il mercato piu' la riserva", gs.in_vendita().size(), gs.market.size() + 6)
	var casa: String = gs.riserva[0]
	var p := gs.current_player()
	p.pietra = 5; p.oro = 5; p.idee = 5
	_ok("si attiva una colonna", ctl.place_worker(0))
	var mercato_prima := gs.market.duplicate()
	var costruita := false
	for c in gs.grid.n_cols:
		if ctl.build(casa, c, false):
			costruita = true
			break
	_ok("  e si costruisce una casa dalla riserva", costruita)
	_eq("  che perde una copia", gs.riserva.count(casa), 1)
	_eq("  e il mercato non si tocca", gs.market, mercato_prima)
	var copia := gs.duplica()
	_eq("la copia della partita porta la riserva", copia.riserva, gs.riserva)
	# A fine era la riserva e' quella dell'era nuova.
	var guard := 0
	while gs.era == 1 and gs.phase != Enums.Phase.FINE_PARTITA and guard < 200:
		StrategyBot.play_turn(ctl, "bilanciata")
		guard += 1
	if gs.era == 2:
		_eq("nell'era 2 la riserva e' di nuovo piena", gs.riserva.size(), 6)
		_ok("  con le case dell'era 2", gs.riserva.all(func(id): return int(CardDB.buildings[id]["era"]) == 2))
	CardDB.load_db(CardDB.DB_PATH)
