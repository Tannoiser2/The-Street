# res://scripts/rules/era_rules.gd
# Attivazione di colonna, fine era (evento, censimento, dispersione), setup d'era.
class_name EraRules
extends RefCounted

# ---- attivazione --------------------------------------------------
# Il terreno produce per chi attiva; ogni edificio vivo paga il proprio proprietario;
# se la colonna è un Centro Urbano, ogni proprietario vivo riceve 1 oro.
# LE TESSERE UNA VOLTA PER ERA (punto 6 della proposta, registro 100): con la
# costante `tessere_una_volta_per_era` (vera nel file v2) l'effetto di ogni
# tessera scatta una volta per era, alla prima occasione, e poi la tessera
# si gira: pianura, -1 Costruzione a un edificio da 2 o 3 caselle; fiume, +1
# Denaro a chi la attiva; collina, +1 resistenza per l'era al primo edificio
# costruito qui; bosco, -1 Costruzione a una ristrutturazione. Nella v1.5 le
# stesse regole sono permanenti (e il fiume produce oro dalla base).
static func tessere_una_volta(gs: GameState) -> bool:
	return bool(CardDB.constants.get("tessere_una_volta_per_era", false))

static func tessera_disponibile(gs: GameState, col: int) -> bool:
	if col < 0 or col >= gs.tessere_usate.size(): return false
	return not gs.tessere_usate[col]

static func usa_tessera(gs: GameState, col: int, cosa: String) -> void:
	if col < 0 or col >= gs.tessere_usate.size(): return
	gs.tessere_usate[col] = true
	gs.log_line("La tessera della colonna %d si gira: %s" % [col, cosa])

static func activate(gs: GameState, player: int, col: int) -> void:
	var g := gs.grid
	var t_id: String = ["pianura", "fiume", "collina", "bosco"][g.terrains[col]]
	# Fiume, una volta per era: +1 Denaro a chi attiva.
	if tessere_una_volta(gs) and g.terrains[col] == Enums.Terrain.FIUME and tessera_disponibile(gs, col):
		gs.players[player].gain(0, 1)
		usa_tessera(gs, col, "+1 Denaro a giocatore %d" % player)
	var base = CardDB.terrains[t_id]["base_production"]
	# V2: la tessera produce secondo una curva per era (`base_production_by_era`,
	# punto 7 della proposta). Nei dati v1.5 la chiave non c'e' e vale la base fissa.
	var per_era = CardDB.terrains[t_id].get("base_production_by_era", null)
	if per_era != null and per_era.has(str(gs.era)): base = per_era[str(gs.era)]
	# "Anni della fame: nessuna produzione durante l'ultimo round dell'era."
	# Decisione del designer: salta la sola produzione BASE, e solo sull'ultimo
	# lavoratore che ciascuno piazza. Gli edifici pagano comunque. "Ultimo" si
	# calcola sul momento: chi compra la Dinastia guadagna un lavoratore e
	# sposta in avanti il proprio ultimo giro.
	if not (Effects.has_override(gs, "no_production_last_round") and _is_last_worker(gs, player)):
		var bp := int(base.get("pietra", 0))
		var bo := int(base.get("oro", 0))
		var bi := int(base.get("idee", 0))
		var be := Effects.production_bonus(gs, player, bp, bo)
		gs.players[player].gain(bp + be.x, bo + be.y, bi)
	else:
		gs.log_line("Anni della fame: giocatore %d non incassa la produzione base" % player)

	for b in g.alive_in_column(col):
		paga_edificio(gs, b)

	Effects.apply_on_activate(gs, player, col)

	# UNA VOLTA PER ERA (manopola `once_per_era`, spenta nei dati): la prima
	# attivazione di un Centro Urbano in un'era paga, le altre nella stessa
	# colonna no. Si prova per rendere la Prosperita' piu' rara senza toccarne
	# la soglia: la colonna resta un Centro, smette di essere un bancomat.
	var pr: Dictionary = CardDB.constants["prosperity"]
	var una_volta := bool(pr.get("once_per_era", false))
	if g.is_prosperity_center(col) and not (una_volta and g.prosperity_paid.has(col)):
		if una_volta: g.prosperity_paid[col] = true
		var gold := int(pr["gold_per_owner"])
		var chi := g.owners_alive_in(col)
		# Contatori per le misure: quante volte il Centro paga (a chi lo
		# attiva) e quanto oro porta a ciascuno.
		gs.players[player].bump("centro_attivato")
		for ow in chi:
			gs.players[ow].gain(0, gold)
			gs.players[ow].bump("oro_centro", gold)
		# A registro come gli altri incassi: il Centro Urbano paga tutti quelli
		# che hanno un edificio intatto li', non solo chi ha attivato, ed e'
		# l'unico premio del tabellone che paga anche gli avversari.
		gs.log_line("Centro Urbano in colonna %d: %d proprietari incassano %d oro"
			% [col, chi.size(), gold])

