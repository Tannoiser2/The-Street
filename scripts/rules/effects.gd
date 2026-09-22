# res://scripts/rules/effects.gd
# Motore degli effetti strutturati (M4). Legge il campo `effects` delle carte;
# nessuna stringa viene interpretata a runtime.
# Funzioni PURE tranne dove indicato: non modificano lo stato.
#
# Lo schema e' CHIUSO: hook, op, nomi di rule_override e predicati del selettore
# sono enumerati in data/cards.schema.json, quindi un refuso e' un errore di
# validazione invece di un effetto che non scatta in silenzio.
class_name Effects
extends RefCounted

# Che cosa il motore applica DAVVERO, oggi. Tutto il resto e' dichiarato nei
# dati ma inerte. Un test confronta questi due elenchi con cio' che le carte
# dichiarano: se qualcuno struttura un effetto nuovo senza implementarlo, il
# test lo segnala invece di lasciarlo passare per attivo.
# La chiave e' "tipo:hook:op", NON solo "hook:op". La distinzione non e'
# pedanteria: con la granularita' precedente lo Sciamano risultava applicato
# perche' "on_event:resistance" lo era per eventi ed edifici, mentre nessun
# codice scorreva i personaggi come sorgente. Il registro diceva il falso.
const APPLIED: Array[String] = [
	"evento:on_event:resistance",
	"evento:on_era_end:resource",
	"edificio:on_event:resistance",          # aure di Quartiere e di colonna
	"edificio:on_final_scoring:vp",
	"edificio:on_final_scoring:vp_per",
	"personaggio:on_acquire:resource",       # i "Subito:"
	"personaggio:on_acquire:vp",
	"personaggio:on_event:resistance",       # Sciamano, Capotribu, Ingegnere militare
	"personaggio:on_build:cost_delta",       # Costruttore di zattere, Architetto, Cardinale
	"personaggio:on_build:upgrade_slots_delta",  # Vescovo
	"personaggio:on_final_scoring:vp",
	"personaggio:on_final_scoring:vp_per",
	"personaggio:on_final_scoring:scavo_delta",  # Soprintendente
	"edificio:on_build:cost_delta",          # Bottega d'artista
	"edificio:on_activate:resource",         # Focolare comune, Ospedale dei pellegrini
	"personaggio:on_activate:resource",      # Console, Mercante
	"personaggio:on_activate:vp",            # Cronista
	"personaggio:on_acquire:protection_delta",   # Capotribu', Legionario, Cavaliere
	"personaggio:on_acquire:scavo_delta",    # le due Impronte, Incisore e Retore
	"personaggio:on_build:resource",         # Sacerdotessa
	"personaggio:on_build:resistance",       # Mastro costruttore
	"personaggio:on_era_end:vp",             # Legionario e Cavaliere, se l'edificio regge
	"potenziamento:on_activate:resource",    # Granaio, Boutique, Banchina
	"potenziamento:on_acquire:vp",
	"potenziamento:on_acquire:resistance",
	"potenziamento:on_acquire:scavo_delta",
	"potenziamento:on_final_scoring:scavo_delta",
]
const APPLIED_OVERRIDES: Array[String] = ["first_terrapieno_free", "free_restore_of_class",
	"ignore_terrain_requirement"]

static func _blocchi() -> Array:
	return [["evento", CardDB.events], ["personaggio", CardDB.characters],
			["edificio", CardDB.buildings], ["potenziamento", CardDB.upgrades]]

# Tutto cio' che le carte dichiarano ma il motore non applica, per tipo di carta.
static func pending() -> Array[String]:
	var out: Array[String] = []
	for coppia in _blocchi():
		var tipo: String = coppia[0]
		var block: Dictionary = coppia[1]
		for id in block:
			for e in block[id].get("effects", []):
				if e["op"] == "rule_override":
					if not e["name"] in APPLIED_OVERRIDES and not e["name"] in out:
						out.append(e["name"])
					continue
				var key: String = "%s:%s:%s" % [tipo, e["hook"], e["op"]]
				if not key in APPLIED and not key in out:
					out.append(key)
	out.sort()
	return out

