# res://scripts/view/board_view_3d.gd
# Costruisce la scena 3D della plancia leggendo la geometria da BoardLayout3D.
# Non tocca mai lo stato: lo legge e basta.
extends Node3D

const COLORI_GIOCATORE: Array[Color] = [
	Color("#d9534f"), Color("#4a90d9"), Color("#5cb85c"), Color("#c9a227"),
]
# Il colore di un giocatore, preso in prestito anche dall'interfaccia: a
# turno sullo stesso schermo, sapere di che colore sei e' la prima cosa.
static func colore_giocatore(i: int) -> Color:
	return COLORI_GIOCATORE[i % COLORI_GIOCATORE.size()]

const COLORI_TERRENO: Array[Color] = [
	Color("#9c9069"), Color("#4a7fa0"), Color("#8b7a62"), Color("#4c7049"),
]
const CIELO := Color("#4a76b8")
const TAVOLO := Color("#2b2620")
const BASETTA := Color("#6f6a63")
const TERRAPIENO := Color("#6e5b41")

var gs: GameState
var _evidenziata := -1
# La telecamera che il giocatore puo' girare. Se non c'e', si usa
# l'inquadratura calcolata da BoardLayout3D e basta.
var orbita: CameraOrbita = null
var _cam: Camera3D = null
# Cosa accendere: la carta scelta, i posti dove si puo' metterla, gli edifici
# che possono riceverla. E' l'interfaccia che lo decide; qui si disegna.
var evidenze: Dictionary = {}
# Chi sta guardando: il suo obiettivo segreto si vede, quello degli altri no.
var umano := -1

func mostra(stato: GameState, colonna_evidenziata := -1, acceso := {}) -> void:
	gs = stato
	_evidenziata = colonna_evidenziata
	evidenze = acceso
	for f in get_children(): f.queue_free()
	_tavolo()
	_cielo()
	_tessere()
	_file_laterali()
	_plance()
	_edifici()
	_posti_liberi()
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
	# Il fondale: largo quanto la fila di tessere e attaccato al loro bordo
	# alto. L'altezza la detta l'immagine, non un numero scelto: si prende il
	# rapporto della texture, cosi' il panorama non si schiaccia.
	var tex: Texture2D = null
	if ResourceLoader.exists(BoardLayout3D.SFONDO_PATH):
		tex = load(BoardLayout3D.SFONDO_PATH) as Texture2D
	var rapporto := BoardLayout3D.CIELO_RAPPORTO
	if tex != null and tex.get_height() > 0:
		rapporto = float(tex.get_width()) / float(tex.get_height())
	var r := BoardLayout3D.sky_rect(gs, rapporto)
	var p := _quad(Vector2(r.size.x, r.size.y), CIELO if tex == null else Color.WHITE, true)
	if tex != null:
		var mat := p.material_override as StandardMaterial3D
		mat.albedo_texture = tex
		mat.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	p.position = r.position + Vector3(r.size.x / 2.0, r.size.y / 2.0, 0.0)
	add_child(p)

# Un velo chiaro steso su un riquadro: e' cosi' che si "accende" qualcosa
# senza coprirne il disegno.
func _velo_su(box: AABB, col: Color, alzo := 1.2) -> void:
	var velo := _quad(Vector2(box.size.x, box.size.z), col, true)
	velo.rotate_x(-PI / 2.0)
	var mat := velo.material_override as StandardMaterial3D
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	velo.position = Vector3(box.position.x + box.size.x / 2.0,
		box.end.y + alzo, box.position.z + box.size.z / 2.0)
	add_child(velo)

# Una CORNICE accesa attorno a un riquadro. Una velatura sola si perdeva
# sopra il disegno della tessera: il bordo pieno si vede anche su una striscia
# di 26 mm, e non copre quello che c'e' dentro.
func _cornice(box: AABB, col: Color, spessore := 5.0) -> void:
	# Dentro solo una velatura, cosi' il disegno della tessera resta
	# leggibile: se il posto acceso coprisse il terreno, per sapere dove si
	# sta costruendo bisognerebbe spegnere l'accensione.
	_velo_su(box, Color(col.r, col.g, col.b, 0.26), 1.4)
	var pieno := Color(col.r, col.g, col.b, 0.95)
	var x0 := box.position.x
	var z0 := box.position.z
	var w := box.size.x
	var d := box.size.z
	var y := box.position.y
	var h := box.size.y
	for lato in [
		AABB(Vector3(x0 - spessore, y, z0 - spessore), Vector3(w + 2.0 * spessore, h, spessore)),
		AABB(Vector3(x0 - spessore, y, z0 + d), Vector3(w + 2.0 * spessore, h, spessore)),
		AABB(Vector3(x0 - spessore, y, z0), Vector3(spessore, h, d)),
		AABB(Vector3(x0 + w, y, z0), Vector3(spessore, h, d)),
	]:
		_velo_su(lato, pieno, 1.7)

