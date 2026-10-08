# res://scripts/rules/build_rules.gd
# Legalità e costo delle costruzioni. Funzioni PURE: non modificano lo stato.
# L'applicazione avviene in commands/, che chiama queste funzioni per validare.
class_name BuildRules
extends RefCounted

# Risultato di una valutazione: legale?, costo finale, livello, basi trovate, motivo.
class BuildQuote:
	var legal: bool = false
	var reason: String = ""
	var pietra: int = 0
	var oro: int = 0
	var idee: int = 0              # la terza risorsa: nessuno sconto la tocca
	var level: int = 0
	var bases: Array = []          # Building che finiranno sotterrati
	var razed: Array = []          # tuoi intatti che verrebbero spianati
	# LE COLONNE, non quante sono: la vista deve sapere DOVE la terra e' stata
	# riportata, per disegnare il riempimento sotto l'edificio. Prima era un
	# contatore e il terrapieno non si vedeva: l'edificio restava sospeso
	# sopra il vuoto in quella colonna.
	var terrapieno_cols: Array[int] = []
	var continuity_bonus: int = 0
	var despoiled: Building = null   # rudere depredato, diventa rovina prima di costruire
	var terrapieno_free_applied: bool = false
	var terrapieno_pietra: int = 0   # pietra effettivamente spesa in terrapieni
	var binario: int = 0             # il binario scelto, quando si costruisce a terra
	# Le tessere scavo che finiscono sotto il nuovo edificio (una per casella
	# che poggia su una rovina con tessere): il bonus scavo del registro 151.
	var tessere_sotto: int = 0

# ---- requisiti di terreno -----------------------------------------
# Morbidi per pianura/collina/bosco (colonna o adiacente), stretti per fiume.
static func terrain_ok(gs: GameState, data: Dictionary, col_from: int, col_to: int,
		player: int = -1) -> bool:
	var req = data.get("terrain")
	if req == null: return true
	# Mastro costruttore: "puoi costruire in qualsiasi slot".
	if player >= 0 and Effects.has_active_override(gs, player, "ignore_terrain_requirement"):
		return true
	# Tessera dell'era "Terra di nessuno" (registro 121).
	if TessereEra.ignora_terreno(gs, col_from, col_to): return true
	var g := gs.grid
	if req == "fiume":
		for c in range(col_from, col_to):
			if g.terrains[c] == Enums.Terrain.FIUME: return true
		return false
	var want := Enums.terrain_from_string(req)
	var found := false
	for c in range(max(0, col_from - 1), min(g.n_cols, col_to + 1)):
		if g.terrains[c] == want: found = true; break
	if not found: return false
	# `terrain_adjacent`: un secondo terreno richiesto in una colonna ADIACENTE
	# (il Mulino: "la colonna e' Pianura ed e' adiacente a una colonna Fiume").
	# E' un campo della carta, non un caso speciale nel codice.
	var adj = data.get("terrain_adjacent")
	if adj == null: return true
	var want2 := Enums.terrain_from_string(adj)
	for c in [col_from - 1, col_to]:
		if c >= 0 and c < g.n_cols and g.terrains[c] == want2: return true
	return false

# ---- spoliazione ---------------------------------------------------
# "Quando costruite potete depredare un rudere esposto nella colonna della
# costruzione o in una adiacente: diventa subito rovina - restando del suo
# proprietario - e vi sconta 1, 2 o 3 pietra secondo la sua taglia, mai piu' del
# costo in pietra della costruzione. Si risolve prima di costruire, quindi quel
# rudere non vi dara' la continuita' di classe, e sostituisce lo sconto macerie:
# i due non si sommano."
static func despoil_reason(gs: GameState, target: Building, col_from: int, col_to: int) -> String:
	if target == null: return ""
	if target.is_buried: return "il rudere e' sotterrato, non e' esposto"
	if target.state != Enums.BuildingState.RUDERE: return "il bersaglio della spoliazione non e' un rudere"
	# esposto nella colonna della costruzione o in una adiacente
	for c in range(max(0, col_from - 1), min(gs.grid.n_cols, col_to + 1)):
		if target.covers(c): return ""
	return "il rudere non e' nella colonna della costruzione ne' in una adiacente"

static func base_cost(data: Dictionary) -> Vector2i:
	return Vector2i(int(data["cost"]["pietra"]), int(data["cost"]["oro"]))

