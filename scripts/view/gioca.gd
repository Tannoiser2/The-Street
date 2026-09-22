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
	_messaggio = ""
	_orbita = null
	_colonna_sotto_mouse = -1
	ctl = GameController.new()
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
	if ctl == null:
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
				"width": int(d["width"]), "level": int(v.parametri.get("level", 0))})
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
func muovi_un_bot() -> void:
	if not bot_da_muovere(): return
	RandomBot.play_turn(ctl)
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
		RandomBot.play_turn(ctl)
		giri += 1

# ---- input -----------------------------------------------------------
func _unhandled_input(evento: InputEvent) -> void:
	if evento is InputEventMouseButton:
		_pulsante(evento)
	elif evento is InputEventMouseMotion:
		_movimento(evento)
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
			if e.pressed:
				_premuto = e.button_index
				_partenza = e.position
				_trascinato = false
			else:
				if _premuto == MOUSE_BUTTON_LEFT and not _trascinato:
					_clic(e.position)
				elif _trascinato:
					# Durante la trascinata la scena non si ridisegna: a gesto
					# finito si riallinea quel che sta sotto il mouse.
					_colonna_sotto_mouse = _colonna_puntata(e.position)
					_aggiorna()
				_premuto = MOUSE_BUTTON_NONE

func _movimento(e: InputEventMouseMotion) -> void:
	if ctl == null:
		_nota_dove = e.position
		return
	if _premuto != MOUSE_BUTTON_NONE:
		if not _trascinato \
				and e.position.distance_to(_partenza) < SOGLIA_TRASCINAMENTO:
			return
		_trascinato = true
		if _premuto == MOUSE_BUTTON_LEFT:
			_orbita.ruota(e.relative)
		else:
			_orbita.trasla(e.relative, get_viewport().get_visible_rect().size.y)
		# Si muove la sola telecamera: ricostruire la scena a ogni pixel di
		# trascinamento sarebbe uno spreco e la farebbe scattare.
		vista.muovi_telecamera()
		return
	_nota_dove = e.position
	_nota = _descrivi_sotto(e.position)
	_sotto_mouse = _bersaglio_sotto(e.position)
	var col := _colonna_puntata(e.position)
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
	var out := PackedStringArray()
	var b := _edificio_puntato(pixel)
	if b != null:
		var stato := "intatto"
		match b.state:
			Enums.BuildingState.RUDERE: stato = "rudere"
			Enums.BuildingState.ROVINA: stato = "rovina"
		if b.is_buried: stato += ", sepolto"
		out.append(str(b.data["name"]))
		out.append("G%d · %s · res %d · vetusta %d" % [b.owner, stato,
			b.effective_resistance(), b.vetusta])
		if not b.upgrades.is_empty():
			var nomi := PackedStringArray()
			for u in b.upgrades: nomi.append(str(CardDB.upgrades[u]["name"]))
			out.append("potenziamenti: " + ", ".join(nomi))
		return out
	var c := _carta_puntata(pixel)
	if c.is_empty(): return out
	var id := str(c["id"])
	match str(c["kind"]):
		"mercato":
			var d: Dictionary = CardDB.buildings[id]
			var co: Dictionary = d["cost"]
			out.append(str(d["name"]))
			out.append("%dp %do · res %d · scavo %d · %d slot" % [
				int(co.get("pietra", 0)), int(co.get("oro", 0)),
				int(d["resistance"]), int(d["scavo"]), int(d["width"])])
			out.append(", ".join(d["classes"]))
		"personaggio":
			var pe: Dictionary = CardDB.characters[id]
			out.append(str(pe["name"]))
			out.append("personaggio · %s" % pe["class"])
			if str(pe.get("effect_text", "")) != "": out.append(str(pe["effect_text"]))
		"potenziamento":
			var po: Dictionary = CardDB.upgrades[id]
			out.append(str(po["name"]))
			out.append("potenziamento · %s" % po["family"])
			if str(po.get("effect_text", "")) != "": out.append(str(po["effect_text"]))
		"monumento":
			if CardDB.monuments.has(id):
				var mo: Dictionary = CardDB.monuments[id]
				out.append(str(mo["name"]))
				out.append(str(mo.get("effect_text", "")))
		"dinastia":
			out.append("Dinastia")
		"eredita":
			if CardDB.legacies.has(id):
				var er: Dictionary = CardDB.legacies[id]
				out.append("%s (il tuo obiettivo segreto)" % er["name"])
				out.append(str(er.get("effect_text", "")))
		"eredita_coperta":
			out.append("Obiettivo segreto")
			out.append("coperto: lo vede solo il suo giocatore")
	return out

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
		var scelto := _edificio_puntato(pixel)
		if scelto != null and ctl.choose(scelto.uid):
			_messaggio = "Scelto."
			_turni_dei_bot()
			_aggiorna()
		return
	if _io() < 0: return

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

