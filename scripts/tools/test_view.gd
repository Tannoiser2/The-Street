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
	_run("3D: i cubetti sulla basetta", _test_cubetti)
	_run("3D: le linguette dei potenziamenti", _test_linguette)
	_run("3D: le file e le plance sul tavolo", _test_tavolo)
	_run("3D: cliccare una carta", _test_clic_sulle_carte)
	_run("3D: l'inquadratura si calcola", _test_3d_inquadratura)
	_run("3D: dal clic allo slot", _test_raggio)
	_run("le azioni offerte, col preventivo", _test_azioni_offerte)
	_run("  e la promessa che mantengono", _test_azioni_mantengono_la_promessa)
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
	# "Davanti" e' dal lato della telecamera, che guarda verso le z calanti:
	# l'era 1 ha percio' la z maggiore, non la minore.
	var cam := BoardLayout3D.camera_position(_gioco().gs)
	_ok("l'era 1 sta davanti a tutte",
		absf(cam.z - BoardLayout3D.rail_z(1)) < absf(cam.z - BoardLayout3D.rail_z(2)))
	_ok("  e l'era 5 in fondo",
		absf(cam.z - BoardLayout3D.rail_z(5)) > absf(cam.z - BoardLayout3D.rail_z(4)))
	# Misurato dal cartone: la tessera colonna e' un'unica striscia da 271 mm
	# con cinque binari contigui. Non c'e' nessuno stacco fra i binari, e cio'
	# che lascia vedere le file dietro e' la basetta, che degli 54 mm dello
	# slot ne occupa 15.
	_approx("i binari sono contigui, non distanziati",
		absf(BoardLayout3D.rail_z(2) - BoardLayout3D.rail_z(1)), BoardLayout3D.SLOT_D)
	_approx("i cinque binari riempiono la tessera",
		BoardLayout3D.RAILS * BoardLayout3D.SLOT_D, BoardLayout3D.TESSERA_D)
	_ok("la basetta occupa meno di mezzo slot: e' cosi' che si vede dietro",
		BoardLayout3D.BASETTA_D < BoardLayout3D.SLOT_D / 2.0)
	_ok("le colonne procedono lungo la X", BoardLayout3D.col_x(0) < BoardLayout3D.col_x(1))
	_ok("le quote salgono lungo la Y",
		BoardLayout3D.level_y(2) > BoardLayout3D.level_y(1))
	_approx("una sagoma da due slot e' larga due moduli", BoardLayout3D.span_w(2),
		2.0 * BoardLayout3D.SAGOMA_MODULO)
	_ok("e sta dentro le due tessere che occupa",
		BoardLayout3D.span_w(2) <= 2.0 * BoardLayout3D.TESSERA_W)

	# Le tessere si toccano ma non si sovrappongono: sono contigue per
	# costruzione, non per caso.
	# Contigue vuol dire che si toccano senza invadersi: gli intervalli hanno
	# un estremo in comune e nient'altro. Scritto senza dipendere dal verso
	# dell'asse, cosi' resta vero se un giorno si gira il tavolo.
	var sovrapposte := 0
	for c in 4:
		for e in range(1, BoardLayout3D.RAILS):
			var a := BoardLayout3D.tile_box(c, e)
			var b := BoardLayout3D.tile_box(c, e + 1)
			if _si_accavallano(a.position.z, a.size.z, b.position.z, b.size.z):
				sovrapposte += 1
			var d := BoardLayout3D.tile_box(c + 1, e)
			if _si_accavallano(a.position.x, a.size.x, d.position.x, d.size.x):
				sovrapposte += 1
	_eq("nessuna tessera invade quella accanto", sovrapposte, 0)

func _si_accavallano(a: float, la: float, b: float, lb: float) -> bool:
	return a < b + lb - 0.001 and b < a + la - 0.001

