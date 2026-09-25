# res://scripts/rules/scoring.gd
# Conteggio finale: sette voci, nell'ordine del regolamento.
# I punti Lampo, Cultura e i censimenti delle ere 1-4 sono già sul segnapunti.
class_name Scoring
extends RefCounted

static func final_scoring(gs: GameState) -> void:
	# I modificatori di Scavo (Targa storica, Soprintendente) vanno applicati
	# prima che _scavo conti: dopo sarebbe troppo tardi.
	Effects.apply_scavo_modifiers(gs)
	_census_final(gs)
	_verticality(gs)
	_continuity(gs)
	_scavo(gs)
	_skeletons(gs)
	Conditions.score_legacies(gs)     # voce 6: Eredita' segrete
	Effects.apply_final_scoring(gs)   # voce 7: effetti finali delle carte

static func _census_final(gs: GameState) -> void:
	EraRules.census(gs)

# PREMIO DI SCAVO (registro 89, manopola `premio_scavo`, "nessuno" nei dati):
# chi costruisce al livello L sopra un edificio con Scavo S lo incassa subito,
# al posto della Verticalita'. Tre moltiplicatori da misurare: "per_livello"
# S x L, "piu_livello" S + L, "per_livello_meno_uno" S x (L - 1). Uno
# spianato (S = 0) non paga mai: seppellire il proprio vivo resta a zero.
# La correzione all'ultima era (registro 91, manopola `premio_era5`): "intero"
# come nelle altre ere, "dimezzato" per difetto, "niente". Serve perche' con
# S x L meta' del premio arrivava nell'era 5 e una partita su cinque si
# decideva li'.
static func premio_scavo(scavo: int, livello: int, era: int = 1) -> int:
	if scavo <= 0: return 0
	var premio := 0
	match str(CardDB.constants.get("premio_scavo", "nessuno")):
		"per_livello": premio = scavo * livello
		"piu_livello": premio = scavo + livello
		"per_livello_meno_uno": premio = scavo * (livello - 1)
	if premio > 0 and era >= int(CardDB.constants["eras"]):
		match str(CardDB.constants.get("premio_era5", "intero")):
			"dimezzato": premio = premio / 2
			"niente": premio = 0
	return premio

# Metà del premio a chi ha la cima; metà divisa in proporzione agli edifici.
static func _verticality(gs: GameState) -> void:
	var vp_table = CardDB.constants["verticality_vp"]
	for col in gs.grid.n_cols:
		var h: int = gs.grid.height(col)
		if h < 1: continue
		var prize := int(vp_table[str(min(h, 4))])
		var owners := {}
		var total := 0
		for b in gs.grid.in_column(col):
			owners[b.owner] = owners.get(b.owner, 0) + 1
			total += 1
		var top := gs.grid.top_of(col)
		if top != null:
			gs.players[top.owner].add_vp("verticalita", prize / 2)
			top.rende("verticalita", prize / 2)
		for ow in owners:
			var share := int(round((prize / 2.0) * owners[ow] / float(total)))
			gs.players[ow].add_vp("verticalita", share)
			# La meta' divisa la si segna anche sulle carte, ma spezzando LA
			# QUOTA DEL GIOCATORE fra le sue carte col resto piu' grande, non
			# arrotondando ogni carta per conto suo. Arrotondando carta per
			# carta la somma non fa i punti del giocatore: con un premio da 14
			# diviso fra due edifici, ogni carta si segnava 4 (3,5 arrotondato
			# per eccesso) e le carte dicevano 8 dove il tabellone diceva 7.
			# L'errore cresceva con le colonne alte, ed e' saltato fuori
			# alzando `rovina_gap`: piu' edifici sopravvivono, piu' le colonne
			# salgono.
			var suoi: Array = gs.grid.in_column(col).filter(
				func(b): return b.owner == ow)
			_spezza(share, suoi, "verticalita")

# Spezza `punti` fra le carte, il piu' in parti uguali possibile: il resto va
# alle prime, una unita' a testa. Serve perche' la somma di quel che si segna
# sulle carte faccia ESATTAMENTE i punti che il giocatore ha incassato - un
# libro mastro che non torna non e' un libro mastro.
static func _spezza(punti: int, carte: Array, canale: String) -> void:
	if carte.is_empty() or punti == 0: return
	var base: int = punti / carte.size()
	var resto: int = punti % carte.size()
	for i in carte.size():
		var quota: int = base + (1 if i < resto else 0)
		if quota != 0: carte[i].rende(canale, quota)

static func _continuity(gs: GameState) -> void:
	var table = CardDB.constants["continuity_vp"]
	for col in gs.grid.n_cols:
		for p in gs.players:
			var count := {}
			for b in gs.grid.in_column(col):
				if b.owner != p.index: continue
				for c in b.classes(): count[c] = count.get(c, 0) + 1
			if count.is_empty(): continue
			var best: int = count.values().max()
			if best >= 3: p.add_vp("continuita", int(table["3"]))
			elif best >= 2: p.add_vp("continuita", int(table["2"]))

