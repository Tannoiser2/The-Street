# res://scripts/rules/tessere_era.gd
# LE TESSERE DELL'ERA (v2, registro 121, docs/proposte/tessere-v2.md).
#
# Il terreno non ha piu' la sua curva di produzione ne' la sua regola: ha una
# produzione di BASE fissa (Pianura 1 Costruzione, Fiume 1 Denaro, Collina 1
# Costruzione, Bosco 1 Idea). A inizio era si mescolano le 14 tessere
# dell'era (7 diverse, in due copie) e se ne posa una su ogni colonna: aggiunge
# la sua produzione e un effetto che scatta UNA VOLTA PER ERA, alla prima
# occasione, poi la tessera si gira (lo stesso segnale di prima,
# `gs.tessere_usate`, che la vista e i bot gia' conoscono).
#
# Accese dalla costante `tessere_era` (vera nel file v2). Spente, niente di
# questo file tocca la partita, e la v1.5 resta identica al riferimento.
#
# LE SCELTE. Alcune tessere dicono "puo' cambiare" o "a scelta". Qui la scelta
# e' automatica e prudente, uguale per bot e persone: si cambia solo se la
# risorsa d'arrivo manca piu' di quella di partenza, si prende la risorsa di
# cui se ne ha meno, la colonna adiacente che produce di piu'. Basta per
# misurare; a schermo potra' diventare una domanda.
class_name TessereEra
extends RefCounted

const RISORSE := ["pietra", "oro", "idee"]

static func attive() -> bool:
	return bool(CardDB.constants.get("tessere_era", false))

# ---- il mazzo ---------------------------------------------------------
# Una tessera per colonna, pescata dalle copie dell'era mescolate. A quattro
# giocatori (9 colonne) 14 bastano; il mazzo si rimescola se mai finisse.
static func distribuisci(gs: GameState) -> void:
	gs.tessere_colonna.clear()
	if not attive(): return
	var mazzo: Array = []
	for id in CardDB.tessere_era:
		var t: Dictionary = CardDB.tessere_era[id]
		if int(t["era"]) != gs.era: continue
		for k in int(t.get("copie", 1)): mazzo.append(str(id))
	mazzo.sort()                      # l'ordine del dizionario non e' un dato
	_mescola(gs, mazzo)
	for c in gs.grid.n_cols:
		gs.tessere_colonna.append(str(mazzo[c % mazzo.size()]) if not mazzo.is_empty() else "")
	for c in gs.grid.n_cols:
		if gs.tessere_colonna[c] != "":
			gs.log_line("Colonna %d: %s" % [c, CardDB.tessere_era[gs.tessere_colonna[c]]["name"]])

static func _mescola(gs: GameState, a: Array) -> void:
	for i in range(a.size() - 1, 0, -1):
		var j := gs.rng.randi_range(0, i)
		var tmp = a[i]; a[i] = a[j]; a[j] = tmp

static func tessera(gs: GameState, col: int) -> Dictionary:
	if col < 0 or col >= gs.tessere_colonna.size(): return {}
	var id := gs.tessere_colonna[col]
	return CardDB.tessere_era.get(id, {})

# L'effetto della tessera, se e' dell'innesco chiesto e non si e' ancora girata.
static func effetto(gs: GameState, col: int, quando: String) -> Dictionary:
	if not attive(): return {}
	var t := tessera(gs, col)
	if t.is_empty(): return {}
	var e: Dictionary = t["effetto"]
	if str(e["quando"]) != quando: return {}
	if not EraRules.tessera_disponibile(gs, col): return {}
	return e

static func gira(gs: GameState, col: int, cosa: String) -> void:
	var id := gs.tessere_colonna[col]
	gs.tessere_scattate[id] = int(gs.tessere_scattate.get(id, 0)) + 1
	EraRules.usa_tessera(gs, col, "%s: %s" % [CardDB.tessere_era[id]["name"], cosa])

