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

# L'era 1 sta DAVANTI, cioe' dalla parte della telecamera, che guarda verso
# le z calanti. Con la telecamera dall'altro lato lo schermo specchierebbe la
# X e la colonna 0 finirebbe a destra: chi legge "colonna 2" guarderebbe dalla
# parte sbagliata.
static func rail_z(era: int) -> float:
	return (RAILS - era) * SLOT_D

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
		# sul davanti dello slot, cioe' dal lato della telecamera
		z = rail_z(b.era_built) + SLOT_D - BASETTA_D / 2.0
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

# Le misure della sagoma vera, da data/sagome.json. Se mancano - il file non
# c'e', o l'edificio non e' mappato - si ripiega sulla mediana misurata per
# quella larghezza: un numero preso dal cartone, non inventato.
const ALTEZZA_MEDIANA: Array[float] = [66.0, 66.0, 62.0, 74.0]

static func standee_size(b: Building) -> Vector2:
	var s: Dictionary = CardDB.sagome.get(str(b.data["id"]), {})
	if s.has("mm"):
		var mm: Array = s["mm"]
		return Vector2(float(mm[0]), float(mm[1]))
	var n: int = clampi(b.width(), 1, ALTEZZA_MEDIANA.size() - 1)
	return Vector2(span_w(b.width()), ALTEZZA_MEDIANA[n])

# Il file dell'illustrazione, nello stato giusto: a colori finche' l'edificio
# e' intatto, in grigio quando e' spento. Stringa vuota se non c'e' mappatura.
static func sagoma_path(b: Building) -> String:
	var s: Dictionary = CardDB.sagome.get(str(b.data["id"]), {})
	if not s.has("n"): return ""
	var variante := "colore" if b.state == Enums.BuildingState.INTATTO else "grigio"
	return "res://assets/sagome/%s/%02d.png" % [variante, int(s["n"])]

static func sky_rect(gs: GameState) -> AABB:
	var z := -CIELO_STACCO
	return AABB(Vector3(-TESSERA_W * 2.0, -20.0, z),
		Vector3(board_w(gs) + TESSERA_W * 4.0, CIELO_H, 0.0))

# L'inquadratura e' DERIVATA, non aggiustata a occhio: inclinazione fissa e
# distanza calcolata perche' la strada riempia il fotogramma. Cosi' vale per
# 5, 7 o 9 colonne senza ritoccare nulla.
#
# L'inclinazione e' un compromesso fra due cose che tirano in direzioni
# opposte, e va scelta coi numeri:
#   - piu' alta: le file dietro si vedono meglio, perche' la fila davanti le
#     copre meno;
#   - piu' bassa: le sagome si vedono meglio, perche' un cartone in piedi
#     guardato dall'alto si schiaccia col coseno.
# A 62 gradi le file erano tutte intere ma le sagome ridotte al 47%: con le
# illustrazioni sopra, illeggibili. A 45 gradi resta visibile l'82% di una
# sagoma dietro quella davanti e lo scorcio sale al 71%.
const FOV := 40.0
const INCLINAZIONE := 45.0      # gradi sopra l'orizzonte
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
	var t := table_aabb_piatto(gs)
	return Vector3(t.position.x + t.size.x / 2.0, altezza_scena(gs) * 0.38,
		t.position.z + t.size.z * 0.55)

# Come table_aabb ma senza chiamare camera_*: serve alla mira, e senza questa
# separazione le due funzioni si chiamerebbero a vicenda senza fine.
static func table_aabb_piatto(gs: GameState) -> AABB:
	var tutto := AABB(Vector3.ZERO, Vector3(board_w(gs), 0.0, board_d()))
	for c in side_cards(gs): tutto = tutto.merge(c["aabb"])
	for p in player_boards(gs): tutto = tutto.merge(p["aabb"])
	return tutto

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
	var dir := Vector3(0.0, sin(p), cos(p))
	var mira := camera_target(gs)
	var scatola := table_aabb(gs)
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
	return _ingombro(camera_position(gs), camera_target(gs), table_aabb(gs))

# Quanta parte di una sagoma resta visibile dietro quella della fila davanti,
# da 0 a 1. E' la meta' del compromesso dell'inclinazione; l'altra meta' e'
# lo scorcio, che vale semplicemente cos(inclinazione).
static func quota_visibile(altezza := 66.0) -> float:
	var nascosto: float = maxf(0.0, altezza - SLOT_D * tan(deg_to_rad(INCLINAZIONE)))
	return (altezza - nascosto) / altezza

static func scorcio() -> float:
	return cos(deg_to_rad(INCLINAZIONE))

# L'angolo di sguardo, in gradi sopra l'orizzonte.
static func camera_pitch_deg(gs: GameState) -> float:
	var c := camera_position(gs)
	var t := camera_target(gs)
	var oriz := Vector2(t.x - c.x, t.z - c.z).length()
	return rad_to_deg(atan2(c.y - t.y, oriz))

# ---- le file e le plance, sul tavolo --------------------------------
# Stanno nella scena e non in una sovrimpressione, perche' sul tavolo vero
# sono carte: si vedono, si indicano e si cliccano come tutto il resto.
# La carta misura 62,6 x 61,8 mm nel PDF: quadrata, in pratica.
const CARTA := 62.5
const CARTA_GAP := 8.0
const BORDO := 26.0          # stacco fra la strada e le file
const PLANCIA_D := 54.0      # profondita' della plancia di un giocatore

