# res://scripts/tools/validate_data.gd
# Test di validazione della fonte unica dei dati.
# Uso:  godot --headless res://scenes/validate_data.tscn
# Esce con codice 1 se qualcosa non torna: utilizzabile in CI prima di ogni build.
extends Node

const DATA := "res://data/cards.json"
const SCHEMA := "res://data/cards.schema.json"

func _ready() -> void:
	var failures := 0
	failures += _validate_schema()
	failures += _check_sources_in_sync()
	if failures == 0:
		print("\nOK: i dati rispettano lo schema e le copie sono allineate.")
	else:
		printerr("\nFALLITO: %d controlli non superati." % failures)
	get_tree().quit(0 if failures == 0 else 1)

func _read_json(path: String):
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		printerr("impossibile aprire %s" % path)
		return null
	return JSON.parse_string(f.get_as_text())

func _validate_schema() -> int:
	var data = _read_json(DATA)
	var schema = _read_json(SCHEMA)
	if data == null or schema == null:
		return 1
	var v := SchemaValidator.new()
	if v.validate(data, schema):
		print("schema ....... OK (%d edifici, %d personaggi, %d potenziamenti, %d eventi, %d monumenti, %d eredita)" % [
			data["buildings"].size(), data["characters"].size(), data["upgrades"].size(),
			data["events"].size(), data["monuments"].size(), data["legacies"].size()])
		return 0
	printerr("schema ....... %d violazioni:" % v.errors.size())
	for e in v.errors: printerr("   - %s" % e)
	return 1

# Principio 3 del brief: fonte unica. Oggi data/cards.json esiste in due copie
# (radice del repo e godot/data/). Finche' restano due file, questo controllo
# impedisce che divergano in silenzio. Vedi docs/domande-aperte.md.
func _check_sources_in_sync() -> int:
	var proj := ProjectSettings.globalize_path("res://")
	var bad := 0
	for name in ["cards.json", "cards.schema.json"]:
		var root_copy := proj.path_join("../data/").path_join(name)
		var f := FileAccess.open(root_copy, FileAccess.READ)
		if f == null:
			print("sincronia .... copia radice %s non leggibile, controllo saltato" % name)
			continue
		var a := f.get_as_text()
		var g := FileAccess.open("res://data/".path_join(name), FileAccess.READ)
		var b := g.get_as_text() if g != null else ""
		if a == b:
			print("sincronia .... OK (%s identico fra data/ e godot/data/)" % name)
		else:
			printerr("sincronia .... DIVERGE: data/%s != godot/data/%s" % [name, name])
			bad += 1
	return bad
