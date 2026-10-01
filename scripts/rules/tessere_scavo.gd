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
# scoperte a fine partita valgono la meta'. Il premio di chi costruisce
# sopra conta le tessere sotto (`premio: "tessere"`, `per_tessera` PV l'una).
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
# (si tolgono i bonus che il token gli dava); i token ARTE, tenuti davanti a
# se', valgono il loro Scavo se un'icona arte scoperta li "ritrova"
# (registro 133). Gli altri non valgono niente.
static func riscatta(gs: GameState, b: Building) -> void:
	if not carte_restituite() or b.upgrades.is_empty(): return
	var p: PlayerState = gs.players[b.owner]
	for uid in b.upgrades:
		if not CardDB.upgrades.has(uid): continue
		Effects.annulla_potenziamento(gs, b, CardDB.upgrades[uid])
		p.potenziamenti_riscattati.append(uid)
		# Per l'audit: quanti token arte si riscattano, e di che era.
		if str(CardDB.upgrades[uid].get("family", "")) == "arte":
			p.bump("riscattati_arte")
			p.bump("riscattati_arte_e%d" % int(CardDB.upgrades[uid]["era"]))
		gs.log_line("%s va in rovina: il giocatore %d riscatta %s" % [b.data["name"], b.owner, CardDB.upgrades[uid]["name"]])
	b.upgrades.clear()

# Lo Scavo del Personaggio che il giocatore ha preso in quell'era (il migliore,
# se ne ha piu' d'uno); 0 se non ne ha.
static func scavo_personaggio_di_era(p: PlayerState, era: int) -> int:
	var meglio := 0
	for voce in p.personaggi_storia:
		if int(voce[1]) != era: continue
		var carta: Dictionary = CardDB.characters.get(str(voce[0]), {})
		meglio = maxi(meglio, int(carta.get("scavo", 6 - era)))
	return meglio

# Quante tessere restano nel mazzetto del giocatore: il mazzetto meno quelle
# gia' posate sulle sue rovine (la vista ne disegna la pila).
static func rimaste(gs: GameState, player: int) -> int:
	if not attive(): return 0
	var usate := 0
	for b in gs.grid.buildings:
		if b.owner == player: usate += quante(b)
	return maxi(0, (CardDB.constants["tessere_scavo"]["mazzo"] as Array).size() - usate)

static func costo(uid: String) -> int:
	var c: Dictionary = CardDB.upgrades[uid]["cost"]
	return int(c.get("pietra", 0)) + int(c.get("oro", 0)) + int(c.get("idee", 0))

# Le caselle che l'edificio occupava: una tessera ciascuna. Lo spianato non
# ne ha (il suo Scavo valeva gia' 0).
static func quante(b: Building) -> int:
	if b.state != Enums.BuildingState.ROVINA: return 0
	# LO SPIANATO (registro 134, da valutare): di regola la carta torna al
	# proprietario e non lascia tessere, come un terrapieno. Con
	# `spianato_lascia_tessere` lascia le tessere del proprietario come ogni
	# rovina (ma non paga il premio: chi spiana costruisce sopra il proprio).
	if b.was_razed and not (attive() and bool(CardDB.constants["tessere_scavo"].get("spianato_lascia_tessere", false))):
		return 0
	return b.width() * b.profondita()

# Lo Scavo su cui si paga il premio di chi costruisce sopra. Di regola quello
# stampato; con `premio: "tessere"` la carta della rovina non c'e' piu' e si
# contano le tessere coperte sotto (una per casella), `per_tessera` PV l'una.
static func scavo_per_premio(b: Building) -> int:
	if attive() and str(CardDB.constants["tessere_scavo"].get("premio", "")) == "tessere":
		if b.was_razed: return 0
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
				# Il Restauratore (registro 133) conta le proprie rovine scoperte.
				gs.players[b.owner].bump("rovine_scoperte")
				gs.log_line("Scavo dell'era moderna: %s riporta alla luce %s" % [costruito.data["name"], b.data["name"]])
			coda.append_array(b.basi)

# A fine partita: il proprietario incassa le sue tessere, per intero se
# scoperte, a meta' se ancora coperte; le icone valgono solo se scoperte.
static func conta(gs: GameState) -> void:
	for p in gs.players:
		# Lo scheletro vale lo Scavo stampato sul Personaggio (registro 133);
		# senza valore stampato, 6 meno l'era, per i Personaggi delle ere 1-4.
		var personaggi: Array = []
		for voce in p.personaggi_storia:
			var carta: Dictionary = CardDB.characters.get(str(voce[0]), {})
			if carta.has("scavo"): personaggi.append(int(carta["scavo"]))
			elif int(voce[1]) < int(CardDB.constants["eras"]): personaggi.append(6 - int(voce[1]))
		personaggi.sort()
		# L'arte ritrovata: con le carte restituite, lo Scavo stampato dei
		# token ARTE riscattati (registro 133); prima, il costo dei
		# potenziamenti che stavano sulle proprie rovine.
		var opere: Array = []
		if carte_restituite():
			for u in p.potenziamenti_riscattati:
				if CardDB.upgrades.has(u) and str(CardDB.upgrades[u].get("family", "")) == "arte":
					opere.append(int(CardDB.upgrades[u].get("scavo", 0)))
			# Registro 138: l'icona arte ritrova anche un token Arte ancora su
			# un tuo edificio in piedi, non solo quelli riscattati: l'arte
			# ritrovata valeva 0,3 PV a partita, troppo poco per un flusso.
			for b in gs.grid.buildings:
				if b.owner != p.index or fuori(b): continue
				for u in b.upgrades:
					if CardDB.upgrades.has(u) and str(CardDB.upgrades[u].get("family", "")) == "arte":
						opere.append(int(CardDB.upgrades[u].get("scavo", 0)))
		else:
			for b in gs.grid.buildings:
				if b.owner != p.index or b.state != Enums.BuildingState.ROVINA: continue
				for u in b.upgrades_storia: opere.append(costo(u))
		opere.sort()
		for b in gs.grid.buildings:
			if b.owner != p.index or quante(b) == 0: continue
			var somma := 0
			var extra := 0
			var ext_scheletri := 0
			for t in tessere(gs, b):
				somma += int(t.get("v", 0))
				if not b.scavata: continue
				var s = t.get("s", false)
				if typeof(s) == TYPE_BOOL:
					if s and not personaggi.is_empty(): extra += int(personaggi.pop_back())
				elif int(s) > 0:
					# Lo scheletro con l'era (registro 135): vale lo Scavo del
					# Personaggio preso in quell'era.
					var sc := scavo_personaggio_di_era(p, int(s))
					extra += sc
					ext_scheletri += sc
					p.bump("scavo_scheletri_era", sc)
				if bool(t.get("p", false)) and not opere.is_empty():
					var arte := int(opere.pop_back())
					extra += arte
					p.bump("scavo_arte", arte)
			var v: int = (somma if b.scavata else somma / 2) + b.bonus_scavo + extra
			if v <= 0: continue
			# Tre voci per il riepilogo, un canale solo: le tessere, gli
			# scheletri (lo Scavo dei Personaggi) e l'arte ritrovata.
			var ext_arte := extra - ext_scheletri
			p.add_vp("scavo", v - extra, "tessere scavo")
			if ext_scheletri > 0: p.add_vp("scavo", ext_scheletri, "scheletri ritrovati")
			if ext_arte > 0: p.add_vp("scavo", ext_arte, "arte ritrovata")
			b.rende("scavo", v)
			p.bump("scavo_tessere", v)
			if b.scavata: p.bump("scavo_scoperto", v)