# La paga di UN edificio vivo: la sua produzione al proprietario, la quota dei
# firmatari, la carica della Cava. E' un pezzo dell'attivazione di colonna,
# estratto pari pari perche' nel turno v2 (registro 93) chi costruisce mette il
# lavoratore sull'edificio nuovo e attiva solo quello.
static func paga_edificio(gs: GameState, b: Building) -> void:
	var pr = b.data["production"]
	var ow: PlayerState = gs.players[b.owner]
	# Il Ponte alza cio' che l'edificio gia' produce, prima che si conti
	# se la produzione e' "di oro" per l'Industriale.
	var aura := Effects.aura_production_bonus(gs, b)
	var pp := int(pr.get("pietra", 0)) + int(aura["pietra"])
	var po := int(pr.get("oro", 0)) + int(aura["oro"])
	var pc := int(pr.get("cultura", 0)) + int(aura["cultura"])
	var pi := int(pr.get("idee", 0))      # v2: le Idee prodotte dagli edifici
	var ex := Effects.production_bonus(gs, b.owner, pp, po)
	ow.gain(pp + ex.x, po + ex.y, pi)
	if pc > 0:
		ow.add_vp("cultura", pc)
	# Artista di corte: chi ha firmato l'edificio altrui incassa la sua
	# quota. Non e' una produzione dell'edificio ma un taglio dell'artista,
	# quindi non conta per l'Industriale, come l'oro della Prosperita'.
	for chi in b.patrons:
		var quota := int(b.patrons[chi])
		if quota <= 0: continue
		gs.players[int(chi)].gain(0, quota)
		gs.log_line("%s: giocatore %d incassa %d oro come firmatario" % [b.data["name"], int(chi), quota])
	if int(b.data.get("exhaustible", 0)) > 0:
		b.charges -= 1
		if b.charges <= 0:
			# Senza rudere (manopola) la Cava vuota crolla in rovina: e'
			# l'unico altro modo di diventare rudere, e la manopola deve
			# togliere lo stato del tutto, se no `n_rudere` non e' zero e
			# la misura mente.
			if bool(CardDB.constants.get("senza_rudere", false)):
				b.state = Enums.BuildingState.ROVINA
				b.upgrades.clear()
				gs.log_line("%s si esaurisce e crolla in rovina" % b.data["name"])
			else:
				b.state = Enums.BuildingState.RUDERE
				gs.log_line("%s si esaurisce e diventa rudere" % b.data["name"])