# Le Idee (v2) stanno accanto a pietra e oro nel costo; nei dati v1.5 mancano
# e valgono 0. Nessun effetto le sconta: i `cost_delta` parlano di pietra e oro.
static func base_idee(data: Dictionary) -> int:
	return int(data["cost"].get("idee", 0))

static func pianura_discount(gs: GameState, data: Dictionary, col_from: int) -> int:
	# Con le tessere dell'era lo sconto e' la tessera "Campi arati", non la pianura.
	if TessereEra.attive(): return 0
	if int(data["width"]) >= 2 and gs.grid.terrains[col_from] == Enums.Terrain.PIANURA:
		# V2 (registro 100): lo sconto e' l'effetto della tessera, una volta per era.
		if EraRules.tessere_una_volta(gs) and not EraRules.tessera_disponibile(gs, col_from): return 0
		return 1
	return 0

# ---- quale binario -------------------------------------------------
# NORMALMENTE OGNI ERA HA IL SUO: si costruisce a terra solo nel binario
# dell'era corrente, e quando e' pieno l'unico modo di continuare e' salire.
# Sulle 10 000 partite misurate ogni era tranne la quinta chiede piu' caselle
# di quante il suo binario ne abbia - l'era 2 ne chiede 9,6 su 7 - quindi
# salire non e' una strategia, e' uno sfratto.
#
# CON I BINARI LIBERI (la prova: `binari_liberi` fra le costanti, spento) un
# edificio puo' finire su qualunque binario ancora libero in quelle colonne, e
# SI RIEMPIE DAL FONDO: il piu' lontano che ha posto. Nessuna scelta in piu'
# per chi gioca - la regola sceglie da sola - solo piu' terreno: 35 caselle
# per tutta la partita invece di 7 per era, contro le 39,7 che servono. Salire
# torna a essere una scelta con un costo.
# Il fondo si riempie per primo anche per come scorre il tempo: chi gioca
# l'era 1 trova i binari in fondo vuoti, l'era 2 prende quel che resta e si
# sposta avanti. La citta' si stratifica in profondita' da sola.
#
# CON LE CASELLE (registro 122) il binario lo sceglie chi costruisce: i binari
# non sono le ere, si parte dal fondo solo per comodita'. `voluto` e' quella
# scelta (0 = il piu' in fondo libero), `profondita` i binari che la carta
# occupa: devono stare tutti dentro la tessera e tutti liberi.
static func binario_per(gs: GameState, col_from: int, col_to: int,
		profondita := 1, voluto := 0) -> int:
	if not bool(CardDB.constants.get("binari_liberi", false)):
		return 0 if gs.grid.rail_occupied(gs.era, col_from, col_to) else gs.era
	var ultimo := int(CardDB.constants["rails"]) - profondita + 1
	if voluto > 0:
		if voluto > ultimo or gs.grid.rail_occupied(voluto, col_from, col_to, profondita): return 0
		return voluto
	for r in range(1, ultimo + 1):
		if not gs.grid.rail_occupied(r, col_from, col_to, profondita): return r
	return 0

# ---- costruzione nel proprio binario ------------------------------
static func quote_rail(gs: GameState, player: int, data: Dictionary, col_from: int,
		despoil: Building = null, voluto := 0) -> BuildQuote:
	var q := BuildQuote.new()
	var w := int(data["width"])
	var col_to := col_from + w
	if col_from < 0 or col_to > gs.grid.n_cols:
		q.reason = "fuori dalla strada"; return q
	if int(data["era"]) != gs.era:
		q.reason = "non è un edificio dell'era corrente"; return q
	# I colossali di forma nuova (registro 122) non vanno mai a terra: si
	# costruiscono solo sopra, con le regole di sempre (rovine, propri attivi
	# spianati, terrapieno sulle caselle vuote, almeno una base vera).
	# V3 (registro 166): le carte grandi con `a_terra_o_sopra` (nel file dati
	# della v3) vanno anche a terra, con le regole di tutti; il designer, "a
	# terra oppure sopra". Sopra restano le regole della v2.
	var a_terra := bool(data.get("a_terra_o_sopra", false))
	if bool(data.get("solo_su_rovine", false)) and not a_terra:
		q.reason = "va costruito sopra: rovine o propri edifici da spianare"; return q
	var binario := binario_per(gs, col_from, col_to, int(data.get("depth", 1)), voluto)
	if binario == 0:
		q.reason = "caselle occupate nel binario"; return q
	q.binario = binario
	if int(data["level_required"]) > 0 and not a_terra:
		q.reason = "richiede livello %d: va costruito sopra" % data["level_required"]; return q
	if not terrain_ok(gs, data, col_from, col_to, player):
		q.reason = "terreno non adatto"; return q
	var dr := despoil_reason(gs, despoil, col_from, col_to)
	if dr != "":
		q.reason = dr; return q
	var c := base_cost(data)
	var sconto := Effects.cost_delta(gs, player, "building",
		Effects.sonda(data, player, col_from, 0))
	var te := TessereEra.sconto_costruzione(gs, player, data, col_from, 0, [])
	var p := c.x - pianura_discount(gs, data, col_from) + sconto.x - int(te["pietra"])
	p = _apply_despoil(q, despoil, p)
	q.pietra = max(0, p)
	q.oro = max(0, c.y + sconto.y - int(te["oro"]))
	q.idee = max(0, base_idee(data) - int(te["idee"]))
	q.level = 0
	q.legal = true
	return q

