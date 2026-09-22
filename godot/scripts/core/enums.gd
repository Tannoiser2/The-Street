# res://scripts/core/enums.gd
# Enumerazioni condivise dal nucleo. Nessun riferimento a nodi o scene.
class_name Enums
extends RefCounted

enum Terrain { PIANURA, FIUME, COLLINA, BOSCO }

enum BuildingState {
	INTATTO,   # vivo: produce, rende, subisce eventi, ospita lavoratori
	RUDERE,    # in piedi ma spento: contendibile (restauro, spoliazione)
	ROVINA,    # crollato: fa da base, alza il livello
}
# NB: "Sotterrato" NON è uno stato ma una CONDIZIONE DI POSIZIONE
# (un edificio ha qualcosa costruito sopra). Vedi Building.is_buried.

enum Phase { PIAZZA, ATTIVA, AZIONE, FINE_ERA, FINE_PARTITA }

enum ActionType { NESSUNA, COSTRUISCI_BINARIO, COSTRUISCI_SOPRA, POTENZIA, RESTAURA, RECLUTA, DINASTIA }

enum BaseKind { RUDERE, ROVINA, PROPRIO_INTATTO, TERRAPIENO }

const CLASSES: Array[String] = ["militare", "religione", "commercio", "cultura", "civico", "ingegneria"]

static func terrain_from_string(s: String) -> int:
	match s:
		"pianura": return Terrain.PIANURA
		"fiume": return Terrain.FIUME
		"collina": return Terrain.COLLINA
		"bosco": return Terrain.BOSCO
	push_error("Terreno sconosciuto: %s" % s)
	return -1
