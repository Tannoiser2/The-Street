# res://scripts/core/grid.gd
# La strada: 5 binari (ere) x N colonne (terreni).
# Un edificio a livello 0 occupa caselle del binario della sua era.
# Un edificio sopraelevato sta nello "stack" delle colonne che copre.
class_name Grid
extends RefCounted

var n_cols: int
var terrains: Array = []          # Enums.Terrain per colonna
var buildings: Array = []         # tutti gli edifici mai costruiti
var risen_this_era: Dictionary = {}  # colonna -> true se ha già guadagnato un livello in quest'era

func _init(cols: int, terrain_list: Array) -> void:
	n_cols = cols
	terrains = terrain_list

# --- interrogazioni -------------------------------------------------

func in_column(col: int) -> Array:
	return buildings.filter(func(b): return b.covers(col))

func standing_in_column(col: int) -> Array:
	return in_column(col).filter(func(b): return b.is_standing())

func alive_in_column(col: int) -> Array:
	return in_column(col).filter(func(b): return b.is_alive())

func rail_occupied(era: int, col_from: int, col_to: int) -> bool:
	for b in buildings:
		if b.level == 0 and b.era_built == era and b.col_from < col_to and b.col_to > col_from:
			return true
	return false

# L'elemento più alto non sotterrato che copre la colonna (la "cima").
func top_of(col: int) -> Building:
	var best: Building = null
	for b in in_column(col):
		if b.is_buried: continue
		if best == null or b.level > best.level or (b.level == best.level and b.era_built > best.era_built):
			best = b
	return best

func height(col: int) -> int:
	var h := 0
	for b in in_column(col):
		h = max(h, b.level)
	return h

func is_prosperity_center(col: int) -> bool:
	var alive := alive_in_column(col)
	var owners := {}
	for b in alive: owners[b.owner] = true
	var p = CardDB.constants["prosperity"]
	return alive.size() >= int(p["min_buildings"]) and owners.size() >= int(p["min_owners"])

func owners_alive_in(col: int) -> Array:
	var owners := {}
	for b in alive_in_column(col): owners[b.owner] = true
	return owners.keys()

func reset_era_flags() -> void:
	risen_this_era.clear()
