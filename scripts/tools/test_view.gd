# res://scripts/tools/test_view.gd
# Test della geometria della plancia (M5). BoardLayout e' puro, quindi si prova
# headless come il resto: se la vista si sposta, questi test lo dicono senza
# che qualcuno debba guardare lo schermo.
# Uso:  godot --headless res://scenes/test_view.tscn   (esce 1 se fallisce)
extends Node

var _passed := 0
var _failed := 0

func _ready() -> void:
	_run("una casella, una colonna", _test_colonne)
	_run("i binari sono le ere", _test_binari)
	_run("la fascia laterale sta sopra, e in ordine di quota", _test_quote)
	_run("nessuna sovrapposizione illecita", _test_sovrapposizioni)
	_run("dal punto all'edificio", _test_click)
	_run("le file laterali", _test_pannelli)
	_run("una partita vera sta tutta dentro la plancia", _test_partita)
	_run("3D: gli assi del tavolo", _test_3d_assi)
	_run("3D: quote, sagome e plinti", _test_3d_quote)
	_run("3D: cielo e telecamera", _test_3d_scena)
	_run("3D: una partita vera sta sulla strada", _test_3d_partita)
	print("\n%d superati, %d falliti" % [_passed, _failed])
	get_tree().quit(0 if _failed == 0 else 1)

func _run(name: String, f: Callable) -> void:
	print("\n— %s" % name)
	f.call()

func _ok(label: String, cond: bool, detail := "") -> void:
	if cond:
		_passed += 1
		print("  [ok]   %s" % label)
	else:
		_failed += 1
		printerr("  [KO]   %s%s" % [label, ("  — " + detail) if detail != "" else ""])

func _eq(label: String, got, want) -> void:
	_ok(label, got == want, "atteso %s, ottenuto %s" % [want, got])

# I float non si confrontano con ==: la geometria li produce per somme e
# prodotti, e 0.85 calcolato non e' 0.85 scritto.
func _approx(label: String, got: float, want: float) -> void:
	_ok(label, is_equal_approx(got, want), "atteso %f, ottenuto %f" % [want, got])

func _gioco(n := 3) -> GameController:
	var ctl := GameController.new()
	ctl.new_game(n, 11)
	return ctl

func _metti(gs: GameState, card_id: String, col: int, era: int, livello := 0,
		proprietario := 0) -> Building:
	var b := Building.new()
	b.uid = gs.new_uid()
	b.data = CardDB.buildings[card_id]
	b.owner = proprietario
	b.era_built = era
	b.col_from = col
	b.col_to = col + int(b.data["width"])
	b.level = livello
	gs.grid.buildings.append(b)
	return b

func _largo(n: int) -> String:
	for id in CardDB.buildings:
		if int(CardDB.buildings[id]["width"]) == n: return id
	return ""

func _test_colonne() -> void:
	var gs := _gioco().gs
	_ok("le colonne procedono da sinistra a destra",
		BoardLayout.col_x(0) < BoardLayout.col_x(1))
	_eq("una casella e' larga CELL.x", BoardLayout.span_w(1), BoardLayout.CELL.x)
	_eq("due caselle sono due caselle piu' lo stacco",
		BoardLayout.span_w(2), 2.0 * BoardLayout.CELL.x + BoardLayout.GUTTER)

	# Un edificio largo 3 deve coprire esattamente le tre colonne che occupa,
	# non una in piu' ne' una in meno.
	var id3 := _largo(3)
	_ok("esiste un edificio da 3 caselle", id3 != "")
	var b := _metti(gs, id3, 1, 1)
	var r := BoardLayout.building_rect(gs, b)
	_eq("parte dalla prima colonna che occupa", r.position.x, BoardLayout.col_x(1))
	_eq("  e finisce dove finisce la terza",
		r.position.x + r.size.x, BoardLayout.col_x(3) + BoardLayout.CELL.x)

func _test_binari() -> void:
	var gs := _gioco().gs
	var a := _metti(gs, "ed_capanne", 0, 1)
	var b := _metti(gs, "ed_capanne", 0, 3)
	var ra := BoardLayout.building_rect(gs, a)
	var rb := BoardLayout.building_rect(gs, b)
	_ok("l'era 1 sta sopra l'era 3", ra.position.y < rb.position.y)
	_eq("  e stanno nella stessa colonna", ra.position.x, rb.position.x)
	_eq("l'edificio dell'era 3 sta sul binario 3",
		rb.position.y, BoardLayout.rail_y(gs, 3))
	_ok("i terreni stanno sotto tutti i binari",
		BoardLayout.terrain_y(gs) > BoardLayout.rail_y(gs, BoardLayout.RAILS))