# Lo sconto vale la taglia del rudere e non puo' superare la pietra ancora dovuta.
static func _apply_despoil(q: BuildQuote, despoil: Building, pietra_so_far: int) -> int:
	if despoil == null: return pietra_so_far
	q.despoiled = despoil
	var discount: int = min(despoil.width(), max(0, pietra_so_far))
	return pietra_so_far - discount

# ---- costruzione sopra --------------------------------------------
# Ogni colonna dell'impronta offre una base valida (rudere/rovina di chiunque,
# oppure un proprio intatto da spianare) o richiede terrapieno.
# Almeno una colonna deve avere una base vera. Cap: +1 livello per colonna per era.
static func quote_above(gs: GameState, player: int, data: Dictionary, col_from: int,
		despoil: Building = null, voluto := 0) -> BuildQuote:
	if Grid.caselle(): return _quote_above_caselle(gs, player, data, col_from, despoil, voluto)
	var q := BuildQuote.new()
	var g := gs.grid
	var w := int(data["width"])
	var col_to := col_from + w
	if col_from < 0 or col_to > g.n_cols:
		q.reason = "fuori dalla strada"; return q
	if int(data["era"]) != gs.era:
		q.reason = "non è un edificio dell'era corrente"; return q
	if not terrain_ok(gs, data, col_from, col_to, player):
		q.reason = "terreno non adatto"; return q
	var dr := despoil_reason(gs, despoil, col_from, col_to)
	if dr != "":
		q.reason = dr; return q

	var top_level := -1
	var real_bases := 0
	var spolia := 0
	var rubble_discount := false
	for c in range(col_from, col_to):
		if g.risen_this_era.get(c, false):
			q.reason = "la colonna %d è già salita di un livello in quest'era" % c; return q
		var top := g.top_of(c)
		if top == null:
			q.terrapieno_cols.append(c)
			top_level = max(top_level, 0)
			continue
		if top.solo_su_rovine() and top.state != Enums.BuildingState.ROVINA:
			q.reason = "sopra %s si costruisce solo quando e' in rovina" % top.data["name"]; return q
		match top.state:
			Enums.BuildingState.INTATTO:
				if top.owner != player:
					q.reason = "un edificio intatto altrui blocca la colonna %d" % c; return q
				# NON SI SPIANA LA STESSA ERA (v3, costante `spiana_solo_ere_precedenti`,
				# registro 161): il designer, "non si possono spianare edifici della
				# stessa era, ma solo ere precedenti". Toglie la casa messa sopra il
				# proprio edificio appena costruito.
				if bool(CardDB.constants.get("spiana_solo_ere_precedenti", false)) and top.era_built >= gs.era:
					q.reason = "%s e' di quest'era: si spiana solo il passato" % top.data["name"]; return q
				# SPIANARE CHE COSTA (registro 152, manopola `spianare_costo`):
				# al posto dello sconto, 1 Costruzione per ogni casella demolita.
				if CardDB.constants.has("spianare_costo"):
					spolia -= int(CardDB.constants["spianare_costo"])
					if not top in q.razed: q.razed.append(top)
				elif not top in q.razed:
					q.razed.append(top)
					# Le spoglie valgono meta' della resistenza; con la scala
					# 1-10 del registro 200 un quarto (`spolia_divisore`), se no
					# spianare un Dolmen da 10 regalava 5 Costruzione.
					spolia += int(ceil(float(top.data["resistance"] + top.bonus_res) / float(CardDB.constants.get("spolia_divisore", 2))))
			Enums.BuildingState.RUDERE:
				# Il rudere depredato e' gia' rovina quando si costruisce:
				# non offre continuita' di classe.
				if top != despoil and top.shares_class_with(data): q.continuity_bonus = 1
			Enums.BuildingState.ROVINA:
				# Manopola `sconto_macerie_solo_altrui` (registro 87): lo
				# sconto vale solo costruendo sopra le rovine degli altri,
				# per dare un motivo di non seppellire sempre i propri.
				if top.owner != player or not bool(CardDB.constants.get("sconto_macerie_solo_altrui", false)):
					rubble_discount = true
				if TessereScavo.quante(top) > 0: q.tessere_sotto += 1
		if not top in q.bases: q.bases.append(top)
		real_bases += 1
		top_level = max(top_level, top.level + 1)
	if real_bases == 0:
		q.reason = "almeno una colonna deve avere una base vera"; return q

	q.level = max(1, top_level)
	if int(data["level_required"]) > q.level:
		q.reason = "richiede livello %d" % data["level_required"]; return q

	var c := base_cost(data)
	# ev_bonifiche: "Il primo terrapieno di ogni giocatore in quest'era costa 0."
	# Lettura adottata: il primo SLOT di terrapieno, non l'intera costruzione.
	var billable := q.terrapieno_cols.size()
	if billable > 0 and Effects.has_override(gs, "first_terrapieno_free") \
			and not gs.players[player].terrapieno_free_used:
		billable -= 1
		q.terrapieno_free_applied = true
	q.terrapieno_pietra = billable * int(CardDB.constants["terrapieno_cost_pietra"])
	var p := c.x + q.terrapieno_pietra
	p -= pianura_discount(gs, data, col_from)
	p -= spolia
	# Lo sconto macerie non si somma alla spoliazione: la sostituisce.
	if rubble_discount and despoil == null: p -= int(CardDB.constants["rubble_discount_pietra"])
	p = _apply_despoil(q, despoil, p)
	var sconto := Effects.cost_delta(gs, player, "building",
		Effects.sonda(data, player, col_from, q.level))
	var te := TessereEra.sconto_costruzione(gs, player, data, col_from, q.level, q.bases)
	q.pietra = max(0, p + sconto.x - int(te["pietra"]))
	q.oro = max(0, c.y + sconto.y - int(te["oro"]))
	q.idee = max(0, base_idee(data) - int(te["idee"]))
	q.legal = true
	return q

