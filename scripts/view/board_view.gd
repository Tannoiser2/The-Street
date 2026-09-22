# res://scripts/view/board_view.gd
# Disegna la plancia leggendo la geometria da BoardLayout. Non tocca mai lo
# stato: lo legge e basta. Ogni modifica passa dal GameController.
extends Node2D

const COLORI_GIOCATORE: Array[Color] = [
	Color("#d9534f"), Color("#4a90d9"), Color("#5cb85c"), Color("#c9a227"),
]
const COLORI_TERRENO: Array[Color] = [
	Color("#8a7f5c"),   # pianura
	Color("#3f6f8f"),   # fiume
	Color("#7a6a55"),   # collina
	Color("#41613f"),   # bosco
]
const NOMI_TERRENO: Array[String] = ["Pianura", "Fiume", "Collina", "Bosco"]
const SFONDO := Color("#20222a")
const GRIGLIA := Color("#343845")
const TESTO := Color("#e8e6df")
const TESTO_FIOCO := Color("#9aa0ad")

var gs: GameState
var _font: Font = ThemeDB.fallback_font

func mostra(stato: GameState) -> void:
	gs = stato
	queue_redraw()

func _draw() -> void:
	if gs == null: return
	_disegna_intestazione()
	_disegna_quote()
	_disegna_griglia()
	_disegna_terreni()
	for t in BoardLayout.tiles(gs):
		_disegna_edificio(t)
	_disegna_pannelli()
	_disegna_plance()

func _disegna_intestazione() -> void:
	var ev: String = str(gs.current_event.get("name", "nessuno"))
	var forza := int(gs.current_event.get("force", 0))
	var testa := "Era %d di 5" % gs.era
	if not gs.current_event.is_empty():
		testa += "     Evento: %s (forza %d)" % [ev, forza]
	else:
		testa += "     L'era Moderna non ha evento"
	draw_string(_font, Vector2(BoardLayout.ORIGIN.x, 40), testa,
		HORIZONTAL_ALIGNMENT_LEFT, -1, 22, TESTO)
	var riga := ""
	for p in gs.players:
		riga += "G%d: %d PV · %d pietra · %d oro     " % [p.index, p.vp, p.pietra, p.oro]
	draw_string(_font, Vector2(BoardLayout.ORIGIN.x, 68), riga,
		HORIZONTAL_ALIGNMENT_LEFT, -1, 15, TESTO_FIOCO)

# I 5 binari vuoti, con l'era a sinistra di ciascuno.
func _disegna_griglia() -> void:
	for era in range(1, BoardLayout.RAILS + 1):
		for c in gs.grid.n_cols:
			var r := BoardLayout.rail_rect(gs, era, c)
			draw_rect(r, GRIGLIA, false, 1.0)
		var y := BoardLayout.rail_y(gs, era)
		draw_string(_font, Vector2(6, y + 34), "E%d" % era,
			HORIZONTAL_ALIGNMENT_LEFT, -1, 13, TESTO_FIOCO)

# Le quote della vista laterale: senza, una sagoma sospesa non dice a che
# livello sta.
func _disegna_quote() -> void:
	var m := BoardLayout.max_level(gs)
	if m == 0: return
	for lv in range(1, m + 1):
		var y: float = BoardLayout.ORIGIN.y + BoardLayout.stack_h(gs) \
			- BoardLayout.STACK_GAP - lv * (BoardLayout.LEVEL_H + BoardLayout.GUTTER)
		draw_line(Vector2(BoardLayout.ORIGIN.x, y + BoardLayout.LEVEL_H + 3),
			Vector2(BoardLayout.col_x(gs.grid.n_cols - 1) + BoardLayout.CELL.x, y + BoardLayout.LEVEL_H + 3),
			GRIGLIA, 1.0)
		draw_string(_font, Vector2(6, y + 22), "↑%d" % lv,
			HORIZONTAL_ALIGNMENT_LEFT, -1, 13, TESTO_FIOCO)

func _disegna_terreni() -> void:
	for c in gs.grid.n_cols:
		var r := BoardLayout.terrain_rect(gs, c)
		var t: int = gs.grid.terrains[c]
		draw_rect(r, COLORI_TERRENO[t], true)
		var etichetta: String = NOMI_TERRENO[t]
		if gs.grid.is_prosperity_center(c): etichetta += " ★"
		draw_string(_font, r.position + Vector2(6, 18), etichetta,
			HORIZONTAL_ALIGNMENT_LEFT, r.size.x - 8, 13, TESTO)

