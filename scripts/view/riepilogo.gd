# res://scripts/view/riepilogo.gd
# Il conto finale, messo in tabella: una riga per giocatore, una colonna per
# ogni fonte di punti. Il motore i punti li divide gia' per canale mentre la
# partita va avanti (PlayerState.vp_breakdown); qui si leggono e basta, in
# ordine di regolamento e con i nomi per esteso.
#
# Serviva perche' a fine partita restava un numero solo - "vincitore: giocatore
# 3" - e non si capiva DOVE fossero andati i punti: se la verticalita' paga
# quanto lo scavo, se le eredita' segrete spostano davvero la classifica. Sono
# le domande che un designer si fa, e la risposta era gia' nello stato.
#
# PURO come BoardLayout3D e CameraOrbita: entra lo stato, esce una tabella.
# Nessun Node, nessun disegno, quindi i conti si provano headless.
class_name Riepilogo
extends RefCounted

# I canali nell'ordine in cui il regolamento elenca le voci. Il nome per
# esteso sta qui e non nel nucleo: `add_vp("verticalita", ...)` e' dato, non
# interfaccia.
const VOCI: Array[Dictionary] = [
	{"id": "lampo", "nome": "Lampo"},
	{"id": "cultura", "nome": "Cultura"},
	{"id": "rendita", "nome": "Rendita"},
	{"id": "monumenti", "nome": "Monumenti"},
	{"id": "verticalita", "nome": "Verticalità"},
	{"id": "continuita", "nome": "Continuità"},
	{"id": "scavo", "nome": "Scavo"},
	{"id": "scheletri", "nome": "Scheletri"},
	{"id": "eredita", "nome": "Eredità"},
	{"id": "effetti_finali", "nome": "Carte"},
]
# Le stesse voci con i nomi del regolamento v2 (registro 119), nell'ordine
# del suo "Fine partita": il Lampo e i PV prodotti si segnano subito, poi il
# Censimento (la Rendita), la Continuita', lo Scavo - che nella v2 tiene
# insieme il premio di scavo pagato sul momento a chi costruisce sopra e lo
# Scavo stampato di fine partita: stesso canale nel nucleo, quindi una
# colonna sola, col nome che lo dice - gli Scheletri, gli Obiettivi
# (Monumenti ed Eredita') e gli Effetti finali. La Verticalita' non c'e':
# nella v2 non esiste piu' e restava in tabella solo come nome vecchio.
# I nomi stanno in una colonna da 86 px a corpo 12: piu' lunghi si tagliano.
const VOCI_V2: Array[Dictionary] = [
	{"id": "lampo", "nome": "Lampo"},
	{"id": "cultura", "nome": "PV prodotti"},
	{"id": "rendita", "nome": "Censimento"},
	{"id": "continuita", "nome": "Continuità"},
	{"id": "scavo", "nome": "Scavo"},
	{"id": "scheletri", "nome": "Scheletri"},
	{"id": "monumenti", "nome": "Monumenti"},
	{"id": "eredita", "nome": "Eredità"},
	{"id": "effetti_finali", "nome": "Finali"},
]

# Le voci del regolamento in gioco: il file dei dati dice quale e'.
static func voci() -> Array[Dictionary]:
	return VOCI_V2 if str(CardDB.ruleset).begins_with("v2") else VOCI

# Le colonne da mostrare: le voci che hanno dato punti a qualcuno. Una colonna
# di zeri per tutti non dice niente e ruba spazio alle altre.
# In coda finiscono i canali che questa tabella non conosce: se un giorno il
# nucleo ne aggiunge uno, si vede lo stesso invece di sparire dal totale.
static func colonne(gs: GameState) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	var noti := {}
	for v in voci():
		noti[str(v["id"])] = true
		if _qualcuno_ha(gs, str(v["id"])): out.append(v)
	# Anche qui solo se ha dato punti: il nucleo segna un canale anche con
	# zero (`add_vp("verticalita", 0)` nella v2, dove la tabella vale 0), e
	# una colonna di trattini con un nome vecchio e' proprio quel che non
	# si vuole.
	for p in gs.players:
		for canale in p.vp_breakdown:
			var id := str(canale)
			if noti.has(id): continue
			noti[id] = true
			if _qualcuno_ha(gs, id):
				out.append({"id": id, "nome": id.capitalize()})
	return out

static func _qualcuno_ha(gs: GameState, id: String) -> bool:
	for p in gs.players:
		if int(p.vp_breakdown.get(id, 0)) != 0: return true
	return false

# Una riga per giocatore, in ordine di arrivo. La classifica la calcola
# Scoring, cosi' il primo della tabella e' lo stesso che il gioco chiama
# vincitore - due modi di ordinare avrebbero finito per litigare.
static func righe(gs: GameState) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	var ordine := Scoring.classifica(gs)
	for posto in ordine.size():
		var i: int = ordine[posto]
		var p: PlayerState = gs.players[i]
		out.append({
			"player": i,
			"posto": posto + 1,
			"vp": p.vp,
			"punti": p.vp_breakdown.duplicate(),
			"dettaglio": p.vp_dettaglio.duplicate(true),
			"dettaglio_fine": p.vp_dettaglio_fine.duplicate(true),
			"edifici": Scoring.in_piedi(gs, i),
			"eredita": p.legacy_id,
			"eredita_nome": _nome_eredita(p.legacy_id),
			"eredita_punti": int(p.vp_breakdown.get("eredita", 0)),
		})
	return out