func _piazza_lavoratore(pixel: Vector2) -> void:
	var col := _colonna_puntata(pixel)
	if col < 0: return
	if ctl.place_worker(col, _da_abitare(col)):
		_messaggio = "Colonna %d attivata." % col
	else:
		_messaggio = "Non puoi piazzare un lavoratore nella colonna %d." % col
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
			int(v.parametri.get("level", 0)), ctl.gs.era))
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
		_messaggio = "Nessun rudere da restaurare in questa colonna."
		_aggiorna()
		return
	_scelta = {"kind": "restauro", "id": "restauro"}
	_bersagli = buoni
	_messaggio = "Restauro: scegli il rudere."
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
	return id

func _esegui(v) -> void:
	var fatto := false
	_messaggio = ""
	# La carta si sceglie prima del lavoratore: il lavoratore lo piazza il
	# clic sul bersaglio, nella colonna che quel bersaglio richiede. Cosi' il
	# giocatore decide "questo edificio, li'" invece di dover indovinare
	# prima quale colonna gli aprira' la carta che vuole.
	if ctl.gs.phase == Enums.Phase.PIAZZA and v.parametri.has("attiva"):
		var dove := int(v.parametri["attiva"])
		if not ctl.place_worker(dove, _da_abitare(dove)):
			_messaggio = "Non puoi piazzare un lavoratore nella colonna %d." % dove
			_deseleziona(false)
			_aggiorna()
			return
		_messaggio = "Colonna %d attivata. " % dove
	match v.tipo:
		"costruisci":
			fatto = ctl.build(str(v.parametri["card_id"]), int(v.parametri["col_from"]),
				bool(v.parametri["above"]))
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
	_deseleziona(false)
	_turni_dei_bot()
	_aggiorna()

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
	var testa := "Era %d · %s · %s: %d PV, %d pietra, %d oro, lavoratori %d/%d" % [
		gs.era, str(gs.current_event.get("name", "nessun evento")), chi,
		p.vp, p.pietra, p.oro, p.workers_used, p.workers]
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
	elif gs.phase == Enums.Phase.PIAZZA:
		invito = "Scegli una carta e ti mostro dove puoi metterla, "
		invito += "oppure clicca una colonna per attivarla e basta."
	elif _scelta.is_empty():
		invito = "Clicca una carta per vedere dove puoi metterla."
	else:
		invito = "Clicca un posto acceso. Esc per lasciar perdere."
	if _messaggio != "": invito += "     — " + _messaggio
	return invito

# ---- il riepilogo finale ---------------------------------------------
# Alla fine restava un numero solo - "vincitore: giocatore 3" - e non si
# capiva DOVE fossero andati i punti. Il motore li divide gia' per canale
# mentre la partita va avanti: qui si mettono in tabella, una riga per
# giocatore e una colonna per fonte, in ordine di arrivo.
# Le eredita' segrete a questo punto sono scoperte sul tavolo, quindi sotto
# ogni riga si dice quale era e quanto ha fruttato.
# 76 non bastavano: "Monumenti" usciva tagliato a meta'. L'intestazione e'
# scritta piccola ma i nomi delle voci sono quelli del regolamento, e
# abbreviarli avrebbe reso la tabella un rebus.
const RIEP_COL := 86.0        # larghezza di una colonna di punti
const RIEP_NOME := 176.0      # la prima colonna: posto, colore, giocatore