func _test_quote() -> void:
	var gs := _gioco().gs
	_eq("senza sopraelevazioni la fascia non occupa spazio", BoardLayout.stack_h(gs), 0.0)
	var terra := _metti(gs, "ed_capanne", 2, 1)
	_eq("  nemmeno con soli edifici a terra", BoardLayout.stack_h(gs), 0.0)

	var uno := _metti(gs, "ed_capanne", 2, 2, 1)
	var due := _metti(gs, "ed_capanne", 2, 3, 2)
	_ok("con una sopraelevazione la fascia si apre", BoardLayout.stack_h(gs) > 0.0)
	var r1 := BoardLayout.building_rect(gs, uno)
	var r2 := BoardLayout.building_rect(gs, due)
	_ok("la quota 2 sta sopra la quota 1", r2.position.y < r1.position.y)
	_ok("e la quota 1 sta sopra i binari",
		r1.position.y + r1.size.y <= BoardLayout.rails_y(gs))
	var rt := BoardLayout.building_rect(gs, terra)
	_ok("l'edificio a terra resta sul suo binario", rt.position.y >= BoardLayout.rails_y(gs))

func _test_sovrapposizioni() -> void:
	# Due edifici alla stessa quota non possono occupare la stessa colonna:
	# e' una regola, e la plancia deve mostrarla senza sovrapposizioni.
	var gs := _gioco().gs
	_metti(gs, "ed_capanne", 0, 1)
	_metti(gs, "ed_capanne", 1, 1)
	_metti(gs, "ed_capanne", 0, 2)
	_metti(gs, "ed_capanne", 2, 1, 1)
	_metti(gs, "ed_capanne", 3, 2, 1)
	var tt := BoardLayout.tiles(gs)
	var scontri := 0
	for i in tt.size():
		for j in range(i + 1, tt.size()):
			var a: Rect2 = tt[i]["rect"]
			var b: Rect2 = tt[j]["rect"]
			if a.intersects(b): scontri += 1
	_eq("nessun riquadro ne tocca un altro", scontri, 0)

func _test_click() -> void:
	var gs := _gioco().gs
	var sotto := _metti(gs, "ed_capanne", 2, 1)
	var r := BoardLayout.building_rect(gs, sotto)
	var dentro := r.position + r.size / 2.0
	_eq("il punto dentro trova l'edificio", int(BoardLayout.at(gs, dentro)["uid"]), sotto.uid)
	var fuori := Vector2(r.position.x - 40.0, r.position.y)
	_ok("il punto fuori non trova nulla", BoardLayout.at(gs, fuori).is_empty())

	# Un sotterrato e' coperto: il clic deve prendere cio' che si vede.
	# Alla stessa quota non si sovrappongono, quindi il caso vero e' il
	# riquadro del binario contro quello della fascia: si verifica che il
	# sotterrato resti raggiungibile finche' nessuno lo copre sullo schermo.
	sotto.is_buried = true
	_eq("il sotterrato resta cliccabile se nulla lo copre a schermo",
		int(BoardLayout.at(gs, dentro)["uid"]), sotto.uid)

	_eq("la colonna si ricava dal punto", BoardLayout.column_at(gs, dentro), 2)
	_eq("  e da un punto nella striscia dei terreni",
		BoardLayout.column_at(gs, BoardLayout.terrain_rect(gs, 4).position + Vector2(4, 4)), 4)
	_eq("  fuori dalla plancia non c'e' colonna",
		BoardLayout.column_at(gs, Vector2(-100, -100)), -1)

