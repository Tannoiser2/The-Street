# res://scripts/rules/tessere_scavo.gd
# LE TESSERE SCAVO (registro 130). Idea del designer: quando un edificio va in
# rovina la sua carta esce dal tavolo e il proprietario pesca, dal suo
# mazzetto del suo colore, una tessera coperta per ogni casella che
# l'edificio occupava. Ogni tessera vale da 0 a 3; alcune portano uno
# scheletro (si aggiunge il valore scheletro di un proprio Personaggio delle
# ere passate) o un potenziamento (si aggiunge il valore di un potenziamento
# che stava sui propri edifici crollati: un'opera d'arte ritrovata).
# L'era moderna riporta alla luce la storia: le tessere sotto un edificio
# dell'era 5 si scoprono e valgono per intero al proprietario; quelle mai
# scoperte a fine partita valgono la meta'. Il premio di scavo di chi
# costruisce sopra resta quello di sempre (Scavo stampato x livello).
#
# Le tessere si pescano quando servono (a fine partita, o allo scavo
# dell'era 5), dal mazzetto del proprietario mescolato alla prima pesca:
# il risultato e' lo stesso che pescarle al crollo, e il resto del motore non
# deve sapere quando un edificio e' crollato.
class_name TessereScavo
extends RefCounted

static func attive() -> bool:
	return CardDB.constants.has("tessere_scavo")

# Le caselle che l'edificio occupava: una tessera ciascuna. Lo spianato non
# ne ha (il suo Scavo valeva gia' 0).
static func quante(b: Building) -> int:
	if b.state != Enums.BuildingState.ROVINA or b.was_razed: return 0
	return b.width() * b.profondita()

static func _mazzo(gs: GameState, player: int) -> Array:
	if not gs.mazzi_scavo.has(player):
		var m: Array = (CardDB.constants["tessere_scavo"]["mazzo"] as Array).duplicate(true)
		for i in range(m.size() - 1, 0, -1):
			var j := gs.rng.randi_range(0, i)
			var t = m[i]; m[i] = m[j]; m[j] = t
		gs.mazzi_scavo[player] = m
	return gs.mazzi_scavo[player]

# Le tessere di una rovina: si pescano la prima volta che servono. Se il
# mazzetto e' finito, le caselle restano senza tessera (valgono 0).
static func tessere(gs: GameState, b: Building) -> Array:
	var n := quante(b)
	if b.tessere.size() < n:
		var m := _mazzo(gs, b.owner)
		while b.tessere.size() < n and not m.is_empty():
			b.tessere.append(m.pop_back())
		while b.tessere.size() < n:
			b.tessere.append({"v": 0})
	return b.tessere

# Lo scavo dell'era moderna: chi costruisce nell'era 5 sopra delle rovine
# scopre le tessere di tutta la pila sotto di se'.
static func scava(gs: GameState, costruito: Building) -> void:
	if not attive() or costruito.level <= 0: return
	if int(costruito.data["era"]) < int(CardDB.constants["eras"]): return
	var coda: Array = costruito.basi.duplicate()
	var visti := {}
	while not coda.is_empty():
		var uid: int = coda.pop_back()
		if visti.has(uid): continue
		visti[uid] = true
		for b in gs.grid.buildings:
			if b.uid != uid: continue
			if quante(b) > 0 and not b.scavata:
				b.scavata = true
				tessere(gs, b)
				gs.log_line("Scavo dell'era moderna: %s riporta alla luce %s" % [costruito.data["name"], b.data["name"]])
			coda.append_array(b.basi)

# A fine partita: il proprietario incassa le sue tessere, per intero se
# scoperte, a meta' se ancora coperte; le icone valgono solo se scoperte.
static func conta(gs: GameState) -> void:
	for p in gs.players:
		var personaggi: Array = []
		for voce in p.personaggi_storia:
			if int(voce[1]) < int(CardDB.constants["eras"]): personaggi.append(6 - int(voce[1]))
		personaggi.sort()
		var opere: Array = []
		for b in gs.grid.buildings:
			if b.owner != p.index or b.state != Enums.BuildingState.ROVINA: continue
			for u in b.upgrades_storia:
				var c: Dictionary = CardDB.upgrades[u]["cost"]
				opere.append(int(c.get("pietra", 0)) + int(c.get("oro", 0)) + int(c.get("idee", 0)))
		opere.sort()
		for b in gs.grid.buildings:
			if b.owner != p.index or quante(b) == 0: continue
			var somma := 0
			var extra := 0
			for t in tessere(gs, b):
				somma += int(t.get("v", 0))
				if not b.scavata: continue
				if bool(t.get("s", false)) and not personaggi.is_empty(): extra += int(personaggi.pop_back())
				if bool(t.get("p", false)) and not opere.is_empty(): extra += int(opere.pop_back())
			var v: int = (somma if b.scavata else somma / 2) + b.bonus_scavo + extra
			if v <= 0: continue
			p.add_vp("scavo", v)
			b.rende("scavo", v)
			p.bump("scavo_tessere", v)
			if b.scavata: p.bump("scavo_scoperto", v)
