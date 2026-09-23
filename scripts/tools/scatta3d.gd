# res://scripts/tools/scatta3d.gd
# Come scatta.gd, ma per la plancia 3D. Vedi tools/scatta3d.sh.
extends Node3D

func _ready() -> void:
	var args := _args()
	var ctl := GameController.new()
	ctl.new_game(int(args.get("players", "3")), int(args.get("seed", "7")))
	var fino := int(args.get("era", "3"))
	# Gioca StrategyBot, come in partita: un tavolo costruito a caso non e' il
	# tavolo che si vede giocando, e gli scatti servono a guardare quello.
	while ctl.gs.era < fino and ctl.gs.phase != Enums.Phase.FINE_PARTITA:
		StrategyBot.play_turn(ctl, StrategyBot.STRATEGIE[ctl.gs.current_index % 5])
	for i in int(args.get("turns", "6")):
		if ctl.gs.phase == Enums.Phase.FINE_PARTITA: break
		StrategyBot.play_turn(ctl, StrategyBot.STRATEGIE[ctl.gs.current_index % 5])
	var vista := preload("res://scripts/view/board_view_3d.gd").new()
	add_child(vista)
	vista.scale = Vector3.ONE * BoardLayout3D.U   # dai millimetri alle unita'
	# La telecamera si puo' avvicinare e girare come fa il giocatore, cosi' un
	# difetto visto da vicino si puo' riguardare da qui invece che a occhio
	# sullo schermo di chi gioca.
	#   --zoom 0.35   la distanza in frazioni di quella di partenza
	#   --giro -20    gradi attorno all'asse verticale
	#   --alt 12      gradi sopra l'orizzonte
	#   --mira 3      la colonna da mettere al centro
	if args.has("zoom") or args.has("giro") or args.has("alt") or args.has("mira"):
		var o := CameraOrbita.da_stato(ctl.gs)
		o.distanza *= float(args.get("zoom", "1"))
		o.imbardata += float(args.get("giro", "0"))
		o.inclinazione = float(args.get("alt", str(o.inclinazione)))
		if args.has("mira"):
			var col := int(args["mira"])
			o.mira = Vector3(BoardLayout3D.col_x(col) + BoardLayout3D.TESSERA_W / 2.0,
				BoardLayout3D.TESSERA_Y * 4.0, BoardLayout3D.board_d() / 2.0)
		vista.orbita = o
	vista.mostra(ctl.gs)
	var quote := 0
	for b in ctl.gs.grid.buildings:
		if b.level > 0: quote += 1
	var terreni := []
	for c in ctl.gs.grid.n_cols:
		terreni.append(["pianura", "fiume", "collina", "bosco"][ctl.gs.grid.terrains[c]])
	print("terreni da colonna 0: ", ", ".join(terreni))
	print("plancia 3D: era %d, %d edifici (%d sopraelevati), %d colonne" % [
		ctl.gs.era, ctl.gs.grid.buildings.size(), quote, ctl.gs.grid.n_cols])

func _args() -> Dictionary:
	var out := {}
	var argv := OS.get_cmdline_user_args()
	var i := 0
	while i < argv.size():
		if argv[i].begins_with("--") and i + 1 < argv.size():
			out[argv[i].substr(2)] = argv[i + 1]
			i += 2
		else:
			i += 1
	return out
