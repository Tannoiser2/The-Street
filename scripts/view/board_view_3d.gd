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
# La telecamera che il giocatore puo' girare. Se non c'e', si usa
# l'inquadratura calcolata da BoardLayout3D e basta.
var orbita: CameraOrbita = null
var _cam: Camera3D = null

func mostra(stato: GameState, colonna_evidenziata := -1) -> void:
	gs = stato
	_evidenziata = colonna_evidenziata
	for f in get_children(): f.queue_free()
	_tavolo()
	_cielo()
	_tessere()
	_file_laterali()
	_plance()
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
	var t := BoardLayout3D.table_aabb_piatto(gs)
	var piano := _quad(Vector2(t.size.x + 700.0, t.size.z + 900.0), TAVOLO, false)
	piano.rotate_x(-PI / 2.0)
	piano.position = Vector3(t.position.x + t.size.x / 2.0, -1.0,
		t.position.z + t.size.z / 2.0)
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
		_linguette(b)
		_cubetti(b)
		_segnalini(b)

# Il piede che tiene in piedi il cartone: 15 mm di profondita' sui 54 dello
# slot, cosi' il resto resta scoperto e le file dietro si vedono.
func _basetta(b: Building) -> void:
	var box := BoardLayout3D.basetta_box(gs, b)
	# Col disegno sopra, il colore del giocatore non ha piu' dove stare: va
	# sulla basetta, che e' esattamente cio' che sul tavolo vero distingue
	# due copie della stessa sagoma.
	var m := _scatola(box.size, COLORI_GIOCATORE[b.owner % COLORI_GIOCATORE.size()].darkened(0.15))
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
	# L'illustrazione vera, se c'e': il cartone e' sottile, quindi un piano con
	# la texture e non una scatola. Senza le immagini - assets/ si rigenera e
	# non e' versionata - si ripiega sul rettangolo colorato, cosi' i test e
	# le partite headless non dipendono dalla grafica.
	var tex: Texture2D = _illustrazione(b)
	var m: MeshInstance3D
	if tex != null:
		m = _quad(dim, Color.WHITE)
		var mat := m.material_override as StandardMaterial3D
		mat.albedo_texture = tex
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR
		mat.alpha_scissor_threshold = 0.5
		mat.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
		if b.is_buried: mat.albedo_color = Color(0.62, 0.62, 0.66)
	else:
		m = _scatola(Vector3(dim.x, dim.y, BoardLayout3D.SAGOMA_SPESSORE), col)
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

# L'illustrazione della sagoma, se le immagini sono state estratte.
func _illustrazione(b: Building) -> Texture2D:
	var percorso := BoardLayout3D.sagoma_path(b)
	if percorso == "" or not ResourceLoader.exists(percorso): return null
	return load(percorso) as Texture2D

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
	_cam = Camera3D.new()
	_cam.fov = BoardLayout3D.FOV
	_cam.current = true
	add_child(_cam)
	muovi_telecamera()

# Sposta la sola telecamera, senza ricostruire la scena: e' quello che serve
# mentre si trascina, dove un rebuild a ogni pixel sarebbe uno spreco.
#
# La posa si costruisce nello spazio LOCALE e non con look_at_from_position,
# che in Godot lavora in coordinate GLOBALI. Qui la differenza non e' un
# dettaglio: le misure sono in millimetri e questo nodo e' rimpicciolito di U,
# quindi una posizione globale in millimetri mette la telecamera cento volte
# piu' lontano del tavolo. Il risultato e' una plancia grande come un
# francobollo - che nessun test di geometria vede, perche' i numeri che
# calcolano sono giusti: sbagliato e' lo spazio in cui finiscono.
func muovi_telecamera() -> void:
	if _cam == null: return
	var dove := BoardLayout3D.camera_position(gs)
	var mira := BoardLayout3D.camera_target(gs)
	if orbita != null:
		dove = orbita.posizione()
		mira = orbita.mira
	_cam.transform = Transform3D(Basis(), dove).looking_at(mira, Vector3.UP)
	# Il piano di taglio deve stare dietro al tavolo anche quando si e'
	# allontanato al massimo, altrimenti allontanandosi la citta' sparisce.
	_cam.far = maxf(4000.0, dove.distance_to(mira)
		+ BoardLayout3D.scene_aabb(gs).size.length() * 2.0)

# ---- le file e le plance, sul tavolo --------------------------------
const CARTA_SFONDO := Color("#3a3f4b")
const PLANCIA_SFONDO := Color("#2d323c")

func _file_laterali() -> void:
	for c in BoardLayout3D.side_cards(gs):
		var r: AABB = c["aabb"]
		var m := _scatola(r.size, CARTA_SFONDO)
		m.position = r.position + r.size / 2.0
		add_child(m)
		_scritta(r.position + Vector3(r.size.x / 2.0, 30.0, r.size.z / 2.0),
			_titolo_carta(c), 0.14, Color("#e8e6df"))
		_scritta(r.position + Vector3(r.size.x / 2.0, 16.0, r.size.z / 2.0),
			_dettaglio_carta(c), 0.11, Color("#9aa0ad"))

func _titolo_carta(c: Dictionary) -> String:
	var id := str(c["id"])
	match str(c["kind"]):
		"mercato": return str(CardDB.buildings[id]["name"])
		"personaggio": return str(CardDB.characters[id]["name"])
		"potenziamento": return str(CardDB.upgrades[id]["name"])
		"monumento": return str(CardDB.monuments[id]["name"]) if CardDB.monuments.has(id) else id
	return id

