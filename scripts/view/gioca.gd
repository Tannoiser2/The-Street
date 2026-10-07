# res://scripts/view/gioca.gd
# La plancia giocabile. Si comincia dalla schermata di scelta - quanti
# giocatori, quanti bot - e i posti sono in ordine: prima gli umani, poi i
# bot. Se gli umani sono piu' di uno si gioca a turno sullo stesso schermo,
# e l'interfaccia e' sempre di chi ha il turno: le sue risorse in alto, il
# suo obiettivo segreto scoperto, i suoi posti accesi.
# Ogni modifica passa dal GameController, mai da qui: questo script legge lo
# stato, mostra le opzioni e chiama i comandi.
#
# COME SI GIOCA, ed e' anche il motivo per cui l'elenco a menu non c'e' piu':
# le carte stanno sul tavolo, quindi si scelgono sul tavolo. Clicchi una carta
# del mercato e si accendono tutti i posti dove quell'edificio puo' andare;
# clicchi un potenziamento o un personaggio e si accendono gli edifici che
# possono riceverlo; clicchi il posto acceso e l'azione e' fatta.
# Niente scritte che galleggiano sopra le carte: il nome e i numeri escono in
# un riquadro che segue il mouse, e solo per la carta puntata.
extends Node3D

# Chi siede al tavolo. Finche' `ctl` e' null siamo alla schermata di scelta:
# e' quello, e non una variabile in piu', a dire in che schermo siamo.
# Pubblica di proposito: e' la scelta che la schermata d'inizio mostra e che
# i test pilotano per cominciare una partita senza cliccare.
var inizio := ScelteInizio.new()

# La vista si preloada una volta sola: dallo stesso script viene anche il
# colore dei giocatori, che serve all'interfaccia pure a tavolo sparecchiato.
const VISTA := preload("res://scripts/view/board_view_3d.gd")

# Il giocatore per cui l'interfaccia sta lavorando: chi ha il turno, se e'
# umano. -1 quando tocca a un bot o la partita non e' cominciata, e allora
# non si puo' fare niente - nemmeno vedere l'obiettivo segreto di nessuno.
func _io() -> int:
	if ctl == null: return -1
	return ctl.gs.current_index if inizio.e_umano(ctl.gs.current_index) else -1

# Di chi mostrare risorse e punteggio in alto. Di norma e' chi ha il turno;
# in una partita di soli bot non c'e' nessun umano e si guarda giocare quello
# di turno, che e' meglio di una riga vuota.
# La v2 si riconosce dal file dati caricato, non da una variabile della vista.
func _v2() -> bool:
	return (str(CardDB.ruleset).begins_with("v2") or str(CardDB.ruleset).begins_with("v3"))

# LA V3 A SCHERMO (registro 176). Il lavoratore e' un Personaggio: prima di
# piazzarlo si sceglie quale, fra quelli presi al draft e non ancora usati;
# senza scegliere va il primo, come fa il controller. Dopo l'attivazione il
# gioco puo' chiedere quale edificio della colonna usare (la "scelta" stile
# Caylus, registro 170): e' una pending_choice di tipo "edificio", che si
# risolve cliccando l'edificio sul tavolo o un tasto sotto la barra.
func _v3() -> bool:
	return PersonaggiV3.attivo()

var _personaggio_scelto := ""

# Il Personaggio che il prossimo piazzamento usera' (v3): quello scelto se e'
# ancora libero, se no il primo libero; "" fuori dalla v3.
func _lavoratore() -> String:
	if ctl == null or not _v3() or _io() < 0: return ""
	var liberi: Array[String] = ctl.personaggi_liberi(ctl.gs.players[_io()])
	if liberi.is_empty(): return ""
	if _personaggio_scelto in liberi: return _personaggio_scelto
	return liberi[0]

func _nome_personaggio(cid: String) -> String:
	return str(CardDB.characters[cid]["name"]) if CardDB.characters.has(cid) else cid

func _in_vetrina() -> int:
	if ctl == null: return -1
	# A partita finita si mostra il vincitore, non chi ha mosso per ultimo:
	# e' l'unico giocatore che interessi ancora, e vederne un altro accanto
	# alla riga "vincitore: giocatore 3" confondeva e basta.
	if ctl.gs.phase == Enums.Phase.FINE_PARTITA: return Scoring.winner(ctl.gs)
	return ctl.gs.current_index

# Il mouse fa tre cose e non devono pestarsi i piedi: il sinistro trascinato
# gira il tabellone, il sinistro premuto e rilasciato fermo sceglie, il destro
# sposta e la rotella avvicina. Il confine fra "clic" e "trascinata" e' una
# soglia in pixel: sotto quella il gesto resta un clic, cosi' una mano che
# trema non fa girare il tavolo e non fa perdere la selezione.
const SOGLIA_TRASCINAMENTO := 5.0

var ctl: GameController
var vista: Node3D
var _hud: Control
var _colonna_sotto_mouse := -1
var _messaggio := ""
# La cronaca (registro 146): le ultime mosse raccontate, la piu' recente in
# testa. Ogni voce: {"righe": Array[String], "mia": bool}.
var _cronaca: Array = []
const CRONACA_VOCI := 6

# La carta scelta, {} se nessuna: {"kind": ..., "id": ...}. Da lei discendono
# i bersagli accesi.
var _scelta: Dictionary = {}
var _bersagli: Array = []            # AvailableActions.Voce, una per bersaglio
# Il bersaglio acceso che il mouse sta puntando adesso, null se nessuno: e'
# quello che la barra di stato descrive. Si ricalcola sempre dai `_bersagli`
# correnti, mai conservato oltre, cosi' non puo' restare indietro.
var _sotto_mouse: AvailableActions.Voce = null
var _bottoni: Array = []             # {"rect", "voce"} per le azioni senza carta

# Il riquadro che segue il mouse: sostituisce tutte le scritte che prima
# galleggiavano sul tavolo.
var _nota: PackedStringArray = PackedStringArray()
var _nota_dove := Vector2.ZERO

# Il riepilogo finale sta aperto appena la partita finisce; si chiude per
# guardare il tavolo con le eredita' scoperte, e si riapre col suo tasto.
var _riepilogo_aperto := true

# Quanto manca al prossimo turno di bot, in secondi.
var _attesa := 0.0

var _orbita: CameraOrbita = null
var _premuto := MOUSE_BUTTON_NONE
var _partenza := Vector2.ZERO
var _trascinato := false

# IL TOCCO (iPad). Il tocco non diventa piu' un mouse finto
# (`emulate_mouse_from_touch` spento): un dito che trascinava era il tasto
# sinistro, cioe' solo rotazione, e un tocco tremava piu' dei 5 pixel di
# soglia e diventava una rotazione invece di una scelta. Qui: un dito ruota,
# tocca e trascina le carte; due dita pizzicano per lo zoom e scorrono per
# spostare il tavolo.
const SOGLIA_TOCCO := 22.0
var _tocchi: Dictionary = {}
var _pizzico := 0.0
var _centro_dita := Vector2.ZERO

# IL TRASCINAMENTO DELLE CARTE: premendo su una carta del mercato o della fila
# e trascinando, la carta si sceglie, i posti si accendono e la si lascia
# sul posto voluto. Senza trascinare resta il tocco-tocco di sempre.
var _carta_presa: Dictionary = {}
var _porta_carta := false

func _ready() -> void:
	var strato := CanvasLayer.new()
	add_child(strato)
	_hud = Control.new()
	_hud.set_anchors_preset(Control.PRESET_FULL_RECT)
	_hud.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_hud.draw.connect(_disegna_hud)
	strato.add_child(_hud)
	inizio.rimescola()
	_hud.queue_redraw()

# Dalla schermata di scelta al tavolo. E' anche il punto da cui si ricomincia
# a fine partita, quindi rifa' tutto da capo invece di rattoppare: via la
# vista vecchia, stato nuovo, inquadratura nuova.
func comincia() -> void:
	inizio.sistema()
	_riepilogo_aperto = true
	if vista != null:
		remove_child(vista)
		vista.queue_free()
	_deseleziona(false)
	_personaggio_scelto = ""
	_messaggio = ""
	_cronaca = []
	_orbita = null
	_colonna_sotto_mouse = -1
	# Il regolamento e' il file dati: si carica prima di cominciare, ogni
	# volta, cosi' si puo' passare dalla v2 alla v1.5 e tornare senza
	# riavviare.
	CardDB.load_db(inizio.percorso_dati())
	ctl = GameController.new()
	# Le persone scelgono a schermo le tessere dell'era "a scelta".
	for i in inizio.giocatori:
		if inizio.e_umano(i): ctl.umani[i] = true
	ctl.new_game(inizio.giocatori, inizio.seme)
	vista = VISTA.new()
	add_child(vista)
	vista.scale = Vector3.ONE * BoardLayout3D.U
	_turni_dei_bot()
	_aggiorna()

# Torna alla schermata di scelta: il tavolo sparisce e si ricomincia.
func torna_alla_scelta() -> void:
	if vista != null:
		remove_child(vista)
		vista.queue_free()
		vista = null
	ctl = null
	_orbita = null
	_deseleziona(false)
	_nota = PackedStringArray()
	_messaggio = ""
	inizio.rimescola()
	_hud.queue_redraw()

func _aggiorna() -> void:
	if ctl == null or vista == null:
		_hud.queue_redraw()
		return
	# A turno sullo stesso schermo: l'obiettivo segreto scoperto e' quello di
	# chi ha il turno, e di nessun altro.
	vista.umano = _io()
	# Finche' il giocatore non tocca la telecamera, l'inquadratura continua a
	# calcolarsi da sola e arretra man mano che le torri salgono. Appena la
	# muove, comanda lui e nessun aggiornamento gliela riporta indietro.
	if _orbita == null or _orbita.e_iniziale():
		_orbita = CameraOrbita.da_stato(ctl.gs)
		vista.orbita = _orbita
	vista.mostra(ctl.gs, _colonna_sotto_mouse, _acceso())
	vista.scale = Vector3.ONE * BoardLayout3D.U
	# Il tavolo e' cambiato sotto un mouse fermo: quel che la barra prometteva
	# puo' non esistere piu', quindi si richiede a partire dai bersagli nuovi.
	_sotto_mouse = _bersaglio_sotto(_nota_dove)
	_hud.queue_redraw()

# Cosa la vista deve accendere: la carta scelta, i posti dove puo' andare, gli
# edifici che possono riceverla.
func _acceso() -> Dictionary:
	if _scelta.is_empty(): return {}
	var slot: Array = []
	var uid: Array = []
	for v in _bersagli:
		if v.parametri.has("col_from"):
			var d: Dictionary = CardDB.buildings[str(v.parametri["card_id"])]
			slot.append({"col_from": int(v.parametri["col_from"]),
				"width": int(d["width"]), "level": int(v.parametri.get("level", 0)),
				"binario": int(v.parametri.get("binario", 0)), "depth": int(d.get("depth", 1))})
		elif v.parametri.has("uid"):
			uid.append(int(v.parametri["uid"]))
	return {"carta": _scelta, "slot": slot, "uid": uid}

