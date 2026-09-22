# res://scripts/tools/schema_validator.gd
# Validatore JSON Schema minimale, guidato dal file di schema.
# Copre il sottoinsieme di draft 2020-12 usato da data/cards.schema.json:
#   type, required, properties, additionalProperties, items, minItems/maxItems,
#   minimum/maximum, enum, pattern, oneOf, $ref (#/$defs/...).
# Non e' un validatore generico: se lo schema cresce, va esteso qui.
class_name SchemaValidator
extends RefCounted

var _root: Dictionary = {}
var errors: Array[String] = []

func validate(instance, schema: Dictionary) -> bool:
	_root = schema
	errors.clear()
	_check(instance, schema, "$")
	return errors.is_empty()

func _err(path: String, msg: String) -> void:
	errors.append("%s: %s" % [path, msg])

func _resolve(schema: Dictionary) -> Dictionary:
	# Risolve i $ref locali della forma "#/$defs/nome".
	var guard := 0
	while schema.has("$ref") and guard < 16:
		var ref: String = str(schema["$ref"])
		if not ref.begins_with("#/$defs/"):
			return schema
		var key := ref.substr(8)
		var defs: Dictionary = _root.get("$defs", {})
		if not defs.has(key):
			return schema
		schema = defs[key]
		guard += 1
	return schema

func _type_ok(v, t: String) -> bool:
	match t:
		"object": return typeof(v) == TYPE_DICTIONARY
		"array": return typeof(v) == TYPE_ARRAY
		"string": return typeof(v) == TYPE_STRING or typeof(v) == TYPE_STRING_NAME
		"boolean": return typeof(v) == TYPE_BOOL
		"null": return typeof(v) == TYPE_NIL
		"number": return typeof(v) == TYPE_INT or typeof(v) == TYPE_FLOAT
		"integer":
			# JSON non distingue 3 da 3.0: accetta i float interi.
			if typeof(v) == TYPE_INT: return true
			return typeof(v) == TYPE_FLOAT and is_equal_approx(v, round(v))
	return true

func _check(v, raw_schema: Dictionary, path: String) -> void:
	var s := _resolve(raw_schema)

	if s.has("type"):
		var t = s["type"]
		var types: Array = t if typeof(t) == TYPE_ARRAY else [t]
		var ok := false
		for tt in types:
			if _type_ok(v, str(tt)): ok = true; break
		if not ok:
			_err(path, "tipo atteso %s, trovato %s" % [types, type_string(typeof(v))])
			return

	if s.has("enum"):
		var allowed: Array = s["enum"]
		var found := false
		for a in allowed:
			if typeof(a) in [TYPE_INT, TYPE_FLOAT] and typeof(v) in [TYPE_INT, TYPE_FLOAT]:
				if is_equal_approx(float(a), float(v)): found = true; break
			elif a == v:
				found = true; break
		if not found:
			_err(path, "valore %s non ammesso, attesi %s" % [JSON.stringify(v), allowed])

	if s.has("oneOf"):
		var matches := 0
		for sub in s["oneOf"]:
			var probe := SchemaValidator.new()
			probe._root = _root
			probe._check(v, sub, path)
			if probe.errors.is_empty(): matches += 1
		if matches != 1:
			_err(path, "oneOf soddisfatto da %d alternative (attesa 1)" % matches)

	if typeof(v) in [TYPE_INT, TYPE_FLOAT]:
		if s.has("minimum") and float(v) < float(s["minimum"]):
			_err(path, "%s < minimo %s" % [v, s["minimum"]])
		if s.has("maximum") and float(v) > float(s["maximum"]):
			_err(path, "%s > massimo %s" % [v, s["maximum"]])

	if typeof(v) == TYPE_STRING and s.has("pattern"):
		var re := RegEx.new()
		if re.compile(str(s["pattern"])) == OK and re.search(v) == null:
			_err(path, "\"%s\" non rispetta il pattern %s" % [v, s["pattern"]])

	if typeof(v) == TYPE_ARRAY:
		var arr: Array = v
		if s.has("minItems") and arr.size() < int(s["minItems"]):
			_err(path, "%d elementi, minimo %d" % [arr.size(), int(s["minItems"])])
		if s.has("maxItems") and arr.size() > int(s["maxItems"]):
			_err(path, "%d elementi, massimo %d" % [arr.size(), int(s["maxItems"])])
		if s.has("items"):
			for i in arr.size():
				_check(arr[i], s["items"], "%s[%d]" % [path, i])

	if typeof(v) == TYPE_DICTIONARY:
		var d: Dictionary = v
		for req in s.get("required", []):
			if not d.has(req):
				_err(path, "manca la chiave obbligatoria \"%s\"" % req)
		var props: Dictionary = s.get("properties", {})
		for k in props:
			if d.has(k):
				_check(d[k], props[k], "%s.%s" % [path, k])
		if s.get("additionalProperties", true) == false:
			for k in d:
				if not props.has(k):
					_err(path, "chiave non ammessa \"%s\"" % k)
