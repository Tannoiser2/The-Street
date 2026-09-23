# res://scripts/tools/audit_partita.gd
# Rigioca un seme e racconta la partita turno per turno, poi la spoglia.
# Uso:  godot --headless res://scenes/audit_partita.tscn -- --seed 1609 --players 3 [--muto]
#
# Serve al designer: il riepilogo a fine partita dice DOVE sono andati i punti,
# ma non COME ci sono arrivati. Qui ogni turno si vede la mossa, quanto e'
# costata e cosa ha fruttato, cosi' un distacco grosso si puo' spiegare invece
# di indovinarlo.
#
# NB: si lancia come SCENA, non con --script (gli Autoload, CardDB, non
# esistono in modalita' --script).
extends Node

var _prima_edifici := {}
var _prima_giocatori := []
var _muto := false
# Il bot prova ogni mossa legale in ordine casuale, quindi il log si riempie di
# "Costruzione rifiutata": e' il suo modo di cercare, non un fatto della
# partita. Fuori per difetto, --tutto le rimette.
var _tutto := false

func _ready() -> void:
	var args := _parse_args(OS.get_cmdline_user_args())
	var seme := int(args.get("seed", "1"))
	var players := int(args.get("players", "3"))
	_muto = args.has("muto")
	_tutto = args.has("tutto")

	if args.has("games"):
		_lotto(seme, players, int(args["games"]))
		return

	var ctl := GameController.new()
	ctl.new_game(players, seme)
	var gs := ctl.gs
	_dì("=== Seme %d · %d giocatori · tutti bot ===" % [seme, players])
	_dì("Terreni: %s" % _terreni(gs))
	for p in gs.players:
		_dì("  giocatore %d · eredita' segreta: %s" % [p.index, _nome_eredita(p.legacy_id)])
	_dì("Monumenti aperti: %s" % _monumenti(gs))

	var era := 0
	var turno := 0
	var guard := 0
	_fotografa(gs)
	var log_letto := 0
	while gs.phase != Enums.Phase.FINE_PARTITA and guard < 10000:
		if gs.era != era:
			era = gs.era
			_dì("\n--- ERA %d · evento: %s · ordine %s ---" % [
				era, gs.current_event.get("name", "nessuno"), str(gs.turn_order)])
			_dì("    " + _borsa(gs))
		var chi := gs.current_index
		RandomBot.play_turn(ctl)
		turno += 1
		_racconta(gs, era, turno, chi)
		log_letto = _log_nuovo(gs, log_letto)
		_fotografa(gs)
		guard += 1

	_dì("\n=== FINE PARTITA (%d turni) ===" % turno)
	_tabella(gs)
	_spoglia(gs)
	get_tree().quit(0)

# Tante partite di fila, una riga CSV per giocatore: serve a sapere se un
# distacco visto in una partita sola e' la regola o il caso.
func _lotto(seme: int, players: int, quante: int) -> void:
	print("seme;posto;giocatore;pv;" + ";".join(Riepilogo.VOCI.map(func(v): return str(v["id"]))))
	for g in quante:
		var ctl := GameController.new()
		ctl.new_game(players, seme + g)
		var guard := 0
		while ctl.gs.phase != Enums.Phase.FINE_PARTITA and guard < 10000:
			RandomBot.play_turn(ctl)
			guard += 1
		for riga in Riepilogo.righe(ctl.gs):
			var campi: Array[String] = ["%d" % (seme + g), "%d" % riga["posto"],
				"%d" % riga["player"], "%d" % riga["vp"]]
			for v in Riepilogo.VOCI:
				campi.append("%d" % Riepilogo.punti(riga, str(v["id"])))
			print(";".join(campi))
	get_tree().quit(0)

# ---- il racconto di un turno ---------------------------------------

