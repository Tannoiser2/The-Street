# res://scripts/ai/strategy_bot.gd
# I bot che giocano davvero. A differenza di RandomBot - che prova mosse a
# caso per far emergere crash - questo sceglie: valuta tutte le mosse legali
# e pagabili con una funzione comune, poi ci somma la preferenza della sua
# strategia.
#
# LE CINQUE STRATEGIE sono quelle del simulatore di riferimento: Rendita,
# Lampo, Scavo, Verticale, Bilanciata. Non sono cinque modi di giocare
# diversi, sono cinque PESI sulla stessa testa: dove il gioco paga in piu'
# modi, ognuna tira verso il suo canale.
#
# IL CONTO DELLA SOPRAVVIVENZA NON E' UNA SCOMMESSA. La forza dell'evento e'
# fissa per era - 2, 3, 4, 5, e nell'era 5 non c'e' evento - quindi "quante
# ere resta in piedi questo edificio" si CALCOLA: sopravvive all'era `e` se la
# sua resistenza efficace e' almeno `e + 1`. Un giocatore vero fa lo stesso
# conto guardando la carta. Il simulatore di riferimento usava una probabilita'
# perche' non aveva le regole vere sotto: qui ci sono, e si usano.
class_name StrategyBot
extends RefCounted

const STRATEGIE: Array[String] = ["rendita", "lampo", "scavo", "verticale", "bilanciata"]

# DUE CANDIDATE, non nel canone. Le cinque di sopra coprono quattro canali -
# Lampo, Rendita, Scavo, Verticalita' - e uno che non ne insegue nessuno.
# Restano fuori la Continuita' (che pesa quanto lo Scavo) e gli Obiettivi
# (Monumenti + Eredita'). Queste due li inseguono, e servono a rispondere con
# i numeri alla domanda "cinque bastano?".
const STRATEGIE_CANDIDATE: Array[String] = ["continuita", "obiettivi"]

static func tutte() -> Array[String]:
	var out: Array[String] = STRATEGIE.duplicate()
	out.append_array(STRATEGIE_CANDIDATE)
	return out

# QUANTO VALE UNA RISORSA. Il brief e' esplicito: "nessun peso fisso
# rappresenta bene un giocatore umano" - nel simulatore di riferimento due
# numeri fissi (oro 1,2 contro pietra 0,8) avevano falsato per round interi la
# misura della dominanza del fiume. Quindi qui non c'e' un peso: c'e' un
# conto. Una risorsa vale quanto la CHIEDE il mercato di adesso, diviso
# quanta se ne ha gia' in mano. Se le carte in tavola vogliono oro e io non ne
# ho, il prossimo oro vale molto; se ho cinque pietre e nessuno ne chiede,
# la sesta non vale niente.
const VALORE_MEDIO := 0.8

static func valore_risorse(gs: GameState, p: PlayerState) -> Vector2:
	var chiede_p := 0.0
	var chiede_o := 0.0
	for id in gs.market:
		var c: Dictionary = CardDB.buildings[id]["cost"]
		chiede_p += float(c["pietra"])
		chiede_o += float(c["oro"])
	if chiede_p + chiede_o <= 0.0: return Vector2(VALORE_MEDIO, VALORE_MEDIO)
	var vp := chiede_p / float(p.pietra + 1)
	var vo := chiede_o / float(p.oro + 1)
	if vp + vo <= 0.0: return Vector2(VALORE_MEDIO, VALORE_MEDIO)
	# Si normalizza sulla media, cosi' a cambiare e' il RAPPORTO fra le due e
	# non la scala: se no un mercato caro farebbe sembrare tutto impagabile.
	var scala := 2.0 * VALORE_MEDIO / (vp + vo)
	# Il rapporto si tiene entro il doppio e la meta': un mercato che per caso
	# non chiede oro non deve far credere che l'oro non serva - serve a
	# reclutare, a comprare la Dinastia e a pagare le ere dopo.
	return Vector2(clampf(vp * scala, VALORE_MEDIO * 0.5, VALORE_MEDIO * 2.0),
		clampf(vo * scala, VALORE_MEDIO * 0.5, VALORE_MEDIO * 2.0))