# ---- la produzione ----------------------------------------------------
# Base del terreno piu' la tessera dell'era.
static func produzione(gs: GameState, col: int) -> Dictionary:
	var t_id: String = ["pianura", "fiume", "collina", "bosco"][gs.grid.terrains[col]]
	var base: Dictionary = CardDB.terrains[t_id].get("produzione_base", {})
	var out := {}
	var tess := tessera(gs, col)
	var extra: Dictionary = tess.get("produzione", {})
	for r in RISORSE: out[r] = int(base.get(r, 0)) + int(extra.get(r, 0))
	return out

static func _somma(p: Dictionary) -> int:
	return int(p["pietra"]) + int(p["oro"]) + int(p["idee"])

# ---- all'attivazione ----------------------------------------------------
static func all_attivazione(gs: GameState, player: int, col: int) -> void:
	var e := effetto(gs, col, "attiva")
	if e.is_empty(): return
	var p: PlayerState = gs.players[player]
	var se: Dictionary = e.get("se", {})
	if bool(se.get("ultimo_in_punti", false)):
		for altro in gs.players:
			if altro.index != player and altro.vp < p.vp:
				return                        # non e' l'ultimo: la tessera aspetta
	var g := {"pietra": 0, "oro": 0, "idee": 0}
	var cosa := ""
	if e.has("guadagno"):
		for r in e["guadagno"]: g[r] += int(e["guadagno"][r])
	if e.has("cambio"):
		var da := str(e["cambio"][0]); var a := str(e["cambio"][1])
		# Si cambia solo se conviene: la risorsa d'arrivo manca piu' di quella
		# di partenza. Se no la tessera non scatta e aspetta un'altra occasione.
		if _quanto(p, da) < 1 or _quanto(p, a) >= _quanto(p, da): return
		g[da] -= 1; g[a] += 1
	if bool(e.get("produzione_adiacente", false)):
		var meglio := {}
		for c in [col - 1, col + 1]:
			if c < 0 or c >= gs.grid.n_cols: continue
			var pr := produzione(gs, c)
			if meglio.is_empty() or _somma(pr) > _somma(meglio): meglio = pr
		for r in RISORSE: g[r] += int(meglio.get(r, 0))
	if e.has("per_altrui_intatti"):
		var chi := {}
		for b in gs.grid.alive_in_column(col):
			if b.owner != player and b.state == Enums.BuildingState.INTATTO: chi[b.owner] = true
		g[str(e["per_altrui_intatti"])] += chi.size()
	if e.has("per_classe_intatti"):
		var pc: Dictionary = e["per_classe_intatti"]
		var n := 0
		for b in gs.grid.alive_in_column(col):
			if b.state != Enums.BuildingState.INTATTO: continue
			for cl in b.classes():
				if cl in pc["classi"]: n += 1; break
		g[str(pc["risorsa"])] += n
	if e.has("a_scelta"):
		var poca := "pietra"
		for r in RISORSE:
			if _quanto(p, r) < _quanto(p, poca): poca = r
		g[poca] += int(e["a_scelta"])
	# Una tessera che darebbe zero (Fiera senza vicini, Scuola dei mastri
	# senza Ingegneria, Via consolare fra colonne vuote) non si spreca:
	# aspetta un'occasione vera, come dice "alla prima occasione".
	if g["pietra"] == 0 and g["oro"] == 0 and g["idee"] == 0: return
	# Si paga cio' che si cede prima di prendere, perche' `gain` non accetta
	# negativi e il tetto per risorsa vale solo a fine era.
	p.pay(maxi(0, -g["pietra"]), maxi(0, -g["oro"]), maxi(0, -g["idee"]))
	p.gain(maxi(0, g["pietra"]), maxi(0, g["oro"]), maxi(0, g["idee"]))
	cosa = "%+d C %+d D %+d I a giocatore %d" % [g["pietra"], g["oro"], g["idee"], player]
	gira(gs, col, cosa)

static func _quanto(p: PlayerState, r: String) -> int:
	match r:
		"pietra": return p.pietra
		"oro": return p.oro
	return p.idee