func _disegna_riepilogo(font: Font, gs: GameState) -> void:
	var cols := Riepilogo.colonne(gs)
	var righe := Riepilogo.righe(gs)
	var schermo := _hud.get_viewport_rect().size
	var largo: float = minf(RIEP_NOME + (cols.size() + 1) * RIEP_COL + 48.0,
		schermo.x - 40.0)
	var alto := 128.0 + righe.size() * 46.0 + 56.0
	var r := Rect2(Vector2((schermo.x - largo) / 2.0, (schermo.y - alto) / 2.0),
		Vector2(largo, alto))
	# Piu' coperto degli altri pannelli: questo e' una tabella di numeri e ci
	# cadono sotto le carte del tavolo, che la rendevano illeggibile.
	_hud.draw_rect(r, Color(0.07, 0.08, 0.10, 0.97), true)
	_hud.draw_rect(r, Color(1, 1, 1, 0.18), false, 1.0)
	var x := r.position.x + 24.0
	var y := r.position.y + 46.0
	_hud.draw_string(font, Vector2(x, y), "Riepilogo finale",
		HORIZONTAL_ALIGNMENT_LEFT, -1, 24, CHIARO)
	y += 36.0

	# L'intestazione: i nomi delle fonti, allineati a destra come i numeri
	# che stanno sotto, cosi' le cifre si leggono in colonna.
	var cx := x + RIEP_NOME
	for c in cols:
		_hud.draw_string(font, Vector2(cx, y), str(c["nome"]),
			HORIZONTAL_ALIGNMENT_RIGHT, RIEP_COL - 10.0, 12, SPENTO)
		cx += RIEP_COL
	_hud.draw_string(font, Vector2(cx, y), "Totale",
		HORIZONTAL_ALIGNMENT_RIGHT, RIEP_COL - 10.0, 12, CHIARO)
	y += 12.0
	_hud.draw_line(Vector2(x, y), Vector2(r.end.x - 24.0, y),
		Color(1, 1, 1, 0.15), 1.0)
	y += 28.0

	for riga in righe:
		var pl := int(riga["player"])
		_hud.draw_rect(Rect2(Vector2(x, y - 11.0), Vector2(11, 11)),
			VISTA.colore_giocatore(pl), true)
		_hud.draw_string(font, Vector2(x + 20.0, y),
			"%d.  %s" % [int(riga["posto"]), _nome_giocatore(pl)],
			HORIZONTAL_ALIGNMENT_LEFT, RIEP_NOME - 24.0, 14, CHIARO)
		cx = x + RIEP_NOME
		for c in cols:
			var n := Riepilogo.punti(riga, str(c["id"]))
			# Lo zero si scrive come un trattino: una colonna di zeri veri
			# nasconde i numeri che contano.
			_hud.draw_string(font, Vector2(cx, y), str(n) if n != 0 else "–",
				HORIZONTAL_ALIGNMENT_RIGHT, RIEP_COL - 10.0, 14,
				CHIARO if n != 0 else Color("#5b616c"))
			cx += RIEP_COL
		_hud.draw_string(font, Vector2(cx, y), str(int(riga["vp"])),
			HORIZONTAL_ALIGNMENT_RIGHT, RIEP_COL - 10.0, 18, CHIARO)

		# Sotto la riga: l'eredita' segreta, che adesso e' scoperta sul tavolo,
		# e quel che resta fuori dalle colonne.
		var sotto := "nessuna eredita'"
		if str(riga["eredita_nome"]) != "":
			sotto = "eredita': %s · %d" % [riga["eredita_nome"],
				int(riga["eredita_punti"])]
		sotto += " · %d edifici in piedi" % int(riga["edifici"])
		var resto := Riepilogo.altro(gs, riga)
		if resto != 0: sotto += " · altro %d" % resto
		_hud.draw_string(font, Vector2(x + 20.0, y + 17.0), sotto,
			HORIZONTAL_ALIGNMENT_LEFT, largo - 48.0, 12, SPENTO)
		y += 46.0

	var t := _tasto(font, "Nuova partita", Vector2(x, r.end.y - 48.0), true,
		{"che": "menu"}, 150.0)
	_tasto(font, "Guarda il tavolo", Vector2(t.end.x + 10.0, t.position.y),
		false, {"che": "tavolo"}, 160.0)

