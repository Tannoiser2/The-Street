# res://scripts/view/board_layout.gd
# Geometria della plancia. PURA: nessun Node, nessun disegno, nessuna scena.
# Serve due volte - a disegnare e a capire dove il giocatore ha cliccato -
# cosi' le due cose non possono divergere.
#
# La strada e' 5 binari (le ere) x N colonne (i terreni). Un edificio a livello
# 0 sta sul binario della propria era; uno sopraelevato non sta su nessun
# binario, e va mostrato nella fascia in vista laterale sopra la griglia.
class_name BoardLayout
extends RefCounted

const CELL := Vector2(104.0, 56.0)   # una casella del binario
const GUTTER := 6.0
const ORIGIN := Vector2(28.0, 96.0)  # sotto l'intestazione
const LEVEL_H := 42.0                # altezza di un livello in vista laterale
const STACK_GAP := 22.0              # stacco fra vista laterale e binari
const TERRAIN_H := 26.0
const RAILS := 5

static func col_x(col: int) -> float:
	return ORIGIN.x + col * (CELL.x + GUTTER)

static func span_w(n_col: int) -> float:
	return n_col * CELL.x + (n_col - 1) * GUTTER

static func max_level(gs: GameState) -> int:
	var m := 0
	for b in gs.grid.buildings:
		m = maxi(m, b.level)
	return m

# Altezza della fascia laterale. Zero finche' nessuno ha sopraelevato: la
# fascia non deve occupare spazio in una partita tutta a livello 0.
static func stack_h(gs: GameState) -> float:
	var m := max_level(gs)
	if m == 0: return 0.0
	return m * (LEVEL_H + GUTTER) + STACK_GAP

static func rails_y(gs: GameState) -> float:
	return ORIGIN.y + stack_h(gs)

static func rail_y(gs: GameState, era: int) -> float:
	return rails_y(gs) + (era - 1) * (CELL.y + GUTTER)

static func terrain_y(gs: GameState) -> float:
	return rail_y(gs, RAILS) + CELL.y + GUTTER

static func rail_rect(gs: GameState, era: int, col: int) -> Rect2:
	return Rect2(Vector2(col_x(col), rail_y(gs, era)), CELL)

static func terrain_rect(gs: GameState, col: int) -> Rect2:
	return Rect2(Vector2(col_x(col), terrain_y(gs)), Vector2(CELL.x, TERRAIN_H))

# Il riquadro di un edificio: sul suo binario se sta a terra, nella fascia
# laterale alla propria quota se e' sopraelevato.
static func building_rect(gs: GameState, b: Building) -> Rect2:
	var w := span_w(b.width())
	if b.level == 0:
		return Rect2(Vector2(col_x(b.col_from), rail_y(gs, b.era_built)), Vector2(w, CELL.y))
	var y: float = ORIGIN.y + stack_h(gs) - STACK_GAP - b.level * (LEVEL_H + GUTTER)
	return Rect2(Vector2(col_x(b.col_from), y), Vector2(w, LEVEL_H))

# Tutto cio' che va disegnato per gli edifici, gia' ordinato: prima i
# sotterrati, poi il resto, cosi' chi sta sopra copre chi sta sotto.
static func tiles(gs: GameState) -> Array[Dictionary]:
	var sotto: Array[Dictionary] = []
	var sopra: Array[Dictionary] = []
	for b in gs.grid.buildings:
		var t := {
			"uid": b.uid,
			"rect": building_rect(gs, b),
			"owner": b.owner,
			"state": b.state,
			"buried": b.is_buried,
			"razed": b.was_razed,
			"level": b.level,
			"era": b.era_built,
			"name": str(b.data["name"]),
			"vetusta": b.vetusta,
			"res": b.effective_resistance(),
			"protected": b.protection > 0,
			"upgrades": b.upgrades.size(),
			"character": b.buried_character,
		}
		if b.is_buried: sotto.append(t)
		else: sopra.append(t)
	var out: Array[Dictionary] = []
	out.append_array(sotto)
	out.append_array(sopra)
	return out

# L'edificio sotto un punto, il piu' in alto per primo: e' il verso giusto per
# il clic, che deve prendere cio' che si vede, non cio' che e' coperto.
static func at(gs: GameState, pos: Vector2) -> Dictionary:
	var tt := tiles(gs)
	tt.reverse()
	for t in tt:
		if (t["rect"] as Rect2).has_point(pos): return t
	return {}

# La colonna sotto un punto, cercando nella striscia dei terreni e nei binari.
static func column_at(gs: GameState, pos: Vector2) -> int:
	for c in gs.grid.n_cols:
		var x := col_x(c)
		if pos.x < x or pos.x > x + CELL.x: continue
		if pos.y >= ORIGIN.y and pos.y <= terrain_y(gs) + TERRAIN_H: return c
	return -1

# ---- le file laterali ----------------------------------------------
# Mercato, personaggi, potenziamenti, monumenti: ogni carta ha il suo
# riquadro, cosi' cliccarla sara' solo questione di cercare il punto.
const PANEL_W := 300.0
const ROW_H := 24.0
const ROW_GAP := 3.0
const SECTION_GAP := 16.0

static func panel_x(gs: GameState) -> float:
	return col_x(gs.grid.n_cols - 1) + CELL.x + 34.0

static func side_rows(gs: GameState) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	var x := panel_x(gs)
	var y := ORIGIN.y - 40.0
	var sezioni := [
		["mercato", "Mercato", gs.market],
		["personaggio", "Personaggi", gs.char_row],
		["potenziamento", "Potenziamenti", gs.upg_row],
		["monumento", "Monumenti", gs.monuments_open],
	]
	for sez in sezioni:
		out.append({"kind": "titolo", "testo": str(sez[1]),
			"rect": Rect2(Vector2(x, y), Vector2(PANEL_W, ROW_H))})
		y += ROW_H + ROW_GAP
		for id in (sez[2] as Array):
			out.append({"kind": str(sez[0]), "id": str(id),
				"rect": Rect2(Vector2(x, y), Vector2(PANEL_W, ROW_H))})
			y += ROW_H + ROW_GAP
		y += SECTION_GAP
	return out

static func board_size(gs: GameState) -> Vector2:
	return Vector2(col_x(gs.grid.n_cols - 1) + CELL.x + ORIGIN.x,
		terrain_y(gs) + TERRAIN_H + ORIGIN.x)
