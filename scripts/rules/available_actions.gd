# res://scripts/rules/available_actions.gd
# Tutto cio' che il giocatore puo' fare adesso, col preventivo gia' fatto e il
# motivo del rifiuto in italiano quando l'azione non e' legale. PURA: non
# modifica nulla, e per questo si prova headless.
#
# Il brief chiede "un'anteprima del costo prima di confermare una costruzione".
# Questo modulo e' quell'anteprima, e la stessa lista servira' ai bot della M6:
# oggi il RandomBot tenta le azioni a caso per scoprire quali passano.
class_name AvailableActions
extends RefCounted

# Una voce: cosa si puo' fare, quanto costa, e - se non si puo' - perche'.
# `parametri` porta quel che serve al comando, cosi' l'interfaccia resta muta.
class Voce:
	var tipo: String = ""            # costruisci, potenzia, restaura, recluta, dinastia, passa
	var etichetta: String = ""
	var legale: bool = false
	var motivo: String = ""
	var pietra: int = 0
	var oro: int = 0
	var parametri: Dictionary = {}

	# Pagabile e' diverso da legale: l'azione puo' essere permessa e le
	# risorse mancare. Il giocatore deve vedere due cose diverse.
	func pagabile(p: PlayerState) -> bool:
		return p.pietra >= pietra and p.oro >= oro

static func _voce(tipo: String, etichetta: String, q, parametri := {}) -> Voce:
	var v := Voce.new()
	v.tipo = tipo
	v.etichetta = etichetta
	v.legale = q.legal
	v.motivo = q.reason
	v.pietra = q.pietra
	v.oro = q.oro
	v.parametri = parametri
	return v

# Le colonne da cui un edificio largo `w` puo' partire coprendo `col`.
# Il regolamento concede alla sola costruzione "la colonna attivata o una
# adiacente"; le altre azioni restano sulla colonna.
static func _partenze(gs: GameState, col: int, w: int) -> Array[int]:
	var out: Array[int] = []
	for c in range(maxi(0, col - w + 1), mini(gs.grid.n_cols - w, col + 1) + 1):
		if c <= col and c + w > col: out.append(c)
	return out

# Per ogni carta del mercato, la posizione piu' economica fra quelle legali.
# Se nessuna e' legale si riporta comunque un motivo, perche' "non puoi" senza
# spiegazione e' la cosa che rende un'interfaccia incomprensibile.
static func costruzioni(gs: GameState, player: int, col: int) -> Array[Voce]:
	var out: Array[Voce] = []
	for card_id in gs.market:
		var d: Dictionary = CardDB.buildings[card_id]
		var migliore = null
		var migliori_par := {}
		var ripiego = null
		for c in _partenze(gs, col, int(d["width"])):
			for sopra in [false, true]:
				var q = BuildRules.quote_above(gs, player, d, c) if sopra \
					else BuildRules.quote_rail(gs, player, d, c)
				if q.legal:
					if migliore == null or q.pietra + q.oro < migliore.pietra + migliore.oro:
						migliore = q
						migliori_par = {"card_id": card_id, "col_from": c, "above": sopra}
				elif ripiego == null:
					ripiego = q
		if migliore != null:
			out.append(_voce("costruisci", "Costruisci %s" % d["name"], migliore, migliori_par))
		elif ripiego != null:
			out.append(_voce("costruisci", "Costruisci %s" % d["name"], ripiego,
				{"card_id": card_id, "col_from": col, "above": false}))
	return out

static func potenziamenti(gs: GameState, player: int, col: int) -> Array[Voce]:
	var out: Array[Voce] = []
	for upg_id in gs.upg_row:
		var d: Dictionary = CardDB.upgrades[upg_id]
		var migliore = null
		var par := {}
		var ripiego = null
		for b in gs.grid.in_column(col):
			var q := ActionRules.quote_upgrade(gs, player, upg_id, b)
			if q.legal:
				if migliore == null or q.pietra + q.oro < migliore.pietra + migliore.oro:
					migliore = q
					par = {"upg_id": upg_id, "uid": b.uid}
			elif ripiego == null:
				ripiego = q
		if migliore != null:
			out.append(_voce("potenzia", "Potenzia con %s" % d["name"], migliore, par))
		elif ripiego != null:
			out.append(_voce("potenzia", "Potenzia con %s" % d["name"], ripiego, {"upg_id": upg_id}))
		else:
			var q2 := ActionRules.quote_upgrade(gs, player, upg_id, null)
			out.append(_voce("potenzia", "Potenzia con %s" % d["name"], q2, {"upg_id": upg_id}))
	return out

static func restauri(gs: GameState, player: int, col: int) -> Array[Voce]:
	var out: Array[Voce] = []
	for b in gs.grid.in_column(col):
		if b.state != Enums.BuildingState.RUDERE or b.is_buried: continue
		var q := ActionRules.quote_restore(gs, player, b)
		var chi := "" if b.owner == player else " (di G%d: diventa tuo)" % b.owner
		out.append(_voce("restaura", "Restaura %s%s" % [b.data["name"], chi], q, {"uid": b.uid}))
	return out

static func reclutamenti(gs: GameState, player: int, col: int) -> Array[Voce]:
	var out: Array[Voce] = []
	for cid in gs.char_row:
		var d: Dictionary = CardDB.characters[cid]
		# Le Impronte vogliono un edificio scelto: si offre il primo legale,
		# finche' l'interfaccia non fara' scegliere (domande-aperte punto 47).
		var bersaglio: Building = null
		if d.get("imprint", false):
			for b in gs.grid.in_column(col):
				if ActionRules.imprint_reason(gs, player, d, b) == "":
					bersaglio = b
					break
		var q := ActionRules.quote_recruit(gs, player, cid, col, bersaglio)
		var par := {"char_id": cid}
		if bersaglio != null: par["uid"] = bersaglio.uid
		out.append(_voce("recluta", "Recluta %s (%s)" % [d["name"], d["class"]], q, par))
	return out

static func dinastia(gs: GameState, player: int) -> Voce:
	return _voce("dinastia", "Acquista la Dinastia",
		ActionRules.quote_dynasty(gs, player), {})

# La lista completa, nell'ordine in cui il regolamento elenca le azioni.
static func tutte(gs: GameState, player: int, col: int) -> Array[Voce]:
	var out: Array[Voce] = []
	out.append_array(costruzioni(gs, player, col))
	out.append_array(potenziamenti(gs, player, col))
	out.append_array(restauri(gs, player, col))
	out.append_array(reclutamenti(gs, player, col))
	out.append(dinastia(gs, player))
	var passa := Voce.new()
	passa.tipo = "passa"
	passa.etichetta = "Passa (l'azione e' facoltativa)"
	passa.legale = true
	out.append(passa)
	return out

# Solo quelle che si possono fare davvero, legali E pagabili.
static func eseguibili(gs: GameState, player: int, col: int) -> Array[Voce]:
	var p: PlayerState = gs.players[player]
	var out: Array[Voce] = []
	for v in tutte(gs, player, col):
		if v.legale and v.pagabile(p): out.append(v)
	return out