# ---- il turno -------------------------------------------------------
static func play_turn(ctl: GameController, strategia := "bilanciata") -> void:
	var gs := ctl.gs
	while not gs.pending_choice.is_empty():
		if not ctl.choose(_scelta(gs)): break
	if gs.phase == Enums.Phase.FINE_PARTITA: return
	var p := gs.current_player()

	var col := _colonna(gs, p, strategia)
	if col < 0 or not ctl.place_worker(col, _da_proteggere(gs, p, col)):
		ctl.pass_action()
		return

	# Il Mercante di ossidiana: si converte solo se manca l'oro per la mossa
	# che si vuole fare, non per abitudine.
	while p.oro < 2 and p.pietra >= 4 and ctl.exchange(true):
		pass

	var mosse := _opzioni(gs, p.index, col)
	var meglio = null
	var punteggio := 0.0
	for v in mosse:
		var q := _valore(gs, p, v, strategia, col)
		if meglio == null or q > punteggio:
			meglio = v
			punteggio = q
	if meglio == null or punteggio <= 0.0:
		ctl.pass_action()
		return
	if not _esegui(ctl, meglio):
		ctl.pass_action()

# ---- la colonna da attivare -----------------------------------------
# Vale la produzione del terreno, quello che ci si puo' costruire e - se sta
# per arrivare un evento che non regge - il proprio edificio da proteggere.
static func _colonna(gs: GameState, p: PlayerState, strategia: String) -> int:
	var libere: Array[int] = []
	for c in gs.grid.n_cols:
		if not c in p.worker_cols: libere.append(c)
	if libere.is_empty(): return -1
	var meglio := -1
	var punteggio := -INF
	for c in libere:
		var q := _produzione_colonna(gs, p, c)
		q += _valore_protezione(gs, p, c)
		var mosse := _opzioni(gs, p.index, c)
		var migliore := 0.0
		for v in mosse:
			migliore = maxf(migliore, _valore(gs, p, v, strategia, c))
		q += migliore
		if q > punteggio:
			punteggio = q
			meglio = c
	return meglio

static func _produzione_colonna(gs: GameState, p: PlayerState, col: int) -> float:
	var t: int = gs.grid.terrains[col]
	var q := 0.6 if t == Enums.Terrain.PIANURA or t == Enums.Terrain.COLLINA else 0.5
	# "attivando arricchite anche i proprietari che ci sono": una colonna dove
	# ho gia' qualcosa di vivo rende di piu' a me che agli altri.
	for b in gs.grid.alive_in_column(col):
		if b.owner == p.index: q += 0.8
		else: q -= 0.2
	return q

# Il lavoratore da' +2 resistenza per l'era: vale quanto l'edificio che salva.
static func _valore_protezione(gs: GameState, p: PlayerState, col: int) -> float:
	var b := _da_proteggere(gs, p, col)
	if b == null: return 0.0
	var forza: int = gs.era + 1
	var res: int = b.effective_resistance()
	if res >= forza: return 0.0            # regge da solo
	if res + 2 < forza: return 0.0         # non basta comunque
	return 1.5 + float(b.rendita_value()) * float(_ere_rimaste(gs))

static func _da_proteggere(gs: GameState, p: PlayerState, col: int) -> Building:
	var meglio: Building = null
	for b in gs.grid.in_column(col):
		if b.owner != p.index or not b.is_standing(): continue
		if meglio == null or b.rendita_value() > meglio.rendita_value(): meglio = b
	return meglio

# ---- le mosse possibili ---------------------------------------------
static func _opzioni(gs: GameState, player: int, col: int) -> Array:
	var p: PlayerState = gs.players[player]
	var out := []
	for card_id in gs.market:
		for v in AvailableActions.piazzamenti(gs, player, col, card_id):
			if v.pagabile(p): out.append(v)
	for v in AvailableActions.potenziamenti(gs, player, col):
		if v.legale and v.pagabile(p): out.append(v)
	for v in AvailableActions.restauri(gs, player, col):
		if v.legale and v.pagabile(p): out.append(v)
	for v in AvailableActions.reclutamenti(gs, player, col):
		if v.legale and v.pagabile(p): out.append(v)
	var d := AvailableActions.dinastia(gs, player)
	if d.legale and d.pagabile(p): out.append(d)
	return out

static func _esegui(ctl: GameController, v) -> bool:
	var par: Dictionary = v.parametri
	match v.tipo:
		"costruisci":
			return ctl.build(str(par["card_id"]), int(par["col_from"]), bool(par["above"]))
		"potenzia":
			return ctl.upgrade(str(par["upg_id"]), _per_uid(ctl.gs, int(par["uid"])))
		"restaura":
			return ctl.restore(_per_uid(ctl.gs, int(par["uid"])))
		"recluta":
			var bersaglio: Building = _per_uid(ctl.gs, int(par["uid"])) if par.has("uid") else null
			return ctl.recruit(str(par["char_id"]), bersaglio)
		"dinastia":
			return ctl.buy_dynasty()
	return false