# Il costo e i numeri che servono a decidere: il giocatore non deve girare
# la carta per sapere se se la puo' permettere.
func _dettaglio_carta(c: Dictionary) -> String:
	var id := str(c["id"])
	match str(c["kind"]):
		"mercato":
			var d: Dictionary = CardDB.buildings[id]
			var co: Dictionary = d["cost"]
			return "%dp %do · res %d · scavo %d" % [int(co.get("pietra", 0)),
				int(co.get("oro", 0)), int(d["resistance"]), int(d["scavo"])]
		"personaggio":
			return "personaggio · %s" % CardDB.characters[id]["class"]
		"potenziamento":
			return "potenziamento · %s" % CardDB.upgrades[id]["family"]
		"monumento":
			return "monumento"
	return ""

func _plance() -> void:
	for p in BoardLayout3D.player_boards(gs):
		var r: AABB = p["aabb"]
		var i: int = int(p["player"])
		var ps: PlayerState = gs.players[i]
		var suo: Color = COLORI_GIOCATORE[i % COLORI_GIOCATORE.size()]
		var sfondo := PLANCIA_SFONDO.lerp(suo, 0.22)
		if i == gs.current_index: sfondo = sfondo.lightened(0.18)
		var m := _scatola(r.size, sfondo)
		m.position = r.position + r.size / 2.0
		add_child(m)
		var centro := r.position + Vector3(r.size.x / 2.0, 0.0, r.size.z / 2.0)
		var turno := "  ←" if i == gs.current_index else ""
		_scritta(centro + Vector3(0, 34, 0), "G%d — %d PV%s" % [i, ps.vp, turno], 0.15, suo.lightened(0.5))
		_scritta(centro + Vector3(0, 20, 0),
			"%dp %do · lav %d/%d" % [ps.pietra, ps.oro, ps.workers_used, ps.workers],
			0.12, Color("#c8ccd4"))
		var extra := ""
		if ps.has_dynasty: extra += "Dinastia "
		for cid in ps.specialized_characters:
			extra += "%s " % CardDB.characters[cid]["name"]
		# Gli edifici in piedi e i personaggi sepolti: le "carte possedute"
		# che il brief chiede sulla plancia del giocatore.
		var vivi := 0
		var sepolti := 0
		for b in gs.grid.buildings:
			if b.owner != i: continue
			if b.is_alive(): vivi += 1
			if b.buried_character != "": sepolti += 1
		var riga := "%d edifici" % vivi
		if sepolti > 0: riga += " · %d sepolti" % sepolti
		if extra != "": riga += " · " + extra.strip_edges()
		_scritta(centro + Vector3(0, 8, 0), riga, 0.10, Color("#9aa0ad"))

# I cubetti: bianchi la Vetusta', neri la resistenza guadagnata. Sono i
# segnalini del gioco vero, e sulla basetta si leggono senza girare il
# tabellone - cosa che in 3D non si puo' fare.
const CUBETTO_BIANCO := Color("#e6e3da")
const CUBETTO_NERO := Color("#2b2b30")
const LINGUETTA := Color("#c9a227")

func _cubetti(b: Building) -> void:
	for c in BoardLayout3D.cubetti(gs, b):
		var lato: float = float(c["lato"])
		var m := _scatola(Vector3(lato, lato, lato),
			CUBETTO_BIANCO if str(c["tipo"]) == "vetusta" else CUBETTO_NERO)
		m.position = (c["pos"] as Vector3) + Vector3(0, lato / 2.0, 0)
		add_child(m)

# "Infilate la carta sotto, lasciandone sporgere la linguetta": il
# potenziamento si vede perche' spunta, non perche' sia scritto da qualche
# parte.
func _linguette(b: Building) -> void:
	for p in BoardLayout3D.linguette(gs, b):
		var m := _scatola(Vector3(BoardLayout3D.LINGUETTA_W, 2.0,
			BoardLayout3D.LINGUETTA_D), LINGUETTA)
		m.position = p
		add_child(m)

# Il lavoratore che abita l'edificio e il personaggio sepolto sotto: due cose
# che cambiano il punteggio e che altrimenti non si vedrebbero.
func _segnalini(b: Building) -> void:
	var base := BoardLayout3D.standee_base(gs, b)
	if b.protected_by >= 0:
		var col: Color = COLORI_GIOCATORE[b.protected_by % COLORI_GIOCATORE.size()]
		var lav := _scatola(Vector3(7.0, 20.0, 7.0), col.lightened(0.35))
		lav.position = base + Vector3(-BoardLayout3D.span_w(b.width()) / 2.0 + 5.0,
			BoardLayout3D.BASETTA_Y + 10.0, BoardLayout3D.BASETTA_D / 2.0 - 3.0)
		add_child(lav)
	if b.buried_character != "":
		var sep := _scatola(Vector3(8.0, 8.0, 8.0), Color("#8a6f3a"))
		sep.position = base + Vector3(BoardLayout3D.span_w(b.width()) / 2.0 - 5.0,
			BoardLayout3D.BASETTA_Y + 4.0, BoardLayout3D.BASETTA_D / 2.0 - 3.0)
		add_child(sep)

# Una scritta che guarda sempre la telecamera: le carte sono stese sul tavolo
# e viste di scorcio, quindi il testo stampato sopra non si leggerebbe.
func _scritta(dove: Vector3, testo: String, dimensione: float, colore: Color) -> void:
	if testo == "": return
	var e := Label3D.new()
	e.text = testo
	e.font_size = 64
	e.pixel_size = dimensione
	e.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	e.no_depth_test = true
	e.position = dove
	e.modulate = colore
	e.outline_size = 22
	e.outline_modulate = Color(0, 0, 0, 0.85)
	add_child(e)