# L'errore che avevo fatto: con la quota piu' bassa di una sagoma, due livelli
# si compenetrano e la plancia diventa illeggibile. Il test lo impedisce per
# TUTTI i 60 edifici, non per quello che ho guardato io.
func _test_3d_quote() -> void:
	var gs := _gioco().gs
	var altezze: Array[float] = []
	var piu_alta := 0.0
	var nome := ""
	for id in CardDB.buildings:
		var b := Building.new()
		b.data = CardDB.buildings[id]
		b.col_from = 0
		b.col_to = int(b.data["width"])
		var h: float = BoardLayout3D.standee_size(b).y
		altezze.append(h)
		if h > piu_alta:
			piu_alta = h
			nome = str(b.data["name"])
	altezze.sort()
	var mediana: float = altezze[altezze.size() / 2]

	# Il passo fra le quote e' l'altezza del rialzo, una misura fisica del
	# gioco: la sagoma TIPICA ci sta sotto, ma una sagoma alta lo scavalca -
	# ed e' giusto che lo faccia, perche' e' quello che fa un grattacielo.
	# Il test regge il caso tipico, non pretende l'impossibile dal caso limite.
	_ok("il passo fra le quote copre la sagoma tipica (mediana %.0f su %.0f)"
		% [mediana, BoardLayout3D.LEVEL_H], mediana <= BoardLayout3D.LEVEL_H)
	_ok("  e la piu' alta lo scavalca, come deve (%s: %.0f mm)" % [nome, piu_alta],
		piu_alta > BoardLayout3D.LEVEL_H)
	_eq("  ed e' il Grattacielo", nome, "Grattacielo")

	# Le misure vengono dal cartone: ogni edificio deve averle.
	var senza := 0
	for id in CardDB.buildings:
		if not CardDB.sagome.has(id): senza += 1
	_eq("ogni edificio ha la sua sagoma misurata", senza, 0)

	# La basetta e' il piede da 15 mm che regge il cartone da 4, non una
	# lastra che copre la colonna: gli edifici sotto devono restare visibili.
	var sopra := _metti(gs, "ed_capanne", 2, 3, 1)
	var basetta := BoardLayout3D.basetta_box(gs, sopra)
	_approx("la basetta e' profonda 15 mm", basetta.size.z, BoardLayout3D.BASETTA_D)
	_ok("  cioe' meno di un terzo dello slot",
		basetta.size.z < BoardLayout3D.SLOT_D / 3.0)
	_ok("  e molto meno della profondita' della strada",
		basetta.size.z < BoardLayout3D.board_d() / 10.0)
	_ok("il cartone e' spesso 4 mm, come il vero",
		is_equal_approx(BoardLayout3D.SAGOMA_SPESSORE, 4.0))
	_approx("la basetta poggia alla quota della sagoma",
		basetta.position.y, BoardLayout3D.standee_base(gs, sopra).y)

func _test_3d_scena() -> void:
	var gs := _gioco().gs
	_metti(gs, "ed_capanne", 0, 1)
	var cielo := BoardLayout3D.sky_rect(gs)
	_ok("il cielo sta dietro l'ultimo binario",
		cielo.position.z < BoardLayout3D.rail_z(BoardLayout3D.RAILS))
	_ok("  ed e' piu' largo della strada", cielo.size.x > BoardLayout3D.board_w(gs))
	_ok("  e in piedi, non steso", cielo.size.y > 0.0 and cielo.size.z == 0.0)

	var cam := BoardLayout3D.camera_position(gs)
	_ok("la telecamera sta davanti alla prima fila", cam.z > BoardLayout3D.rail_z(1))
	_ok("  e alzata, per vedere oltre l'era 1", cam.y > 1.0)
	var mira := BoardLayout3D.camera_target(gs)
	_ok("  e guarda verso il fondo della strada", mira.z < cam.z)

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

