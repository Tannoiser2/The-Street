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
	var target: Building = null      # edificio bersaglio, dove previsto

	static func no(r: String) -> ActionQuote:
		var q := ActionQuote.new()
		q.reason = r
		return q

	static func yes(p: int, o: int, t: Building = null) -> ActionQuote:
		var q := ActionQuote.new()
		q.legal = true
		q.pietra = p
		q.oro = o
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

static func quote_upgrade(gs: GameState, player: int, upg_id: String, target: Building) -> ActionQuote:
	if not upg_id in gs.upg_row:
		return ActionQuote.no("potenziamento non disponibile nella fila")
	if target == null:
		return ActionQuote.no("nessun edificio bersaglio")
	if target.owner != player:
		return ActionQuote.no("l'edificio non e' tuo")
	# Decisione del designer: un potenziamento su un rudere non ha senso.
	# "in piedi" alla lettera includerebbe il rudere ("in piedi ma spento"),
	# ma si potenzia solo cio' che e' vivo. Vedi docs/domande-aperte.md punto 9.
	if not target.is_alive():
		return ActionQuote.no("l'edificio non e' intatto")
	var cap := upgrade_capacity(target.data)
	if target.upgrades.size() >= cap:
		return ActionQuote.no("l'edificio ha gia' %d potenziamenti (capienza %d)" % [target.upgrades.size(), cap])
	var data: Dictionary = CardDB.upgrades[upg_id]
	var cost: Dictionary = data["cost"]
	return ActionQuote.yes(int(cost.get("pietra", 0)), int(cost.get("oro", 0)), target)

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
	if _touches_terrain(gs, target, Enums.Terrain.BOSCO):
		p = max(0, p - 1)
	return ActionQuote.yes(p, o, target)

# ---- reclutare -----------------------------------------------------
# "Reclutare costa 1 oro e richiede che la classe del personaggio sia presente
# fra gli edifici in piedi della colonna."
# Lettura adottata: fra gli edifici INTATTI. Il regolamento elenca "la sua classe
# conta per il reclutamento" fra le proprieta' dell'intatto, e il rudere e'
# esplicitamente "spento". Vedi docs/domande-aperte.md.
static func quote_recruit(gs: GameState, player: int, char_id: String, col: int) -> ActionQuote:
	if not char_id in gs.char_row:
		return ActionQuote.no("personaggio non disponibile nella fila")
	var data: Dictionary = CardDB.characters[char_id]
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
	return ActionQuote.yes(int(c.get("pietra", 0)), int(c.get("oro", 0)))

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