# ---- alla costruzione -----------------------------------------------------
# Le tessere che scattano per un edificio costruito su queste colonne: la
# prima occasione di ciascuna colonna coperta. `b` e' l'edificio gia' posato
# (per le condizioni che guardano la strada dopo), null nel preventivo.
static func _in_costruzione(gs: GameState, player: int, data: Dictionary, col_from: int,
		level: int, bases: Array, b: Building = null) -> Array:
	var out := []
	if not attive(): return out
	var col_to := col_from + int(data["width"])
	for c in range(col_from, col_to):
		var e := effetto(gs, c, "costruisci")
		if e.is_empty(): continue
		if not _condizioni(gs, player, data, level, bases, b, e.get("se", {})): continue
		out.append([c, e])
	return out

static func _condizioni(gs: GameState, player: int, data: Dictionary, level: int,
		bases: Array, b: Building, se: Dictionary) -> bool:
	if int(data["width"]) < int(se.get("larghezza_min", 0)): return false
	if se.has("classi"):
		var ok := false
		for cl in data["classes"]:
			if cl in se["classi"]: ok = true
		if not ok: return false
	if bool(se.get("sopra", false)) and level < 1: return false
	if level < int(se.get("livello_min", 0)): return false
	if bool(se.get("su_rovina_altrui", false)):
		var ok2 := false
		for base in bases:
			if base.owner != player and base.state != Enums.BuildingState.INTATTO: ok2 = true
		if not ok2: return false
	if bool(se.get("il_piu_alto", false)):
		if b == null: return false        # si sa solo a edificio posato
		for altro in gs.grid.buildings:
			if altro != b and altro.is_standing() and altro.level >= b.level: return false
	return true

# Lo sconto sul preventivo: la somma delle tessere che scatterebbero.
static func sconto_costruzione(gs: GameState, player: int, data: Dictionary, col_from: int,
		level: int, bases: Array) -> Dictionary:
	var s := {"pietra": 0, "oro": 0, "idee": 0}
	for ce in _in_costruzione(gs, player, data, col_from, level, bases):
		var sc: Dictionary = ce[1].get("sconto", {})
		for r in sc: s[r] += int(sc[r])
	return s

# "Il primo edificio costruito qui ignora il requisito di terreno."
static func ignora_terreno(gs: GameState, col_from: int, col_to: int) -> bool:
	for c in range(col_from, col_to):
		if bool(effetto(gs, c, "costruisci").get("ignora_terreno", false)): return true
	return false

# A edificio posato: le tessere si girano e danno quel che danno. Lo sconto e'
# gia' stato pagato nel preventivo.
static func dopo_costruzione(gs: GameState, player: int, b: Building, bases: Array) -> void:
	var p: PlayerState = gs.players[player]
	for ce in _in_costruzione(gs, player, b.data, b.col_from, b.level, bases, b):
		var c: int = ce[0]
		var e: Dictionary = ce[1]
		var cosa := []
		if e.has("sconto"): cosa.append("sconto sul costo")
		if int(e.get("lampo", 0)) > 0:
			p.add_vp("lampo", int(e["lampo"])); b.rende("lampo", int(e["lampo"]))
			cosa.append("+%d Lampo" % int(e["lampo"]))
		if int(e.get("lampo_per_altrui", 0)) > 0:
			var n := 0
			for altro in gs.grid.alive_in_column(c):
				if altro.owner != player and altro.state == Enums.BuildingState.INTATTO: n += 1
			n *= int(e["lampo_per_altrui"])
			if n > 0:
				p.add_vp("lampo", n); b.rende("lampo", n)
			cosa.append("+%d Lampo" % n)
		if int(e.get("resistenza_era", 0)) > 0:
			b.protection += int(e["resistenza_era"])
			cosa.append("+%d resistenza per l'era" % int(e["resistenza_era"]))
		if bool(e.get("immune_evento", false)):
			# "Protetto all'evento": la protezione si azzera a fine era, come
			# quella del lavoratore; nessun evento arriva a 20.
			b.protection += 20
			cosa.append("protetto all'evento")
		if int(e.get("scavo", 0)) > 0:
			b.bonus_scavo += int(e["scavo"])
			cosa.append("Scavo +%d" % int(e["scavo"]))
		if e.has("guadagno"):
			var gg: Dictionary = e["guadagno"]
			p.gain(int(gg.get("pietra", 0)), int(gg.get("oro", 0)), int(gg.get("idee", 0)))
			cosa.append("guadagno")
		if bool(e.get("produce_subito", false)):
			EraRules.paga_edificio(gs, b)
			cosa.append("produce subito")
		if bool(e.get("ignora_terreno", false)): cosa.append("terreno libero")
		gira(gs, c, "%s (%s)" % [b.data["name"], ", ".join(cosa)])

