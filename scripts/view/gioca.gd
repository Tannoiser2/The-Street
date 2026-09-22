# res://scripts/view/gioca.gd
# La plancia giocabile: tu sei il giocatore 0, gli altri li gioca il bot.
# Ogni modifica passa dal GameController, mai da qui: questo script legge lo
# stato, mostra le opzioni e chiama i comandi.
extends Node3D

const UMANO := 0

var ctl: GameController
var vista: Node3D
var _menu: Control
var _voci: Array = []                # AvailableActions.Voce mostrate ora
var _righe: Array[Rect2] = []        # i loro riquadri, per il clic
var _colonna_sotto_mouse := -1
var _messaggio := ""

func _ready() -> void:
	ctl = GameController.new()
	ctl.new_game(3, 7)
	vista = preload("res://scripts/view/board_view_3d.gd").new()
	add_child(vista)
	vista.scale = Vector3.ONE * BoardLayout3D.U
	var strato := CanvasLayer.new()
	add_child(strato)
	_menu = Control.new()
	_menu.set_anchors_preset(Control.PRESET_FULL_RECT)
	_menu.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_menu.draw.connect(_disegna_menu)
	strato.add_child(_menu)
	_turni_dei_bot()
	_aggiorna()

func _aggiorna() -> void:
	vista.mostra(ctl.gs, _colonna_sotto_mouse)
	vista.scale = Vector3.ONE * BoardLayout3D.U
	_menu.queue_redraw()

# Il bot gioca finche' non tocca all'umano.
func _turni_dei_bot() -> void:
	var giri := 0
	while ctl.gs.phase != Enums.Phase.FINE_PARTITA \
			and ctl.gs.current_index != UMANO and giri < 500:
		RandomBot.play_turn(ctl)
		giri += 1

# ---- input ----------------------------------------------------------
func _unhandled_input(evento: InputEvent) -> void:
	if evento is InputEventMouseMotion:
		var c := _colonna_puntata(evento.position)
		if c != _colonna_sotto_mouse:
			_colonna_sotto_mouse = c
			_aggiorna()
	elif evento is InputEventMouseButton and evento.pressed \
			and evento.button_index == MOUSE_BUTTON_LEFT:
		_clic(evento.position)

# Dal pixel allo slot: si costruisce il raggio della telecamera e si chiede a
# BoardLayout3D dove cade. La stessa geometria che disegna.
func _colonna_puntata(pixel: Vector2) -> int:
	var cam := get_viewport().get_camera_3d()
	if cam == null: return -1
	var o := cam.project_ray_origin(pixel) / BoardLayout3D.U
	var d := cam.project_ray_normal(pixel)
	var slot := BoardLayout3D.slot_at_ray(ctl.gs, o, d)
	return int(slot.get("col", -1)) if not slot.is_empty() else -1

func _carta_puntata(pixel: Vector2) -> Dictionary:
	var cam := get_viewport().get_camera_3d()
	if cam == null: return {}
	var o := cam.project_ray_origin(pixel) / BoardLayout3D.U
	return BoardLayout3D.card_at_ray(ctl.gs, o, cam.project_ray_normal(pixel))

func _descrivi(c: Dictionary) -> String:
	var id := str(c["id"])
	match str(c["kind"]):
		"mercato":
			var d: Dictionary = CardDB.buildings[id]
			var co: Dictionary = d["cost"]
			return "%s — %dp %do · res %d · scavo %d · %s" % [d["name"],
				int(co.get("pietra", 0)), int(co.get("oro", 0)),
				int(d["resistance"]), int(d["scavo"]), ", ".join(d["classes"])]
		"personaggio":
			var pe: Dictionary = CardDB.characters[id]
			return "%s (%s) — %s" % [pe["name"], pe["class"], pe.get("effect_text", "")]
		"potenziamento":
			var po: Dictionary = CardDB.upgrades[id]
			return "%s (%s) — %s" % [po["name"], po["family"], po.get("effect_text", "")]
		"monumento":
			if CardDB.monuments.has(id):
				var mo: Dictionary = CardDB.monuments[id]
				return "%s — %s" % [mo["name"], mo.get("effect_text", "")]
	return id

func _clic(pixel: Vector2) -> void:
	if ctl.gs.phase == Enums.Phase.FINE_PARTITA: return
	if ctl.gs.current_index != UMANO: return
	# Prima il menu: se il clic cade su una voce, quella vince sul tabellone.
	for i in _righe.size():
		if _righe[i].has_point(pixel):
			_esegui(_voci[i])
			return
	# Poi le carte delle file: cliccarne una la descrive, cosi' si puo'
	# guardare cosa c'e' in mercato senza dover chiudere il menu.
	var carta := _carta_puntata(pixel)
	if not carta.is_empty():
		_messaggio = _descrivi(carta)
		_aggiorna()
		return
	if ctl.gs.phase == Enums.Phase.PIAZZA:
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

func _esegui(v) -> void:
	var gs := ctl.gs
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
	_turni_dei_bot()
	_aggiorna()

func _edificio(uid: int) -> Building:
	if uid < 0: return null
	for b in ctl.gs.grid.buildings:
		if b.uid == uid: return b
	return null

# ---- il menu ---------------------------------------------------------
func _disegna_menu() -> void:
	var font: Font = ThemeDB.fallback_font
	var gs := ctl.gs
	var p: PlayerState = gs.players[UMANO]
	_voci = []
	_righe = []

	var testa := "Era %d · %s · tu: %d PV, %d pietra, %d oro, lavoratori %d/%d" % [
		gs.era, str(gs.current_event.get("name", "nessun evento")),
		p.vp, p.pietra, p.oro, p.workers_used, p.workers]
	_menu.draw_string(font, Vector2(20, 30), testa, HORIZONTAL_ALIGNMENT_LEFT, -1, 18,
		Color("#e8e6df"))

	var invito := ""
	if gs.phase == Enums.Phase.FINE_PARTITA:
		invito = "Partita finita. Vincitore: giocatore %d" % Scoring.winner(gs)
	elif gs.current_index != UMANO:
		invito = "Tocca al giocatore %d" % gs.current_index
	elif gs.phase == Enums.Phase.PIAZZA:
		invito = "Clicca una colonna per piazzare un lavoratore e attivarla."
	else:
		invito = "Scegli un'azione (e' facoltativa)."
	if _messaggio != "": invito += "     — " + _messaggio
	_menu.draw_string(font, Vector2(20, 54), invito, HORIZONTAL_ALIGNMENT_LEFT, -1, 14,
		Color("#9aa0ad"))

	if gs.phase != Enums.Phase.AZIONE or gs.current_index != UMANO: return
	var col := ctl.colonna_attivata()
	_voci = AvailableActions.tutte(gs, UMANO, col)
	var y := 90.0
	for v in _voci:
		var r := Rect2(Vector2(20, y), Vector2(560, 22))
		_righe.append(r)
		var colore := Color("#7c828e")          # illegale
		var testo: String = v.etichetta
		if v.legale:
			if v.pietra + v.oro > 0: testo += "  —  %dp %do" % [v.pietra, v.oro]
			colore = Color("#e8e6df") if v.pagabile(p) else Color("#c98f3c")
			if not v.pagabile(p): testo += "   (risorse insufficienti)"
		elif v.motivo != "":
			testo += "  —  " + v.motivo
		_menu.draw_rect(r, Color(1, 1, 1, 0.05), true)
		_menu.draw_string(font, r.position + Vector2(8, 16), testo,
			HORIZONTAL_ALIGNMENT_LEFT, r.size.x - 12, 13, colore)
		y += 25.0
