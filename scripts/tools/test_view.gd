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
	_run("3D: chi crolla perde la sagoma e resta la basetta", _test_rovine)
	_run("3D: la telecamera gira attorno al tavolo", _test_orbita)
	_run("  e cliccare funziona da ogni angolo", _test_orbita_e_clic)
	_run("  e finisce davvero dove dice, nella scena", _test_telecamera_nel_mondo)
	_run("3D: la tessera si disegna intera", _test_tessera_intera)
	_run("la scena giocabile si compila e si avvia", _test_scena_giocabile)
	_run("le azioni offerte, col preventivo", _test_azioni_offerte)
	_run("  e la promessa che mantengono", _test_azioni_mantengono_la_promessa)
	_run("i bersagli: dove si puo' mettere una carta", _test_bersagli)
	_run("  e il riquadro acceso e' quello che si clicca", _test_riquadri)
	_run("  e la barra dice che mossa sarebbe, e quanto costa", _test_descrizione)
	_run("chi sta sopra poggia su chi sta sotto", _test_pila)
	_run("  e una volta costruita non si muove piu'", _test_sagome_ferme)
	_run("le carte del giocatore non si coprono", _test_carte_giocatore)
	_run("chi siede al tavolo lo si sceglie", _test_scelte_inizio)
	_run("  e a che velocita' si muovono i bot", _test_velocita_bot)
	_run("il conto finale, diviso per fonte", _test_riepilogo)
	_run("il valore di Scavo sulla basetta", _test_banner_scavo)
	_run("i pupazzetti dei lavoratori", _test_pupazzetti)
	_run("la Dinastia resta fuori dalle file", _test_dinastia)
	_run("il personaggio sepolto sta sotto la carta del suo edificio", _test_sepolto)
	_run("il terrapieno si paga e si vede", _test_terrapieni)
	_run("sotto un edificio a scalino non resta un buco", _test_scalino)
	_run("le carte stanno in piedi alla stessa altezza", _test_misure_carte)
	_run("la sagoma e' un pezzo solo, spesso", _test_sagoma_estrusa)
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
	# I binari riempiono la FASCIA DEL DISEGNO, non tutta la tessera: sotto
	# ci sono icone, regola e "Prosperita' Urbana", che devono restare
	# leggibili per tutta la partita.
	_approx("i cinque binari riempiono la fascia del disegno",
		BoardLayout3D.RAILS * BoardLayout3D.SLOT_D,
		BoardLayout3D.BANDA_GIU - BoardLayout3D.BANDA_SU)
	_ok("la fascia sta dentro la tessera e lascia scoperto il testo",
		BoardLayout3D.BANDA_SU > 0.0
		and BoardLayout3D.BANDA_GIU < BoardLayout3D.TESSERA_D - 50.0,
		"fascia %.0f-%.0f su %.0f mm" % [BoardLayout3D.BANDA_SU,
			BoardLayout3D.BANDA_GIU, BoardLayout3D.TESSERA_D])
	_ok("nessuna sagoma finisce sul testo della tessera",
		BoardLayout3D.rail_z(1) + BoardLayout3D.SLOT_D <= BoardLayout3D.BANDA_GIU + 0.001)
	_ok("la basetta sta dentro il suo binario",
		BoardLayout3D.BASETTA_D < BoardLayout3D.SLOT_D,
		"basetta %.0f su un binario di %.0f mm" % [BoardLayout3D.BASETTA_D,
			BoardLayout3D.SLOT_D])
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

	# Il passo fra le quote e' lo spessore di cio' che sta sotto, e sotto c'e'
	# solo la BASETTA: chi crolla in rovina perde la sagoma. Un edificio non
	# si trova mai sopra una sagoma in piedi, perche' le basi diventano tutte
	# rovina nel momento in cui ci si costruisce sopra - quindi non c'e'
	# niente da scavalcare, e il passo non deve piu' coprire una sagoma.
	_approx("il passo fra le quote e' la basetta, non una sagoma",
		BoardLayout3D.LEVEL_H, BoardLayout3D.BASETTA_Y)
	_ok("  e le sagome sono tutte piu' alte del passo (mediana %.0f, max %.0f)"
		% [mediana, piu_alta], mediana > BoardLayout3D.LEVEL_H)
	_eq("  la piu' alta e' il Grattacielo", nome, "Grattacielo")

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
	_ok("  cioe' meno di un binario, che ne e' profondo %.0f"
		% BoardLayout3D.SLOT_D, basetta.size.z < BoardLayout3D.SLOT_D)
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
	# Il cielo e' il fondale della strada: attaccato al bordo alto delle
	# tessere e largo quanto loro, non una parete della stanza piu' larga e
	# staccata indietro - cosi' si vedeva che era un'altra cosa.
	_approx("il cielo e' attaccato al bordo alto delle tessere", cielo.position.z, 0.0)
	_approx("  ed e' largo quanto le tessere", cielo.size.x, BoardLayout3D.board_w(gs))
	_approx("  e parte dal piano del tavolo", cielo.position.x, 0.0)
	_ok("  e sta dietro l'ultimo binario",
		cielo.position.z <= BoardLayout3D.rail_z(BoardLayout3D.RAILS))
	_ok("  e in piedi, non steso", cielo.size.y > 0.0 and cielo.size.z == 0.0)

	# E NON E' PIU' UN MURO. A pannello intero saliva quasi quanto e'
	# profonda la strada, e la meta' alta era cielo vuoto: adesso si mostra
	# la striscia bassa, quella dell'orizzonte.
	var intero := BoardLayout3D.sky_rect(gs, BoardLayout3D.CIELO_RAPPORTO, 1.0)
	_approx("il fondale mostra la quota scelta dell'immagine",
		cielo.size.y, intero.size.y * BoardLayout3D.CIELO_QUOTA)
	_ok("  cioe' la meta' o meno", cielo.size.y <= intero.size.y / 2.0 + 0.001)
	_ok("  e resta piu' basso della strada e' profonda",
		cielo.size.y < BoardLayout3D.board_d())
	_approx("  restando largo quanto le tessere", cielo.size.x, intero.size.x)

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
	# Le due soglie di prima - 75% visibile e 65% di scorcio - non stanno piu'
	# insieme da quando i binari si sono stretti a 26 mm per entrare nella
	# fascia del disegno: la prima vorrebbe almeno 62 gradi, la seconda al
	# massimo 49. Vince la seconda, e non per gusto: a 62 gradi la TESSERA si
	# legge alta la meta' di quello che e', e una tessera distorta si vede
	# subito mentre una fila dietro un po' coperta no.
	# La soglia sulla visibilita' qui sotto e' quella vera, non la vecchia
	# allentata di nascosto: dice che dietro se ne vede circa un terzo, ed e'
	# il prezzo scritto in chiaro. La telecamera si muove, quindi chi vuole
	# guardare in fondo alza lo sguardo.
	_ok("dietro la fila davanti resta visibile almeno un terzo di sagoma (%.0f%%)"
		% (visibile * 100.0), visibile >= 0.33)
	_ok("  e ne' sagoma ne' tessera sono schiacciate sotto il 65%% (%.0f%%)"
		% (scorcio * 100.0), scorcio >= 0.65,
		"a 62 gradi la tessera si leggeva alta la meta' di quello che e'")
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
	var carte := BoardLayout3D.side_cards(gs, 0)
	var possedute := 0
	for i in gs.n_players: possedute += BoardLayout3D.carte_giocatore(gs, i, 0).size()
	# +1: la Dinastia, che sta "sempre disponibile fuori dalle file" e non e'
	# in nessun mazzetto.
	_eq("una carta per ogni carta sul tavolo", carte.size(),
		gs.market.size() + gs.char_row.size() + gs.upg_row.size()
		+ gs.monuments_open.size() + possedute + 1)
	_ok("e ogni giocatore ha davanti il suo obiettivo segreto", possedute >= gs.n_players)
	var tipi := {}
	for c in carte: tipi[str(c["kind"])] = true
	_ok("ci sono mercato, personaggi e potenziamenti",
		tipi.has("mercato") and tipi.has("personaggio") and tipi.has("potenziamento"))

	# Nessuna carta sta SOPRA la strada: le file ai lati, le carte possedute
	# davanti. Se una ci finisse sopra coprirebbe le sagome.
	var sopra_la_strada := 0
	for c in carte:
		var r: AABB = c["aabb"]
		if _si_accavallano(r.position.x, r.size.x, 0.0, BoardLayout3D.board_w(gs)) \
				and _si_accavallano(r.position.z, r.size.z, 0.0, BoardLayout3D.board_d()):
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

