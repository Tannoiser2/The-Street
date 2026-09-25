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
# Il livello degli effetti: quello che si muove nel tempo invece di essere
# ridisegnato fermo a ogni giro.
var _effetti: Node3D = null
var _crolli: Array[Dictionary] = []
# Lo stato di ogni edificio al giro prima: e' guardando come cambia che si
# sa CHI e' appena crollato. Il nucleo non lo dice alla vista - non la
# conosce - e non deve: la differenza si vede dallo stato, che c'e' gia'.
var _stato_prima: Dictionary = {}

func mostra(stato: GameState, colonna_evidenziata := -1, acceso := {}) -> void:
	var prima := gs
	gs = stato
	_evidenziata = colonna_evidenziata
	evidenze = acceso
	# Gli EFFETTI non si buttano col resto: un crollo dura piu' di un
	# fotogramma, e fra un turno e l'altro il tavolo si ridisegna piu' volte.
	# Vivono in un nodo loro, che sopravvive al ridisegno e si svuota da se'.
	for f in get_children():
		if f == _effetti: continue
		f.queue_free()
	if _effetti == null:
		_effetti = Node3D.new()
		add_child(_effetti)
	_nuovi_crolli(prima)
	_tavolo()
	_cielo()
	_tessere()
	_file_laterali()
	_plance()
	_edifici()
	_pupazzetti()
	_posti_liberi()
	_luci()
	_telecamera()

# ---- lo sgretolamento ------------------------------------------------
# Chi e' passato a ROVINA da quando abbiamo guardato l'ultima volta si abbatte.
# Alla prima chiamata non si anima niente: si prende nota e basta, se no
# aprendo una partita a meta' crollerebbe tutto insieme.
func _nuovi_crolli(prima: GameState) -> void:
	var adesso := {}
	for b in gs.grid.buildings: adesso[b.uid] = b.state
	if prima != null and not _stato_prima.is_empty():
		for b in gs.grid.buildings:
			if b.state != Enums.BuildingState.ROVINA: continue
			if not _stato_prima.has(b.uid): continue
			if int(_stato_prima[b.uid]) == Enums.BuildingState.ROVINA: continue
			# Nella v2 la rovina non si abbatte: si gira, e resta in piedi.
			if BoardLayout3D.sagoma_girata(b): continue
			_avvia_crollo(b)
	_stato_prima = adesso

func _avvia_crollo(b: Building) -> void:
	if _effetti == null: return
	var dim := BoardLayout3D.standee_size(b)
	var base := BoardLayout3D.standee_base(gs, b)
	# Il perno sta al PIEDE della sagoma, sul davanti: e' li' che il cartone
	# fa leva quando si abbatte, non al centro.
	var perno := Node3D.new()
	perno.position = base + Vector3(0.0, BoardLayout3D.BASETTA_Y,
		BoardLayout3D.SAGOMA_SPESSORE_VISTA / 2.0)
	_effetti.add_child(perno)
	var sagoma := _mesh_sagoma_di(b, dim)
	if sagoma != null:
		sagoma.position = Vector3(0.0, dim.y / 2.0, -BoardLayout3D.SAGOMA_SPESSORE_VISTA / 2.0)
		perno.add_child(sagoma)
	var pezzi: Array[Node3D] = []
	var dati := BoardLayout3D.macerie(b.uid, dim.x)
	for m in dati:
		var lato := float(m["lato"])
		var cubo := _scatola(Vector3(lato, lato, lato), TERRAPIENO.lightened(0.1))
		_effetti.add_child(cubo)
		pezzi.append(cubo)
	_crolli.append({"perno": perno, "sagoma": sagoma, "t": 0.0,
		"macerie": dati, "pezzi": pezzi,
		"origine": base + Vector3(0.0, BoardLayout3D.BASETTA_Y, 0.0)})