func _nome_giocatore(i: int) -> String:
	if not inizio.e_umano(i): return "giocatore %d (bot)" % i
	return "tu" if inizio.umani() <= 1 else "giocatore %d" % i

# ---- la schermata d'inizio -------------------------------------------
# Prima la partita cominciava da sola: tre giocatori e seme 7, scritti nel
# codice. Per provarne altri bisognava ricompilare, e in due o in quattro non
# ci si giocava affatto.
#
# I posti sono in ordine - prima gli umani, poi i bot - quindi chi gioca da
# solo e' sempre il giocatore 0 e sa dove guardare. Con piu' umani si gioca a
# turno sullo stesso schermo; con zero si guarda giocare.
const SCELTA_LARGO := 560.0
const SCELTA_ALTO := 296.0
const RIGA_ALTA := 46.0

func _disegna_scelta(font: Font) -> void:
	var schermo := _hud.get_viewport_rect().size
	# Il pannello cresce con la riga della velocita', che c'e' solo se al
	# tavolo siede almeno un bot.
	var alto := SCELTA_ALTO + (RIGA_ALTA if inizio.bot > 0 else 0.0)
	var r := Rect2(Vector2((schermo.x - SCELTA_LARGO) / 2.0,
		(schermo.y - alto) / 2.0), Vector2(SCELTA_LARGO, alto))
	_hud.draw_rect(r, SFONDO, true)
	_hud.draw_rect(r, Color(1, 1, 1, 0.18), false, 1.0)
	var x := r.position.x + 28.0
	var y := r.position.y + 46.0
	_hud.draw_string(font, Vector2(x, y), "La Strada delle Ere",
		HORIZONTAL_ALIGNMENT_LEFT, -1, 26, CHIARO)
	y += 40.0

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
	_bottoni.append({"rect": r, "scelta": dato})
	return r

func _applica_scelta(d: Dictionary) -> void:
	match str(d["che"]):
		"giocatori": inizio.con_giocatori(int(d["n"]))
		"bot": inizio.con_bot(int(d["n"]))
		"seme": inizio.rimescola()
		"velocita": inizio.con_velocita(int(d["n"]))
		"gira_velocita": inizio.velocita_dopo()
		"riepilogo": _riepilogo_aperto = true
		"tavolo": _riepilogo_aperto = false
		"avanza":
			muovi_un_bot()
			return
		"via":
			comincia()
			return
		"menu":
			torna_alla_scelta()
			return
	_hud.queue_redraw()

# Le azioni che non hanno una carta da cliccare sul tavolo. Sono tre, e stanno
# in un angolo: non e' piu' un menu, e' quello che avanza.
func _disegna_bottoni(font: Font, p: PlayerState) -> void:
	var schermo := _hud.get_viewport_rect().size
	var voci: Array = []
	var din := AvailableActions.dinastia(ctl.gs, _io())
	voci.append({"voce": din, "testo": "Dinastia  %dp %do" % [din.pietra, din.oro],
		"attiva": din.legale and din.pagabile(p)})
	var restauri := AvailableActions.restauri(ctl.gs, _io(), ctl.colonna_attivata())
	var quanti := 0
	for r in restauri:
		if r.legale: quanti += 1
	voci.append({"voce": null, "modo": "restauro",
		"testo": "Restaura  (%d)" % quanti, "attiva": quanti > 0})
	var tutte := AvailableActions.tutte(ctl.gs, _io(), ctl.colonna_attivata())
	voci.append({"voce": tutte[tutte.size() - 1], "testo": "Passa", "attiva": true})

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