# ---- la telecamera che il giocatore muove ----------------------------
func _test_orbita() -> void:
	var gs := _gioco().gs
	var o := CameraOrbita.da_stato(gs)

	# Parte esattamente dall'inquadratura calcolata: girare il tabellone e' in
	# piu', non al posto di quella. Se questa cade, la prima schermata della
	# partita non e' piu' quella scelta coi numeri.
	_ok("parte dall'inquadratura calcolata",
		o.posizione().is_equal_approx(BoardLayout3D.camera_position(gs)),
		"attesa %s, ottenuta %s" % [BoardLayout3D.camera_position(gs), o.posizione()])
	_ok("  e guarda lo stesso punto", o.mira.is_equal_approx(BoardLayout3D.camera_target(gs)))
	_ok("  e si dichiara iniziale", o.e_iniziale())

	# Girare cambia il punto di vista ma non la distanza: e' un'orbita, non
	# una passeggiata. Provata a giri interi, non a un angolo solo.
	var d0 := o.distanza
	var lontano := 0.0
	# I pixel si ricavano dalla sensibilita', non scritti a mano: cosi' il
	# giro resta un giro anche il giorno che la sensibilita' cambia - e quel
	# giorno e' arrivato subito, perche' 0,5 gradi per pixel era troppo.
	var pixel_per_scatto := 360.0 / 36.0 / CameraOrbita.GRADI_PER_PIXEL
	for i in 36:
		o.ruota(Vector2(pixel_per_scatto, 0.0))
		lontano = maxf(lontano, absf((o.posizione() - o.mira).length() - d0))
	_ok("girare non cambia la distanza dalla mira", lontano < 0.001,
		"scarto massimo %f mm" % lontano)
	_ok("dopo un giro intero si torna al punto di partenza",
		o.posizione().is_equal_approx(BoardLayout3D.camera_position(gs)),
		"ottenuta %s" % o.posizione())

	# L'inclinazione non passa i due limiti: sotto si guarderebbe il tavolo di
	# taglio, sopra si perderebbe il senso dell'altezza.
	for i in 200: o.ruota(Vector2(0.0, 60.0))
	_approx("l'inclinazione si ferma in basso", o.inclinazione, CameraOrbita.INCLINAZIONE_MIN)
	_ok("  e la telecamera resta sopra la mira", o.posizione().y > o.mira.y)
	for i in 400: o.ruota(Vector2(0.0, -60.0))
	_approx("l'inclinazione si ferma in alto", o.inclinazione, CameraOrbita.INCLINAZIONE_MAX)

	# Lo zoom: moltiplicativo, quindi avanti e indietro tornano al punto esatto.
	o.reimposta()
	_ok("il ripristino riporta all'inquadratura calcolata",
		o.posizione().is_equal_approx(BoardLayout3D.camera_position(gs)) and o.e_iniziale())
	o.zoom(3.0)
	_ok("avvicinare riduce la distanza", o.distanza < d0)
	_ok("  e non e' piu' l'inquadratura iniziale", not o.e_iniziale())
	o.zoom(-3.0)
	_approx("avanti e indietro tornano alla distanza di prima", o.distanza, d0)
	for i in 100: o.zoom(1.0)
	_approx("lo zoom si ferma da vicino", o.distanza, d0 * CameraOrbita.ZOOM_MIN)
	for i in 200: o.zoom(-1.0)
	_approx("lo zoom si ferma da lontano", o.distanza, d0 * CameraOrbita.ZOOM_MAX)

	# Lo spostamento: la mira si muove nel piano del tavolo e non se ne va.
	o.reimposta()
	var y0 := o.mira.y
	o.trasla(Vector2(60.0, 0.0), 900.0)
	_approx("spostare non cambia la quota della mira", o.mira.y, y0)
	_ok("  e la mira si e' mossa", not o.mira.is_equal_approx(BoardLayout3D.camera_target(gs)))
	var tavolo := BoardLayout3D.table_aabb_piatto(gs)
	var largo: float = maxf(tavolo.size.x, tavolo.size.z)
	for i in 400: o.trasla(Vector2(80.0, 80.0), 900.0)
	_ok("la mira non scappa dal tavolo",
		o.mira.x <= tavolo.end.x + largo * 0.5 + 0.001 \
		and o.mira.z <= tavolo.end.z + largo * 0.5 + 0.001,
		"finita in %s" % o.mira)

# Girare il tabellone non deve rompere il clic. E' il rischio vero di questa
# modifica: la mira si costruisce dal raggio della telecamera, quindi se la
# telecamera si muove e il conto non la segue, si clicca una colonna e se ne
# seleziona un'altra - in silenzio.
func _test_orbita_e_clic() -> void:
	var gs := _gioco().gs
	var sbagliati := 0
	var provati := 0
	for giro in [0.0, 37.0, 90.0, 143.0, 180.0, 251.0, 300.0]:
		for alzo in [15.0, 45.0, 75.0]:
			var o := CameraOrbita.da_stato(gs)
			o.imbardata = giro
			o.inclinazione = alzo
			var cam := o.posizione()
			for c in gs.grid.n_cols:
				for era in range(1, BoardLayout3D.RAILS + 1):
					var centro := BoardLayout3D.slot_center(c, era)
					var s := BoardLayout3D.slot_at_ray(gs, cam, (centro - cam).normalized())
					provati += 1
					if s.is_empty() or int(s["col"]) != c or int(s["era"]) != era:
						sbagliati += 1
	_eq("da ogni angolo, il raggio verso uno slot trova quello slot", sbagliati, 0)
	_ok("  e li ha provati tutti", provati == 7 * 3 * gs.grid.n_cols * BoardLayout3D.RAILS,
		"provati %d" % provati)

# I test di geometria guardano i numeri che BoardLayout3D calcola, e quelli
# possono essere giusti mentre la telecamera finisce da un'altra parte: basta
# posarla nello spazio sbagliato. E' successo - la plancia era un francobollo
# e nessuno dei test lo vedeva - quindi qui si costruisce la vista vera e si
# misura dove la telecamera e' andata a finire NEL MONDO.
func _test_telecamera_nel_mondo() -> void:
	var gs := _gioco().gs
	var vista: Node3D = preload("res://scripts/view/board_view_3d.gd").new()
	add_child(vista)
	vista.scale = Vector3.ONE * BoardLayout3D.U
	vista.mostra(gs)
	var cam: Camera3D = null
	for f in vista.get_children():
		if f is Camera3D: cam = f
	_ok("la vista crea una telecamera", cam != null)
	if cam == null:
		vista.queue_free()
		return

	# Le misure sono in millimetri e la vista e' rimpicciolita di U: nel mondo
	# la telecamera deve stare a U volte la posizione calcolata.
	var atteso := BoardLayout3D.camera_position(gs) * BoardLayout3D.U
	var scarto := cam.global_position.distance_to(atteso)
	_ok("sta dove la geometria dice, in coordinate del mondo", scarto < 0.001,
		"attesa %s, trovata %s" % [atteso, cam.global_position])

	# E guarda il tavolo: il centro della strada deve cadere dentro al
	# fotogramma, non dietro le spalle.
	var mira := BoardLayout3D.camera_target(gs) * BoardLayout3D.U
	_ok("e guarda il centro del tavolo", not cam.is_position_behind(mira))
	var sullo_schermo := cam.unproject_position(mira)
	var finestra := Vector2(cam.get_viewport().get_visible_rect().size)
	_ok("  che cade dentro al fotogramma",
		Rect2(Vector2.ZERO, finestra).has_point(sullo_schermo),
		"finito a %s su una finestra %s" % [sullo_schermo, finestra])

	# Girata di tre quarti: deve restare alla stessa distanza dalla mira.
	var orb := CameraOrbita.da_stato(gs)
	orb.ruota(Vector2(270.0 / CameraOrbita.GRADI_PER_PIXEL, 0.0))
	vista.orbita = orb
	vista.muovi_telecamera()
	_approx("girata di tre quarti, resta alla stessa distanza dalla mira",
		cam.global_position.distance_to(orb.mira * BoardLayout3D.U),
		BoardLayout3D.camera_position(gs).distance_to(BoardLayout3D.camera_target(gs))
			* BoardLayout3D.U)
	_ok("  e continua a guardarla", not cam.is_position_behind(orb.mira * BoardLayout3D.U))
	vista.queue_free()

# ---- le rovine ------------------------------------------------------
# Un edificio crollato non e' piu' in piedi: resta il piede, che fa da
# fondamenta a chi ci costruisce sopra. Disegnarlo come un rudere era il
# motivo per cui in partita sembrava che nessun edificio crollasse mai.
func _test_rovine() -> void:
	var gs := _gioco().gs
	var b := _metti(gs, "ed_capanne", 1, 2)
	_ok("un edificio intatto ha la sua sagoma", BoardLayout3D.ha_sagoma(b))
	b.state = Enums.BuildingState.RUDERE
	_ok("  il rudere ce l'ha ancora: e' in piedi, solo spento",
		BoardLayout3D.ha_sagoma(b))
	_ok("  e la mostra in grigio", BoardLayout3D.sagoma_path(b).contains("grigio"))
	b.state = Enums.BuildingState.ROVINA
	_ok("  chi e' crollato no", not BoardLayout3D.ha_sagoma(b))
	var piede := BoardLayout3D.basetta_box(gs, b)
	_ok("  ma la basetta resta, e regge la quota sopra",
		piede.size.y > 0.0 and piede.size.z > 0.0)
	_approx("  che e' esattamente il passo fra le quote",
		piede.size.y, BoardLayout3D.LEVEL_H)

	# E non e' un caso di laboratorio: in partita le rovine sono la meta'
	# degli edifici. Se questo conto va a zero, la regola sopra non serve piu'
	# a niente e qualcosa si e' rotto negli eventi.
	var rovine := 0
	var totali := 0
	for s in 5:
		var ctl := GameController.new()
		ctl.new_game(3, 100 + s)
		var giri := 0
		while ctl.gs.phase != Enums.Phase.FINE_PARTITA and giri < 4000:
			RandomBot.play_turn(ctl)
			giri += 1
		for e in ctl.gs.grid.buildings:
			totali += 1
			if e.state == Enums.BuildingState.ROVINA: rovine += 1
	_ok("in partita gli edifici crollano davvero (%d su %d in 5 partite)"
		% [rovine, totali], rovine > totali / 5)

# La tessera e' 63 x 271 mm, e il test che serviva non e' "la funzione che la
# misura restituisce 271" - quella era giusta e non la chiamava nessuno - ma
# "il rettangolo che finisce sul tavolo e' profondo 271". Qui si costruisce la
# vista vera e si misurano i piani disegnati.
# Il difetto che questo test prende: il disegno della tessera veniva steso su
# un riquadro alto 130 mm, cioe' la fascia dei binari, e la carta ci entrava
# schiacciata a meta'. A occhio si vede, ma solo se si sa cosa cercare.
func _test_tessera_intera() -> void:
	var gs := _gioco().gs
	var vista: Node3D = preload("res://scripts/view/board_view_3d.gd").new()
	add_child(vista)
	vista.mostra(gs)
	var piu_profondo := 0.0
	var quanti := 0
	for f in vista.get_children():
		if not (f is MeshInstance3D): continue
		var q := (f as MeshInstance3D).mesh as QuadMesh
		if q == null: continue
		if not is_equal_approx(q.size.x, BoardLayout3D.TESSERA_W): continue
		piu_profondo = maxf(piu_profondo, q.size.y)
		if is_equal_approx(q.size.y, BoardLayout3D.TESSERA_D): quanti += 1
	_approx("il piano della tessera e' profondo quanto la tessera",
		piu_profondo, BoardLayout3D.TESSERA_D)
	_eq("  e ce n'e' uno per colonna", quanti, gs.grid.n_cols)
	vista.queue_free()

