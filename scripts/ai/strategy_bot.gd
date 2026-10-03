# res://scripts/ai/strategy_bot.gd
# I bot che giocano davvero. A differenza di RandomBot - che prova mosse a
# caso per far emergere crash - questo sceglie: valuta tutte le mosse legali
# e pagabili con una funzione comune, poi ci somma la preferenza della sua
# strategia.
#
# LE SEI STRATEGIE: le cinque del simulatore di riferimento - Rendita, Lampo,
# Scavo, Verticale, Bilanciata - piu' Obiettivi, entrata nel canone quando il
# torneo ha mostrato che vince sopra la media con tutti e due i bot. Non sono
# sei modi di giocare diversi, sono sei PESI sulla stessa testa: dove il gioco
# paga in piu' modi, ognuna tira verso il suo canale.
#
# IL CONTO DELLA SOPRAVVIVENZA NON E' UNA SCOMMESSA. La forza dell'evento e'
# fissa per era - 2, 3, 4, 5, e nell'era 5 non c'e' evento - quindi "quante
# ere resta in piedi questo edificio" si CALCOLA: sopravvive all'era `e` se la
# sua resistenza efficace e' almeno `e + 1`. Un giocatore vero fa lo stesso
# conto guardando la carta. Il simulatore di riferimento usava una probabilita'
# perche' non aveva le regole vere sotto: qui ci sono, e si usano.
class_name StrategyBot
extends RefCounted

# LA VERSIONE DEL BOT, scritta nell'intestazione di ogni batteria di partite.
# Due lotti giocati con le stesse regole ma con bot diversi non sono lo stesso
# esperimento, e confrontarli senza saperlo vuol dire attribuire alle regole
# quello che ha fatto il bot.
#   1  sceglie la colonna guardando lo stato di prima dell'attivazione
#   2  valuta le mosse sullo stato DOPO l'attivazione (copia della partita)
const VERSIONE := 2
# Quale versione gioca adesso. Di serie l'ultima; la si rimette indietro per
# rispondere a "questo e' merito del bot o delle regole?" - rigiocando le regole
# nuove col bot vecchio. Deve riprodurre il bot di allora ESATTAMENTE, e c'e'
# un test che lo verifica: una versione vecchia approssimata non separerebbe
# niente.
static var versione_in_uso := VERSIONE

# L'ORDINE CONTA: le partite assegnano le strategie a rotazione su questa
# lista, e Obiettivi sta in fondo perche' e' arrivata dopo. Le prime cinque
# coprono quattro canali - Lampo, Rendita, Scavo, Verticalita' - e uno che non
# ne insegue nessuno; Obiettivi insegue Monumenti ed Eredita'.
const STRATEGIE: Array[String] = ["rendita", "lampo", "scavo", "verticale", "bilanciata",
	"obiettivi"]

# UNA CANDIDATA, fuori dal canone: la Continuita', che pesa quanto lo Scavo e
# nel torneo non ha mai vinto sopra la media. Resta per rispondere con i
# numeri alla domanda "sei bastano?".
const STRATEGIE_CANDIDATE: Array[String] = ["continuita"]

# IL CANONE DELLA V2 (registro 92). Senza Verticalita' la strategia Verticale
# non insegue niente, e lo Scavo lo fa chi scava (il premio S x L), non chi
# viene sepolto: la Verticale esce, la Continuita' entra (senza il premio
# della colonna e' il quarto canale del gioco), e la Scavo cambia testa.
# Quale canone vale lo dice il file dati caricato, non una manopola: due lotti
# con lo stesso file giocano le stesse strategie.
const STRATEGIE_V2: Array[String] = ["rendita", "lampo", "scavo", "continuita", "bilanciata",
	"obiettivi"]

static func e_v2() -> bool:
	return (str(CardDB.ruleset).begins_with("v2") or str(CardDB.ruleset).begins_with("v3"))

static func canone() -> Array[String]:
	return STRATEGIE_V2 if e_v2() else STRATEGIE

static func tutte() -> Array[String]:
	var out: Array[String] = canone().duplicate()
	if not e_v2(): out.append_array(STRATEGIE_CANDIDATE)
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
	# V3 (registro 159): le Idee sono una risorsa chiesta dal mercato come il
	# Denaro, e si contano con lui (il valutatore ha due componenti, e le Idee
	# si pagano al valore del Denaro). Fuori dalla v3 il conto non cambia.
	var v3 := PersonaggiV3.attivo()
	var stock_o := p.oro + (p.idee if v3 else 0)
	for id in gs.in_vendita():
		var c: Dictionary = CardDB.buildings[id]["cost"]
		chiede_p += float(c["pietra"])
		chiede_o += float(c["oro"]) + (float(c.get("idee", 0)) if v3 else 0.0)
	if chiede_p + chiede_o <= 0.0: return Vector2(VALORE_MEDIO, VALORE_MEDIO)
	var vp := chiede_p / float(p.pietra + 1)
	var vo := chiede_o / float(stock_o + 1)
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
# ---- il taccuino della decisione ------------------------------------
# Acceso `racconta`, il bot lascia scritto COSA HA GUARDATO prima di muovere:
# le colonne con quanto valevano, le mosse con quanto valevano e da cosa.
# Serve a raccontare una partita, e deve venire da qui dentro: chiedendo la
# classifica da fuori PRIMA della mossa si valuta uno stato che poi cambia -
# il lavoratore non e' ancora piazzato, quindi la colonna non e' ancora stata
# attivata e la produzione non e' ancora stata incassata -
# e il racconto finisce per spiegare una mossa diversa da quella fatta. E'
# successo, e si vedeva: il turno diceva "recluta" e il tabellone costruiva.
static var racconta := false
static var taccuino := {}