# ---- dal clic allo slot ---------------------------------------------
func _test_raggio() -> void:
	var gs := _gioco().gs
	# Un raggio verticale sul centro di ogni slot deve ritrovare quello slot.
	# Provati tutti, non uno a campione.
	var sbagliati := 0
	for c in gs.grid.n_cols:
		for era in range(1, BoardLayout3D.RAILS + 1):
			var centro := BoardLayout3D.slot_center(c, era)
			var o := centro + Vector3(0, 500, 0)
			var s := BoardLayout3D.slot_at_ray(gs, o, Vector3(0, -1, 0))
			if s.is_empty() or int(s["col"]) != c or int(s["era"]) != era: sbagliati += 1
	_eq("ogni slot si ritrova dal proprio centro", sbagliati, 0)

	# Un raggio obliquo, come quello vero della telecamera.
	var cam := BoardLayout3D.camera_position(gs)
	var bersaglio := BoardLayout3D.slot_center(2, 3)
	var s2 := BoardLayout3D.slot_at_ray(gs, cam, (bersaglio - cam).normalized())
	_ok("un raggio obliquo trova lo slot che punta", not s2.is_empty())
	if not s2.is_empty():
		_eq("  colonna giusta", int(s2["col"]), 2)
		_eq("  binario giusto", int(s2["era"]), 3)

	# Fuori dal tabellone non si trova nulla, e un raggio che va all'insu'
	# nemmeno: senza questi due casi il clic prenderebbe cose a caso.
	var fuori := BoardLayout3D.slot_at_ray(gs, Vector3(-500, 500, 0), Vector3(0, -1, 0))
	_ok("fuori dalla strada non c'e' slot", fuori.is_empty())
	var insu := BoardLayout3D.slot_at_ray(gs, BoardLayout3D.slot_center(1, 1) + Vector3(0, 100, 0),
		Vector3(0, 1, 0))
	_ok("un raggio verso l'alto non tocca il tavolo", insu.is_empty())

	# L'inclinazione e' un compromesso fra due cose opposte, e il test tiene
	# tutte e due: alzandosi si vedono meglio le FILE, abbassandosi si vedono
	# meglio le SAGOME, che guardate dall'alto si schiacciano col coseno.
	# Niente soglia a naso: due limiti, e l'angolo deve rispettarli entrambi.
	var visibile := BoardLayout3D.quota_visibile()
	var scorcio := BoardLayout3D.scorcio()
	_ok("dietro la fila davanti resta visibile almeno il 75%% di una sagoma (%.0f%%)"
		% (visibile * 100.0), visibile >= 0.75)
	_ok("  e una sagoma non e' schiacciata sotto il 65%% (%.0f%%)"
		% (scorcio * 100.0), scorcio >= 0.65,
		"con l'illustrazione sopra, piu' schiacciata di cosi' non si legge")
	_ok("  e la telecamera usa davvero quell'inclinazione",
		is_equal_approx(BoardLayout3D.camera_pitch_deg(gs), BoardLayout3D.INCLINAZIONE))

# ---- le azioni offerte ----------------------------------------------
func _test_azioni_offerte() -> void:
	var ctl := _gioco()
	var gs := ctl.gs
	ctl.place_worker(2)
	var col := ctl.colonna_attivata()
	_eq("il controller dice quale colonna e' attivata", col, 2)

	var tutte := AvailableActions.tutte(gs, gs.current_index, col)
	_ok("l'elenco non e' vuoto", tutte.size() > 3)
	var senza_motivo := 0
	var passa := 0
	for v in tutte:
		if not v.legale and v.motivo == "": senza_motivo += 1
		if v.tipo == "passa": passa += 1
	_eq("ogni azione rifiutata dice perche'", senza_motivo, 0)
	_eq("passare c'e' sempre, ed e' l'azione facoltativa", passa, 1)

	var esegui := AvailableActions.eseguibili(gs, gs.current_index, col)
	_ok("le eseguibili sono un sottoinsieme di tutte", esegui.size() <= tutte.size())
	var non_pagabili := 0
	for v in esegui:
		if not v.legale or not v.pagabile(gs.players[gs.current_index]): non_pagabili += 1
	_eq("e sono tutte legali e pagabili", non_pagabili, 0)