# Intatto: pieno. Rudere: pieno smorzato con una banda. Rovina: solo contorno.
# Sotterrato: tratteggio diagonale, perche' non e' uno stato ma una posizione.
func _disegna_edificio(t: Dictionary) -> void:
	var r: Rect2 = t["rect"]
	var c: Color = COLORI_GIOCATORE[int(t["owner"]) % COLORI_GIOCATORE.size()]
	var stato := int(t["state"])
	match stato:
		Enums.BuildingState.INTATTO:
			draw_rect(r, c, true)
		Enums.BuildingState.RUDERE:
			draw_rect(r, c.darkened(0.45), true)
		Enums.BuildingState.ROVINA:
			draw_rect(r, c.darkened(0.7), true)
	draw_rect(r, c.lightened(0.3) if stato == Enums.BuildingState.INTATTO else c.darkened(0.2), false, 2.0)

	# Sotterrato non e' uno stato ma una posizione: un velo, non una campitura,
	# altrimenti coprirebbe il nome dell'edificio che sta sotto.
	if bool(t["buried"]):
		draw_rect(r, Color(0.09, 0.09, 0.11, 0.55), true)
		var passo := 14.0
		var x := r.position.x
		while x < r.position.x + r.size.x:
			var x2: float = minf(x + r.size.y, r.position.x + r.size.x)
			draw_line(Vector2(x, r.position.y + r.size.y), Vector2(x2, r.position.y),
				Color(1, 1, 1, 0.13), 1.0)
			x += passo
	if bool(t["razed"]):
		draw_line(r.position + Vector2(4, 4), r.position + r.size - Vector2(4, 4),
			Color(0, 0, 0, 0.8), 2.0)

	var titolo: String = str(t["name"])
	var col_testo := TESTO if not bool(t["buried"]) else TESTO.darkened(0.25)
	draw_string(_font, r.position + Vector2(6, 16), titolo,
		HORIZONTAL_ALIGNMENT_LEFT, r.size.x - 10, 13, col_testo)

	# I cubetti: bianchi la Vetusta', neri la resistenza oltre la base.
	var segni := "res %d" % int(t["res"])
	if int(t["vetusta"]) > 0: segni += "  vet %d" % int(t["vetusta"])
	if int(t["upgrades"]) > 0: segni += "  pot %d" % int(t["upgrades"])
	if bool(t["protected"]): segni += "  lav"
	if str(t["character"]) != "": segni += "  sep"
	draw_string(_font, r.position + Vector2(6, r.size.y - 8), segni,
		HORIZONTAL_ALIGNMENT_LEFT, r.size.x - 10, 11, Color(1, 1, 1, 0.72))

# ---- le file laterali e le plance dei giocatori ---------------------
func _disegna_pannelli() -> void:
	for riga in BoardLayout.side_rows(gs):
		var r: Rect2 = riga["rect"]
		if str(riga["kind"]) == "titolo":
			draw_string(_font, r.position + Vector2(0, 17), str(riga["testo"]),
				HORIZONTAL_ALIGNMENT_LEFT, r.size.x, 16, TESTO)
			draw_line(r.position + Vector2(0, 21), r.position + Vector2(r.size.x, 21),
				GRIGLIA, 1.0)
			continue
		draw_rect(r, GRIGLIA.darkened(0.3), true)
		draw_string(_font, r.position + Vector2(6, 16), _etichetta(riga),
			HORIZONTAL_ALIGNMENT_LEFT, r.size.x - 10, 12, TESTO_FIOCO.lightened(0.25))

# Nome e costo: il giocatore deve poter decidere senza girare la carta.
func _etichetta(riga: Dictionary) -> String:
	var id := str(riga["id"])
	match str(riga["kind"]):
		"mercato":
			var d: Dictionary = CardDB.buildings[id]
			var c: Dictionary = d["cost"]
			return "%s — %dp %do · res %d · scavo %d" % [d["name"],
				int(c.get("pietra", 0)), int(c.get("oro", 0)),
				int(d["resistance"]), int(d["scavo"])]
		"personaggio":
			var d2: Dictionary = CardDB.characters[id]
			return "%s — %s" % [d2["name"], d2["class"]]
		"potenziamento":
			var d3: Dictionary = CardDB.upgrades[id]
			return "%s — %s" % [d3["name"], d3["family"]]
		"monumento":
			return str(CardDB.monuments[id]["name"]) if CardDB.monuments.has(id) else id
	return id

# La plancia di ciascun giocatore, sotto le file.
func _disegna_plance() -> void:
	var righe := BoardLayout.side_rows(gs)
	var y: float = BoardLayout.ORIGIN.y - 40.0
	if not righe.is_empty():
		var ultima: Rect2 = righe[righe.size() - 1]["rect"]
		y = ultima.position.y + ultima.size.y + BoardLayout.SECTION_GAP
	var x := BoardLayout.panel_x(gs)
	draw_string(_font, Vector2(x, y + 17), "Giocatori", HORIZONTAL_ALIGNMENT_LEFT,
		BoardLayout.PANEL_W, 16, TESTO)
	draw_line(Vector2(x, y + 21), Vector2(x + BoardLayout.PANEL_W, y + 21), GRIGLIA, 1.0)
	y += BoardLayout.ROW_H + BoardLayout.ROW_GAP
	for p in gs.players:
		var c: Color = COLORI_GIOCATORE[p.index % COLORI_GIOCATORE.size()]
		draw_rect(Rect2(Vector2(x, y + 4), Vector2(10, 14)), c, true)
		var turno := " ←" if p.index == gs.current_index else ""
		draw_string(_font, Vector2(x + 16, y + 16),
			"G%d  %d PV  ·  %dp %do  ·  lav %d/%d%s" % [p.index, p.vp, p.pietra, p.oro,
				p.workers_used, p.workers, turno],
			HORIZONTAL_ALIGNMENT_LEFT, BoardLayout.PANEL_W - 16, 12, TESTO)
		y += 17
		var extra := ""
		if p.has_dynasty: extra += "Dinastia  "
		for cid in p.specialized_characters:
			extra += "%s  " % CardDB.characters[cid]["name"]
		if extra != "":
			draw_string(_font, Vector2(x + 16, y + 12), extra,
				HORIZONTAL_ALIGNMENT_LEFT, BoardLayout.PANEL_W - 16, 11, TESTO_FIOCO)
			y += 14
		y += 6