static func play_turn(ctl: GameController, strategia := "bilanciata") -> void:
	var gs := ctl.gs
	var chi := gs.current_index
	while not gs.pending_choice.is_empty():
		# Il draft e' una scelta PER GIOCATORE: risolta la propria, la
		# prossima e' di un altro, con la sua strategia (il chiamante lo sa).
		if str(gs.pending_choice.get("kind", "")).begins_with("draft") \
				and int(gs.pending_choice["player"]) != chi: return
		if not ctl.choose(_scelta(gs, strategia)): break
	if gs.phase == Enums.Phase.FINE_PARTITA: return
	if not gs.pending_choice.is_empty(): return
	giocatori = gs.n_players
	var p := gs.current_player()
	if bool(CardDB.constants.get("turno_v2", false)):
		_play_turn_v2(ctl, p, strategia)
		return

	if racconta: taccuino = {"strategia": strategia, "chi": p.index}
	var colonne := classifica_colonne(gs, p, strategia)
	if racconta: taccuino["colonne"] = colonne
	var col := _colonna(gs, p, strategia, colonne)
	if col < 0 or not ctl.place_worker(col, _da_proteggere(gs, p, col), _personaggio_di(colonne, col)):
		ctl.pass_action()
		return
	if racconta: taccuino["col"] = col
	# "scelta" (registro 170): l'edificio da usare, con lo stesso conto fatto in classifica.
	if str(gs.pending_choice.get("kind", "")) == "edificio":
		ctl.choose(_scelta_edificio(gs, strategia))

	# Il Mercante di ossidiana: si converte solo se manca l'oro per la mossa
	# che si vuole fare, non per abitudine.
	while p.oro < 2 and p.pietra >= 4 and ctl.exchange(true):
		pass

	var lista := classifica(gs, p, col, strategia)
	var scelta := migliore(lista)
	if racconta:
		taccuino["mosse"] = lista
		taccuino["scelta"] = scelta
	# V3 (registro 161): "le risorse possono essere tenute per poter comprare
	# meglio con il lavoratore successivo". Se una carta che oggi non si puo'
	# pagare, ma che il prossimo incasso rende pagabile, vale piu' della
	# mossa di adesso, si tiene e si passa.
	var attesa := _valore_attesa(gs, p, col, strategia)
	if racconta: taccuino["attesa"] = attesa
	if not scelta.is_empty() and attesa > float(scelta["valore"]) + MARGINE_ATTESA:
		scelta = {}
	if scelta.is_empty():
		_passa(ctl, gs, p)
		return
	if not _esegui(ctl, scelta["mossa"]):
		_passa(ctl, gs, p)
		return
	# V3, l'acquisto extra: dopo la mossa si puo' ancora comprare un
	# potenziamento o una casa. Stessa testa: la voce che vale di piu', se vale
	# piu' di zero, altrimenti si chiude il turno.
	if gs.acquisto_extra_aperto and gs.current_index == p.index and gs.pending_choice.is_empty():
		var extra: Array[Dictionary] = []
		for v in _opzioni(gs, p.index, col):
			if v.tipo == "potenzia" or (not gs.extra_solo_potenziamenti and v.tipo == "costruisci" \
					and str(v.parametri.get("card_id", "")) in gs.riserva):
				extra.append({"mossa": v, "valore": _valore(gs, p, v, strategia, col)})
		var ex := migliore(extra)
		if racconta: taccuino["extra"] = ex
		if ex.is_empty() or not _esegui(ctl, ex["mossa"]):
			ctl.pass_action()

# Passare nel turno v1: con l'incasso al passaggio (`passa_incasso`) si
# sceglie la risorsa che vale di piu', come nel turno a un'azione; senza, si
# passa e basta.
static func _passa(ctl: GameController, gs: GameState, p: PlayerState) -> void:
	if ctl.passa_incasso():
		ctl.passa(_risorsa_da_passare(p, valore_risorse(gs, p)))
	else:
		ctl.pass_action()

# ---- la classifica che il bot si fa in testa ------------------------
# Tutte le mosse legali e pagabili con quanto valgono, NELL'ORDINE IN CUI LE
# GUARDA. Non si ordina qui: `migliore` prende il primo massimo stretto, ed e'
# la stessa regola di prima - ordinare cambierebbe le parita', cioe' le
# partite gia' misurate.
# Serve anche a RACCONTARE una partita: "perche' ha fatto questa mossa" si
# risponde solo mostrando quali erano le altre e quanto valevano.
static func classifica(gs: GameState, p: PlayerState, col: int,
		strategia: String) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	for v in _opzioni(gs, p.index, col):
		var dett := {}
		out.append({"mossa": v, "valore": _valore(gs, p, v, strategia, col, dett),
			"dettaglio": dett})
	return out

# La mossa scelta: il primo massimo stretto, e solo se vale piu' di zero -
# passare e' meglio di una mossa che toglie.
static func migliore(lista: Array[Dictionary]) -> Dictionary:
	var scelta := {}
	var punteggio := 0.0
	for e in lista:
		if scelta.is_empty() or float(e["valore"]) > punteggio:
			if float(e["valore"]) <= 0.0 and scelta.is_empty(): continue
			scelta = e
			punteggio = float(e["valore"])
	return scelta

# ---- la colonna da attivare -----------------------------------------
# Vale la produzione del terreno, quello che ci si puo' costruire e - se sta
# per arrivare un evento che non regge - il proprio edificio da proteggere.
static func _colonna(gs: GameState, p: PlayerState, strategia: String,
		gia_fatta: Array[Dictionary] = []) -> int:
	var lista := gia_fatta if not gia_fatta.is_empty() else classifica_colonne(gs, p, strategia)
	var meglio := -1
	var punteggio := -INF
	for e in lista:
		if float(e["valore"]) > punteggio:
			punteggio = float(e["valore"])
			meglio = int(e["col"])
	return meglio

# Le colonne ancora libere per questo giocatore, con quanto valgono e da cosa:
# quel che il terreno produce, l'edificio che il lavoratore salverebbe
# dall'evento, e la migliore mossa che si potrebbe fare li'. Serve a
# `_colonna` e a raccontare perche' il lavoratore e' andato proprio li'.
# LE MOSSE SI VALUTANO SULLO STATO DOPO L'ATTIVAZIONE. Piazzare il lavoratore
# non e' un gesto neutro: ATTIVA la colonna, e l'attivazione paga la produzione
# a chi ha edifici li', fa scattare le abilita' "quando la attivi" e distribuisce
# l'oro del Centro Urbano. Con quelle risorse in mano le mosse possibili sono
# altre - una carta che prima non si poteva pagare adesso si puo'.
# Guardando lo stato di PRIMA, il bot sceglieva la colonna contando mosse che
# non avrebbe potuto fare e ignorandone altre che avrebbe potuto: e' la stessa
# svista di chi, al tavolo, decide dove andare senza contare cosa incassa
# andandoci.
# La colonna si prova su una COPIA della partita, e si prova col codice vero -
# `place_worker`, che protegge e attiva - invece di rifare i conti
# dell'attivazione qui dentro: due versioni della stessa regola divergono, e la
# seconda non la prova nessuno.
static func classifica_colonne(gs: GameState, p: PlayerState,
		strategia: String) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	for c in gs.grid.n_cols:
		if c in p.worker_cols: continue
		var prod := _produzione_colonna(gs, p, c)
		var prot := _valore_protezione(gs, p, c)
		var da_salvare := _da_proteggere(gs, p, c)
		var migliore := 0.0
		var meglio_pers := ""
		if versione_in_uso <= 1:
			# Versione 1: le mosse sullo stato di PRIMA, senza attivare.
			for v in _opzioni(gs, p.index, c):
				migliore = maxf(migliore, _valore(gs, p, v, strategia, c))
		else:
			# V3: il lavoratore e' un Personaggio, e quale si piazza cambia
			# cosa si incassa e cosa si puo' fare dopo: si prova ciascuno di
			# quelli liberi e si tiene il migliore, col suo guadagno.
			var candidati: Array[String] = [""]
			if PersonaggiV3.attivo():
				candidati = []
				for cid in p.specialized_characters:
					if not cid in p.personaggi_piazzati: candidati.append(cid)
			var meglio_tot := -INF
			for pid in candidati:
				var copia := gs.duplica()
				var ctl := GameController.new()
				ctl.gs = copia
				var protetto: Building = _per_uid(copia, da_salvare.uid) if da_salvare != null else null
				if not ctl.place_worker(c, protetto, pid): continue
				# "scelta" (registro 170): sulla copia si sceglie l'edificio come si fara' davvero.
				if str(copia.pending_choice.get("kind", "")) == "edificio":
					ctl.choose(_scelta_edificio(copia, strategia))
				var pc: PlayerState = copia.players[p.index]
				var mossa := 0.0
				for v in _opzioni(copia, p.index, c):
					mossa = maxf(mossa, _valore(copia, pc, v, strategia, c))
				var tot := mossa + (_guadagno_v3(gs, p, copia, pc, c, strategia) if pid != "" else 0.0)
				if tot > meglio_tot:
					meglio_tot = tot
					meglio_pers = pid
					migliore = tot
		out.append({"col": c, "valore": prod + prot + migliore,
			"produzione": prod, "protezione": prot, "mossa": migliore,
			"salva": da_salvare, "pers": meglio_pers})
	return out

