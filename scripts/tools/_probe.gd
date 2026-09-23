extends Node
func _ready() -> void:
	var buchi := 0
	var pile := 0
	var esempio := ""
	for g in 12:
		var ctl := GameController.new()
		ctl.new_game(3, 726 + g)
		var guard := 0
		while ctl.gs.phase != Enums.Phase.FINE_PARTITA and guard < 10000:
			StrategyBot.play_turn(ctl, StrategyBot.STRATEGIE[ctl.gs.current_index % 5])
			guard += 1
		var gs := ctl.gs
		for col in gs.grid.n_cols:
			var per_z := {}
			for b in gs.grid.buildings:
				if not b.covers(col): continue
				var r := BoardLayout3D.basetta_box(gs, b)
				var chiave := int(round(r.position.z / 5.0))
				if not per_z.has(chiave): per_z[chiave] = []
				per_z[chiave].append(b.level)
				for t in BoardLayout3D.terrapieni(gs, b):
					var centro := t.position.x + t.size.x / 2.0
					if centro < BoardLayout3D.col_x(col) or centro > BoardLayout3D.col_x(col + 1):
						continue
					var da := int(round((t.position.y - BoardLayout3D.TESSERA_Y) / BoardLayout3D.LEVEL_H))
					var a := int(round((t.end.y - BoardLayout3D.TESSERA_Y) / BoardLayout3D.LEVEL_H))
					for l in range(da, a): per_z[chiave].append(l)
			for k in per_z:
				var livelli: Array = per_z[k]
				livelli.sort()
				pile += 1
				for i in range(1, livelli.size()):
					if int(livelli[i]) - int(livelli[i - 1]) > 1:
						buchi += 1
						if esempio == "":
							esempio = "seme %d col %d: livelli %s" % [726 + g, col, str(livelli)]
	print("pile esaminate: %d · livelli saltati: %d" % [pile, buchi])
	if esempio != "": print("  " + esempio)
	get_tree().quit(0)