func _test_pannelli() -> void:
	var ctl := _gioco()
	var gs := ctl.gs
	var righe := BoardLayout.side_rows(gs)
	var carte := 0
	var titoli := 0
	for r in righe:
		if str(r["kind"]) == "titolo": titoli += 1
		else: carte += 1
	_eq("un titolo per sezione", titoli, 4)
	_eq("una riga per carta in fila", carte,
		gs.market.size() + gs.char_row.size() + gs.upg_row.size() + gs.monuments_open.size())
	_ok("le file stanno a destra della plancia",
		BoardLayout.panel_x(gs) > BoardLayout.col_x(gs.grid.n_cols - 1) + BoardLayout.CELL.x)
	var scontri := 0
	for i in righe.size():
		for j in range(i + 1, righe.size()):
			if (righe[i]["rect"] as Rect2).intersects(righe[j]["rect"]): scontri += 1
	_eq("e non si accavallano fra loro", scontri, 0)

func _test_partita() -> void:
	# Una partita vera, giocata fino in fondo: ogni riquadro deve stare dentro
	# la plancia. E' la prova che la geometria regge i casi che i test
	# costruiti a mano non pensano, come un colossale a quota 3.
	var ctl := _gioco()
	var giri := 0
	while ctl.gs.phase != Enums.Phase.FINE_PARTITA and giri < 4000:
		RandomBot.play_turn(ctl)
		giri += 1
	var gs := ctl.gs
	_ok("la partita e' finita", gs.phase == Enums.Phase.FINE_PARTITA)
	_ok("  con edifici sulla plancia", gs.grid.buildings.size() > 10)
	var dim := BoardLayout.board_size(gs)
	var fuori := 0
	for t in BoardLayout.tiles(gs):
		var r: Rect2 = t["rect"]
		if r.position.x < 0 or r.position.y < 0: fuori += 1
		elif r.position.x + r.size.x > dim.x: fuori += 1
		elif r.position.y + r.size.y > dim.y: fuori += 1
	_eq("nessun riquadro esce dalla plancia", fuori, 0)

	# Alla stessa quota, mai due riquadri sovrapposti: e' l'invariante di
	# regola "un edificio sta tutto a un solo livello", vista da qui.
	var per_quota := {}
	for t in BoardLayout.tiles(gs):
		var k := "%d:%d" % [int(t["level"]), int(t["era"]) if int(t["level"]) == 0 else 0]
		if not per_quota.has(k): per_quota[k] = []
		per_quota[k].append(t["rect"])
	var scontri := 0
	for k in per_quota:
		var lista: Array = per_quota[k]
		for i in lista.size():
			for j in range(i + 1, lista.size()):
				if (lista[i] as Rect2).intersects(lista[j]): scontri += 1
	_eq("nessuna sovrapposizione alla stessa quota", scontri, 0)

# ---- geometria 3D ---------------------------------------------------
# Il tavolo: X le colonne, Z i binari con l'ERA 1 DAVANTI, Y le quote.
func _test_3d_assi() -> void:
	_ok("l'era 1 sta davanti a tutte", BoardLayout3D.rail_z(1) < BoardLayout3D.rail_z(2))
	_ok("  e l'era 5 in fondo", BoardLayout3D.rail_z(4) < BoardLayout3D.rail_z(5))
	_ok("i binari sono distanziati: e' cio' che lascia vedere le basette",
		BoardLayout3D.rail_z(2) - BoardLayout3D.rail_z(1) > BoardLayout3D.SLOT_D)
	_ok("le colonne procedono lungo la X", BoardLayout3D.col_x(0) < BoardLayout3D.col_x(1))
	_ok("le quote salgono lungo la Y",
		BoardLayout3D.level_y(2) > BoardLayout3D.level_y(1))
	_approx("due colonne sono due slot piu' uno stacco", BoardLayout3D.span_w(2),
		2.0 * BoardLayout3D.SLOT_W + BoardLayout3D.GAP_X)

	# Le tessere non si compenetrano, ne' di fianco ne' in profondita'.
	var scontri := 0
	for c in 4:
		for e in range(1, BoardLayout3D.RAILS + 1):
			var a := BoardLayout3D.tile_box(c, e)
			for c2 in 4:
				for e2 in range(1, BoardLayout3D.RAILS + 1):
					if c2 == c and e2 == e: continue
					if a.intersects(BoardLayout3D.tile_box(c2, e2)): scontri += 1
	_eq("nessuna tessera tocca un'altra", scontri, 0)