# ---- evento --------------------------------------------------------
# Confronta la resistenza effettiva con la forza dell'era.
# Fallire di 1 -> rudere; di 2+ -> rovina; un rudere che fallisce crolla.
# Restituisce i proprietari che hanno perso un edificio: il potenziamento
# dell'Eruzione va a loro, ma DOVE lo decide il giocatore, quindi qui non si
# piazza nulla.
static func resolve_event(gs: GameState) -> Array[int]:
	var force := int(gs.current_event.get("force", 0))
	if force == 0: return [] as Array[int]
	var persi: Array[int] = []       # chi ha perso un edificio: ev_eruzione
	for b in gs.grid.buildings:
		if not b.is_standing(): continue
		var eff: int = b.effective_resistance() + Effects.event_resistance_modifier(gs, b)
		if eff >= force:
			# La Vetusta' cresce fino a `vetusta_max`; nella v2 e' 0, cioe'
			# la Vetusta' non esiste (registro 95).
			var vmax := int(CardDB.constants["vetusta_max"])
			if _on_terrain(gs, b, Enums.Terrain.BOSCO):
				vmax = int(CardDB.constants["vetusta_max_bosco"])
			b.vetusta = min(b.vetusta + 1, vmax)
			continue
		var gap := force - eff
		# QUANTO SI PUO' FALLIRE RESTANDO IN PIEDI. "Fallire di 1 -> rudere,
		# di 2+ -> rovina" e' la regola stampata, ed e' questa soglia: era
		# scritta come `gap == 1` dentro il codice, e una regola di
		# bilanciamento scritta nel codice non si puo' ne' leggere ne' provare
		# senza ricompilare. Adesso sta nei dati come tutte le altre.
		var soglia := int(CardDB.constants.get("rovina_gap", 2))
		if b.state == Enums.BuildingState.INTATTO and gap < soglia:
			# SENZA RUDERE (manopola `senza_rudere`, spenta nei dati): la
			# proposta della nuova meccanica toglie lo stato intermedio. Chi
			# fallisce di meno della soglia resta intatto, ma senza Vetusta':
			# non ha superato l'evento, l'ha solo scampato. Chi fallisce di
			# piu' crolla come oggi. E' la prima misura dell'audit (D15):
			# quanto vale il rudere da solo, prima di toccare il resto.
			if bool(CardDB.constants.get("senza_rudere", false)):
				gs.log_line("%s regge per un soffio: senza rudere resta intatto" % b.data["name"])
				continue
			b.state = Enums.BuildingState.RUDERE
			gs.log_line("%s diventa rudere" % b.data["name"])
		else:
			b.state = Enums.BuildingState.ROVINA
			b.upgrades.clear()
			if not b.owner in persi: persi.append(b.owner)
			gs.log_line("%s crolla in rovina" % b.data["name"])
	# Crollare puo' voler dire finire sotterrati: un edificio gia' coperto
	# dagli strati successivi restava in piedi finche' era intatto, e da
	# rovina diventa archeologia. Si ricalcola qui perche' questo e' l'unico
	# punto, oltre alla costruzione, in cui uno stato cambia da solo.
	gs.grid.refresh_buried()
	return persi

# ev_eruzione: "chi perde un edificio pesca un potenziamento gratis (massimo
# uno per giocatore)". Decisione del designer: "perdere" e' il crollo in
# rovina, non il passaggio a rudere; la carta si pesca dal mazzetto coperto
# dell'era e si piazza subito.
# DOVE si piazza e' una scelta del giocatore, quindi qui si pesca soltanto: il
# comando chiede il bersaglio e poi chiama `place_gift`.
static func draw_gifts(gs: GameState, persi: Array) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	if persi.is_empty(): return out
	var e := Effects.find_override(gs, "free_upgrade_on_loss")
	if e.is_empty(): return out
	var quante := int(e.get("times", 1))
	var deck: Array = gs.upg_decks.get(gs.era, [])
	for i in gs.turn_order:          # ordine di turno: il pescaggio e' deterministico
		if not int(i) in persi: continue
		if deck.is_empty(): return out
		var p: PlayerState = gs.players[i]
		var chiave := str(gs.current_event["id"])
		if int(p.effect_used.get(chiave, 0)) >= quante: continue
		if possible_hosts(gs, int(i)).is_empty(): continue   # non ha dove infilarla
		p.effect_used[chiave] = int(p.effect_used.get(chiave, 0)) + 1
		out.append({"player": int(i), "upg_id": str(deck.pop_back())})
	return out