static func _per_uid(gs: GameState, uid: int) -> Building:
	for b in gs.grid.buildings:
		if b.uid == uid: return b
	return null

# ---- quanto vale una mossa ------------------------------------------
static func _valore(gs: GameState, p: PlayerState, v, strategia: String, col: int) -> float:
	var r := valore_risorse(gs, p)
	var speso := float(v.pietra) * r.x + float(v.oro) * r.y
	match v.tipo:
		"costruisci": return _valore_costruzione(gs, p, v, strategia, r) - speso
		"potenzia": return _valore_potenziamento(gs, p, v) - speso
		"restaura": return _valore_restauro(gs, p, v) - speso
		"recluta": return _valore_reclutamento(gs, p, v, strategia, r) - speso
		"dinastia": return _valore_dinastia(gs) - speso
	return 0.0

static func _ere_rimaste(gs: GameState) -> int:
	return 5 - gs.era

# I censimenti che questo edificio incassera' se nessuno lo tocca. Non e' una
# stima: l'evento dell'era `e` ha forza `e + 1` e l'era 5 non ne ha.
static func rendite_future(res: int, rendita: int, era: int) -> float:
	if rendita <= 0: return 0.0
	var vmax := int(CardDB.constants["vetusta_max"])
	var vet := 0
	var totale := 0.0
	for e in range(era, 6):
		if e < 5:
			if res < e + 1: break           # l'evento lo butta giu' prima del censimento
			vet = mini(vet + 1, vmax)
		totale += float(rendita + vet)
	return totale

static func _valore_costruzione(gs: GameState, p: PlayerState, v, strategia: String,
		r: Vector2) -> float:
	var par: Dictionary = v.parametri
	var d: Dictionary = CardDB.buildings[str(par["card_id"])]
	var col_from := int(par["col_from"])
	var sopra: bool = par["above"]
	var res := int(d["resistance"])
	if gs.grid.terrains[col_from] == Enums.Terrain.COLLINA: res += 1
	var rimaste := _ere_rimaste(gs)

	var q := float(d["lampo"])
	q += rendite_future(res, int(d["rendita"]), gs.era)
	var prod: Dictionary = d.get("production", {})
	q += (float(prod.get("pietra", 0)) * r.x + float(prod.get("oro", 0)) * r.y
		+ float(prod.get("cultura", 0))) * float(rimaste) * 0.5

	var larghezza := int(d["width"])
	if sopra:
		# La Verticalita' paga il premio della colonna per OGNI colonna che
		# l'edificio tocca, e chi sta in cima ne prende meta'.
		var tab = CardDB.constants["verticality_vp"]
		for c in range(col_from, col_from + larghezza):
			var h: int = gs.grid.height(c)
			var prima := 0 if h < 1 else int(tab[str(mini(h, 4))])
			var dopo := int(tab[str(mini(h + 1, 4))])
			q += float(dopo - prima) * 0.35 + float(dopo) * 0.15
		# Cosa finisce sotto e cosa si spiana lo dice il preventivo, che sa
		# gia' quali edifici faranno da base: lo Scavo di un proprio rudere si
		# incassa, la rendita futura di un proprio intatto spianato si perde.
		var q2 := BuildRules.quote_above(gs, p.index, d, col_from)
		for b in q2.bases:
			if b.owner == p.index: q += float(b.scavo_value()) * 0.5
		for b in q2.razed:
			q -= rendite_future(b.effective_resistance(), b.rendita_value(), gs.era) * 0.6
			q -= float(b.data["scavo"]) * 0.25      # spianato vale Scavo 0
	# Continuita' di luogo: una seconda carta della stessa classe nella colonna.
	var mie := {}
	for b in gs.grid.in_column(col_from):
		if b.owner != p.index: continue
		for c in b.classes(): mie[c] = int(mie.get(c, 0)) + 1
	for c in d["classes"]:
		if int(mie.get(c, 0)) >= 1:
			q += 1.5
			break
	# Lo Scavo si incassa solo da sotterrati: vale, ma meno della rendita.
	q += float(d["scavo"]) * 0.25

	# LA PREFERENZA DELLA STRATEGIA. Tira in due sensi: premia la carta che fa
	# al caso suo e scoraggia quella che non ne fa. Solo il premio non
	# bastava - il valutatore comune vale molto di piu' della spinta, e le
	# cinque finivano per giocare la stessa partita.
	match strategia:
		"rendita":
			q += float(d["rendita"]) * float(rimaste) * 0.9
			if int(d["rendita"]) == 0: q -= 1.5
		"lampo":
			q += float(d["lampo"]) * 1.6
			if int(d["lampo"]) == 0: q -= 1.0
		"scavo":
			q += float(d["scavo"]) * 0.9 + (2.0 if sopra else 0.0)
			if int(d["scavo"]) == 0: q -= 1.0
		"verticale":
			if sopra: q += 3.0 + 1.2 * float(par.get("level", 1))
			else: q -= 1.5
		"continuita": q += _premio_catena(mie, d)
		"obiettivi": q += _premio_obiettivi(gs, p, d, col_from, par)
	return q