# Quanto vale ASPETTARE (v3): la migliore carta del mazzo che non si puo'
# pagare adesso ma si potrebbe pagare al prossimo lavoratore, con l'incasso
# di un'attivazione (circa 1 Costruzione, 1 Denaro o Idea), valutata come le
# altre mosse e scontata, perche' il mercato puo' cambiare e la carta sparire.
# Zero se non restano lavoratori o fuori dalla v3.
const SCONTO_ATTESA := 0.4
# Si aspetta solo se conviene chiaramente: con lo sconto a 0,6 e senza margine il
# bot passava un turno su quattro, con 0,5 e margine 0,5 uno su sei.
const MARGINE_ATTESA := 1.0
const INCASSO_ATTESO := Vector3i(1, 1, 1)

static func _valore_attesa(gs: GameState, p: PlayerState, col: int, strategia: String) -> float:
	if not PersonaggiV3.risorse_muoiono(): return 0.0
	if p.workers - p.workers_used <= 0: return 0.0
	var best := 0.0
	for card_id in gs.market:
		var c: Dictionary = CardDB.buildings[card_id]["cost"]
		if p.can_pay(int(c["pietra"]), int(c["oro"]), int(c.get("idee", 0))): continue
		if int(c["pietra"]) > p.pietra + INCASSO_ATTESO.x or int(c["oro"]) > p.oro + INCASSO_ATTESO.y \
				or int(c.get("idee", 0)) > p.idee + INCASSO_ATTESO.z: continue
		for v in AvailableActions.piazzamenti_ovunque(gs, p.index, card_id):
			best = maxf(best, _valore(gs, p, v, strategia, int(v.parametri["col_from"])) * SCONTO_ATTESA)
			break          # un piazzamento basta: si decide se aspettare, non dove
	return best

# Il Personaggio scelto per la colonna (v3): sta nella voce della classifica.
static func _personaggio_di(colonne: Array[Dictionary], col: int) -> String:
	for e in colonne:
		if int(e["col"]) == col: return str(e.get("pers", ""))
	return ""

# Quanto ha reso piazzare QUEL Personaggio su quella colonna (v3): si guarda
# la copia dopo l'attivazione e si conta cio' che e' cambiato per il
# giocatore: risorse (al valore di mercato), punti, resistenza data ai propri
# edifici, Scavo aggiunto, lo sconto e il Lampo lasciati per l'azione del turno.
static func _guadagno_v3(gs: GameState, p: PlayerState, copia: GameState, pc: PlayerState,
		col: int, strategia: String) -> float:
	var r := valore_risorse(gs, p)
	var q := float(pc.pietra - p.pietra) * r.x + float(pc.oro - p.oro) * r.y + float(pc.idee - p.idee) * r.y
	# Le risorse che non si potranno spendere prima della fine dell'era non
	# valgono: si guarda la copia, dove il piazzamento e' gia' fatto.
	q *= _fattore_morte(copia, pc)
	q += float(pc.vp - p.vp) * 0.9
	# L'acquisto extra guadagnato vale qualcosa solo se resta con che comprare.
	q += 0.4 * float(pc.extra_turno - p.extra_turno)
	var prima := {}
	for b in gs.grid.buildings: prima[b.uid] = [b.protection, b.bonus_scavo]
	for b in copia.grid.buildings:
		if b.owner != p.index or not prima.has(b.uid): continue
		var dp: int = b.protection - int(prima[b.uid][0])
		var ds: int = b.bonus_scavo - int(prima[b.uid][1])
		if dp > 0:
			# vale se serve: l'edificio che senza non passerebbe l'evento
			var forza := gs.era + 1
			var res_prima: int = b.effective_resistance() - dp
			q += (1.0 + float(b.rendita_value()) if res_prima < forza and res_prima + dp >= forza else 0.2) * float(dp)
			if strategia == "rendita": q += 0.3 * float(dp)
		if ds > 0:
			q += (0.8 if strategia == "scavo" else 0.3) * float(ds)
	q += 0.8 * float(pc.sconto_turno) + 1.0 * float(pc.lampo_turno)
	return q

static func _produzione_colonna(gs: GameState, p: PlayerState, col: int) -> float:
	var t: int = gs.grid.terrains[col]
	var q := 0.6 if t == Enums.Terrain.PIANURA or t == Enums.Terrain.COLLINA else 0.5
	# "attivando arricchite anche i proprietari che ci sono": una colonna dove
	# ho gia' qualcosa di vivo rende di piu' a me che agli altri.
	# Con la "scelta" (registro 170) gli edifici altrui si usano come i propri:
	# il guadagno vero lo misura la simulazione, qui niente pregiudizio.
	if PersonaggiV3.scelta_attiva(): return q
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
# ---- il turno v2 -----------------------------------------------------
# Una lista sola con tutto quello che si puo' fare: attivare una colonna
# (vale quello che rende, provato su una copia), costruire ovunque, potenziare,
# ristrutturare, reclutare, la Dinastia, passare. La stessa testa di sempre
# (`_valore`) e la stessa spinta della strategia; a cambiare e' solo che non
# c'e' piu' una colonna da scegliere prima.
# NEL TURNO V2 L'INCASSO COSTA UN TURNO. Nella v1.5 attivare era gratis (il
# lavoratore attivava E agiva), quindi una risorsa valeva sempre il suo prezzo
# di mercato. Qui attivare o passare e' l'azione intera, in concorrenza con il
# costruire, e a fine era la dispersione taglia a `resource_cap_per_resource`
# per risorsa e a `resource_cap` in tutto: le risorse oltre quello che il
# mercato puo' assorbire in quest'era, o oltre il tetto con l'ultimo
# lavoratore, non valgono quasi niente. Senza questo sconto il bot passava
# l'era a incassare con tredici pietre in mano e le perdeva tutte (registro
# 93): la prima misura del turno v2 usciva a 15 punti a giocatore.
const VALORE_OLTRE_SOGLIA := 0.15

