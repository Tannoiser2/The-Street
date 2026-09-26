# res://scripts/tools/audit_partita.gd
# Rigioca un seme e racconta la partita turno per turno, poi la spoglia.
# Uso:  godot --headless res://scenes/audit_partita.tscn -- --seed 1609 --players 3 [--muto]
#
# Serve al designer: il riepilogo a fine partita dice DOVE sono andati i punti,
# ma non COME ci sono arrivati. Qui ogni turno si vede la mossa, quanto e'
# costata e cosa ha fruttato, cosi' un distacco grosso si puo' spiegare invece
# di indovinarlo.
#
# NB: si lancia come SCENA, non con --script (gli Autoload, CardDB, non
# esistono in modalita' --script).
extends Node

var _prima_edifici := {}
var _prima_giocatori := []
var _muto := false
var _perche := false
var _piano := false
var _tutti := ""
# Chi muove i bot: le sei strategie vere o il tira-a-caso di RandomBot.
# Il caso serve ancora come metro di paragone - "quanto pesa la testa di chi
# gioca" e' la differenza fra le due colonne.
var _strategie := true
# Con --candidate entra in gioco anche la strategia fuori canone
# (Continuita'): serve a misurare se sei bastano.
var _candidate := false
# Il bot prova ogni mossa legale in ordine casuale, quindi il log si riempie di
# "Costruzione rifiutata": e' il suo modo di cercare, non un fatto della
# partita. Fuori per difetto, --tutto le rimette.
var _tutto := false

