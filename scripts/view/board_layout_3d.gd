# res://scripts/view/board_layout_3d.gd
# Geometria della plancia in 3D. PURA: nessun Node, nessuna mesh, solo
# posizioni. Serve a piazzare le sagome E a capire dove il giocatore ha
# cliccato, cosi' le due cose non possono divergere.
#
# TUTTE LE MISURE SONO IN MILLIMETRI, prese dal cartone vero: cosi' i numeri
# del designer entrano qui verbatim invece di passare da una conversione a
# occhio. `U` le porta alle unita' di Godot.
#
# Misurate da materiali/Carte.pdf (solo geometria, non dati di gioco):
#   tessera colonna  63 x 271 mm  ->  5 binari da 54,2 mm
#   sagome           61 / 121 / 181 mm di larghezza = 1, 2, 3 slot
#   altezze          mediane 66 / 62 / 74 mm per 1 / 2 / 3 slot
# Dal designer: basetta profonda 15 mm, cartone della sagoma spesso 4 mm.
#
# Gli assi vengono dal tavolo vero:
#   X  le colonne, una tessera a fianco all'altra
#   Z  i 5 binari in profondita'. ERA 1 DAVANTI, era 5 in fondo, cielo dietro.
#   Y  le quote. Un edificio sopraelevato non appartiene a nessun binario:
#      poggia su quelli sotto, che gli fanno da basetta.
class_name BoardLayout3D
extends RefCounted

const U := 0.01                  # 1 unita' Godot = 100 mm

const RAILS := 5
const TESSERA_W := 63.0          # larghezza di una tessera colonna
const TESSERA_D := 271.0         # profondita': i cinque binari, contigui
const TESSERA_Y := 2.0           # spessore della tessera stesa sul tavolo
const SLOT_D := TESSERA_D / float(RAILS)     # 54,2 mm per binario
const SAGOMA_MODULO := 60.3      # 1/2/3 slot -> 60,3 / 120,6 / 180,9 mm
const SAGOMA_SPESSORE := 4.0     # cartone
const BASETTA_D := 15.0          # il piede che tiene in piedi la sagoma
const BASETTA_Y := 5.0
# Le sagome sono contigue sul binario, ma la basetta ne occupa 15 mm sui 54:
# il resto dello slot resta scoperto, ed e' quello che lascia vedere le file
# dietro senza bisogno di allontanare i binari.
const LEVEL_H := 85.0            # passo fra le quote: mai meno di una sagoma
const CIELO_STACCO := 90.0
const CIELO_H := 620.0

static func col_x(col: int) -> float:
	return col * TESSERA_W

static func rail_z(era: int) -> float:
	return (era - 1) * SLOT_D

static func span_w(n_col: int) -> float:
	return n_col * SAGOMA_MODULO

static func board_w(gs: GameState) -> float:
	return gs.grid.n_cols * TESSERA_W

static func board_d() -> float:
	return TESSERA_D

static func level_y(level: int) -> float:
	return TESSERA_Y + level * LEVEL_H

# Il centro dello slot (colonna, binario) sul piano del tavolo.
static func slot_center(col: int, era: int) -> Vector3:
	return Vector3(col_x(col) + TESSERA_W / 2.0, TESSERA_Y, rail_z(era) + SLOT_D / 2.0)

# Dove poggia la sagoma. La basetta sta sul DAVANTI dello slot: i 39 mm dietro
# restano scoperti, ed e' cosi' che si vedono le file in fondo.
static func standee_base(gs: GameState, b: Building) -> Vector3:
	var x := col_x(b.col_from) + b.width() * TESSERA_W / 2.0
	var z: float
	if b.level == 0:
		z = rail_z(b.era_built) + BASETTA_D / 2.0
	else:
		# Senza binario: al centro della profondita' della colonna, sopra il
		# baricentro di cio' che la sorregge.
		z = board_d() / 2.0
	return Vector3(x, level_y(b.level), z)

# La basetta: ogni sagoma ne ha una. 15 mm di profondita' per 4 mm di cartone.
static func basetta_box(gs: GameState, b: Building) -> AABB:
	var c := standee_base(gs, b)
	return AABB(Vector3(c.x - span_w(b.width()) / 2.0, c.y, c.z - BASETTA_D / 2.0),
		Vector3(span_w(b.width()), BASETTA_Y, BASETTA_D))

static func tile_box(col: int, era: int) -> AABB:
	return AABB(Vector3(col_x(col), 0.0, rail_z(era)), Vector3(TESSERA_W, TESSERA_Y, SLOT_D))

# Finche' non si sa quale sagoma appartiene a quale edificio (domande-aperte
# punto 23), l'altezza e' la MEDIANA misurata per quella larghezza: un numero
# preso dal cartone vero, non inventato.
const ALTEZZA_MEDIANA: Array[float] = [66.0, 66.0, 62.0, 74.0]

static func standee_size(b: Building) -> Vector2:
	var n: int = clampi(b.width(), 1, ALTEZZA_MEDIANA.size() - 1)
	return Vector2(span_w(b.width()), ALTEZZA_MEDIANA[n])

static func sky_rect(gs: GameState) -> AABB:
	var z := board_d() + CIELO_STACCO
	return AABB(Vector3(-TESSERA_W * 2.0, -20.0, z),
		Vector3(board_w(gs) + TESSERA_W * 4.0, CIELO_H, 0.0))