# L'interfaccia nuova non offre piu' una lista: accende sul tabellone i posti
# dove la carta puo' andare. Quei posti li calcolano queste funzioni, e se
# sbagliano il giocatore clicca un riquadro acceso e si sente dire di no.
func _test_bersagli() -> void:
	var ctl := _gioco()
	var gs := ctl.gs
	ctl.place_worker(2)
	var col := ctl.colonna_attivata()

	# Ogni piazzamento offerto deve essere legale e pagabile: e' la promessa
	# che l'accensione fa al giocatore.
	var offerti := 0
	var bugie := 0
	for card_id in gs.market:
		for v in AvailableActions.piazzamenti(gs, 0, col, card_id):
			offerti += 1
			if not v.legale: bugie += 1
			var c0 := int(v.parametri["col_from"])
			var w := int(CardDB.buildings[card_id]["width"])
			# il piazzamento deve coprire la colonna attivata o una adiacente
			if c0 > col or c0 + w <= col: bugie += 1
	_ok("i piazzamenti offerti sono parecchi (%d)" % offerti, offerti > 0)
	_eq("  e sono tutti legali e coprono la colonna attivata", bugie, 0)

	# Il piu' economico fra i piazzamenti deve coincidere con quello che la
	# vecchia lista compatta sceglieva: le due strade portano allo stesso
	# posto, altrimenti una delle due mente.
	for v in AvailableActions.costruzioni(gs, 0, col):
		if not v.legale: continue
		var id := str(v.parametri["card_id"])
		var minimo := 999
		for p2 in AvailableActions.piazzamenti(gs, 0, col, id):
			minimo = mini(minimo, p2.pietra + p2.oro)
		_eq("  %s: il piu' economico e' lo stesso della lista" % id,
			minimo, v.pietra + v.oro)

	# I bersagli dei potenziamenti e dei personaggi sono edifici veri.
	var uid_validi := {}
	for b in gs.grid.buildings: uid_validi[b.uid] = true
	var fuori := 0
	for u in gs.upg_row:
		for v in AvailableActions.bersagli_potenziamento(gs, 0, col, u):
			if not uid_validi.has(int(v.parametri["uid"])): fuori += 1
	for c in gs.char_row:
		for v in AvailableActions.bersagli_reclutamento(gs, 0, col, c):
			if v.parametri.has("uid") and not uid_validi.has(int(v.parametri["uid"])): fuori += 1
	_eq("i bersagli indicati sono edifici che esistono", fuori, 0)

	# Una carta che non c'e' non accende nulla, invece di far saltare tutto.
	_eq("una carta sconosciuta non offre posti",
		AvailableActions.piazzamenti(gs, 0, col, "ed_inventato").size(), 0)

# La promessa dell'interfaccia nuova: quello che si accende e' quello che si
# clicca. Il riquadro lo calcola una funzione sola - box_piazzamento - e la
# usano sia il disegno sia il raggio del clic, quindi non possono divergere.
# Qui si verifica che ogni riquadro sia davvero raggiungibile, e che
# "costruire sopra" stia PIU' IN ALTO di "costruire a terra": e' quello che
# rende cliccabile un'opzione che prima si poteva chiedere solo tenendo
# premuto un tasto, e che quindi non chiedeva nessuno.
func _test_riquadri() -> void:
	var ctl := _gioco()
	var gs := ctl.gs
	# una torre: un edificio a terra su cui si possa costruire sopra
	_metti(gs, "ed_capanne", 2, 1, 0, 0)
	_metti(gs, "ed_capanne", 3, 1, 0, 0)
	ctl.place_worker(2)
	var col := ctl.colonna_attivata()

	var trovati := 0
	var sopra_piu_in_alto := 0
	var sopra_totali := 0
	for card_id in gs.market:
		var voci := AvailableActions.piazzamenti(gs, 0, col, card_id)
		var riquadri: Array = []
		for v in voci:
			var w := int(CardDB.buildings[card_id]["width"])
			riquadri.append(BoardLayout3D.box_piazzamento(gs,
				int(v.parametri["col_from"]), w, int(v.parametri["level"]), gs.era))
		for i in voci.size():
			var b: AABB = riquadri[i]
			var centro := b.position + Vector3(b.size.x / 2.0, 0.0, b.size.z / 2.0)
			# un raggio verticale dall'alto sul centro del riquadro
			var k := BoardLayout3D.riquadro_al_raggio(riquadri,
				centro + Vector3(0, 400, 0), Vector3(0, -1, 0))
			if k >= 0: trovati += 1
			if int(voci[i].parametri["level"]) > 0:
				sopra_totali += 1
				if b.position.y > BoardLayout3D.level_y(0) + 0.001: sopra_piu_in_alto += 1

	_ok("ogni riquadro acceso e' raggiungibile dal raggio (%d)" % trovati, trovati > 0)
	_ok("  e la partita ne offre di quelli sopra (%d)" % sopra_totali, sopra_totali > 0)
	_eq("  che stanno tutti piu' in alto di quelli a terra",
		sopra_piu_in_alto, sopra_totali)

	# E il piu' importante: fra i piazzamenti offerti ci sono sia quelli che
	# poggiano su una rovina sia quelli che SPIANANO un proprio edificio
	# intatto - la mossa che l'interfaccia vecchia non sapeva chiedere.
	var spianamenti := 0
	for card_id in gs.market:
		for v in AvailableActions.piazzamenti(gs, 0, col, card_id):
			if v.etichetta.contains("spianando"): spianamenti += 1
	_ok("si puo' chiedere di spianare un proprio edificio (%d modi)" % spianamenti,
		spianamenti > 0)

# La barra di stato: passando sopra un riquadro acceso deve dire CHE MOSSA
# sarebbe e quanto costa. Serviva perche' i riquadri accesi si somigliano
# tutti: la stessa carta, due caselle piu' in la', e' una costruzione a
# terra oppure lo spianamento di una propria bottega ancora intatta. Prima la
# differenza si scopriva cliccando, cioe' dopo.
# DescrizioneAzione e' pura, quindi le frasi si provano qui senza schermo.
func _test_descrizione() -> void:
	var ctl := _gioco()
	var gs := ctl.gs
	# Tre situazioni nello stesso tabellone, perche' sono le tre mosse che il
	# riquadro acceso non sa distinguere da solo: terra libera, una rovina su
	# cui salire, un proprio edificio intatto da spianare.
	_metti(gs, "ed_capanne", 2, 1, 0, 0)
	var rovina := _metti(gs, "ed_capanne", 6, 1, 0, 0)
	rovina.state = Enums.BuildingState.ROVINA
	var p: PlayerState = gs.players[0]

	var righe := 0
	var senza_prezzo := 0
	var tipo_sbagliato := 0
	var spianate := 0
	var sopraelevazioni := 0
	var costruzioni := 0
	# Si interrogano tutte le colonne come fa la plancia quando il lavoratore
	# non e' ancora piazzato: AvailableActions e' pura e la colonna e' un suo
	# parametro, quindi la domanda si puo' fare per una colonna ipotetica.
	for col in gs.grid.n_cols:
		for card_id in gs.market:
			for v in AvailableActions.piazzamenti(gs, 0, col, card_id):
				var riga := DescrizioneAzione.riga(gs, v, 0)
				righe += 1
				# il nome dell'edificio e il conto ci sono sempre
				if not riga.contains(str(CardDB.buildings[card_id]["name"])) \
						or not riga.contains(DescrizioneAzione.prezzo(v)):
					senza_prezzo += 1
				var tipo := DescrizioneAzione.tipo(v)
				var spiana: PackedStringArray = v.parametri["spiana"]
				if not spiana.is_empty():
					spianate += 1
					# spianare e' la mossa che costa un proprio edificio: la
					# parola deve dirlo, e deve dire quale
					if tipo != "Spianata" or not riga.contains(spiana[0]):
						tipo_sbagliato += 1
				elif bool(v.parametri["above"]):
					sopraelevazioni += 1
					if tipo != "Sopraelevazione": tipo_sbagliato += 1
				else:
					costruzioni += 1
					if tipo != "Costruzione": tipo_sbagliato += 1

	_ok("ogni posto acceso ha la sua riga (%d)" % righe, righe > 0)
	_eq("  col nome dell'edificio e il prezzo", senza_prezzo, 0)
	_ok("  la partita offre le tre mosse: %d a terra, %d sopra, %d spianando"
		% [costruzioni, sopraelevazioni, spianate],
		costruzioni > 0 and sopraelevazioni > 0 and spianate > 0)
	_eq("  e ognuna si chiama col suo nome", tipo_sbagliato, 0)

	# Il prezzo si scrive in italiano, non "0 pietra 0 oro".
	var gratis := AvailableActions.Voce.new()
	_eq("quel che non costa si dice gratis", DescrizioneAzione.prezzo(gratis), "gratis")
	var caro := AvailableActions.Voce.new()
	caro.pietra = 3
	caro.oro = 1
	_eq("  e il resto col suo conto", DescrizioneAzione.prezzo(caro), "3 pietra 1 oro")

	# Legale e pagabile sono due cose diverse: il posto resta acceso, ma la
	# barra deve dire quanto manca invece di far scoprire il rifiuto al clic.
	var avanzo := Vector2i(p.pietra, p.oro)
	p.pietra = 1
	p.oro = 0
	_eq("col borsellino vuoto la barra dice quanto manca",
		DescrizioneAzione.ammanco(caro, p), "ti manca 2 pietra e 1 oro")
	p.pietra = avanzo.x
	p.oro = avanzo.y
	_eq("  e non dice niente quando il conto torna",
		DescrizioneAzione.ammanco(AvailableActions.Voce.new(), p), "")

	# Il lavoratore non ancora piazzato: cliccare il posto lo mette, ed e' una
	# conseguenza che nel riquadro acceso non si vede.
	var v2 := AvailableActions.Voce.new()
	v2.tipo = "costruisci"
	v2.parametri = {"card_id": gs.market[0], "col_from": 0, "above": false,
		"level": 0, "spiana": PackedStringArray(), "terrapieni": 0, "attiva": 4}
	_ok("e se il lavoratore non c'e' ancora, dice quale colonna attiva",
		DescrizioneAzione.riga(gs, v2, 0).contains("attiva la colonna 4"))