# ---- costruzione sopra, a caselle (registro 122) ---------------------
# Come quote_above, ma ogni casella dell'impronta (colonne x binari) ha la sua
# cima: le basi sono le cime di quelle caselle, non di tutta la colonna. Il
# terrapieno si paga per casella vuota: e' la terra che si mette sotto la
# carta. Se il binario non e' scelto si prova ogni binario e si tiene il
# preventivo legale piu' economico (a parita', il piu' in fondo).
static func _quote_above_caselle(gs: GameState, player: int, data: Dictionary, col_from: int,
		despoil: Building, voluto: int) -> BuildQuote:
	var prof := int(data.get("depth", 1))
	var ultimo := int(CardDB.constants["rails"]) - prof + 1
	if voluto > 0:
		if voluto > ultimo:
			var q0 := BuildQuote.new()
			q0.reason = "la carta esce dalla tessera"; return q0
		return _quote_sopra_binario(gs, player, data, col_from, despoil, voluto)
	var migliore: BuildQuote = null
	var primo: BuildQuote = null
	for r in range(1, ultimo + 1):
		var q := _quote_sopra_binario(gs, player, data, col_from, despoil, r)
		if primo == null: primo = q
		if not q.legal: continue
		if migliore == null or q.pietra + q.oro + q.idee < migliore.pietra + migliore.oro + migliore.idee:
			migliore = q
	return migliore if migliore != null else primo

