# res://scripts/tools/validate_data.gd
# Test di validazione della fonte unica dei dati.
# Uso:  godot --headless res://scenes/validate_data.tscn
# Esce con codice 1 se qualcosa non torna: utilizzabile in CI prima di ogni build.
extends Node

const DATA := "res://data/cards.json"
const DATA_V2 := "res://data/cards-v2.json"   # la v2 a tre risorse, generata
const SCHEMA := "res://data/cards.schema.json"

func _ready() -> void:
	var failures := 0
	failures += _validate_schema(DATA)
	# La v2 rispetta lo stesso schema (allargato alle Idee): un file generato
	# che non lo rispetta e' un errore del generatore, e si vede qui.
	if FileAccess.file_exists(DATA_V2): failures += _validate_schema(DATA_V2)
	failures += _check_no_duplicate_data()
	if failures == 0:
		print("\nOK: i dati rispettano lo schema e la fonte e' unica.")
	else:
		printerr("\nFALLITO: %d controlli non superati." % failures)
	get_tree().quit(0 if failures == 0 else 1)

func _read_json(path: String):
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		printerr("impossibile aprire %s" % path)
		return null
	return JSON.parse_string(f.get_as_text())

func _validate_schema(path: String) -> int:
	var data = _read_json(path)
	var schema = _read_json(SCHEMA)
	if data == null or schema == null:
		return 1
	var v := SchemaValidator.new()
	if v.validate(data, schema):
		print("schema %s OK (%d edifici, %d personaggi, %d potenziamenti, %d eventi, %d monumenti, %d eredita)" % [
			path.get_file(),
			data["buildings"].size(), data["characters"].size(), data["upgrades"].size(),
			data["events"].size(), data["monuments"].size(), data["legacies"].size()])
		return 0
	printerr("schema ....... %d violazioni:" % v.errors.size())
	for e in v.errors: printerr("   - %s" % e)
	return 1

# Principio 3 del brief: fonte unica. Il progetto Godot vive nella radice del
# repository, quindi res://data/cards.json E' il file master data/cards.json:
# una sola copia, nessuna sincronizzazione possibile da sbagliare.
# Questa guardia impedisce che un duplicato rientri di soppiatto.
func _check_no_duplicate_data() -> int:
	var strays: Array[String] = []
	_scan("res://", strays)
	if strays.is_empty():
		print("fonte unica ... OK (una sola copia di cards.json, in res://data/)")
		return 0
	printerr("fonte unica ... trovate copie fuori da res://data/:")
	for s in strays: printerr("   - %s" % s)
	printerr("   La fonte unica e' data/cards.json. Rimuovi i duplicati.")
	return 1

func _scan(dir_path: String, strays: Array[String]) -> void:
	var d := DirAccess.open(dir_path)
	if d == null: return
	d.list_dir_begin()
	var entry := d.get_next()
	while entry != "":
		if entry.begins_with("."):
			entry = d.get_next()
			continue
		var full := dir_path.path_join(entry)
		if d.current_is_dir():
			_scan(full, strays)
		elif entry in ["cards.json", "cards.schema.json"] and not full.begins_with("res://data/"):
			strays.append(full)
		entry = d.get_next()
	d.list_dir_end()
