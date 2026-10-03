# res://scripts/rules/personaggi_v3.gd
# LA V3 (docs/proposte/v3-metro.md, v3-era-1.md): i Personaggi sono gli unici
# lavoratori e hanno produzione e azione; ogni edificio ha un'azione che scatta
# per il proprietario a ogni attivazione della colonna, di chiunque; le risorse
# nascono e muoiono nell'era. Tutto acceso dalla costante `turno_v3` del file
# dati (vera solo in data/proposte/cards-v3-*.json): con la v1.5 e la v2 non
# cambia niente.
#
# LE SCELTE DELLE AZIONI. Alcune azioni chiedono una scelta (quale risorsa
# cambiare, quale edificio proteggere). Qui le fa una regola fissa, la stessa
# per tutti i bot, scritta accanto a ogni azione: la misura dell'era di prova
# deve dipendere dalle carte, non da quanto e' furbo chi sceglie. Per le
# persone diventeranno domande (pending_choice), dopo.
class_name PersonaggiV3
extends RefCounted

static func attivo() -> bool:
	return bool(CardDB.constants.get("turno_v3", false))

static func risorse_muoiono() -> bool:
	return bool(CardDB.constants.get("risorse_muoiono", false))

# ---- il Personaggio piazzato -----------------------------------------
# Dopo la tessera della colonna e dopo gli edifici: la sua produzione e la
# sua azione, a chi lo ha piazzato.
static func attiva_personaggio(gs: GameState, player: int, col: int) -> void:
	if not attivo() or gs.personaggio_attivo == "": return
	if not CardDB.characters.has(gs.personaggio_attivo): return
	var d: Dictionary = CardDB.characters[gs.personaggio_attivo]
	var p: PlayerState = gs.players[player]
	var pr: Dictionary = d.get("produzione", {})
	var pp := int(pr.get("pietra", 0))
	var po := int(pr.get("oro", 0))
	var pi := int(pr.get("idee", 0))
	if pp + po + pi > 0:
		p.gain(pp, po, pi, "personaggi")
		gs.log_line("%s produce %s per giocatore %d" % [d["name"], _risorse(pp, po, pi), player])
	esegui_azione(gs, player, d.get("azione", {}), col, d, player, null)

# ---- le azioni degli edifici -------------------------------------------
# Ogni edificio vivo nella colonna, di chiunque: l'azione al proprietario
# (costante `azione_edificio` = "proprietario", l'unica letta per ora).
static func azioni_edifici(gs: GameState, attivatore: int, col: int) -> void:
	if not attivo(): return
	for b in gs.grid.alive_in_column(col):
		var az: Dictionary = b.data.get("azione", {})
		if az.is_empty(): continue
		esegui_azione(gs, b.owner, az, col, b.data, attivatore, b)