# Quanto vale allungare una catena di classe in questa colonna: la differenza
# fra quello che la colonna paga adesso e quello che pagherebbe dopo.
static func _premio_catena(mie: Dictionary, d: Dictionary) -> float:
	var tabella = CardDB.constants["continuity_vp"]
	var meglio := 0.0
	for c in d["classes"]:
		var quante := int(mie.get(c, 0))
		var prima := 0
		if quante >= 3: prima = int(tabella["3"])
		elif quante >= 2: prima = int(tabella["2"])
		var dopo := 0
		if quante + 1 >= 3: dopo = int(tabella["3"])
		elif quante + 1 >= 2: dopo = int(tabella["2"])
		meglio = maxf(meglio, float(dopo - prima))
	return meglio

# Monumenti aperti ed Eredita' segreta: si prova a costruire per finta e si
# chiede alle REGOLE se la condizione e' soddisfatta. Cosi' la strategia non
# ricopia i requisiti delle carte - che sono dati - ma li interroga.
static func _premio_obiettivi(gs: GameState, p: PlayerState, d: Dictionary,
		col_from: int, par: Dictionary) -> float:
	var finto := Building.new()
	finto.uid = -1
	finto.data = d
	finto.owner = p.index
	finto.era_built = gs.era
	finto.col_from = col_from
	finto.col_to = col_from + int(d["width"])
	finto.level = int(par.get("level", 0))
	gs.grid.buildings.append(finto)
	var q := 0.0
	for id in gs.monuments_open:
		var m: Dictionary = CardDB.monuments[id]
		if p.monuments_claimed.has(id): continue
		if Conditions.met(gs, p.index, m["condition"]) : q += float(m["vp"])
	if p.legacy_id != "" and CardDB.legacies.has(p.legacy_id):
		var l: Dictionary = CardDB.legacies[p.legacy_id]
		if Conditions.met(gs, p.index, l["condition"]): q += float(l["vp"]) * 0.7
	gs.grid.buildings.erase(finto)
	# Il monumento gia' soddisfatto senza questa carta non e' merito suo.
	var senza := 0.0
	for id in gs.monuments_open:
		var m2: Dictionary = CardDB.monuments[id]
		if p.monuments_claimed.has(id): continue
		if Conditions.met(gs, p.index, m2["condition"]): senza += float(m2["vp"])
	if p.legacy_id != "" and CardDB.legacies.has(p.legacy_id):
		var l2: Dictionary = CardDB.legacies[p.legacy_id]
		if Conditions.met(gs, p.index, l2["condition"]): senza += float(l2["vp"]) * 0.7
	return maxf(0.0, q - senza)

static func _valore_potenziamento(gs: GameState, p: PlayerState, v) -> float:
	var par: Dictionary = v.parametri
	var b := _per_uid(gs, int(par["uid"])) if par.has("uid") else null
	if b == null: return 0.0
	# Una carta infilata sotto dura quanto l'edificio che la ospita.
	var vive := b.effective_resistance() >= gs.era + 1
	return (2.2 if vive else 0.8) + float(b.rendita_value()) * 0.3

static func _valore_restauro(gs: GameState, p: PlayerState, v) -> float:
	var b := _per_uid(gs, int(v.parametri["uid"]))
	if b == null: return 0.0
	# Torna intatto e la Vetusta' si azzera; se era altrui, cambia padrone.
	var q := rendite_future(int(b.data["resistance"]) + b.bonus_res, b.rendita_value(), gs.era)
	q += float(b.data["scavo"]) * 0.25
	if b.owner != p.index: q += 2.0
	return q