# UNA SAGOMA COSTRUITA NON SI MUOVE PIU'. Sembra ovvio e non lo era: la quota
# di chi sta sopra si ricavava dalle basi che si trovavano IN QUEL MOMENTO
# nelle sue colonne, e a quota zero una colonna porta fino a cinque edifici,
# uno per binario d'era. Bastava che qualcuno costruisse in un altro binario
# della stessa colonna perche' la media cambiasse e la sagoma sopra
# scivolasse verso il fondo. Adesso le basi sono quelle di quando la si e'
# costruita, segnate sull'edificio.
#
# Il test guarda una partita intera: dopo ogni turno confronta la posizione di
# ogni sagoma gia' in tavola con quella che aveva, e non ne perdona una.
func _test_sagome_ferme() -> void:
	var ctl := _gioco()
	var dove := {}          # uid -> posizione del piede
	var mosse := 0
	var esempio := ""
	var giri := 0
	while ctl.gs.phase != Enums.Phase.FINE_PARTITA and giri < 4000:
		RandomBot.play_turn(ctl)
		giri += 1
		for b in ctl.gs.grid.buildings:
			var p := BoardLayout3D.standee_base(ctl.gs, b)
			if dove.has(b.uid):
				var prima: Vector3 = dove[b.uid]
				if not p.is_equal_approx(prima):
					mosse += 1
					if esempio == "":
						esempio = "%s (liv %d) da %s a %s" % [b.data["name"], b.level,
							str(prima), str(p)]
			dove[b.uid] = p
	_ok("la partita ha messo in tavola parecchie sagome (%d)" % dove.size(),
		dove.size() > 10)
	_eq("e nessuna si e' mossa dopo essere stata costruita%s"
		% ("" if esempio == "" else ": " + esempio), mosse, 0)

	# La prova diretta del difetto: si costruisce sopra, si segna la quota, e
	# poi si aggiunge un edificio a quota zero in un ALTRO binario della
	# stessa colonna. Era quello a spostare la sagoma di sopra.
	var g := _gioco().gs
	var sotto := _metti(g, "ed_capanne", 2, 1, 0, 0)
	sotto.state = Enums.BuildingState.ROVINA
	var sopra := _metti(g, "ed_capanne", 2, 1, 1, 0)
	sopra.basi = [sotto.uid] as Array[int]
	var prima2 := BoardLayout3D.standee_base(g, sopra)
	_metti(g, "ed_capanne", 2, 4, 0, 1)      # un altro binario, stessa colonna
	_ok("un edificio nuovo in un altro binario non sposta chi sta sopra",
		BoardLayout3D.standee_base(g, sopra).is_equal_approx(prima2))
	_approx("  che resta appoggiato alla sua base",
		BoardLayout3D.standee_base(g, sopra).z,
		BoardLayout3D.standee_base(g, sotto).z)

# LE SAGOME SOPRAELEVATE GALLEGGIAVANO IN ARIA. Un edificio sopra finiva
# sempre in mezzo alla fascia del disegno, mentre le sue fondamenta restavano
# al binario della loro era - per l'era 1 sono 57 mm piu' avanti - e a
# schermo stava per conto suo, a fianco della pila che avrebbe dovuto
# reggerlo. Nessun test se ne accorgeva perche' nessuno confrontava la
# posizione di chi sta sopra con quella di chi sta sotto.
func _test_pila() -> void:
	var gs := _gioco().gs
	# la pila piu' semplice: una base dell'era 1, un edificio sopra
	var sotto := _metti(gs, "ed_capanne", 2, 1, 0, 0)
	sotto.state = Enums.BuildingState.ROVINA
	var sopra := _metti(gs, "ed_capanne", 2, 3, 1, 0)
	_approx("chi sta sopra prende la profondita' della sua base",
		BoardLayout3D.standee_base(gs, sopra).z,
		BoardLayout3D.standee_base(gs, sotto).z)
	var giu := BoardLayout3D.basetta_box(gs, sotto)
	var su := BoardLayout3D.basetta_box(gs, sopra)
	_approx("  e la sua basetta poggia sul tetto di quella sotto",
		su.position.y, giu.end.y)
	_ok("  con i due piedi uno sopra l'altro, non uno a fianco all'altro",
		su.position.z < giu.end.z and giu.position.z < su.end.z)

	# E il riquadro acceso deve stare dove finira' la sagoma: se i due conti
	# divergono, il giocatore accende un posto e l'edificio compare altrove.
	var riq := BoardLayout3D.box_piazzamento(gs, 2, 1, 1, gs.era)
	var centro := riq.position.z + riq.size.z / 2.0
	_approx("il riquadro acceso e' dove la sagoma andra' a finire",
		centro, BoardLayout3D.standee_base(gs, sopra).z)

	# In una partita vera nessun sopraelevato deve restare senza appoggio.
	var ctl := _gioco()
	var giri := 0
	while ctl.gs.phase != Enums.Phase.FINE_PARTITA and giri < 4000:
		RandomBot.play_turn(ctl)
		giri += 1
	var g2 := ctl.gs
	var quanti := 0
	var appesi := 0
	for b in g2.grid.buildings:
		if b.level == 0: continue
		quanti += 1
		var mio := BoardLayout3D.basetta_box(g2, b)
		var appoggiato := false
		for s2 in g2.grid.buildings:
			if s2.level != b.level - 1: continue
			if s2.col_to <= b.col_from or s2.col_from >= b.col_to: continue
			var suo := BoardLayout3D.basetta_box(g2, s2)
			# si tocca in profondita' e si tocca di lato: e' appoggiato
			if mio.position.z < suo.end.z and suo.position.z < mio.end.z \
				and mio.position.x < suo.end.x and suo.position.x < mio.end.x:
				appoggiato = true
				break
		if not appoggiato: appesi += 1
	_ok("la partita ha prodotto pile (%d sopraelevati)" % quanti, quanti > 0)
	_eq("  e nessuno di loro galleggia in aria", appesi, 0)

	# E NESSUNA SAGOMA RESTA INGLOBATA NELLA PILA. A quota zero una colonna
	# porta fino a cinque edifici, uno per binario d'era, e chi costruisce
	# sopra ne spiana uno solo: gli altri restano INTATTI e finiscono
	# sepolti. Le loro sagome attraversavano la pila da parte a parte,
	# perche' un livello sale di 10 mm e una sagoma ne e' alta 66.
	var sepolti := 0
	var sepolti_in_piedi := 0
	for b in g2.grid.buildings:
		if not b.is_buried: continue
		sepolti += 1
		if BoardLayout3D.ha_sagoma(b): sepolti_in_piedi += 1
	_ok("la partita ha prodotto sepolti (%d)" % sepolti, sepolti > 0)
	_eq("  e nessuno di loro ha ancora la sagoma in piedi", sepolti_in_piedi, 0)
	# E NESSUNO DI LORO E' INTATTO. Chi fa da base viene spianato o
	# schiacciato prima, quindi quando finisce sotto e' gia' rovina:
	# "intatto e sepolto" e' uno stato che al tavolo non si presenta, e che
	# qui usciva a decine perche' un solo strato sotterrava tutti e cinque
	# i binari della colonna.
	var intatti_sepolti := 0
	for b in g2.grid.buildings:
		if b.is_buried and b.state == Enums.BuildingState.INTATTO:
			intatti_sepolti += 1
	_eq("  e nessuno di loro e' intatto", intatti_sepolti, 0)
	_ok("  ma la basetta gli resta, che e' le fondamenta di chi sta sopra",
		BoardLayout3D.basetta_box(g2, g2.grid.buildings[0]).size.y > 0.0)

# LE CARTE COMPRATE SI COPRIVANO A VICENDA. Il passo si stringeva per tenerle
# tutte su una riga: con tre carte larghe 125 mm in una fetta da 147 scendeva
# a 12 mm, e di ogni carta si vedeva una striscia. Adesso si va a capo.
func _test_carte_giocatore() -> void:
	var gs := _gioco().gs
	# un giocatore carico: obiettivo, dinastia, monumenti e personaggi
	var p: PlayerState = gs.players[0]
	p.has_dynasty = true
	for id in CardDB.monuments:
		p.monuments_claimed.append(str(id))
		if p.monuments_claimed.size() >= 2: break
	for id in gs.char_row: p.specialized_characters.append(str(id))
	# E le carte degli edifici costruiti: "costruire significa pagare il
	# costo della carta e mettere la sagoma sul tabellone", quindi la carta
	# resta davanti a chi l'ha presa. Prima spariva nel nulla.
	for c in range(0, 5): _metti(gs, "ed_capanne", c, 1, 0, 0)
	var carte := BoardLayout3D.player_cards(gs, 0)
	_ok("il giocatore ha parecchie carte davanti (%d)" % carte.size(),
		carte.size() >= 5)
	var edifici := 0
	for c in carte:
		if int(c["player"]) == 0 and str(c["kind"]) == "mercato": edifici += 1
	_eq("  fra cui le carte degli edifici che ha costruito", edifici, 5)

	# Le carte diverse dagli edifici non si coprono: sono poche e si
	# leggono per intero.
	var stese: Array = []
	var mazzetto: Array = []
	for c in carte:
		if str(c["kind"]) == "mercato": mazzetto.append(c)
		else: stese.append(c)
	var coperte := 0
	for i in stese.size():
		for j in range(i + 1, stese.size()):
			var a: AABB = stese[i]["aabb"]
			var b: AABB = stese[j]["aabb"]
			if a.position.x < b.end.x - 0.001 and b.position.x < a.end.x - 0.001 \
				and a.position.z < b.end.z - 0.001 and b.position.z < a.end.z - 0.001:
				coperte += 1
	_eq("nessuna carta stesa ne copre un'altra", coperte, 0)

	# Le carte edificio invece si impilano a ventaglio, ma di ognuna resta
	# fuori la fascia del titolo: e' quello che le rende ancora leggibili.
	var nascoste := 0
	for i in mazzetto.size():
		var a: AABB = mazzetto[i]["aabb"]
		var scoperto := a.size.z
		for j in mazzetto.size():
			if j == i: continue
			var b: AABB = mazzetto[j]["aabb"]
			if b.position.y <= a.position.y: continue
			if b.position.x >= a.end.x - 0.001 or a.position.x >= b.end.x - 0.001:
				continue
			scoperto = minf(scoperto, b.position.z - a.position.z)
		# Il passo scende con la carta: nel mazzetto le carte si stringono
		# per stare in due colonne, e la fascia del titolo si stringe con
		# loro. Si ricava dalla carta disegnata invece di riscriverlo.
		var passo: float = BoardLayout3D.VENTAGLIO_Z \
			* (a.size.x / BoardLayout3D.misura_carta("mercato").x)
		if scoperto < passo - 0.001: nascoste += 1
	_eq("di ogni carta edificio resta fuori la fascia del titolo", nascoste, 0)

	# LE DUE COLONNE VOGLIONO DIRE QUALCOSA: a sinistra quello che sta
	# ancora sulla strada, a destra quello che e' finito sotto. Finche'
	# non si sotterra niente, il mazzetto sta tutto a sinistra.
	var colonne := {}
	for c in mazzetto: colonne[snappedf((c["aabb"] as AABB).position.x, 0.1)] = true
	_eq("senza sepolti il mazzetto sta tutto in una colonna", colonne.size(), 1)
	var largo_pieno := BoardLayout3D.misura_carta("mercato")
	var stretta: AABB = mazzetto[0]["aabb"]
	_ok("  con le carte strette quel poco che serve (%.2f)"
		% (stretta.size.x / largo_pieno.x),
		stretta.size.x <= largo_pieno.x + 0.001
		and stretta.size.x > largo_pieno.x * 0.7)
	_ok("  e senza deformarsi",
		is_equal_approx(stretta.size.x / stretta.size.z,
			largo_pieno.x / largo_pieno.y))


	# E nessuna finisce addosso al vicino: ognuno sta nella sua fetta.
	var fetta := BoardLayout3D.board_w(gs) / float(gs.n_players)
	var sconfinate := 0
	for c in carte:
		var b2: AABB = c["aabb"]
		var mio: int = int(c["player"])
		if b2.position.x < mio * fetta - 0.001: sconfinate += 1
		if b2.end.x > (mio + 1) * fetta + 0.001: sconfinate += 1
	_eq("  e nessuna sborda nel posto del vicino", sconfinate, 0)

	# Le carte restano cliccabili: ognuna deve rispondere al raggio, e deve
	# rispondere PROPRIO LEI. Era questo che il mucchio rendeva impossibile.
	var sbagliate := 0
	for c in stese:
		var b3: AABB = c["aabb"]
		var centro := b3.position + Vector3(b3.size.x / 2.0, 0.0, b3.size.z / 2.0)
		var colpita := BoardLayout3D.card_at_ray(gs,
			centro + Vector3(0, 500, 0), Vector3(0, -1, 0), 0)
		if colpita.is_empty() or str(colpita["id"]) != str(c["id"]): sbagliate += 1
	_eq("  e cliccandone una si prende proprio quella", sbagliate, 0)

	# E nel ventaglio vince quella SOPRA: puntando la fascia scoperta di una
	# carta deve rispondere lei, non quella nascosta sotto.
	var sotto := 0
	for i in mazzetto.size():
		var b4: AABB = mazzetto[i]["aabb"]
		# Il passo si stringe con la carta: la fascia scoperta si misura da
		# quella disegnata, se no si punta gia' dentro la carta sopra.
		var passo2: float = BoardLayout3D.VENTAGLIO_Z \
			* (b4.size.x / BoardLayout3D.misura_carta("mercato").x)
		var punto := b4.position + Vector3(b4.size.x / 2.0, 0.0, passo2 / 2.0)
		var presa := BoardLayout3D.card_at_ray(gs, punto + Vector3(0, 500, 0),
			Vector3(0, -1, 0), 0)
		if presa.is_empty() or int(presa.get("ordine", -1)) != int(mazzetto[i]["ordine"]):
			sotto += 1
	_eq("  e nel mazzetto risponde la carta sopra, non quella coperta", sotto, 0)

	# Adesso se ne sotterrano due e se ne spegne una: le sepolte passano
	# nella colonna di destra - che e' il mazzetto dello Scavo - le altre
	# restano dove stavano, e quella spenta si segna come tale.
	var sx := snappedf((mazzetto[0]["aabb"] as AABB).position.x, 0.1)
	var miei: Array = []
	for b in gs.grid.buildings:
		if b.owner == 0: miei.append(b)
	miei[0].state = Enums.BuildingState.ROVINA
	miei[0].is_buried = true
	miei[1].state = Enums.BuildingState.ROVINA
	miei[1].is_buried = true
	miei[2].state = Enums.BuildingState.RUDERE
	var dopo: Array = []
	for c in BoardLayout3D.player_cards(gs, 0):
		if int(c["player"]) == 0 and str(c["kind"]) == "mercato": dopo.append(c)
	var a_destra: Array = []
	var a_sinistra: Array = []
	for c in dopo:
		if bool(c["sepolta"]): a_destra.append(c)
		else: a_sinistra.append(c)
	_eq("le sepolte diventano due", a_destra.size(), 2)
	_eq("  e le altre restano tre", a_sinistra.size(), 3)
	var fuori := 0
	for c in a_sinistra:
		if not is_equal_approx(snappedf((c["aabb"] as AABB).position.x, 0.1), sx):
			fuori += 1
	_eq("chi resta sulla strada non si sposta di colonna", fuori, 0)
	var non_a_destra := 0
	for c in a_destra:
		if (c["aabb"] as AABB).position.x <= sx + 0.001: non_a_destra += 1
	_eq("  e le sepolte passano nella colonna a destra", non_a_destra, 0)
	var spente := 0
	for c in a_sinistra:
		if bool(c["spenta"]): spente += 1
	_eq("  e la rovina non sepolta si segna spenta", spente, 1)