# ---- accesso -------------------------------------------------------
static func of_event(gs: GameState) -> Array:
	return gs.current_event.get("effects", [])

static func find_override(gs: GameState, name: String) -> Dictionary:
	for e in of_event(gs):
		if e["op"] == "rule_override" and e["name"] == name:
			return e
	return {}

static func has_override(gs: GameState, name: String) -> bool:
	return not find_override(gs, name).is_empty()

# ---- selettore -----------------------------------------------------
# I predicati presenti valgono in AND. `source` serve solo ai predicati di
# adiacenza; se manca, quei predicati non possono essere soddisfatti.
# Un personaggio non sta sul tabellone: non ha un edificio sorgente, ma ha un
# proprietario. `owner` serve a risolvere "self"/"others" in quel caso.
static func matches(gs: GameState, b: Building, t: Dictionary,
		source: Building = null, owner: int = -1) -> bool:
	if t.is_empty(): return true

	var mio: int = source.owner if source != null else owner
	if t.has("owner") and mio >= 0:
		match str(t["owner"]):
			"self": if b.owner != mio: return false
			"others": if b.owner == mio: return false

	if t.has("class"):
		var hit := false
		for c in b.classes():
			if c in t["class"]: hit = true; break
		if not hit: return false

	if t.has("terrain"):
		var names: Array = t["terrain"]
		var hit2 := false
		for c in range(b.col_from, b.col_to):
			if _terrain_name(gs.grid.terrains[c]) in names: hit2 = true; break
		if not hit2: return false

	if t.has("state"):
		if not ["intatto", "rudere", "rovina"][b.state] in t["state"]: return false
	if t.has("buried") and b.is_buried != bool(t["buried"]): return false
	if t.has("razed") and b.was_razed != bool(t["razed"]): return false
	if not _in_range(b.upgrades.size(), t.get("upgrades", {})): return false
	if t.has("protected") and (b.protection > 0) != bool(t["protected"]): return false
	if t.has("produces"):
		var pr: Dictionary = b.data["production"]
		var makes := int(pr.get("pietra", 0)) > 0 or int(pr.get("oro", 0)) > 0
		if makes != bool(t["produces"]): return false

	if not _in_range(b.level, t.get("level", {})): return false
	if not _in_range(b.width(), t.get("width", {})): return false
	if not _in_range(b.vetusta, t.get("vetusta", {})): return false
	if not _in_range(int(b.data["scavo"]), t.get("scavo", {})): return false
	if not _in_range(b.era_built, t.get("era", {})): return false

	if t.has("column") and not _column_ok(gs, b, t["column"]): return false

	if t.has("is_self"):
		if source == null: return false
		if (b == source) != bool(t["is_self"]): return false
	if t.has("is_top") and _is_top(gs, b) != bool(t["is_top"]): return false
	if t.get("below_self", false):
		if source == null or b.level >= source.level or not _shares_column(b, source): return false
	if t.get("adjacent_to_self", false):
		if source == null or not _adjacent(b, source): return false
	if t.get("same_column_as_self", false):
		if source == null or not _shares_column(b, source): return false
	return true

# In cima ad almeno una delle colonne che occupa.
static func _is_top(gs: GameState, b: Building) -> bool:
	for c in range(b.col_from, b.col_to):
		if gs.grid.top_of(c) == b: return true
	return false

# Una sola colonna dell'ingombro che soddisfi la condizione basta: l'edificio
# e' esposto anche li'.
static func _column_ok(gs: GameState, b: Building, spec: Dictionary) -> bool:
	for c in range(b.col_from, b.col_to):
		var standing := gs.grid.standing_in_column(c)
		var owners := {}
		var eras := {}
		for o in standing:
			owners[o.owner] = true
			eras[o.era_built] = true
		if spec.has("min_owners") and owners.size() < int(spec["min_owners"]): continue
		if spec.has("min_standing") and standing.size() < int(spec["min_standing"]): continue
		if spec.has("min_eras") and eras.size() < int(spec["min_eras"]): continue
		return true
	return false

static func _in_range(v: int, r: Dictionary) -> bool:
	if r.is_empty(): return true
	if r.has("min") and v < int(r["min"]): return false
	if r.has("max") and v > int(r["max"]): return false
	return true