static func _valore_incasso(gs: GameState, p: PlayerState, dp: int, do: int, di: int, r: Vector2) -> float:
	var ultimo := p.workers_used + 1 >= p.workers
	var tetto := int(CardDB.constants.get("resource_cap_per_resource", 0))
	if tetto <= 0: tetto = int(CardDB.constants["resource_cap"])
	# Quanto chiede al massimo il mercato, risorsa per risorsa: oltre, si
	# accumula per niente (o per il tetto, che e' gia' compreso nel massimo).
	var max_p := tetto
	var max_o := tetto
	var max_i := tetto
	if not ultimo:
		for id in gs.in_vendita():
			var c: Dictionary = CardDB.buildings[id]["cost"]
			max_p = maxi(max_p, int(c["pietra"]))
			max_o = maxi(max_o, int(c["oro"]))
			max_i = maxi(max_i, int(c.get("idee", 0)))
	return _utili(p.pietra, dp, max_p) * r.x + _utili(p.oro, do, max_o) * r.y \
		+ _utili(p.idee, di, max_i) * r.y

# Le unita' guadagnate che stanno sotto la soglia valgono intere, le altre
# `VALORE_OLTRE_SOGLIA` (qualcosa valgono: uno sconto, uno scambio).
static func _utili(stock: int, guadagno: int, soglia: int) -> float:
	if guadagno <= 0: return float(guadagno)
	var sotto := clampi(soglia - stock, 0, guadagno)
	return float(sotto) + float(guadagno - sotto) * VALORE_OLTRE_SOGLIA

static func _play_turn_v2(ctl: GameController, p: PlayerState, strategia: String) -> void:
	var gs := ctl.gs
	var r := valore_risorse(gs, p)
	var lista: Array[Dictionary] = []
	for c in gs.grid.n_cols:
		if c in p.worker_cols: continue
		var copia := gs.duplica()
		var pc: PlayerState = copia.players[p.index]
		var prima := Vector3(pc.pietra, pc.oro, pc.idee)
		EraRules.activate(copia, p.index, c)
		var guadagno := _valore_incasso(gs, p, pc.pietra - int(prima.x), pc.oro - int(prima.y),
			pc.idee - int(prima.z), r)
		var v := AvailableActions.Voce.new()
		v.tipo = "colonna"
		v.legale = true
		v.etichetta = "Attiva la colonna %d" % c
		v.parametri = {"col": c}
		# Anche i punti (Cultura, effetti all'attivazione) contano.
		guadagno += float(pc.vp - p.vp) * 0.9
		lista.append({"mossa": v, "valore": guadagno + 0.3})
	for v in _opzioni_v2(gs, p.index, r):
		lista.append({"mossa": v, "valore": _valore(gs, p, v, strategia, int(v.parametri.get("col_from", -1)))})
	var scelta := migliore(lista)
	if scelta.is_empty() or not _esegui(ctl, scelta["mossa"]):
		ctl.passa(_risorsa_da_passare(p, r))

static func _opzioni_v2(gs: GameState, player: int, r: Vector2) -> Array:
	var p: PlayerState = gs.players[player]
	var out := []
	for card_id in gs.in_vendita():
		for v in AvailableActions.piazzamenti_ovunque(gs, player, card_id):
			if v.pagabile(p): out.append(v)
	for v in AvailableActions.potenziamenti_ovunque(gs, player):
		if v.pagabile(p): out.append(v)
	for v in AvailableActions.ristrutturazioni(gs, player):
		if v.pagabile(p): out.append(v)
	if not ctl_draft():
		for v in AvailableActions.reclutamenti(gs, player, -1):
			if v.legale and v.pagabile(p): out.append(v)
	var d := AvailableActions.dinastia(gs, player)
	if d.legale and d.pagabile(p): out.append(d)
	out.append(AvailableActions.passa(_risorsa_da_passare(p, r)))
	return out

# La risorsa da chiedere passando: quella che vale di piu', e fra oro e Idee
# quella che manca di piu'.
static func _risorsa_da_passare(p: PlayerState, r: Vector2) -> String:
	if r.y < r.x: return "pietra"
	return "idee" if p.idee < p.oro else "oro"

static func _opzioni(gs: GameState, player: int, col: int) -> Array:
	var p: PlayerState = gs.players[player]
	var out := []
	# Con l'incasso al passaggio (registro 109) passare e' una mossa fra le
	# altre, con il valore delle due risorse: il bot puo' preferirla a una
	# costruzione che vale poco, che e' il punto della regola.
	if bool(CardDB.constants.get("passa_incasso", false)) and not bool(CardDB.constants.get("turno_v2", false)):
		out.append(AvailableActions.passa(_risorsa_da_passare(p, valore_risorse(gs, p))))
	for card_id in gs.in_vendita():
		for v in AvailableActions.piazzamenti(gs, player, col, card_id):
			if v.pagabile(p): out.append(v)
	for v in AvailableActions.potenziamenti(gs, player, col):
		if v.legale and v.pagabile(p): out.append(v)
	for v in AvailableActions.restauri(gs, player, col):
		if v.legale and v.pagabile(p): out.append(v)
	if not ctl_draft():
		for v in AvailableActions.reclutamenti(gs, player, col):
			if v.legale and v.pagabile(p): out.append(v)
	var d := AvailableActions.dinastia(gs, player)
	if d.legale and d.pagabile(p): out.append(d)
	return out

