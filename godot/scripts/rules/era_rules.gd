# res://scripts/rules/era_rules.gd
# Attivazione di colonna, fine era (evento, censimento, dispersione), setup d'era.
class_name EraRules
extends RefCounted

# ---- attivazione --------------------------------------------------
# Il terreno produce per chi attiva; ogni edificio vivo paga il proprio proprietario;
# se la colonna è un Centro Urbano, ogni proprietario vivo riceve 1 oro.
static func activate(gs: GameState, player: int, col: int) -> void:
	var g := gs.grid
	var t_id: String = ["pianura", "fiume", "collina", "bosco"][g.terrains[col]]
	var base = CardDB.terrains[t_id]["base_production"]
	gs.players[player].gain(int(base["pietra"]), int(base["oro"]))

	for b in g.alive_in_column(col):
		var pr = b.data["production"]
		var ow: PlayerState = gs.players[b.owner]
		ow.gain(int(pr.get("pietra", 0)), int(pr.get("oro", 0)))
		if int(pr.get("cultura", 0)) > 0:
			ow.add_vp("cultura", int(pr["cultura"]))
		if int(b.data.get("exhaustible", 0)) > 0:
			b.charges -= 1
			if b.charges <= 0:
				b.state = Enums.BuildingState.RUDERE
				gs.log_line("%s si esaurisce e diventa rudere" % b.data["name"])

	if g.is_prosperity_center(col):
		var gold := int(CardDB.constants["prosperity"]["gold_per_owner"])
		for ow in g.owners_alive_in(col):
			gs.players[ow].gain(0, gold)
	# TODO: effetti "quando attivi" di edifici e personaggi (hook su effect_text).

# ---- evento --------------------------------------------------------
# Confronta la resistenza effettiva con la forza dell'era.
# Fallire di 1 -> rudere; di 2+ -> rovina; un rudere che fallisce crolla.
static func resolve_event(gs: GameState) -> void:
	var force := int(gs.current_event.get("force", 0))
	if force == 0: return
	for b in gs.grid.buildings:
		if not b.is_standing(): continue
		var eff: int = b.effective_resistance() + event_modifier(gs, b)
		if eff >= force:
			var vmax := int(CardDB.constants["vetusta_max"])
			if _on_terrain(gs, b, Enums.Terrain.BOSCO):
				vmax = int(CardDB.constants["vetusta_max_bosco"])
			b.vetusta = min(b.vetusta + 1, vmax)
			continue
		var gap := force - eff
		if b.state == Enums.BuildingState.INTATTO and gap == 1:
			b.state = Enums.BuildingState.RUDERE
			gs.log_line("%s diventa rudere" % b.data["name"])
		else:
			b.state = Enums.BuildingState.ROVINA
			b.upgrades.clear()
			gs.log_line("%s crolla in rovina" % b.data["name"])

# Modificatori dell'evento corrente.
# TODO: tradurre i 24 effect_text in modificatori strutturati. Per ora sono gestiti
# i due pattern più comuni; il resto va implementato carta per carta.
static func event_modifier(gs: GameState, b: Building) -> int:
	var txt: String = gs.current_event.get("effect_text", "")
	var mod := 0
	if txt.contains("colonne fiume") and _on_terrain(gs, b, Enums.Terrain.FIUME):
		mod -= 1
	for cls in Enums.CLASSES:
		var cap := cls.capitalize()
		if txt.contains(cap + " +1") and cls in b.classes(): mod += 1
		if txt.contains(cap + " −1") and cls in b.classes(): mod -= 1
		if txt.contains(cap + " −2") and cls in b.classes(): mod -= 2
	return mod

static func _on_terrain(gs: GameState, b: Building, t: int) -> bool:
	for c in range(b.col_from, b.col_to):
		if gs.grid.terrains[c] == t: return true
	return false

# ---- censimento ----------------------------------------------------
static func census(gs: GameState) -> void:
	for b in gs.grid.buildings:
		if b.is_alive() and int(b.data["rendita"]) > 0:
			gs.players[b.owner].add_vp("rendita", int(b.data["rendita"]) + b.vetusta)

# ---- dispersione dei secoli ---------------------------------------
# Si scarta a scelta del giocatore; il default scarta prima la pietra.
static func disperse(gs: GameState) -> void:
	var cap := int(CardDB.constants["resource_cap"])
	for p in gs.players:
		var excess: int = p.total_resources() - cap
		if excess <= 0: continue
		var from_p: int = min(excess, p.pietra)
		p.pietra -= from_p
		p.oro -= excess - from_p

# ---- chiusura dell'era completa -----------------------------------
static func end_era(gs: GameState) -> void:
	resolve_event(gs)
	census(gs)
	disperse(gs)
	for b in gs.grid.buildings: b.protection = 0
	for p in gs.players:
		p.workers_used = 0
		p.specialized_character = ""
	gs.grid.reset_era_flags()
