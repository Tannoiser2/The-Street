# res://scripts/ai/random_bot.gd
# Bot minimale per i test di fumo: sceglie mosse legali a caso, provando tutte
# le azioni in ordine casuale. Non gioca bene, ma tocca ogni comando: serve a
# far emergere crash e stati illegali nelle partite headless.
# Le strategie vere - Rendita, Lampo, Scavo, Verticale, Bilanciata, Obiettivi -
# stanno in StrategyBot; questo resta come metro di paragone (`--caso`).
class_name RandomBot
extends RefCounted

static func play_turn(ctl: GameController) -> void:
	var gs := ctl.gs
	# Il gioco puo' aspettare una scelta - dove infilare il potenziamento
	# dell'Eruzione - e finche' aspetta nessun comando passa. Il bot sceglie
	# a caso: e' una scelta vera, non una che il motore possa fare al posto
	# suo, quindi meglio casuale che "sempre la prima".
	while not gs.pending_choice.is_empty():
		var opzioni: Array = gs.pending_choice["options"]
		if opzioni.is_empty(): break
		if not ctl.choose(int(opzioni[gs.rng.randi_range(0, opzioni.size() - 1)])): break
	if gs.phase == Enums.Phase.FINE_PARTITA: return
	var p := gs.current_player()
	if bool(CardDB.constants.get("turno_v2", false)):
		_play_turn_v2(ctl, p)
		return
	var col := _free_column(gs, p)
	# "Mettetelo su una colonna, sopra un vostro edificio ancora in piedi
	# oppure sulla colonna nuda": abitare da' +2 resistenza, quindi conviene
	# quasi sempre. Senza questo, la protezione non entra mai in gioco.
	if col < 0 or not ctl.place_worker(col, _own_standing(gs, p, col)):
		ctl.pass_action()
		return

	# Il Mercante di ossidiana: il bot non ha una strategia, ma lo scambio
	# deve entrare in gioco, altrimenti resterebbe codice che non gira mai.
	# Politica minima e difendibile: converte la pietra in oro quando e' corto
	# d'oro e ne ha di pietra, perche' quasi ogni azione chiede oro mentre la
	# pietra la produce quasi ogni terreno. La soglia "meno di 2 oro e almeno
	# 3 pietra" e' scelta perche' scatta davvero: con "0 oro" non scatterebbe
	# mai, dato che reclutare il Mercante ne regala gia' 1.
	while p.oro < 2 and p.pietra >= 3 and ctl.exchange(true):
		pass

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

static func _own_standing(gs: GameState, p: PlayerState, col: int) -> Building:
	for b in gs.grid.in_column(col):
		if b.owner == p.index and b.is_standing(): return b
	return null

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
	# L'Artista di corte: firmare un edificio altrui e' gratis e rende per
	# tutta la partita, quindi il bot ci prova prima di rinunciare. Senza
	# questo tentativo la carta non entrerebbe mai in gioco nelle partite.
	for upg_id in gs.upg_row.duplicate():
		for b in gs.grid.in_column(col):
			if b.owner != me and b.is_alive() and ctl.upgrade(upg_id, b): return true
	return false

static func _try_restore(ctl: GameController, col: int) -> bool:
	var gs := ctl.gs
	for b in gs.grid.in_column(col):
		if not b.is_buried and b.state == Enums.BuildingState.RUDERE and ctl.restore(b): return true
	return false

static func _try_recruit(ctl: GameController, col: int) -> bool:
	var gs := ctl.gs
	var me := gs.current_index
	for char_id in gs.char_row.duplicate():
		# le Impronte vogliono un edificio bersaglio: si prova coi propri
		if CardDB.characters[char_id].get("imprint", false):
			for b in gs.grid.buildings:
				if b.owner == me and b.is_standing() and b.imprint == "":
					if ctl.recruit(char_id, b): return true
		elif ctl.recruit(char_id): return true
	return false

static func _shuffle(gs: GameState, a: Array) -> void:
	for i in range(a.size() - 1, 0, -1):
		var j := gs.rng.randi_range(0, i)
		var tmp = a[i]; a[i] = a[j]; a[j] = tmp

# ---- il turno v2 -----------------------------------------------------
# Una delle sette cose, a caso, finche' una passa: attivare una colonna,
# costruire ovunque, potenziare, ristrutturare, reclutare, la Dinastia; se
# niente passa, passare e incassare.
static func _play_turn_v2(ctl: GameController, p: PlayerState) -> void:
	var gs := ctl.gs
	var order := [0, 1, 2, 3, 4, 5]
	_shuffle(gs, order)
	for a in order:
		match a:
			0:
				var col := _free_column(gs, p)
				if col >= 0 and ctl.place_worker(col): return
			1:
				for card_id in gs.market.duplicate():
					for c in gs.grid.n_cols:
						for above in [false, true]:
							if ctl.build(card_id, c, above): return
			2:
				for upg_id in gs.upg_row.duplicate():
					for b in gs.grid.buildings.duplicate():
						if b.owner == p.index and ctl.upgrade(upg_id, b): return
			3:
				for b in gs.grid.buildings.duplicate():
					if b.owner == p.index and b.state == Enums.BuildingState.ROVINA \
							and not b.is_buried and ctl.restore(b): return
			4:
				for cid in gs.char_row.duplicate():
					if ctl.recruit(cid, null): return
					for b in gs.grid.buildings.duplicate():
						if b.owner == p.index and b.is_standing() and ctl.recruit(cid, b): return
			5:
				if ctl.buy_dynasty(): return
	ctl.passa(["pietra", "oro", "idee"][gs.rng.randi_range(0, 2)])