static func _esegui(ctl: GameController, v) -> bool:
	var par: Dictionary = v.parametri
	match v.tipo:
		"colonna":
			return ctl.place_worker(int(par["col"]))
		"passa":
			return ctl.passa(str(par.get("scelta", "oro")))
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
# `dett` e' un taccuino facoltativo: se lo si passa, il valutatore ci scrive
# dentro voce per voce da dove viene il punteggio. Non cambia il conto - e'
# la stessa aritmetica - ma permette di RACCONTARE la mossa invece di
# limitarsi al totale.
static func _valore(gs: GameState, p: PlayerState, v, strategia: String, col: int,
		dett := {}) -> float:
	var r := valore_risorse(gs, p)
	# Le Idee (v2) si contano come l'oro: una risorsa che non si scava.
	var speso := float(v.pietra) * r.x + float(v.oro) * r.y + float(v.idee) * r.y
	# V3: le risorse muoiono a fine era. Quel che non si potra' spendere nei
	# piazzamenti rimasti non costa niente spenderlo adesso.
	speso *= _fattore_morte(gs, p)
	if speso != 0.0: dett["costo"] = -speso
	match v.tipo:
		"passa":
			# Passare vale le due risorse che porta, meno il turno che costa;
			# nel turno v2 con lo sconto sull'incasso oltre soglia.
			var scelta := str(v.parametri.get("scelta", "oro"))
			var base := int(CardDB.constants.get("passa_incasso_pietra", 1))
			var extra := int(CardDB.constants.get("passa_incasso_scelta", 1))
			var q := _valore_incasso(gs, p, base + (extra if scelta == "pietra" else 0),
				extra if scelta == "oro" else 0, extra if scelta == "idee" else 0, r) - 0.5
			dett["passare e incassare"] = q
			return q
		"costruisci": return _valore_costruzione(gs, p, v, strategia, r, dett) - speso
		"potenzia": return _valore_potenziamento(gs, p, v, dett, strategia) - speso
		"restaura": return _valore_restauro(gs, p, v, dett) - speso
		"recluta": return _valore_reclutamento(gs, p, v, strategia, r, dett) - speso
		"dinastia": return _valore_dinastia(gs, dett) - speso
	return 0.0

# LE RISORSE MUOIONO (v3, costante `risorse_muoiono`, registro 157). Un
# giocatore vero, all'ultimo lavoratore dell'era, spende tutto quel che ha:
# tenere non vale niente. Qui si stima quanto si potra' ancora spendere nei
# piazzamenti rimasti (circa 2,5 risorse l'uno, un po' di piu' se le carte
# danno acquisti extra) e si confronta con quel che si ha in mano: la quota di
# risorse che non si potra' spendere vale zero, sia come costo di una mossa
# sia come guadagno di un'attivazione. Vale 1 (nessuno sconto) fuori dalla v3.
# Lo stato guardato e' quello DOPO il piazzamento di questo turno, quindi i
# lavoratori rimasti sono quelli che restano dopo questo.
const SPESA_PER_PIAZZAMENTO := 2.5

static func _fattore_morte(gs: GameState, p: PlayerState) -> float:
	if not PersonaggiV3.risorse_muoiono(): return 1.0
	var rimasti := maxi(0, p.workers - p.workers_used)
	var capacita := float(rimasti) * SPESA_PER_PIAZZAMENTO + (1.5 if p.extra_turno > 0 or gs.acquisto_extra_aperto else 0.0)
	var stock := float(p.total_resources())
	if stock <= 0.0: return 1.0
	return clampf(capacita / stock, 0.0, 1.0)

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

# LE SPINTE DELLE STRATEGIE, in tabella (registro 98): nella v1.5 sono
# quelle tarate a suo tempo; nella v2 le sei strategie vanno ritarate sul
# lotto di riferimento, e la taratura si fa misurando, con la manopola
# `--spinta chiave=valore,...` dell'audit, poi si scrive qui.
# `protezione_attesa` e' la resistenza in piu' che il valutatore comune si
# aspetta dai lavoratori a venire quando stima le rendite future di un
# edificio: con quattro lavoratori (v2) quasi ogni edificio che conta viene
# protetto, e stimarlo scoperto faceva sembrare la Rendita meno di quello
# che rende (la strategia Rendita vinceva il 55% proprio perche' ci credeva
# di piu' del valutatore).
const SPINTE_V1 := {"rendita_per_era": 0.9, "rendita_zero": -1.5, "lampo": 1.6, "lampo_zero": -1.0,
	"scavo_premio": 0.8, "scavo_terra": -1.5, "scavo_terra_scavo": 0.0, "protezione_attesa": 0.0,
	"lampo_potenzia": 0.0, "lampo_sopra": 0.0, "obiettivi_peso": 1.0, "continuita_peso": 1.0}
# La tabella v2 e' il lotto Q2 della taratura (registro 98) piu' la spinta
# ai potenziamenti della Lampo (registro 101, lotto L2): protezione
# attesa 2 (il valutatore conta l'edificio protetto), la Scavo costruisce a
# terra le carte con lo Scavo alto invece di passare; le altre spinte
# restano quelle della v1.5, perche' abbassarle non aiutava.
# Registro 114: col torneo su tutte le combinazioni (`--giro tutte`) la Scavo
# era la debole a due e a tre (38% e 26%), e spingerla di piu' la peggiorava:
# le spinte sono handicap rispetto al valutatore comune, non aiuti. A meta'
# (premio 0,4, Scavo a terra 0,25) torna nella media a tutti e due i tavoli.
const SPINTE_V2 := {"rendita_per_era": 0.9, "rendita_zero": -1.5, "lampo": 1.6, "lampo_zero": -1.0,
	"scavo_premio": 0.4, "scavo_terra": -0.5, "scavo_terra_scavo": 0.25, "protezione_attesa": 2.0,
	"lampo_potenzia": 3.0, "lampo_sopra": 0.0, "obiettivi_peso": 1.0, "continuita_peso": 1.0}
# LE SPINTE PER NUMERO DI GIOCATORI (registro 114). Le regole non cambiano
# col numero di giocatori (registro 113), i bot si': a due la Continuita'
# vinceva il 58% e la Obiettivi il 40%, a quattro la Rendita il 30% e la
# Lampo il 20%. Qui, per la v2, la tabella di un tavolo sovrascrive le voci
# della tabella base; il tavolo lo dice `giocatori`, che `play_turn` legge
# dalla partita. Vuota dove la tabella base va bene.
# A quattro la Lampo vinceva il 18%: con meta' peso al Lampo delle carte e
# piu' ai potenziamenti (5) sale al 26%, e la Rendita scende da 36 a 32.
# Registro 118, con le case della riserva (che danno Lampo a tutti e un
# edificio in piu' a testa): a tre la Lampo vinceva il 40%, e la spinta a 2
# (piu' handicap) la riporta al 30; a quattro la Rendita vinceva il 32% e la
# Scavo il 19: Rendita per era a 1,5 e Scavo a un quarto le riportano a 28
# e 23. Tarato sul torneo `--giro tutte`, 750 partite, seme 700000.
# Registro 125, con le caselle e il Lampo delle carte al massimo 2: la Lampo
# vinceva ancora il 56/45/39 %. Con la spinta a 2,6 (a quattro 3,2, dove
# resta piu' forte) torna nell'errore: a tre le sei strategie stanno fra 30 e
# 38 %. Tarato sul torneo `--giro tutte`, 300 partite, seme 700000.
# Registro 127, dopo l'era 4 a forza 3, l'avanzo in Idee e le carte vive: a
# due la Obiettivi vinceva il 59 % e la Lampo il 38 %, a tre la Obiettivi il
# 38 %, a quattro il 32 %. Il peso della Obiettivi va GIU' per indebolirla (a
# differenza del Lampo, dove la spinta alta e' un handicap).
# Registro 136, con le rovine a tessere, le carte restituite, la Continuita'
# a collezione e i flussi riequilibrati: la Rendita vinceva il 20% a ogni
# tavolo qualunque fosse il suo peso, perche' scartava le carte senza
# Rendita (l'80% del mazzo): senza quella penalita' torna nella media. Il
# premio di scavo nel bot rafforzava la Scavo invece di frenarla (34-39% a
# quattro con 0,6): a zero la riporta al 26%. La Lampo torna in media con
# meno peso (1,4 a tre, 1,0 a quattro).
const SPINTE_V2_PER_GIOCATORI := {2: {"lampo": 2.0, "obiettivi_peso": 0.6, "rendita_zero": 0.0},
	3: {"lampo": 1.2, "obiettivi_peso": 1.5, "rendita_zero": 0.0, "scavo_premio": 0.0},
	4: {"lampo": 1.0, "lampo_potenzia": 5.0, "rendita_per_era": 1.5, "rendita_zero": 0.0,
		"scavo_premio": 0.0, "scavo_terra_scavo": 0.1, "obiettivi_peso": 0.45}}
