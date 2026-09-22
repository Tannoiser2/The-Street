# res://scripts/view/gioca.gd
# La plancia giocabile: tu sei il giocatore 0, gli altri li gioca il bot.
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

const UMANO := 0

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
var _bottoni: Array = []             # {"rect", "voce"} per le azioni senza carta

# Il riquadro che segue il mouse: sostituisce tutte le scritte che prima
# galleggiavano sul tavolo.
var _nota: PackedStringArray = PackedStringArray()
var _nota_dove := Vector2.ZERO

var _orbita: CameraOrbita = null
var _premuto := MOUSE_BUTTON_NONE
var _partenza := Vector2.ZERO
var _trascinato := false

func _ready() -> void:
	ctl = GameController.new()
	ctl.new_game(3, 7)
	vista = preload("res://scripts/view/board_view_3d.gd").new()
	add_child(vista)
	vista.scale = Vector3.ONE * BoardLayout3D.U
	var strato := CanvasLayer.new()
	add_child(strato)
	_hud = Control.new()
	_hud.set_anchors_preset(Control.PRESET_FULL_RECT)
	_hud.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_hud.draw.connect(_disegna_hud)
	strato.add_child(_hud)
	_turni_dei_bot()
	_aggiorna()

func _aggiorna() -> void:
	# Finche' il giocatore non tocca la telecamera, l'inquadratura continua a
	# calcolarsi da sola e arretra man mano che le torri salgono. Appena la
	# muove, comanda lui e nessun aggiornamento gliela riporta indietro.
	if _orbita == null or _orbita.e_iniziale():
		_orbita = CameraOrbita.da_stato(ctl.gs)
		vista.orbita = _orbita
	vista.mostra(ctl.gs, _colonna_sotto_mouse, _acceso())
	vista.scale = Vector3.ONE * BoardLayout3D.U
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
				"width": int(d["width"]), "above": bool(v.parametri.get("above", false))})
		elif v.parametri.has("uid"):
			uid.append(int(v.parametri["uid"]))
	return {"carta": _scelta, "slot": slot, "uid": uid}

# Il bot gioca finche' non tocca all'umano.
func _turni_dei_bot() -> void:
	var giri := 0
	while ctl.gs.phase != Enums.Phase.FINE_PARTITA \
			and ctl.gs.current_index != UMANO and giri < 500:
		RandomBot.play_turn(ctl)
		giri += 1

# ---- input -----------------------------------------------------------
func _unhandled_input(evento: InputEvent) -> void:
	if evento is InputEventMouseButton:
		_pulsante(evento)
	elif evento is InputEventMouseMotion:
		_movimento(evento)
	elif evento is InputEventKey and evento.pressed and not evento.echo:
		if evento.keycode in [KEY_HOME, KEY_R]:
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
	var col := _colonna_puntata(e.position)
	if col != _colonna_sotto_mouse:
		_colonna_sotto_mouse = col
		_aggiorna()
	else:
		_hud.queue_redraw()      # il riquadro segue comunque il mouse

func _zoom(passi: float) -> void:
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
	if get_viewport().get_camera_3d() == null: return -1
	var slot := BoardLayout3D.slot_at_ray(ctl.gs, _origine(pixel), _direzione(pixel))
	return int(slot.get("col", -1)) if not slot.is_empty() else -1

func _carta_puntata(pixel: Vector2) -> Dictionary:
	if get_viewport().get_camera_3d() == null: return {}
	return BoardLayout3D.card_at_ray(ctl.gs, _origine(pixel), _direzione(pixel))

func _edificio_puntato(pixel: Vector2) -> Building:
	if get_viewport().get_camera_3d() == null: return null
	return _edificio(BoardLayout3D.at_ray_building(ctl.gs, _origine(pixel), _direzione(pixel)))

func _edificio(uid: int) -> Building:
	if uid < 0: return null
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
	return out

# ---- il clic ---------------------------------------------------------
func _clic(pixel: Vector2) -> void:
	var gs := ctl.gs
	if gs.phase == Enums.Phase.FINE_PARTITA: return
	# Una scelta in sospeso viene prima di tutto: finche' non e' risolta il
	# gioco non prosegue, quindi il clic serve solo a quella.
	if not gs.pending_choice.is_empty():
		if int(gs.pending_choice["player"]) != UMANO: return
		var scelto := _edificio_puntato(pixel)
		if scelto != null and ctl.choose(scelto.uid):
			_messaggio = "Scelto."
			_turni_dei_bot()
			_aggiorna()
		return
	if gs.current_index != UMANO: return

	# I pulsanti delle azioni che non hanno una carta sul tavolo.
	for b in _bottoni:
		if (b["rect"] as Rect2).has_point(pixel):
			_deseleziona(false)
			if str(b.get("modo", "")) == "restauro":
				_scegli_restauro()
			else:
				_esegui(b["voce"])
			return

	if gs.phase == Enums.Phase.PIAZZA:
		_piazza_lavoratore(pixel)
		return

	# Col bersaglio gia' acceso, il clic sul posto acceso esegue.
	if not _scelta.is_empty() and _prova_bersaglio(pixel): return

	# Altrimenti il clic sceglie una carta.
	var c := _carta_puntata(pixel)
	if not c.is_empty():
		_seleziona(c)
		return
	_deseleziona()

func _piazza_lavoratore(pixel: Vector2) -> void:
	var col := _colonna_puntata(pixel)
	if col < 0: return
	# "Sopra un vostro edificio ancora in piedi": abitare da' +2 resistenza.
	var abita: Building = null
	for b in ctl.gs.grid.in_column(col):
		if b.owner == UMANO and b.is_standing():
			abita = b
			break
	if ctl.place_worker(col, abita):
		_messaggio = "Colonna %d attivata." % col
	else:
		_messaggio = "Non puoi piazzare un lavoratore nella colonna %d." % col
	_aggiorna()

