# res://scripts/rules/scoring.gd
# Conteggio finale: sette voci, nell'ordine del regolamento.
# I punti Lampo, Cultura e i censimenti delle ere 1-4 sono già sul segnapunti.
class_name Scoring
extends RefCounted

static func final_scoring(gs: GameState) -> void:
	_census_final(gs)
	_verticality(gs)
	_continuity(gs)
	_scavo(gs)
	_skeletons(gs)
	# TODO: _objectives(gs)  — Monumenti reclamati + Eredità segrete (condition_text)
	# TODO: _final_effects(gs) — Museo, Piazza monumentale, Biblioteca, eco, personaggi "Finale"

static func _census_final(gs: GameState) -> void:
	EraRules.census(gs)

# Metà del premio a chi ha la cima; metà divisa in proporzione agli edifici.
static func _verticality(gs: GameState) -> void:
	var vp_table = CardDB.constants["verticality_vp"]
	for col in gs.grid.n_cols:
		var h: int = gs.grid.height(col)
		if h < 1: continue
		var prize := int(vp_table[str(min(h, 4))])
		var owners := {}
		var total := 0
		for b in gs.grid.in_column(col):
			owners[b.owner] = owners.get(b.owner, 0) + 1
			total += 1
		var top := gs.grid.top_of(col)
		if top != null:
			gs.players[top.owner].add_vp("verticalita", prize / 2)
		for ow in owners:
			var share := int(round((prize / 2.0) * owners[ow] / float(total)))
			gs.players[ow].add_vp("verticalita", share)

static func _continuity(gs: GameState) -> void:
	var table = CardDB.constants["continuity_vp"]
	for col in gs.grid.n_cols:
		for p in gs.players:
			var count := {}
			for b in gs.grid.in_column(col):
				if b.owner != p.index: continue
				for c in b.classes(): count[c] = count.get(c, 0) + 1
			if count.is_empty(): continue
			var best: int = count.values().max()
			if best >= 3: p.add_vp("continuita", int(table["3"]))
			elif best >= 2: p.add_vp("continuita", int(table["2"]))

# Lo Scavo va al proprietario dell'edificio sotterrato; chi lo ha sotterrato
# ne prende 1 se non era suo. TODO: tracciare "sotterrato da" in Building.
static func _scavo(gs: GameState) -> void:
	for b in gs.grid.buildings:
		if b.is_buried:
			gs.players[b.owner].add_vp("scavo", b.scavo_value())

# Personaggi sepolti (ere 1-4): valgono 6 - era se il loro edificio è sotterrato.
static func _skeletons(gs: GameState) -> void:
	for b in gs.grid.buildings:
		if b.buried_character != "" and b.is_buried:
			gs.players[b.owner].add_vp("scheletri", 6 - b.buried_character_era)

static func winner(gs: GameState) -> int:
	var best := 0
	for i in range(1, gs.players.size()):
		var a: PlayerState = gs.players[i]
		var cur: PlayerState = gs.players[best]
		if a.vp > cur.vp: best = i
		elif a.vp == cur.vp:
			var alive_a := gs.grid.buildings.filter(func(b): return b.owner == i and b.is_alive()).size()
			var alive_c := gs.grid.buildings.filter(func(b): return b.owner == best and b.is_alive()).size()
			if alive_a > alive_c or (alive_a == alive_c and a.total_resources() > cur.total_resources()):
				best = i
	return best