# La stessa sagoma che disegna `_sagoma`, ma staccata dal tabellone: serve a
# farla cadere. Se non c'e' l'illustrazione si ripiega sul cartoncino colorato,
# come fa il resto della vista.
func _mesh_sagoma_di(b: Building, dim: Vector2) -> MeshInstance3D:
	var col: Color = COLORI_GIOCATORE[b.owner % COLORI_GIOCATORE.size()].darkened(0.48)
	var tex: Texture2D = _illustrazione(b)
	if tex == null:
		return _scatola(Vector3(dim.x, dim.y, BoardLayout3D.SAGOMA_SPESSORE_VISTA), col)
	var mesh := mesh_sagoma(tex, dim, BoardLayout3D.SAGOMA_SPESSORE_VISTA)
	if mesh == null: return _scatola(Vector3(dim.x, dim.y, BoardLayout3D.SAGOMA_SPESSORE_VISTA), col)
	var m := MeshInstance3D.new()
	m.mesh = mesh
	var stampa := StandardMaterial3D.new()
	_stampa(stampa, tex)
	stampa.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	var taglio := StandardMaterial3D.new()
	taglio.albedo_color = TAGLIO_CARTONE
	taglio.cull_mode = BaseMaterial3D.CULL_DISABLED
	taglio.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	m.set_surface_override_material(0, stampa)
	if mesh.get_surface_count() > 1: m.set_surface_override_material(1, taglio)
	return m

func _process(delta: float) -> void:
	if _crolli.is_empty(): return
	var vivi: Array[Dictionary] = []
	for c in _crolli:
		c["t"] = float(c["t"]) + delta
		var q := float(c["t"]) / BoardLayout3D.CROLLO_DURATA
		var stato := BoardLayout3D.crollo(q)
		var perno: Node3D = c["perno"]
		if is_instance_valid(perno):
			perno.rotation = Vector3(float(stato["angolo"]), 0.0, 0.0)
			_opacita(c["sagoma"], float(stato["opacita"]))
		var pezzi: Array = c["pezzi"]
		var dati: Array = c["macerie"]
		for i in pezzi.size():
			var n: Node3D = pezzi[i]
			if not is_instance_valid(n): continue
			n.position = (c["origine"] as Vector3) \
				+ BoardLayout3D.maceria_pos(dati[i], float(c["t"]))
			_opacita(n, float(stato["opacita"]))
		if bool(stato["finito"]):
			if is_instance_valid(perno): perno.queue_free()
			for n in pezzi:
				if is_instance_valid(n): n.queue_free()
			continue
		vivi.append(c)
	_crolli = vivi

func _opacita(n, valore: float) -> void:
	if n == null or not is_instance_valid(n): return
	var m := n as MeshInstance3D
	if m == null: return
	if m.material_override is StandardMaterial3D:
		var mat := m.material_override as StandardMaterial3D
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		mat.albedo_color.a = valore
		return
	for i in m.get_surface_override_material_count():
		var mat2 := m.get_surface_override_material(i) as StandardMaterial3D
		if mat2 != null: mat2.albedo_color.a = valore

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
		# Del panorama si mostra solo la striscia bassa - orizzonte e terra -
		# invece di schiacciare tutta l'immagine in meta' pannello: si taglia
		# il cielo vuoto in alto e quel che resta tiene le sue proporzioni.
		var quota := clampf(BoardLayout3D.CIELO_QUOTA, 0.05, 1.0)
		mat.uv1_scale = Vector3(1.0, quota, 1.0)
		mat.uv1_offset = Vector3(0.0, 1.0 - quota, 0.0)
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
		giu := false, stampa := Color.WHITE) -> void:
	var m := _scatola(box.size, tinta)
	m.position = box.position + box.size / 2.0
	add_child(m)
	if percorso == "" or not ResourceLoader.exists(percorso): return
	var tex := load(percorso) as Texture2D
	if tex == null: return
	var piano := _quad(Vector2(box.size.x, box.size.z), stampa, true)
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
		# Il cartellino della Prosperita': si posa sulla fascia in fondo alla
		# tessera quando la colonna e' un Centro Urbano attivo, e si spegne
		# quando ha gia' pagato in quest'era. La scritta stampata c'e' sempre,
		# il cartellino no.
		if gs.grid.is_prosperity_center(c): _cartello_prosperita(c)
		# LA TESSERA GIRATA (v2, registro 100 e 103): l'effetto della tessera
		# scatta una volta per era, poi la tessera si gira. Sul tavolo vero si
		# capovolge; qui si abbuia e ci si scrive sopra, cosi' il disegno del
		# terreno resta leggibile e si vede da lontano che per quest'era non
		# da' piu' niente. A inizio era il motore la rigira e il velo sparisce.
		if tessera_girata(c): _tessera_girata(c, box)
		if c == _evidenziata:
			var velo := _quad(Vector2(box.size.x, box.size.z),
				Color(1, 1, 1, 0.22), true)
			velo.rotate_x(-PI / 2.0)
			var mat := velo.material_override as StandardMaterial3D
			mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
			velo.position = Vector3(box.position.x + box.size.x / 2.0,
				box.end.y + 0.8, box.position.z + box.size.z / 2.0)
			add_child(velo)