# C'e' un bot che deve muovere? Lo chiedono il motore dei turni, il tasto
# "Avanza" e il disegno, quindi la risposta e' una sola.
func bot_da_muovere() -> bool:
	return ctl != null and ctl.gs.phase != Enums.Phase.FINE_PARTITA \
		and not inizio.e_umano(ctl.gs.current_index)

# Un turno di bot, e il tavolo si ridisegna. E' il passo che il giocatore
# vede: prima i bot giocavano tutti i loro turni fra un clic e l'altro e sul
# tabellone comparivano tre edifici insieme, senza che si capisse chi avesse
# fatto cosa.
# Fa una mossa e la racconta: fotografia prima, differenza dopo.
func _racconta(mossa: Callable) -> Variant:
	if ctl == null: return mossa.call()
	var prima := Cronaca.fotografa(ctl.gs)
	var esito = mossa.call()
	# "Tu" e' l'umano che ha mosso, se gioca da solo; a turno sullo stesso
	# schermo ognuno e' "giocatore N". Si guarda chi ha mosso, non di chi e'
	# il turno adesso: finita la mossa tocca gia' a un altro.
	var chi := int(prima["chi"])
	var mio := inizio.e_umano(chi)
	var io := chi if mio and inizio.umani() <= 1 else -1
	var righe := Cronaca.racconta(ctl.gs, prima, io)
	if not righe.is_empty():
		_cronaca.push_front({"righe": righe, "mia": mio})
		while _cronaca.size() > CRONACA_VOCI: _cronaca.pop_back()
	return esito

func muovi_un_bot() -> void:
	if not bot_da_muovere(): return
	_racconta(func(): StrategyBot.play_turn(ctl, inizio.strategia(ctl.gs.current_index)))
	_attesa = maxf(inizio.pausa_bot(), 0.0)
	_aggiorna()

# Il tempo che passa muove i bot, uno alla volta. A "passo" non li muove
# nessuno: aspettano il tasto Avanza.
func _process(delta: float) -> void:
	if not bot_da_muovere() or inizio.bot_a_mano() or inizio.bot_subito(): return
	_attesa -= delta
	if _attesa <= 0.0: muovi_un_bot()

# Il turno passa ai bot. A velocita' "subito" giocano tutti i loro turni in
# un colpo, com'e' sempre stato; altrimenti si mettono in coda e li muove il
# tempo, cosi' si vede una mossa per volta.
func _turni_dei_bot() -> void:
	_attesa = maxf(inizio.pausa_bot(), 0.0)
	if not inizio.bot_subito(): return
	var giri := 0
	while bot_da_muovere() and giri < 500:
		_racconta(func(): StrategyBot.play_turn(ctl, inizio.strategia(ctl.gs.current_index)))
		giri += 1

# ---- input -----------------------------------------------------------
func _unhandled_input(evento: InputEvent) -> void:
	if evento is InputEventMouseButton:
		_pulsante(evento)
	elif evento is InputEventMouseMotion:
		_movimento(evento)
	elif evento is InputEventScreenTouch:
		_tocco(evento)
	elif evento is InputEventScreenDrag:
		_trascina_dito(evento)
	elif evento is InputEventKey and evento.pressed and not evento.echo:
		if ctl == null and evento.keycode in [KEY_ENTER, KEY_KP_ENTER, KEY_SPACE]:
			comincia()
		elif evento.keycode in [KEY_HOME, KEY_R] and _orbita != null:
			_orbita.reimposta()
			_messaggio = "Inquadratura ripristinata."
			_aggiorna()
		elif evento.keycode == KEY_ESCAPE:
			_deseleziona()

func _pulsante(e: InputEventMouseButton) -> void:
	match e.button_index:
		MOUSE_BUTTON_WHEEL_UP:
			if e.pressed: _zoom(1.0)
		MOUSE_BUTTON_WHEEL_DOWN:
			if e.pressed: _zoom(-1.0)
		MOUSE_BUTTON_LEFT, MOUSE_BUTTON_RIGHT, MOUSE_BUTTON_MIDDLE:
			if e.pressed: _premi(e.position, e.button_index)
			else: _rilascia(e.position)

func _movimento(e: InputEventMouseMotion) -> void:
	if ctl == null:
		_nota_dove = e.position
		return
	if _premuto != MOUSE_BUTTON_NONE:
		_sposta(e.position, e.relative, SOGLIA_TRASCINAMENTO)
		return
	_sopra(e.position)

# ---- un gesto, dal mouse o dal dito ------------------------------------
func _premi(pos: Vector2, tasto: int) -> void:
	_premuto = tasto
	_partenza = pos
	_trascinato = false
	_porta_carta = false
	_carta_presa = {}
	if tasto == MOUSE_BUTTON_LEFT and ctl != null and ctl.gs.phase != Enums.Phase.FINE_PARTITA \
			and ctl.gs.pending_choice.is_empty() and _io() >= 0:
		var c := _carta_puntata(pos)
		if not c.is_empty() and not c.has("player") and str(c["kind"]) in ["mercato", "potenziamento"]:
			_carta_presa = c

func _sposta(pos: Vector2, relativo: Vector2, soglia: float) -> void:
	if not _trascinato and pos.distance_to(_partenza) < soglia: return
	_trascinato = true
	if _premuto == MOUSE_BUTTON_LEFT and not _carta_presa.is_empty():
		if not _porta_carta:
			_porta_carta = true
			var gia := str(_scelta.get("kind", "")) == str(_carta_presa["kind"]) \
				and str(_scelta.get("id", "")) == str(_carta_presa["id"])
			if not gia: _seleziona(_carta_presa)
			if _scelta.is_empty():
				_porta_carta = false
				_carta_presa = {}
				return
		_nota_dove = pos
		_sotto_mouse = _bersaglio_sotto(pos)
		var kind := str(_carta_presa["kind"])
		var id := str(_carta_presa["id"])
		var misura := BoardLayout3D.misura_edificio(id) if kind == "mercato" and BoardLayout3D.grandezza_vera() \
			else BoardLayout3D.misura_carta(kind)
		vista.fantasma(BoardLayout3D.carta_path(kind, id), _sul_tavolo(pos, 60.0), misura)
		_hud.queue_redraw()
		return
	if _premuto == MOUSE_BUTTON_LEFT:
		_orbita.ruota(relativo)
	else:
		_orbita.trasla(relativo, get_viewport().get_visible_rect().size.y)
	# Si muove la sola telecamera: ricostruire la scena a ogni pixel di
	# trascinamento sarebbe uno spreco e la farebbe scattare.
	vista.muovi_telecamera()

func _rilascia(pos: Vector2) -> void:
	if _porta_carta:
		vista.fantasma_via()
		var v := _bersaglio_sotto(pos)
		if v != null: _esegui(v)
		else:
			_messaggio = "Lasciala su un posto acceso, oppure tocca un posto acceso."
			_aggiorna()
	elif _premuto == MOUSE_BUTTON_LEFT and not _trascinato:
		_sopra(pos)
		_clic(pos)
	elif _trascinato:
		# Durante la trascinata la scena non si ridisegna: a gesto finito si
		# riallinea quel che sta sotto il puntatore.
		_colonna_sotto_mouse = _colonna_puntata(pos)
		_aggiorna()
	_premuto = MOUSE_BUTTON_NONE
	_porta_carta = false
	_carta_presa = {}

# Il punto del tavolo sotto il pixel, sollevato di `alto` mm.
func _sul_tavolo(pixel: Vector2, alto: float) -> Vector3:
	var o := _origine(pixel)
	var d := _direzione(pixel)
	if absf(d.y) < 0.0001: return o
	return o + d * ((alto - o.y) / d.y)

# ---- le dita ------------------------------------------------------------
func _tocco(e: InputEventScreenTouch) -> void:
	if e.pressed:
		_tocchi[e.index] = e.position
		if _tocchi.size() == 1:
			if ctl != null: _sopra(e.position)
			_premi(e.position, MOUSE_BUTTON_LEFT)
		elif _tocchi.size() == 2:
			# Il secondo dito trasforma il gesto in pizzico: niente rotazione
			# e niente carta trascinata.
			if _porta_carta: vista.fantasma_via()
			_porta_carta = false
			_carta_presa = {}
			_premuto = MOUSE_BUTTON_NONE
			_inizia_pizzico()
		return
	var solo := _tocchi.size() == 1
	_tocchi.erase(e.index)
	if solo and _premuto != MOUSE_BUTTON_NONE:
		# Un tocco trema piu' di un clic: `_sposta` lo dice trascinamento solo
		# oltre SOGLIA_TOCCO, quindi qui un tocco fermo resta un tocco.
		_rilascia(e.position)
	elif _tocchi.size() < 2:
		_pizzico = 0.0
		if ctl != null and vista != null: _aggiorna()

func _trascina_dito(e: InputEventScreenDrag) -> void:
	_tocchi[e.index] = e.position
	if ctl == null: return
	if _tocchi.size() == 1:
		if _premuto != MOUSE_BUTTON_NONE: _sposta(e.position, e.relative, SOGLIA_TOCCO)
		return
	if _orbita == null: return
	var dita: Array = _tocchi.values()
	var a: Vector2 = dita[0]
	var b: Vector2 = dita[1]
	var d := a.distance_to(b)
	var c := (a + b) / 2.0
	if _pizzico > 0.0 and d > 0.0:
		_orbita.zoom(log(d / _pizzico) / log(CameraOrbita.PASSO_ZOOM))
		_orbita.trasla(c - _centro_dita, get_viewport().get_visible_rect().size.y)
		vista.muovi_telecamera()
	_pizzico = d
	_centro_dita = c

func _inizia_pizzico() -> void:
	var dita: Array = _tocchi.values()
	_pizzico = (dita[0] as Vector2).distance_to(dita[1])
	_centro_dita = ((dita[0] as Vector2) + (dita[1] as Vector2)) / 2.0

# Il puntatore e' sopra `pos` (il mouse che passa, o il dito che tocca): la
# barra e il riquadro dicono cosa c'e' li'.
func _sopra(pos: Vector2) -> void:
	_nota_dove = pos
	if ctl == null: return
	_nota = _descrivi_sotto(pos)
	_sotto_mouse = _bersaglio_sotto(pos)
	var col := _colonna_puntata(pos)
	if col != _colonna_sotto_mouse:
		_colonna_sotto_mouse = col
		_aggiorna()
	else:
		_hud.queue_redraw()      # il riquadro segue comunque il mouse

func _zoom(passi: float) -> void:
	if _orbita == null: return
	_orbita.zoom(passi)
	vista.muovi_telecamera()

# ---- dal pixel al tavolo ---------------------------------------------
func _origine(pixel: Vector2) -> Vector3:
	var cam := get_viewport().get_camera_3d()
	return Vector3.ZERO if cam == null else cam.project_ray_origin(pixel) / BoardLayout3D.U

func _direzione(pixel: Vector2) -> Vector3:
	var cam := get_viewport().get_camera_3d()
	return Vector3.DOWN if cam == null else cam.project_ray_normal(pixel)

func _colonna_puntata(pixel: Vector2) -> int:
	if ctl == null or get_viewport().get_camera_3d() == null: return -1
	var slot := BoardLayout3D.slot_at_ray(ctl.gs, _origine(pixel), _direzione(pixel))
	return int(slot.get("col", -1)) if not slot.is_empty() else -1

