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
	print("\n%d superati, %d falliti" % [_passed, _failed])
	get_tree().quit(0 if _failed == 0 else 1)

func _run(name: String, f: Callable) -> void:
	print("\n— %s" % name)
	f.call()

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