# La tessera della colonna e' girata? Lo dice lo stato, non la vista: nella
# v1.5 la lista e' vuota o tutta falsa e nessuna tessera si abbuia mai.
func tessera_girata(col: int) -> bool:
	if gs == null or col < 0 or col >= gs.tessere_usate.size(): return false
	return bool(gs.tessere_usate[col])

const VELO_GIRATA := Color(0.05, 0.04, 0.03, 0.62)

func _tessera_girata(col: int, box: AABB) -> void:
	var velo := _quad(Vector2(box.size.x, box.size.z), VELO_GIRATA, true)
	velo.rotate_x(-PI / 2.0)
	var mat := velo.material_override as StandardMaterial3D
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	velo.position = Vector3(box.position.x + box.size.x / 2.0,
		box.end.y + 1.0, box.position.z + box.size.z / 2.0)
	velo.set_meta("girata", col)
	add_child(velo)
	# La scritta sta sulla fascia in fondo, dove sta il cartellino della
	# Prosperita', e come lui si legge da ogni lato.
	var dove := BoardLayout3D.prosperita_box(col)
	_scritta(Vector3(dove.position.x + dove.size.x / 2.0, box.end.y + 6.0,
		dove.position.z + dove.size.z / 2.0), "girata", 0.28, Color("#d9d2c5"))

func _cartello_prosperita(col: int) -> void:
	if not ResourceLoader.exists(BoardLayout3D.PROSPERITA_PATH): return
	var tex := load(BoardLayout3D.PROSPERITA_PATH) as Texture2D
	if tex == null: return
	var box := BoardLayout3D.prosperita_box(col)
	# Il colore moltiplica il disegno: bianco lo lascia com'e', grigio lo
	# spegne quando il Centro ha gia' pagato in quest'era.
	var q := _quad(Vector2(box.size.x, box.size.z), BoardLayout3D.prosperita_colore(gs, col), true)
	var mat := q.material_override as StandardMaterial3D
	mat.albedo_texture = tex
	mat.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	q.rotate_x(-PI / 2.0)
	q.position = Vector3(box.position.x + box.size.x / 2.0, box.position.y + 0.4,
		box.position.z + box.size.z / 2.0)
	add_child(q)

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
		# La terra riportata e' TERRA, e ha un disegno suo: una sezione di
		# terreno. Prima era un parallelepipedo grigio e in mezzo a due
		# basette disegnate sembrava un buco nella costruzione, non il pieno
		# che invece e'.
		_faccia_di_terra(box, b.col_from)

func _faccia_di_terra(box: AABB, variante: int) -> void:
	if not ResourceLoader.exists(BoardLayout3D.TERRAPIENO_PATH): return
	var tex := load(BoardLayout3D.TERRAPIENO_PATH) as Texture2D
	if tex == null: return
	var uv: Dictionary = BoardLayout3D.terra_uv(box, variante)
	for davanti in [true, false]:
		var p := _quad(Vector2(box.size.x, box.size.y), Color.WHITE, true)
		var mat := p.material_override as StandardMaterial3D
		mat.albedo_texture = tex
		mat.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
		mat.uv1_scale = Vector3((uv["scala"] as Vector2).x, (uv["scala"] as Vector2).y, 1.0)
		mat.uv1_offset = Vector3((uv["offset"] as Vector2).x, (uv["offset"] as Vector2).y, 0.0)
		if not davanti: p.rotate_y(PI)
		p.position = Vector3(box.position.x + box.size.x / 2.0,
			box.position.y + box.size.y / 2.0,
			(box.end.z + 0.15) if davanti else (box.position.z - 0.15))
		add_child(p)

