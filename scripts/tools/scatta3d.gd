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
		StrategyBot.play_turn(ctl, StrategyBot.STRATEGIE[ctl.gs.current_index % StrategyBot.STRATEGIE.size()])
	for i in int(args.get("turns", "6")):
		if ctl.gs.phase == Enums.Phase.FINE_PARTITA: break
		StrategyBot.play_turn(ctl, StrategyBot.STRATEGIE[ctl.gs.current_index % StrategyBot.STRATEGIE.size()])
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
	# --crollo 0.4   abbatte una sagoma e ferma lo sgretolamento a quel punto
	#                della caduta (0 in piedi, 1 a terra), per guardarlo fermo
	#                in un PNG invece che a occhio mentre scorre.
	if args.has("crollo"):
		_sgretola(vista, ctl.gs, float(args["crollo"]))
	var quote := 0
	for b in ctl.gs.grid.buildings:
		if b.level > 0: quote += 1
	var terreni := []
	for c in ctl.gs.grid.n_cols:
		terreni.append(["pianura", "fiume", "collina", "bosco"][ctl.gs.grid.terrains[c]])
	print("terreni da colonna 0: ", ", ".join(terreni))
	# I Centri Urbani e se hanno gia' pagato in quest'era: il cartellino acceso
	# e quello spento si cercano qui, prima di guardare lo scatto.
	var centri := []
	for c in ctl.gs.grid.n_cols:
		if ctl.gs.grid.is_prosperity_center(c):
			centri.append("%d%s" % [c, " (pagato)" if BoardLayout3D.prosperita_pagata(ctl.gs, c) else ""])
	print("centri urbani: ", ", ".join(centri) if not centri.is_empty() else "nessuno")
	print("plancia 3D: era %d, %d edifici (%d sopraelevati), %d colonne" % [
		ctl.gs.era, ctl.gs.grid.buildings.size(), quote, ctl.gs.grid.n_cols])

# Sceglie la sagoma piu' in vista - la piu' alta, e fra quelle la piu' larga -
# la manda in rovina e porta l'animazione all'istante chiesto, poi la blocca:
# senza fermarla, i fotogrammi che Movie Maker scrive dopo la farebbero
# proseguire e lo scatto uscirebbe sempre a caduta finita.
func _sgretola(vista: Node3D, gs: GameState, quando: float) -> void:
	var vittima: Building = null
	for b in gs.grid.buildings:
		if not BoardLayout3D.ha_sagoma(b): continue
		if vittima == null or b.level > vittima.level \
			or (b.level == vittima.level and b.width() > vittima.width()):
			vittima = b
	if vittima == null:
		print("crollo: nessuna sagoma in piedi da abbattere")
		return
	vittima.state = Enums.BuildingState.ROVINA
	vista.mostra(gs)
	vista._process(clampf(quando, 0.0, 1.0) * BoardLayout3D.CROLLO_DURATA)
	vista.set_process(false)
	print("crollo: %s in colonna %d, fermato a %.2f" % [
		vittima.data["name"], vittima.col_from, quando])

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
