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
	# "Anni della fame: nessuna produzione durante l'ultimo round dell'era."
	# Decisione del designer: salta la sola produzione BASE, e solo sull'ultimo
	# lavoratore che ciascuno piazza. Gli edifici pagano comunque. "Ultimo" si
	# calcola sul momento: chi compra la Dinastia guadagna un lavoratore e
	# sposta in avanti il proprio ultimo giro.
	if not (Effects.has_override(gs, "no_production_last_round") and _is_last_worker(gs, player)):
		var bp := int(base["pietra"])
		var bo := int(base["oro"])
		var be := Effects.production_bonus(gs, player, bp, bo)
		gs.players[player].gain(bp + be.x, bo + be.y)
	else:
		gs.log_line("Anni della fame: giocatore %d non incassa la produzione base" % player)

	for b in g.alive_in_column(col):
		var pr = b.data["production"]
		var ow: PlayerState = gs.players[b.owner]
		# Il Ponte alza cio' che l'edificio gia' produce, prima che si conti
		# se la produzione e' "di oro" per l'Industriale.
		var aura := Effects.aura_production_bonus(gs, b)
		var pp := int(pr.get("pietra", 0)) + int(aura["pietra"])
		var po := int(pr.get("oro", 0)) + int(aura["oro"])
		var pc := int(pr.get("cultura", 0)) + int(aura["cultura"])
		var ex := Effects.production_bonus(gs, b.owner, pp, po)
		ow.gain(pp + ex.x, po + ex.y)
		if pc > 0:
			ow.add_vp("cultura", pc)
		if int(b.data.get("exhaustible", 0)) > 0:
			b.charges -= 1
			if b.charges <= 0:
				b.state = Enums.BuildingState.RUDERE
				gs.log_line("%s si esaurisce e diventa rudere" % b.data["name"])

	Effects.apply_on_activate(gs, player, col)

	if g.is_prosperity_center(col):
		var gold := int(CardDB.constants["prosperity"]["gold_per_owner"])
		for ow in g.owners_alive_in(col):
			gs.players[ow].gain(0, gold)

# ---- evento --------------------------------------------------------
# Confronta la resistenza effettiva con la forza dell'era.
# Fallire di 1 -> rudere; di 2+ -> rovina; un rudere che fallisce crolla.
static func resolve_event(gs: GameState) -> void:
	var force := int(gs.current_event.get("force", 0))
	if force == 0: return
	var persi: Array[int] = []       # chi ha perso un edificio: ev_eruzione
	for b in gs.grid.buildings:
		if not b.is_standing(): continue
		var eff: int = b.effective_resistance() + Effects.event_resistance_modifier(gs, b)
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
			if not b.owner in persi: persi.append(b.owner)
			gs.log_line("%s crolla in rovina" % b.data["name"])
	_free_upgrade_on_loss(gs, persi)

# ev_eruzione: "chi perde un edificio pesca un potenziamento gratis (massimo
# uno per giocatore)". Decisione del designer: "perdere" e' il crollo in
# rovina, non il passaggio a rudere; la carta si pesca dal mazzetto coperto
# dell'era e si piazza subito.
# Il bersaglio e' pero' una SCELTA del giocatore, e l'interfaccia non c'e'
# ancora: per ora va sul primo edificio intatto con capienza libera, in ordine
# di uid. Approssimazione dichiarata, come per l'Ingegnere militare: vedi
# docs/domande-aperte.md.
static func _free_upgrade_on_loss(gs: GameState, persi: Array) -> void:
	if persi.is_empty(): return
	var e := Effects.find_override(gs, "free_upgrade_on_loss")
	if e.is_empty(): return
	var quante := int(e.get("times", 1))
	var deck: Array = gs.upg_decks.get(gs.era, [])
	for i in gs.turn_order:          # ordine di turno: il pescaggio e' deterministico
		if not int(i) in persi: continue
		if deck.is_empty(): return
		var p: PlayerState = gs.players[i]
		var chiave := str(gs.current_event["id"])
		if int(p.effect_used.get(chiave, 0)) >= quante: continue
		var host := _primo_ospite_libero(gs, int(i))
		if host == null: continue    # nessun edificio dove infilarla: si perde
		var upg_id: String = deck.pop_back()
		p.effect_used[chiave] = int(p.effect_used.get(chiave, 0)) + 1
		host.upgrades.append(upg_id)
		Effects.apply_on_acquire(gs, int(i), CardDB.upgrades[upg_id], host)
		gs.log_line("%s: giocatore %d pesca %s e la infila sotto %s" % [
			gs.current_event["name"], int(i), CardDB.upgrades[upg_id]["name"], host.data["name"]])

