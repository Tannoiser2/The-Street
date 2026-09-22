# res://scripts/view/board_view_3d.gd
# Costruisce la scena 3D della plancia leggendo la geometria da BoardLayout3D.
# Non tocca mai lo stato: lo legge e basta.
extends Node3D

const COLORI_GIOCATORE: Array[Color] = [
	Color("#d9534f"), Color("#4a90d9"), Color("#5cb85c"), Color("#c9a227"),
]
const COLORI_TERRENO: Array[Color] = [
	Color("#9c9069"), Color("#4a7fa0"), Color("#8b7a62"), Color("#4c7049"),
]
const CIELO := Color("#4a76b8")
const TAVOLO := Color("#2b2620")
const BASETTA := Color("#6f6a63")

var gs: GameState
var _evidenziata := -1

func mostra(stato: GameState, colonna_evidenziata := -1) -> void:
	gs = stato
	_evidenziata = colonna_evidenziata
	for f in get_children(): f.queue_free()
	_tavolo()
	_cielo()
	_tessere()
	_edifici()
	_luci()
	_telecamera()

func _quad(dim: Vector2, col: Color, unshaded := false) -> MeshInstance3D:
	var m := MeshInstance3D.new()
	var q := QuadMesh.new()
	q.size = dim
	m.mesh = q
	var mat := StandardMaterial3D.new()
	mat.albedo_color = col
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	if unshaded: mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	m.material_override = mat
	return m

func _scatola(dim: Vector3, col: Color) -> MeshInstance3D:
	var m := MeshInstance3D.new()
	var b := BoxMesh.new()
	b.size = dim
	m.mesh = b
	var mat := StandardMaterial3D.new()
	mat.albedo_color = col
	m.material_override = mat
	return m

func _tavolo() -> void:
	var w := BoardLayout3D.board_w(gs)
	var piano := _quad(Vector2(w + 600.0, BoardLayout3D.board_d() + 900.0), TAVOLO, false)
	piano.rotate_x(-PI / 2.0)
	piano.position = Vector3(w / 2.0, -1.0, BoardLayout3D.board_d() / 2.0)
	add_child(piano)

# Il pannello verticale che fa da cielo. Per ora un colore pieno: al suo posto
# andra' un PNG, e basta cambiare l'albedo in una texture.
func _cielo() -> void:
	var r := BoardLayout3D.sky_rect(gs)
	var p := _quad(Vector2(r.size.x, r.size.y), CIELO, true)
	p.position = r.position + Vector3(r.size.x / 2.0, r.size.y / 2.0, 0.0)
	add_child(p)

func _tessere() -> void:
	for c in gs.grid.n_cols:
		var t: int = gs.grid.terrains[c]
		for era in range(1, BoardLayout3D.RAILS + 1):
			var box := BoardLayout3D.tile_box(c, era)
			var col: Color = COLORI_TERRENO[t].darkened(0.08 * (era - 1))
			# La colonna puntata dal mouse si accende: senza, il giocatore non
			# sa dove sta per cliccare, perche' in prospettiva le colonne non
			# stanno dove sembra.
			if c == _evidenziata: col = col.lightened(0.45)
			var m := _scatola(box.size, col)
			m.position = box.position + box.size / 2.0
			add_child(m)

func _edifici() -> void:
	for b in gs.grid.buildings:
		_basetta(b)
		_sagoma(b)

# Il piede che tiene in piedi il cartone: 15 mm di profondita' sui 54 dello
# slot, cosi' il resto resta scoperto e le file dietro si vedono.
func _basetta(b: Building) -> void:
	var box := BoardLayout3D.basetta_box(gs, b)
	var m := _scatola(box.size, BASETTA)
	m.position = box.position + box.size / 2.0
	add_child(m)

func _sagoma(b: Building) -> void:
	var dim := BoardLayout3D.standee_size(b)
	var col: Color = COLORI_GIOCATORE[b.owner % COLORI_GIOCATORE.size()]
	match b.state:
		Enums.BuildingState.RUDERE: col = col.darkened(0.28)
		Enums.BuildingState.ROVINA: col = col.darkened(0.48)
	# Sepolto: non sparisce - e' la basetta su cui poggia cio' che sta sopra,
	# e lo Scavo finale dipende da lui - ma si spegne, perche' non produce
	# piu' nulla e non subisce piu' eventi.
	if b.is_buried: col = col.darkened(0.15).lerp(Color("#5a5a64"), 0.42)
	var base := BoardLayout3D.standee_base(gs, b)
	var m := _scatola(Vector3(dim.x, dim.y, BoardLayout3D.SAGOMA_SPESSORE), col)
	m.position = base + Vector3(0.0, dim.y / 2.0 + BoardLayout3D.BASETTA_Y, 0.0)
	add_child(m)
	# Il nome va solo a chi si vede dall'alto della propria colonna: la cima.
	# Etichettare tutto riempiva la plancia di scritte accavallate, e le
	# scritte accavallate non si leggono piu' di nessuna.
	if b.is_buried: return
	var in_cima := false
	for c in range(b.col_from, b.col_to):
		if gs.grid.top_of(c) == b:
			in_cima = true
			break
	if not in_cima: return
	var eti := Label3D.new()
	eti.text = str(b.data["name"])
	eti.font_size = 64
	eti.pixel_size = 0.20
	eti.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	eti.no_depth_test = true
	eti.position = base + Vector3(0.0, dim.y + BoardLayout3D.BASETTA_Y + 14.0, 0.0)
	eti.modulate = Color(1, 1, 1, 0.95)
	eti.outline_size = 22
	eti.outline_modulate = Color(0, 0, 0, 0.85)
	add_child(eti)

func _luci() -> void:
	var sole := DirectionalLight3D.new()
	sole.rotation_degrees = Vector3(-48.0, -28.0, 0.0)
	sole.light_energy = 1.1
	add_child(sole)
	var amb := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color("#1b1f27")
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color("#6d7a8c")
	env.ambient_light_energy = 0.85
	amb.environment = env
	add_child(amb)

func _telecamera() -> void:
	var cam := Camera3D.new()
	cam.position = BoardLayout3D.camera_position(gs)
	cam.look_at_from_position(BoardLayout3D.camera_position(gs),
		BoardLayout3D.camera_target(gs), Vector3.UP)
	cam.fov = BoardLayout3D.FOV
	cam.current = true
	add_child(cam)