static func _quote_sopra_binario(gs: GameState, player: int, data: Dictionary, col_from: int,
		despoil: Building, binario: int) -> BuildQuote:
	var q := BuildQuote.new()
	var g := gs.grid
	var w := int(data["width"])
	var prof := int(data.get("depth", 1))
	var col_to := col_from + w
	if col_from < 0 or col_to > g.n_cols:
		q.reason = "fuori dalla strada"; return q
	if int(data["era"]) != gs.era:
		q.reason = "non è un edificio dell'era corrente"; return q
	if not terrain_ok(gs, data, col_from, col_to, player):
		q.reason = "terreno non adatto"; return q
	var dr := despoil_reason(gs, despoil, col_from, col_to)
	if dr != "":
		q.reason = dr; return q
	q.binario = binario
	var top_level := -1
	var real_bases := 0
	var vuote := 0
	var spolia := 0
	var rubble_discount := false
	for c in range(col_from, col_to):
		if g.risen_this_era.get(c, false):
			q.reason = "la colonna %d è già salita di un livello in quest'era" % c; return q
		for r in range(binario, binario + prof):
			var top := g.top_of_casella(c, r)
			if top == null:
				vuote += 1
				if not c in q.terrapieno_cols: q.terrapieno_cols.append(c)
				top_level = max(top_level, 0)
				continue
			if top.solo_su_rovine() and top.state != Enums.BuildingState.ROVINA:
				q.reason = "sopra %s si costruisce solo quando e' in rovina" % top.data["name"]; return q
			match top.state:
				Enums.BuildingState.INTATTO:
					if top.owner != player:
						q.reason = "un edificio intatto altrui blocca la colonna %d" % c; return q
					if bool(CardDB.constants.get("spiana_solo_ere_precedenti", false)) and top.era_built >= gs.era:
						q.reason = "%s e' di quest'era: si spiana solo il passato" % top.data["name"]; return q
					if CardDB.constants.has("spianare_costo"):
						spolia -= int(CardDB.constants["spianare_costo"])
						if not top in q.razed: q.razed.append(top)
					elif not top in q.razed:
						q.razed.append(top)
						spolia += int(ceil(float(top.data["resistance"] + top.bonus_res) / float(CardDB.constants.get("spolia_divisore", 2))))
				Enums.BuildingState.RUDERE:
					if top != despoil and top.shares_class_with(data): q.continuity_bonus = 1
				Enums.BuildingState.ROVINA:
					if top.owner != player or not bool(CardDB.constants.get("sconto_macerie_solo_altrui", false)):
						rubble_discount = true
					# Casella per casella: di uno spianato in parte (registro
					# 180) contano solo le caselle rimaste rovina.
					if TessereScavo.casella_ha_tessera(top, c, r): q.tessere_sotto += 1
			if not top in q.bases: q.bases.append(top)
			real_bases += 1
			top_level = max(top_level, top.level + 1)
	if real_bases == 0:
		q.reason = "almeno una casella deve avere una base vera"; return q
	q.level = max(1, top_level)
	if int(data["level_required"]) > q.level:
		q.reason = "richiede livello %d" % data["level_required"]; return q
	var c0 := base_cost(data)
	var billable := vuote
	if billable > 0 and Effects.has_override(gs, "first_terrapieno_free") \
			and not gs.players[player].terrapieno_free_used:
		billable -= 1
		q.terrapieno_free_applied = true
	q.terrapieno_pietra = billable * int(CardDB.constants["terrapieno_cost_pietra"])
	var p := c0.x + q.terrapieno_pietra
	p -= pianura_discount(gs, data, col_from)
	p -= spolia
	if rubble_discount and despoil == null: p -= int(CardDB.constants["rubble_discount_pietra"])
	p = _apply_despoil(q, despoil, p)
	var sconto := Effects.cost_delta(gs, player, "building",
		Effects.sonda(data, player, col_from, q.level))
	var te := TessereEra.sconto_costruzione(gs, player, data, col_from, q.level, q.bases)
	q.pietra = max(0, p + sconto.x - int(te["pietra"]))
	q.oro = max(0, c0.y + sconto.y - int(te["oro"]))
	q.idee = max(0, base_idee(data) - int(te["idee"]))
	q.legal = true
	return q

# ---- costo flessibile ◈ -------------------------------------------
# Una sola unità: 2 pietra <-> 1 oro, solo all'acquisto.
static func flexible_options(data: Dictionary, p: int, o: int) -> Array:
	var opts := [Vector2i(p, o)]
	if data.get("flexible", false):
		if p >= 2: opts.append(Vector2i(p - 2, o + 1))
		if o >= 1: opts.append(Vector2i(p + 2, o - 1))
	return opts