static func place_gift(gs: GameState, omaggio: Dictionary, host: Building) -> void:
	if host == null: return
	var giocatore := int(omaggio["player"])
	var upg_id := str(omaggio["upg_id"])
	host.upgrades.append(upg_id)
	Effects.apply_on_acquire(gs, giocatore, CardDB.upgrades[upg_id], host)
	gs.log_line("%s: giocatore %d pesca %s e la infila sotto %s" % [
		gs.current_event["name"], giocatore, CardDB.upgrades[upg_id]["name"], host.data["name"]])

# Gli edifici che possono ospitare il potenziamento omaggio: tuoi, intatti e
# con capienza libera. L'interfaccia li offre tutti.
static func possible_hosts(gs: GameState, player: int) -> Array[Building]:
	var out: Array[Building] = []
	for b in gs.grid.buildings:
		if b.owner != player or not b.is_alive(): continue
		if b.upgrades.size() >= ActionRules.upgrade_capacity_for(gs, player, b): continue
		out.append(b)
	return out

# La scelta automatica, per chi non ha nessuno a cui chiedere: il bot e i test
# che chiamano `end_era` direttamente. Deterministica, in ordine di uid.
static func default_host(gs: GameState, player: int) -> Building:
	var out: Building = null
	for b in possible_hosts(gs, player):
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
			var quanto: int = b.rendita_value() + b.vetusta
			gs.players[b.owner].add_vp("rendita", quanto)
			b.rende("rendita", quanto)

# ---- dispersione dei secoli ---------------------------------------
# Si scarta a scelta del giocatore; il default scarta prima la pietra.
static func disperse(gs: GameState) -> void:
	var cap := int(CardDB.constants["resource_cap"])
	# V2 (registro 91): un tetto PER RISORSA, "tetto a tre"; 0 nei dati v1.5,
	# cioe' spento. Si applica prima del tetto totale, che resta com'e'.
	var per_risorsa := int(CardDB.constants.get("resource_cap_per_resource", 0))
	for p in gs.players:
		if per_risorsa > 0:
			p.pietra = mini(p.pietra, per_risorsa)
			p.oro = mini(p.oro, per_risorsa)
			p.idee = mini(p.idee, per_risorsa)
		var excess: int = p.total_resources() - cap
		if excess <= 0: continue
		var from_p: int = min(excess, p.pietra)
		p.pietra -= from_p
		# Poi l'oro, e per ultime le Idee (v2): con i dati v1.5 le Idee sono 0
		# e il conto e' quello di sempre.
		var from_o: int = min(excess - from_p, p.oro)
		p.oro -= from_o
		p.idee -= excess - from_p - from_o

# ---- scheletri: sepoltura dei personaggi ---------------------------
# "Nelle ere 1-4, a fine era il personaggio non si scarta: infilatelo sotto la
# carta di un vostro edificio ancora in piedi, uno solo per edificio."
# "I personaggi dell'era Moderna si scartano."
# I personaggi in eccesso rispetto agli edifici disponibili si scartano.
static func bury_characters(gs: GameState) -> void:
	if gs.era >= 5: return
	# V2 (registro 95): il Personaggio del draft non si seppellisce. Costante
	# `personaggi_sepolti`, vera dove manca (v1.5).
	if not bool(CardDB.constants.get("personaggi_sepolti", true)): return
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
# La fine dell'era per intero, con i bersagli scelti automaticamente. Il
# GameController usa invece i tre pezzi separati, perche' fra l'evento e il
# resto deve poter chiedere al giocatore dove infilare il potenziamento.
static func end_era(gs: GameState) -> void:
	var persi := resolve_event(gs)
	for omaggio in draw_gifts(gs, persi):
		place_gift(gs, omaggio, default_host(gs, int(omaggio["player"])))
	end_era_after_event(gs)

static func end_era_after_event(gs: GameState) -> void:
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