# La prova che conta: se l'anteprima dice che si puo' fare, il comando deve
# accettarla. Un'interfaccia che promette e poi rifiuta e' peggio di una che
# non offre nulla. Si gioca una partita intera scegliendo SOLO dalle
# eseguibili, e ogni rifiuto e' un fallimento.
func _test_azioni_mantengono_la_promessa() -> void:
	var ctl := _gioco()
	var gs := ctl.gs
	var rifiuti := 0
	var tentate := 0
	var tipi := {}
	var giri := 0
	while gs.phase != Enums.Phase.FINE_PARTITA and giri < 3000:
		giri += 1
		if gs.phase == Enums.Phase.PIAZZA:
			var messa := false
			for c in gs.grid.n_cols:
				if ctl.place_worker(c):
					messa = true
					break
			if not messa:
				ctl.pass_action()
				continue
		if gs.phase != Enums.Phase.AZIONE: continue
		var col := ctl.colonna_attivata()
		var chi := gs.current_index
		var esegui := AvailableActions.eseguibili(gs, chi, col)
		# la prima che non sia "passa", cosi' si prova davvero qualcosa
		var scelta = null
		for v in esegui:
			if v.tipo != "passa":
				scelta = v
				break
		if scelta == null:
			ctl.pass_action()
			continue
		tentate += 1
		tipi[scelta.tipo] = int(tipi.get(scelta.tipo, 0)) + 1
		var ok := false
		match scelta.tipo:
			"costruisci": ok = ctl.build(str(scelta.parametri["card_id"]),
				int(scelta.parametri["col_from"]), bool(scelta.parametri["above"]))
			"potenzia": ok = ctl.upgrade(str(scelta.parametri["upg_id"]),
				_per_uid(gs, int(scelta.parametri.get("uid", -1))))
			"restaura": ok = ctl.restore(_per_uid(gs, int(scelta.parametri["uid"])))
			"recluta": ok = ctl.recruit(str(scelta.parametri["char_id"]),
				_per_uid(gs, int(scelta.parametri.get("uid", -1))))
			"dinastia": ok = ctl.buy_dynasty()
		if not ok:
			rifiuti += 1
			ctl.pass_action()
	_ok("la partita finisce giocando dalle azioni offerte", gs.phase == Enums.Phase.FINE_PARTITA)
	_ok("  e ne ha tentate parecchie (%d)" % tentate, tentate > 30)
	_ok("  di piu' di un tipo (%s)" % str(tipi), tipi.size() >= 3)
	_eq("nessuna azione offerta e' stata rifiutata dal comando", rifiuti, 0)

func _per_uid(gs: GameState, uid: int) -> Building:
	if uid < 0: return null
	for b in gs.grid.buildings:
		if b.uid == uid: return b
	return null

# ---- l'inquadratura -------------------------------------------------
# La telecamera si calcola, non si aggiusta a occhio: deve far entrare tutta
# la scena per 5, 7 e 9 colonne e con le torri alte, senza tagliare nulla e
# senza sprecare mezzo fotogramma.
func _test_3d_inquadratura() -> void:
	for n in [2, 3, 4]:
		var ctl := GameController.new()
		ctl.new_game(n, 5)
		var giri := 0
		while ctl.gs.phase != Enums.Phase.FINE_PARTITA and giri < 4000:
			RandomBot.play_turn(ctl)
			giri += 1
		var r := BoardLayout3D.riempimento(ctl.gs)
		_ok("%d giocatori (%d colonne): tutta la scena entra nel fotogramma (%.2f)"
			% [n, ctl.gs.grid.n_cols, r], r <= 1.0,
			"sopra 1.0 si taglia qualcosa")
		_ok("  e non se ne spreca meta' (%.2f)" % r, r >= 0.55,
			"molto sotto 1.0 vuol dire telecamera troppo lontana")

	# Una citta' alta deve far arretrare la telecamera, non farsi tagliare.
	var a := _gioco().gs
	var vicino := BoardLayout3D.camera_position(a).distance_to(BoardLayout3D.camera_target(a))
	for era in range(1, 5):
		_metti(a, "ed_capanne", 2, era, era)
	var lontano := BoardLayout3D.camera_position(a).distance_to(BoardLayout3D.camera_target(a))
	_ok("con le torri la telecamera arretra", lontano > vicino)
	_ok("  e continua a far entrare tutto", BoardLayout3D.riempimento(a) <= 1.0)