# "Adiacente" vuol dire accanto, non sovrapposto: le colonne si toccano ma non
# si intersecano. Due edifici nella stessa colonna sono "same_column", non
# "adjacent".
static func _adjacent(a: Building, b: Building) -> bool:
	if a == b: return false
	if a.col_from < b.col_to and b.col_from < a.col_to: return false
	return a.col_to == b.col_from or b.col_to == a.col_from

# "i tuoi edifici in questa colonna" comprende anche la carta che porta
# l'effetto: e' uno dei tuoi edifici in quella colonna. Chi deve escludersi lo
# dice con `is_self: false` nel selettore (vedi Monumento ai caduti).
# Nota: "adiacente" invece esclude sempre se stessi, perche' un edificio non e'
# adiacente a se'. Vedi docs/domande-aperte.md punto 24.
static func _shares_column(a: Building, b: Building) -> bool:
	return a.col_from < b.col_to and b.col_from < a.col_to

# "Per l'era: i tuoi edifici Religione hanno +1 res" e simili. Il personaggio
# non e' sul tabellone: la sorgente e' il giocatore che lo ha reclutato.
static func character_resistance_modifier(gs: GameState, b: Building) -> int:
	var mod := 0
	for p in gs.players:
		for cid in p.specialized_characters:
			if not CardDB.characters.has(cid): continue
			for e in CardDB.characters[cid].get("effects", []):
				if e["hook"] != "on_event" or e["op"] != "resistance": continue
				if matches(gs, b, e.get("target", {}), null, p.index):
					mod += int(e["value"])
	return mod

# ---- hook: on_era_end per i personaggi ------------------------------
# "se l'edificio protetto sopravvive all'evento, +1 cultura". Va valutato DOPO
# la risoluzione dell'evento e PRIMA che protezioni e personaggi si azzerino.
static func apply_era_end_characters(gs: GameState) -> void:
	for p in gs.players:
		for cid in p.specialized_characters:
			if not CardDB.characters.has(cid): continue
			var carta: Dictionary = CardDB.characters[cid]
			for e in carta.get("effects", []):
				if e["hook"] != "on_era_end" or e["op"] != "vp": continue
				var cond: Dictionary = e.get("condition", {})
				if str(cond.get("op", "")) == "protected_survived":
					if not _protetto_sopravvissuto(gs, p, cid): continue
				elif not _condition_met(gs, null, cond, p.index): continue
				p.add_vp("cultura", int(e["value"]))
				gs.log_line("%s: l'edificio protetto ha retto, +%d cultura" % [carta["name"], int(e["value"])])

static func _protetto_sopravvissuto(gs: GameState, p: PlayerState, cid: String) -> bool:
	if not p.character_targets.has(cid): return false
	var uid: int = int(p.character_targets[cid])
	for b in gs.grid.buildings:
		if b.uid == uid:
			return b.state == Enums.BuildingState.INTATTO and not b.is_buried
	return false

# ---- hook: on_activate (applica) -----------------------------------
# Scatta quando un giocatore attiva una colonna. La COLONNA ATTIVATA e' un
# contesto implicito, non un predicato del selettore: i bersagli candidati sono
# gli edifici che la coprono. Un personaggio non ha un edificio sorgente, e
# senza questa regola "quando attivi una colonna con un tuo strato Civico" non
# sarebbe esprimibile.
static func apply_on_activate(gs: GameState, attivatore: int, col: int) -> void:
	for voce in _sorgenti_attivabili(gs, col):
		var e: Dictionary = voce[0]
		var src: Building = voce[1]
		var own: int = voce[2]
		var carta: Dictionary = voce[3]
		if e["hook"] != "on_activate": continue
		if not _scatta(e, attivatore, own): continue
		if not _condition_met(gs, src, e.get("condition", {}), own): continue
		# i candidati sono i soli edifici della colonna attivata
		var trovato := false
		for b in gs.grid.in_column(col):
			if matches(gs, b, e.get("target", {}), src, own): trovato = true; break
		if not trovato: continue
		match str(e["op"]):
			"resource": _paga(gs, own, e, carta, int(e.get("pietra", 0)), int(e.get("oro", 0)))
			"vp": _paga_vp(gs, own, e, carta, int(e.get("value", 0)))