# Lo Scavo va al proprietario dell'edificio sotterrato. Il regolamento da'
# anche "+1 per ogni edificio altrui che avete sotterrato": ne' il motore ne'
# l'oracolo Python lo hanno mai contato, e le 80 000 partite del bilanciamento
# sono senza; sta in `disturbo_vp`, a 0 finche' il designer non decide
# (registro 88). Manopola `scavo_a_chi_scava` (registro 87): lo Scavo lo
# incassa chi ha completato la sepoltura, se l'edificio non era suo; il
# proprio sepolto da se' vale 0, come un terrapieno. I contatori
# `scavo_scavato` e `scavo_e5` servono all'audit ("l'ultimo che costruisce
# prende tutto il bottino?"): quanto si incassa scavando, e quanto nell'era 5.
static func _scavo(gs: GameState) -> void:
	var a_chi_scava := bool(CardDB.constants.get("scavo_a_chi_scava", false))
	var disturbo := int(CardDB.constants.get("disturbo_vp", 0))
	for b in gs.grid.buildings:
		if not b.is_buried: continue
		# `b` non ha tipo (viene da un Array): il tipo va scritto, se no non compila.
		var v: int = b.scavo_value()
		var altrui: bool = b.buried_by >= 0 and b.buried_by != b.owner
		if a_chi_scava:
			if altrui:
				var chi: PlayerState = gs.players[b.buried_by]
				chi.add_vp("scavo", v)
				chi.bump("scavo_scavato", v)
				if b.buried_era >= int(CardDB.constants["eras"]): chi.bump("scavo_e5", v)
				b.rende("scavo", v)
			elif b.buried_by < 0:
				# Sepolto senza uno scavatore (ricalcolo a fine era): al proprietario.
				gs.players[b.owner].add_vp("scavo", v)
				b.rende("scavo", v)
			continue
		gs.players[b.owner].add_vp("scavo", v)
		b.rende("scavo", v)
		if altrui and disturbo > 0:
			var chi2: PlayerState = gs.players[b.buried_by]
			chi2.add_vp("scavo", disturbo)
			chi2.bump("scavo_scavato", disturbo)
			if b.buried_era >= int(CardDB.constants["eras"]): chi2.bump("scavo_e5", disturbo)
			b.rende("scavo", disturbo)

# Personaggi sepolti (ere 1-4): valgono 6 - era se il loro edificio è sotterrato.
# `scheletro_conta` (registro 96): "sotterrato" e' la regola di sempre;
# "sempre" paga lo scheletro comunque finisca l'edificio (l'artista viene
# ricordato anche se la sua casa sta in piedi), una prova per dare piu' peso
# agli scheletri del potenziamento.
static func _skeletons(gs: GameState) -> void:
	var sempre := str(CardDB.constants.get("scheletro_conta", "sotterrato")) == "sempre"
	for b in gs.grid.buildings:
		if b.buried_character != "" and (b.is_buried or sempre):
			gs.players[b.owner].add_vp("scheletri", 6 - b.buried_character_era)
			b.rende("scheletri", 6 - b.buried_character_era)

# L'ordine di arrivo, dal primo all'ultimo. Prima si contava solo il
# vincitore, ma il riepilogo finale li vuole tutti in fila, e due modi di
# ordinare gli stessi giocatori avrebbero finito per non essere d'accordo.
# I pareggi si sciolgono come dice il regolamento - piu' edifici in piedi,
# poi piu' risorse - e a parita' piena passa avanti chi ha giocato prima,
# cosi' la classifica e' sempre la stessa e non dipende dall'ordinamento.
static func classifica(gs: GameState) -> Array[int]:
	var out: Array[int] = []
	for i in gs.players.size(): out.append(i)
	out.sort_custom(func(a: int, b: int) -> bool: return _precede(gs, a, b))
	return out

static func _precede(gs: GameState, a: int, b: int) -> bool:
	var pa: PlayerState = gs.players[a]
	var pb: PlayerState = gs.players[b]
	if pa.vp != pb.vp: return pa.vp > pb.vp
	var va := in_piedi(gs, a)
	var vb := in_piedi(gs, b)
	if va != vb: return va > vb
	if pa.total_resources() != pb.total_resources():
		return pa.total_resources() > pb.total_resources()
	return a < b

static func in_piedi(gs: GameState, player: int) -> int:
	var q := 0
	for b in gs.grid.buildings:
		if b.owner == player and b.is_alive(): q += 1
	return q

static func winner(gs: GameState) -> int:
	return classifica(gs)[0]
