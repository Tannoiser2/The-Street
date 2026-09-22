# res://scripts/view/board_layout_3d.gd
# Geometria della plancia in 3D. PURA come la sorella 2D: nessun Node, nessuna
# mesh, solo posizioni. Serve a piazzare le sagome e a capire dove il giocatore
# ha cliccato, cosi' le due cose non possono divergere.
#
# Gli assi vengono dal tavolo vero:
#   X  le colonne, una tessera a fianco all'altra
#   Z  i 5 binari (le ere) in profondita'. ERA 1 DAVANTI, era 5 in fondo,
#      col pannello del cielo dietro l'ultima.
#   Y  le quote. Un edificio sopraelevato non appartiene a nessun binario:
#      poggia sugli edifici sotto di se', che gli fanno da basetta.
#
# I binari sono distanziati apposta: e' quello che lascia vedere le basette,
# cioe' gli edifici sepolti, invece di nasconderle sotto le sagome nuove.
class_name BoardLayout3D
extends RefCounted

const SLOT_W := 1.0          # larghezza di uno slot (una colonna)
const SLOT_D := 0.85         # profondita' di uno slot (un binario)
const GAP_X := 0.10          # stacco fra tessere colonna
const GAP_Z := 0.34          # stacco fra binari: e' cio' che rende visibili le basette
const TILE_Y := 0.06         # spessore della tessera stesa sul tavolo
const LEVEL_H := 1.05        # quanto sale una quota: mai meno dell'altezza
                             # di una sagoma, altrimenti due quote si compenetrano
const PLINTO_Y := 0.09       # il dado sotto una sagoma sopraelevata: solo il suo
                             # ingombro, non una lastra - la basetta VERA sono gli
                             # edifici sotto, che devono restare visibili
const RAILS := 5
const SKY_GAP := 1.2         # distanza del pannello del cielo dall'ultimo binario
const SKY_H := 7.5

static func col_x(col: int) -> float:
	return col * (SLOT_W + GAP_X)

static func rail_z(era: int) -> float:
	return (era - 1) * (SLOT_D + GAP_Z)

# Larghezza di un edificio che occupa n colonne: le tessere in mezzo tornano
# contigue, quindi lo stacco va contato n-1 volte.
static func span_w(n_col: int) -> float:
	return n_col * SLOT_W + (n_col - 1) * GAP_X

static func board_w(gs: GameState) -> float:
	return span_w(gs.grid.n_cols)

static func board_d() -> float:
	return RAILS * SLOT_D + (RAILS - 1) * GAP_Z

# Il centro di uno slot sul piano del tavolo.
static func slot_center(col: int, era: int) -> Vector3:
	return Vector3(col_x(col) + SLOT_W / 2.0, TILE_Y, rail_z(era) + SLOT_D / 2.0)

# La quota a cui poggia un edificio: 0 sul tavolo, altrimenti sopra le basette.
static func level_y(level: int) -> float:
	if level <= 0: return TILE_Y
	return TILE_Y + level * LEVEL_H

# Dove sta in piedi la sagoma di un edificio.
# A terra: al centro del proprio slot, sul binario della sua era.
# Sopraelevata: non ha binario, quindi poggia sulla basetta che copre l'intera
# profondita' della colonna, e sta sul BORDO DAVANTI di quella basetta - cosi'
# non si mette fra la telecamera e cio' che la sorregge.
static func standee_base(gs: GameState, b: Building) -> Vector3:
	var x := col_x(b.col_from) + span_w(b.width()) / 2.0
	if b.level == 0:
		return Vector3(x, level_y(0), rail_z(b.era_built) + SLOT_D / 2.0)
	# Senza binario: sta al centro della profondita' della colonna, cioe'
	# sopra il baricentro di cio' che la sorregge.
	return Vector3(x, level_y(b.level), board_d() / 2.0)

# Il plinto di una sopraelevazione: un dado sotto la sagoma, largo quanto lei
# e profondo uno slot. NON una lastra che copre la colonna: la basetta vera
# sono gli edifici sottostanti, che devono restare visibili.
static func base_box(gs: GameState, b: Building) -> AABB:
	var c := standee_base(gs, b)
	return AABB(Vector3(c.x - span_w(b.width()) / 2.0, c.y - PLINTO_Y, c.z - SLOT_D / 2.0),
		Vector3(span_w(b.width()), PLINTO_Y, SLOT_D))

static func tile_box(col: int, era: int) -> AABB:
	return AABB(Vector3(col_x(col), 0.0, rail_z(era)), Vector3(SLOT_W, TILE_Y, SLOT_D))

# Il pannello del cielo: dietro l'ultimo binario, largo quanto la strada.
static func sky_rect(gs: GameState) -> AABB:
	var z := rail_z(RAILS) + SLOT_D + SKY_GAP
	var largo := board_w(gs) + 4.0
	return AABB(Vector3(-2.0, -0.5, z), Vector3(largo, SKY_H, 0.0))

# La telecamera: davanti alla strada, alzata quel tanto che serve a vedere
# oltre la prima fila. Guarda il centro della plancia.
static func camera_position(gs: GameState) -> Vector3:
	var w := board_w(gs)
	return Vector3(w / 2.0, 5.0 + w * 0.32, rail_z(1) - 4.6 - w * 0.32)

static func camera_target(gs: GameState) -> Vector3:
	return Vector3(board_w(gs) / 2.0, 1.15, board_d() * 0.45)

# Altezza della sagoma. Le sagome vere sono ritagli con un rapporto attorno a
# 1, quindi la larghezza detta l'altezza: un edificio da tre colonne e' un
# cartone largo, non una torre. Il minimo tiene in piedi quelli da una colonna.
static func standee_size(b: Building) -> Vector2:
	var w := span_w(b.width())
	return Vector2(w, minf(LEVEL_H - 0.12, maxf(0.60, w * 0.42)))
