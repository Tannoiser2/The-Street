# res://scripts/tools/export_states.gd
# Esporta lo stato finale di N partite deterministiche piu' il punteggio
# calcolato da Godot, in JSON, per il confronto con l'oracolo Python.
# Uso:  godot --headless res://scenes/export_states.tscn -- --games 60 --players 3 --seed 1 --out /percorso/stati.json
extends Node

func _ready() -> void:
	var args := _parse_args(OS.get_cmdline_user_args())
	var games := int(args.get("games", "60"))
	var players := int(args.get("players", "3"))
	var seed_base := int(args.get("seed", "1"))
	var out_path: String = args.get("out", "user://stati.json")

	var payload := {"ruleset": CardDB.ruleset, "games": []}
	for g in games:
		var ctl := GameController.new()
		# vp_breakdown e' cumulativo (censimenti di tutte le ere). Per confrontarlo
		# con l'oracolo, che calcola il solo punteggio finale, serve il delta:
		# era_ended per l'era 5 scatta PRIMA di Scoring.final_scoring.
		var before := {}
		var cb := func(era: int):
			if era >= 5:
				for p in ctl.gs.players:
					before[p.index] = p.vp_breakdown.duplicate(true)
		ctl.era_ended.connect(cb)
		ctl.new_game(players, seed_base + g)
		var guard := 0
		while ctl.gs.phase != Enums.Phase.FINE_PARTITA and guard < 10000:
			RandomBot.play_turn(ctl)
			guard += 1
		# la lambda cattura ctl: senza disconnessione il ciclo di riferimenti
		# tiene vivo tutto fino all'uscita (ObjectDB instances were leaked).
		ctl.era_ended.disconnect(cb)
		payload["games"].append(_snapshot(ctl.gs, seed_base + g, players, before))

	var f := FileAccess.open(out_path, FileAccess.WRITE)
	if f == null:
		printerr("impossibile scrivere %s" % out_path)
		get_tree().quit(1)
		return
	f.store_string(JSON.stringify(payload))
	f.close()
	print("esportate %d partite a %d giocatori in %s" % [games, players, out_path])
	get_tree().quit(0)

# Lo stato viene esportato DOPO il punteggio finale: contiene sia la plancia
# sia il verdetto di Godot, cosi' l'oracolo puo' ricalcolare e confrontare.
func _snapshot(gs: GameState, seed_v: int, players: int, before: Dictionary) -> Dictionary:
	var bs := []
	for b in gs.grid.buildings:
		bs.append({
			"uid": b.uid,
			"owner": b.owner,
			"col_from": b.col_from,
			"col_to": b.col_to,
			"level": b.level,
			"state": ["intatto", "rudere", "rovina"][b.state],
			"buried": b.is_buried,
			"razed": b.was_razed,
			# classi EFFETTIVE: la continuita' che l'oracolo ricalcola deve
			# vedere anche quelle acquisite (po_merlatura).
			"classes": b.classes(),
			"rendita": int(b.data["rendita"]),
			"lampo": int(b.data["lampo"]),
			# Scavo effettivo, bonus da Impronte e potenziamenti inclusi, ma
			# SENZA l'azzeramento dello spianato: quello lo applica l'oracolo
			# per conto suo, cosi' il confronto resta sulla stessa regola.
			"scavo": int(b.data["scavo"]) + b.bonus_scavo,
			"vetusta": b.vetusta,
			"buried_character_era": b.buried_character_era if b.buried_character != "" else 0,
		})
	var scores := []
	for p in gs.players:
		var pre: Dictionary = before.get(p.index, {})
		var delta := {}
		for k in p.vp_breakdown:
			var d: int = int(p.vp_breakdown[k]) - int(pre.get(k, 0))
			if d != 0: delta[k] = d
		scores.append({
			"index": p.index,
			"vp": p.vp,
			"breakdown": p.vp_breakdown,
			"final_only": delta,      # il solo conteggio di fine partita
		})
	return {
		"seed": seed_v,
		"players": players,
		"n_cols": gs.grid.n_cols,
		"buildings": bs,
		"godot_scores": scores,
	}

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
