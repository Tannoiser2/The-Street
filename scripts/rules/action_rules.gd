# res://scripts/rules/action_rules.gd
# Legalita' e costo delle azioni diverse dalla costruzione: potenziare,
# restaurare, reclutare, acquistare la Dinastia.
# Funzioni PURE: non modificano lo stato. L'applicazione avviene in commands/.
#
# Vincolo di colonna (regolamento, "Compi un'azione"): l'azione e' sempre legata
# alla colonna appena attivata. Solo la costruzione si estende a una colonna
# adiacente ("nella colonna che avete attivato o in una adiacente"); potenziare,
# restaurare e reclutare dicono "di quella colonna", quindi restano sulla stessa.
class_name ActionRules
extends RefCounted

class ActionQuote:
	var legal: bool = false
	var reason: String = ""
	var pietra: int = 0
	var oro: int = 0
	var idee: int = 0                # la terza risorsa (v2); 0 nei dati v1.5
	var target: Building = null      # edificio bersaglio, dove previsto

	static func no(r: String) -> ActionQuote:
		var q := ActionQuote.new()
		q.reason = r
		return q

	static func yes(p: int, o: int, t: Building = null, i: int = 0) -> ActionQuote:
		var q := ActionQuote.new()
		q.legal = true
		q.pietra = p
		q.oro = o
		q.idee = i
		q.target = t
		return q

# ---- potenziare ----------------------------------------------------
# "Potenziare costa 1 oro nelle prime tre ere e 2 nelle ultime due. Infilate la
# carta sotto un vostro edificio in piedi di quella colonna."
# "La capienza base e' di un potenziamento per edificio, salvo le carte che ne
# dichiarano di piu'." Quattro edifici ne dichiarano di piu' nel proprio testo
# (Chiesa, Abbazia, Accademia: 2 · Duomo: 3): il valore sta nel campo
# `upgrade_slots` della carta, non in un caso speciale nel codice.
const UPGRADE_CAPACITY_BASE := 1

static func upgrade_capacity(data: Dictionary) -> int:
	return int(data.get("upgrade_slots", UPGRADE_CAPACITY_BASE))

# La capienza puo' crescere per un effetto attivo (il Vescovo: "capienza dei
# tuoi Religione +1").
static func upgrade_capacity_for(gs: GameState, player: int, host: Building) -> int:
	return upgrade_capacity(host.data) + Effects.upgrade_slots_bonus(gs, player, host)

static func quote_upgrade(gs: GameState, player: int, upg_id: String, target: Building) -> ActionQuote:
	if not upg_id in gs.upg_row:
		return ActionQuote.no("potenziamento non disponibile nella fila")
	if target == null:
		return ActionQuote.no("nessun edificio bersaglio")
	# Artista di corte: "il primo potenziamento che piazzi su un edificio altrui".
	# E' l'unica eccezione al divieto del regolamento, "infilate la carta sotto
	# un VOSTRO edificio in piedi". Gratis, e fuori dal limite di capienza.
	var altrui := target.owner != player
	if altrui and Effects.player_override(gs, player, "upgrade_on_others_building").is_empty():
		return ActionQuote.no("l'edificio non e' tuo")
	# Decisione del designer: un potenziamento su un rudere non ha senso.
	# "in piedi" alla lettera includerebbe il rudere ("in piedi ma spento"),
	# ma si potenzia solo cio' che e' vivo. Vedi docs/domande-aperte.md punto 9.
	if not target.is_alive():
		return ActionQuote.no("l'edificio non e' intatto")
	if altrui:
		return ActionQuote.yes(0, 0, target)
	var cap := upgrade_capacity_for(gs, player, target)
	if target.upgrades.size() >= cap:
		return ActionQuote.no("l'edificio ha gia' %d potenziamenti (capienza %d)" % [target.upgrades.size(), cap])
	var data: Dictionary = CardDB.upgrades[upg_id]
	var cost: Dictionary = data["cost"]
	# Vescovo: "il prossimo potenziamento su un tuo edificio Religione in
	# quest'era costa 0". Decisione del designer: aspetta il primo Religione,
	# non si brucia se nel frattempo potenzi un edificio di un'altra classe.
	# Lo sconto e' percio' legato al bersaglio, non all'ordine delle azioni.
	if not Effects.player_override(gs, player, "free_upgrade_of_class", target).is_empty():
		return ActionQuote.yes(0, 0, target)
	# Sconti sui potenziamenti: Bottega d'artista, e il Cardinale sui Religione.
	var sconto := Effects.cost_delta(gs, player, "upgrade", target)
	return ActionQuote.yes(max(0, int(cost.get("pietra", 0)) + sconto.x),
						   max(0, int(cost.get("oro", 0)) + sconto.y), target,
						   int(cost.get("idee", 0)))

# ---- restaurare ----------------------------------------------------
# "pagate meta' del costo originale, arrotondato per eccesso, e torna intatto
# con la Vetusta' azzerata. Se il rudere era di un avversario, diventa vostro."
# Bosco: "il restauro costa 1 in meno" (applicato alla pietra: vedi domande-aperte).
static func quote_restore(gs: GameState, player: int, target: Building) -> ActionQuote:
	if target == null:
		return ActionQuote.no("nessun rudere bersaglio")
	if target.is_buried:
		return ActionQuote.no("l'edificio e' sotterrato")
	if target.state != Enums.BuildingState.RUDERE:
		return ActionQuote.no("non e' un rudere")
	# ev_secolarizzazioni: "durante l'era, restaurare un rudere Religione non
	# costa risorse (richiede comunque l'azione) e vale sui ruderi gia' presenti."
	var free := Effects.find_override(gs, "free_restore_of_class")
	if not free.is_empty() and Effects.matches(gs, target, free.get("target", {})):
		return ActionQuote.yes(0, 0, target)
	var c: Dictionary = target.data["cost"]
	var p := int(ceil(float(int(c["pietra"])) / 2.0))
	var o := int(ceil(float(int(c["oro"])) / 2.0))
	var i := int(ceil(float(int(c.get("idee", 0))) / 2.0))
	if _touches_terrain(gs, target, Enums.Terrain.BOSCO):
		p = max(0, p - 1)
	return ActionQuote.yes(p, o, target, i)