static func _scatta(e: Dictionary, attivatore: int, proprietario: int) -> bool:
	if str(e.get("when", "self_activates")) == "other_activates":
		return attivatore != proprietario
	return attivatore == proprietario

# Le sorgenti che possono scattare su questa attivazione: gli edifici che
# coprono la colonna coi loro potenziamenti, e i personaggi di tutti i
# giocatori (il Mercante scatta quando attiva un avversario).
static func _sorgenti_attivabili(gs: GameState, col: int) -> Array:
	var out := []
	for b in gs.grid.in_column(col):
		if not b.is_alive(): continue
		for card in _carte_di(b):
			for e in card.get("effects", []):
				out.append([e, b, b.owner, card])
	for p in gs.players:
		for cid in p.specialized_characters:
			if not CardDB.characters.has(cid): continue
			for e in CardDB.characters[cid].get("effects", []):
				out.append([e, null, p.index, CardDB.characters[cid]])
	return out

# `cap` e' un tetto sul TOTALE reso in quest'era da quella carta; `times` limita
# quante volte puo' scattare. Entrambi si contano su PlayerState.effect_used.
static func _quota(p: PlayerState, e: Dictionary, carta: Dictionary, valore: int) -> int:
	var chiave: String = str(carta["id"])
	var usato: int = int(p.effect_used.get(chiave, 0))
	if e.has("times"):
		if usato >= int(e["times"]): return 0
		p.effect_used[chiave] = usato + 1
		return valore
	if e.has("cap"):
		var resto: int = int(e["cap"]) - usato
		if resto <= 0: return 0
		var dato: int = min(valore, resto)
		p.effect_used[chiave] = usato + dato
		return dato
	return valore

static func _paga(gs: GameState, player: int, e: Dictionary, carta: Dictionary,
		pietra: int, oro: int) -> void:
	var p: PlayerState = gs.players[player]
	var tot := _quota(p, e, carta, max(pietra, oro))
	if tot <= 0: return
	p.gain(pietra if pietra > 0 else 0, oro if oro > 0 else 0)
	gs.log_line("%s: attivazione, %+d pietra %+d oro a giocatore %d" % [carta["name"], pietra, oro, player])

static func _paga_vp(gs: GameState, player: int, e: Dictionary, carta: Dictionary, v: int) -> void:
	var p: PlayerState = gs.players[player]
	var dato := _quota(p, e, carta, v)
	if dato <= 0: return
	p.add_vp("cultura", dato)
	gs.log_line("%s: attivazione, %+d cultura a giocatore %d" % [carta["name"], dato, player])

# ---- hook: on_build (applica) --------------------------------------
# Scatta dopo che l'edificio e' sulla griglia. `built` e' l'edificio appena
# costruito: senza bersaglio l'effetto va a lui, con bersaglio solo se lo
# soddisfa (la Sacerdotessa rimborsa solo i Religione).
static func apply_on_build(gs: GameState, player: int, built: Building) -> void:
	for voce in _sorgenti_attive(gs, player):
		var ef: Dictionary = voce[0]
		var src: Building = voce[1]
		var own: int = voce[2]
		if ef["hook"] != "on_build": continue
		if ef["op"] in ["cost_delta", "upgrade_slots_delta", "rule_override"]: continue
		if own != player: continue
		if not matches(gs, built, ef.get("target", {}), src, own): continue
		var carta: Dictionary = voce[3] if voce.size() > 3 else {}
		if carta.is_empty(): continue
		match str(ef["op"]):
			"resource":
				var quanto := _quota(gs.players[player], ef, carta, max(int(ef.get("pietra", 0)), int(ef.get("oro", 0))))
				if quanto <= 0: continue
				gs.players[player].gain(int(ef.get("pietra", 0)), int(ef.get("oro", 0)))
				gs.log_line("%s: rimborso di %+d pietra %+d oro" % [carta["name"], int(ef.get("pietra", 0)), int(ef.get("oro", 0))])
			"resistance":
				if _quota(gs.players[player], ef, carta, int(ef["value"])) <= 0: continue
				built.bonus_res += int(ef["value"])
				gs.log_line("%s: %s nasce con +%d resistenza" % [carta["name"], built.data["name"], int(ef["value"])])