# L'inquadratura e' DERIVATA, non aggiustata a occhio: inclinazione fissa e
# distanza calcolata perche' la strada riempia il fotogramma. Cosi' vale per
# 5, 7 o 9 colonne senza ritoccare nulla.
#
# L'inclinazione non e' un gusto. I binari sono contigui (54,2 mm) e le sagome
# sono alte fino a 74: da un angolo basso le file dietro sparirebbero dietro
# quelle davanti. Il minimo e' atan(altezza / passo) ~ 54 gradi; 62 lascia
# margine e mostra ancora il cielo.
const FOV := 40.0
const INCLINAZIONE := 62.0      # gradi sopra l'orizzonte
const RIEMPIMENTO := 0.80       # quanta larghezza del fotogramma occupa la strada
const ASPETTO := 1520.0 / 900.0

# Il punto che la telecamera guarda: il centro della strada, un po' sopra il
# piano del tavolo perche' le sagome stanno in piedi.
# Quanto e' alta la citta': serve all'inquadratura, che deve arretrare man
# mano che le torri salgono invece di tagliarle.
static func altezza_scena(gs: GameState) -> float:
	var m := 0
	for b in gs.grid.buildings:
		m = maxi(m, b.level)
	return level_y(m) + ALTEZZA_MEDIANA[0] + BASETTA_Y

static func camera_target(gs: GameState) -> Vector3:
	return Vector3(board_w(gs) / 2.0, altezza_scena(gs) * 0.38, board_d() * 0.55)

# L'ingombro di tutta la scena: la strada piu' le torri.
static func scene_aabb(gs: GameState) -> AABB:
	return AABB(Vector3.ZERO, Vector3(board_w(gs), altezza_scena(gs), board_d()))

# Quanto della scena esce dal fotogramma, da una certa posizione: 1.0 vuol
# dire che tocca esattamente il bordo. Si guardano gli OTTO SPIGOLI, perche'
# in prospettiva la fila davanti e' piu' vicina e si ingrandisce - una stima
# lineare la taglierebbe, ed e' proprio l'errore che avevo fatto.
static func _ingombro(cam: Vector3, mira: Vector3, scatola: AABB) -> float:
	var avanti := (mira - cam).normalized()
	var destra := avanti.cross(Vector3.UP).normalized()
	var su := destra.cross(avanti).normalized()
	var tan_v := tan(deg_to_rad(FOV) / 2.0)
	var tan_o := tan_v * ASPETTO
	var peggio := 0.0
	for i in 8:
		var ang := scatola.position + Vector3(
			scatola.size.x * float(i & 1),
			scatola.size.y * float((i >> 1) & 1),
			scatola.size.z * float((i >> 2) & 1))
		var v := ang - cam
		var z := v.dot(avanti)
		if z <= 1.0: return 99.0          # spigolo dietro la telecamera
		peggio = maxf(peggio, absf(v.dot(destra)) / (z * tan_o))
		peggio = maxf(peggio, absf(v.dot(su)) / (z * tan_v))
	return peggio

# La distanza si trova per avvicinamento: poche passate bastano, e il
# risultato e' esatto per 5, 7 o 9 colonne e per qualsiasi altezza.
static func camera_position(gs: GameState) -> Vector3:
	var p := deg_to_rad(INCLINAZIONE)
	var dir := Vector3(0.0, sin(p), -cos(p))
	var mira := camera_target(gs)
	var scatola := scene_aabb(gs)
	var d := board_w(gs) + board_d() + altezza_scena(gs)
	for i in 8:
		var fattore := _ingombro(mira + dir * d, mira, scatola)
		if fattore > 90.0:
			d *= 2.0
			continue
		d = maxf(d * fattore / RIEMPIMENTO, 1.0)
	return mira + dir * d

# Quanta parte del fotogramma occupa la scena dalla posizione calcolata:
# 1.0 e' il bordo esatto. Sopra 1.0 si taglia qualcosa, molto sotto si spreca
# il fotogramma. Il test ci si appoggia, cosi' l'inquadratura non si giudica
# a occhio.
static func riempimento(gs: GameState) -> float:
	return _ingombro(camera_position(gs), camera_target(gs), scene_aabb(gs))

# L'angolo di sguardo, in gradi sopra l'orizzonte. Serve al test: sotto una
# certa inclinazione le file dietro si occludono fra loro.
static func camera_pitch_deg(gs: GameState) -> float:
	var c := camera_position(gs)
	var t := camera_target(gs)
	var oriz := Vector2(t.x - c.x, t.z - c.z).length()
	return rad_to_deg(atan2(c.y - t.y, oriz))

# ---- dal clic allo slot --------------------------------------------
# Pura anche questa: prende un raggio (origine e direzione, in millimetri) e
# dice su quale slot cade. Il disegno e il clic leggono la stessa geometria.
# Restituisce {"col": int, "era": int} oppure {} se il raggio manca il tavolo.
static func slot_at_ray(gs: GameState, origine: Vector3, direzione: Vector3) -> Dictionary:
	if absf(direzione.y) < 0.00001: return {}
	var t := (TESSERA_Y - origine.y) / direzione.y
	if t < 0.0: return {}                       # il tavolo e' dietro la telecamera
	var p := origine + direzione * t
	var col := int(floor(p.x / TESSERA_W))
	if col < 0 or col >= gs.grid.n_cols: return {}
	if p.z < 0.0 or p.z >= board_d(): return {}
	var era := int(floor(p.z / SLOT_D)) + 1
	return {"col": col, "era": clampi(era, 1, RAILS), "punto": p}