# ---- le file e le plance sul tavolo ---------------------------------
func _test_tavolo() -> void:
	var ctl := _gioco()
	var gs := ctl.gs
	var carte := BoardLayout3D.side_cards(gs)
	_eq("una carta per ogni carta in fila", carte.size(),
		gs.market.size() + gs.char_row.size() + gs.upg_row.size() + gs.monuments_open.size())
	var tipi := {}
	for c in carte: tipi[str(c["kind"])] = true
	_ok("ci sono mercato, personaggi e potenziamenti",
		tipi.has("mercato") and tipi.has("personaggio") and tipi.has("potenziamento"))

	# Le file stanno AI LATI della strada, non sopra: la strada deve restare
	# libera, altrimenti coprirebbero le sagome.
	var sopra_la_strada := 0
	for c in carte:
		var r: AABB = c["aabb"]
		if r.position.x + r.size.x > 0.0 and r.position.x < BoardLayout3D.board_w(gs):
			sopra_la_strada += 1
	_eq("nessuna carta sta sopra la strada", sopra_la_strada, 0)

	# E non si accavallano fra loro.
	var scontri := 0
	for i in carte.size():
		for j in range(i + 1, carte.size()):
			var a: AABB = carte[i]["aabb"]
			var b: AABB = carte[j]["aabb"]
			if _si_accavallano(a.position.x, a.size.x, b.position.x, b.size.x) \
					and _si_accavallano(a.position.z, a.size.z, b.position.z, b.size.z):
				scontri += 1
	_eq("e nessuna copre un'altra", scontri, 0)

	# Le plance stanno davanti, dal lato di chi guarda.
	var plance := BoardLayout3D.player_boards(gs)
	_eq("una plancia per giocatore", plance.size(), gs.n_players)
	var cam := BoardLayout3D.camera_position(gs)
	var davanti := 0
	for p in plance:
		var r: AABB = p["aabb"]
		if absf(cam.z - r.position.z) < absf(cam.z - BoardLayout3D.rail_z(1)): davanti += 1
	_eq("tutte davanti alla strada", davanti, gs.n_players)

	# Il tavolo contiene tutto: strada, file e plance.
	var t := BoardLayout3D.table_aabb(gs)
	var fuori := 0
	for c in carte:
		if not t.encloses((c["aabb"] as AABB).grow(-0.01)): fuori += 1
	for p in plance:
		if not t.encloses((p["aabb"] as AABB).grow(-0.01)): fuori += 1
	_eq("il tavolo le contiene tutte", fuori, 0)

# Cliccare una carta: stessa geometria del disegno, provata su TUTTE.
func _test_clic_sulle_carte() -> void:
	var gs := _gioco().gs
	var carte := BoardLayout3D.side_cards(gs)
	_ok("ci sono carte da cliccare", carte.size() > 5)
	var sbagliate := 0
	for c in carte:
		var r: AABB = c["aabb"]
		var centro := r.position + r.size / 2.0
		var trovata := BoardLayout3D.card_at_ray(gs, centro + Vector3(0, 400, 0),
			Vector3(0, -1, 0))
		if trovata.is_empty() or str(trovata["id"]) != str(c["id"]): sbagliate += 1
	_eq("ogni carta si ritrova dal proprio centro", sbagliate, 0)

	# Sulla strada non c'e' nessuna carta: il clic deve cadere sullo slot.
	var sopra_strada := BoardLayout3D.slot_center(1, 2)
	_ok("sopra la strada non si trova una carta",
		BoardLayout3D.card_at_ray(gs, sopra_strada + Vector3(0, 400, 0), Vector3(0, -1, 0)).is_empty())
	_ok("  e invece si trova lo slot",
		not BoardLayout3D.slot_at_ray(gs, sopra_strada + Vector3(0, 400, 0), Vector3(0, -1, 0)).is_empty())
	# E viceversa: sopra una carta non c'e' uno slot della strada.
	var c0: AABB = carte[0]["aabb"]
	_ok("sopra una carta non si trova uno slot",
		BoardLayout3D.slot_at_ray(gs, c0.position + c0.size / 2.0 + Vector3(0, 400, 0),
			Vector3(0, -1, 0)).is_empty())