# CHI SIEDE AL TAVOLO. Prima erano due numeri dentro gioca.gd - tre giocatori,
# seme 7 - e in due o in quattro non ci si giocava affatto. ScelteInizio e'
# pura, quindi si prova headless che nessuna combinazione impossibile passi.
func _test_scelte_inizio() -> void:
	var s := ScelteInizio.new()
	_eq("umani piu' bot fa i giocatori", s.umani() + s.bot, s.giocatori)

	# Il regolamento sta su 2, 3 e 4: fuori di li' i terreni non sono tabulati.
	s.con_giocatori(9)
	_eq("in nove non si gioca: si scende al massimo", s.giocatori, 4)
	s.con_giocatori(1)
	_eq("  e da soli nemmeno: si sale al minimo", s.giocatori, 2)

	s.con_giocatori(4)
	s.con_bot(4)
	_eq("tutti bot si puo': e' la partita che si guarda", s.umani(), 0)
	s.con_bot(99)
	_eq("  ma non piu' bot che giocatori", s.bot, 4)
	s.con_bot(0)
	_eq("  e nemmeno meno di zero: tutti umani", s.umani(), 4)

	# E stringendo il tavolo i bot devono stringersi con lui, altrimenti si
	# resterebbe con piu' bot che posti.
	s.con_giocatori(4)
	s.con_bot(3)
	s.con_giocatori(2)
	_ok("stringendo il tavolo i bot si stringono (%d su %d)" % [s.bot, s.giocatori],
		s.bot <= s.giocatori)

	# I primi posti sono degli umani: chi gioca da solo e' il giocatore 0 e sa
	# dove guardare.
	s.con_giocatori(3)
	s.con_bot(2)
	_ok("l'umano e' il primo", s.e_umano(0))
	_ok("  e gli altri sono bot", not s.e_umano(1) and not s.e_umano(2))
	_eq("  e i posti umani sono quelli", s.posti_umani(), [0] as Array[int])
	_ok("  fuori dal tavolo non c'e' nessuno", not s.e_umano(-1) and not s.e_umano(3))

	# Il seme resta scelto e visibile: e' quello che rende una partita
	# ripetibile, e un difetto raccontabile.
	var semi := {}
	for i in 40:
		s.rimescola()
		semi[s.seme] = true
		if s.seme < 1: _ok("seme fuori scala", false)
	_ok("il seme cambia rimescolando (%d valori su 40)" % semi.size(), semi.size() > 1)
	_ok("  e la descrizione dice chi gioca: \"%s\"" % s.descrizione(),
		s.descrizione().contains("bot") and s.descrizione().contains(str(s.seme)))

# LA VELOCITA' DEI BOT. Prima giocavano tutti i loro turni fra un clic e
# l'altro: sul tabellone comparivano tre edifici insieme e non si capiva chi
# avesse fatto cosa. Adesso si sceglie il passo, e i due casi che non sono
# un'attesa - "subito" e "passo" - si chiedono per nome invece di confrontare
# numeri, perche' e' li' che si sbaglia.
func _test_velocita_bot() -> void:
	var s := ScelteInizio.new()
	_ok("di suo i bot si muovono a vista (%s)" % s.nome_velocita(),
		not s.bot_subito() and not s.bot_a_mano())

	# Le velocita' vanno dalla piu' lenta alla piu' svelta, senza buchi: e'
	# l'ordine in cui la schermata le mette in fila.
	var prima := 99.0
	var scale := 0
	for i in range(1, ScelteInizio.VELOCITA.size()):
		s.con_velocita(i)
		if s.pausa_bot() < prima: scale += 1
		prima = s.pausa_bot()
	_eq("ogni velocita' e' piu' svelta della prima",
		scale, ScelteInizio.VELOCITA.size() - 1)

	s.con_velocita(0)
	_ok("la prima e' a mano: non e' un'attesa", s.bot_a_mano() and not s.bot_subito())
	s.con_velocita(ScelteInizio.VELOCITA.size() - 1)
	_ok("l'ultima e' tutto in un colpo", s.bot_subito() and not s.bot_a_mano())

	# Fuori scala non si va, e il tasto in partita gira in tondo invece di
	# fermarsi sull'ultima.
	s.con_velocita(99)
	_eq("  e fuori scala non si va", s.velocita, ScelteInizio.VELOCITA.size() - 1)
	s.velocita_dopo()
	_eq("  e dall'ultima si torna alla prima", s.velocita, 0)
	var giro := 0
	for i in ScelteInizio.VELOCITA.size():
		s.velocita_dopo()
		giro += 1
	_eq("  e un giro intero riporta dov'era", s.velocita, 0)

	# La descrizione dice a che velocita' vanno, ma solo se un bot c'e'.
	s.con_giocatori(3)
	s.con_bot(2)
	s.con_velocita(ScelteInizio.VELOCITA_NORMALE)
	_ok("la descrizione dice il passo dei bot: \"%s\"" % s.descrizione(),
		s.descrizione().contains(s.nome_velocita()))
	s.con_bot(0)
	_ok("  e tace quando bot non ce ne sono: \"%s\"" % s.descrizione(),
		not s.descrizione().contains("bot %s" % s.nome_velocita()))