func _carta_puntata(pixel: Vector2) -> Dictionary:
	if ctl == null or get_viewport().get_camera_3d() == null: return {}
	return BoardLayout3D.card_at_ray(ctl.gs, _origine(pixel), _direzione(pixel), _io())

func _edificio_puntato(pixel: Vector2) -> Building:
	if ctl == null or get_viewport().get_camera_3d() == null: return null
	return _edificio(BoardLayout3D.at_ray_building(ctl.gs, _origine(pixel), _direzione(pixel)))

func _edificio(uid: int) -> Building:
	if uid < 0 or ctl == null: return null
	for b in ctl.gs.grid.buildings:
		if b.uid == uid: return b
	return null

# ---- il riquadro che segue il mouse ----------------------------------
# Quello che prima stava scritto sul tavolo, e lo copriva. I numeri vengono
# dai DATI e non dal disegno stampato: su 44 edifici su 60 lo Scavo del PDF
# non e' quello della v1.5.
func _descrivi_sotto(pixel: Vector2) -> PackedStringArray:
	var b := _edificio_puntato(pixel)
	if b != null: return _descrivi_sotto_edificio(b)
	var out := PackedStringArray()
	var c := _carta_puntata(pixel)
	if c.is_empty():
		# Ne' un edificio ne' una carta: se il mouse e' su una colonna, si
		# descrive la tessera, con quel che produce in quest'era e la regola.
		var col := _colonna_puntata(pixel)
		if col >= 0: return descrivi_tessera(col)
		return out
	return _descrivi_sotto_carta(c)

# Il riquadro di un edificio puntato.
func _descrivi_sotto_edificio(b: Building) -> PackedStringArray:
	var out := PackedStringArray()
	if b != null:
		var stato := "intatto"
		match b.state:
			Enums.BuildingState.RUDERE: stato = "rudere"
			Enums.BuildingState.ROVINA: stato = "rovina"
		if b.is_buried: stato += ", sepolto"
		# Nella v2 la rovina propria si ristruttura: il riquadro lo dice,
		# perche' e' l'unica cosa che una rovina in piedi invita a fare.
		elif b.state == Enums.BuildingState.ROVINA and BoardLayout3D.senza_rudere() \
				and b.owner == _io() and not TessereScavo.carte_restituite():
			stato += ", si puo' ristrutturare"
		out.append(str(b.data["name"]))
		# Nella v2 la Vetusta' non esiste (tetto 0): il riquadro la nominava
		# lo stesso, sempre a zero, e sembrava una regola ancora in gioco. Al
		# suo posto i cubetti neri, che sono la resistenza guadagnata.
		var riga := "G%d · %s · resistenza %d" % [b.owner, stato, b.effective_resistance()]
		if int(CardDB.constants.get("vetusta_max", 0)) > 0:
			riga += " · vetusta %d" % b.vetusta
		elif BoardLayout3D.cubetti_neri(b) > 0:
			var nc := BoardLayout3D.cubetti_neri(b)
			riga += " (%d cubett%s ner%s)" % [nc, "o" if nc == 1 else "i", "o" if nc == 1 else "i"]
		out.append(riga)
		if not b.upgrades.is_empty():
			var nomi := PackedStringArray()
			for u in b.upgrades: nomi.append(str(CardDB.upgrades[u]["name"]))
			out.append("potenziamenti: " + ", ".join(nomi))
		if TessereScavo.fuori(b) and TessereScavo.quante(b) > 0:
			if TessereScavo.scheletri_personaggi():
				# Col sacchetto (registro 188) le tessere sono scheletri di
				# Personaggi: scoperte, dicono chi sono e chi incassa.
				if b.scavata:
					var nomi := PackedStringArray()
					for t in b.tessere:
						if not t.has("chi"): nomi.append("nessuno (sacchetto vuoto)"); continue
						var cid := str(t["chi"])
						var padrone := TessereScavo.proprietario_personaggio(ctl.gs, cid)
						nomi.append("%s %d%s" % [str(CardDB.characters[cid]["name"]), int(t.get("v", 0)),
							"" if padrone < 0 else " a G%d" % padrone])
					out.append("scheletri riportati alla luce: " + ", ".join(nomi))
				else:
					out.append("%d tessere scavo coperte dal sacchetto; la carta e' tornata a G%d" % [
						TessereScavo.quante(b), b.owner])
			else:
				out.append("%d tessere scavo di G%d, %s; la carta e' tornata al proprietario" % [
					TessereScavo.quante(b), b.owner, "scoperte" if b.scavata else "coperte"])
		var sc := descrivi_scheletro(b)
		if sc != "": out.append(sc)
		# V3: l'azione dell'edificio, e se in questo giro e' gia' stata usata.
		if _v3() and str(b.data.get("effect_text", "")) != "":
			out.append(str(b.data["effect_text"]))
			if str(ctl.gs.bruciati.get(b.uid, "")) == PersonaggiV3.giro_corrente(ctl.gs):
				out.append("gia' usato in questo giro")
	return out

# Chi sta sepolto sotto l'edificio e quanto vale: nella v2 il lavoratore del
# potenziamento, nella v1.5 il Personaggio di fine era. Prima il riquadro
# non lo diceva, e il gettone sulla basetta restava senza nome.
func descrivi_scheletro(b: Building) -> String:
	if b.buried_character == "": return ""
	var chi := "il lavoratore del potenziamento"
	if b.buried_character != Building.LAVORATORE:
		chi = str(CardDB.characters[b.buried_character]["name"]) \
			if CardDB.characters.has(b.buried_character) else b.buried_character
	return "scheletro: %s · era %d · vale %d" % [chi, b.buried_character_era,
		BoardLayout3D.scheletro_valore(b.buried_character_era)]

# Il riquadro di una carta puntata: {"kind": ..., "id": ...}.
func _descrivi_sotto_carta(c: Dictionary) -> PackedStringArray:
	var out := PackedStringArray()
	var id := str(c["id"])
	match str(c["kind"]):
		"mercato":
			var d: Dictionary = CardDB.buildings[id]
			var co: Dictionary = d["cost"]
			out.append(str(d["name"]))
			var costo := "%dp %do" % [int(co.get("pietra", 0)), int(co.get("oro", 0))]
			if _v2(): costo = "%d C %d D %d I" % [int(co.get("pietra", 0)), int(co.get("oro", 0)), int(co.get("idee", 0))]
			out.append("%s · res %d · scavo %d · %d slot" % [
				costo, int(d["resistance"]), int(d["scavo"]), int(d["width"])])
			out.append(", ".join(d["classes"]))
		"personaggio":
			var pe: Dictionary = CardDB.characters[id]
			out.append(str(pe["name"]))
			out.append("personaggio · %s" % pe["class"])
			if str(pe.get("effect_text", "")) != "": out.append(str(pe["effect_text"]))
			# Girato (registro 194): e' uno scheletro, la tessera e' nel
			# sacchetto o sotto una rovina; a fine partita, mai ritrovato.
			if bool(c.get("coperta", false)):
				out.append("scheletro mai ritrovato" if ctl.gs.phase == Enums.Phase.FINE_PARTITA
					else "era passata: e' uno scheletro, la sua tessera (Scavo %d) e' nel sacchetto o sotto una rovina" % int(pe.get("scavo", 0)))
			# V3: e' un lavoratore; si dice se e' gia' stato piazzato in quest'era.
			if _v3() and c.has("player") and int(c["player"]) == _io():
				var mio: PlayerState = ctl.gs.players[_io()]
				if id in mio.personaggi_piazzati: out.append("gia' piazzato in quest'era")
				elif id == _lavoratore(): out.append("e' il prossimo che piazzerai")
				else: out.append("da piazzare: clicca per sceglierlo")
		"potenziamento":
			var po: Dictionary = CardDB.upgrades[id]
			out.append(str(po["name"]))
			out.append("potenziamento · %s" % po["family"])
			if str(po.get("effect_text", "")) != "": out.append(str(po["effect_text"]))
		"mazzetto":
			if TessereScavo.scheletri_personaggi():
				out.append("Il sacchetto delle tessere scavo")
				out.append("%d dentro: una per Personaggio reclutato, pescate quando un edificio crolla" % TessereScavo.rimaste(ctl.gs, id.to_int()))
			else:
				out.append("Mazzetto rovine del giocatore %s" % id)
				out.append("%d tessere scavo ancora da pescare" % TessereScavo.rimaste(ctl.gs, int(id)))
		"token":
			var tk: Dictionary = CardDB.upgrades[id]
			out.append(str(tk["name"]))
			out.append("token riscattato · %s" % tk["family"] + (" · Scavo %d" % int(tk["scavo"]) if tk.has("scavo") else ""))
		"scheletro":
			var era := int(id)
			out.append("Scheletro")
			out.append("il lavoratore del potenziamento · era %d" % era)
			out.append("vale %d punti, comunque finisca l'edificio"
				% BoardLayout3D.scheletro_valore(era))
		"monumento":
			if CardDB.monuments.has(id):
				var mo: Dictionary = CardDB.monuments[id]
				out.append(str(mo["name"]))
				out.append(str(mo.get("effect_text", "")))
		"dinastia":
			out.append("Dinastia")
			# Nella v2 i lavoratori di base sono quattro: la Dinastia e' il quinto.
			out.append("un lavoratore in piu', permanente: il %s" % ("quinto" if _v2() else "quarto"))
			var din := AvailableActions.dinastia(ctl.gs, _in_vetrina())
			out.append("costa " + DescrizioneAzione.prezzo(din) if din.legale else str(din.motivo))
		"eredita":
			if CardDB.legacies.has(id):
				var er: Dictionary = CardDB.legacies[id]
				out.append("%s (il tuo obiettivo segreto)" % er["name"])
				out.append(str(er.get("effect_text", "")))
		"eredita_coperta":
			out.append("Obiettivo segreto")
			out.append("coperto: lo vede solo il suo giocatore")
	return out