func _basetta(b: Building) -> void:
	var box := BoardLayout3D.basetta_box(gs, b)
	# Col disegno sopra, il colore del giocatore non ha piu' dove stare: va
	# sulla basetta, che e' esattamente cio' che sul tavolo vero distingue
	# due copie della stessa sagoma.
	var m := _scatola(box.size, COLORI_GIOCATORE[b.owner % COLORI_GIOCATORE.size()].darkened(0.15))
	m.position = box.position + box.size / 2.0
	add_child(m)
	_banner_scavo(b)

# Il valore di Scavo scritto sulla basetta, davanti e dietro: la striscia di
# terra e macerie che cresce col numero. Due piani appoggiati alle facce, non
# la texture della scatola - una BoxMesh porterebbe lo stesso disegno anche
# sui fianchi e sopra, dove ci sta in piedi la sagoma.
func _banner_scavo(b: Building) -> void:
	if not ResourceLoader.exists(BoardLayout3D.SCAVO_PATH): return
	var tex := load(BoardLayout3D.SCAVO_PATH) as Texture2D
	if tex == null: return
	var uv: Dictionary = BoardLayout3D.scavo_uv(b)
	for f in BoardLayout3D.facce_basetta(gs, b):
		var p := _quad(f["dim"], Color.WHITE, true)
		var mat := p.material_override as StandardMaterial3D
		mat.albedo_texture = tex
		mat.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
		mat.uv1_scale = Vector3((uv["scala"] as Vector2).x, (uv["scala"] as Vector2).y, 1.0)
		mat.uv1_offset = Vector3((uv["offset"] as Vector2).x, (uv["offset"] as Vector2).y, 0.0)
		# Il quad guarda +Z: quello dietro si gira, se no si vedrebbe il
		# disegno specchiato e il numero al contrario.
		if not bool(f["davanti"]): p.rotate_y(PI)
		# Un pelo fuori dalla faccia, se no i due piani complanari sfarfallano.
		var fuori := 0.15 if bool(f["davanti"]) else -0.15
		p.position = (f["pos"] as Vector3) + Vector3(0.0, 0.0, fuori)
		add_child(p)

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
	# LA ROVINA GIRATA (v2): la sagoma resta in piedi ma mostra il retro, il
	# lato rovina. Non abbiamo il disegno di quel lato, quindi si gira il
	# cartone di mezzo giro - la stampa in grigio si vede specchiata - e lo
	# si scurisce come una rovina. Senza le immagini resta la scatola scura.
	if BoardLayout3D.sagoma_girata(b):
		var perno := Node3D.new()
		perno.position = centro
		perno.rotation = Vector3(0.0, PI, 0.0)
		perno.set_meta("girata", true)
		add_child(perno)
		var dietro: Node3D
		if tex == null:
			dietro = _scatola(Vector3(dim.x, dim.y, BoardLayout3D.SAGOMA_SPESSORE_VISTA), col)
		else:
			dietro = _quad(dim, Color.WHITE)
			var mat := dietro.material_override as StandardMaterial3D
			_stampa(mat, tex)
			mat.albedo_color = Color(0.55, 0.55, 0.58)
		perno.add_child(dietro)
		return
	if tex == null:
		var m := _scatola(Vector3(dim.x, dim.y, BoardLayout3D.SAGOMA_SPESSORE_VISTA), col)
		m.position = centro
		add_child(m)
		return
	# UNA SAGOMA SOLA, SPESSA. Prima si impilavano quattro copie del disegno
	# lungo lo spessore per far sembrare pieno il cartone: da vicino si
	# vedevano per quello che erano, quattro figure appaiate. Adesso e' un
	# pezzo unico - il contorno ritagliato dall'alfa dell'illustrazione ed
	# estruso nello spessore - con la stampa sulle due facce e il taglio
	# scuro sul bordo, come il cartoncino vero.
	var mesh := mesh_sagoma(tex, dim, BoardLayout3D.SAGOMA_SPESSORE_VISTA)
	if mesh == null:
		# L'alfa non ha dato un contorno: meglio un piano con la stampa che
		# niente. Succede se l'immagine e' piena fino ai bordi.
		var piatta := _quad(dim, Color.WHITE)
		_stampa(piatta.material_override as StandardMaterial3D, tex)
		piatta.position = centro
		add_child(piatta)
		return
	var m := MeshInstance3D.new()
	m.mesh = mesh
	# La mesh e' condivisa fra tutte le copie della stessa sagoma, quindi i
	# materiali vanno sull'istanza e non sulla mesh.
	var stampa := StandardMaterial3D.new()
	_stampa(stampa, tex)
	var taglio := StandardMaterial3D.new()
	taglio.albedo_color = TAGLIO_CARTONE
	taglio.cull_mode = BaseMaterial3D.CULL_DISABLED
	m.set_surface_override_material(0, stampa)
	if mesh.get_surface_count() > 1: m.set_surface_override_material(1, taglio)
	m.position = centro
	add_child(m)