func _acceso_carta(c: Dictionary) -> bool:
	var sc: Dictionary = evidenze.get("carta", {})
	return not sc.is_empty() and str(sc.get("kind", "")) == str(c["kind"]) \
		and str(sc.get("id", "")) == str(c["id"])

# I posti dove la carta scelta puo' andare: riquadri accesi sul binario
# dell'era in corso, e un alone attorno agli edifici che possono riceverla.
func _posti_liberi() -> void:
	for pz in evidenze.get("slot", []):
		var box: AABB = BoardLayout3D.box_piazzamento(gs, int(pz["col_from"]),
			int(pz["width"]), int(pz.get("level", 0)), gs.era)
		# Verde a terra, ambra in alto: due quote e due colori, cosi' si
		# capisce a colpo d'occhio che sono due cose diverse.
		var col := Color(0.42, 1.0, 0.52)
		if int(pz.get("level", 0)) > 0: col = Color(1.0, 0.76, 0.26)
		_cornice(box, col)
	for uid in evidenze.get("uid", []):
		for b in gs.grid.buildings:
			if b.uid != int(uid): continue
			var piede := BoardLayout3D.basetta_box(gs, b)
			_cornice(piede, Color(0.42, 1.0, 0.52), 4.0)

# Una carta stesa sul tavolo: lo spessore del cartoncino piu' il disegno
# sopra. Il disegno e' un piano a se' e non la faccia della scatola, perche'
# una BoxMesh porterebbe la stessa texture anche sui fianchi.
# Senza immagine resta il rettangolo colorato: assets/ si rigenera dai PDF e
# non e' versionata, quindi la plancia deve reggere anche senza.
func _carta_stesa(box: AABB, percorso: String, tinta: Color,
		giu := false) -> void:
	var m := _scatola(box.size, tinta)
	m.position = box.position + box.size / 2.0
	add_child(m)
	if percorso == "" or not ResourceLoader.exists(percorso): return
	var tex := load(percorso) as Texture2D
	if tex == null: return
	var piano := _quad(Vector2(box.size.x, box.size.z), Color.WHITE, true)
	piano.rotate_x(-PI / 2.0)
	# Il titolo della carta va dalla parte opposta a chi guarda, come una
	# carta vera appoggiata sul tavolo davanti a se'.
	if giu: piano.rotate_y(PI)
	var mat := piano.material_override as StandardMaterial3D
	mat.albedo_texture = tex
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR
	mat.alpha_scissor_threshold = 0.5
	mat.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	piano.position = Vector3(box.position.x + box.size.x / 2.0,
		box.end.y + 0.4, box.position.z + box.size.z / 2.0)
	add_child(piano)

func _tessere() -> void:
	for c in gs.grid.n_cols:
		var t: int = gs.grid.terrains[c]
		# La tessera stampata e' UNA per colonna e va disegnata INTERA, 63 x
		# 271 mm. Qui prima si univa il primo binario con l'ultimo: da quando
		# i binari stanno nella sola fascia del disegno quella unione da' 130
		# mm, e la carta ci finiva dentro schiacciata a meta'. Il disegno era
		# giusto, la cornice no.
		var box := BoardLayout3D.tessera_box(c)
		var col: Color = COLORI_TERRENO[t]
		var percorso := BoardLayout3D.tessera_path(gs, c)
		if percorso != "" and ResourceLoader.exists(percorso): col = Color("#1d1b17")
		_carta_stesa(box, percorso, col)
		# La colonna puntata dal mouse si accende: senza, il giocatore non sa
		# dove sta per cliccare, perche' in prospettiva le colonne non stanno
		# dove sembra. Col disegno sopra non si puo' piu' schiarire il colore
		# della scatola, quindi si posa una velatura chiara sopra la tessera.
		if c == _evidenziata:
			var velo := _quad(Vector2(box.size.x, box.size.z),
				Color(1, 1, 1, 0.22), true)
			velo.rotate_x(-PI / 2.0)
			var mat := velo.material_override as StandardMaterial3D
			mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
			velo.position = Vector3(box.position.x + box.size.x / 2.0,
				box.end.y + 0.8, box.position.z + box.size.z / 2.0)
			add_child(velo)

