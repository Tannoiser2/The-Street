# res://scripts/view/cronaca.gd
# LA CRONACA DEL TURNO (registro 146). Il designer: "non si capisce bene cosa
# succede, nella barra di stato ci deve essere scritto cosa sto facendo e cosa
# ho fatto, quali effetti degli edifici sono stati attivati e quante risorse
# ho guadagnato". Il registro di gioco dice gli eventi rari (crolli, effetti di
# carte), ma non la produzione: quella passa da `gain` senza una riga.
#
# Qui si fotografa lo stato prima di un turno e si racconta la differenza
# dopo: chi ha fatto cosa, quali edifici della colonna hanno prodotto e per
# chi, quanto ha guadagnato ciascuno, e le righe nuove del registro.
#
# PURO come Riepilogo: entra lo stato, escono righe di testo.
class_name Cronaca
extends RefCounted

static func fotografa(gs: GameState) -> Dictionary:
	var giocatori: Array = []
	for p in gs.players:
		giocatori.append({"pietra": p.pietra, "oro": p.oro, "idee": p.idee, "vp": p.vp,
			"cols": p.worker_cols.duplicate(), "din": p.has_dynasty,
			"pers": p.specialized_characters.duplicate()})
	var edifici := {}
	for b in gs.grid.buildings:
		edifici[b.uid] = {"upg": b.upgrades.size(), "stato": b.state}
	return {"giocatori": giocatori, "edifici": edifici, "log": gs.log.size(),
		"chi": gs.current_index, "era": gs.era}

static func nome(gs: GameState, i: int, io: int) -> String:
	return "tu" if i == io else "giocatore %d" % i

# Le righe del racconto, la prima e' l'azione. `io` e' il giocatore umano
# (per scrivere "tu"), -1 se nessuno.
static func racconta(gs: GameState, prima: Dictionary, io: int) -> Array[String]:
	var out: Array[String] = []
	var chi := int(prima["chi"])
	if chi < 0 or chi >= gs.players.size(): return out
	var p: PlayerState = gs.players[chi]
	var vecchio: Dictionary = (prima["giocatori"] as Array)[chi]
	var azioni := PackedStringArray()
	# La colonna attivata: il lavoratore nuovo.
	var col := -1
	for c in p.worker_cols:
		if not (int(c) in (vecchio["cols"] as Array)): col = int(c)
	if col >= 0:
		azioni.append("attiva la colonna %d (%s)" % [col + 1, _terreno(gs, col)])
	# Costruito, potenziato.
	for b in gs.grid.buildings:
		var era: Dictionary = (prima["edifici"] as Dictionary).get(b.uid, {})
		if era.is_empty() and b.owner == chi:
			azioni.append("costruisce %s" % str(b.data["name"]))
		elif not era.is_empty() and b.upgrades.size() > int(era["upg"]) and b.owner == chi:
			azioni.append("potenzia %s con %s" % [str(b.data["name"]),
				str(CardDB.upgrades.get(b.upgrades[b.upgrades.size() - 1], {}).get("name", "un potenziamento"))])
	if p.has_dynasty and not bool(vecchio["din"]): azioni.append("compra la Dinastia")
	for c in p.specialized_characters:
		if not (c in (vecchio["pers"] as Array)):
			azioni.append("prende %s" % str(CardDB.characters.get(c, {}).get("name", c)))
	if azioni.is_empty(): azioni.append("passa")
	if chi == io: out.append("Hai fatto: " + ", poi ".join(azioni))
	else: out.append("Giocatore %d: %s" % [chi, ", poi ".join(azioni)])
	if gs.era != int(prima["era"]): out.append("Finisce l'era %d, comincia l'era %d" % [int(prima["era"]), gs.era])
	# Gli edifici della colonna che hanno prodotto, con il loro proprietario.
	if col >= 0:
		var prod := PackedStringArray()
		for b in gs.grid.in_column(col):
			if not b.is_standing(): continue
			var pr: Dictionary = b.data.get("production", {})
			var pezzi := _risorse(int(pr.get("pietra", 0)), int(pr.get("oro", 0)),
				int(pr.get("idee", 0)), int(pr.get("cultura", 0)))
			if pezzi == "": continue
			prod.append("%s (%s) %s" % [str(b.data["name"]), nome(gs, b.owner, io), pezzi])
		if not prod.is_empty(): out.append("Edifici attivati: " + "; ".join(prod))
	# Quanto ha guadagnato ciascuno, chi ha agito per primo.
	var ordine: Array[int] = [chi]
	for i in gs.players.size():
		if i != chi: ordine.append(i)
	var conti := PackedStringArray()
	for i in ordine:
		var g: PlayerState = gs.players[i]
		var v: Dictionary = (prima["giocatori"] as Array)[i]
		var d := _risorse(g.pietra - int(v["pietra"]), g.oro - int(v["oro"]),
			g.idee - int(v["idee"]), g.vp - int(v["vp"]))
		if d != "": conti.append("%s %s" % [nome(gs, i, io), d])
	if not conti.is_empty(): out.append("Risorse: " + "; ".join(conti))
	# Il resto lo dice il registro: effetti di carte, crolli, eventi.
	for k in range(int(prima["log"]), gs.log.size()):
		out.append(str(gs.log[k]))
	return out

static func _terreno(gs: GameState, col: int) -> String:
	if col < 0 or col >= gs.grid.terrains.size(): return "?"
	var t = gs.grid.terrains[col]
	var nomi := {}
	for k in Enums.Terrain: nomi[Enums.Terrain[k]] = str(k).to_lower()
	return str(nomi.get(t, str(t)))

# "+2 Costruzione, -1 Denaro, +1 PV": solo le voci che cambiano.
static func _risorse(c: int, d: int, i: int, pv: int) -> String:
	var pezzi := PackedStringArray()
	if c != 0: pezzi.append("%+d Costruzione" % c)
	if d != 0: pezzi.append("%+d Denaro" % d)
	if i != 0: pezzi.append("%+d Idee" % i)
	if pv != 0: pezzi.append("%+d PV" % pv)
	return ", ".join(pezzi)