func _ready() -> void:
	var args := _parse_args(OS.get_cmdline_user_args())
	var seme := int(args.get("seed", "1"))
	var players := int(args.get("players", "3"))
	# UN ALTRO FILE DATI (`--dati data/cards-v2.json`): la v2 con tre risorse
	# gioca sullo stesso motore, e `cards.json` resta la fonte della v1.5.
	if args.has("dati"):
		CardDB.load_db("res://" + str(args["dati"]).trim_prefix("res://"))
		print("# dati = %s" % str(args["dati"]))
		# Il turno lo decide il file dati: lo si dichiara, cosi' due lotti v2
		# con turni diversi non si confondono.
		print("# turno_v2 = %s" % str(bool(CardDB.constants.get("turno_v2", false))))
		print("# draft_personaggi = %s" % str(bool(CardDB.constants.get("draft_personaggi", false))))
	_muto = args.has("muto")
	_tutto = args.has("tutto")
	_strategie = not args.has("caso")
	_candidate = args.has("candidate")
	_perche = args.has("perche")
	# IL TORNEO DEL PIANIFICATORE. `--piano` fa pianificare l'era a UN posto,
	# che ruota di partita in partita cosi' nessuno siede sempre li';
	# `--tutti rendita` fa giocare a tutti la stessa strategia. Insieme isolano
	# l'effetto del PIANIFICARE da quello della strategia: stessi bot, stesse
	# preferenze, uno solo guarda avanti.
	_piano = args.has("piano")
	# `--bot 1` rigioca col bot della versione 1, per separare l'effetto del
	# bot da quello delle regole.
	if args.has("bot"):
		StrategyBot.versione_in_uso = int(args["bot"])
		print("# versione del bot = %d" % StrategyBot.versione_in_uso)
	_tutti = str(args.get("tutti", ""))
	# Una tabella della Verticalita' diversa da quella stampata, per provare
	# "e se pagasse meno salire?" senza toccare data/cards.json - che resta
	# l'unica fonte. Il simulatore di riferimento fa lo stesso con VBONUS.
	if args.has("verticalita"):
		var pezzi := str(args["verticalita"]).split(",")
		var tabella := {}
		for i in pezzi.size(): tabella[str(i + 1)] = int(pezzi[i])
		CardDB.constants["verticality_vp"] = tabella
		print("# verticality_vp = %s" % str(tabella))

	# Stessa idea per la soglia del Centro Urbano: "e se bastassero due
	# edifici invece di tre?" si prova qui, senza toccare i dati.
	if args.has("prosperita"):
		var pr: Dictionary = (CardDB.constants["prosperity"] as Dictionary).duplicate()
		pr["min_buildings"] = int(args["prosperita"])
		CardDB.constants["prosperity"] = pr
		print("# prosperity.min_buildings = %d" % int(pr["min_buildings"]))
	# E le due vie per renderla piu' rara senza cambiarne la soglia: piu'
	# proprietari diversi (`--proprietari 3`) o un pagamento solo per colonna
	# e per era (`--una_per_era 1`, accesa nei dati; `--una_per_era 0` la spegne).
	if args.has("proprietari") or args.has("una_per_era"):
		var pr2: Dictionary = (CardDB.constants["prosperity"] as Dictionary).duplicate()
		if args.has("proprietari"): pr2["min_owners"] = int(args["proprietari"])
		# `--una_per_era 0` la spegne: da quando e' accesa nei dati serve anche
		# il contrario, per rimisurare il mondo di prima.
		if args.has("una_per_era"): pr2["once_per_era"] = str(args["una_per_era"]) != "0"
		CardDB.constants["prosperity"] = pr2
		print("# prosperity.min_owners = %d once_per_era = %s" % [int(pr2["min_owners"]),
			str(bool(pr2.get("once_per_era", false)))])

	# Le manopole della punizione, per provare "e se il gioco perdonasse di
	# piu'?" senza toccare i dati:
	#   --rudere 1      quanto costa essere un rudere (rudere_penalty)
	#   --gap 3         di quanto si puo' fallire restando in piedi
	#   --forza 2,3,3,4 la forza dell'evento, era per era
	if args.has("rudere"):
		CardDB.constants["rudere_penalty"] = int(args["rudere"])
		print("# rudere_penalty = %d" % int(args["rudere"]))
	if args.has("gap"):
		CardDB.constants["rovina_gap"] = int(args["gap"])
		print("# rovina_gap = %d" % int(args["gap"]))
	# SENZA RUDERE (`--senza_rudere 1`, spenta nei dati): fallire di meno della
	# soglia lascia intatto invece di fare rudere. Prima misura dell'audit
	# della nuova meccanica (D15), a parita' di tutto il resto.
	if args.has("senza_rudere"):
		CardDB.constants["senza_rudere"] = str(args["senza_rudere"]) != "0"
		print("# senza_rudere = %s" % str(bool(CardDB.constants["senza_rudere"])))
	# LO SCAVO NON SI AZZERA MAI (`--scavo_spianato 1`, spenta nei dati): un
	# proprio edificio spianato vale il suo Scavo come gli altri sepolti.
	# Decisione del designer per la nuova meccanica (registro 87).
	if args.has("scavo_spianato"):
		CardDB.constants["spianare_conserva_scavo"] = str(args["scavo_spianato"]) != "0"
		print("# spianare_conserva_scavo = %s" % str(bool(CardDB.constants["spianare_conserva_scavo"])))
	# PERCHE' COSTRUIRE SOPRA GLI ALTRI (registro 87), tre manopole spente nei dati:
	#   --scavo_scava 1    lo Scavo lo incassa chi seppellisce (il proprio vale 0)
	#   --sconto_altrui 1  lo sconto macerie solo sulle rovine altrui
	if args.has("scavo_scava"):
		CardDB.constants["scavo_a_chi_scava"] = str(args["scavo_scava"]) != "0"
		print("# scavo_a_chi_scava = %s" % str(bool(CardDB.constants["scavo_a_chi_scava"])))
	if args.has("sconto_altrui"):
		CardDB.constants["sconto_macerie_solo_altrui"] = str(args["sconto_altrui"]) != "0"
		print("# sconto_macerie_solo_altrui = %s" % str(bool(CardDB.constants["sconto_macerie_solo_altrui"])))
	# IL PREMIO DI SCAVO al posto della Verticalita' (registro 89):
	#   --premio per_livello | piu_livello | per_livello_meno_uno
	if args.has("premio"):
		CardDB.constants["premio_scavo"] = str(args["premio"])
		print("# premio_scavo = %s" % str(args["premio"]))
	#   --premio_era5 intero | dimezzato | niente   (la correzione all'ultima era)
	if args.has("premio_era5"):
		CardDB.constants["premio_era5"] = str(args["premio_era5"])
		print("# premio_era5 = %s" % str(args["premio_era5"]))
	#   --tetto N   il tetto per risorsa alla dispersione (0 = solo il totale)
	if args.has("tetto"):
		CardDB.constants["resource_cap_per_resource"] = int(args["tetto"])
		print("# resource_cap_per_resource = %d" % int(args["tetto"]))
	# IL TURNO A UN'AZIONE (`--turno_v2 1`, registro 93; spento nel file v2 dal
	# registro 94): ogni lavoratore fa una cosa sola e va dove agisce.
	if args.has("turno_v2"):
		CardDB.constants["turno_v2"] = str(args["turno_v2"]) != "0"
		print("# turno_v2 = %s" % str(bool(CardDB.constants["turno_v2"])))
	# REGISTRO 95, due manopole per rigiocare la v2 con una sola delle due
	# decisioni: `--sepolti 1` riseppellisce i Personaggi del draft,
	# `--vetusta 3` rimette la Vetusta' (tetto 3, bosco +1).
	if args.has("sepolti"):
		CardDB.constants["personaggi_sepolti"] = str(args["sepolti"]) != "0"
		print("# personaggi_sepolti = %s" % str(bool(CardDB.constants["personaggi_sepolti"])))
	if args.has("vetusta"):
		var vm := int(args["vetusta"])
		CardDB.constants["vetusta_max"] = vm
		CardDB.constants["vetusta_max_bosco"] = vm + 1 if vm > 0 else 0
		print("# vetusta_max = %d" % vm)
	# LA PROTEZIONE DEL LAVORATORE (`--protezione 1`, `protection_bonus`, 2 nei
	# dati): con quattro lavoratori e' quattro edifici protetti per era, e la
	# Rendita vince il 56% (registro 95). Registro 96: si prova a +1.
	if args.has("protezione"):
		CardDB.constants["protection_bonus"] = int(args["protezione"])
		print("# protection_bonus = %d" % int(args["protezione"]))
	# GLI SCHELETRI (`--scheletro sotterrato|sempre`, `scheletro_conta`): con
	# "sempre" lo scheletro del potenziamento paga comunque finisca l'edificio.
	if args.has("scheletro"):
		CardDB.constants["scheletro_conta"] = str(args["scheletro"])
		print("# scheletro_conta = %s" % str(args["scheletro"]))
	# LA RENDITA DELLE CARTE CARE (`--rendita_tetto N`, registro 97): la Rendita
	# stampata si taglia a N su ogni edificio. Come `--forza`, si scontano le
	# carte, non una costante: la Rendita sta sulla carta.
	if args.has("rendita_tetto"):
		var rt := int(args["rendita_tetto"])
		var tagliati := 0
		for id in CardDB.buildings:
			var bd: Dictionary = CardDB.buildings[id]
			if int(bd.get("rendita", 0)) > rt:
				bd["rendita"] = rt
				tagliati += 1
		print("# rendita_tetto = %d (%d edifici tagliati)" % [rt, tagliati])
	# LE SPINTE DELLE STRATEGIE (`--spinta rendita_per_era=0.6,scavo_terra=-0.5`,
	# registro 98): sovrascrive la tabella del bot per tarare la v2 misurando.
	if args.has("spinta"):
		for pezzo in str(args["spinta"]).split(","):
			var kv := pezzo.split("=")
			if kv.size() == 2: StrategyBot.spinte_override[kv[0].strip_edges()] = float(kv[1])
		print("# spinte = %s" % str(StrategyBot.spinte_override))
	# LE TESSERE UNA VOLTA PER ERA (`--tessere 0/1`, `tessere_una_volta_per_era`,
	# registro 100): a 0 le regole delle tessere tornano permanenti come nella v1.5.
	if args.has("tessere"):
		CardDB.constants["tessere_una_volta_per_era"] = str(args["tessere"]) != "0"
		print("# tessere_una_volta_per_era = %s" % str(bool(CardDB.constants["tessere_una_volta_per_era"])))
	# L'INCASSO AL PASSAGGIO (`--passa_incasso 0/1`, `passa_incasso`, spenta
	# dove manca, registro 109): nel turno v1 chi passa incassa 1 Costruzione
	# piu' 1 risorsa a scelta, come nel turno a un'azione.
	if args.has("passa_incasso"):
		CardDB.constants["passa_incasso"] = str(args["passa_incasso"]) != "0"
		print("# passa_incasso = %s" % str(bool(CardDB.constants["passa_incasso"])))
	# I LAVORATORI PER ERA (`--lavoratori 5`, `workers_base`, 3 nei dati). Nel
	# turno v2 ogni lavoratore e' UN'azione, non piu' un'attivazione piu'
	# un'azione: con 3 il ritmo si dimezza (registro 93), e la manopola misura
	# quanti ne servono per tornare al ritmo della v1.5.
	if args.has("lavoratori"):
		CardDB.constants["workers_base"] = int(args["lavoratori"])
		print("# workers_base = %d" % int(args["lavoratori"]))
	# LA FORZA STA SULLA CARTA EVENTO, non nella costante: `event_force_by_era`
	# e' la tabella di riferimento, ma chi decide e' `gs.current_event["force"]`.
	# La prima versione di questa manopola scriveva la costante e non cambiava
	# niente - la variante "eventi piu' deboli" usciva identica al controllo, ed
	# e' cosi' che ce ne siamo accorti. Qui si sconta ogni carta evento.
	# I BINARI LIBERI: un edificio puo' finire su qualunque binario libero,
	# riempiendo dal fondo, invece che solo su quello della sua era.
	if args.has("binari"):
		CardDB.constants["binari_liberi"] = int(args["binari"]) != 0
		print("# binari_liberi = %s" % str(bool(CardDB.constants["binari_liberi"])))

	if args.has("forza"):
		var delta := int(args["forza"])
		for id in CardDB.events:
			var ev: Dictionary = CardDB.events[id]
			if not ev.has("force"): continue
			ev["force"] = maxi(1, int(ev["force"]) + delta)
		print("# forza degli eventi scontata di %d" % delta)

	if args.has("games"):
		_lotto(seme, players, int(args["games"]))
		return
	if args.has("vita"):
		_vita(seme, players, int(args["vita"]))
		return

	var ctl := GameController.new()
	ctl.new_game(players, seme)
	var gs := ctl.gs
	_dì("=== Seme %d · %d giocatori · bot %s ===" % [seme, players,
		"con strategia" if _strategie else "a caso"])
	if _strategie:
		for i in players:
			_dì("  giocatore %d gioca %s" % [i, strategia_di(i, 0)])
	_dì("Terreni: %s" % _terreni(gs))
	for p in gs.players:
		_dì("  giocatore %d · eredita' segreta: %s" % [p.index, _nome_eredita(p.legacy_id)])
	_dì("Monumenti aperti: %s" % _monumenti(gs))

	var era := 0
	var turno := 0
	var guard := 0
	_fotografa(gs)
	var log_letto := 0
	while gs.phase != Enums.Phase.FINE_PARTITA and guard < 10000:
		if gs.era != era:
			era = gs.era
			_dì("\n--- ERA %d · evento: %s · ordine %s ---" % [
				era, gs.current_event.get("name", "nessuno"), str(gs.turn_order)])
			_dì("    " + _borsa(gs))
		var chi := gs.current_index
		_muovi(ctl, 0)
		turno += 1
		_racconta(gs, era, turno, chi)
		log_letto = _log_nuovo(gs, log_letto)
		_fotografa(gs)
		guard += 1

	_dì("\n=== FINE PARTITA (%d turni) ===" % turno)
	_tabella(gs)
	_spoglia(gs)
	get_tree().quit(0)

