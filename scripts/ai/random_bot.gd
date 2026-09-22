# res://scripts/ai/random_bot.gd
# Bot minimale per i test di fumo: sceglie mosse legali a caso.
# Le cinque strategie vere (Rendita, Lampo, Scavo, Verticale, Bilanciata) sono
# descritte in reference/ e vanno portate dopo che il nucleo è stabile.
class_name RandomBot
extends RefCounted

static func play_turn(ctl: GameController) -> void:
	var gs := ctl.gs
	var col := gs.rng.randi_range(0, gs.grid.n_cols - 1)
	ctl.place_worker(col)
	# prova a costruire qualcosa di legale nel mercato, altrimenti passa
	var tries := gs.market.duplicate()
	for card_id in tries:
		for c in range(max(0, col - 1), min(gs.grid.n_cols, col + 2)):
			for above in [false, true]:
				if ctl.gs.phase != Enums.Phase.AZIONE: return
				if ctl.build(card_id, c, above): return
	ctl.pass_action()


# ---------------------------------------------------------------
# res://scripts/ai/headless_runner.gd  (vedi file separato)
