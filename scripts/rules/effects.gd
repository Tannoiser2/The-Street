# res://scripts/rules/effects.gd
# Motore degli effetti strutturati (M4). Legge il campo `effects` delle carte;
# nessuna stringa viene interpretata a runtime.
# Funzioni PURE tranne dove indicato: non modificano lo stato.
#
# Lo schema e' CHIUSO: hook, op, nomi di rule_override e predicati del selettore
# sono enumerati in data/cards.schema.json, quindi un refuso e' un errore di
# validazione invece di un effetto che non scatta in silenzio.
class_name Effects
extends RefCounted

# Override dichiarati nei dati ma NON ancora applicati dal motore.
# Elencarli qui e' deliberato: un test verifica che questo insieme sia esatto,
# cosi' non si puo' credere per sbaglio che siano attivi.
const NOT_YET_APPLIED: Array[String] = ["no_production_last_round", "free_upgrade_on_loss"]

# ---- accesso -------------------------------------------------------
static func of_event(gs: GameState) -> Array:
	return gs.current_event.get("effects", [])

static func find_override(gs: GameState, name: String) -> Dictionary:
	for e in of_event(gs):
		if e["op"] == "rule_override" and e["name"] == name:
			return e
	return {}

static func has_override(gs: GameState, name: String) -> bool:
	return not find_override(gs, name).is_empty()

# ---- selettore -----------------------------------------------------
# I predicati presenti valgono in AND. `source` serve solo ai predicati di
# adiacenza; se manca, quei predicati non possono essere soddisfatti.
static func matches(gs: GameState, b: Building, t: Dictionary, source: Building = null) -> bool:
	if t.is_empty(): return true

	if t.has("owner") and source != null:
		match str(t["owner"]):
			"self": if b.owner != source.owner: return false
			"others": if b.owner == source.owner: return false

	if t.has("class"):
		var hit := false
		for c in b.classes():
			if c in t["class"]: hit = true; break
		if not hit: return false

	if t.has("terrain"):
		var names: Array = t["terrain"]
		var hit2 := false
		for c in range(b.col_from, b.col_to):
			if _terrain_name(gs.grid.terrains[c]) in names: hit2 = true; break
		if not hit2: return false

	if t.has("state"):
		if not ["intatto", "rudere", "rovina"][b.state] in t["state"]: return false
	if t.has("buried") and b.is_buried != bool(t["buried"]): return false
	if t.has("protected") and (b.protection > 0) != bool(t["protected"]): return false
	if t.has("produces"):
		var pr: Dictionary = b.data["production"]
		var makes := int(pr.get("pietra", 0)) > 0 or int(pr.get("oro", 0)) > 0
		if makes != bool(t["produces"]): return false

	if not _in_range(b.level, t.get("level", {})): return false
	if not _in_range(b.width(), t.get("width", {})): return false
	if not _in_range(b.vetusta, t.get("vetusta", {})): return false
	if not _in_range(int(b.data["scavo"]), t.get("scavo", {})): return false
	if not _in_range(b.era_built, t.get("era", {})): return false

	if t.has("column") and not _column_ok(gs, b, t["column"]): return false

	if t.get("adjacent_to_self", false):
		if source == null or not _adjacent(b, source): return false
	if t.get("same_column_as_self", false):
		if source == null or not _shares_column(b, source): return false
	return true

# Una sola colonna dell'ingombro che soddisfi la condizione basta: l'edificio
# e' esposto anche li'.
static func _column_ok(gs: GameState, b: Building, spec: Dictionary) -> bool:
	for c in range(b.col_from, b.col_to):
		var standing := gs.grid.standing_in_column(c)
		var owners := {}
		var eras := {}
		for o in standing:
			owners[o.owner] = true
			eras[o.era_built] = true
		if spec.has("min_owners") and owners.size() < int(spec["min_owners"]): continue
		if spec.has("min_standing") and standing.size() < int(spec["min_standing"]): continue
		if spec.has("min_eras") and eras.size() < int(spec["min_eras"]): continue
		return true
	return false

static func _in_range(v: int, r: Dictionary) -> bool:
	if r.is_empty(): return true
	if r.has("min") and v < int(r["min"]): return false
	if r.has("max") and v > int(r["max"]): return false
	return true

static func _adjacent(a: Building, b: Building) -> bool:
	return a != b and a.col_from <= b.col_to and b.col_from <= a.col_to

static func _shares_column(a: Building, b: Building) -> bool:
	return a != b and a.col_from < b.col_to and b.col_from < a.col_to

static func _terrain_name(t: int) -> String:
	return ["pianura", "fiume", "collina", "bosco"][t]

# ---- op: resistance ------------------------------------------------
# Somma dei modificatori dell'evento corrente applicabili all'edificio.
# Sostituisce l'analisi testuale di effect_text.
static func event_resistance_modifier(gs: GameState, b: Building) -> int:
	var mod := 0
	for e in of_event(gs):
		if e["hook"] != "on_event" or e["op"] != "resistance": continue
		if matches(gs, b, e.get("target", {})):
			mod += int(e["value"])
	return mod

# ---- op: resource (applica) ----------------------------------------
# Unico effetto che modifica lo stato: lo fa il chiamante in rules/, non qui.
static func era_end_resources(gs: GameState) -> void:
	for e in of_event(gs):
		if e["hook"] != "on_era_end" or e["op"] != "resource": continue
		var dp := int(e.get("pietra", 0))
		var do_ := int(e.get("oro", 0))
		for p in gs.players:
			p.pietra = max(0, p.pietra + dp)
			p.oro = max(0, p.oro + do_)
		gs.log_line("%s: tutti %+d pietra %+d oro" % [gs.current_event.get("name", "evento"), dp, do_])