# Tante partite di fila, una riga CSV per giocatore: serve a sapere se un
# distacco visto in una partita sola e' la regola o il caso.
func _lotto(seme: int, players: int, quante: int) -> void:
	# Oltre ai punti, due misure di FORMA del tavolo: quanti edifici ha
	# costruito sopra e quanto in alto e' arrivato. Servono a vedere se,
	# cambiando quanto paga la Verticalita', cambia anche come si gioca e non
	# solo quanto si segna.
	print("seme;posto;giocatore;pv;strategia;sopra;quota_max;costruiti;"
		+ ";".join(Riepilogo.VOCI.map(func(v): return str(v["id"]))) + ";piano;centro_attivato;oro_centro"
		+ ";sopra_propri;sopra_altrui;spianati;scavo_scavato;scavo_e5;idee_prodotte;idee_spese"
		+ ";az_colonna;az_costruisci;az_potenzia;az_ristruttura;az_recluta;az_dinastia;az_passa")
	for g in quante:
		var ctl := GameController.new()
		ctl.new_game(players, seme + g)
		var guard := 0
		while ctl.gs.phase != Enums.Phase.FINE_PARTITA and guard < 10000:
			_muovi(ctl, g)
			guard += 1
		for riga in Riepilogo.righe(ctl.gs):
			var chi := int(riga["player"])
			var sopra := 0
			var quota := 0
			var costruiti := 0
			for b in ctl.gs.grid.buildings:
				if b.owner != chi: continue
				costruiti += 1
				if b.level > 0: sopra += 1
				quota = maxi(quota, b.level)
			var campi: Array[String] = ["%d" % (seme + g), "%d" % riga["posto"],
				"%d" % chi, "%d" % riga["vp"],
				strategia_di(chi, g) if _strategie else "caso",
				"%d" % sopra, "%d" % quota, "%d" % costruiti]
			for v in Riepilogo.VOCI:
				campi.append("%d" % Riepilogo.punti(riga, str(v["id"])))
			campi.append("1" if pianifica_qui(chi, g, players) else "0")
			var cnt: Dictionary = ctl.gs.players[chi].counters
			campi.append("%d" % int(cnt.get("centro_attivato", 0)))
			campi.append("%d" % int(cnt.get("oro_centro", 0)))
			# Sopra chi ha costruito (registro 87): quante basi erano sue,
			# quante altrui, e quanti suoi intatti ha spianato.
			for k in ["sopra_propri", "sopra_altrui", "spianati", "scavo_scavato", "scavo_e5",
					"idee_prodotte", "idee_spese", "az_colonna", "az_costruisci", "az_potenzia",
					"az_ristruttura", "az_recluta", "az_dinastia", "az_passa"]:
				campi.append("%d" % int(cnt.get(k, 0)))
			print(";".join(campi))
	get_tree().quit(0)

