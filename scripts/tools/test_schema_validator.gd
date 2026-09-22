# res://scripts/tools/test_schema_validator.gd
# Verifica che il validatore RIFIUTI davvero i dati non conformi.
# Un validatore che approva tutto darebbe un falso verde.
# Uso:  godot --headless res://scenes/test_schema_validator.tscn
extends Node

var _passed := 0
var _failed := 0

func _ready() -> void:
	var schema = JSON.parse_string(FileAccess.open("res://data/cards.schema.json", FileAccess.READ).get_as_text())
	var good = JSON.parse_string(FileAccess.open("res://data/cards.json", FileAccess.READ).get_as_text())

	_expect_valid("dati originali", good, schema)

	# type
	_expect_invalid("era come stringa", _mut(good, func(d): d["buildings"][0]["era"] = "uno"), schema)
	# required
	_expect_invalid("manca 'resistance'", _mut(good, func(d): d["buildings"][1].erase("resistance")), schema)
	# enum (via $ref)
	_expect_invalid("classe inesistente", _mut(good, func(d): d["buildings"][2]["classes"] = ["agricoltura"]), schema)
	# enum letterale
	_expect_invalid("scavo fuori scala", _mut(good, func(d): d["buildings"][3]["scavo"] = 4), schema)
	# maximum
	_expect_invalid("resistenza 9", _mut(good, func(d): d["buildings"][4]["resistance"] = 9), schema)
	# minimum
	_expect_invalid("rendita negativa", _mut(good, func(d): d["buildings"][5]["rendita"] = -1), schema)
	# pattern sull'id
	_expect_invalid("id malformato", _mut(good, func(d): d["buildings"][6]["id"] = "Edificio Uno"), schema)
	# minItems/maxItems
	_expect_invalid("un edificio in meno", _mut(good, func(d): d["buildings"].pop_back()), schema)
	# enum annidato negli eventi
	_expect_invalid("severity sconosciuta", _mut(good, func(d): d["events"][0]["severity"] = "catastrofica"), schema)
	# forza evento fuori intervallo
	_expect_invalid("forza evento 7", _mut(good, func(d): d["events"][1]["force"] = 7), schema)
	# additionalProperties: false su cost
	_expect_invalid("risorsa sconosciuta nel costo", _mut(good, func(d): d["buildings"][7]["cost"]["legno"] = 1), schema)
	# chiave di primo livello mancante
	_expect_invalid("manca 'legacies'", _mut(good, func(d): d.erase("legacies")), schema)

	print("\n%d superati, %d falliti" % [_passed, _failed])
	get_tree().quit(0 if _failed == 0 else 1)

func _mut(base: Dictionary, f: Callable) -> Dictionary:
	var copy: Dictionary = base.duplicate(true)
	f.call(copy)
	return copy

func _expect_valid(label: String, inst, schema: Dictionary) -> void:
	var v := SchemaValidator.new()
	if v.validate(inst, schema): _ok(label, "accettati")
	else: _ko(label, "rifiutati a torto: %s" % str(v.errors.slice(0, 3)))

func _expect_invalid(label: String, inst, schema: Dictionary) -> void:
	var v := SchemaValidator.new()
	if v.validate(inst, schema): _ko(label, "ACCETTATO a torto")
	else: _ok(label, v.errors[0])

func _ok(label: String, detail: String) -> void:
	_passed += 1
	print("  [ok]   %-32s %s" % [label, detail])

func _ko(label: String, detail: String) -> void:
	_failed += 1
	printerr("  [KO]   %-32s %s" % [label, detail])