# La tessera di una colonna, come la vede chi ci passa sopra col mouse: il
# terreno, la produzione di quest'era, la regola stampata, e nella v2 se
# l'effetto e' ancora da usare o la tessera e' gia' girata (registro 103).
func descrivi_tessera(col: int) -> PackedStringArray:
	var out := PackedStringArray()
	if ctl == null or col < 0 or col >= ctl.gs.grid.n_cols: return out
	var gs := ctl.gs
	var t_id := Enums.terrain_to_string(gs.grid.terrains[col])
	var tess: Dictionary = CardDB.terrains[t_id]
	# Le tessere dell'era (registro 121): la base del terreno, la tessera
	# posata in quest'era, il suo effetto e se si e' gia' girata.
	if TessereEra.attive():
		var pr := TessereEra.produzione(gs, col)
		out.append("Colonna %d · %s" % [col, t_id.capitalize()])
		out.append("produce " + _risorse_testo(pr) + " in quest'era (base %s)"
			% _risorse_testo(tess.get("produzione_base", {})))
		var te := TessereEra.tessera(gs, col)
		if not te.is_empty():
			out.append("%s: %s" % [te["name"], te["testo"]])
			out.append("tessera girata: l'effetto torna nell'era prossima" if not EraRules.tessera_disponibile(gs, col)
				else "effetto ancora da usare in quest'era")
		return out
	var base: Dictionary = tess["base_production"]
	var per_era = tess.get("base_production_by_era", null)
	if per_era != null and per_era.has(str(gs.era)): base = per_era[str(gs.era)]
	var pezzi := PackedStringArray()
	if int(base.get("pietra", 0)) > 0: pezzi.append("%d %s" % [int(base["pietra"]), "Costruzione" if _v2() else "pietra"])
	if int(base.get("oro", 0)) > 0: pezzi.append("%d %s" % [int(base["oro"]), "Denaro" if _v2() else "oro"])
	if int(base.get("idee", 0)) > 0: pezzi.append("%d Idee" % int(base["idee"]))
	out.append("Colonna %d · %s" % [col, t_id.capitalize()])
	out.append("produce " + (", ".join(pezzi) if not pezzi.is_empty() else "niente") + " in quest'era")
	if str(tess.get("rule", "")) != "": out.append(str(tess["rule"]))
	if EraRules.tessere_una_volta(gs):
		out.append("tessera girata: l'effetto torna nell'era prossima" if not EraRules.tessera_disponibile(gs, col)
			else "effetto ancora da usare in quest'era")
	return out

func _risorse_testo(pr: Dictionary) -> String:
	var pezzi := PackedStringArray()
	if int(pr.get("pietra", 0)) > 0: pezzi.append("%d Costruzione" % int(pr["pietra"]))
	if int(pr.get("oro", 0)) > 0: pezzi.append("%d Denaro" % int(pr["oro"]))
	if int(pr.get("idee", 0)) > 0: pezzi.append("%d Idee" % int(pr["idee"]))
	return ", ".join(pezzi) if not pezzi.is_empty() else "niente"

# ---- il clic ---------------------------------------------------------
func _clic(pixel: Vector2) -> void:
	# I tasti della schermata valgono sempre - anche a partita finita, che e'
	# proprio quando "Nuova partita" serve - quindi si provano per primi.
	for b in _bottoni:
		if b.has("scelta") and (b["rect"] as Rect2).has_point(pixel):
			_applica_scelta(b["scelta"])
			return
	if ctl == null: return
	var gs := ctl.gs
	if gs.phase == Enums.Phase.FINE_PARTITA: return
	# Una scelta in sospeso viene prima di tutto: finche' non e' risolta il
	# gioco non prosegue, quindi il clic serve solo a quella.
	if not gs.pending_choice.is_empty():
		if int(gs.pending_choice["player"]) != _io(): return
		# IL DRAFT (v2, registro 93 e 102): le opzioni sono posizioni nella
		# fila dei Personaggi, e si sceglie cliccando la carta nella fila.
		# Le altre scelte (l'edificio dove infilare una carta) si fanno
		# cliccando l'edificio.
		if str(gs.pending_choice.get("kind", "")) == "draft":
			var c := _carta_puntata(pixel)
			if c.is_empty() or str(c["kind"]) != "personaggio": return
			var posto := gs.char_row.find(str(c["id"]))
			if posto < 0 or not posto in (gs.pending_choice["options"] as Array):
				_messaggio = "Questo Personaggio non si puo' prendere ora."
				_aggiorna()
				return
			var nome := str(CardDB.characters[str(c["id"])]["name"])
			if _racconta(func(): return ctl.choose(posto)):
				_messaggio = "Hai preso %s." % nome
				_turni_dei_bot()
				_aggiorna()
			return
		# LA SCELTA DELL'EDIFICIO (v3, registro 170): le opzioni sono uid di
		# edifici della colonna, e si sceglie cliccandone uno (o un tasto).
		var scelto := _edificio_puntato(pixel)
		if scelto != null and str(gs.pending_choice.get("kind", "")) == "edificio" \
				and not scelto.uid in (gs.pending_choice["options"] as Array):
			_messaggio = "%s non si puo' usare ora: non e' in colonna, non ha un'azione o e' gia' stato usato in questo giro." % str(scelto.data["name"])
			_aggiorna()
			return
		if scelto != null and _racconta(func(): return ctl.choose(scelto.uid)):
			_messaggio = "Scelto." if str(gs.pending_choice.get("kind", "")) != "" else "Hai usato %s." % str(scelto.data["name"])
			_turni_dei_bot()
			_aggiorna()
		return
	if _io() < 0: return

	# V3: un clic su un proprio Personaggio ancora da piazzare lo sceglie come
	# prossimo lavoratore (il piazzamento resta il clic sulla colonna o sul
	# posto acceso).
	if _v3() and gs.phase == Enums.Phase.PIAZZA:
		var cp := _carta_puntata(pixel)
		if not cp.is_empty() and str(cp["kind"]) == "personaggio" and cp.has("player") \
				and int(cp["player"]) == _io() and str(cp["id"]) in ctl.personaggi_liberi(gs.players[_io()]):
			_scegli_personaggio(str(cp["id"]))
			return

	# I pulsanti delle azioni che non hanno una carta sul tavolo.
	for b in _bottoni:
		if (b["rect"] as Rect2).has_point(pixel):
			_deseleziona(false)
			if str(b.get("modo", "")) == "restauro":
				_scegli_restauro()
			else:
				_esegui(b["voce"])
			return

	# Col bersaglio gia' acceso, il clic sul posto acceso esegue - e se il
	# lavoratore non e' ancora piazzato lo piazza lui, nella colonna giusta.
	if not _scelta.is_empty() and _prova_bersaglio(pixel): return

	# Poi la scelta di una carta. Viene PRIMA del piazzamento: la carta si
	# sceglie senza aver ancora messo il lavoratore, ed e' il punto di tutto
	# il giro - prima si decide cosa, poi dove.
	var c := _carta_puntata(pixel)
	if not c.is_empty():
		_seleziona(c)
		return

	# CON UNA CARTA SCELTA, un clic fuori dai posti accesi non fa niente. Non
	# e' pignoleria: prima piazzava un lavoratore di nascosto, e il giocatore
	# si ritrovava una colonna attivata che non aveva chiesto - e con meno
	# posti accesi di prima, perche' il lavoratore li aveva ristretti a
	# quella colonna. Sembrava che la carta non si comprasse mai.
	if not _scelta.is_empty():
		_messaggio = "Li' non ci va. Clicca un posto acceso, o Esc per cambiare carta."
		_aggiorna()
		return

	# Senza carta scelta, il clic su una colonna mette il lavoratore e basta:
	# si attiva la colonna per la produzione anche senza fare azioni.
	if gs.phase == Enums.Phase.PIAZZA:
		_piazza_lavoratore(pixel)
		return
	_deseleziona()

# "Sopra un vostro edificio ancora in piedi": abitare da' +2 resistenza.
func _da_abitare(col: int) -> Building:
	for b in ctl.gs.grid.in_column(col):
		if b.owner == _io() and b.is_standing(): return b
	return null

func _piazza_in_colonna(col: int) -> void:
	var chi := _lavoratore()
	if _racconta(func(): return ctl.place_worker(col, _da_abitare(col), chi)):
		_messaggio = _dopo_piazzamento(col, chi)
	else:
		_messaggio = "Non puoi piazzare un lavoratore nella colonna %d." % (col + 1)
	_aggiorna()

func _piazza_lavoratore(pixel: Vector2) -> void:
	var col := _colonna_puntata(pixel)
	if col < 0: return
	var chi := _lavoratore()
	if _racconta(func(): return ctl.place_worker(col, _da_abitare(col), chi)):
		_messaggio = _dopo_piazzamento(col, chi)
	else:
		_messaggio = "Non puoi piazzare un lavoratore nella colonna %d." % (col + 1)
	_aggiorna()

# Il messaggio dopo il piazzamento: con la domanda "quale edificio usi?" in
# sospeso si dice quella, se no si invita a comprare.
func _dopo_piazzamento(col: int, chi: String) -> String:
	var con := "" if chi == "" else " con %s" % _nome_personaggio(chi)
	if str(ctl.gs.pending_choice.get("kind", "")) == "edificio":
		return "Colonna %d attivata%s: scegli quale edificio usare." % [col + 1, con]
	return "Colonna %d attivata%s: ora puoi costruire o potenziare, oppure Fine turno." % [col + 1, con]

# V3: il Personaggio scelto per il prossimo piazzamento.
func _scegli_personaggio(cid: String) -> void:
	_personaggio_scelto = cid
	var d: Dictionary = CardDB.characters.get(cid, {})
	_messaggio = "Piazzerai %s (%s): clicca una colonna, o una carta e poi un posto acceso." % [
		_nome_personaggio(cid), str(d.get("effect_text", ""))]
	_aggiorna()

# Il clic e' caduto su un bersaglio acceso? Allora l'azione si fa.
# I riquadri accesi SONO i riquadri cliccabili: si prova il raggio contro gli
# stessi rettangoli che la vista disegna, invece di risalire alla colonna dal
# piano del tavolo. Cosi' un posto in alto - costruire sopra una rovina,
# spianare un proprio edificio - si clicca dove lo si vede, e non serve piu'
# nessun tasto da tenere premuto.
func _prova_bersaglio(pixel: Vector2) -> bool:
	var v := _bersaglio_sotto(pixel)
	if v == null: return false
	_esegui(v)
	return true

# Il bersaglio acceso sotto quel pixel, null se il mouse e' altrove. Lo
# chiedono in due: il clic per eseguirlo, la barra di stato per dire cosa
# sarebbe. E' la stessa domanda, quindi e' la stessa funzione: non puo'
# succedere che la barra annunci una mossa e il clic ne faccia un'altra.
func _bersaglio_sotto(pixel: Vector2) -> AvailableActions.Voce:
	if ctl == null or _bersagli.is_empty(): return null
	if get_viewport().get_camera_3d() == null: return null
	var b := _edificio_puntato(pixel)
	if b != null:
		for v in _bersagli:
			if int(v.parametri.get("uid", -1)) == b.uid: return v
	var riquadri: Array = []
	var voci: Array = []
	for v in _bersagli:
		if not v.parametri.has("col_from"): continue
		var d: Dictionary = CardDB.buildings[str(v.parametri["card_id"])]
		riquadri.append(BoardLayout3D.box_piazzamento(ctl.gs,
			int(v.parametri["col_from"]), int(d["width"]),
			int(v.parametri.get("level", 0)), ctl.gs.era,
			int(v.parametri.get("binario", 0)), int(d.get("depth", 1))))
		voci.append(v)
	var i := BoardLayout3D.riquadro_al_raggio(riquadri, _origine(pixel), _direzione(pixel))
	return voci[i] if i >= 0 else null

# Le colonne dove il lavoratore puo' ancora andare. Sono quelle che aprono
# un'azione: se la carta si sceglie PRIMA di piazzare, i posti da accendere
# sono quelli raggiungibili da una qualsiasi di queste.
func _colonne_possibili() -> Array[int]:
	var out: Array[int] = []
	var p: PlayerState = ctl.gs.players[_io()]
	if p.workers_used >= p.workers: return out
	for c in ctl.gs.grid.n_cols:
		if c in p.worker_cols: continue     # "un solo vostro lavoratore per colonna"
		out.append(c)
	return out

