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

# Che cosa il motore applica DAVVERO, oggi. Tutto il resto e' dichiarato nei
# dati ma inerte. Un test confronta questi due elenchi con cio' che le carte
# dichiarano: se qualcuno struttura un effetto nuovo senza implementarlo, il
# test lo segnala invece di lasciarlo passare per attivo.
const APPLIED_HOOK_OPS: Array[String] = [
	"on_event:resistance",      # i 24 eventi e le aure degli edifici
	"on_era_end:resource",      # ev_inverno_lungo
	"on_acquire:resource",      # "Subito: +N pietra/oro" dei personaggi
	"on_acquire:vp",            # "Subito: +N cultura"
	"on_final_scoring:vp",      # Osservatorio, Acquedotto, Caffe' letterario
	"on_final_scoring:vp_per",  # Museo, Biblioteca, Grattacielo, Universita'...
]
const APPLIED_OVERRIDES: Array[String] = ["first_terrapieno_free", "free_restore_of_class"]

# Elenco di tutto cio' che le carte dichiarano ma il motore non applica ancora.
static func pending() -> Array[String]:
	var out: Array[String] = []
	for block in [CardDB.events, CardDB.characters, CardDB.buildings, CardDB.upgrades]:
		for id in block:
			for e in block[id].get("effects", []):
				var key: String = "%s:%s" % [e["hook"], e["op"]]
				if e["op"] == "rule_override":
					if not e["name"] in APPLIED_OVERRIDES and not e["name"] in out:
						out.append(e["name"])
				elif not key in APPLIED_HOOK_OPS and not key in out:
					out.append(key)
	out.sort()
	return out

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

	if t.has("is_self"):
		if source == null: return false
		if (b == source) != bool(t["is_self"]): return false
	if t.has("is_top") and _is_top(gs, b) != bool(t["is_top"]): return false
	if t.get("below_self", false):
		if source == null or b.level >= source.level or not _shares_column(b, source): return false
	if t.get("adjacent_to_self", false):
		if source == null or not _adjacent(b, source): return false
	if t.get("same_column_as_self", false):
		if source == null or not _shares_column(b, source): return false
	return true

# In cima ad almeno una delle colonne che occupa.
static func _is_top(gs: GameState, b: Building) -> bool:
	for c in range(b.col_from, b.col_to):
		if gs.grid.top_of(c) == b: return true
	return false

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

# "Adiacente" vuol dire accanto, non sovrapposto: le colonne si toccano ma non
# si intersecano. Due edifici nella stessa colonna sono "same_column", non
# "adjacent".
static func _adjacent(a: Building, b: Building) -> bool:
	if a == b: return false
	if a.col_from < b.col_to and b.col_from < a.col_to: return false
	return a.col_to == b.col_from or b.col_to == a.col_from

# "i tuoi edifici in questa colonna" comprende anche la carta che porta
# l'effetto: e' uno dei tuoi edifici in quella colonna. Chi deve escludersi lo
# dice con `is_self: false` nel selettore (vedi Monumento ai caduti).
# Nota: "adiacente" invece esclude sempre se stessi, perche' un edificio non e'
# adiacente a se'. Vedi docs/domande-aperte.md punto 24.
static func _shares_column(a: Building, b: Building) -> bool:
	return a.col_from < b.col_to and b.col_from < a.col_to

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
	return mod + aura_resistance_modifier(gs, b)

# Aure di edificio: "Quartiere: +1 res ai tuoi edifici adiacenti", Castrum,
# Arsenale, Mura. La sorgente deve essere viva: un edificio spento non protegge.
static func aura_resistance_modifier(gs: GameState, b: Building) -> int:
	var mod := 0
	for src in gs.grid.buildings:
		if not src.is_alive(): continue
		for e in src.data.get("effects", []):
			if e["hook"] != "on_event" or e["op"] != "resistance": continue
			if matches(gs, b, e.get("target", {}), src):
				mod += int(e["value"])
	return mod

