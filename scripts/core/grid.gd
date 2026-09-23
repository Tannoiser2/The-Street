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

# Una copia su cui provare: vedi Building.duplica.
func duplica() -> Grid:
	var g := Grid.new(n_cols, terrains.duplicate())
	for b in buildings:
		g.buildings.append(b.duplica())
	g.risen_this_era = risen_this_era.duplicate(true)
	return g

# --- interrogazioni -------------------------------------------------

func in_column(col: int) -> Array:
	return buildings.filter(func(b): return b.covers(col))

func standing_in_column(col: int) -> Array:
	return in_column(col).filter(func(b): return b.is_standing())

func alive_in_column(col: int) -> Array:
	return in_column(col).filter(func(b): return b.is_alive())

func rail_occupied(binario: int, col_from: int, col_to: int) -> bool:
	for b in buildings:
		if b.level == 0 and b.binario_effettivo() == binario \
			and b.col_from < col_to and b.col_to > col_from:
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

# --- sotterramento ---------------------------------------------------
# "Una rovina e' sotterrata quando l'unione degli strati successivi copre
# INTERAMENTE la sua proiezione, anche se quegli strati appartengono a ere
# diverse." Non basta che il nuovo edificio le stia sopra in una colonna:
# un edificio da 1 casella costruito su uno da 2 ne sotterra solo meta',
# e quella meta' non basta.
# Va ricalcolato su tutti gli edifici dopo ogni costruzione, perche' un nuovo
# strato puo' completare la copertura di un edificio coperto solo in parte
# molte ere prima.
# UNA ROVINA, non un edificio qualunque. La regola parla di rovine, e il
# simulatore di riferimento - su cui il gioco e' stato bilanciato - non
# sotterra mai un intatto: costruendo sopra, la base viene spianata
# (intatto -> rovina) oppure sotterrata (gia' rudere o rovina), e nessun
# altro edificio della colonna viene toccato.
# Senza questo, a quota zero una colonna porta fino a cinque edifici - uno
# per binario d'era - e il primo strato costruito sopra ne sotterrava
# CINQUE invece di uno: restavano "intatti e sepolti", smettevano di
# produrre e regalavano lo Scavo al proprietario. A fine partita sul
# tabellone restavano in piedi tre sagome su quaranta.
func refresh_buried() -> void:
	for b in buildings:
		b.is_buried = b.state == Enums.BuildingState.ROVINA and is_fully_covered(b)

# "L'unione degli strati successivi copre interamente la sua proiezione."
# GLI STRATI SUCCESSIVI SONO QUELLI CHE GLI POGGIANO SOPRA, non tutto quello
# che nella colonna sta piu' in alto. A quota zero una colonna porta fino a
# cinque edifici - uno per binario d'era, affiancati in profondita' - e chi
# costruisce sopra ne sceglie UNO come base: gli altri quattro restano
# scoperti, all'aria, con niente addosso. Guardando il solo livello, un
# edificio al livello 1 li seppelliva tutti e cinque: sul tabellone si vedeva
# una basetta marcata "sepolto" con sopra il vuoto.
#
# Si risale la catena: chi poggia su di lui, chi poggia su quelli, e cosi'
# via. E' sepolto se quella catena gli copre tutte le colonne.
func is_fully_covered(b: Building) -> bool:
	var sopra := _catena_sopra(b)
	if sopra.is_empty(): return false
	for c in range(b.col_from, b.col_to):
		var covered := false
		for o in sopra:
			if o.covers(c):
				covered = true
				break
		if not covered: return false
	return true

# Tutto quello che grava su `b`: chi lo ha per base, piu' chi ha per base
# quelli, fino in cima.
func _catena_sopra(b: Building) -> Array:
	var visti := {}
	var out: Array = []
	var coda: Array[int] = [b.uid]
	while not coda.is_empty():
		var uid: int = coda.pop_back()
		for o in buildings:
			if visti.has(o.uid) or not uid in o.basi: continue
			visti[o.uid] = true
			out.append(o)
			coda.append(o.uid)
	return out