func _voci_per(kind: String, id: String, col: int) -> Array:
	match kind:
		"mercato": return AvailableActions.piazzamenti(ctl.gs, _io(), col, id)
		"potenziamento": return AvailableActions.bersagli_potenziamento(ctl.gs, _io(), col, id)
		"personaggio": return AvailableActions.bersagli_reclutamento(ctl.gs, _io(), col, id)
	return []

# I bersagli di una carta. Se il lavoratore e' gia' piazzato valgono solo
# quelli della colonna attivata; se non lo e' ancora si guardano TUTTE le
# colonne dove potrebbe andare, e ogni bersaglio si porta dietro la colonna
# da attivare per raggiungerlo.
#
# Si puo' fare perche' AvailableActions e' pura e prende la colonna come
# parametro: si interroga per una colonna ipotetica senza attivarla davvero.
# E la legalita' non dipende dalle risorse - quelle contano nel `pagabile` -
# quindi chiedere prima o dopo l'attivazione da' la stessa risposta.
func _bersagli_di(kind: String, id: String) -> Array:
	if ctl.gs.phase != Enums.Phase.PIAZZA:
		return _voci_per(kind, id, ctl.colonna_attivata())
	var out: Array = []
	var visti := {}
	for c in _colonne_possibili():
		for v in _voci_per(kind, id, c):
			# La stessa posizione si raggiunge da piu' colonne: si tiene la
			# prima, e la colonna da attivare viaggia con lei.
			var chiave: String = "%s|%s|%s" % [v.parametri.get("col_from", -1),
				v.parametri.get("level", 0), v.parametri.get("uid", -1)]
			if visti.has(chiave): continue
			visti[chiave] = true
			v.parametri["attiva"] = c
			out.append(v)
	return out

func _seleziona(c: Dictionary) -> void:
	# Le carte gia' davanti a un giocatore non si scelgono: sono il suo
	# mazzetto, non il mercato. Senza questo, cliccare una propria carta
	# accendeva i posti e poi la costruzione veniva rifiutata, perche' quella
	# carta dal mercato era gia' uscita.
	if c.has("player"):
		_deseleziona()
		return
	var kind := str(c["kind"])
	var id := str(c["id"])
	if str(_scelta.get("kind", "")) == kind and str(_scelta.get("id", "")) == id:
		_deseleziona()
		return
	if not (kind in ["mercato", "potenziamento", "personaggio"]):
		_deseleziona()
		return
	var voci: Array = _bersagli_di(kind, id)
	# Un personaggio senza bersaglio da scegliere non ha niente da accendere:
	# si recluta e basta, e chiedere un secondo clic sarebbe finto.
	if voci.size() == 1 and not voci[0].parametri.has("uid") \
			and not voci[0].parametri.has("col_from"):
		_esegui(voci[0])
		return
	if voci.is_empty():
		_messaggio = "%s: nessun posto dove metterla adesso." % _nome_carta(kind, id)
		_deseleziona()
		return
	_scelta = {"kind": kind, "id": id}
	_bersagli = voci
	_messaggio = "%s: scegli dove." % _nome_carta(kind, id)
	_aggiorna()

func _scegli_restauro() -> void:
	var voci := AvailableActions.restauri(ctl.gs, _io(), ctl.colonna_attivata())
	var buoni: Array = []
	for v in voci:
		if v.legale: buoni.append(v)
	if buoni.is_empty():
		_messaggio = "Nessuna tua rovina da ristrutturare in questa colonna." \
			if BoardLayout3D.senza_rudere() else "Nessun rudere da restaurare in questa colonna."
		_aggiorna()
		return
	_scelta = {"kind": "restauro", "id": "restauro"}
	_bersagli = buoni
	_messaggio = "Ristrutturazione: scegli la rovina." \
		if BoardLayout3D.senza_rudere() else "Restauro: scegli il rudere."
	_aggiorna()

func _deseleziona(ridisegna := true) -> void:
	_scelta = {}
	_bersagli = []
	_sotto_mouse = null
	if ridisegna: _aggiorna()

func _nome_carta(kind: String, id: String) -> String:
	match kind:
		"mercato": return str(CardDB.buildings[id]["name"])
		"personaggio": return str(CardDB.characters[id]["name"])
		"potenziamento": return str(CardDB.upgrades[id]["name"])
		"monumento":
			return str(CardDB.monuments[id]["name"]) if CardDB.monuments.has(id) else id
		"scheletro": return "scheletro"
	return id

func _esegui(v) -> void:
	# La mossa si racconta da sola (registro 146); i bot muovono dopo, e
	# ognuno ha la sua voce nella cronaca.
	_racconta(func(): _esegui_mossa(v))
	# V3: con la domanda "quale edificio usi?" in sospeso la carta resta scelta.
	if str(ctl.gs.pending_choice.get("kind", "")) != "edificio": _deseleziona(false)
	_turni_dei_bot()
	_aggiorna()

func _esegui_mossa(v) -> void:
	var fatto := false
	_messaggio = ""
	# La carta si sceglie prima del lavoratore: il lavoratore lo piazza il
	# clic sul bersaglio, nella colonna che quel bersaglio richiede. Cosi' il
	# giocatore decide "questo edificio, li'" invece di dover indovinare
	# prima quale colonna gli aprira' la carta che vuole.
	if ctl.gs.phase == Enums.Phase.PIAZZA and v.parametri.has("attiva"):
		var dove := int(v.parametri["attiva"])
		var chi := _lavoratore()
		if not ctl.place_worker(dove, _da_abitare(dove), chi):
			_messaggio = "Non puoi piazzare un lavoratore nella colonna %d." % (dove + 1)
			return
		_messaggio = "Colonna %d attivata%s. " % [dove + 1, "" if chi == "" else " con " + _nome_personaggio(chi)]
		# V3: se il gioco chiede quale edificio usare, la mossa aspetta la
		# risposta; la carta scelta resta scelta e si eseguira' al prossimo clic.
		if str(ctl.gs.pending_choice.get("kind", "")) == "edificio":
			_messaggio += "Prima scegli quale edificio usare, poi la mossa."
			return
	match v.tipo:
		"costruisci":
			fatto = ctl.build(str(v.parametri["card_id"]), int(v.parametri["col_from"]),
				bool(v.parametri["above"]), 0, null, int(v.parametri.get("binario", 0)))
		"potenzia":
			fatto = ctl.upgrade(str(v.parametri["upg_id"]), _edificio(int(v.parametri.get("uid", -1))))
		"restaura":
			fatto = ctl.restore(_edificio(int(v.parametri["uid"])))
		"recluta":
			fatto = ctl.recruit(str(v.parametri["char_id"]), _edificio(int(v.parametri.get("uid", -1))))
		"dinastia":
			fatto = ctl.buy_dynasty()
		"passa":
			ctl.pass_action()
			fatto = true
	_messaggio += v.etichetta if fatto else "Rifiutata: %s" % v.etichetta

# ---- quel poco che resta a schermo ------------------------------------
const SFONDO := Color(0.09, 0.10, 0.13, 0.86)
const CHIARO := Color("#e8e6df")
const SPENTO := Color("#8b919c")
# Solo per il conto che non torna: e' l'unica cosa in tutta la barra che
# dice "questa mossa e' permessa ma non te la puoi permettere".
const ROSSO := Color("#e8795f")

func _riquadro(font: Font, righe: PackedStringArray, dove: Vector2,
		larghezza := 340.0) -> void:
	var alto := 14.0 + righe.size() * 19.0
	var r := Rect2(dove, Vector2(larghezza, alto))
	var schermo := _hud.get_viewport_rect().size
	if r.end.x > schermo.x - 8.0: r.position.x = schermo.x - 8.0 - r.size.x
	if r.end.y > schermo.y - 8.0: r.position.y = schermo.y - 8.0 - r.size.y
	_hud.draw_rect(r, SFONDO, true)
	_hud.draw_rect(r, Color(1, 1, 1, 0.16), false, 1.0)
	var y := r.position.y + 21.0
	for i in righe.size():
		_hud.draw_string(font, Vector2(r.position.x + 10.0, y), righe[i],
			HORIZONTAL_ALIGNMENT_LEFT, r.size.x - 20.0, 14 if i == 0 else 12,
			CHIARO if i == 0 else SPENTO)
		y += 19.0