func _edifici() -> void:
	for b in gs.grid.buildings:
		_terrapieni(b)
		_basetta(b)
		# Chi e' CROLLATO IN ROVINA non ha piu' una sagoma in piedi: resta il
		# piede, che fa da fondamenta a chi ci costruisce sopra. Il rudere
		# invece e' "in piedi ma spento" e la sagoma ce l'ha ancora, in grigio.
		# Disegnarli uguali era il motivo per cui in partita sembrava che
		# nessun edificio crollasse mai: crollano eccome - 877 su 1720 in 60
		# partite a tre giocatori - ma sullo schermo restavano in piedi.
		if BoardLayout3D.ha_sagoma(b):
			_sagoma(b)
			_linguette(b)
		_cubetti(b)
		_segnalini(b)

# Il piede che tiene in piedi il cartone: 15 mm di profondita' sui 26 dello
# slot, cosi' il resto resta scoperto e le file dietro si vedono.
# La terra riportata sotto le colonne che non avevano una base. Si paga (1
# pietra a colonna) ed e' l'unica cosa che regge l'edificio li' sotto:
# senza, restava sospeso sopra il vuoto proprio dove aveva pagato per
# riempire. Colore di terra e non del giocatore: il terrapieno non e' un suo
# pezzo di cartone, e' il terreno alzato.
func _terrapieni(b: Building) -> void:
	for box in BoardLayout3D.terrapieni(gs, b):
		if box.size.y <= 0.0: continue
		var m := _scatola(box.size, TERRAPIENO)
		m.position = box.position + box.size / 2.0
		add_child(m)

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
	var centro := base + Vector3(0.0, dim.y / 2.0 + BoardLayout3D.BASETTA_Y, 0.0)
	if tex == null:
		var m := _scatola(Vector3(dim.x, dim.y, BoardLayout3D.SAGOMA_SPESSORE_VISTA), col)
		m.position = centro
		add_child(m)
		return
	# Il cartone ha uno spessore, e un piano solo non ce l'ha: appena si gira
	# il tabellone la sagoma spariva di taglio come un adesivo. Si impilano
	# quindi alcune copie del disegno lungo lo spessore - le interne piu'
	# scure, come il cuore del cartoncino - e da qualunque angolo si vede un
	# pezzo pieno.
	var strati := 4
	var passo := BoardLayout3D.SAGOMA_SPESSORE_VISTA / float(strati - 1)
	for i in strati:
		var m := _quad(dim, Color.WHITE)
		var mat := m.material_override as StandardMaterial3D
		mat.albedo_texture = tex
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR
		mat.alpha_scissor_threshold = 0.5
		mat.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
		mat.cull_mode = BaseMaterial3D.CULL_DISABLED
		# Solo la faccia davanti porta il colore pieno: le altre fanno da
		# taglio e vanno in ombra, altrimenti lo spessore sembra vetro.
		var buio := 1.0 if i == strati - 1 else 0.45
		mat.albedo_color = Color(buio, buio, buio)
		if b.is_buried: mat.albedo_color *= Color(0.62, 0.62, 0.66)
		m.position = centro + Vector3(0.0, 0.0,
			-BoardLayout3D.SAGOMA_SPESSORE_VISTA / 2.0 + i * passo)
		add_child(m)
	# Niente nome sopra la sagoma. Le scritte che galleggiano sul tavolo
	# coprivano proprio quello che dovevano far vedere: adesso il nome esce
	# quando ci passi sopra col mouse, e solo quello puntato.

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
	for c in BoardLayout3D.side_cards(gs, umano):
		var r: AABB = c["aabb"]
		var percorso := BoardLayout3D.carta_path(str(c["kind"]), str(c["id"]))
		var sfondo := CARTA_SFONDO
		if percorso != "" and ResourceLoader.exists(percorso): sfondo = Color("#1d1b17")
		_carta_stesa(r, percorso, sfondo)
		# Niente scritte sopra: il nome e i numeri escono nel riquadro che
		# segue il mouse. I numeri li' vengono dai DATI e non dal disegno,
		# perche' quelli stampati sono vecchi - su 44 edifici su 60 lo Scavo
		# del PDF non e' quello della v1.5.
		if _acceso_carta(c): _cornice(r, Color(1.0, 0.88, 0.35), 4.0)

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
	# Del rettangolo colorato che fingeva di essere un tabellone resta una
	# BACCHETTA del colore del giocatore: le carte che ha comprato si
	# impilano sotto, e sono carte vere - vengono disegnate come tutte le
	# altre da _file_laterali.
	for p in BoardLayout3D.player_boards(gs):
		var r: AABB = p["aabb"]
		var i: int = int(p["player"])
		var suo: Color = COLORI_GIOCATORE[i % COLORI_GIOCATORE.size()]
		if i == gs.current_index: suo = suo.lightened(0.35)
		var m := _scatola(r.size, suo)
		m.position = r.position + r.size / 2.0
		add_child(m)

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