# IL CONTO FINALE. Alla fine restava un numero solo - "vincitore: giocatore
# 3" - e non si capiva dove fossero andati i punti. Il nucleo li divide gia'
# per canale mentre la partita va avanti: qui si controlla che la tabella non
# ne perda per strada, perche' un riepilogo che non torna col totale e'
# peggio di nessun riepilogo.
func _test_riepilogo() -> void:
	var ctl := _gioco()
	var giri := 0
	while ctl.gs.phase != Enums.Phase.FINE_PARTITA and giri < 4000:
		RandomBot.play_turn(ctl)
		giri += 1
	var gs := ctl.gs
	_eq("la partita e' arrivata in fondo", gs.phase, Enums.Phase.FINE_PARTITA)

	var righe := Riepilogo.righe(gs)
	_eq("c'e' una riga per giocatore", righe.size(), gs.players.size())
	var visti := {}
	for r in righe: visti[int(r["player"])] = true
	_eq("  e ogni giocatore compare una volta sola", visti.size(), gs.players.size())

	# La tabella e' in ordine di arrivo, e il primo e' quello che il gioco
	# chiama vincitore: due modi di ordinare avrebbero finito per litigare.
	_eq("il primo della tabella e' il vincitore",
		int(righe[0]["player"]), Scoring.winner(gs))
	var scesa := true
	for i in range(1, righe.size()):
		if int(righe[i]["vp"]) > int(righe[i - 1]["vp"]): scesa = false
	_ok("  e i punti scendono riga dopo riga", scesa)

	# NESSUN PUNTO SI PERDE PER STRADA: la somma delle colonne mostrate piu'
	# l'eventuale "altro" deve fare il totale segnato.
	var cols := Riepilogo.colonne(gs)
	var storte := 0
	for r in righe:
		var somma := 0
		for c in cols: somma += Riepilogo.punti(r, str(c["id"]))
		if somma + Riepilogo.altro(gs, r) != int(r["vp"]): storte += 1
	_eq("le colonne sommate fanno il totale", storte, 0)

	# E i canali che il nucleo usa davvero devono essere TUTTI fra le
	# colonne: se un giorno ne aggiunge uno, deve finire in tabella invece
	# che in "altro".
	var noti := {}
	for c in cols: noti[str(c["id"])] = true
	var fuori := PackedStringArray()
	for pl in gs.players:
		for canale in pl.vp_breakdown:
			if int(pl.vp_breakdown[canale]) != 0 and not noti.has(str(canale)):
				fuori.append(str(canale))
	_eq("nessun canale resta fuori dalla tabella (%s)" % ", ".join(fuori),
		fuori.size(), 0)

	# Le colonne mostrate hanno dato punti a qualcuno: una colonna di zeri
	# ruba spazio a quelle che contano.
	var vuote := 0
	for c in cols:
		var qualcuno := false
		for r in righe:
			if Riepilogo.punti(r, str(c["id"])) != 0: qualcuno = true
		if not qualcuno: vuote += 1
	_eq("nessuna colonna e' tutta vuota (%d colonne)" % cols.size(), vuote, 0)

	# L'eredita' segreta: a fine partita e' scoperta sul tavolo, e il
	# riepilogo dice quale era e quanto ha fruttato.
	var senza_nome := 0
	for r in righe:
		if str(r["eredita"]) != "" and str(r["eredita_nome"]) == "": senza_nome += 1
	_eq("ogni eredita' ha il suo nome", senza_nome, 0)
	var coperte := 0
	for c in BoardLayout3D.player_cards(gs):
		if str(c["kind"]) == "eredita_coperta": coperte += 1
	_eq("a partita finita nessun obiettivo resta coperto", coperte, 0)
	# E prima della fine restano coperti, che e' il punto di averli segreti.
	var gs2 := _gioco().gs
	var coperte2 := 0
	for c in BoardLayout3D.player_cards(gs2, 0):
		if str(c["kind"]) == "eredita_coperta": coperte2 += 1
	_eq("  ma in partita si vede solo il proprio", coperte2, gs2.players.size() - 1)

# IL TERRAPIENO. Le regole lo facevano pagare da sempre - 1 pietra per ogni
# colonna senza base - ma sul tavolo non si vedeva, e l'edificio restava
# sospeso sopra il vuoto proprio nella colonna che aveva pagato per
# riempirla. Il preventivo sapeva quante erano; adesso sa anche QUALI, e
# l'edificio se le porta dietro.
# Il banner dello Scavo: la riga giusta dell'immagine, e il taglio da sinistra
# per gli edifici corti - a destra c'e' il numero, e quello non si taglia mai.
func _test_banner_scavo() -> void:
	var ctl := _gioco()
	var gs := ctl.gs
	# Un edificio da tre slot mostra la striscia intera.
	var largo := _metti(gs, _largo(3), 1, 1, 0, 0)
	var u3: Dictionary = BoardLayout3D.scavo_uv(largo)
	_approx("l'edificio da tre slot prende la striscia intera",
		(u3["scala"] as Vector2).x, 1.0)
	_approx("  senza tagliare niente a sinistra", (u3["offset"] as Vector2).x, 0.0)

	# Uno da una casella ne prende un terzo, TAGLIATO A SINISTRA.
	var stretto := _metti(gs, "ed_capanne", 4, 1, 0, 0)
	var u1: Dictionary = BoardLayout3D.scavo_uv(stretto)
	_approx("quello da una casella ne prende un terzo",
		(u1["scala"] as Vector2).x, 1.0 / 3.0)
	_approx("  e il taglio e' a sinistra", (u1["offset"] as Vector2).x, 2.0 / 3.0)
	_ok("  cosi' il bordo destro - dove c'e' il numero - resta dentro",
		is_equal_approx((u1["offset"] as Vector2).x + (u1["scala"] as Vector2).x, 1.0))

	# La riga dipende dal valore di Scavo, e sono righe di uguale altezza.
	var passo := 1.0 / float(BoardLayout3D.SCAVO_RIGHE)
	_approx("ogni riga e' alta un decimo", (u1["scala"] as Vector2).y, passo)
	_approx("  e si sceglie col valore",
		(u1["offset"] as Vector2).y, passo * float(int(stretto.data["scavo"])))

	# Spianare porta lo Scavo a 0: il banner deve dirlo.
	stretto.was_razed = true
	var u0: Dictionary = BoardLayout3D.scavo_uv(stretto)
	_eq("uno spianato mostra lo zero", int(u0["valore"]), 0)
	_approx("  cioe' la prima riga", (u0["offset"] as Vector2).y, 0.0)

	# L'Impronta alza lo Scavo: anche quello si vede.
	stretto.was_razed = false
	stretto.bonus_scavo = 3        # l'Incisore: +3 permanenti
	_eq("un'Impronta sposta la riga", int(BoardLayout3D.scavo_uv(stretto)["valore"]),
		int(stretto.data["scavo"]) + 3)
	_ok("  e ci sono righe abbastanza per tutti i valori stampati",
		not bool(BoardLayout3D.scavo_uv(stretto)["fuori_scala"]))
	stretto.bonus_scavo = 0

	# Nessuna carta deve restare fuori scala: se il banner ha meno righe dei
	# valori in gioco, sul tavolo finisce un numero sbagliato.
	var fuori: Array[String] = []
	for id in CardDB.buildings:
		var b2 := _metti(gs, str(id), 0, 1, 0, 0)
		if bool(BoardLayout3D.scavo_uv(b2)["fuori_scala"]): fuori.append(str(id))
		gs.grid.buildings.erase(b2)
	_eq("nessuna carta ha uno Scavo oltre le righe del banner (%s)"
		% ", ".join(fuori), fuori.size(), 0)

	# Il terrapieno prende la stessa terra, ma senza il numero: li' non c'e'
	# niente da contare, e il numero di un altro edificio sarebbe una bugia.
	var t := BoardLayout3D.terra_uv(AABB(Vector3.ZERO,
		Vector3(BoardLayout3D.span_w(1), 10.0, BoardLayout3D.BASETTA_D)))
	var fine: float = (t["offset"] as Vector2).x + (t["scala"] as Vector2).x
	_ok("la terra del terrapieno si ferma prima del numero (%.2f)" % fine,
		fine <= BoardLayout3D.SCAVO_NUMERO_DA + 0.001)
	_approx("  e prende la riga dello zero", (t["offset"] as Vector2).y, 0.0)
	var t3 := BoardLayout3D.terra_uv(AABB(Vector3.ZERO,
		Vector3(BoardLayout3D.span_w(3), 10.0, BoardLayout3D.BASETTA_D)))
	_ok("  un blocco largo il triplo prende il triplo di terra",
		(t3["scala"] as Vector2).x > (t["scala"] as Vector2).x * 2.9)

	# Le due facce: davanti e dietro, grandi quanto la basetta.
	var facce := BoardLayout3D.facce_basetta(gs, largo)
	_eq("il banner sta su due facce", facce.size(), 2)
	var piede := BoardLayout3D.basetta_box(gs, largo)
	for f in facce:
		var d: Vector2 = f["dim"]
		_ok("  grande quanto la basetta",
			is_equal_approx(d.x, piede.size.x) and is_equal_approx(d.y, piede.size.y))
		break
	_approx("  una davanti", (facce[0]["pos"] as Vector3).z, piede.end.z)
	_approx("  e una dietro", (facce[1]["pos"] as Vector3).z, piede.position.z)

# I lavoratori sono pupazzetti e si contano: quelli in mano stanno sulla
# bacchetta, quelli usati sulla strada, e non se ne perde nessuno per via.
func _test_pupazzetti() -> void:
	var ctl := _gioco()
	var gs := ctl.gs
	var p: PlayerState = gs.players[0]
	_eq("a inizio partita sono tutti in mano",
		BoardLayout3D.meeple_liberi(gs, 0).size(), p.workers)
	_eq("  e sulla strada non ce n'e' nessuno",
		BoardLayout3D.meeple_in_campo(gs, 0).size(), 0)

	var bacchetta := BoardLayout3D.bacchetta_box(gs, 0)
	for pos in BoardLayout3D.meeple_liberi(gs, 0):
		_ok("  e stanno sulla bacchetta del loro colore",
			pos.x >= bacchetta.position.x - 0.1 and pos.x <= bacchetta.end.x + 0.1
			and pos.z >= bacchetta.position.z - 0.1 and pos.z <= bacchetta.end.z + 0.1)
		break

	# Piazzato uno, il conto si sposta ma non cambia.
	ctl.place_worker(2)
	_eq("piazzandone uno, in mano ne restano %d" % (p.workers - 1),
		BoardLayout3D.meeple_liberi(gs, 0).size(), p.workers - 1)
	_eq("  e uno e' sulla strada", BoardLayout3D.meeple_in_campo(gs, 0).size(), 1)
	_eq("  nella colonna che ha attivato",
		int(BoardLayout3D.meeple_in_campo(gs, 0)[0]["col"]), 2)
	_eq("  e il conto torna sempre",
		BoardLayout3D.meeple_liberi(gs, 0).size()
		+ BoardLayout3D.meeple_in_campo(gs, 0).size(), p.workers)

	# Chi abita un edificio ci sale sopra: il pupazzetto sta sulla basetta.
	# Serve una partita nuova, perche' di lavoratori se ne piazza uno per
	# turno e in questa e' gia' stato piazzato.
	var ctl2 := _gioco()
	var gs2 := ctl2.gs
	var b := _metti(gs2, "ed_capanne", 4, 1, 0, 0)
	_ok("si piazza il lavoratore sull'edificio", ctl2.place_worker(4, b))
	var su_edificio := []
	for m in BoardLayout3D.meeple_in_campo(gs2, 0):
		if int(m["uid"]) == b.uid: su_edificio.append(m)
	_eq("chi abita un edificio sta sulla sua basetta", su_edificio.size(), 1)
	if not su_edificio.is_empty():
		var piede := BoardLayout3D.basetta_box(gs2, b)
		var pos: Vector3 = su_edificio[0]["pos"]
		_approx("  alla quota della basetta", pos.y, piede.end.y)
		_ok("  e dentro il suo ingombro",
			pos.x >= piede.position.x - 0.1 and pos.x <= piede.end.x + 0.1)

	# A fine era tornano tutti indietro da soli: e' `worker_cols` che si
	# svuota, la vista non deve ricordarsi niente.
	p.reset_for_era()
	_eq("a fine era tornano tutti sulla bacchetta",
		BoardLayout3D.meeple_liberi(gs, 0).size(), p.workers)
	_eq("  e la strada resta sgombra",
		BoardLayout3D.meeple_in_campo(gs, 0).size(), 0)