# QUANTO VALE UN PERSONAGGIO. Anche qui il brief e' esplicito: va calcolato
# "dalla sua abilita' reale, non stimato". Le abilita' sono dati strutturati
# (`effects`), quindi si leggono una per una invece di dare a tutti lo stesso
# numero: il Capotribu' che da' 2 pietra subito non vale come lo Sciamano che
# da' +1 resistenza agli edifici Religione, e lo Sciamano vale qualcosa solo
# se di edifici Religione ne ho.
static func _valore_reclutamento(gs: GameState, p: PlayerState, v, strategia: String,
		r: Vector2) -> float:
	var d: Dictionary = CardDB.characters[str(v.parametri["char_id"])]
	var q := 0.5                                   # il lavoratore specializzato in se'
	for e in d.get("effects", []):
		q += _valore_effetto(gs, p, e, r)
	# Se finisce sepolto vale 6 meno l'era: si conta per quel che e', una
	# possibilita', non una certezza.
	if gs.era <= 4: q += 0.3 * float(6 - gs.era)
	if strategia == "bilanciata": q += 0.6
	if strategia == "scavo": q += 0.6
	return q

# Il valore di una singola abilita'. Gli `op` sono uno schema chiuso: quelli
# che si sanno contare si contano, gli altri valgono un numero piccolo e
# dichiarato invece di zero - un'abilita' che non so leggere non e' un'abilita'
# che non serve.
const VALORE_IGNOTO := 1.0

static func _valore_effetto(gs: GameState, p: PlayerState, e: Dictionary, r: Vector2) -> float:
	var rimaste := float(_ere_rimaste(gs))
	match str(e.get("op", "")):
		"resource":
			return float(e.get("pietra", 0)) * r.x + float(e.get("oro", 0)) * r.y
		"vp":
			return float(e.get("value", 0))
		"vp_per":
			# vale quanti bersagli ho davvero adesso
			var n := 0
			for b in gs.grid.buildings:
				if Effects.matches(gs, b, e.get("target", {}), null, p.index): n += 1
			return float(e.get("value", 1)) * float(n)
		"resistance", "protection_delta":
			# vale gli edifici che salva: quelli che senza questo punto in piu'
			# non passerebbero l'evento di quest'era
			var forza := gs.era + 1
			var salvati := 0.0
			for b in gs.grid.buildings:
				if not b.is_standing() or b.owner != p.index: continue
				if not Effects.matches(gs, b, e.get("target", {}), null, p.index): continue
				var res: int = b.effective_resistance()
				if res >= forza or res + int(e.get("value", 1)) < forza: continue
				# Quanto vale salvarlo: le rendite che incassera' in piu'
				# perche' non e' crollato, piu' il suo Scavo che resta buono.
				salvati += 1.0 + rendite_future(res + int(e.get("value", 1)),
					b.rendita_value(), gs.era)
			return salvati
		"scavo_delta":
			return float(e.get("value", 0)) * 0.5
		"cost_delta":
			# uno sconto vale una volta per ogni era che resta, se ci costruisco
			return absf(float(e.get("pietra", 0))) * r.x * maxf(1.0, rimaste * 0.5) \
				+ absf(float(e.get("oro", 0))) * r.y * maxf(1.0, rimaste * 0.5)
		"production_delta":
			return (float(e.get("pietra", 0)) * r.x + float(e.get("oro", 0)) * r.y
				+ float(e.get("cultura", 0))) * maxf(1.0, rimaste)
		"upgrade_slots_delta":
			return 0.8
	return VALORE_IGNOTO

static func _valore_dinastia(gs: GameState) -> float:
	# Un quarto lavoratore per tutte le ere che restano: e' il moltiplicatore
	# piu' grosso che si possa comprare, e prima lo si compra piu' rende.
	return 1.2 * float(_ere_rimaste(gs) + 1)

# La scelta in sospeso (dove infilare il potenziamento dell'Eruzione): si
# sceglie l'edificio che reggera' piu' a lungo, cosi' la carta non muore con
# lui nella stessa era.
static func _scelta(gs: GameState) -> int:
	var opzioni: Array = gs.pending_choice.get("options", [])
	if opzioni.is_empty(): return 0
	var meglio := int(opzioni[0])
	var punteggio := -INF
	for uid in opzioni:
		var b := _per_uid(gs, int(uid))
		if b == null: continue
		var q := float(b.effective_resistance()) + float(b.rendita_value())
		if q > punteggio:
			punteggio = q
			meglio = int(uid)
	return meglio