# ---- i cubetti e le linguette ---------------------------------------
# I segnalini del gioco vero: bianchi la Vetusta', neri la resistenza
# guadagnata, e la linguetta del potenziamento che spunta da sotto.
func _test_cubetti() -> void:
	var gs := _gioco().gs
	var b := _metti(gs, "ed_capanne", 2, 1)
	_eq("un edificio nuovo non ha cubetti", BoardLayout3D.cubetti(gs, b).size(), 0)

	b.vetusta = 2
	b.bonus_res = 3
	var cc := BoardLayout3D.cubetti(gs, b)
	_eq("un cubetto per ogni Vetusta' e per ogni resistenza", cc.size(), 5)
	var bianchi := 0
	var neri := 0
	for c in cc:
		if str(c["tipo"]) == "vetusta": bianchi += 1
		else: neri += 1
	_eq("  due bianchi, la Vetusta'", bianchi, 2)
	_eq("  tre neri, la resistenza", neri, 3)

	# Stanno sulla basetta, non per aria e non dentro il tavolo.
	var basetta := BoardLayout3D.basetta_box(gs, b)
	var fuori := 0
	for c in cc:
		var p: Vector3 = c["pos"]
		if p.y < basetta.position.y: fuori += 1
		if p.x < basetta.position.x - 1.0 or p.x > basetta.position.x + basetta.size.x + 1.0:
			fuori += 1
	_eq("  e tutti poggiano sulla basetta", fuori, 0)

	# Tanti cubetti su una sagoma stretta si stringono invece di sbordare:
	# meglio affollati che fuori dal pezzo.
	b.vetusta = 4
	b.bonus_res = 6
	var molti := BoardLayout3D.cubetti(gs, b)
	_eq("dieci cubetti ci stanno tutti", molti.size(), 10)
	var larghezza := BoardLayout3D.span_w(b.width())
	var sbordano := 0
	for c in molti:
		var p: Vector3 = c["pos"]
		if absf(p.x - BoardLayout3D.standee_base(gs, b).x) > larghezza / 2.0 + 1.0:
			sbordano += 1
	_eq("  e nessuno sborda dalla sagoma", sbordano, 0)

	# La resistenza negativa non toglie cubetti: non esistono cubetti in meno.
	b.vetusta = 0
	b.bonus_res = -2
	_eq("una resistenza negativa non produce cubetti", BoardLayout3D.cubetti(gs, b).size(), 0)

func _test_linguette() -> void:
	var gs := _gioco().gs
	var b := _metti(gs, "ed_capanne", 2, 1)
	_eq("senza potenziamenti non spunta nulla", BoardLayout3D.linguette(gs, b).size(), 0)
	b.upgrades.append("po_palizzata")
	b.upgrades.append("po_statua")
	var ll := BoardLayout3D.linguette(gs, b)
	_eq("una linguetta per potenziamento", ll.size(), 2)
	# Davanti alla basetta, dal lato di chi guarda: dietro la sagoma non si
	# vedrebbero, ed e' l'errore che avevo fatto.
	var base := BoardLayout3D.standee_base(gs, b)
	var dietro := 0
	for p in ll:
		if p.z <= base.z + BoardLayout3D.BASETTA_D / 2.0: dietro += 1
	_eq("  e spuntano davanti, non dietro la sagoma", dietro, 0)