static var giocatori := 0
static var spinte_override := {}

# LA TABELLA V3 (registro 165). Sulla partita intera della v3 la Lampo vinceva
# il 23% con 66 PV contro 71-77 delle altre: il Lampo e' il canale che tutti
# prendono (16 PV a testa) e inseguirlo di piu' non rende. Con la spinta a 0,8
# e i potenziamenti a 1,5 (misurati con `--spinta` sugli stessi 300 semi) la
# Lampo fa 69 PV e vince il 30%, come con 1,0 e come la base: le tre tarature
# stanno nell'errore sulle vittorie, questa da' i punti migliori.
# Registro 168: la penalita' sulle carte senza Lampo (`lampo_zero` -1) le
# faceva scartare le carte a Rendita, le piu' forti (5,6 PV di Rendita contro
# 10-16 delle altre). A zero la Lampo passa dal 25 al 31% con 71 PV e resta
# una Lampo (22 PV dal canale); abbassare `lampo` a 0,4 la fa giocare come la
# Bilanciata, alzarlo a 1,2 non rende.
const SPINTE_V3 := {"rendita_per_era": 0.9, "rendita_zero": -1.5, "lampo": 0.8, "lampo_zero": 0.0,
	"scavo_premio": 0.4, "scavo_terra": -0.5, "scavo_terra_scavo": 0.25, "protezione_attesa": 2.0,
	"lampo_potenzia": 1.5, "lampo_sopra": 0.0, "obiettivi_peso": 1.0, "continuita_peso": 1.0}

static func spinte() -> Dictionary:
	var base := SPINTE_V2 if e_v2() else SPINTE_V1
	if PersonaggiV3.attivo(): base = SPINTE_V3
	var tavolo: Dictionary = SPINTE_V2_PER_GIOCATORI.get(giocatori, {}) if e_v2() else {}
	if spinte_override.is_empty() and tavolo.is_empty(): return base
	var out := base.duplicate()
	for k in tavolo: out[k] = tavolo[k]
	for k in spinte_override: out[k] = spinte_override[k]
	return out

static func _valore_costruzione(gs: GameState, p: PlayerState, v, strategia: String,
		r: Vector2, dett := {}) -> float:
	var par: Dictionary = v.parametri
	var d: Dictionary = CardDB.buildings[str(par["card_id"])]
	var col_from := int(par["col_from"])
	var sopra: bool = par["above"]
	var res := int(d["resistance"])
	if not TessereEra.attive() and gs.grid.terrains[col_from] == Enums.Terrain.COLLINA \
			and (not EraRules.tessere_una_volta(gs) or EraRules.tessera_disponibile(gs, col_from)): res += 1
	var rimaste := _ere_rimaste(gs)

	var q := float(d["lampo"])
	if q != 0.0: dett["lampo subito"] = q
	var rend := rendite_future(res + int(round(float(spinte()["protezione_attesa"]))), int(d["rendita"]), gs.era)
	if rend != 0.0: dett["rendite future"] = rend
	q += rend
	var prod: Dictionary = d.get("production", {})
	var pr := (float(prod.get("pietra", 0)) * r.x + float(prod.get("oro", 0)) * r.y
		+ float(prod.get("idee", 0)) * r.y + float(prod.get("cultura", 0))) * float(rimaste) * 0.5
	if pr != 0.0: dett["produzione"] = pr
	q += pr

	var larghezza := int(d["width"])
	var premio_stimato := 0.0     # il premio di scavo di questa costruzione, per la strategia Scavo v2
	if sopra:
		# La Verticalita' paga il premio della colonna per OGNI colonna che
		# l'edificio tocca, e chi sta in cima ne prende meta'.
		var tab = CardDB.constants["verticality_vp"]
		var vert := 0.0
		for c in range(col_from, col_from + larghezza):
			var h: int = gs.grid.height(c)
			var prima := 0 if h < 1 else int(tab[str(mini(h, 4))])
			var dopo := int(tab[str(mini(h + 1, 4))])
			vert += float(dopo - prima) * 0.35 + float(dopo) * 0.15
		# Cosa finisce sotto e cosa si spiana lo dice il preventivo, che sa
		# gia' quali edifici faranno da base: lo Scavo di un proprio rudere si
		# incassa, la rendita futura di un proprio intatto spianato si perde.
		if vert != 0.0: dett["Verticalita' della colonna"] = vert
		q += vert
		var q2 := BuildRules.quote_above(gs, p.index, d, col_from)
		var sotto := 0.0
		var perso := 0.0
		# Con `scavo_a_chi_scava` lo Scavo dei sepolti ALTRUI e' mio e il mio
		# sepolto da me vale 0: la stessa riga, letta dalla parte giusta.
		var a_chi_scava := bool(CardDB.constants.get("scavo_a_chi_scava", false))
		for b in q2.bases:
			if (b.owner != p.index) == a_chi_scava: sotto += float(b.scavo_value()) * 0.5
		for b in q2.razed:
			perso -= rendite_future(b.effective_resistance(), b.rendita_value(), gs.era) * 0.6
			# Spianato vale Scavo 0, salvo la manopola `spianare_conserva_scavo`:
			# allora il suo Scavo e' gia' contato sopra fra "i miei che vanno
			# sotto", e togliergli un quarto sarebbe giocare una regola vecchia.
			if not bool(CardDB.constants.get("spianare_conserva_scavo", false)):
				perso -= float(b.data["scavo"]) * 0.25
		if sotto != 0.0: dett["Scavo dei miei che vanno sotto"] = sotto
		if perso != 0.0: dett["quel che perdo spianando"] = perso
		q += sotto + perso
		# Il premio di scavo (manopola `premio_scavo`) si incassa subito: vale
		# quasi per intero, scontato solo perche' una base larga puo' non
		# finire coperta del tutto da questa costruzione.
		if str(CardDB.constants.get("premio_scavo", "nessuno")) != "nessuno":
			var premio := 0.0
			for b in q2.bases: premio += float(Scoring.premio_scavo(TessereScavo.scavo_per_premio(b), q2.level, gs.era))
			if premio != 0.0:
				dett["premio di scavo"] = premio * 0.8
				q += premio * 0.8
				premio_stimato = premio
	# Continuita' di luogo: una seconda carta della stessa classe nella colonna.
	# Come collezione (registro 132) conta quanto la carta allunga la classe
	# fra tutti i propri edifici, dovunque siano.
	var mie := {}
	var collezione := CardDB.constants.has("continuita_collezione")
	if collezione:
		mie = Scoring.classi_di(gs, p.index)
		var passo := _premio_collezione(mie, d)
		if passo > 0.0:
			q += passo * 0.5
			dett["collezione di classe"] = passo * 0.5
	else:
		for b in gs.grid.in_column(col_from):
			if b.owner != p.index: continue
			for c in b.classes(): mie[c] = int(mie.get(c, 0)) + 1
		for c in d["classes"]:
			if int(mie.get(c, 0)) >= 1:
				q += 1.5
				dett["continuita' di classe in colonna"] = 1.5
				break
	# Lo Scavo si incassa solo da sotterrati: vale, ma meno della rendita.
	if float(d["scavo"]) != 0.0: dett["Scavo suo"] = float(d["scavo"]) * 0.25
	q += float(d["scavo"]) * 0.25

	# LA PREFERENZA DELLA STRATEGIA. Tira in due sensi: premia la carta che fa
	# al caso suo e scoraggia quella che non ne fa. Solo il premio non
	# bastava - il valutatore comune vale molto di piu' della spinta, e le
	# cinque finivano per giocare la stessa partita.
	var prima_della_spinta := q
	var sp := spinte()
	match strategia:
		"rendita":
			q += float(d["rendita"]) * float(rimaste) * float(sp["rendita_per_era"])
			if int(d["rendita"]) == 0: q += float(sp["rendita_zero"])
		"lampo":
			q += float(d["lampo"]) * float(sp["lampo"])
			if int(d["lampo"]) == 0: q += float(sp["lampo_zero"])
			if sopra: q += float(sp["lampo_sopra"])
		"scavo":
			if e_v2():
				# V2: lo Scavo lo incassa chi scava, sul momento. La strategia
				# cerca le pile ricche e alte; a terra costruisce le carte con
				# lo Scavo alto, che sepolte pagano.
				q += premio_stimato * float(sp["scavo_premio"])
				if not sopra: q += float(sp["scavo_terra"]) + float(d["scavo"]) * float(sp["scavo_terra_scavo"])
			else:
				q += float(d["scavo"]) * 0.9 + (2.0 if sopra else 0.0)
				if int(d["scavo"]) == 0: q -= 1.0
		"verticale":
			if sopra: q += 3.0 + 1.2 * float(par.get("level", 1))
			else: q -= 1.5
		"continuita":
			var catena := _premio_collezione(mie, d) if collezione else _premio_catena(mie, d)
			q += catena * float(sp["continuita_peso"])
		"obiettivi": q += _premio_obiettivi(gs, p, d, col_from, par) * float(sp["obiettivi_peso"])
	if q != prima_della_spinta:
		dett["spinta della strategia %s" % strategia] = q - prima_della_spinta
	return q