# Un override attivo per il giocatore, che venga da un personaggio o da una
# carta in gioco. Distinto da has_override, che guarda l'evento dell'era.
static func has_active_override(gs: GameState, player: int, name: String) -> bool:
	for voce in _sorgenti_attive(gs, player):
		var ef: Dictionary = voce[0]
		if ef["op"] == "rule_override" and str(ef["name"]) == name and int(voce[2]) == player:
			return true
	return false

# ---- op: cost_delta ------------------------------------------------
# Sconti e rincari su una costruzione o un potenziamento ANCORA DA FARE.
# Il selettore va valutato su un edificio che non esiste: si costruisce una
# sonda con i dati della carta e la posizione scelta, e la si passa a matches.
static func sonda(data: Dictionary, owner: int, col_from: int, level: int) -> Building:
	var b := Building.new()
	b.data = data
	b.owner = owner
	b.col_from = col_from
	b.col_to = col_from + int(data.get("width", 1))
	b.level = level
	return b

static func cost_delta(gs: GameState, player: int, what: String, probe: Building) -> Vector2i:
	var d := Vector2i.ZERO
	for e in _sorgenti_attive(gs, player):
		var eff: Dictionary = e[0]
		var src: Building = e[1]
		var own: int = e[2]
		if eff["hook"] != "on_build" or eff["op"] != "cost_delta": continue
		if str(eff.get("what", "building")) != what: continue
		if not matches(gs, probe, eff.get("target", {}), src, own): continue
		d += Vector2i(int(eff.get("pietra", 0)), int(eff.get("oro", 0)))
	return d

# Capienza extra dei potenziamenti (il Vescovo: "capienza dei tuoi Religione +1").
static func upgrade_slots_bonus(gs: GameState, player: int, host: Building) -> int:
	var n := 0
	for e in _sorgenti_attive(gs, player):
		var eff: Dictionary = e[0]
		if eff["hook"] != "on_build" or eff["op"] != "upgrade_slots_delta": continue
		if not matches(gs, host, eff.get("target", {}), e[1], e[2]): continue
		n += int(eff["value"])
	return n

# Gli effetti che il giocatore ha attivi ora: i suoi personaggi dell'era, e le
# carte degli edifici vivi (proprie o altrui: il selettore decide a chi valgono).
# Ogni voce e' [effetto, edificio sorgente o null, proprietario].
static func _sorgenti_attive(gs: GameState, player: int) -> Array:
	var out := []
	for cid in gs.players[player].specialized_characters:
		if not CardDB.characters.has(cid): continue
		for e in CardDB.characters[cid].get("effects", []):
			out.append([e, null, player, CardDB.characters[cid]])
	for b in gs.grid.buildings:
		if not b.is_alive(): continue
		for card in _carte_di(b):
			for e in card.get("effects", []):
				out.append([e, b, b.owner, card])
	return out

static func _terrain_name(t: int) -> String:
	return ["pianura", "fiume", "collina", "bosco"][t]

# ---- op: resistance ------------------------------------------------
# Somma dei modificatori dell'evento corrente applicabili all'edificio.
# Sostituisce l'analisi testuale di effect_text.
static func event_resistance_modifier(gs: GameState, b: Building) -> int:
	var mod := 0
	for e in of_event(gs):
		if e["hook"] != "on_event" or e["op"] != "resistance": continue
		if matches(gs, b, e.get("target", {})):
			mod += int(e["value"])
	return mod + aura_resistance_modifier(gs, b) + character_resistance_modifier(gs, b)

# Aure di edificio: "Quartiere: +1 res ai tuoi edifici adiacenti", Castrum,
# Arsenale, Mura. La sorgente deve essere viva: un edificio spento non protegge.
static func aura_resistance_modifier(gs: GameState, b: Building) -> int:
	var mod := 0
	for src in gs.grid.buildings:
		if not src.is_alive(): continue
		for e in src.data.get("effects", []):
			if e["hook"] != "on_event" or e["op"] != "resistance": continue
			if matches(gs, b, e.get("target", {}), src):
				mod += int(e["value"])
	return mod