# LA VITA DEGLI EDIFICI. Tante partite, e per ogni CARTA quanto e' durata:
# quante ere resta intatta, quante resta in piedi, quante volte finisce
# sotterrata, quanta Vetusta' accumula e quanti punti ha fruttato al suo
# proprietario. Una riga CSV per carta, da impaginare fuori.
#
# La vita si misura in ERE, perche' e' l'era il battito del gioco: gli eventi
# colpiscono a fine era ed e' li' che un edificio diventa rudere o crolla.
# L'era si prende PRIMA della mossa: la fine di un'era succede dentro il turno
# di qualcuno, e quando il turno torna il contatore e' gia' avanzato.
func _vita(seme: int, players: int, quante: int) -> void:
	var acc := {}
	for g in quante:
		var ctl := GameController.new()
		ctl.new_game(players, seme + g)
		var gs := ctl.gs
		var era_rudere := {}
		var era_rovina := {}
		var era_sepolto := {}
		var visto := {}
		var guard := 0
		while gs.phase != Enums.Phase.FINE_PARTITA and guard < 10000:
			var era: int = gs.era
			_muovi(ctl, g)
			for b in gs.grid.buildings:
				if not visto.has(b.uid): visto[b.uid] = true
				if b.state != Enums.BuildingState.INTATTO and not era_rudere.has(b.uid):
					era_rudere[b.uid] = era
				if b.state == Enums.BuildingState.ROVINA and not era_rovina.has(b.uid):
					era_rovina[b.uid] = era
				if b.is_buried and not era_sepolto.has(b.uid):
					era_sepolto[b.uid] = era
			guard += 1
		var ultima: int = gs.era
		for b in gs.grid.buildings:
			var id := str(b.data["id"])
			if not acc.has(id): acc[id] = _riga_vuota()
			var r: Dictionary = acc[id]
			r["n"] += 1
			# ere da intatto e ere in piedi: se non e' mai caduto si conta
			# fino all'ultima era giocata.
			var fine_intatto: int = int(era_rudere.get(b.uid, ultima))
			var giu: int = mini(int(era_rovina.get(b.uid, 99)), int(era_sepolto.get(b.uid, 99)))
			var fine_piedi: int = ultima if giu == 99 else giu
			r["ere_intatto"] += maxi(0, fine_intatto - b.era_built) + 1
			r["ere_piedi"] += maxi(0, fine_piedi - b.era_built) + 1
			if era_rudere.has(b.uid): r["n_rudere"] += 1
			if era_rovina.has(b.uid): r["n_rovina"] += 1
			if era_sepolto.has(b.uid): r["n_sepolto"] += 1
			if giu != 99 and giu == b.era_built: r["n_subito"] += 1
			if b.is_standing(): r["n_in_piedi_fine"] += 1
			if b.is_alive(): r["n_intatto_fine"] += 1
			if b.was_razed: r["n_spianato"] += 1
			if b.is_buried and b.buried_by >= 0 and b.buried_by != b.owner: r["n_sepolto_altrui"] += 1
			r["vetusta"] += b.vetusta
			r["potenziamenti"] += b.upgrades.size()
			for c in b.vp_reso: r["vp_" + str(c)] = int(r.get("vp_" + str(c), 0)) + int(b.vp_reso[c])
			r["vp"] += b.vp_totali()
	_stampa_vita(acc, quante, players, seme)
	get_tree().quit(0)