# ---- ristrutturare, potenziare, scheletro, seppellire ---------------------------
static func _prima_su(gs: GameState, b: Building, quando: String) -> Array:
	for c in range(b.col_from, b.col_to):
		var e := effetto(gs, c, quando)
		if not e.is_empty(): return [c, e]
	return []

static func sconto_ristrutturazione(gs: GameState, target: Building) -> Dictionary:
	var ce := _prima_su(gs, target, "ristruttura")
	return {} if ce.is_empty() else ce[1].get("sconto", {})

static func dopo_ristrutturazione(gs: GameState, target: Building) -> void:
	var ce := _prima_su(gs, target, "ristruttura")
	if ce.is_empty(): return
	var e: Dictionary = ce[1]
	if int(e.get("resistenza", 0)) > 0: target.bonus_res += int(e["resistenza"])
	gira(gs, ce[0], "ristrutturazione di %s" % target.data["name"])

static func sconto_potenziamento(gs: GameState, target: Building) -> Dictionary:
	var ce := _prima_su(gs, target, "potenzia")
	return {} if ce.is_empty() else ce[1].get("sconto", {})

static func dopo_potenziamento(gs: GameState, target: Building) -> void:
	var ce := _prima_su(gs, target, "potenzia")
	if ce.is_empty(): return
	gira(gs, ce[0], "potenziamento su %s" % target.data["name"])

# "Il primo scheletro lasciato qui vale +1 punto a fine partita": lo scheletro
# conta sempre (costante `scheletro_conta`), quindi il punto si segna subito.
static func dopo_scheletro(gs: GameState, player: int, target: Building) -> void:
	var ce := _prima_su(gs, target, "scheletro")
	if ce.is_empty(): return
	var n := int(ce[1].get("punti", 0))
	gs.players[player].add_vp("scheletri", n)
	gira(gs, ce[0], "+%d allo scheletro sotto %s" % [n, target.data["name"]])

# "Chi seppellisce per primo un edificio qui prende +1 al premio di scavo":
# solo se il premio c'e' (seppellire il proprio spianato vale 0 e resta 0).
static func premio_in_piu(gs: GameState, player: int, sepolto: Building, premio: int) -> int:
	if premio <= 0: return 0
	var ce := _prima_su(gs, sepolto, "seppellisci")
	if ce.is_empty(): return 0
	var n := int(ce[1].get("premio", 0))
	gira(gs, ce[0], "+%d al premio di scavo per %s" % [n, sepolto.data["name"]])
	return n

# ---- fine partita -----------------------------------------------------
# "A fine partita chi ha l'edificio in cima a questa colonna prende +2 punti."
static func fine_partita(gs: GameState) -> void:
	for c in gs.tessere_colonna.size():
		var e := effetto(gs, c, "fine_partita")
		if e.is_empty(): continue
		var top := gs.grid.top_of(c)
		if top == null or not top.is_alive(): continue
		var n := int(e.get("cima_punti", 0))
		gs.players[top.owner].add_vp("effetti_finali", n)
		gira(gs, c, "+%d a giocatore %d per %s in cima" % [n, top.owner, top.data["name"]])