# Il mercato corre lungo il fianco SINISTRO della strada; personaggi,
# potenziamenti e monumenti lungo il DESTRO. Cosi' la strada resta libera e
# il tavolo si allarga di una carta per lato invece di allungarsi.
# Centrata sulla strada: una fila lunga sborda davanti e dietro in parti
# uguali invece di allungare il tavolo da un lato solo.
static func _colonna_di_carte(x: float, quante: int) -> Array[AABB]:
	var out: Array[AABB] = []
	if quante <= 0: return out
	var passo := CARTA + CARTA_GAP
	var z0 := board_d() / 2.0 - (quante * CARTA + (quante - 1) * CARTA_GAP) / 2.0
	for i in quante:
		out.append(AABB(Vector3(x, 0.0, z0 + i * passo),
			Vector3(CARTA, TESSERA_Y, CARTA)))
	return out

# Tutte le carte delle file, ognuna col suo riquadro: serve a disegnarle e a
# cliccarle. `kind` dice a quale fila appartiene, `id` quale carta e'.
static func side_cards(gs: GameState) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	var x_sx := -(CARTA + BORDO)
	var box_sx := _colonna_di_carte(x_sx, gs.market.size())
	for i in gs.market.size():
		out.append({"kind": "mercato", "id": str(gs.market[i]), "aabb": box_sx[i]})
	var destra: Array = []
	for id in gs.char_row: destra.append(["personaggio", str(id)])
	for id in gs.upg_row: destra.append(["potenziamento", str(id)])
	for id in gs.monuments_open: destra.append(["monumento", str(id)])
	var x_dx := board_w(gs) + BORDO
	var box_dx := _colonna_di_carte(x_dx, destra.size())
	for i in destra.size():
		out.append({"kind": str(destra[i][0]), "id": str(destra[i][1]), "aabb": box_dx[i]})
	return out

# Le plance dei giocatori, davanti alla strada: e' il posto del giocatore.
static func player_boards(gs: GameState) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	var largo := board_w(gs) / float(gs.n_players)
	var z := board_d() + BORDO      # davanti alla strada, dal lato di chi guarda
	for i in gs.n_players:
		out.append({"player": i, "aabb": AABB(
			Vector3(i * largo + 4.0, 0.0, z),
			Vector3(largo - 8.0, TESSERA_Y, PLANCIA_D))})
	return out

# Tutto il tavolo: strada, file e plance. E' questo che l'inquadratura deve
# far entrare, non la sola strada.
static func table_aabb(gs: GameState) -> AABB:
	var tutto := scene_aabb(gs)
	for c in side_cards(gs): tutto = tutto.merge(c["aabb"])
	for p in player_boards(gs): tutto = tutto.merge(p["aabb"])
	return tutto

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
	var era := RAILS - int(floor(p.z / SLOT_D))
	return {"col": col, "era": clampi(era, 1, RAILS), "punto": p}

# L'edificio colpito da un raggio: la sagoma sta IN PIEDI, quindi non basta
# intersecare il piano del tavolo come per gli slot e le carte. Si prova
# l'ingombro di ciascuna, e vince la piu' vicina alla telecamera.
# Restituisce l'uid, o -1.
static func at_ray_building(gs: GameState, origine: Vector3, direzione: Vector3) -> int:
	var migliore := -1
	var piu_vicino := INF
	for b in gs.grid.buildings:
		var base := standee_base(gs, b)
		var dim := standee_size(b)
		var box := AABB(
			Vector3(base.x - dim.x / 2.0, base.y, base.z - SAGOMA_SPESSORE * 2.0),
			Vector3(dim.x, dim.y + BASETTA_Y, SAGOMA_SPESSORE * 4.0))
		var t := _colpisce(box, origine, direzione)
		if t >= 0.0 and t < piu_vicino:
			piu_vicino = t
			migliore = b.uid
	return migliore

# Distanza a cui il raggio entra nella scatola, o -1 se la manca.
static func _colpisce(box: AABB, o: Vector3, d: Vector3) -> float:
	var t0 := -INF
	var t1 := INF
	for asse in 3:
		var od: float = d[asse]
		var oo: float = o[asse]
		var lo: float = box.position[asse]
		var hi: float = lo + box.size[asse]
		if absf(od) < 0.000001:
			if oo < lo or oo > hi: return -1.0
			continue
		var a := (lo - oo) / od
		var b := (hi - oo) / od
		t0 = maxf(t0, minf(a, b))
		t1 = minf(t1, maxf(a, b))
	if t1 < maxf(t0, 0.0): return -1.0
	return maxf(t0, 0.0)

# La carta di una fila sotto un raggio, se ce n'e' una. Stessa geometria del
# disegno: il giocatore clicca cio' che vede.
static func card_at_ray(gs: GameState, origine: Vector3, direzione: Vector3) -> Dictionary:
	if absf(direzione.y) < 0.00001: return {}
	var t := (TESSERA_Y - origine.y) / direzione.y
	if t < 0.0: return {}
	var p := origine + direzione * t
	for c in side_cards(gs):
		var r: AABB = c["aabb"]
		if p.x >= r.position.x and p.x <= r.position.x + r.size.x \
				and p.z >= r.position.z and p.z <= r.position.z + r.size.z:
			return c
	return {}