const CANALI_CARTA: Array[String] = ["lampo", "rendita", "verticalita", "scavo", "scheletri"]

func _riga_vuota() -> Dictionary:
	var r := {"n": 0, "ere_intatto": 0, "ere_piedi": 0, "n_rudere": 0, "n_rovina": 0,
		"n_sepolto": 0, "n_subito": 0, "n_in_piedi_fine": 0, "n_intatto_fine": 0,
		"vetusta": 0, "potenziamenti": 0, "vp": 0}
	for c in CANALI_CARTA: r["vp_" + c] = 0
	r["n_spianato"] = 0     # in fondo: le colonne nuove si aggiungono in coda
	r["n_sepolto_altrui"] = 0
	return r

func _stampa_vita(acc: Dictionary, quante: int, players: int, seme: int) -> void:
	# La tabella della Verticalita' finisce nell'intestazione: due lotti si
	# confrontano solo se si sa con che regole sono stati giocati.
	var vt = CardDB.constants["verticality_vp"]
	var scala: Array[String] = []
	for i in 4: scala.append("%d" % int(vt[str(i + 1)]))
	print("# partite=%d giocatori=%d seme_base=%d bot=%s verticalita=%s prosperita=%d rovina=%d binari=%s versione_bot=%d strategie=%d centro=%s rudere=%s spianato=%s scavo=%s sconto=%s premio=%s dati=%s era5=%s tetto=%d turno=%s lavoratori=%d draft=%s sepolti=%s vetusta=%d protezione=%d scheletro=%s tessere=%s incasso=%s" % [
		quante, players, seme, "strategie" if _strategie else "caso",
		"/".join(scala), int(CardDB.constants["prosperity"]["min_buildings"]),
		int(CardDB.constants.get("rovina_gap", 2)),
		"liberi" if bool(CardDB.constants.get("binari_liberi", false)) else "per_era",
		StrategyBot.versione_in_uso, _quante_strategie(),
		"una_per_era" if bool(CardDB.constants["prosperity"].get("once_per_era", false))
			else "ogni_attivazione",
		"no" if bool(CardDB.constants.get("senza_rudere", false)) else "si",
		"vale" if bool(CardDB.constants.get("spianare_conserva_scavo", false)) else "zero",
		"scavatore" if bool(CardDB.constants.get("scavo_a_chi_scava", false)) else "proprietario",
		"altrui" if bool(CardDB.constants.get("sconto_macerie_solo_altrui", false)) else "tutti",
		str(CardDB.constants.get("premio_scavo", "nessuno")),
		str(CardDB.ruleset),
		str(CardDB.constants.get("premio_era5", "intero")),
		int(CardDB.constants.get("resource_cap_per_resource", 0)),
		"v2" if bool(CardDB.constants.get("turno_v2", false)) else "v1",
		int(CardDB.constants["workers_base"]),
		"si" if bool(CardDB.constants.get("draft_personaggi", false)) else "no",
		"si" if bool(CardDB.constants.get("personaggi_sepolti", true)) else "no",
		int(CardDB.constants["vetusta_max"]),
		int(CardDB.constants["protection_bonus"]),
		str(CardDB.constants.get("scheletro_conta", "sotterrato")),
		"una_volta" if bool(CardDB.constants.get("tessere_una_volta_per_era", false)) else "permanenti",
		"si" if bool(CardDB.constants.get("passa_incasso", false)) else "no"])
	var intestazione: Array[String] = ["id", "nome", "era", "classi", "larghezza",
		"costo_pietra", "costo_oro", "resistenza", "rendita", "scavo", "lampo_carta",
		"copie", "n", "ere_intatto", "ere_piedi", "n_rudere", "n_rovina", "n_sepolto",
		"n_subito", "n_in_piedi_fine", "n_intatto_fine", "vetusta", "potenziamenti", "vp"]
	for c in CANALI_CARTA: intestazione.append("vp_" + c)
	intestazione.append("n_spianato")
	intestazione.append("n_sepolto_altrui")
	intestazione.append("costo_idee")
	print(";".join(intestazione))
	for id in CardDB.buildings:
		var d: Dictionary = CardDB.buildings[id]
		var r: Dictionary = acc.get(id, _riga_vuota())
		var campi: Array[String] = [str(id), str(d["name"]), str(int(d["era"])),
			"|".join(d["classes"]), str(int(d["width"])),
			str(int(d["cost"]["pietra"])), str(int(d["cost"]["oro"])),
			str(int(d["resistance"])), str(int(d["rendita"])), str(int(d["scavo"])),
			str(int(d["lampo"])), str(int(d.get("copies", 1)))]
		for k in ["n", "ere_intatto", "ere_piedi", "n_rudere", "n_rovina", "n_sepolto",
				"n_subito", "n_in_piedi_fine", "n_intatto_fine", "vetusta",
				"potenziamenti", "vp"]:
			campi.append(str(r[k]))
		for c in CANALI_CARTA: campi.append(str(r["vp_" + c]))
		campi.append(str(r["n_spianato"]))
		campi.append(str(r["n_sepolto_altrui"]))
		campi.append(str(int(d["cost"].get("idee", 0))))
		print(";".join(campi))