func _racconta(gs: GameState, era: int, turno: int, chi: int) -> void:
	if chi < 0 or chi >= gs.players.size(): return
	var p: PlayerState = gs.players[chi]
	var vecchio: Dictionary = _prima_giocatori[chi]
	var pezzi: Array[String] = []

	var col := _colonna_nuova(p, vecchio)
	if col >= 0: pezzi.append("lavoratore in col %d" % col)

	for uid in gs.grid.buildings.map(func(b): return b.uid):
		var b := _per_uid(gs, uid)
		if not _prima_edifici.has(uid):
			if b.owner != chi: continue
			pezzi.append("COSTRUISCE %s (col %d-%d, liv %d%s)" % [
				b.data["name"], b.col_from, b.col_to - 1, b.level,
				", terrapieno x%d" % b.terrapieno_cols.size() if not b.terrapieno_cols.is_empty() else ""])
			continue
		var pre: Dictionary = _prima_edifici[uid]
		if b.upgrades.size() > int(pre["upg"]):
			pezzi.append("POTENZIA %s con %s" % [b.data["name"], _nome_upg(b.upgrades[b.upgrades.size() - 1])])
		if b.state != int(pre["state"]):
			var verso := "%s -> %s" % [_stato(int(pre["state"])), _stato(b.state)]
			if b.state == Enums.BuildingState.INTATTO and int(pre["state"]) == Enums.BuildingState.RUDERE:
				pezzi.append("RESTAURA %s%s" % [b.data["name"], " (rubato)" if b.owner != int(pre["owner"]) else ""])
			else:
				pezzi.append("%s: %s" % [b.data["name"], verso])
		if b.is_buried and not bool(pre["buried"]):
			pezzi.append("%s sepolto" % b.data["name"])

	if p.recruited_total > int(vecchio["recl"]):
		pezzi.append("RECLUTA %s" % _nome_pers(p.specialized_characters))
	if p.has_dynasty and not bool(vecchio["din"]):
		pezzi.append("compra la DINASTIA")
	if pezzi.size() == (1 if col >= 0 else 0):
		pezzi.append("passa")

	var dp := p.pietra - int(vecchio["pietra"])
	var do_ := p.oro - int(vecchio["oro"])
	var conto := ""
	if dp != 0 or do_ != 0: conto = "  [%+d pietra %+d oro]" % [dp, do_]
	var dv := _delta_vp(p, vecchio)
	if dv != "": conto += "  {%s}" % dv
	_dì("E%d t%02d · g%d · %s%s" % [era, turno, chi, " · ".join(pezzi), conto])
	# Il censimento e il conto finale scattano dentro il turno di qualcuno ma
	# pagano tutti: senza questo, i punti di fine partita degli altri due
	# sparivano dal racconto e il totale sembrava uscire dal nulla.
	for altro_p in gs.players:
		if altro_p.index == chi: continue
		var d2 := _delta_vp(altro_p, _prima_giocatori[altro_p.index])
		if d2 != "": _dì("            g%d {%s}" % [altro_p.index, d2])

func _log_nuovo(gs: GameState, letto: int) -> int:
	for i in range(letto, gs.log.size()):
		var riga := str(gs.log[i])
		if not _tutto and riga.contains("rifiutat"): continue
		_dì("        . %s" % riga)
	return gs.log.size()

# ---- la fotografia su cui si fa la differenza ----------------------

func _fotografa(gs: GameState) -> void:
	_prima_edifici = {}
	for b in gs.grid.buildings:
		_prima_edifici[b.uid] = {
			"state": b.state, "buried": b.is_buried, "upg": b.upgrades.size(),
			"owner": b.owner, "level": b.level}
	_prima_giocatori = []
	for p in gs.players:
		_prima_giocatori.append({
			"pietra": p.pietra, "oro": p.oro, "vp": p.vp,
			"punti": p.vp_breakdown.duplicate(),
			"recl": p.recruited_total, "din": p.has_dynasty,
			"cols": p.worker_cols.duplicate()})

func _colonna_nuova(p: PlayerState, vecchio: Dictionary) -> int:
	var prima: Array = vecchio["cols"]
	for c in p.worker_cols:
		if not c in prima: return int(c)
	return -1

func _delta_vp(p: PlayerState, vecchio: Dictionary) -> String:
	var vecchi: Dictionary = vecchio["punti"]
	var fuori: Array[String] = []
	for canale in p.vp_breakdown:
		var d := int(p.vp_breakdown[canale]) - int(vecchi.get(canale, 0))
		if d != 0: fuori.append("%+d %s" % [d, canale])
	return ", ".join(fuori)

