# res://scripts/ai/headless_runner.gd
# Esegue partite complete senza grafica.
# Uso:  godot --headless res://scenes/headless_runner.tscn -- --games 100 --players 3 --seed 42
#
# NB: si lancia come SCENA, non con --script. In modalità --script Godot non
# istanzia gli Autoload, quindi CardDB non esisterebbe né a compile time né a
# runtime e l'intero nucleo non compilerebbe.
extends Node

func _ready() -> void:
	var args := _parse_args(OS.get_cmdline_user_args())
	var games := int(args.get("games", "10"))
	var players := int(args.get("players", "3"))
	var seed_base := int(args.get("seed", "1"))

	var wins := {}
	var total_vp := 0
	var completed := 0
	var stalled := 0
	for g in games:
		var ctl := GameController.new()
		ctl.new_game(players, seed_base + g)
		var guard := 0
		while ctl.gs.phase != Enums.Phase.FINE_PARTITA and guard < 10000:
			RandomBot.play_turn(ctl)
			guard += 1
		if ctl.gs.phase == Enums.Phase.FINE_PARTITA:
			completed += 1
		else:
			stalled += 1
			push_error("Partita %d (seme %d) non conclusa: guard esaurito" % [g, seed_base + g])
		var w := Scoring.winner(ctl.gs)
		wins[w] = wins.get(w, 0) + 1
		for p in ctl.gs.players: total_vp += p.vp
	print("Partite: %d · completate: %d · bloccate: %d · vittorie per posto: %s · PV medi: %.1f" % [games, completed, stalled, wins, total_vp / float(games * players)])
	get_tree().quit(0 if stalled == 0 else 1)

func _parse_args(a: PackedStringArray) -> Dictionary:
	var out := {}
	var i := 0
	while i < a.size():
		if a[i].begins_with("--") and i + 1 < a.size():
			out[a[i].substr(2)] = a[i + 1]
			i += 2
		else:
			i += 1
	return out
