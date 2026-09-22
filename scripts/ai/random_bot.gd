# res://scripts/ai/random_bot.gd
# Bot minimale per i test di fumo: sceglie mosse legali a caso, provando tutte
# le azioni in ordine casuale. Non gioca bene, ma tocca ogni comando: serve a
# far emergere crash e stati illegali nelle partite headless.
# Le cinque strategie vere (Rendita, Lampo, Scavo, Verticale, Bilanciata) sono
# descritte in reference/ e vanno portate dopo che il nucleo e' stabile (M6).
class_name RandomBot
extends RefCounted

static func play_turn(ctl: GameController) -> void:
	var gs := ctl.gs
	var p := gs.current_player()
	var col := _free_column(gs, p)
	if col < 0 or not ctl.place_worker(col):
		ctl.pass_action()
		return

	var order := [0, 1, 2, 3, 4]
	_shuffle(gs, order)
	for a in order:
		if gs.phase != Enums.Phase.AZIONE: return
		match a:
			0: if _try_build(ctl, col): return
			1: if _try_upgrade(ctl, col): return
			2: if _try_restore(ctl, col): return
			3: if _try_recruit(ctl, col): return
			4: if ctl.buy_dynasty(): return
	ctl.pass_action()

# "al massimo un vostro lavoratore per colonna"
static func _free_column(gs: GameState, p: PlayerState) -> int:
	var cols := []
	for c in gs.grid.n_cols:
		if not c in p.worker_cols: cols.append(c)
	if cols.is_empty(): return -1
	return cols[gs.rng.randi_range(0, cols.size() - 1)]

static func _try_build(ctl: GameController, col: int) -> bool:
	var gs := ctl.gs
	for card_id in gs.market.duplicate():
		for c in range(max(0, col - 1), min(gs.grid.n_cols, col + 2)):
			# ogni tanto prova anche a depredare un rudere vicino
			var despoil: Building = _ruin_near(gs, c) if gs.rng.randi_range(0, 2) == 0 else null
			for above in [false, true]:
				if gs.phase != Enums.Phase.AZIONE: return true
				if ctl.build(card_id, c, above, 0, despoil): return true
				if despoil != null and ctl.build(card_id, c, above, 0, null): return true
	return false

static func _ruin_near(gs: GameState, col: int) -> Building:
	for c in range(max(0, col - 1), min(gs.grid.n_cols, col + 2)):
		for b in gs.grid.in_column(c):
			if not b.is_buried and b.state == Enums.BuildingState.RUDERE:
				return b
	return null

static func _try_upgrade(ctl: GameController, col: int) -> bool:
	var gs := ctl.gs
	var me := gs.current_index
	for upg_id in gs.upg_row.duplicate():
		for b in gs.grid.in_column(col):
			if b.owner == me and b.is_alive() and ctl.upgrade(upg_id, b): return true
	return false

static func _try_restore(ctl: GameController, col: int) -> bool:
	var gs := ctl.gs
	for b in gs.grid.in_column(col):
		if not b.is_buried and b.state == Enums.BuildingState.RUDERE and ctl.restore(b): return true
	return false

static func _try_recruit(ctl: GameController, col: int) -> bool:
	var gs := ctl.gs
	for char_id in gs.char_row.duplicate():
		if ctl.recruit(char_id): return true
	return false

static func _shuffle(gs: GameState, a: Array) -> void:
	for i in range(a.size() - 1, 0, -1):
		var j := gs.rng.randi_range(0, i)
		var tmp = a[i]; a[i] = a[j]; a[j] = tmp