# `chi` riceve l'azione; `attivatore` ha attivato la colonna; `src` e'
# l'edificio che porta l'azione (null per il Personaggio).
static func esegui_azione(gs: GameState, chi: int, az: Dictionary, col: int, carta: Dictionary,
		attivatore: int, src: Building) -> void:
	var tipo := str(az.get("tipo", "nessuna"))
	if tipo == "nessuna": return
	var p: PlayerState = gs.players[chi]
	var se = az.get("se", null)
	if se is String:
		if se == "altrui" and attivatore == chi: return
		if se == "proprio" and attivatore != chi: return
	var n := int(az.get("n", 1))
	var nome := str(carta.get("name", "?"))
	# Solo per il rapporto: da dove vengono le risorse, dal Personaggio
	# piazzato (`in_azioni_*`) o dall'azione di un edificio in piedi
	# (`in_edifici_azione_*`, registro 166). Il gioco non lo legge.
	var fonte := "azioni" if src == null else "edifici_azione"
	match tipo:
		"risorsa":
			var pp := int(az.get("pietra", 0))
			var po := int(az.get("oro", 0))
			var pi := int(az.get("idee", 0))
			p.gain(pp, po, pi, fonte)
			gs.log_line("%s: %s a giocatore %d" % [nome, _risorse(pp, po, pi), chi])
		"cambio":
			_cambio(gs, p, az, nome)
		"pv":
			if not _condizione(gs, chi, az.get("se", null), col): return
			p.add_vp("cultura", n, "azioni")
			gs.log_line("%s: +%d PV a giocatore %d" % [nome, n, chi])
		"resistenza":
			_resistenza(gs, chi, az, col, src, nome)
		"sconto":
			# Vale per la costruzione (o il potenziamento Arte) di QUESTO turno:
			# ha senso solo per il Personaggio, che si piazza prima dell'azione.
			p.sconto_turno += n
			p.sconto_se = str(az.get("se", ""))
			gs.log_line("%s: sconto %d%s per questo turno a giocatore %d" % [nome, n,
				"" if p.sconto_se == "" else " (" + p.sconto_se + ")", chi])
		"acquisto":
			# L'acquisto extra (registro 157) serve a chi sta giocando il turno:
			# un edificio lo da' al proprietario solo quando e' lui ad attivare.
			if attivatore != chi: return
			p.extra_turno += n
			gs.log_line("%s: %d acquisto extra in questo turno a giocatore %d" % [nome, n, chi])
		"lampo":
			p.lampo_turno += n
			gs.log_line("%s: +%d Lampo all'edificio costruito in questo turno" % [nome, n])
		"scavo":
			_scavo(gs, chi, az, col, src, nome)
		"altri":
			var quanti := 0
			for ow in gs.grid.owners_alive_in(col):
				if int(ow) != chi: quanti += 1
			quanti = mini(quanti, int(az.get("max", 2)))
			var oro := quanti * int(az.get("oro", 1))
			if oro > 0:
				p.gain(0, oro, 0, fonte)
				gs.log_line("%s: +%d Denaro a giocatore %d per %d altri in colonna %d" % [nome, oro, chi, quanti, col])
		"adiacente":
			# La produzione della tessera di una colonna accanto: quella che
			# produce di piu' (prima la Costruzione, poi il Denaro, poi le Idee).
			var meglio := {}
			var tot := -1
			for c in [col - 1, col + 1]:
				if c < 0 or c >= gs.grid.n_cols or not TessereEra.attive(): continue
				var pr: Dictionary = TessereEra.produzione(gs, c)
				var t := int(pr.get("pietra", 0)) + int(pr.get("oro", 0)) + int(pr.get("idee", 0))
				if t > tot: tot = t; meglio = pr
			if tot > 0:
				p.gain(int(meglio.get("pietra", 0)), int(meglio.get("oro", 0)), int(meglio.get("idee", 0)), fonte)
				gs.log_line("%s: la produzione della tessera accanto a giocatore %d" % [nome, chi])
		"tessera":
			if col >= 0 and col < gs.tessere_usate.size() and gs.tessere_usate[col]:
				gs.tessere_usate[col] = false
				gs.log_line("%s: la tessera della colonna %d si rigira" % [nome, col])
		_:
			gs.log_line("%s: azione '%s' sconosciuta" % [nome, tipo])
			return
	p.bump("az3_" + tipo)

# ---- le scelte fisse ---------------------------------------------------
# Il cambio: con `da`/`a` fisso si cambia quello; se no si cede la risorsa
# che si ha di piu' per quella che si ha di meno. Non si cambia se non c'e'
# differenza (tutte uguali) o se non si ha niente.
static func _cambio(gs: GameState, p: PlayerState, az: Dictionary, nome: String) -> void:
	var n := int(az.get("n", 1))
	var fatti := 0
	for k in n:
		var da := str(az.get("da", ""))
		var a := str(az.get("a", ""))
		if da == "":
			var stock := {"pietra": p.pietra, "oro": p.oro, "idee": p.idee}
			da = "pietra"; a = "pietra"
			for r in ["pietra", "oro", "idee"]:
				if int(stock[r]) > int(stock[da]): da = r
				if int(stock[r]) < int(stock[a]): a = r
			if da == a or int(stock[da]) - int(stock[a]) < 2: break
		if _stock(p, da) < 1: break
		_muovi(p, da, -1)
		_muovi(p, a, 1)
		p._conta("out_cambio", 1 if da == "pietra" else 0, 1 if da == "oro" else 0, 1 if da == "idee" else 0)
		p._conta("in_cambio", 1 if a == "pietra" else 0, 1 if a == "oro" else 0, 1 if a == "idee" else 0)
		fatti += 1
		gs.log_line("%s: giocatore %d cambia 1 %s in 1 %s" % [nome, p.index, da, a])
	if fatti > 0: p.bump("cambi", fatti)

static func _stock(p: PlayerState, r: String) -> int:
	match r:
		"pietra": return p.pietra
		"oro": return p.oro
	return p.idee

static func _muovi(p: PlayerState, r: String, d: int) -> void:
	match r:
		"pietra": p.pietra += d
		"oro": p.oro += d
		_: p.idee += d

