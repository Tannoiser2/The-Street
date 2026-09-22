# res://scripts/data/card_db.gd
# Carica data/cards.json: la FONTE UNICA dei dati di gioco.
# Registrare come Autoload con nome "CardDB".
extends Node

var constants: Dictionary = {}
var terrains: Dictionary = {}     # id -> dict
var buildings: Dictionary = {}    # id -> dict
var characters: Dictionary = {}
var upgrades: Dictionary = {}
var events: Dictionary = {}
var monuments: Dictionary = {}
var legacies: Dictionary = {}
var ruleset: String = ""
# Numero e misura reale della sagoma di ciascun edificio. NON e' un dato di
# gioco - non entra in nessuna regola - ma serve alla plancia per disegnare le
# proporzioni giuste anche quando le immagini non ci sono, perche' assets/ si
# rigenera e non e' versionata.
var sagome: Dictionary = {}       # id edificio -> {"n": int, "mm": [w, h]}
# Le tessere colonna stampate: varianti nominate dei quattro terreni. Anche
# queste NON sono dati di gioco - le loro regole non sono implementate, vedi
# data/tessere_pdf.json - servono solo a mettere il cartone vero sul tavolo.
var tessere: Array = []           # in ordine di stampa, solo quelle con un id
var tessere_per_terreno: Dictionary = {}   # "pianura" -> [id, id, ...]

const DB_PATH := "res://data/cards.json"
const SAGOME_PATH := "res://data/sagome.json"
const TESSERE_PATH := "res://data/tessere_pdf.json"

func _ready() -> void:
	load_db(DB_PATH)
	load_sagome(SAGOME_PATH)
	load_tessere(TESSERE_PATH)

func load_tessere(path: String) -> bool:
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null: return false        # senza, le colonne restano a tinta unita
	var parsed = JSON.parse_string(f.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY: return false
	for t in parsed.get("tessere", []):
		if t.get("id") == null: continue
		tessere.append(t)
		var terr := str(t["terreno"])
		if not tessere_per_terreno.has(terr): tessere_per_terreno[terr] = []
		tessere_per_terreno[terr].append(str(t["id"]))
	return true

func load_sagome(path: String) -> bool:
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null: return false        # senza, la plancia usa le proporzioni medie
	var parsed = JSON.parse_string(f.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY: return false
	for k in parsed:
		if str(k).begins_with("_"): continue
		sagome[k] = parsed[k]
	return true

func load_db(path: String) -> bool:
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		push_error("CardDB: impossibile aprire %s" % path)
		return false
	var parsed = JSON.parse_string(f.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("CardDB: JSON non valido")
		return false
	ruleset = parsed["meta"]["ruleset"]
	constants = parsed["constants"]
	for t in parsed["terrains"]: terrains[t["id"]] = t
	for b in parsed["buildings"]: buildings[b["id"]] = b
	for c in parsed["characters"]: characters[c["id"]] = c
	for u in parsed["upgrades"]: upgrades[u["id"]] = u
	for e in parsed["events"]: events[e["id"]] = e
	for m in parsed["monuments"]: monuments[m["id"]] = m
	for l in parsed["legacies"]: legacies[l["id"]] = l
	return true

func buildings_of_era(era: int) -> Array:
	return buildings.values().filter(func(b): return b["era"] == era)

func events_of_era(era: int) -> Array:
	return events.values().filter(func(e): return e["era"] == era)

func const_int(key: String, sub = null) -> int:
	var v = constants[key]
	if sub != null: v = v[str(sub)]
	return int(v)
