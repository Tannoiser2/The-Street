# res://scripts/ai/headless_runner.gd
# Esegue partite complete senza grafica.
# Uso:  godot --headless --script res://scripts/ai/headless_runner.gd -- --games 100 --players 3 --seed 42
extends SceneTree

func _init() -> void:
	var args := _parse_args(OS.get_cmdline_user_args())
	var games := int(args.get("games", "10"))
	var players := int(args.get("players", "3"))
	var seed_base := int(args.get("seed", "1"))

	# CardDB è un Autoload; in modalità --script va istanziato a mano.
	var db = load("res://scripts/data/card_db.gd").new()
	db.name = "CardDB"
	root.add_child(db)
	db.load_db("res://data/cards.json")

	var wins := {}
	var total_vp := 0
	for g in games:
		var ctl := GameController.new()
		ctl.new_game(players, seed_base + g)
		var guard := 0
		while ctl.gs.phase != Enums.Phase.FINE_PARTITA and guard < 10000:
			RandomBot.play_turn(ctl)
			guard += 1
		var w := Scoring.winner(ctl.gs)
		wins[w] = wins.get(w, 0) + 1
		for p in ctl.gs.players: total_vp += p.vp
	print("Partite: %d · vittorie per posto: %s · PV medi: %.1f" % [games, wins, total_vp / float(games * players)])
	quit()

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