# "+1 PV se hai un Religione in piedi in questa colonna" (dove = colonna) o
# "se hai 2+ Religione in piedi" (dove = ovunque).
static func _condizione(gs: GameState, chi: int, se, col: int) -> bool:
	if se == null or not (se is Dictionary): return true
	var classe := str(se.get("classe", ""))
	var dove := str(se.get("dove", "colonna"))
	var minimo := int(se.get("min", 1))
	var quanti := 0
	for b in gs.grid.buildings:
		if b.owner != chi or not b.is_alive(): continue
		if dove == "colonna" and not b.covers(col): continue
		if classe != "" and not classe in (b.data["classes"] as Array): continue
		quanti += 1
	return quanti >= minimo

# La resistenza per l'era si somma a `protection`, che l'era azzera come il
# +2 del lavoratore. Bersagli: "uno" il proprio edificio in piedi nella colonna
# con la resistenza piu' bassa (a parita' la Rendita piu' alta: e' quello che
# si vuole salvare); "tutti" tutti i propri nella colonna (con `classe`, solo
# quelli); "abitato" l'edificio su cui sta il lavoratore, altrimenti "uno";
# "adiacente"/"adiacenti" i propri accanto all'edificio sorgente.
static func _resistenza(gs: GameState, chi: int, az: Dictionary, col: int, src: Building, nome: String) -> void:
	var n := int(az.get("n", 1))
	var a := str(az.get("a", "uno"))
	var classe := str(az.get("classe", ""))
	var candidati: Array = []
	if a == "adiacente" or a == "adiacenti":
		if src == null: return
		for b in gs.grid.buildings:
			if b.owner == chi and b.is_standing() and Effects._adjacent(src, b): candidati.append(b)
	else:
		for b in gs.grid.in_column(col):
			if b.owner == chi and b.is_standing(): candidati.append(b)
	if classe != "":
		candidati = candidati.filter(func(b): return classe in (b.data["classes"] as Array))
	if candidati.is_empty(): return
	var bersagli: Array = []
	if a == "tutti" or a == "adiacenti":
		bersagli = candidati
	else:
		var scelto: Building = null
		if a == "abitato" and gs.protetto_uid >= 0:
			for b in candidati:
				if b.uid == gs.protetto_uid: scelto = b
		if scelto == null:
			for b in candidati:
				if scelto == null or b.effective_resistance() < scelto.effective_resistance() \
						or (b.effective_resistance() == scelto.effective_resistance() and b.rendita_value() > scelto.rendita_value()):
					scelto = b
		bersagli = [scelto]
	for b in bersagli:
		b.protection += n
		gs.log_line("%s: +%d resistenza per l'era a %s" % [nome, n, b.data["name"]])

# Lo Scavo permanente va all'edificio proprio con lo Scavo piu' alto: e' quello
# che si vuole far trovare.
static func _scavo(gs: GameState, chi: int, az: Dictionary, col: int, src: Building, nome: String) -> void:
	var n := int(az.get("n", 1))
	var a := str(az.get("a", "uno"))
	var scelto: Building = null
	for b in gs.grid.buildings:
		if b.owner != chi or not b.is_standing(): continue
		if a == "adiacente":
			if src == null or not Effects._adjacent(src, b): continue
		elif not b.covers(col): continue
		if scelto == null or b.scavo_value() > scelto.scavo_value(): scelto = b
	if scelto == null: return
	scelto.bonus_scavo += n
	gs.log_line("%s: +%d Scavo permanente a %s" % [nome, n, scelto.data["name"]])

# ---- fine era: le risorse muoiono ----------------------------------------
# Al posto della dispersione: tutto a zero, contato (`out_morte_*` e
# `morte_e<era>_*`) perche' e' il primo numero che la misura guarda.
static func azzera(gs: GameState) -> void:
	for p in gs.players:
		p._conta("out_morte", p.pietra, p.oro, p.idee)
		p.bump("morte_e%d_pietra" % gs.era, p.pietra)
		p.bump("morte_e%d_oro" % gs.era, p.oro)
		p.bump("morte_e%d_idee" % gs.era, p.idee)
		if p.total_resources() > 0:
			gs.log_line("Fine dell'era: giocatore %d perde %s" % [p.index, _risorse(p.pietra, p.oro, p.idee)])
		p.pietra = 0
		p.oro = 0
		p.idee = 0

static func _risorse(pp: int, po: int, pi: int) -> String:
	var parti: Array[String] = []
	if pp > 0: parti.append("%d Costruzione" % pp)
	if po > 0: parti.append("%d Denaro" % po)
	if pi > 0: parti.append("%d Idee" % pi)
	return ", ".join(parti) if not parti.is_empty() else "niente"