# Il clic e' caduto su un bersaglio acceso? Allora l'azione si fa.
func _prova_bersaglio(pixel: Vector2) -> bool:
	var b := _edificio_puntato(pixel)
	if b != null:
		for v in _bersagli:
			if int(v.parametri.get("uid", -1)) == b.uid:
				_esegui(v)
				return true
	var slot := BoardLayout3D.slot_at_ray(ctl.gs, _origine(pixel), _direzione(pixel))
	if slot.is_empty(): return false
	var col := int(slot["col"])
	# Fra i piazzamenti che coprono questa colonna vince il piu' economico, e
	# a parita' quello a terra: sopra si costruisce apposta, non per sbaglio,
	# e per farlo si tiene premuto Maiusc.
	var sopra := Input.is_key_pressed(KEY_SHIFT)
	var migliore = null
	for v in _bersagli:
		if not v.parametri.has("col_from"): continue
		var c0 := int(v.parametri["col_from"])
		var w := int(CardDB.buildings[str(v.parametri["card_id"])]["width"])
		if col < c0 or col >= c0 + w: continue
		if bool(v.parametri.get("above", false)) != sopra: continue
		if migliore == null or v.pietra + v.oro < migliore.pietra + migliore.oro:
			migliore = v
	if migliore == null: return false
	_esegui(migliore)
	return true

func _seleziona(c: Dictionary) -> void:
	var kind := str(c["kind"])
	var id := str(c["id"])
	if str(_scelta.get("kind", "")) == kind and str(_scelta.get("id", "")) == id:
		_deseleziona()
		return
	var col := ctl.colonna_attivata()
	var voci: Array = []
	match kind:
		"mercato": voci = AvailableActions.piazzamenti(ctl.gs, UMANO, col, id)
		"potenziamento": voci = AvailableActions.bersagli_potenziamento(ctl.gs, UMANO, col, id)
		"personaggio": voci = AvailableActions.bersagli_reclutamento(ctl.gs, UMANO, col, id)
		_:
			_deseleziona()
			return
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
	var voci := AvailableActions.restauri(ctl.gs, UMANO, ctl.colonna_attivata())
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
	_messaggio = v.etichetta if fatto else "Rifiutata: %s" % v.etichetta
	_deseleziona(false)
	_turni_dei_bot()
	_aggiorna()

# ---- quel poco che resta a schermo ------------------------------------
const SFONDO := Color(0.09, 0.10, 0.13, 0.86)
const CHIARO := Color("#e8e6df")
const SPENTO := Color("#8b919c")

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
	var gs := ctl.gs
	var p: PlayerState = gs.players[UMANO]
	_bottoni = []

	_hud.draw_string(font, Vector2(20, 30),
		"Era %d · %s · tu: %d PV, %d pietra, %d oro, lavoratori %d/%d" % [
			gs.era, str(gs.current_event.get("name", "nessun evento")),
			p.vp, p.pietra, p.oro, p.workers_used, p.workers],
		HORIZONTAL_ALIGNMENT_LEFT, -1, 18, CHIARO)

	var invito := ""
	if gs.phase == Enums.Phase.FINE_PARTITA:
		invito = "Partita finita. Vincitore: giocatore %d" % Scoring.winner(gs)
	elif gs.current_index != UMANO:
		invito = "Tocca al giocatore %d" % gs.current_index
	elif not gs.pending_choice.is_empty():
		invito = str(gs.pending_choice["prompt"])
	elif gs.phase == Enums.Phase.PIAZZA:
		invito = "Clicca una colonna per piazzare un lavoratore e attivarla."
	elif _scelta.is_empty():
		invito = "Clicca una carta per vedere dove puoi metterla."
	else:
		invito = "Clicca un posto acceso. Esc per lasciar perdere."
	if _messaggio != "": invito += "     — " + _messaggio
	_hud.draw_string(font, Vector2(20, 54), invito, HORIZONTAL_ALIGNMENT_LEFT, -1, 14, SPENTO)

	if gs.phase == Enums.Phase.AZIONE and gs.current_index == UMANO \
			and gs.pending_choice.is_empty():
		_disegna_bottoni(font, p)

	var schermo := _hud.get_viewport_rect().size
	_hud.draw_string(font, Vector2(20, schermo.y - 16),
		"Trascina per girare il tabellone · rotella per avvicinare · "
		+ "tasto destro per spostare · Maiusc mentre clicchi per costruire sopra · "
		+ "R riporta l'inquadratura",
		HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("#6f7683"))

	if not _nota.is_empty():
		_riquadro(font, _nota, _nota_dove + Vector2(18, 18))

# Le azioni che non hanno una carta da cliccare sul tavolo. Sono tre, e stanno
# in un angolo: non e' piu' un menu, e' quello che avanza.
func _disegna_bottoni(font: Font, p: PlayerState) -> void:
	var schermo := _hud.get_viewport_rect().size
	var voci: Array = []
	var din := AvailableActions.dinastia(ctl.gs, UMANO)
	voci.append({"voce": din, "testo": "Dinastia  %dp %do" % [din.pietra, din.oro],
		"attiva": din.legale and din.pagabile(p)})
	var restauri := AvailableActions.restauri(ctl.gs, UMANO, ctl.colonna_attivata())
	var quanti := 0
	for r in restauri:
		if r.legale: quanti += 1
	voci.append({"voce": null, "modo": "restauro",
		"testo": "Restaura  (%d)" % quanti, "attiva": quanti > 0})
	var tutte := AvailableActions.tutte(ctl.gs, UMANO, ctl.colonna_attivata())
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