# ---- hook: on_acquire (applica) ------------------------------------
# "Subito:" dei personaggi. Applica solo resource e vp; gli altri op su
# on_acquire (l'Impronta dei due scultori) richiedono un edificio bersaglio
# che il comando di reclutamento non passa ancora.
static func apply_on_acquire(gs: GameState, player: int, card: Dictionary) -> void:
	var p: PlayerState = gs.players[player]
	for e in card.get("effects", []):
		if e["hook"] != "on_acquire": continue
		match str(e["op"]):
			"resource":
				p.gain(int(e.get("pietra", 0)), int(e.get("oro", 0)))
				gs.log_line("%s: %+d pietra %+d oro" % [card["name"], int(e.get("pietra", 0)), int(e.get("oro", 0))])
			"vp":
				p.add_vp("cultura", int(e["value"]))
				gs.log_line("%s: %+d cultura" % [card["name"], int(e["value"])])

# ---- hook: on_final_scoring (applica) -------------------------------
# Voce 7 del conteggio, "Effetti finali". Ogni edificio in gioco porta i propri
# effetti, in qualunque stato si trovi: le carte che richiedono di essere
# sopravvissute lo dicono con una `condition` esplicita (Osservatorio,
# Acquedotto), quindi il silenzio delle altre e' significativo.
const VP_CHANNEL := "effetti_finali"

static func apply_final_scoring(gs: GameState) -> void:
	for src in gs.grid.buildings:
		for e in src.data.get("effects", []):
			if e["hook"] != "on_final_scoring": continue
			if not _condition_met(gs, src, e.get("condition", {})): continue
			match str(e["op"]):
				"vp": _award(gs, src.owner, int(e.get("value", 0)), src)
				"vp_per": _apply_vp_per(gs, src, e)

static func _condition_met(gs: GameState, src: Building, cond: Dictionary) -> bool:
	if cond.is_empty(): return true
	if str(cond["op"]) != "count_matching": return true
	var n := 0
	for b in gs.grid.buildings:
		if matches(gs, b, cond.get("target", {}), src): n += 1
	return n >= int(cond["min"])

static func _apply_vp_per(gs: GameState, src: Building, e: Dictionary) -> void:
	var hits: Array[Building] = []
	for b in gs.grid.buildings:
		if matches(gs, b, e.get("target", {}), src): hits.append(b)
	# `times` limita QUANTI bersagli si contano ("fino a 2 tuoi edifici").
	# `cap` limita i PUNTI totali ("max +4"). Sono due cose diverse.
	if e.has("times"): hits = hits.slice(0, int(e["times"]))

	# A chi vanno i punti: di norma al proprietario della carta; col malus del
	# Grattacielo vanno invece a ciascun proprietario colpito.
	if str(e.get("to", "self")) == "target_owner":
		for b in hits: _award(gs, b.owner, int(e.get("value", 0)), src)
		return

	var pts := 0
	if e.has("value_from"):
		var field := str(e["value_from"])
		for b in hits:
			pts += b.level if field == "level" else int(b.data["scavo"])
	else:
		var v := int(e.get("value", 0))
		pts = v * _conta(gs, src, hits, str(e.get("per", "building")))
	if e.has("cap"): pts = min(pts, int(e["cap"]))
	_award(gs, src.owner, pts, src)

static func _conta(gs: GameState, src: Building, hits: Array[Building], per: String) -> int:
	match per:
		"distinct_class":
			var cls := {}
			for b in hits:
				for c in b.classes(): cls[c] = true
			return cls.size()
		"level":
			var n := 0
			for b in hits: n += b.level
			return n
		"upgrade":
			var n2 := 0
			for b in hits: n2 += b.upgrades.size()
			return n2
		"recruited_character":
			return gs.players[src.owner].recruited_total
	return hits.size()

static func _award(gs: GameState, player: int, pts: int, src: Building) -> void:
	if pts == 0: return
	gs.players[player].add_vp(VP_CHANNEL, pts)
	gs.log_line("%s: %+d PV a giocatore %d" % [src.data["name"], pts, player])

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