# La strategia del posto `i` nella partita `g`: si ruota, cosi' ogni strategia
# gioca ogni posto lo stesso numero di volte e il posto non falsa il confronto.
func strategia_di(i: int, g: int) -> String:
	if _tutti != "": return _tutti
	var lista := StrategyBot.tutte() if _candidate else StrategyBot.canone()
	return lista[(i + g) % lista.size()]

# Quante strategie si alternano al tavolo: finisce nell'intestazione, perche'
# un lotto giocato con cinque e uno con sei non sono lo stesso esperimento.
func _quante_strategie() -> int:
	if not _strategie: return 0
	if _tutti != "": return 1
	return (StrategyBot.tutte() if _candidate else StrategyBot.canone()).size()

# Chi pianifica in questa partita: un posto solo, a rotazione.
func pianifica_qui(i: int, g: int, players: int) -> bool:
	return _piano and i == g % players

func _muovi(ctl: GameController, g: int) -> void:
	if _strategie:
		var chi := ctl.gs.current_index
		# Il pianificatore conosce solo il turno v1.5: nella v2 gioca lo StrategyBot.
		if pianifica_qui(chi, g, ctl.gs.n_players) and not bool(CardDB.constants.get("turno_v2", false)):
			PlanningBot.play_turn(ctl, strategia_di(chi, g))
			return
		StrategyBot.racconta = _perche
		StrategyBot.taccuino = {}
		StrategyBot.play_turn(ctl, strategia_di(chi, g))
		if _perche: _ragiona(ctl.gs)
	else: RandomBot.play_turn(ctl)

# ---- perche' ha fatto quella mossa ---------------------------------
# Il bot sceglie prima la colonna e poi, fra le mosse che quella colonna gli
# apre, quella che vale di piu'. Qui si guarda la stessa classifica che si fa
# lui - le funzioni non tirano dadi, quindi chiederla non cambia la partita -
# e si stampa: cosa ha scelto, quanto valeva, DA COSA era fatto quel valore, e
# cosa ha scartato. "Perche' ha fatto questa mossa" non si risponde altrimenti:
# una mossa si capisce solo accanto a quelle che non ha fatto.
func _ragiona(gs: GameState) -> void:
	var t: Dictionary = StrategyBot.taccuino
	if t.is_empty() or not t.has("colonne"): return
	var colonne: Array = (t["colonne"] as Array).duplicate()
	colonne.sort_custom(func(a, b): return float(a["valore"]) > float(b["valore"]))
	if colonne.is_empty(): return
	var col := int(t.get("col", -1))
	var scelta_col: Dictionary = colonne[0]
	for e in colonne:
		if int(e["col"]) == col: scelta_col = e
	_dì("    · **colonna %d** (%.1f): %s" % [col, float(scelta_col["valore"]),
		_perche_colonna(gs, scelta_col)])
	if colonne.size() > 1:
		var seconda: Dictionary = colonne[0] if int(colonne[0]["col"]) != col else colonne[1]
		_dì("      (la seconda era la %d a %.1f)" % [int(seconda["col"]),
			float(seconda["valore"])])
	if not t.has("scelta") or (t["scelta"] as Dictionary).is_empty():
		_dì("      nessuna mossa vale piu' di zero: passa")
		return
	var scelta: Dictionary = t["scelta"]
	_dì("    · **%s** (%.1f) perche': %s" % [_descrivi(scelta["mossa"]),
		float(scelta["valore"]), _voci(scelta["dettaglio"])])
	var altre: Array = (t["mosse"] as Array).duplicate()
	altre.sort_custom(func(a, b): return float(a["valore"]) > float(b["valore"]))
	var scartate: Array[String] = []
	for e in altre:
		if e["mossa"] == scelta["mossa"] or scartate.size() >= 3: continue
		scartate.append("%s %.1f" % [_descrivi(e["mossa"]), float(e["valore"])])
	if not scartate.is_empty():
		_dì("      scartate: %s" % " · ".join(scartate))

func _perche_colonna(gs: GameState, e: Dictionary) -> String:
	var pezzi: Array[String] = []
	pezzi.append("terreno %s" % _nome_terreno(gs.grid.terrains[int(e["col"])]))
	if float(e["produzione"]) != 0.0:
		pezzi.append("produzione e roba mia %.1f" % float(e["produzione"]))
	if float(e["protezione"]) > 0.0:
		var b = e["salva"]
		pezzi.append("il lavoratore salva %s dall'evento (%.1f)" % [
			b.data["name"] if b != null else "un edificio", float(e["protezione"])])
	if float(e["mossa"]) > 0.0:
		pezzi.append("ci si puo' fare una mossa da %.1f" % float(e["mossa"]))
	return ", ".join(pezzi)