# ---- hook: on_acquire (applica) ------------------------------------
# "Subito:" dei personaggi. Applica solo resource e vp; gli altri op su
# on_acquire (l'Impronta dei due scultori) richiedono un edificio bersaglio
# che il comando di reclutamento non passa ancora.
# `host` e' l'edificio su cui la carta viene posata: per un potenziamento e' la
# sorgente di ogni selettore, perche' quasi tutti i suoi effetti parlano
# dell'edificio che lo porta ("+2 PV su edificio Religione", "+1 res").
static func apply_on_acquire(gs: GameState, player: int, card: Dictionary,
		host: Building = null) -> void:
	var p: PlayerState = gs.players[player]
	for e in card.get("effects", []):
		if e["hook"] != "on_acquire": continue
		if not _condition_met(gs, host, e.get("condition", {})): continue
		match str(e["op"]):
			"resource":
				p.gain(int(e.get("pietra", 0)), int(e.get("oro", 0)))
				gs.log_line("%s: %+d pietra %+d oro" % [card["name"], int(e.get("pietra", 0)), int(e.get("oro", 0))])
			"vp":
				p.add_vp("cultura", int(e["value"]))
				gs.log_line("%s: %+d cultura" % [card["name"], int(e["value"])])
			"resistance":
				for b in _bersagli(gs, host, e):
					b.bonus_res += int(e["value"])
			"scavo_delta":
				for b in _bersagli(gs, host, e):
					b.bonus_scavo += int(e["value"])
			"protection_delta":
				# "la sua protezione vale +3 invece di +2", "l'edificio protetto
				# da questo lavoratore ha +1 res": vanno all'edificio abitato.
				if host != null:
					host.protection += int(e["value"])
					gs.log_line("%s: %s protetto meglio (+%d)" % [card["name"], host.data["name"], int(e["value"])])

static func _bersagli(gs: GameState, src: Building, e: Dictionary) -> Array[Building]:
	var out: Array[Building] = []
	if src == null: return out
	for b in gs.grid.buildings:
		if matches(gs, b, e.get("target", {}), src): out.append(b)
	if e.has("times"): out = out.slice(0, int(e["times"]))
	return out

# ---- hook: on_final_scoring (applica) -------------------------------
# Voce 7 del conteggio, "Effetti finali". Ogni edificio in gioco porta i propri
# effetti, in qualunque stato si trovi: le carte che richiedono di essere
# sopravvissute lo dicono con una `condition` esplicita (Osservatorio,
# Acquedotto), quindi il silenzio delle altre e' significativo.
const VP_CHANNEL := "effetti_finali"

static func apply_final_scoring(gs: GameState) -> void:
	for p in gs.players:
		for cid in p.final_characters:
			if not CardDB.characters.has(cid): continue
			for e in CardDB.characters[cid].get("effects", []):
				if e["hook"] != "on_final_scoring": continue
				if e["op"] == "scavo_delta": continue
				if not _condition_met(gs, null, e.get("condition", {}), p.index): continue
				match str(e["op"]):
					"vp": _award(gs, p.index, int(e.get("value", 0)), CardDB.characters[cid])
					"vp_per": _apply_vp_per(gs, null, e, p.index, CardDB.characters[cid])
	for src in gs.grid.buildings:
		for card in _carte_di(src):
			for e in card.get("effects", []):
				if e["hook"] != "on_final_scoring": continue
				if e["op"] == "scavo_delta": continue      # gia' applicato nel pre-passo
				if not _condition_met(gs, src, e.get("condition", {})): continue
				match str(e["op"]):
					"vp": _award(gs, src.owner, int(e.get("value", 0)), src.data)
					"vp_per": _apply_vp_per(gs, src, e, src.owner, src.data)

# La carta dell'edificio piu' i potenziamenti che porta: per tutte, la sorgente
# dei selettori e' l'edificio stesso.
static func _carte_di(b: Building) -> Array[Dictionary]:
	var out: Array[Dictionary] = [b.data]
	for uid in b.upgrades:
		if CardDB.upgrades.has(uid): out.append(CardDB.upgrades[uid])
	return out