func _disegna_hud() -> void:
	var font: Font = ThemeDB.fallback_font
	_bottoni = []
	if ctl == null:
		_disegna_scelta(font)
		return
	var gs := ctl.gs
	var v := _in_vetrina()
	var p: PlayerState = gs.players[v]

	# Di chi e' il turno, col suo colore. Giocando a turno sullo stesso
	# schermo e' la prima cosa da sapere, e il colore e' lo stesso delle
	# basette sul tavolo.
	var chi := "giocatore %d" % v
	if _io() >= 0:
		chi = "tu" if inizio.umani() <= 1 else "tocca a te, giocatore %d" % v
	var risorse := "%d pietra, %d oro" % [p.pietra, p.oro]
	if _v2(): risorse = "%d Costruzione, %d Denaro, %d Idee" % [p.pietra, p.oro, p.idee]
	var testa := "Era %d · %s · %s: %d PV, %s, lavoratori %d/%d" % [
		gs.era, str(gs.current_event.get("name", "nessun evento")), chi,
		p.vp, risorse, p.workers_used, p.workers]
	# V3: lo sconto, il Lampo e l'acquisto in piu' valgono solo in questo turno.
	if _v3():
		if p.sconto_turno > 0: testa += " · sconto %d%s" % [p.sconto_turno, "" if p.sconto_se == "" else " (" + p.sconto_se + ")"]
		if p.lampo_turno > 0: testa += " · Lampo +%d" % p.lampo_turno
		if p.extra_turno > 0 or gs.acquisto_extra_aperto: testa += " · acquisto in piu'"
	# Le classi per la Continuita' (registro 139): edifici in piedi e carte
	# restituite, contati per classe, al posto del mazzetto davanti al
	# giocatore.
	if TessereScavo.carte_restituite() and CardDB.constants.has("continuita_collezione"):
		var classi := Scoring.classi_di(gs, v)
		var pezzi := PackedStringArray()
		for c in classi: pezzi.append("%s %d" % [str(c).capitalize(), int(classi[c])])
		if not pezzi.is_empty(): testa += " · classi: " + ", ".join(pezzi)
	# I token riscattati dalle proprie rovine (registro 131), col loro valore
	# di fine partita.
	if not p.potenziamenti_riscattati.is_empty():
		var valore := 0
		for u in p.potenziamenti_riscattati: valore += TessereScavo.costo(u)
		testa += ", token riscattati %d (%d PV)" % [p.potenziamenti_riscattati.size(), valore]
	_striscia(font, testa, 41.0, 12.0, 18)
	_hud.draw_rect(Rect2(Vector2(20, 17), Vector2(13, 13)),
		VISTA.colore_giocatore(v), true)
	_hud.draw_string(font, Vector2(41, 30), testa,
		HORIZONTAL_ALIGNMENT_LEFT, -1, 18, CHIARO)

	# Col mouse su un posto acceso la barra smette di dare istruzioni e dice
	# che mossa sarebbe e quanto costa: i riquadri accesi si somigliano tutti,
	# e questo e' l'ultimo momento in cui si puo' cambiare idea gratis.
	if _sotto_mouse != null:
		_riga_azione(font, _sotto_mouse, p)
	else:
		var invito := _invito(gs)
		_striscia(font, invito, 20.0, 39.0, 14)
		_hud.draw_string(font, Vector2(20, 54), invito,
			HORIZONTAL_ALIGNMENT_LEFT, -1, 14, SPENTO)

	if gs.phase == Enums.Phase.AZIONE and _io() >= 0 \
			and gs.pending_choice.is_empty():
		_disegna_bottoni(font, p)
	# REGISTRO 146: col lavoratore ancora da piazzare, un tasto per colonna
	# che si puo' attivare. E' la mossa che c'e' sempre, anche quando nessuna
	# carta ha un posto valido.
	if gs.phase == Enums.Phase.PIAZZA and _io() >= 0 and gs.pending_choice.is_empty():
		_disegna_attiva_colonne(font, p)
		if _v3(): _disegna_personaggi(font, p)
	if not _scelta.is_empty() and _io() >= 0:
		var schermo_a := _hud.get_viewport_rect().size
		_tasto(font, "Annulla la scelta", Vector2(20.0, schermo_a.y - 96.0), false, {"che": "annulla"}, 170.0)
	var kind := str(gs.pending_choice.get("kind", ""))
	var con_tasti := kind in ["tessera", "edificio"] and int(gs.pending_choice.get("player", -1)) == _io()
	_disegna_cronaca(font, 116.0 if con_tasti else 82.0)
	# La scelta di una tessera dell'era: un tasto per opzione, sotto l'invito.
	if kind == "tessera" and con_tasti:
		var tx := 20.0
		var etichette: Array = gs.pending_choice.get("etichette", [])
		for i in etichette.size():
			var r := _tasto(font, str(etichette[i]), Vector2(tx, 72.0), i == 0,
				{"che": "scelta_tessera", "n": i})
			tx = r.end.x + 10.0
	# V3, "quale edificio usi?": un tasto per edificio, col nome e l'azione.
	if kind == "edificio" and con_tasti:
		var tx := 20.0
		var opzioni: Array = gs.pending_choice.get("options", [])
		for i in opzioni.size():
			var b := _edificio(int(opzioni[i]))
			if b == null: continue
			var testo := "%s%s: %s" % [str(b.data["name"]), "" if b.owner == _io() else " (G%d)" % b.owner,
				str(b.data.get("effect_text", "")).trim_prefix("Usa: ")]
			var r := _tasto(font, testo, Vector2(tx, 72.0), i == 0, {"che": "scelta_edificio", "n": int(opzioni[i])})
			tx = r.end.x + 10.0

	var schermo := _hud.get_viewport_rect().size
	# Finita la partita si tira la somma. Il tasto per rifarne un'altra sta
	# li' dentro: senza, bisognava ricaricare la pagina.
	if gs.phase == Enums.Phase.FINE_PARTITA:
		if _riepilogo_aperto:
			_disegna_riepilogo(font, gs)
		else:
			_tasto(font, "Riepilogo", Vector2(20.0, schermo.y - 58.0), true,
				{"che": "riepilogo"}, 150.0)
			_tasto(font, "Nuova partita", Vector2(186.0, schermo.y - 58.0), false,
				{"che": "menu"}, 150.0)
	# La velocita' dei bot si cambia anche a partita iniziata: un tasto solo
	# che gira fra i cinque modi, perche' in fondo allo schermo per cinque
	# nomi non c'e' posto.
	if inizio.bot > 0 and gs.phase != Enums.Phase.FINE_PARTITA:
		var t := _tasto(font, "Bot: " + inizio.nome_velocita(),
			Vector2(schermo.x - 190.0, schermo.y - 58.0), false,
			{"che": "gira_velocita"}, 170.0)
		if inizio.bot_a_mano() and bot_da_muovere():
			_tasto(font, "Avanza", Vector2(t.position.x - 118.0, t.position.y),
				true, {"che": "avanza"}, 110.0)
	_hud.draw_string(font, Vector2(20, schermo.y - 16),
		"Trascina per girare il tabellone · rotella per avvicinare · "
		+ "tasto destro per spostare · R riporta l'inquadratura",
		HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("#6f7683"))

	if not _nota.is_empty():
		_riquadro(font, _nota, _nota_dove + Vector2(18, 18))

# Che mossa sarebbe cliccare qui, e quanto costa. Il conto che non torna esce
# in coda e in rosso: il posto resta acceso perche' la mossa e' permessa, ed
# e' il prezzo a non essere alla portata - sono due cose diverse e il
# giocatore deve vederle diverse.
func _riga_azione(font: Font, v: AvailableActions.Voce, p: PlayerState) -> void:
	var riga := DescrizioneAzione.riga(ctl.gs, v, _io())
	var manca := DescrizioneAzione.ammanco(v, p)
	if manca != "": manca = "  ·  " + manca
	_striscia(font, riga + manca, 20.0, 39.0, 14)
	_hud.draw_string(font, Vector2(20, 54), riga, HORIZONTAL_ALIGNMENT_LEFT, -1, 14, CHIARO)
	if manca == "": return
	var x := 20.0 + font.get_string_size(riga, HORIZONTAL_ALIGNMENT_LEFT, -1, 14).x
	_hud.draw_string(font, Vector2(x, 54), manca,
		HORIZONTAL_ALIGNMENT_LEFT, -1, 14, ROSSO)

# La riga di stato cade sul cielo dipinto, che e' chiaro: senza una striscia
# scura sotto, meta' frase si perde fra le nuvole. Larga quanto il testo e
# non quanto lo schermo, per non coprire il tabellone piu' del necessario.
func _striscia(font: Font, testo: String, sx: float, cima: float,
		corpo: int) -> void:
	var largo := font.get_string_size(testo, HORIZONTAL_ALIGNMENT_LEFT, -1, corpo).x
	_hud.draw_rect(Rect2(Vector2(12.0, cima),
		Vector2(sx - 12.0 + largo + 12.0, corpo + 8.0)), SFONDO, true)

# Cosa il gioco si aspetta adesso, quando il mouse non e' su niente.
func _invito(gs: GameState) -> String:
	var invito := ""
	if gs.phase == Enums.Phase.FINE_PARTITA:
		invito = "Partita finita. Vincitore: giocatore %d" % Scoring.winner(gs)
	elif _io() < 0:
		invito = "Tocca al giocatore %d" % gs.current_index
		if inizio.bot_a_mano(): invito += " — premi Avanza per farlo muovere"
	elif not gs.pending_choice.is_empty():
		invito = str(gs.pending_choice["prompt"])
		if str(gs.pending_choice.get("kind", "")) == "draft":
			invito += " — clicca una carta della fila dei Personaggi: e' gratis"
			if _v3(): invito += "; la fila e' la tua mano, le altre passano al vicino"
		elif str(gs.pending_choice.get("kind", "")) == "tessera":
			invito += " — scegli qui sotto"
		elif str(gs.pending_choice.get("kind", "")) == "edificio":
			invito += " — clicca l'edificio sul tavolo, o un tasto qui sotto"
		else:
			invito += " — clicca l'edificio"
	elif gs.acquisto_extra_aperto and _v3():
		invito = "Acquisto in piu': un potenziamento%s, oppure Fine turno." % (
			"" if gs.extra_solo_potenziamenti else " o una casa della riserva")
	elif gs.phase == Enums.Phase.PIAZZA:
		invito = "Scegli una carta e ti mostro dove puoi metterla, "
		invito += "oppure clicca una colonna per attivarla e basta."
		if _v3() and _lavoratore() != "":
			invito = "Piazzi %s. " % _nome_personaggio(_lavoratore()) + invito
	elif _scelta.is_empty():
		invito = "Clicca una carta per vedere dove puoi metterla."
	else:
		invito = "Clicca un posto acceso. Esc per lasciar perdere."
	if _messaggio != "": invito += "     — " + _messaggio
	return invito

# ---- il riepilogo finale ---------------------------------------------
# Alla fine restava un numero solo - "vincitore: giocatore 3" - e non si
# capiva DOVE fossero andati i punti. Il motore li divide gia' per canale
# mentre la partita va avanti: qui si mettono in tabella, in ordine di
# arrivo. Le eredita' segrete a questo punto sono scoperte sul tavolo, quindi
# in fondo si dice quale era ciascuna.

# LA LENTE (registro 140). Il designer, sull'iPad: "il menu iniziale e il
# resoconto finale sono troppo piccoli e non si legge nulla". I due pannelli
# si disegnano alla loro misura e poi si ingrandiscono fino a riempire buona
# parte dello schermo; i tasti si registrano gia' ingranditi, cosi' il tocco
# cade dove si vede.
var _lente := Transform2D.IDENTITY

func _metti_lente(largo: float, alto: float) -> Rect2:
	var schermo := _hud.get_viewport_rect().size
	# Anche sotto 1 (registro 145): il riepilogo in due parti e' piu' alto di
	# uno schermo da 900, e un pannello tagliato non si legge comunque.
	var k := clampf(minf(schermo.x * 0.9 / largo, schermo.y * 0.94 / alto), 0.6, 2.6)
	var origine := Vector2((schermo.x - largo * k) / 2.0, (schermo.y - alto * k) / 2.0)
	_lente = Transform2D(0.0, Vector2(k, k), 0.0, origine)
	_hud.draw_set_transform_matrix(_lente)
	return Rect2(Vector2.ZERO, Vector2(largo, alto))

func _togli_lente() -> void:
	_lente = Transform2D.IDENTITY
	_hud.draw_set_transform_matrix(_lente)

func _disegna_riepilogo(font: Font, gs: GameState) -> void:
	_disegna_riepilogo_dentro(font, gs)
	_togli_lente()

# IL RIEPILOGO GIRATO (registro 144). Il designer: "i giocatori in alto e
# ogni riga indica i punti vittoria divisi per categoria, e sotto in basso il
# totale". Prima ogni giocatore era una riga e le voci colonne strette da 86
# px, coi nomi tagliati; ora le voci sono righe con il loro nome intero, e
# sotto ognuna le sottovoci che dicono da dove vengono i punti (i premi di
# scavo, le tessere, gli scheletri, l'arte...).
const RIEP_VOCE := 210.0      # la colonna dei nomi delle voci
const RIEP_GIOC := 160.0      # una colonna per giocatore
const RIEP_RIGA := 26.0
const RIEP_SOTTO := 20.0