# Le voci del punteggio, dalla piu' grossa, col segno.
func _voci(dett: Dictionary) -> String:
	var chiavi := dett.keys()
	chiavi.sort_custom(func(a, b): return absf(float(dett[a])) > absf(float(dett[b])))
	var pezzi: Array[String] = []
	for k in chiavi:
		pezzi.append("%s %+.1f" % [str(k), float(dett[k])])
	return " · ".join(pezzi) if not pezzi.is_empty() else "nessuna voce"

# Ogni mossa si porta dietro l'etichetta con cui l'interfaccia la offre al
# giocatore: e' gia' la sua descrizione, e riscriverla qui vorrebbe dire
# tenerne due allineate - cosa che infatti non si e' riusciti a fare, perche'
# i parametri non hanno tutti le stesse chiavi e il primo tentativo scoppiava
# sul primo potenziamento.
func _descrivi(v) -> String:
	var dove := ""
	if v.parametri.has("col_from"): dove = " in col %d" % int(v.parametri["col_from"])
	return "%s%s" % [str(v.etichetta), dove]

func _nome_terreno(t: int) -> String:
	return ["pianura", "fiume", "collina", "bosco"][t]

# ---- il racconto di un turno ---------------------------------------

func _racconta(gs: GameState, era: int, turno: int, chi: int) -> void:
	if chi < 0 or chi >= gs.players.size(): return
	var p: PlayerState = gs.players[chi]
	var vecchio: Dictionary = _prima_giocatori[chi]
	var pezzi: Array[String] = []

	var col := _colonna_nuova(p, vecchio)
	var sepolti_ora: Array[String] = []
	if col >= 0: pezzi.append("lavoratore in col %d" % col)

	for uid in gs.grid.buildings.map(func(b): return b.uid):
		var b := _per_uid(gs, uid)
		if not _prima_edifici.has(uid):
			if b.owner != chi: continue
			pezzi.append("COSTRUISCE %s (col %d-%d, liv %d%s)" % [
				b.data["name"], b.col_from, b.col_to - 1, b.level,
				", terrapieno x%d" % b.terrapieno_cols.size() if not b.terrapieno_cols.is_empty() else ""])
			continue
		var pre: Dictionary = _prima_edifici[uid]
		if b.upgrades.size() > int(pre["upg"]):
			pezzi.append("POTENZIA %s con %s" % [b.data["name"], _nome_upg(b.upgrades[b.upgrades.size() - 1])])
		if b.state != int(pre["state"]):
			var verso := "%s -> %s" % [_stato(int(pre["state"])), _stato(b.state)]
			if b.state == Enums.BuildingState.INTATTO and int(pre["state"]) == Enums.BuildingState.RUDERE:
				pezzi.append("RESTAURA %s%s" % [b.data["name"], " (rubato)" if b.owner != int(pre["owner"]) else ""])
			else:
				pezzi.append("%s: %s" % [b.data["name"], verso])
		if b.is_buried and not bool(pre["buried"]):
			pezzi.append("%s sepolto" % b.data["name"])
		# Il personaggio infilato sotto la carta a fine era: e' l'unica cosa
		# che un edificio continua a rendere anche da rovina, e nel racconto
		# non si vedeva.
		if str(b.buried_character) != str(pre.get("pers", "")) and b.buried_character != "":
			var nome := _nome_pers([b.buried_character])
			sepolti_ora.append(nome)
			pezzi.append("seppellisce %s sotto %s" % [nome, b.data["name"]])

	if p.recruited_total > int(vecchio["recl"]):
		# A fine era i personaggi si infilano sotto gli edifici e la mano si
		# svuota: se il turno ha chiuso l'era, il nome va cercato fra quelli
		# appena sepolti, se no il racconto diceva "RECLUTA ?".
		var chi_nome := _nome_pers(p.specialized_characters)
		if chi_nome == "?" and not sepolti_ora.is_empty():
			chi_nome = sepolti_ora[sepolti_ora.size() - 1]
		pezzi.append("RECLUTA %s" % chi_nome)
	if p.has_dynasty and not bool(vecchio["din"]):
		pezzi.append("compra la DINASTIA")
	if pezzi.size() == (1 if col >= 0 else 0):
		pezzi.append("passa")

	var dp := p.pietra - int(vecchio["pietra"])
	var do_ := p.oro - int(vecchio["oro"])
	var conto := ""
	if dp != 0 or do_ != 0: conto = "  [%+d pietra %+d oro]" % [dp, do_]
	var dv := _delta_vp(p, vecchio)
	if dv != "": conto += "  {%s}" % dv
	_dì("E%d t%02d · g%d · %s%s" % [era, turno, chi, " · ".join(pezzi), conto])
	# Il censimento e il conto finale scattano dentro il turno di qualcuno ma
	# pagano tutti: senza questo, i punti di fine partita degli altri due
	# sparivano dal racconto e il totale sembrava uscire dal nulla.
	for altro_p in gs.players:
		if altro_p.index == chi: continue
		var d2 := _delta_vp(altro_p, _prima_giocatori[altro_p.index])
		if d2 != "": _dì("            g%d {%s}" % [altro_p.index, d2])

func _log_nuovo(gs: GameState, letto: int) -> int:
	for i in range(letto, gs.log.size()):
		var riga := str(gs.log[i])
		if not _tutto and riga.contains("rifiutat"): continue
		_dì("        . %s" % riga)
	return gs.log.size()

# ---- la fotografia su cui si fa la differenza ----------------------