func _stampa(mat: StandardMaterial3D, tex: Texture2D) -> void:
	mat.albedo_color = Color.WHITE
	mat.albedo_texture = tex
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR
	mat.alpha_scissor_threshold = 0.5
	mat.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED

# ---- il cartone estruso ----------------------------------------------
# Il contorno della sagoma viene dall'ALFA dell'illustrazione, non da un
# rettangolo: le sagome sono fustellate, e una scatola dietro il disegno
# sporgerebbe da tutte le parti. BitMap.opaque_to_polygons fa il ritaglio,
# poi il contorno si estrude nello spessore.
#
# Il risultato si tiene in cache: la scena si ricostruisce a ogni clic e a
# ogni mossa dei bot, e rifare il ritaglio sessanta volte al secondo sarebbe
# uno spreco. La chiave comprende le misure, perche' la stessa illustrazione
# puo' servire sagome di taglia diversa.
static var _sagome_estruse := {}

# Quanto si semplifica il contorno, in pixel dell'immagine. Sotto l'unita'
# il bordo sfrangiato della compressione produce migliaia di vertici; sopra i
# tre si perdono i campanili.
const CONTORNO_EPSILON := 2.0
const TAGLIO_CARTONE := Color(0.38, 0.35, 0.31)

static func mesh_sagoma(tex: Texture2D, dim: Vector2, spessore: float) -> ArrayMesh:
	if tex == null: return null
	# Le texture caricate da file hanno un percorso; quelle costruite a
	# mano (i test) no, e senza identita' finirebbero nella stessa voce.
	var nome := tex.resource_path if tex.resource_path != "" \
		else "id%d" % tex.get_instance_id()
	var chiave := "%s|%.1f|%.1f|%.1f" % [nome, dim.x, dim.y, spessore]
	if _sagome_estruse.has(chiave): return _sagome_estruse[chiave]
	var img := tex.get_image()
	if img == null: return null
	# Nell'export la texture puo' stare compressa per la scheda video: si
	# decomprime per poterne leggere l'alfa, e se non si puo' si torna
	# indietro col piano invece di far saltare la scena.
	if img.is_compressed(): img.decompress()
	if img.is_compressed(): return null
	if img.get_format() != Image.FORMAT_RGBA8: img.convert(Image.FORMAT_RGBA8)
	var w := float(img.get_width())
	var h := float(img.get_height())
	if w <= 0.0 or h <= 0.0: return null
	var bm := BitMap.new()
	bm.create_from_image_alpha(img, 0.5)
	var poligoni := bm.opaque_to_polygons(Rect2i(0, 0, int(w), int(h)),
		CONTORNO_EPSILON)
	var mesh := _estrudi(poligoni, Vector2(w, h), dim, spessore)
	_sagome_estruse[chiave] = mesh
	return mesh