static func _primo_ospite_libero(gs: GameState, player: int) -> Building:
	var out: Building = null
	for b in gs.grid.buildings:
		if b.owner != player or not b.is_alive(): continue
		if b.upgrades.size() >= ActionRules.upgrade_capacity_for(gs, player, b): continue
		if out == null or b.uid < out.uid: out = b
	return out

# I modificatori dell'evento vengono dal campo `effects` della carta (M4):
# nessuna stringa interpretata a runtime. Vedi Effects.event_resistance_modifier.

# L'ultimo lavoratore che quel giocatore piazza in quest'era. Il lavoratore e'
# gia' stato segnato quando si attiva, quindi "usati == disponibili" vuol dire
# che questo era l'ultimo.
static func _is_last_worker(gs: GameState, player: int) -> bool:
	var p: PlayerState = gs.players[player]
	return p.workers_used >= p.workers

static func _on_terrain(gs: GameState, b: Building, t: int) -> bool:
	for c in range(b.col_from, b.col_to):
		if gs.grid.terrains[c] == t: return true
	return false

# ---- censimento ----------------------------------------------------
# "Ogni vostro edificio in piedi paga la sua Rendita piu' la Vetusta'". Un
# edificio a Rendita 0 non paga nulla, nemmeno la Vetusta': la Vetusta' e' un
# moltiplicatore della Rendita, non una voce a se'. Gli Stalli mercantili
# possono percio' far pagare un edificio che prima taceva.
static func census(gs: GameState) -> void:
	for b in gs.grid.buildings:
		if b.is_alive() and b.rendita_value() > 0:
			gs.players[b.owner].add_vp("rendita", b.rendita_value() + b.vetusta)

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

# ---- scheletri: sepoltura dei personaggi ---------------------------
# "Nelle ere 1-4, a fine era il personaggio non si scarta: infilatelo sotto la
# carta di un vostro edificio ancora in piedi, uno solo per edificio."
# "I personaggi dell'era Moderna si scartano."
# I personaggi in eccesso rispetto agli edifici disponibili si scartano.
static func bury_characters(gs: GameState) -> void:
	if gs.era >= 5: return
	for p in gs.players:
		if p.specialized_characters.is_empty(): continue
		var hosts := gs.grid.buildings.filter(func(b):
			return b.owner == p.index and b.is_standing() and b.buried_character == "")
		var i := 0
		for cid in p.specialized_characters:
			if i >= hosts.size(): break
			var h: Building = hosts[i]
			h.buried_character = cid
			h.buried_character_era = gs.era
			gs.log_line("%s sepolto sotto %s" % [CardDB.characters[cid]["name"], h.data["name"]])
			i += 1

# ---- chiusura dell'era completa -----------------------------------
# L'ordine conta: l'evento precede il censimento ("si conta solo cio' che e'
# sopravvissuto"), e la sepoltura precede l'azzeramento dei personaggi.
static func end_era(gs: GameState) -> void:
	resolve_event(gs)
	Effects.era_end_resources(gs)
	Effects.apply_era_end_characters(gs)
	# Il censimento delle ere 1-4 si paga qui. Quello dell'era 5 NON si paga:
	# l'era Moderna non ha evento e il suo censimento E' il "Censimento finale",
	# voce 1 del conteggio di fine partita (Scoring._census_final). Pagarlo
	# anche qui lo conterebbe due volte.
	if gs.era < 5:
		census(gs)
	bury_characters(gs)
	# "Fra un'era e l'altra passano generazioni": la dispersione prepara l'era
	# successiva, e dopo l'era 5 non ce n'e' una. Decisione del designer
	# (domande-aperte punto 17): le risorse residue restano, perche' sono il
	# secondo criterio di spareggio.
	if gs.era < 5:
		disperse(gs)
	for b in gs.grid.buildings:
		b.protection = 0
		b.protected_by = -1
	# I personaggi dell'era Moderna non si seppelliscono, ma le loro abilita'
	# "Finale:" si pagano dopo: vanno messi da parte prima dell'azzeramento.
	if gs.era >= 5:
		for p in gs.players:
			p.final_characters.append_array(p.specialized_characters)
	for p in gs.players: p.reset_for_era()
	gs.grid.reset_era_flags()