func _fotografa(gs: GameState) -> void:
	_prima_edifici = {}
	for b in gs.grid.buildings:
		_prima_edifici[b.uid] = {
			"state": b.state, "buried": b.is_buried, "upg": b.upgrades.size(),
			"owner": b.owner, "level": b.level, "pers": b.buried_character}
	_prima_giocatori = []
	for p in gs.players:
		_prima_giocatori.append({
			"pietra": p.pietra, "oro": p.oro, "vp": p.vp,
			"punti": p.vp_breakdown.duplicate(),
			"recl": p.recruited_total, "din": p.has_dynasty,
			"cols": p.worker_cols.duplicate()})

func _colonna_nuova(p: PlayerState, vecchio: Dictionary) -> int:
	var prima: Array = vecchio["cols"]
	for c in p.worker_cols:
		if not c in prima: return int(c)
	return -1

func _delta_vp(p: PlayerState, vecchio: Dictionary) -> String:
	var vecchi: Dictionary = vecchio["punti"]
	var fuori: Array[String] = []
	for canale in p.vp_breakdown:
		var d := int(p.vp_breakdown[canale]) - int(vecchi.get(canale, 0))
		if d != 0: fuori.append("%+d %s" % [d, canale])
	return ", ".join(fuori)

# ---- il conto finale ------------------------------------------------

func _tabella(gs: GameState) -> void:
	var colonne := Riepilogo.colonne(gs)
	var testa := "posto  chi   PV "
	for c in colonne: testa += "%9s" % str(c["nome"]).substr(0, 9)
	testa += "   edifici  eredita'"
	_dì(testa)
	for riga in Riepilogo.righe(gs):
		var s := "%4d   g%d  %4d " % [riga["posto"], riga["player"], riga["vp"]]
		for c in colonne: s += "%9d" % Riepilogo.punti(riga, str(c["id"]))
		var extra := Riepilogo.altro(gs, riga)
		s += "   %5d   %s%s" % [riga["edifici"], riga["eredita_nome"],
			"  (altro %+d)" % extra if extra != 0 else ""]
		_dì(s)

func _spoglia(gs: GameState) -> void:
	_dì("\n--- come e' finita la strada ---")
	for p in gs.players:
		var intatti := 0
		var ruderi := 0
		var rovine := 0
		var sepolti := 0
		var potenziamenti := 0
		for b in gs.grid.buildings:
			if b.owner != p.index: continue
			potenziamenti += b.upgrades.size()
			if b.is_buried: sepolti += 1
			elif b.state == Enums.BuildingState.INTATTO: intatti += 1
			elif b.state == Enums.BuildingState.RUDERE: ruderi += 1
			else: rovine += 1
		_dì("g%d · costruiti %d (intatti %d, ruderi %d, rovine %d, sepolti %d) · potenziamenti %d · personaggi %d · dinastia %s · resta %d pietra %d oro" % [
			p.index, p.buildings_built, intatti, ruderi, rovine, sepolti,
			potenziamenti, p.recruited_total, "si" if p.has_dynasty else "no",
			p.pietra, p.oro])

# ---- spiccioli ------------------------------------------------------

func _dì(s: String) -> void:
	if not _muto: print(s)

func _per_uid(gs: GameState, uid: int) -> Building:
	for b in gs.grid.buildings:
		if b.uid == uid: return b
	return null

func _stato(s: int) -> String:
	match s:
		Enums.BuildingState.INTATTO: return "intatto"
		Enums.BuildingState.RUDERE: return "rudere"
		_: return "rovina"

func _borsa(gs: GameState) -> String:
	var pezzi: Array[String] = []
	for p in gs.players:
		pezzi.append("g%d: %d pietra %d oro, %d PV" % [p.index, p.pietra, p.oro, p.vp])
	return " | ".join(pezzi)

func _terreni(gs: GameState) -> String:
	var pezzi: Array[String] = []
	for c in gs.grid.n_cols:
		pezzi.append(str(Enums.terrain_to_string(gs.grid.terrains[c]).substr(0, 3)))
	return " ".join(pezzi)

func _monumenti(gs: GameState) -> String:
	var pezzi: Array[String] = []
	for m in gs.monuments_open:
		pezzi.append("%s (%d PV)" % [CardDB.monuments[m]["name"], int(CardDB.monuments[m]["vp"])])
	return ", ".join(pezzi)

func _nome_eredita(id: String) -> String:
	if id == "" or not CardDB.legacies.has(id): return "-"
	return "%s (%d PV)" % [CardDB.legacies[id]["name"], int(CardDB.legacies[id]["vp"])]

func _nome_upg(id: String) -> String:
	return str(CardDB.upgrades[id]["name"]) if CardDB.upgrades.has(id) else id

func _nome_pers(lista: Array) -> String:
	if lista.is_empty(): return "?"
	var id := str(lista[lista.size() - 1])
	return str(CardDB.characters[id]["name"]) if CardDB.characters.has(id) else id

func _parse_args(a: PackedStringArray) -> Dictionary:
	var out := {}
	var i := 0
	while i < a.size():
		if a[i].begins_with("--"):
			if i + 1 < a.size() and not a[i + 1].begins_with("--"):
				out[a[i].substr(2)] = a[i + 1]
				i += 2
			else:
				out[a[i].substr(2)] = "1"
				i += 1
		else:
			i += 1
	return out