# ---- reclutare -----------------------------------------------------
# "Reclutare costa 1 oro e richiede che la classe del personaggio sia presente
# fra gli edifici in piedi della colonna."
# Lettura adottata: fra gli edifici INTATTI. Il regolamento elenca "la sua classe
# conta per il reclutamento" fra le proprieta' dell'intatto, e il rudere e'
# esplicitamente "spento". Vedi docs/domande-aperte.md.
static func quote_recruit(gs: GameState, player: int, char_id: String, col: int,
		imprint_target: Building = null) -> ActionQuote:
	if not char_id in gs.char_row:
		return ActionQuote.no("personaggio non disponibile nella fila")
	var data: Dictionary = CardDB.characters[char_id]
	if data.get("imprint", false):
		var why := imprint_reason(gs, player, data, imprint_target)
		if why != "": return ActionQuote.no(why)
	# "uno a tua scelta": la carta vuole un edificio designato, e lo stesso
	# parametro serve a passarlo. Senza, l'effetto non avrebbe bersaglio.
	elif Effects.requires_designation(data):
		var why2 := designation_reason(gs, player, data, imprint_target)
		if why2 != "": return ActionQuote.no(why2)
	var cls: String = data["class"]
	var found := false
	for b in gs.grid.alive_in_column(col):
		if cls in b.classes():
			found = true
			break
	if not found:
		return ActionQuote.no("nessun edificio intatto di classe %s nella colonna" % cls)
	return ActionQuote.yes(0, int(CardDB.constants["recruit_cost_oro"]))

# ---- Dinastia ------------------------------------------------------
# "Sempre disponibile fuori dalle file, nessuna classe richiesta." Costo a
# scalare da cost_by_era (ere 1-4), una sola per giocatore.
static func quote_dynasty(gs: GameState, player: int) -> ActionQuote:
	var p: PlayerState = gs.players[player]
	if p.has_dynasty:
		return ActionQuote.no("hai gia' una Dinastia")
	var data: Dictionary = CardDB.characters[dynasty_id()]
	var by_era: Dictionary = data["cost_by_era"]
	if not by_era.has(str(gs.era)):
		return ActionQuote.no("la Dinastia non si acquista nell'era %d" % gs.era)
	if gs.dynasties_left <= 0:
		return ActionQuote.no("nessuna Dinastia disponibile")
	var c: Dictionary = by_era[str(gs.era)]
	return ActionQuote.yes(int(c.get("pietra", 0)), int(c.get("oro", 0)), null, int(c.get("idee", 0)))

# "Impronta: infila questa carta sotto un tuo edificio" — il bersaglio e' una
# SCELTA del giocatore, non l'edificio abitato: va passato al comando.
# "Un edificio puo' portarne una sola."
static func imprint_reason(gs: GameState, player: int, data: Dictionary,
		target: Building) -> String:
	if target == null: return "l'Impronta richiede un edificio bersaglio"
	if target.owner != player: return "l'edificio non e' tuo"
	if not target.is_standing(): return "l'edificio non e' in piedi"
	if target.imprint != "": return "l'edificio porta gia' un'Impronta"
	for e in data.get("effects", []):
		if not Effects.matches(gs, target, e.get("target", {}), target, player):
			return "l'edificio non soddisfa il requisito dell'Impronta"
	return ""

# "Uno a tua scelta": l'edificio designato dev'essere tuo, in piedi, e
# soddisfare il selettore della carta (per l'Ingegnere militare: Militare).
static func designation_reason(gs: GameState, player: int, data: Dictionary,
		target: Building) -> String:
	if target == null: return "questa carta richiede un edificio a tua scelta"
	if target.owner != player: return "l'edificio non e' tuo"
	if not target.is_standing(): return "l'edificio non e' in piedi"
	if not Effects.matches(gs, target, Effects.designation_target(data), null, player):
		return "l'edificio non soddisfa il requisito della carta"
	return ""

# Gli edifici che si possono designare adesso: serve all'interfaccia, che deve
# offrirli tutti invece di sceglierne uno al posto del giocatore.
static func designation_candidates(gs: GameState, player: int, data: Dictionary) -> Array[Building]:
	var out: Array[Building] = []
	for b in gs.grid.buildings:
		if designation_reason(gs, player, data, b) == "": out.append(b)
	return out

static func imprint_candidates(gs: GameState, player: int, data: Dictionary) -> Array[Building]:
	var out: Array[Building] = []
	for b in gs.grid.buildings:
		if imprint_reason(gs, player, data, b) == "": out.append(b)
	return out

static func dynasty_id() -> String:
	for id in CardDB.characters:
		if CardDB.characters[id].get("is_dynasty", false):
			return id
	push_error("Nessuna carta Dinastia in cards.json")
	return ""

static func _touches_terrain(gs: GameState, b: Building, t: int) -> bool:
	for c in range(b.col_from, b.col_to):
		if gs.grid.terrains[c] == t:
			return true
	return false
