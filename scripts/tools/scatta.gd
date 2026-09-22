# res://scripts/tools/scatta.gd
# Gioca una partita col RandomBot fino a un punto dato e disegna la plancia,
# cosi' l'interfaccia si puo' guardare invece di doverla immaginare.
# Uso:  godot --display-driver x11 --rendering-driver opengl3 \
#         --write-movie fuori.png --quit-after 3 res://scenes/scatta.tscn \
#         -- --players 3 --seed 7 --era 4
extends Node2D

var _view: Node2D

func _ready() -> void:
	var args := _args()
	var n := int(args.get("players", "3"))
	var seme := int(args.get("seed", "7"))
	var fino_a_era := int(args.get("era", "3"))

	var ctl := GameController.new()
	ctl.new_game(n, seme)
	while ctl.gs.era < fino_a_era and ctl.gs.phase != Enums.Phase.FINE_PARTITA:
		RandomBot.play_turn(ctl)
	# qualche turno dentro l'era richiesta, per avere una plancia viva
	var giri := int(args.get("turns", "6"))
	for i in giri:
		if ctl.gs.phase == Enums.Phase.FINE_PARTITA: break
		RandomBot.play_turn(ctl)

	_view = preload("res://scripts/view/board_view.gd").new()
	add_child(_view)
	_view.mostra(ctl.gs)
	print("plancia: era %d, %d edifici, %d colonne" % [
		ctl.gs.era, ctl.gs.grid.buildings.size(), ctl.gs.grid.n_cols])

func _args() -> Dictionary:
	var out := {}
	var argv := OS.get_cmdline_user_args()
	var i := 0
	while i < argv.size():
		var a: String = argv[i]
		if a.begins_with("--") and i + 1 < argv.size():
			out[a.substr(2)] = argv[i + 1]
			i += 2
		else:
			i += 1
	return out