func _disegna_riepilogo_dentro(font: Font, gs: GameState) -> void:
	var righe := Riepilogo.righe(gs)
	# Le righe della tabella, prima di disegnarle: servono per l'altezza. Due
	# parti (registro 145): in alto i PV presi giocando, in basso quelli del
	# conto finale, ognuna col suo subtotale.
	var voci: Array[Dictionary] = []
	for fine in [false, true]:
		voci.append({"id": "_titolo", "nome": "A fine partita" if fine else "Durante il gioco",
			"sotto": false, "voce": "", "fine": fine})
		for c in Riepilogo.colonne_fase(gs, righe, fine):
			var id := str(c["id"])
			voci.append({"id": id, "nome": str(c["nome"]), "sotto": false, "voce": "", "fine": fine})
			for v in Riepilogo.sottovoci_fase(righe, id, fine):
				voci.append({"id": id, "nome": Riepilogo.nome_voce(v), "sotto": true, "voce": v, "fine": fine})
		voci.append({"id": "_parziale", "nome": "totale a fine partita" if fine else "totale in gioco",
			"sotto": false, "voce": "", "fine": fine})
	var resti := false
	for riga in righe:
		if Riepilogo.altro(gs, riga) != 0: resti = true
	if resti: voci.append({"id": "_altro", "nome": "altro", "sotto": false, "voce": "", "fine": true})
	var alto_voci := 0.0
	var prima_sotto := false
	for v in voci:
		if not bool(v["sotto"]) and prima_sotto: alto_voci += 6.0
		alto_voci += RIEP_SOTTO if bool(v["sotto"]) else RIEP_RIGA
		if str(v["id"]) == "_titolo": alto_voci += 4.0
		if str(v["id"]) == "_parziale": alto_voci += 8.0
		prima_sotto = bool(v["sotto"])
	var largo: float = RIEP_VOCE + righe.size() * RIEP_GIOC + 48.0
	var alto: float = 46.0 + 36.0 + 44.0 + alto_voci + 14.0 + 34.0 + 44.0 + 64.0
	var r := _metti_lente(largo, alto)
	_hud.draw_rect(r, Color(0.07, 0.08, 0.10, 1.0), true)
	_hud.draw_rect(r, Color(1, 1, 1, 0.18), false, 1.0)
	var x := r.position.x + 24.0
	var y := r.position.y + 46.0
	_hud.draw_string(font, Vector2(x, y), "Riepilogo finale",
		HORIZONTAL_ALIGNMENT_LEFT, -1, 24, CHIARO)
	# Il seme, come promemoria (registro 178): con lo stesso seme la partita si
	# rigioca uguale, e un difetto visto al tavolo si racconta col suo numero.
	_hud.draw_string(font, Vector2(x, y), promemoria_seme(),
		HORIZONTAL_ALIGNMENT_RIGHT, r.size.x - 48.0, 13, SPENTO)
	y += 36.0

	# In alto i giocatori, in ordine di arrivo: posto, colore e nome, e sotto
	# la testa del bot. I numeri stanno allineati a destra sotto il nome.
	var x0 := x + RIEP_VOCE
	for j in righe.size():
		var pl := int(righe[j]["player"])
		var cx := x0 + j * RIEP_GIOC
		_hud.draw_rect(Rect2(Vector2(cx + RIEP_GIOC - 22.0, y - 11.0), Vector2(11, 11)),
			VISTA.colore_giocatore(pl), true)
		var nome := "tu" if inizio.e_umano(pl) and inizio.umani() <= 1 else "giocatore %d" % pl
		_hud.draw_string(font, Vector2(cx, y), "%d. %s" % [int(righe[j]["posto"]), nome],
			HORIZONTAL_ALIGNMENT_RIGHT, RIEP_GIOC - 28.0, 13, CHIARO)
		if not inizio.e_umano(pl):
			_hud.draw_string(font, Vector2(cx, y + 17.0), "bot · %s" % inizio.nome_strategia(pl),
				HORIZONTAL_ALIGNMENT_RIGHT, RIEP_GIOC - 10.0, 11, SPENTO)
	y += 30.0
	_hud.draw_line(Vector2(x, y), Vector2(r.end.x - 24.0, y), Color(1, 1, 1, 0.15), 1.0)
	y += 14.0 + RIEP_RIGA - 8.0

	var era_sotto := false
	for v in voci:
		var sotto := bool(v["sotto"])
		var id := str(v["id"])
		var fine := bool(v["fine"])
		if not sotto and era_sotto: y += 6.0
		era_sotto = sotto
		if id == "_titolo":
			# Il titolo della parte: piccolo, in maiuscolo, color oro.
			y += 4.0
			_hud.draw_string(font, Vector2(x, y), str(v["nome"]).to_upper(),
				HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("#c9a24a"))
			y += RIEP_RIGA
			continue
		if id == "_parziale":
			_hud.draw_line(Vector2(x + RIEP_VOCE - 40.0, y - 16.0), Vector2(r.end.x - 24.0, y - 16.0),
				Color(1, 1, 1, 0.10), 1.0)
		var corpo := 12 if sotto else 14
		_hud.draw_string(font, Vector2(x + (18.0 if sotto else 0.0), y), str(v["nome"]),
			HORIZONTAL_ALIGNMENT_LEFT, RIEP_VOCE - 24.0, corpo,
			SPENTO if sotto or id == "_parziale" else CHIARO)
		for j in righe.size():
			var n: int
			if id == "_altro": n = Riepilogo.altro(gs, righe[j])
			elif id == "_parziale":
				n = 0
				for c in Riepilogo.colonne(gs): n += Riepilogo.punti_fase(righe[j], str(c["id"]), fine)
			elif sotto: n = Riepilogo.punti_voce_fase(righe[j], id, str(v["voce"]), fine)
			else: n = Riepilogo.punti_fase(righe[j], id, fine)
			# Lo zero si scrive come un trattino: una colonna di zeri veri
			# nasconde i numeri che contano.
			var colore := (SPENTO if sotto else CHIARO) if n != 0 else Color("#5b616c")
			_hud.draw_string(font, Vector2(x0 + j * RIEP_GIOC, y), str(n) if n != 0 else "–",
				HORIZONTAL_ALIGNMENT_RIGHT, RIEP_GIOC - 10.0, corpo, colore)
		y += RIEP_SOTTO if sotto else RIEP_RIGA
		if id == "_parziale": y += 8.0

	# In fondo il totale, e sotto l'eredita' segreta e gli edifici in piedi.
	y += 2.0
	_hud.draw_line(Vector2(x, y - 14.0), Vector2(r.end.x - 24.0, y - 14.0), Color(1, 1, 1, 0.15), 1.0)
	y += 10.0
	_hud.draw_string(font, Vector2(x, y), "Totale", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, CHIARO)
	for j in righe.size():
		_hud.draw_string(font, Vector2(x0 + j * RIEP_GIOC, y), str(int(righe[j]["vp"])),
			HORIZONTAL_ALIGNMENT_RIGHT, RIEP_GIOC - 10.0, 20, CHIARO)
	y += 26.0
	_hud.draw_string(font, Vector2(x, y), "eredita' segreta", HORIZONTAL_ALIGNMENT_LEFT,
		RIEP_VOCE - 24.0, 12, SPENTO)
	for j in righe.size():
		var ered := str(righe[j]["eredita_nome"])
		_hud.draw_string(font, Vector2(x0 + j * RIEP_GIOC, y), ered if ered != "" else "nessuna",
			HORIZONTAL_ALIGNMENT_RIGHT, RIEP_GIOC - 10.0, 12, SPENTO)
	y += RIEP_SOTTO
	_hud.draw_string(font, Vector2(x, y), "edifici in piedi", HORIZONTAL_ALIGNMENT_LEFT,
		RIEP_VOCE - 24.0, 12, SPENTO)
	for j in righe.size():
		_hud.draw_string(font, Vector2(x0 + j * RIEP_GIOC, y), str(int(righe[j]["edifici"])),
			HORIZONTAL_ALIGNMENT_RIGHT, RIEP_GIOC - 10.0, 12, SPENTO)

	var t := _tasto(font, "Nuova partita", Vector2(x, r.end.y - 48.0), true,
		{"che": "menu"}, 150.0)
	_tasto(font, "Guarda il tavolo", Vector2(t.end.x + 10.0, t.position.y),
		false, {"che": "tavolo"}, 160.0)

# "seme 1234 · v3 · 3 giocatori": la riga che il riepilogo mette in alto a destra.
func promemoria_seme() -> String:
	return "seme %d · %s · %d giocatori" % [inizio.seme, inizio.nome_regolamento(), inizio.giocatori]

# Il nome senza la strategia, per la colonna stretta del riepilogo.
func _nome_corto(i: int) -> String:
	if not inizio.e_umano(i): return "giocatore %d (bot)" % i
	return _nome_giocatore(i)

func _nome_giocatore(i: int) -> String:
	# Il bot dice anche che testa ha: guardarlo giocare senza sapere cosa
	# insegue e' come guardare qualcuno muovere pezzi a caso.
	if not inizio.e_umano(i): return "giocatore %d (bot · %s)" % [i, inizio.nome_strategia(i)]
	return "tu" if inizio.umani() <= 1 else "giocatore %d" % i

# ---- la schermata d'inizio -------------------------------------------
# Prima la partita cominciava da sola: tre giocatori e seme 7, scritti nel
# codice. Per provarne altri bisognava ricompilare, e in due o in quattro non
# ci si giocava affatto.
#
# I posti sono in ordine - prima gli umani, poi i bot - quindi chi gioca da
# solo e' sempre il giocatore 0 e sa dove guardare. Con piu' umani si gioca a
# turno sullo stesso schermo; con zero si guarda giocare.
const SCELTA_LARGO := 680.0
const SCELTA_ALTO := 296.0
const RIGA_ALTA := 46.0

func _disegna_scelta(font: Font) -> void:
	_disegna_scelta_dentro(font)
	_togli_lente()

func _disegna_scelta_dentro(font: Font) -> void:
	# Il pannello cresce con la riga della velocita', che c'e' solo se al
	# tavolo siede almeno un bot.
	var alto := SCELTA_ALTO + RIGA_ALTA + (RIGA_ALTA if inizio.bot > 0 else 0.0)
	var r := _metti_lente(SCELTA_LARGO, alto)
	_hud.draw_rect(r, SFONDO, true)
	_hud.draw_rect(r, Color(1, 1, 1, 0.18), false, 1.0)
	var x := r.position.x + 28.0
	var y := r.position.y + 46.0
	_hud.draw_string(font, Vector2(x, y), "La Strada delle Ere",
		HORIZONTAL_ALIGNMENT_LEFT, -1, 26, CHIARO)
	y += 40.0

	# Il regolamento per primo: e' la scelta che cambia tutto il resto.
	_hud.draw_string(font, Vector2(x, y + 20.0), "Regolamento",
		HORIZONTAL_ALIGNMENT_LEFT, -1, 14, SPENTO)
	var rx := x + 130.0
	for i in ScelteInizio.REGOLAMENTI.size():
		var t := _tasto(font, str(ScelteInizio.REGOLAMENTI[i]["nome"]),
			Vector2(rx, y), i == inizio.regolamento, {"che": "regolamento", "n": i}, 60.0)
		rx += t.size.x + 8.0
	_hud.draw_string(font, Vector2(rx + 8.0, y + 20.0), inizio.descrizione_regolamento(),
		HORIZONTAL_ALIGNMENT_LEFT, SCELTA_LARGO - (rx + 8.0 - r.position.x) - 20.0, 12, Color("#6f7683"))
	y += RIGA_ALTA
	y = _riga_scelta(font, "Giocatori", x, y,
		range(ScelteInizio.MIN_GIOCATORI, ScelteInizio.MAX_GIOCATORI + 1),
		inizio.giocatori, "giocatori")
	y = _riga_scelta(font, "di cui bot", x, y,
		range(0, inizio.giocatori + 1), inizio.bot, "bot")
	if inizio.bot > 0:
		y = _riga_velocita(font, x, y)

	# Il seme resta in vista e si puo' cambiare: tutto il progetto e'
	# deterministico, quindi con lo stesso numero si rigioca la stessa
	# partita - e un difetto si racconta col suo seme.
	_hud.draw_string(font, Vector2(x, y + 20.0), "Seme %d" % inizio.seme,
		HORIZONTAL_ALIGNMENT_LEFT, -1, 14, SPENTO)
	_tasto(font, "cambia", Vector2(x + 130.0, y), false, {"che": "seme"})
	y += 50.0

	var via := _tasto(font, "Comincia", Vector2(x, y), true, {"che": "via"}, 150.0)
	_hud.draw_string(font, Vector2(via.end.x + 16.0, y + 20.0),
		inizio.descrizione(), HORIZONTAL_ALIGNMENT_LEFT, -1, 14, SPENTO)
	var coda := "I posti sono in ordine: prima gli umani, poi i bot. "
	coda += "Invio per cominciare."
	if inizio.umani() == 0:
		# Senza nessun umano i bot giocano tutto in un colpo: meglio dirlo
		# prima, o il tavolo gia' finito sembra un difetto.
		coda = "Senza umani la partita si gioca da sola: "
		coda += "vedrai il tavolo gia' finito." if inizio.bot_subito() \
			else "la guardi e basta, alla velocita' che hai scelto."
	_hud.draw_string(font, Vector2(x, r.end.y - 18.0), coda,
		HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("#6f7683"))