static func punti(riga: Dictionary, id: String) -> int:
	return int((riga["punti"] as Dictionary).get(id, 0))

# DA DOVE VENGONO I PUNTI DI UNA VOCE (registro 144). Il designer: "puoi
# dividere i punteggi finali per capire da dove vengono? E Premi da dove
# arrivano?". Le sottovoci di un canale che hanno dato punti a qualcuno,
# dalla piu' ricca; vuote se il canale ha una fonte sola (non c'e' niente
# da dividere). La voce senza nome e' quel che il nucleo segna senza dire
# da dove: si chiama "altro".
static func sottovoci(righe_: Array[Dictionary], id: String) -> Array[String]:
	var somme := {}
	for r in righe_:
		var d: Dictionary = (r.get("dettaglio", {}) as Dictionary).get(id, {})
		for v in d:
			if int(d[v]) != 0: somme[v] = int(somme.get(v, 0)) + int(d[v])
	if somme.size() < 2: return []
	var out: Array[String] = []
	for v in somme: out.append(str(v))
	out.sort_custom(func(a, b): return int(somme[a]) > int(somme[b]))
	return out

static func punti_voce(riga: Dictionary, id: String, voce: String) -> int:
	var d: Dictionary = (riga.get("dettaglio", {}) as Dictionary).get(id, {})
	return int(d.get(voce, 0))

static func nome_voce(voce: String) -> String:
	return "altro" if voce == "" else voce

# ---- in gioco e a fine partita (registro 145) ----------------------------
# Il designer: "il resoconto finale divida tutti i modi per prendere i PV
# durante il gioco in alto, e tutti i PV presi a fine partita in basso". Il
# nucleo segna a parte i PV del conto finale (`vp_dettaglio_fine`); quelli
# in gioco sono il resto. La stessa voce puo' stare nelle due parti: lo
# Scavo e' il premio in gioco e la riscoperta alla fine, il Censimento
# quello delle ere 1-4 e quello finale.
const NOMI_GIOCO := {"scavo": "Bonus scavo", "rendita": "Censimenti delle ere"}
const NOMI_FINE := {"scavo": "Scavo (riscoperta)", "rendita": "Censimento finale"}

# {voce: punti} di un canale in una delle due parti.
static func dettaglio_fase(riga: Dictionary, id: String, fine: bool) -> Dictionary:
	var tutto: Dictionary = (riga.get("dettaglio", {}) as Dictionary).get(id, {})
	var alla_fine: Dictionary = (riga.get("dettaglio_fine", {}) as Dictionary).get(id, {})
	if fine: return alla_fine.duplicate()
	var out := {}
	for v in tutto:
		var n := int(tutto[v]) - int(alla_fine.get(v, 0))
		if n != 0: out[v] = n
	return out

static func punti_fase(riga: Dictionary, id: String, fine: bool) -> int:
	var d := dettaglio_fase(riga, id, fine)
	var n := 0
	for v in d: n += int(d[v])
	# Senza dettaglio (canale segnato prima che esistesse) e' tutto "in gioco".
	if d.is_empty() and not fine and not (riga.get("dettaglio", {}) as Dictionary).has(id):
		return punti(riga, id)
	return n

static func punti_voce_fase(riga: Dictionary, id: String, voce: String, fine: bool) -> int:
	return int(dettaglio_fase(riga, id, fine).get(voce, 0))

static func sottovoci_fase(righe_: Array[Dictionary], id: String, fine: bool) -> Array[String]:
	var somme := {}
	for r in righe_:
		var d := dettaglio_fase(r, id, fine)
		for v in d:
			if int(d[v]) != 0: somme[v] = int(somme.get(v, 0)) + int(d[v])
	if somme.size() < 2: return []
	var out: Array[String] = []
	for v in somme: out.append(str(v))
	out.sort_custom(func(a, b): return int(somme[a]) > int(somme[b]))
	return out

# Le voci di una parte: quelle che in quella parte hanno dato punti a qualcuno.
static func colonne_fase(gs: GameState, righe_: Array[Dictionary], fine: bool) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	for c in colonne(gs):
		var id := str(c["id"])
		var qualcuno := false
		for r in righe_:
			if punti_fase(r, id, fine) != 0: qualcuno = true
		if not qualcuno: continue
		var nomi: Dictionary = NOMI_FINE if fine else NOMI_GIOCO
		out.append({"id": id, "nome": str(nomi.get(id, c["nome"]))})
	return out

# La somma delle colonne mostrate. Se non torna col totale segnato, la
# differenza e' roba segnata prima che la tabella conoscesse il canale: si
# mostra come "altro" invece di sparire.
static func altro(gs: GameState, riga: Dictionary) -> int:
	var somma := 0
	for v in colonne(gs): somma += punti(riga, str(v["id"]))
	return int(riga["vp"]) - somma

static func _nome_eredita(id: String) -> String:
	if id == "" or not CardDB.legacies.has(id): return ""
	return str(CardDB.legacies[id]["name"])
