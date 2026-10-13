# res://scripts/tools/scatta_gioca.gd
# Fotografa la PARTITA VERA (scenes/gioca.tscn), non il tavolo ricostruito da
# scatta3d: stessa schermata, stesso caricamento dei dati, solo bot che
# giocano subito fino a `--turni` turni. Serve a vedere quello che vede chi
# gioca.  xvfb-run godot --write-movie f.png --quit-after 30 res://scenes/scatta_gioca.tscn -- --turni 60
extends Node

func _ready() -> void:
	var args := {}
	var argv := OS.get_cmdline_user_args()
	for i in argv.size():
		if argv[i].begins_with("--") and i + 1 < argv.size(): args[argv[i].substr(2)] = argv[i + 1]
	var g = load("res://scenes/gioca.tscn").instantiate()
	add_child(g)
	await get_tree().process_frame
	g.inizio.giocatori = int(args.get("giocatori", "3"))
	g.inizio.bot = g.inizio.giocatori - 1
	g.inizio.seme = int(args.get("seme", "7"))
	g.inizio.velocita = g.inizio.VELOCITA.size() - 1
	g.comincia()
	# L'umano e' il giocatore 0: lo fa muovere lo StrategyBot, poi i bot
	# rispondono, finche' si arriva al turno chiesto.
	var turni := int(args.get("turni", "60"))
	for t in turni:
		if g.ctl.gs.phase == Enums.Phase.FINE_PARTITA: break
		if not g.ctl.gs.pending_choice.is_empty():
			g.ctl.choose(int((g.ctl.gs.pending_choice["options"] as Array)[0]))
		else:
			g._racconta(func(): StrategyBot.play_turn(g.ctl, "bilanciata"))
		g._turni_dei_bot()
		# `--evento 1`: ci si ferma alla prima fine era, con la carta
		# dell'evento rivelata al centro (registro 210).
		if args.has("evento") and not g._rivelazione.is_empty(): break
	g._aggiorna()
	# `--scegli 1` (registro 218): si sceglie il primo Personaggio e la prima
	# carta comprabile, per fotografare i posti accesi coi loro preventivi.
	if args.has("scegli") and g._io() >= 0:
		var liberi: Array[String] = g.ctl.personaggi_liberi(g.ctl.gs.players[g._io()])
		if not liberi.is_empty(): g._personaggio_scelto = liberi[0]
		g._aggiorna()
		for id in g.ctl.gs.market:
			if g._comprabili.has(str(id)):
				g._seleziona({"kind": "mercato", "id": str(id)})
				break
		g._aggiorna()
		print("comprabili ", g._comprabili.keys(), " posti ", g._bersagli.size())
	print("era ", g.ctl.gs.era, " edifici ", g.ctl.gs.grid.buildings.size(), " carte restituite ", TessereScavo.carte_restituite(), " grandezza vera ", BoardLayout3D.grandezza_vera())