# La velocita' dei bot: i nomi al posto dei numeri, ma e' la stessa riga.
func _riga_velocita(font: Font, x: float, y: float) -> float:
	_hud.draw_string(font, Vector2(x, y + 20.0), "che si muovono",
		HORIZONTAL_ALIGNMENT_LEFT, -1, 14, SPENTO)
	var bx := x + 130.0
	for i in ScelteInizio.VELOCITA.size():
		var t := _tasto(font, str(ScelteInizio.VELOCITA[i]["nome"]),
			Vector2(bx, y), i == inizio.velocita, {"che": "velocita", "n": i})
		bx += t.size.x + 8.0
	return y + RIGA_ALTA

# Una riga di scelta: l'etichetta e i numeri, quello scelto acceso.
func _riga_scelta(font: Font, etichetta: String, x: float, y: float,
		numeri, scelto: int, che: String) -> float:
	_hud.draw_string(font, Vector2(x, y + 20.0), etichetta,
		HORIZONTAL_ALIGNMENT_LEFT, -1, 14, SPENTO)
	var bx := x + 130.0
	for n in numeri:
		var t := _tasto(font, str(n), Vector2(bx, y), n == scelto,
			{"che": che, "n": n}, 40.0)
		bx += t.size.x + 8.0
	return y + RIGA_ALTA

# Un tasto: lo disegna e lo mette fra quelli cliccabili. `dato` e' quello che
# il clic eseguira', cosi' il disegno e il clic non possono divergere.
func _tasto(font: Font, testo: String, dove: Vector2, acceso: bool,
		dato: Dictionary, minimo := 0.0) -> Rect2:
	var largo := maxf(minimo,
		font.get_string_size(testo, HORIZONTAL_ALIGNMENT_LEFT, -1, 14).x + 24.0)
	var r := Rect2(dove, Vector2(largo, 32.0))
	_hud.draw_rect(r, Color(1, 1, 1, 0.12) if acceso else Color(0, 0, 0, 0.25), true)
	_hud.draw_rect(r, Color(1, 1, 1, 0.55 if acceso else 0.20), false, 1.0)
	var m := font.get_string_size(testo, HORIZONTAL_ALIGNMENT_LEFT, -1, 14).x
	_hud.draw_string(font, r.position + Vector2((largo - m) / 2.0, 21.0), testo,
		HORIZONTAL_ALIGNMENT_LEFT, -1, 14, CHIARO if acceso else SPENTO)
	# Il tasto si registra dove si vede: con la lente, ingrandito.
	_bottoni.append({"rect": Rect2(_lente * r.position, r.size * _lente.get_scale()), "scelta": dato})
	return r

func _applica_scelta(d: Dictionary) -> void:
	match str(d["che"]):
		"giocatori": inizio.con_giocatori(int(d["n"]))
		"bot": inizio.con_bot(int(d["n"]))
		"seme": inizio.rimescola()
		"velocita": inizio.con_velocita(int(d["n"]))
		"regolamento": inizio.con_regolamento(int(d["n"]))
		"gira_velocita": inizio.velocita_dopo()
		"riepilogo": _riepilogo_aperto = true
		"tavolo": _riepilogo_aperto = false
		"avanza":
			muovi_un_bot()
			return
		"scelta_tessera":
			if ctl != null and _racconta(func(): return ctl.choose(int(d["n"]))):
				_messaggio = "Fatto."
				_aggiorna()
			return
		"scelta_edificio":
			if ctl != null:
				var b := _edificio(int(d["n"]))
				if _racconta(func(): return ctl.choose(int(d["n"]))):
					_messaggio = "Hai usato %s." % (str(b.data["name"]) if b != null else "l'edificio")
					_turni_dei_bot()
					_aggiorna()
			return
		"personaggio":
			if ctl != null: _scegli_personaggio(str(d["id"]))
			return
		"via":
			comincia()
			return
		# REGISTRO 146: attivare una colonna e basta, con un tasto. Sull'iPad
		# il clic sulla colonna poteva cadere su un edificio o su una carta,
		# e con una carta scelta senza posti validi non c'era Esc: restava
		# solo Passa, e la colonna non si attivava.
		"attiva_colonna":
			_deseleziona(false)
			_piazza_in_colonna(int(d["n"]))
			_turni_dei_bot()
			return
		"annulla":
			_deseleziona()
			_messaggio = "Scelta annullata."
			_aggiorna()
			return
		"menu":
			torna_alla_scelta()
			return
	_hud.queue_redraw()

# I tasti "attiva la colonna N": numero e terreno, uno per colonna libera.
func _disegna_attiva_colonne(font: Font, p: PlayerState) -> void:
	var schermo := _hud.get_viewport_rect().size
	var y := schermo.y - 58.0
	_hud.draw_string(font, Vector2(20.0, y + 20.0), "Attiva e incassa:",
		HORIZONTAL_ALIGNMENT_LEFT, -1, 14, SPENTO)
	var x := 150.0
	if p.workers_used >= p.workers: return
	for c in ctl.gs.grid.n_cols:
		if c in p.worker_cols: continue
		var r := _tasto(font, "%d %s" % [c + 1, Cronaca._terreno(ctl.gs, c)], Vector2(x, y),
			false, {"che": "attiva_colonna", "n": c})
		x = r.end.x + 8.0

# V3: i Personaggi ancora da piazzare, un tasto ciascuno sopra la riga delle
# colonne; quello che il prossimo piazzamento usera' e' acceso.
func _disegna_personaggi(font: Font, p: PlayerState) -> void:
	var liberi: Array[String] = ctl.personaggi_liberi(p)
	if liberi.is_empty(): return
	var schermo := _hud.get_viewport_rect().size
	var y := schermo.y - 58.0 - 38.0
	_hud.draw_string(font, Vector2(20.0, y + 20.0), "Piazza:",
		HORIZONTAL_ALIGNMENT_LEFT, -1, 14, SPENTO)
	var x := 150.0
	var scelto := _lavoratore()
	for cid in liberi:
		var r := _tasto(font, _nome_personaggio(cid), Vector2(x, y), cid == scelto,
			{"che": "personaggio", "id": cid})
		x = r.end.x + 8.0

# La cronaca sotto la barra: la mossa piu' recente per intero, le altre una
# riga sola. Le proprie in chiaro, quelle degli altri spente.
func _disegna_cronaca(font: Font, cima: float) -> void:
	var y := cima
	var righe_max := 9
	for k in _cronaca.size():
		var voce: Dictionary = _cronaca[k]
		var righe: Array = voce["righe"]
		var quante: int = righe.size() if k == 0 else 1
		for j in mini(quante, righe_max):
			var testo := str(righe[j])
			var corpo := 13 if j == 0 else 12
			_striscia(font, testo, 20.0, y - corpo - 2.0, corpo)
			_hud.draw_string(font, Vector2(20.0 if j == 0 else 34.0, y), testo,
				HORIZONTAL_ALIGNMENT_LEFT, -1, corpo,
				CHIARO if bool(voce["mia"]) and k == 0 else SPENTO)
			y += corpo + 8.0
			righe_max -= 1
		if righe_max <= 0: break
		if k == 0: y += 6.0

# Le azioni che non hanno una carta da cliccare sul tavolo. Sono tre, e stanno
# in un angolo: non e' piu' un menu, e' quello che avanza.
func _disegna_bottoni(font: Font, p: PlayerState) -> void:
	var schermo := _hud.get_viewport_rect().size
	var voci: Array = []
	var din := AvailableActions.dinastia(ctl.gs, _io())
	voci.append({"voce": din, "testo": "Dinastia  " + DescrizioneAzione.prezzo(din),
		"attiva": din.legale and din.pagabile(p)})
	# Con le carte restituite non si ristruttura (registro 131): niente tasto.
	if not TessereScavo.carte_restituite():
		var restauri := AvailableActions.restauri(ctl.gs, _io(), ctl.colonna_attivata())
		var quanti := 0
		for r in restauri:
			if r.legale: quanti += 1
		voci.append({"voce": null, "modo": "restauro",
			"testo": "%s  (%d)" % [DescrizioneAzione.verbo_restauro(), quanti], "attiva": quanti > 0})
	var tutte := AvailableActions.tutte(ctl.gs, _io(), ctl.colonna_attivata())
	# "Passa" sembrava rinunciare al turno: la colonna e' gia' attivata e
	# incassata, e questo tasto chiude il turno senza un'azione.
	voci.append({"voce": tutte[tutte.size() - 1], "testo": "Fine turno", "attiva": true})

	var y := schermo.y - 58.0
	var x := 20.0
	for v in voci:
		var largo := font.get_string_size(str(v["testo"]), HORIZONTAL_ALIGNMENT_LEFT,
			-1, 14).x + 24.0
		var r := Rect2(Vector2(x, y), Vector2(largo, 28.0))
		_hud.draw_rect(r, SFONDO, true)
		_hud.draw_rect(r, Color(1, 1, 1, 0.22 if bool(v["attiva"]) else 0.08), false, 1.0)
		_hud.draw_string(font, r.position + Vector2(12, 19), str(v["testo"]),
			HORIZONTAL_ALIGNMENT_LEFT, -1, 14,
			CHIARO if bool(v["attiva"]) else SPENTO)
		if bool(v["attiva"]):
			var b := {"rect": r, "voce": v["voce"]}
			if v.has("modo"): b["modo"] = v["modo"]
			_bottoni.append(b)
		x += largo + 10.0