# "Sempre disponibile fuori dalle file": la carta non si muove, si prende il
# pupazzetto.
func _test_dinastia() -> void:
	var ctl := _gioco()
	var gs := ctl.gs
	var carta := BoardLayout3D.carta_dinastia(gs)
	_ok("la carta Dinastia sta sul tavolo", not carta.is_empty())
	if carta.is_empty(): return
	var dove: AABB = carta["aabb"]
	_ok("  fuori dalla strada, a fianco delle file",
		dove.position.x >= BoardLayout3D.board_w(gs))
	_eq("c'e' un pupazzetto per giocatore",
		BoardLayout3D.meeple_dinastia(gs).size(), gs.n_players)
	for m in BoardLayout3D.meeple_dinastia(gs):
		var pos: Vector3 = m["pos"]
		_ok("  e stanno sulla carta",
			pos.x >= dove.position.x - 0.1 and pos.x <= dove.end.x + 0.1
			and pos.z >= dove.position.z - 0.1 and pos.z <= dove.end.z + 0.1)
		break

	var p: PlayerState = gs.players[0]
	var prima := p.workers
	p.pietra = 99
	p.oro = 99
	ctl.place_worker(1)
	_ok("il giocatore 0 compra la Dinastia", ctl.buy_dynasty())
	_eq("  e adesso ha un lavoratore in piu'", p.workers, prima + 1)
	var rimasti := BoardLayout3D.meeple_dinastia(gs)
	_eq("  sulla carta resta un pupazzetto in meno", rimasti.size(), gs.n_players - 1)
	var suoi := 0
	for m in rimasti:
		if int(m["player"]) == 0: suoi += 1
	_eq("  e il suo non c'e' piu'", suoi, 0)
	_eq("  ma la carta e' rimasta dov'era",
		BoardLayout3D.carta_dinastia(gs)["aabb"], dove)
	var carte := BoardLayout3D.carte_giocatore(gs, 0, 0)
	var dinastie := 0
	for c in carte:
		if str(c["kind"]) == "dinastia": dinastie += 1
	_eq("  e non se n'e' portata via una copia", dinastie, 0)

# "Infilatelo sotto la carta di un vostro edificio": il personaggio sepolto
# si vede li' sotto, con la linguetta di fuori, e non in mezzo agli altri.
func _test_sepolto() -> void:
	var ctl := _gioco()
	var gs := ctl.gs
	var p: PlayerState = gs.players[0]
	var b := _metti(gs, "ed_capanne", 3, 1, 0, 0)
	var cid := str(gs.char_row[0]) if not gs.char_row.is_empty() \
		else str(CardDB.characters.keys()[0])
	p.specialized_characters.append(cid)

	var prima := 0
	for c in BoardLayout3D.carte_giocatore(gs, 0, 0):
		if str(c["kind"]) == "personaggio" and str(c["id"]) == cid: prima += 1
	_eq("finche' e' vivo il personaggio sta davanti al giocatore", prima, 1)

	b.buried_character = cid
	b.buried_character_era = 1
	var carte := BoardLayout3D.player_cards(gs, 0)
	var sotto := []
	var edificio := []
	for c in carte:
		if int(c.get("player", -1)) != 0: continue
		if str(c["kind"]) == "personaggio" and str(c["id"]) == cid: sotto.append(c)
		if str(c["kind"]) == "mercato" and str(c["id"]) == str(b.data["id"]): edificio.append(c)
	_eq("una volta sepolto se ne disegna una sola", sotto.size(), 1)
	_eq("  e la carta del suo edificio c'e'", edificio.size(), 1)
	if sotto.is_empty() or edificio.is_empty(): return
	var cs: AABB = sotto[0]["aabb"]
	var ce: AABB = edificio[0]["aabb"]
	_ok("  sta sotto la carta dell'edificio", cs.position.y <= ce.position.y)
	_ok("  ma sporge di fianco",
		cs.end.x > ce.end.x and cs.position.x < ce.end.x)
	_ok("  e si tocca con lei, non sta per conto suo",
		cs.position.z < ce.end.z and cs.end.z > ce.position.z)
	var altrove := 0
	for c in BoardLayout3D.carte_giocatore(gs, 0, 0):
		if str(c["kind"]) == "personaggio" and str(c["id"]) == cid: altrove += 1
	_eq("  e non resta anche in mezzo alle altre", altrove, 0)

func _test_terrapieni() -> void:
	var ctl := _gioco()
	var gs := ctl.gs
	# una base in colonna 1, la 2 nuda: un edificio da due caselle che parte
	# dalla 1 deve riportare terra sulla 2
	var sotto := _metti(gs, "ed_capanne", 1, 1, 0, 0)
	sotto.state = Enums.BuildingState.ROVINA
	var d: Dictionary = CardDB.buildings[_largo(2)]
	var q := BuildRules.quote_above(gs, 0, d, 1)
	_ok("il preventivo passa (%s)" % q.reason, q.legal)
	_eq("  e dice quale colonna va riempita", q.terrapieno_cols, [2] as Array[int])
	_ok("  e la fa pagare", q.terrapieno_pietra > 0)

	# Costruito davvero, l'edificio se le porta dietro: e' da li' che la
	# vista sa dove disegnare la terra.
	var p: PlayerState = gs.players[0]
	p.pietra = 99
	p.oro = 99
	ctl.place_worker(1)
	var quanti := gs.grid.buildings.size()
	_ok("si costruisce col terrapieno", ctl.build(str(d["id"]), 1, true))
	if gs.grid.buildings.size() <= quanti: return
	var su: Building = gs.grid.buildings[gs.grid.buildings.size() - 1]
	_eq("  e l'edificio si ricorda dove", su.terrapieno_cols, [2] as Array[int])

	# E il blocco di terra riempie il vuoto: parte dal piano del tavolo e
	# arriva esatto sotto il piede, senza scalini.
	var boxes := BoardLayout3D.terrapieni(gs, su)
	_eq("si disegna un blocco per colonna riempita", boxes.size(), 1)
	var box: AABB = boxes[0]
	var piede := BoardLayout3D.basetta_box(gs, su)
	_approx("  che parte dal piano del tavolo", box.position.y, BoardLayout3D.TESSERA_Y)
	_approx("  e arriva esatto sotto il piede", box.end.y, piede.position.y)
	_ok("  con la stessa profondita' del piede",
		is_equal_approx(box.position.z, piede.position.z)
		and is_equal_approx(box.size.z, piede.size.z))
	_ok("  e sta nella colonna che ha pagato",
		box.position.x >= BoardLayout3D.col_x(2) - BoardLayout3D.TESSERA_W
		and box.end.x <= BoardLayout3D.col_x(3) + BoardLayout3D.TESSERA_W)

	# Chi poggia su basi vere non riporta niente, e non si disegna niente.
	_eq("senza colonne nude non c'e' terra da riportare",
		BoardLayout3D.terrapieni(gs, sotto).size(), 0)

# LE MISURE DELLE CARTE. Sul foglio di stampa non sono alte uguali - la
# Dinastia e' 95 mm, un edificio 62 - e a schermo la differenza diventava
# enorme: le carte grandi schiacciavano le altre e il tavolo non sembrava
# piu' un mazzo solo. E le sei del mercato, in una colonna sola, erano piu'
# lunghe della strada: la prima finiva fuori dal tabellone, sospesa nel nulla.
# Un edificio largo puo' poggiare su due colonne di quota diversa: prende il
# livello della piu' alta piu' uno, e sull'altra resta uno scalino. Il
# regolamento quello scalino non lo fa pagare - il terrapieno e' "per colonna
# priva di base" - ma sul tavolo la terra ci va lo stesso, se no meta' sagoma
# sta sul vuoto. E' il buco che si vedeva sotto la Fortezza bastionata.
func _test_scalino() -> void:
	var ctl := _gioco()
	var gs := ctl.gs
	# colonna 1: una pila che arriva a livello 1. colonna 2: solo una rovina
	# a terra. Chi costruisce sopra entrambe parte da livello 2.
	var a := _metti(gs, "ed_capanne", 1, 1, 0, 0)
	a.state = Enums.BuildingState.ROVINA
	var b := _metti(gs, "ed_capanne", 1, 1, 1, 0)
	b.state = Enums.BuildingState.ROVINA
	var c := _metti(gs, "ed_capanne", 2, 1, 0, 0)
	c.state = Enums.BuildingState.ROVINA

	var d: Dictionary = CardDB.buildings[_largo(2)]
	var q := BuildRules.quote_above(gs, 0, d, 1)
	_ok("il preventivo passa (%s)" % q.reason, q.legal)
	_eq("  l'edificio va a livello 2", q.level, 2)
	_eq("  e nessuna colonna paga terrapieno", q.terrapieno_cols, [] as Array[int])

	var p: PlayerState = gs.players[0]
	p.pietra = 99
	p.oro = 99
	ctl.place_worker(1)
	var quanti := gs.grid.buildings.size()
	_ok("si costruisce a scalino", ctl.build(str(d["id"]), 1, true))
	if gs.grid.buildings.size() <= quanti: return
	var su: Building = gs.grid.buildings[gs.grid.buildings.size() - 1]

	_eq("la colonna alta regge da sola", BoardLayout3D.quota_sotto(gs, su, 1), 1)
	_eq("  quella bassa e' indietro di un livello", BoardLayout3D.quota_sotto(gs, su, 2), 0)
	var boxes := BoardLayout3D.terrapieni(gs, su)
	_eq("si riempie solo la colonna indietro", boxes.size(), 1)
	if boxes.is_empty(): return
	var box: AABB = boxes[0]
	var piede := BoardLayout3D.basetta_box(gs, su)
	_approx("  la terra parte dalla cima di cio' che c'e'", box.position.y,
		BoardLayout3D.level_y(1))
	_approx("  e arriva esatto sotto il piede", box.end.y, piede.position.y)
	_ok("  e sta nella colonna 2", box.position.x >= BoardLayout3D.col_x(2) - 0.1)