static func _estrudi(poligoni: Array, pixel: Vector2, dim: Vector2,
		spessore: float) -> ArrayMesh:
	var facce := SurfaceTool.new()
	facce.begin(Mesh.PRIMITIVE_TRIANGLES)
	var bordo := SurfaceTool.new()
	bordo.begin(Mesh.PRIMITIVE_TRIANGLES)
	var mezzo := spessore / 2.0
	var triangoli := 0
	for poly in poligoni:
		if poly.size() < 3: continue
		var tri := Geometry2D.triangulate_polygon(poly)
		if tri.is_empty(): continue
		triangoli += tri.size() / 3
		# Le due facce stampate, davanti e dietro. La stampa e' la stessa:
		# sul cartone vero il disegno c'e' da entrambi i lati.
		for lato in [1.0, -1.0]:
			for k in tri.size():
				var p: Vector2 = poly[tri[k]]
				facce.set_uv(Vector2(p.x / pixel.x, p.y / pixel.y))
				facce.set_normal(Vector3(0.0, 0.0, lato))
				facce.add_vertex(_in_mm(p, pixel, dim, lato * mezzo))
		# Il taglio: una striscia lungo tutto il contorno.
		for i in poly.size():
			var a: Vector2 = poly[i]
			var b: Vector2 = poly[(i + 1) % poly.size()]
			var a3 := _in_mm(a, pixel, dim, mezzo)
			var b3 := _in_mm(b, pixel, dim, mezzo)
			var a4 := _in_mm(a, pixel, dim, -mezzo)
			var b4 := _in_mm(b, pixel, dim, -mezzo)
			var lungo := (b3 - a3)
			var n := Vector3(lungo.y, -lungo.x, 0.0).normalized()
			for v in [a3, b3, b4, a3, b4, a4]:
				bordo.set_normal(n)
				bordo.add_vertex(v)
	if triangoli == 0: return null
	var mesh := ArrayMesh.new()
	facce.index()
	facce.commit(mesh)
	bordo.index()
	bordo.commit(mesh)
	return mesh

# Dal pixel dell'immagine al millimetro sulla sagoma, centrata sull'origine.
# La y si ribalta: nell'immagine cresce verso il basso, sul tavolo verso
# l'alto.
static func _in_mm(p: Vector2, pixel: Vector2, dim: Vector2, z: float) -> Vector3:
	return Vector3(p.x / pixel.x * dim.x - dim.x / 2.0,
		(1.0 - p.y / pixel.y) * dim.y - dim.y / 2.0, z)
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

# Le carte del mazzetto di un giocatore si spengono come le sagome: finche'
# l'edificio e' intatto la carta e' accesa; quando diventa rudere o rovina
# si gira sul grigio; quando finisce sotto passa nel mazzetto dello Scavo, a
# destra, e li' si spegne del tutto.
const CARTA_SPENTA := Color(0.45, 0.45, 0.47)
const CARTA_SEPOLTA := Color(0.30, 0.28, 0.26)

func _file_laterali() -> void:
	for c in BoardLayout3D.side_cards(gs, umano):
		var r: AABB = c["aabb"]
		# Lo scheletro del lavoratore (v2) non e' una carta: e' il gettone,
		# in piedi sulla riga del ventaglio che gli tocca.
		if str(c["kind"]) == "scheletro":
			_gettone(BoardLayout3D.scheletro_nel_ventaglio(r), int(str(c["id"])))
			continue
		var percorso := BoardLayout3D.carta_path(str(c["kind"]), str(c["id"]))
		var sfondo := CARTA_SFONDO
		if percorso != "" and ResourceLoader.exists(percorso): sfondo = Color("#1d1b17")
		var stampa := Color.WHITE
		if bool(c.get("sepolta", false)): stampa = CARTA_SEPOLTA
		elif bool(c.get("spenta", false)): stampa = CARTA_SPENTA
		_carta_stesa(r, percorso, sfondo * stampa, false, stampa)
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
		"scheletro": return "scheletro"
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
		"scheletro":
			return "vale %d" % BoardLayout3D.scheletro_valore(int(id))
	return ""

# IL PUPAZZETTO. Non un parallelepipedo: un corpo che si allarga verso il
# basso e una testa tonda, cioe' la sagoma che al tavolo si riconosce a colpo
# d'occhio anche piccola e di scorcio. E' fatto di tre pezzi perche' tre
# bastano - un meeple vero ha le braccia, ma a 8 mm non si vedrebbero.
func _meeple(dove: Vector3, colore: Color) -> Node3D:
	var n := Node3D.new()
	var w := BoardLayout3D.MEEPLE_W
	var h := BoardLayout3D.MEEPLE_H
	var d := BoardLayout3D.MEEPLE_D
	var corpo := _scatola(Vector3(w, h * 0.45, d), colore)
	corpo.position = Vector3(0, h * 0.225, 0)
	n.add_child(corpo)
	var busto := _scatola(Vector3(w * 0.62, h * 0.28, d), colore)
	busto.position = Vector3(0, h * 0.45 + h * 0.14, 0)
	n.add_child(busto)
	var testa := MeshInstance3D.new()
	var s := SphereMesh.new()
	s.radius = w * 0.34
	s.height = w * 0.68
	s.radial_segments = 10
	s.rings = 6
	testa.mesh = s
	var mat := StandardMaterial3D.new()
	mat.albedo_color = colore
	testa.material_override = mat
	testa.position = Vector3(0, h * 0.73 + w * 0.3, 0)
	n.add_child(testa)
	n.position = dove
	return n

