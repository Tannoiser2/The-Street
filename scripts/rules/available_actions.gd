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
		# Dove il regolamento fa scegliere un edificio - l'Impronta che si
		# infila sotto una carta, l'"uno a tua scelta" dell'Ingegnere - si
		# offre UNA VOCE PER BERSAGLIO. Sceglierne uno al posto del giocatore
		# sarebbe decidere per lui: il totale tornerebbe, la partita no.
		var scelta: bool = bool(d.get("imprint", false)) or Effects.requires_designation(d)
		if not scelta:
			out.append(_voce("recluta", "Recluta %s (%s)" % [d["name"], d["class"]],
				ActionRules.quote_recruit(gs, player, cid, col), {"char_id": cid}))
			continue
		var candidati: Array[Building] = ActionRules.imprint_candidates(gs, player, d) \
			if bool(d.get("imprint", false)) else ActionRules.designation_candidates(gs, player, d)
		if candidati.is_empty():
			# nessun bersaglio: si riporta comunque il motivo
			out.append(_voce("recluta", "Recluta %s (%s)" % [d["name"], d["class"]],
				ActionRules.quote_recruit(gs, player, cid, col, null), {"char_id": cid}))
			continue
		for b in candidati:
			var q := ActionRules.quote_recruit(gs, player, cid, col, b)
			var verbo: String = "sotto" if bool(d.get("imprint", false)) else "designando"
			out.append(_voce("recluta",
				"Recluta %s (%s) %s %s" % [d["name"], d["class"], verbo, b.data["name"]],
				q, {"char_id": cid, "uid": b.uid}))
	return out

# ---- una voce per BERSAGLIO ------------------------------------------
# Le funzioni qui sopra riportano, per ogni carta, il solo piazzamento piu'
# economico: bastava a fare una lista, non basta a un'interfaccia che deve
# ACCENDERE SUL TABELLONE tutti i posti dove la carta puo' andare. Queste
# invece le enumerano tutte, cosi' chi gioca vede le sue opzioni sul tavolo
# invece di leggerle in un menu.
# Restano pure come le altre, quindi si provano headless.

# Ogni posizione in cui un edificio del mercato puo' essere costruito: una
# voce per colonna di partenza e per quota (a terra o sopra).
static func piazzamenti(gs: GameState, player: int, col: int,
		card_id: String) -> Array[Voce]:
	var out: Array[Voce] = []
	if not CardDB.buildings.has(card_id): return out
	var d: Dictionary = CardDB.buildings[card_id]
	for c in _partenze(gs, col, int(d["width"])):
		for sopra in [false, true]:
			var q = BuildRules.quote_above(gs, player, d, c) if sopra \
				else BuildRules.quote_rail(gs, player, d, c)
			if not q.legal: continue
			# Il livello viene dal preventivo: serve a disegnare il posto
			# acceso ALLA SUA QUOTA, cosi' "costruire sopra" e' un riquadro
			# che sta in alto invece di un tasto da tenere premuto.
			var dove := "sopra" if sopra else "a terra"
			var spianati := PackedStringArray()
			for r in q.razed: spianati.append(str(r.data["name"]))
			if sopra and not spianati.is_empty():
				dove = "spianando " + ", ".join(spianati)
			# Cosa si spiana e quanti terrapieni servono vengono dal preventivo e
			# viaggiano con la voce: sono la differenza fra due riquadri accesi
			# identici, e l'interfaccia deve poterla dire senza rifare per conto
			# suo i conti delle regole.
			out.append(_voce("costruisci", "Costruisci %s %s" % [d["name"], dove], q,
				{"card_id": card_id, "col_from": c, "above": sopra, "level": q.level,
				"spiana": spianati, "terrapieni": q.terrapieno_cols}))
	return out

# Gli edifici che possono ricevere un potenziamento: uno per bersaglio.
static func bersagli_potenziamento(gs: GameState, player: int, col: int,
		upg_id: String) -> Array[Voce]:
	var out: Array[Voce] = []
	if not CardDB.upgrades.has(upg_id): return out
	var d: Dictionary = CardDB.upgrades[upg_id]
	for b in gs.grid.in_column(col):
		var q := ActionRules.quote_upgrade(gs, player, upg_id, b)
		if not q.legal: continue
		out.append(_voce("potenzia", "Potenzia %s con %s" % [b.data["name"], d["name"]],
			q, {"upg_id": upg_id, "uid": b.uid}))
	return out

# Dove si puo' mettere un personaggio. Quelli senza scelta di bersaglio - la
# maggioranza - danno una voce sola senza uid: si reclutano e basta, e
# l'interfaccia non ha niente da accendere sul tabellone.
static func bersagli_reclutamento(gs: GameState, player: int, col: int,
		char_id: String) -> Array[Voce]:
	var out: Array[Voce] = []
	if not CardDB.characters.has(char_id): return out
	var d: Dictionary = CardDB.characters[char_id]
	var scelta: bool = bool(d.get("imprint", false)) or Effects.requires_designation(d)
	if not scelta:
		var q0 := ActionRules.quote_recruit(gs, player, char_id, col)
		if q0.legal:
			out.append(_voce("recluta", "Recluta %s (%s)" % [d["name"], d["class"]],
				q0, {"char_id": char_id}))
		return out
	var candidati: Array[Building] = ActionRules.imprint_candidates(gs, player, d) \
		if bool(d.get("imprint", false)) else ActionRules.designation_candidates(gs, player, d)
	for b in candidati:
		var q := ActionRules.quote_recruit(gs, player, char_id, col, b)
		if not q.legal: continue
		var verbo: String = "sotto" if bool(d.get("imprint", false)) else "designando"
		out.append(_voce("recluta",
			"Recluta %s (%s) %s %s" % [d["name"], d["class"], verbo, b.data["name"]],
			q, {"char_id": char_id, "uid": b.uid}))
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
