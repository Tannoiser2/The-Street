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

# LE CARTE RESTITUITE (registro 131, `carte_restituite`). Il designer: non ci
# sono piu' carte edificio sulla mappa; quando un edificio va in rovina la sua
# tessera torna al proprietario (resta davanti a lui, "il suo museo") e sulla
# mappa restano solo le tessere scavo. Tre conseguenze:
# - le regole che guardano la MAPPA (colonne, terreni, livelli, cime) non
#   vedono piu' la rovina: "le rovine non contano";
# - le regole che contano le TUE rovine (classi, era, Scavo stampato) leggono
#   la carta restituita, quindi funzionano come prima;
# - gli effetti della carta crollata non scattano piu'.
static func carte_restituite() -> bool:
	return attive() and bool(CardDB.constants["tessere_scavo"].get("carte_restituite", false))

# La rovina la cui carta e' tornata al proprietario: fuori dalla mappa.
static func fuori(b: Building) -> bool:
	return carte_restituite() and b.state == Enums.BuildingState.ROVINA

# I POTENZIAMENTI COME TOKEN (registro 131): quando l'edificio va in rovina il
# proprietario riscatta i token che portava. L'effetto sull'edificio finisce
# (si tolgono i bonus che il token gli dava) e il token, tenuto davanti a se',
# vale a fine partita il suo costo in PV.
static func riscatta(gs: GameState, b: Building) -> void:
	if not carte_restituite() or b.upgrades.is_empty(): return
	var p: PlayerState = gs.players[b.owner]
	for uid in b.upgrades:
		if not CardDB.upgrades.has(uid): continue
		Effects.annulla_potenziamento(gs, b, CardDB.upgrades[uid])
		p.potenziamenti_riscattati.append(uid)
		gs.log_line("%s va in rovina: il giocatore %d riscatta %s" % [b.data["name"], b.owner, CardDB.upgrades[uid]["name"]])
	b.upgrades.clear()

static func costo(uid: String) -> int:
	var c: Dictionary = CardDB.upgrades[uid]["cost"]
	return int(c.get("pietra", 0)) + int(c.get("oro", 0)) + int(c.get("idee", 0))

# Le caselle che l'edificio occupava: una tessera ciascuna. Lo spianato non
# ne ha (il suo Scavo valeva gia' 0).
static func quante(b: Building) -> int:
	if b.state != Enums.BuildingState.ROVINA or b.was_razed: return 0
	return b.width() * b.profondita()

# Lo Scavo su cui si paga il premio di chi costruisce sopra. Di regola quello
# stampato; con `premio: "tessere"` la carta della rovina non c'e' piu' e si
# contano le tessere coperte sotto (una per casella), `per_tessera` PV l'una.
static func scavo_per_premio(b: Building) -> int:
	if attive() and str(CardDB.constants["tessere_scavo"].get("premio", "")) == "tessere":
		return quante(b) * int(CardDB.constants["tessere_scavo"].get("per_tessera", 1))
	return b.scavo_value()

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
		# I token riscattati: ognuno vale il suo costo.
		var riscatto := 0
		for uid in p.potenziamenti_riscattati:
			if CardDB.upgrades.has(uid): riscatto += costo(uid)
		if riscatto > 0:
			p.add_vp("scavo", riscatto)
			p.bump("riscattati_pv", riscatto)