func _test_misure_carte() -> void:
	# Stessa altezza, proporzioni salve: il disegno non si deforma.
	var storte := 0
	for tipo in BoardLayout3D.CARTE_IN_PIEDI:
		var m := BoardLayout3D.misura_carta(str(tipo))
		if not is_equal_approx(m.y, BoardLayout3D.ALTEZZA_CARTA): storte += 1
		var vera: Vector2 = BoardLayout3D.MISURE_CARTE[str(tipo)]
		if not is_equal_approx(m.x / m.y, vera.x / vera.y): storte += 1
	_eq("le carte in piedi sono alte uguali, senza deformarsi", storte, 0)
	_ok("  e la piu' larga non e' il doppio della piu' stretta in altezza",
		is_equal_approx(BoardLayout3D.misura_carta("dinastia").y,
			BoardLayout3D.misura_carta("mercato").y))
	# Le tessere lunghe restano quello che sono: tirarle a quell'altezza le
	# farebbe larghe mezzo metro.
	_approx("i monumenti restano tessere basse",
		BoardLayout3D.misura_carta("monumento").y,
		BoardLayout3D.MISURE_CARTE["monumento"].y)

	# IL MERCATO STA DENTRO LA STRADA. E' il difetto che si vedeva: la prima
	# carta usciva dal tabellone.
	var gs := _gioco().gs
	var mercato: Array = []
	for c in BoardLayout3D.side_cards(gs):
		if str(c["kind"]) == "mercato": mercato.append(c["aabb"])
	_eq("ci sono tutte le carte del mercato", mercato.size(), gs.market.size())
	var fuori := 0
	for b in mercato:
		var r: AABB = b
		if r.position.z < -0.001 or r.end.z > BoardLayout3D.board_d() + 0.001:
			fuori += 1
	_eq("nessuna sborda davanti o dietro la strada", fuori, 0)

	# Due file da tre: le x distinte sono due, le z tre.
	var xs := {}
	var zs := {}
	for b in mercato:
		var r: AABB = b
		xs[snappedf(r.position.x, 0.1)] = true
		zs[snappedf(r.position.z, 0.1)] = true
	_eq("il mercato sta in due file", xs.size(), 2)
	_eq("  da tre carte l'una", zs.size(), 3)

	# E stanno a sinistra della strada, senza coprirla e senza accavallarsi.
	var sopra := 0
	for b in mercato:
		if (b as AABB).end.x > 0.001: sopra += 1
	_eq("il mercato resta fuori dalla strada", sopra, 0)
	var coperte := 0
	for i in mercato.size():
		for j in range(i + 1, mercato.size()):
			var a: AABB = mercato[i]
			var b2: AABB = mercato[j]
			if a.position.x < b2.end.x - 0.001 and b2.position.x < a.end.x - 0.001 \
				and a.position.z < b2.end.z - 0.001 and b2.position.z < a.end.z - 0.001:
				coperte += 1
	_eq("  e nessuna ne copre un'altra", coperte, 0)

	# Cliccabili una per una: il mercato e' il punto da cui si comincia ogni
	# azione, e prenderne una per l'altra sarebbe il peggio.
	var sbagliate := 0
	for c in BoardLayout3D.side_cards(gs):
		if str(c["kind"]) != "mercato": continue
		var r: AABB = c["aabb"]
		var centro := r.position + Vector3(r.size.x / 2.0, 0.0, r.size.z / 2.0)
		var presa := BoardLayout3D.card_at_ray(gs, centro + Vector3(0, 500, 0),
			Vector3(0, -1, 0))
		if presa.is_empty() or str(presa["id"]) != str(c["id"]): sbagliate += 1
	_eq("  e cliccandone una si prende proprio quella", sbagliate, 0)

# LA SAGOMA ERA QUATTRO COPIE DEL DISEGNO impilate lungo lo spessore per far
# sembrare pieno il cartone. Da vicino si vedevano per quello che erano:
# quattro figure appaiate. Adesso e' un pezzo unico, col contorno ritagliato
# dall'alfa dell'illustrazione ed estruso.
func _test_sagoma_estrusa() -> void:
	# Un'illustrazione finta: una losanga opaca al centro di un'immagine
	# trasparente. Serve una forma NON rettangolare, perche' e' tutto il
	# punto: una scatola dietro il disegno sporgerebbe dalla sagoma.
	var lato := 64
	var img := Image.create(lato, lato, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	for y in lato:
		for x in lato:
			if absf(x - lato / 2.0) + absf(y - lato / 2.0) < lato / 3.0:
				img.set_pixel(x, y, Color(0.8, 0.6, 0.4, 1.0))
	var tex := ImageTexture.create_from_image(img)

	var dim := Vector2(60.0, 66.0)
	var spessore := 9.0
	var vista := preload("res://scripts/view/board_view_3d.gd")
	var mesh: ArrayMesh = vista.mesh_sagoma(tex, dim, spessore)
	_ok("il contorno si ritaglia e si estrude", mesh != null)
	if mesh == null: return
	_eq("una superficie per la stampa e una per il taglio",
		mesh.get_surface_count(), 2)

	var box := mesh.get_aabb()
	_approx("e' spessa quanto il cartone disegnato", box.size.z, spessore)
	_ok("  e sta dentro le misure della sagoma (%.1f x %.1f)"
		% [box.size.x, box.size.y],
		box.size.x <= dim.x + 0.001 and box.size.y <= dim.y + 0.001)
	# La losanga occupa i due terzi del quadrato: se il contorno fosse il
	# rettangolo dell'immagine invece della figura, sarebbe largo tutto.
	_ok("  e segue la figura, non il rettangolo (%.1f su %.1f)"
		% [box.size.x, dim.x], box.size.x < dim.x * 0.95)
	_ok("  ed e' centrata sull'origine",
		absf(box.position.z + spessore / 2.0) < 0.001)

	# La cache: la scena si ricostruisce a ogni clic e a ogni mossa dei bot,
	# e rifare il ritaglio ogni volta sarebbe uno spreco.
	var ancora: ArrayMesh = vista.mesh_sagoma(tex, dim, spessore)
	_ok("la stessa sagoma non si ritaglia due volte", ancora == mesh)
	var altra: ArrayMesh = vista.mesh_sagoma(tex, dim * 2.0, spessore)
	_ok("  ma una taglia diversa e' un pezzo diverso", altra != mesh)

	# Un'immagine piena fino ai bordi non ha un contorno da ritagliare: si
	# deve ripiegare sul piano, non far saltare la scena.
	var pieno := Image.create(8, 8, false, Image.FORMAT_RGBA8)
	pieno.fill(Color(1, 1, 1, 1))
	var tex2 := ImageTexture.create_from_image(pieno)
	var m2: ArrayMesh = vista.mesh_sagoma(tex2, dim, spessore)
	_ok("un'immagine senza ritaglio non fa saltare niente (%s)"
		% ("piano" if m2 == null else "estrusa"), true)

# LA SCENA GIOCABILE NON LA COMPILAVA NESSUN TEST. Un errore di sintassi in
# gioca.gd passava tutta la suite - i test caricano i moduli puri, non la
# scena - e si vedeva solo aprendo il gioco, con lo schermo grigio e nessun
# messaggio. E' successo: una sostituzione aveva mangiato tre funzioni e i
# 156 test erano tutti verdi.
# Qui la scena si carica DAVVERO e si avvia: se non compila, o se _ready
# scoppia, il test lo dice.
func _test_scena_giocabile() -> void:
	for percorso in ["res://scripts/view/gioca.gd",
			"res://scripts/view/board_view_3d.gd",
			"res://scripts/view/board_layout_3d.gd",
			"res://scripts/view/camera_orbita.gd",
			"res://scripts/view/descrizione_azione.gd",
			"res://scripts/view/scelte_inizio.gd",
			"res://scripts/view/riepilogo.gd",
			"res://scripts/rules/available_actions.gd"]:
		_ok("%s si compila" % percorso.get_file(), ResourceLoader.load(percorso) != null)
	var scena := ResourceLoader.load("res://scenes/gioca.tscn") as PackedScene
	_ok("la scena giocabile si carica", scena != null)
	if scena == null: return
	var n := scena.instantiate()
	add_child(n)          # qui gira _ready: la schermata di scelta
	_ok("  e si avvia senza fermarsi", n.get_child_count() > 0)
	_ok("  e si apre sulla scelta, non su una partita decisa da noi",
		n.ctl == null)

	# Quel che farebbe il clic su "Comincia": in due, uno dei quali bot.
	n.inizio.con_giocatori(2)
	n.inizio.con_bot(1)
	n.comincia()
	_ok("  e cominciando si ha una partita in piedi",
		n.ctl != null and n.ctl.gs != null)
	_eq("  coi giocatori scelti", n.ctl.gs.n_players, 2)
	_ok("  e col tavolo disegnato", n.vista != null)
	# Col bot al secondo posto, il turno torna sempre all'umano.
	_ok("  e il turno e' dell'umano", n.inizio.e_umano(n.ctl.gs.current_index)
		or n.ctl.gs.phase == Enums.Phase.FINE_PARTITA)

	# Tutti bot: si guarda giocare, e la partita deve arrivare in fondo da
	# sola senza restare appesa ad aspettare un umano che non c'e'.
	n.inizio.con_giocatori(3)
	n.inizio.con_bot(3)
	n.inizio.con_velocita(4)          # subito: tutti i turni in un colpo
	n.comincia()
	_ok("  e con tutti bot a velocita' subito la partita va avanti da sola",
		n.ctl.gs.era > 1 or n.ctl.gs.phase == Enums.Phase.FINE_PARTITA)

	# A passo invece nessuno si muove finche' non glielo si chiede: e' il
	# modo per guardare i bot una mossa alla volta.
	n.inizio.con_velocita(0)
	n.comincia()
	var mosse := func(gs2: GameState) -> int:
		var q := 0
		for pl in gs2.players: q += pl.workers_used
		return q
	_ok("  e a passo il tavolo resta fermo",
		n.ctl.gs.era == 1 and mosse.call(n.ctl.gs) == 0 and n.bot_da_muovere())
	var chi: int = n.ctl.gs.current_index
	n.muovi_un_bot()
	_ok("  e ogni Avanza e' un turno, uno solo (%d mosse, ora tocca a %d)"
		% [mosse.call(n.ctl.gs), n.ctl.gs.current_index],
		mosse.call(n.ctl.gs) == 1 and n.ctl.gs.current_index != chi)
	n.torna_alla_scelta()
	_ok("  e si torna alla scelta", n.ctl == null and n.vista == null)
	n.queue_free()
