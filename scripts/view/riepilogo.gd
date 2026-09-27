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

# Le colonne da mostrare: le voci che hanno dato punti a qualcuno. Una colonna
# di zeri per tutti non dice niente e ruba spazio alle altre.
# In coda finiscono i canali che questa tabella non conosce: se un giorno il
# nucleo ne aggiunge uno, si vede lo stesso invece di sparire dal totale.
static func colonne(gs: GameState) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	var noti := {}
	for v in VOCI:
		noti[str(v["id"])] = true
		if _qualcuno_ha(gs, str(v["id"])): out.append(v)
	for p in gs.players:
		for canale in p.vp_breakdown:
			var id := str(canale)
			if noti.has(id): continue
			noti[id] = true
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
			"edifici": Scoring.in_piedi(gs, i),
			"eredita": p.legacy_id,
			"eredita_nome": _nome_eredita(p.legacy_id),
			"eredita_punti": int(p.vp_breakdown.get("eredita", 0)),
		})
	return out

static func punti(riga: Dictionary, id: String) -> int:
	return int((riga["punti"] as Dictionary).get(id, 0))

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
