# res://scripts/rules/conditions.gd
# Valuta le condizioni di Monumenti ed Eredita'. Funzioni PURE.
#
# I Monumenti sono una CORSA: si reclamano nell'istante in cui la condizione e'
# soddisfatta, non a fine partita (decisione del designer). Le Eredita' invece
# si valutano una volta sola, nel conteggio finale.
#
# Alcune condizioni non sono ricavabili dalla plancia e richiedono contatori
# storici (pietra spesa in terrapieni, restauri, potenziamenti piazzati):
# stanno su PlayerState.counters e non si azzerano mai.
class_name Conditions
extends RefCounted

static func met(gs: GameState, player: int, cond: Dictionary) -> bool:
	if cond.is_empty(): return false
	if cond.has("min_era") and gs.era < int(cond["min_era"]): return false
	var t: Dictionary = cond.get("target", {})
	var n: int = int(cond.get("min", 1))
	match str(cond["op"]):
		"count_matching":      return _hits(gs, player, t).size() >= n
		"same_column_count":   return _max_per_colonna(gs, player, t) >= n
		"distinct_columns":    return _colonne(gs, player, t).size() >= n
		"consecutive_columns": return _consecutive(gs, player, t) >= n
		"all_terrains":        return _terreni(gs, player, t).size() >= CardDB.terrains.size()
		"all_eras":            return _ere(gs, player, t).size() >= int(CardDB.constants["eras"])
		"counter":             return int(gs.players[player].counters.get(cond["name"], 0)) >= n
	return false

static func _hits(gs: GameState, player: int, t: Dictionary) -> Array[Building]:
	var out: Array[Building] = []
	for b in gs.grid.buildings:
		if Effects.matches(gs, b, t, null, player): out.append(b)
	return out

# Il massimo numero di bersagli che stanno in una stessa colonna.
static func _max_per_colonna(gs: GameState, player: int, t: Dictionary) -> int:
	var best := 0
	for c in gs.grid.n_cols:
		var n := 0
		for b in _hits(gs, player, t):
			if b.covers(c): n += 1
		best = max(best, n)
	return best

static func _colonne(gs: GameState, player: int, t: Dictionary) -> Dictionary:
	var cols := {}
	for b in _hits(gs, player, t):
		for c in range(b.col_from, b.col_to): cols[c] = true
	return cols

# La piu' lunga sequenza di colonne consecutive occupate dai bersagli.
static func _consecutive(gs: GameState, player: int, t: Dictionary) -> int:
	var cols := _colonne(gs, player, t)
	var best := 0
	var run := 0
	for c in gs.grid.n_cols:
		run = run + 1 if cols.has(c) else 0
		best = max(best, run)
	return best

static func _terreni(gs: GameState, player: int, t: Dictionary) -> Dictionary:
	var out := {}
	for b in _hits(gs, player, t):
		for c in range(b.col_from, b.col_to): out[gs.grid.terrains[c]] = true
	return out

static func _ere(gs: GameState, player: int, t: Dictionary) -> Dictionary:
	var out := {}
	for b in _hits(gs, player, t): out[b.era_built] = true
	return out

# ---- Monumenti: la corsa ------------------------------------------
# Va richiamata dopo ogni cambiamento di stato. Il primo che soddisfa la
# condizione si prende il Monumento, che esce dalla corsa per tutti.
static func claim_monuments(gs: GameState) -> void:
	for mid in gs.monuments_open.duplicate():
		var m: Dictionary = CardDB.monuments[mid]
		for i in gs.turn_order:                      # a parita', l'ordine di turno decide
			var p: PlayerState = gs.players[int(i)]
			if met(gs, p.index, m["condition"]):
				p.monuments_claimed.append(mid)
				p.add_vp("monumenti", int(m["vp"]))
				gs.monuments_open.erase(mid)
				gs.log_line("%s reclamato dal giocatore %d (+%d PV)" % [m["name"], p.index, int(m["vp"])])
				break

# ---- Eredita': una volta sola, alla fine --------------------------
static func score_legacies(gs: GameState) -> void:
	for p in gs.players:
		if p.legacy_id == "" or not CardDB.legacies.has(p.legacy_id): continue
		var l: Dictionary = CardDB.legacies[p.legacy_id]
		if met(gs, p.index, l["condition"]):
			p.add_vp("eredita", int(l["vp"]))
			gs.log_line("Eredita' %s soddisfatta dal giocatore %d (+%d PV)" % [l["name"], p.index, int(l["vp"])])