# Quanto vale la carta per la collezione (registro 132): i PV che aggiunge
# alla classe migliore, piu' un anticipo per la soglia successiva, perche' a
# soglie la carta che non la passa vale zero ma avvicina.
static func _premio_collezione(mie: Dictionary, d: Dictionary) -> float:
	var meglio := 0.0
	for c in d["classes"]:
		var quante := int(mie.get(c, 0))
		var ora := Scoring.continuita_collezione_pv(quante)
		var dopo := Scoring.continuita_collezione_pv(quante + 1)
		var poi := Scoring.continuita_collezione_pv(quante + 2)
		meglio = maxf(meglio, float(dopo - ora) + 0.5 * float(poi - dopo))
	return meglio

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

static func _valore_potenziamento(gs: GameState, p: PlayerState, v, dett := {}, strategia := "") -> float:
	var par: Dictionary = v.parametri
	var b := _per_uid(gs, int(par["uid"])) if par.has("uid") else null
	if b == null: return 0.0
	# LA STRATEGIA LAMPO POTENZIA (registro 101): costruiva 16 edifici fragili
	# e restava ultima; una spinta ai potenziamenti (che con lo scheletro che
	# conta sempre sono punti sicuri) le da' il canale che le mancava.
	var spinta_lampo := float(spinte()["lampo_potenzia"]) if strategia == "lampo" else 0.0
	if spinta_lampo != 0.0: dett["spinta della strategia lampo"] = spinta_lampo
	# Una carta infilata sotto dura quanto l'edificio che la ospita.
	var vive := b.effective_resistance() >= gs.era + 1
	dett["l'ospite regge l'evento" if vive else "l'ospite rischia di crollare"] = \
		2.2 if vive else 0.8
	if b.rendita_value() > 0:
		dett["rendita dell'ospite"] = float(b.rendita_value()) * 0.3
	var q := (2.2 if vive else 0.8) + float(b.rendita_value()) * 0.3 + spinta_lampo
	# Lo scheletro del potenziamento (registro 95): 6 meno l'era se l'edificio
	# finira' sotterrato, contato come una possibilita', come per i Personaggi.
	if (bool(CardDB.constants.get("scheletro_potenziamento", false)) or bool(CardDB.constants.get("turno_v2", false))) \
			and gs.era <= 4 and b.buried_character == "":
		# Se conta comunque ("sempre") sono punti quasi sicuri; se conta
		# solo da sotterrato, una possibilita'.
		var peso := 0.8 if str(CardDB.constants.get("scheletro_conta", "sotterrato")) == "sempre" else 0.3
		q += peso * float(6 - gs.era)
		dett["lo scheletro vale %d" % (6 - gs.era)] = peso * float(6 - gs.era)
	return q

static func _valore_restauro(gs: GameState, p: PlayerState, v, dett := {}) -> float:
	var b := _per_uid(gs, int(v.parametri["uid"]))
	if b == null: return 0.0
	# Torna intatto e la Vetusta' si azzera; se era altrui, cambia padrone.
	var q := rendite_future(int(b.data["resistance"]) + b.bonus_res, b.rendita_value(), gs.era)
	if q != 0.0: dett["rendite che torna a pagare"] = q
	if float(b.data["scavo"]) != 0.0: dett["Scavo suo"] = float(b.data["scavo"]) * 0.25
	q += float(b.data["scavo"]) * 0.25
	if b.owner != p.index:
		q += 2.0
		dett["ed e' altrui: cambia padrone"] = 2.0
	return q