# I pupazzetti di tutti: quelli ancora in mano sulla bacchetta, quelli gia'
# usati sulla strada, e quelli della Dinastia ancora sulla sua carta.
func _pupazzetti() -> void:
	for i in gs.n_players:
		var col: Color = COLORI_GIOCATORE[i % COLORI_GIOCATORE.size()]
		if i == gs.current_index: col = col.lightened(0.2)
		for pos in BoardLayout3D.meeple_liberi(gs, i):
			add_child(_meeple(pos, col))
		for m in BoardLayout3D.meeple_in_campo(gs, i):
			add_child(_meeple(m["pos"], col.lightened(0.3)))
	for m in BoardLayout3D.meeple_dinastia(gs):
		add_child(_meeple(m["pos"],
			COLORI_GIOCATORE[int(m["player"]) % COLORI_GIOCATORE.size()]))

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
	# Il lavoratore che abita l'edificio non si disegna piu' qui: e' un
	# pupazzetto come gli altri, e lo mette in tavola `_pupazzetti` - uno solo
	# per lavoratore, che sta o sulla bacchetta o sulla strada.
	if b.buried_character != "":
		_gettone_scheletro(b)

# Il gettone del personaggio sepolto, posato sulla basetta: lo scheletro
# dell'era in cui e' stato sepolto, col suo valore stampato sopra. Senza
# l'immagine - assets/ si rigenera e non e' versionata - resta il cubetto
# color ocra di prima, cosi' le partite headless non dipendono dalla grafica.
func _gettone_scheletro(b: Building) -> void:
	_gettone(BoardLayout3D.scheletro_piede(gs, b), b.buried_character_era)

# Il gettone in se', col piede dove lo si appoggia: serve sulla basetta e,
# nella v2, nel ventaglio del giocatore sotto la carta dell'edificio.
func _gettone(piede: Vector3, era: int) -> void:
	var dim := BoardLayout3D.scheletro_size()
	var tex: Texture2D = null
	if ResourceLoader.exists(BoardLayout3D.SCHELETRO_PATH):
		tex = load(BoardLayout3D.SCHELETRO_PATH) as Texture2D
	if tex == null:
		var cubo := _scatola(Vector3(8.0, 8.0, 8.0), Color("#8a6f3a"))
		cubo.position = piede + Vector3(0.0, 4.0, -4.0)
		add_child(cubo)
		return
	# Il perno sta al PIEDE del gettone, sul davanti: e' li' che appoggia
	# sulla basetta, e da li' si inclina all'indietro.
	var perno := Node3D.new()
	perno.position = piede
	perno.rotation = Vector3(-BoardLayout3D.SCHELETRO_PENDENZA, 0.0, 0.0)
	add_child(perno)
	# Il cartoncino sotto la stampa: da' spessore al gettone, che di taglio
	# altrimenti sparirebbe.
	var spessore := _scatola(Vector3(dim.x, dim.y, BoardLayout3D.SCHELETRO_SPESSORE),
		Color("#3a3128"))
	spessore.position = Vector3(0.0, dim.y / 2.0, 0.0)
	perno.add_child(spessore)
	var uv: Dictionary = BoardLayout3D.scheletro_uv(era)
	var faccia := _quad(dim, Color.WHITE)
	var mat := faccia.material_override as StandardMaterial3D
	mat.albedo_texture = tex
	mat.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.uv1_scale = Vector3((uv["scala"] as Vector2).x, (uv["scala"] as Vector2).y, 1.0)
	mat.uv1_offset = Vector3((uv["offset"] as Vector2).x, (uv["offset"] as Vector2).y, 0.0)
	faccia.position = Vector3(0.0, dim.y / 2.0,
		BoardLayout3D.SCHELETRO_SPESSORE / 2.0 + 0.05)
	perno.add_child(faccia)

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