# Pre-passo: i modificatori di Scavo vanno applicati PRIMA che Scoring._scavo
# conti i punti, altrimenti arrivano tardi.
static func apply_scavo_modifiers(gs: GameState) -> void:
	for src in gs.grid.buildings:
		for card in _carte_di(src):
			for e in card.get("effects", []):
				if e["hook"] != "on_final_scoring" or e["op"] != "scavo_delta": continue
				if not _condition_met(gs, src, e.get("condition", {})): continue
				for b in _bersagli(gs, src, e):
					b.bonus_scavo += int(e["value"])
	for p in gs.players:
		for cid in p.final_characters:
			for e in CardDB.characters.get(cid, {}).get("effects", []):
				if e["hook"] != "on_final_scoring" or e["op"] != "scavo_delta": continue
				var hits: Array[Building] = []
				for b in gs.grid.buildings:
					if matches(gs, b, e.get("target", {}), null, p.index): hits.append(b)
				if e.has("times"): hits = hits.slice(0, int(e["times"]))
				for b in hits: b.bonus_scavo += int(e["value"])

static func _condition_met(gs: GameState, src: Building, cond: Dictionary,
		owner: int = -1) -> bool:
	if cond.is_empty(): return true
	if str(cond["op"]) != "count_matching": return true   # protected_survived: vedi _era_end_characters
	var n := 0
	for b in gs.grid.buildings:
		if matches(gs, b, cond.get("target", {}), src, owner): n += 1
	return n >= int(cond["min"])

static func _apply_vp_per(gs: GameState, src: Building, e: Dictionary,
		owner: int, carta: Dictionary) -> void:
	var hits: Array[Building] = []
	for b in gs.grid.buildings:
		if matches(gs, b, e.get("target", {}), src, owner): hits.append(b)
	# `times` limita QUANTI bersagli si contano ("fino a 2 tuoi edifici").
	# `cap` limita i PUNTI totali ("max +4"). Sono due cose diverse.
	if e.has("times"): hits = hits.slice(0, int(e["times"]))

	# A chi vanno i punti: di norma al proprietario della carta; col malus del
	# Grattacielo vanno invece a ciascun proprietario colpito.
	if str(e.get("to", "self")) == "target_owner":
		for b in hits: _award(gs, b.owner, int(e.get("value", 0)), carta)
		return

	var pts := 0
	if e.has("value_from"):
		var field := str(e["value_from"])
		for b in hits:
			pts += b.level if field == "level" else int(b.data["scavo"])
	else:
		var v := int(e.get("value", 0))
		pts = v * _conta(gs, owner, hits, str(e.get("per", "building")))
	if e.has("cap"): pts = min(pts, int(e["cap"]))
	_award(gs, owner, pts, carta)

static func _conta(gs: GameState, owner: int, hits: Array[Building], per: String) -> int:
	match per:
		"distinct_class":
			var cls := {}
			for b in hits:
				for c in b.classes(): cls[c] = true
			return cls.size()
		"level":
			var n := 0
			for b in hits: n += b.level
			return n
		"upgrade":
			var n2 := 0
			for b in hits: n2 += b.upgrades.size()
			return n2
		"recruited_character":
			return gs.players[owner].recruited_total
	return hits.size()

static func _award(gs: GameState, player: int, pts: int, carta: Dictionary) -> void:
	if pts == 0: return
	gs.players[player].add_vp(VP_CHANNEL, pts)
	gs.log_line("%s: %+d PV a giocatore %d" % [carta["name"], pts, player])

# ---- op: resource (applica) ----------------------------------------
# Unico effetto che modifica lo stato: lo fa il chiamante in rules/, non qui.
static func era_end_resources(gs: GameState) -> void:
	for e in of_event(gs):
		if e["hook"] != "on_era_end" or e["op"] != "resource": continue
		var dp := int(e.get("pietra", 0))
		var do_ := int(e.get("oro", 0))
		for p in gs.players:
			p.pietra = max(0, p.pietra + dp)
			p.oro = max(0, p.oro + do_)
		gs.log_line("%s: tutti %+d pietra %+d oro" % [gs.current_event.get("name", "evento"), dp, do_])