# QUANTO VALE UN PERSONAGGIO. Anche qui il brief e' esplicito: va calcolato
# "dalla sua abilita' reale, non stimato". Le abilita' sono dati strutturati
# (`effects`), quindi si leggono una per una invece di dare a tutti lo stesso
# numero: il Capotribu' che da' 2 pietra subito non vale come lo Sciamano che
# da' +1 resistenza agli edifici Religione, e lo Sciamano vale qualcosa solo
# se di edifici Religione ne ho.
# Un Personaggio della v3 (ha `produzione` e `azione`): vale la sua produzione
# al valore di mercato piu' l'azione, pesata dalla strategia. Al draft non si
# sa ancora su quale colonna andra', quindi le azioni con una condizione
# valgono meno di quelle secche.
static func _valore_personaggio_v3(gs: GameState, p: PlayerState, d: Dictionary, strategia: String,
		r: Vector2, dett := {}) -> float:
	var pr: Dictionary = d.get("produzione", {})
	var q := float(pr.get("pietra", 0)) * r.x + float(pr.get("oro", 0)) * r.y + float(pr.get("idee", 0)) * r.y
	dett["produce"] = q
	var az: Dictionary = d.get("azione", {})
	var a := 0.0
	match str(az.get("tipo", "nessuna")):
		"risorsa": a = 0.8
		"cambio": a = 0.5 + (0.3 if strategia == "bilanciata" else 0.0)
		"pv":
			a = 0.9 if not az.has("se") else 0.5
			if strategia == "lampo": a += 0.5
		"resistenza": a = 0.5 * float(az.get("n", 1)) + (0.6 if strategia == "rendita" else 0.0)
		"sconto": a = 0.8 if not az.has("se") else 0.5
		"scavo": a = 0.3 * float(az.get("n", 1)) + (0.8 if strategia == "scavo" else 0.0)
		"lampo": a = 1.0 + (0.5 if strategia == "lampo" else 0.0)
		"altri": a = 0.6
		"acquisto": a = 0.4     # si usa poco: quando si apre, spesso non resta niente da spendere (registro 159)
		"adiacente": a = 0.6
		"tessera": a = 0.4
	# La collezione (Continuita'): un Personaggio della classe che si sta
	# raccogliendo vale un po' di piu'.
	if strategia == "continuita":
		var mia := {}
		for b in gs.grid.buildings:
			if b.owner != p.index: continue
			for cl in b.data["classes"]: mia[cl] = int(mia.get(cl, 0)) + 1
		if int(mia.get(str(d.get("class", "")), 0)) >= 2: a += 0.4
	dett["la sua azione"] = a
	return q + a + 0.5

static func _valore_reclutamento(gs: GameState, p: PlayerState, v, strategia: String,
		r: Vector2, dett := {}) -> float:
	var d: Dictionary = CardDB.characters[str(v.parametri["char_id"])]
	if d.has("produzione"): return _valore_personaggio_v3(gs, p, d, strategia, r, dett)
	var q := 0.5                                   # il lavoratore specializzato in se'
	dett["un lavoratore in piu'"] = 0.5
	var abilita := 0.0
	for e in d.get("effects", []):
		abilita += _valore_effetto(gs, p, e, r)
	if abilita != 0.0: dett["la sua abilita' (%s)" % str(d.get("class", "?"))] = abilita
	q += abilita
	# Se finisce sepolto vale 6 meno l'era: si conta per quel che e', una
	# possibilita', non una certezza.
	if gs.era <= 4:
		q += 0.3 * float(6 - gs.era)
		dett["se lo seppellisco vale %d" % (6 - gs.era)] = 0.3 * float(6 - gs.era)
	if strategia == "bilanciata": q += 0.6
	if strategia == "scavo": q += 0.6
	if strategia == "bilanciata" or strategia == "scavo":
		dett["spinta della strategia %s" % strategia] = 0.6
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

static func _valore_dinastia(gs: GameState, dett := {}) -> float:
	# Un quarto lavoratore per tutte le ere che restano: e' il moltiplicatore
	# piu' grosso che si possa comprare, e prima lo si compra piu' rende.
	var q := 1.2 * float(_ere_rimaste(gs) + 1)
	dett["un quarto lavoratore per %d ere" % (_ere_rimaste(gs) + 1)] = q
	return q

# La scelta in sospeso (dove infilare il potenziamento dell'Eruzione): si
# sceglie l'edificio che reggera' piu' a lungo, cosi' la carta non muore con
# lui nella stessa era.
static func ctl_draft() -> bool:
	return bool(CardDB.constants.get("draft_personaggi", false))

# Il draft: la carta che vale di piu' per la strategia, con lo stesso conto
# del reclutamento (senza costo: e' gratis).
static func _scelta_draft(gs: GameState, strategia: String) -> int:
	var opzioni: Array = gs.pending_choice["options"]
	var p: PlayerState = gs.players[int(gs.pending_choice["player"])]
	var r := valore_risorse(gs, p)
	var meglio := int(opzioni[0])
	var punteggio := -INF
	for i in opzioni:
		var v := AvailableActions.Voce.new()
		v.parametri = {"char_id": gs.char_row[int(i)]}
		var q := _valore_reclutamento(gs, p, v, strategia, r)
		if q > punteggio:
			punteggio = q
			meglio = int(i)
	return meglio

# V3 "scelta" (registro 170): quale edificio usare. Si prova ciascuno su una
# copia e si tiene quello che rende di piu', con lo stesso conto del
# piazzamento (`_guadagno_v3`) piu' la mossa migliore che apre.
static func _scelta_edificio(gs: GameState, strategia: String) -> int:
	var opzioni: Array = gs.pending_choice["options"]
	var p: PlayerState = gs.players[int(gs.pending_choice["player"])]
	var col := int(gs.pending_choice["col"])
	var meglio := int(opzioni[0])
	var punteggio := -INF
	for uid in opzioni:
		var copia := gs.duplica()
		var ctl := GameController.new()
		ctl.gs = copia
		if not ctl.choose(int(uid)): continue
		var pc: PlayerState = copia.players[p.index]
		var mossa := 0.0
		for v in _opzioni(copia, p.index, col):
			mossa = maxf(mossa, _valore(copia, pc, v, strategia, col))
		var q := mossa + _guadagno_v3(gs, p, copia, pc, col, strategia)
		if q > punteggio:
			punteggio = q
			meglio = int(uid)
	return meglio

static func _scelta(gs: GameState, strategia := "bilanciata") -> int:
	var opzioni: Array = gs.pending_choice.get("options", [])
	if opzioni.is_empty(): return 0
	if str(gs.pending_choice.get("kind", "")) == "draft": return _scelta_draft(gs, strategia)
	if str(gs.pending_choice.get("kind", "")) == "edificio": return _scelta_edificio(gs, strategia)
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
