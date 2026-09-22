# res://scripts/tools/scatta3d.gd
# Come scatta.gd, ma per la plancia 3D. Vedi tools/scatta3d.sh.
extends Node3D

func _ready() -> void:
	var args := _args()
	var ctl := GameController.new()
	ctl.new_game(int(args.get("players", "3")), int(args.get("seed", "7")))
	var fino := int(args.get("era", "3"))
	while ctl.gs.era < fino and ctl.gs.phase != Enums.Phase.FINE_PARTITA:
		RandomBot.play_turn(ctl)
	for i in int(args.get("turns", "6")):
		if ctl.gs.phase == Enums.Phase.FINE_PARTITA: break
		RandomBot.play_turn(ctl)
	var vista := preload("res://scripts/view/board_view_3d.gd").new()
	add_child(vista)
	vista.scale = Vector3.ONE * BoardLayout3D.U   # dai millimetri alle unita'
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