# ---- il conto finale ------------------------------------------------

func _tabella(gs: GameState) -> void:
	var colonne := Riepilogo.colonne(gs)
	var testa := "posto  chi   PV "
	for c in colonne: testa += "%9s" % str(c["nome"]).substr(0, 9)
	testa += "   edifici  eredita'"
	_dì(testa)
	for riga in Riepilogo.righe(gs):
		var s := "%4d   g%d  %4d " % [riga["posto"], riga["player"], riga["vp"]]
		for c in colonne: s += "%9d" % Riepilogo.punti(riga, str(c["id"]))
		var extra := Riepilogo.altro(gs, riga)
		s += "   %5d   %s%s" % [riga["edifici"], riga["eredita_nome"],
			"  (altro %+d)" % extra if extra != 0 else ""]
		_dì(s)

func _spoglia(gs: GameState) -> void:
	_dì("\n--- come e' finita la strada ---")
	for p in gs.players:
		var intatti := 0
		var ruderi := 0
		var rovine := 0
		var sepolti := 0
		var potenziamenti := 0
		for b in gs.grid.buildings:
			if b.owner != p.index: continue
			potenziamenti += b.upgrades.size()
			if b.is_buried: sepolti += 1
			elif b.state == Enums.BuildingState.INTATTO: intatti += 1
			elif b.state == Enums.BuildingState.RUDERE: ruderi += 1
			else: rovine += 1
		_dì("g%d · costruiti %d (intatti %d, ruderi %d, rovine %d, sepolti %d) · potenziamenti %d · personaggi %d · dinastia %s · resta %d pietra %d oro" % [
			p.index, p.buildings_built, intatti, ruderi, rovine, sepolti,
			potenziamenti, p.recruited_total, "si" if p.has_dynasty else "no",
			p.pietra, p.oro])

# ---- spiccioli ------------------------------------------------------

func _dì(s: String) -> void:
	if not _muto: print(s)

func _per_uid(gs: GameState, uid: int) -> Building:
	for b in gs.grid.buildings:
		if b.uid == uid: return b
	return null

func _stato(s: int) -> String:
	match s:
		Enums.BuildingState.INTATTO: return "intatto"
		Enums.BuildingState.RUDERE: return "rudere"
		_: return "rovina"

func _borsa(gs: GameState) -> String:
	var pezzi: Array[String] = []
	for p in gs.players:
		pezzi.append("g%d: %d pietra %d oro, %d PV" % [p.index, p.pietra, p.oro, p.vp])
	return " | ".join(pezzi)

func _terreni(gs: GameState) -> String:
	var pezzi: Array[String] = []
	for c in gs.grid.n_cols:
		pezzi.append(str(Enums.terrain_to_string(gs.grid.terrains[c]).substr(0, 3)))
	return " ".join(pezzi)

func _monumenti(gs: GameState) -> String:
	var pezzi: Array[String] = []
	for m in gs.monuments_open:
		pezzi.append("%s (%d PV)" % [CardDB.monuments[m]["name"], int(CardDB.monuments[m]["vp"])])
	return ", ".join(pezzi)

func _nome_eredita(id: String) -> String:
	if id == "" or not CardDB.legacies.has(id): return "-"
	return "%s (%d PV)" % [CardDB.legacies[id]["name"], int(CardDB.legacies[id]["vp"])]

func _nome_upg(id: String) -> String:
	return str(CardDB.upgrades[id]["name"]) if CardDB.upgrades.has(id) else id

func _nome_pers(lista: Array) -> String:
	if lista.is_empty(): return "?"
	var id := str(lista[lista.size() - 1])
	return str(CardDB.characters[id]["name"]) if CardDB.characters.has(id) else id

func _parse_args(a: PackedStringArray) -> Dictionary:
	var out := {}
	var i := 0
	while i < a.size():
		if a[i].begins_with("--"):
			if i + 1 < a.size() and not a[i + 1].begins_with("--"):
				out[a[i].substr(2)] = a[i + 1]
				i += 2
			else:
				out[a[i].substr(2)] = "1"
				i += 1
		else:
			i += 1
	return out