# L'errore che avevo fatto: con la quota piu' bassa di una sagoma, due livelli
# si compenetrano e la plancia diventa illeggibile. Il test lo impedisce per
# TUTTI i 60 edifici, non per quello che ho guardato io.
func _test_3d_quote() -> void:
	var gs := _gioco().gs
	var piu_alta := 0.0
	var nome := ""
	for id in CardDB.buildings:
		var b := Building.new()
		b.data = CardDB.buildings[id]
		b.col_from = 0
		b.col_to = int(b.data["width"])
		var h: float = BoardLayout3D.standee_size(b).y
		if h > piu_alta:
			piu_alta = h
			nome = str(b.data["name"])
	_ok("nessuna sagoma e' piu' alta del passo fra le quote (%s: %.2f su %.2f)"
		% [nome, piu_alta, BoardLayout3D.LEVEL_H], piu_alta <= BoardLayout3D.LEVEL_H,
		"con una sagoma piu' alta del passo, due quote si compenetrano")

	# Il plinto e' un dado sotto la sagoma, non una lastra che copre la
	# colonna: la basetta vera sono gli edifici sotto, che restano visibili.
	var sopra := _metti(gs, "ed_capanne", 2, 3, 1)
	var plinto := BoardLayout3D.base_box(gs, sopra)
	_approx("il plinto e' profondo uno slot, non tutta la strada",
		plinto.size.z, BoardLayout3D.SLOT_D)
	_ok("  ed e' molto piu' sottile della profondita' dei binari",
		plinto.size.z < BoardLayout3D.board_d() / 2.0)
	_ok("il plinto sta sotto la sagoma",
		plinto.position.y + plinto.size.y <= BoardLayout3D.standee_base(gs, sopra).y + 0.001)

func _test_3d_scena() -> void:
	var gs := _gioco().gs
	_metti(gs, "ed_capanne", 0, 1)
	var cielo := BoardLayout3D.sky_rect(gs)
	_ok("il cielo sta dietro l'ultimo binario",
		cielo.position.z > BoardLayout3D.rail_z(BoardLayout3D.RAILS) + BoardLayout3D.SLOT_D)
	_ok("  ed e' piu' largo della strada", cielo.size.x > BoardLayout3D.board_w(gs))
	_ok("  e in piedi, non steso", cielo.size.y > 0.0 and cielo.size.z == 0.0)

	var cam := BoardLayout3D.camera_position(gs)
	_ok("la telecamera sta davanti alla prima fila", cam.z < BoardLayout3D.rail_z(1))
	_ok("  e alzata, per vedere oltre l'era 1", cam.y > 1.0)
	var mira := BoardLayout3D.camera_target(gs)
	_ok("  e guarda verso il fondo della strada", mira.z > cam.z)

func _test_3d_partita() -> void:
	# Una partita vera: ogni sagoma deve stare sulla strada e nessuna coppia
	# alla stessa quota deve occupare lo stesso posto.
	var ctl := _gioco()
	var giri := 0
	while ctl.gs.phase != Enums.Phase.FINE_PARTITA and giri < 4000:
		RandomBot.play_turn(ctl)
		giri += 1
	var gs := ctl.gs
	var sopraelevati := 0
	for b in gs.grid.buildings:
		if b.level > 0: sopraelevati += 1
	_ok("la partita ha prodotto sopraelevazioni", sopraelevati > 0)

	var fuori := 0
	for b in gs.grid.buildings:
		var c := BoardLayout3D.standee_base(gs, b)
		var mezza: float = BoardLayout3D.standee_size(b).x / 2.0
		if c.x - mezza < -0.001 or c.x + mezza > BoardLayout3D.board_w(gs) + 0.001: fuori += 1
		if c.z < -0.001 or c.z > BoardLayout3D.board_d() + 0.001: fuori += 1
	_eq("nessuna sagoma esce dalla strada", fuori, 0)

	# Stessa quota e colonne sovrapposte non possono coesistere: e'
	# l'invariante "un edificio sta tutto a un solo livello", vista da qui.
	var scontri := 0
	for i in gs.grid.buildings.size():
		for j in range(i + 1, gs.grid.buildings.size()):
			var a: Building = gs.grid.buildings[i]
			var b2: Building = gs.grid.buildings[j]
			if a.level != b2.level: continue
			if a.level == 0 and a.era_built != b2.era_built: continue
			if a.col_from < b2.col_to and b2.col_from < a.col_to: scontri += 1
	_eq("nessuna sagoma occupa il posto di un'altra", scontri, 0)
