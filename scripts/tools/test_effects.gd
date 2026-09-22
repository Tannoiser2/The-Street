# res://scripts/tools/test_effects.gd
# Test del motore degli effetti (M4): tutti e 24 gli eventi, caso positivo e
# negativo, piu' la chiusura dello schema e il registro degli override non
# ancora applicati.
# Uso:  godot --headless res://scenes/test_effects.tscn   (esce 1 se fallisce)
extends Node

var _passed := 0
var _failed := 0

func _ready() -> void:
	_run("copertura: ogni evento ha effetti strutturati", _test_coverage)
	_run("modificatori di resistenza, evento per evento", _test_events)
	_run("effetti non di resistenza", _test_non_resistance)
	_run("override dichiarati ma non ancora applicati", _test_pending)
	_run("aure degli edifici", _test_auras)
	_run("requisito di terreno adiacente", _test_terrain_adjacent)
	_run("punteggio finale degli edifici", _test_final_scoring)
	_run("potenziamenti", _test_upgrades)
	_run("lo schema e' davvero chiuso", _test_schema_closed)
	print("\n%d superati, %d falliti" % [_passed, _failed])
	get_tree().quit(0 if _failed == 0 else 1)

func _run(name: String, f: Callable) -> void:
	print("\n— %s" % name)
	f.call()

func _ok(label: String, cond: bool, detail := "") -> void:
	if cond:
		_passed += 1
		print("  [ok]   %s" % label)
	else:
		_failed += 1
		printerr("  [KO]   %s%s" % [label, ("  — " + detail) if detail != "" else ""])

func _eq(label: String, got, want) -> void:
	_ok(label, got == want, "atteso %s, ottenuto %s" % [want, got])

# ---- infrastruttura -------------------------------------------------
func _game() -> GameController:
	var ctl := GameController.new()
	ctl.new_game(3, 11)
	return ctl

func _put(gs: GameState, card_id: String, col: int, level := 0,
		state := Enums.BuildingState.INTATTO) -> Building:
	var b := Building.new()
	b.uid = gs.new_uid()
	b.data = CardDB.buildings[card_id]
	b.owner = 0
	b.era_built = gs.era
	b.col_from = col
	b.col_to = col + int(b.data["width"])
	b.level = level
	b.state = state
	gs.grid.buildings.append(b)
	return b

# Prima carta di una classe; il test fallisce se non esiste, invece di
# proseguire su un caso vuoto.
func _card_of_class(cls: String) -> String:
	for id in CardDB.buildings:
		if cls in CardDB.buildings[id]["classes"]: return id
	return ""

func _set_event(gs: GameState, event_id: String) -> void:
	gs.current_event = CardDB.events[event_id]

func _flat(gs: GameState, t: int) -> void:
	for i in gs.grid.n_cols: gs.grid.terrains[i] = t

# ---- copertura ------------------------------------------------------
func _test_coverage() -> void:
	var missing: Array[String] = []
	var only_res := 0
	for id in CardDB.events:
		var eff: Array = CardDB.events[id].get("effects", [])
		if eff.is_empty(): missing.append(id)
		else:
			var all_res := true
			for e in eff:
				if e["op"] != "resistance": all_res = false
			if all_res: only_res += 1
	_eq("tutti i 24 eventi hanno un campo effects", missing, [] as Array[String])
	_eq("eventi risolti dal solo 'resistance'", only_res, 19)

# ---- i 24 eventi ----------------------------------------------------
func _test_events() -> void:
	for cls in Enums.CLASSES:
		_ok("esiste un edificio di classe %s" % cls, _card_of_class(cls) != "")

	# --- classe +/-N: sei eventi, positivo e negativo
	var by_class := {
		"ev_faide_tribali": [["militare", 1], ["civico", -2], ["cultura", 0]],
		"ev_eta_degli_spiriti": [["religione", 1], ["commercio", -1], ["militare", 0]],
		"ev_persecuzioni": [["religione", -2], ["civico", 1], ["cultura", 0]],
		"ev_pax_imperiale": [["ingegneria", 1], ["militare", -1], ["civico", 0]],
		"ev_scisma": [["religione", -2], ["cultura", -1], ["commercio", 1], ["civico", 0]],
		"ev_guerra": [["militare", 1], ["civico", -1], ["religione", 0]],
		"ev_controriforma": [["religione", 1], ["cultura", -1], ["commercio", 0]],
	}
	for ev in by_class:
		for pair in by_class[ev]:
			var ctl := _game()
			var gs := ctl.gs
			_flat(gs, Enums.Terrain.PIANURA)
			_set_event(gs, ev)
			var b := _put(gs, _card_of_class(pair[0]), 1)
			_eq("%s · %s → %+d" % [ev, pair[0], pair[1]],
				Effects.event_resistance_modifier(gs, b), pair[1])

	# --- terreno
	var by_terrain := {
		"ev_diluvio": [Enums.Terrain.FIUME, -1],
		"ev_incursioni_fluviali": [Enums.Terrain.FIUME, -1],
		"ev_alluvione": [Enums.Terrain.FIUME, -1],
		"ev_eruzione": [Enums.Terrain.COLLINA, -2],
		"ev_bonifiche": [Enums.Terrain.PIANURA, -2],
	}
	for ev in by_terrain:
		var ctl2 := _game()
		var gs2 := ctl2.gs
		_flat(gs2, by_terrain[ev][0])
		_set_event(gs2, ev)
		var b2 := _put(gs2, "ed_capanne", 1)
		_eq("%s · sul terreno colpito → %+d" % [ev, by_terrain[ev][1]],
			Effects.event_resistance_modifier(gs2, b2), by_terrain[ev][1])
		var ctl3 := _game()
		var gs3 := ctl3.gs
		_flat(gs3, Enums.Terrain.BOSCO if by_terrain[ev][0] != Enums.Terrain.BOSCO else Enums.Terrain.FIUME)
		_set_event(gs3, ev)
		var b3 := _put(gs3, "ed_capanne", 1)
		_eq("  %s · su altro terreno → 0" % ev, Effects.event_resistance_modifier(gs3, b3), 0)

	# ev_inverno_lungo colpisce due terreni
	for t in [Enums.Terrain.BOSCO, Enums.Terrain.COLLINA]:
		var ctlx := _game()
		var gsx := ctlx.gs
		_flat(gsx, t)
		_set_event(gsx, "ev_inverno_lungo")
		_eq("ev_inverno_lungo · bosco/collina → -1",
			Effects.event_resistance_modifier(gsx, _put(gsx, "ed_capanne", 1)), -1)
	var ctly := _game()
	_flat(ctly.gs, Enums.Terrain.FIUME)
	_set_event(ctly.gs, "ev_inverno_lungo")
	_eq("  ev_inverno_lungo · fiume → 0",
		Effects.event_resistance_modifier(ctly.gs, _put(ctly.gs, "ed_capanne", 1)), 0)

	# --- non protetti
	for ev in ["ev_migrazione", "ev_invasione"]:
		var ctl4 := _game()
		var gs4 := ctl4.gs
		_flat(gs4, Enums.Terrain.PIANURA)
		_set_event(gs4, ev)
		var nudo := _put(gs4, "ed_capanne", 1)
		var prot := _put(gs4, "ed_capanne", 3)
		prot.protection = 2
		_eq("%s · non protetto → -1" % ev, Effects.event_resistance_modifier(gs4, nudo), -1)
		_eq("  %s · protetto → 0" % ev, Effects.event_resistance_modifier(gs4, prot), 0)

	# --- livello
	var ctl5 := _game()
	var gs5 := ctl5.gs
	_flat(gs5, Enums.Terrain.PIANURA)
	_set_event(gs5, "ev_grande_incendio")
	_eq("ev_grande_incendio · livello 0 → -1", Effects.event_resistance_modifier(gs5, _put(gs5, "ed_capanne", 1, 0)), -1)
	_eq("  livello 1 → -1", Effects.event_resistance_modifier(gs5, _put(gs5, "ed_capanne", 3, 1)), -1)
	_eq("  livello 2 → -2", Effects.event_resistance_modifier(gs5, _put(gs5, "ed_capanne", 5, 2)), -2)

	# --- larghezza
	var ctl6 := _game()
	var gs6 := ctl6.gs
	_flat(gs6, Enums.Terrain.PIANURA)
	_set_event(gs6, "ev_terremoto")
	_eq("ev_terremoto · 2 caselle → -1", Effects.event_resistance_modifier(gs6, _put(gs6, "ed_villaggio_palizzato", 1)), -1)
	_eq("  1 casella → 0", Effects.event_resistance_modifier(gs6, _put(gs6, "ed_capanne", 4)), 0)

	# --- produce + livello 0 + non protetto (tre predicati in AND)
	var ctl7 := _game()
	var gs7 := ctl7.gs
	_flat(gs7, Enums.Terrain.PIANURA)
	_set_event(gs7, "ev_carestia_primitiva")
	_eq("ev_carestia_primitiva · produce, livello 0, scoperto → -2",
		Effects.event_resistance_modifier(gs7, _put(gs7, "ed_capanne", 1)), -2)
	_eq("  non produce → 0", Effects.event_resistance_modifier(gs7, _put(gs7, "ed_dolmen", 3)), 0)
	var alto := _put(gs7, "ed_capanne", 5, 1)
	_eq("  produce ma a livello 1 → 0", Effects.event_resistance_modifier(gs7, alto), 0)
	var difeso := _put(gs7, "ed_capanne", 6)
	difeso.protection = 2
	_eq("  produce ma protetto → 0", Effects.event_resistance_modifier(gs7, difeso), 0)

	# --- vetusta e scavo
	var ctl8 := _game()
	var gs8 := ctl8.gs
	_flat(gs8, Enums.Terrain.PIANURA)
	_set_event(gs8, "ev_speculazione_edilizia")
	var vecchio := _put(gs8, "ed_capanne", 1)
	vecchio.vetusta = 2
	_eq("ev_speculazione_edilizia · Vetusta 2 → -1", Effects.event_resistance_modifier(gs8, vecchio), -1)
	var giovane := _put(gs8, "ed_capanne", 3)
	giovane.vetusta = 1
	_eq("  Vetusta 1 → 0", Effects.event_resistance_modifier(gs8, giovane), 0)

	var ctl9 := _game()
	var gs9 := ctl9.gs
	_flat(gs9, Enums.Terrain.PIANURA)
	_set_event(gs9, "ev_rivoluzione_industriale")
	_eq("ev_rivoluzione_industriale · Scavo 2 → -1",
		Effects.event_resistance_modifier(gs9, _put(gs9, "ed_capanne", 1)), -1)
	_eq("  Scavo 0 → 0", Effects.event_resistance_modifier(gs9, _put(gs9, "ed_trappole_da_pesca", 3)), 0)

	# --- condizioni sulla colonna
	var ctlA := _game()
	var gsA := ctlA.gs
	_flat(gsA, Enums.Terrain.PIANURA)
	_set_event(gsA, "ev_guerra_civile")
	var mio := _put(gsA, "ed_capanne", 1)
	_eq("ev_guerra_civile · colonna di un solo proprietario → 0", Effects.event_resistance_modifier(gsA, mio), 0)
	var altrui := _put(gsA, "ed_capanne", 1)
	altrui.owner = 1
	_eq("  con due proprietari → -1", Effects.event_resistance_modifier(gsA, mio), -1)

	var ctlB := _game()
	var gsB := ctlB.gs
	_flat(gsB, Enums.Terrain.PIANURA)
	_set_event(gsB, "ev_peste")
	var uno := _put(gsB, "ed_capanne", 1)
	_put(gsB, "ed_capanne", 1)
	_eq("ev_peste · 2 edifici in piedi → 0", Effects.event_resistance_modifier(gsB, uno), 0)
	_put(gsB, "ed_capanne", 1)
	_eq("  3 edifici in piedi → -1", Effects.event_resistance_modifier(gsB, uno), -1)

	# --- ev_secolarizzazioni: la parte di resistenza
	var ctlC := _game()
	var gsC := ctlC.gs
	_flat(gsC, Enums.Terrain.PIANURA)
	_set_event(gsC, "ev_secolarizzazioni")
	_eq("ev_secolarizzazioni · Religione → -2",
		Effects.event_resistance_modifier(gsC, _put(gsC, _card_of_class("religione"), 1)), -2)

	# --- ev_anni_della_fame non tocca la resistenza
	var ctlD := _game()
	var gsD := ctlD.gs
	_flat(gsD, Enums.Terrain.PIANURA)
	_set_event(gsD, "ev_anni_della_fame")
	_eq("ev_anni_della_fame · nessun effetto sulla resistenza",
		Effects.event_resistance_modifier(gsD, _put(gsD, "ed_capanne", 1)), 0)

# ---- effetti non di resistenza --------------------------------------
func _test_non_resistance() -> void:
	# ev_inverno_lungo: "Tutti i giocatori perdono 1 pietra"
	var ctl := _game()
	var gs := ctl.gs
	_set_event(gs, "ev_inverno_lungo")
	for p in gs.players: p.pietra = 3
	Effects.era_end_resources(gs)
	var tutte := gs.players.map(func(p): return p.pietra)
	_eq("ev_inverno_lungo · tutti perdono 1 pietra", tutte, [2, 2, 2])
	for p in gs.players: p.pietra = 0
	Effects.era_end_resources(gs)
	_eq("  non scende sotto zero", gs.players.map(func(p): return p.pietra), [0, 0, 0])

	# ev_bonifiche: il primo slot di terrapieno costa 0
	var ctl2 := _game()
	var gs2 := ctl2.gs
	_flat(gs2, Enums.Terrain.PIANURA)
	var me := gs2.current_index
	var data: Dictionary = CardDB.buildings["ed_capanne"]
	_put(gs2, "ed_capanne", 1)          # una base vera, cosi' il preventivo e' legale
	gs2.current_event = CardDB.events["ev_diluvio"]
	var senza := BuildRules.quote_above(gs2, me, data, 1, null)
	gs2.current_event = CardDB.events["ev_bonifiche"]
	var con := BuildRules.quote_above(gs2, me, data, 1, null)
	_ok("preventivo legale in entrambi i casi", senza.legal and con.legal, senza.reason + " / " + con.reason)
	_eq("  senza l'evento il terrapieno si paga", con.pietra, senza.pietra)  # 0 colonne di terrapieno qui
	# ora una costruzione che richiede davvero un terrapieno
	var gs3 := _game().gs
	_flat(gs3, Enums.Terrain.PIANURA)
	var wide: Dictionary = CardDB.buildings["ed_villaggio_palizzato"]
	_put(gs3, "ed_capanne", 1)          # base in colonna 1, colonna 2 nuda -> terrapieno
	gs3.era = int(wide["era"])
	gs3.current_event = CardDB.events["ev_diluvio"]
	var q1 := BuildRules.quote_above(gs3, 0, wide, 1, null)
	gs3.current_event = CardDB.events["ev_bonifiche"]
	var q2 := BuildRules.quote_above(gs3, 0, wide, 1, null)
	_ok("costruzione con terrapieno: preventivo legale", q1.legal and q2.legal, q1.reason + " / " + q2.reason)
	_ok("  ev_bonifiche sconta uno slot di terrapieno", q2.pietra < q1.pietra,
		"senza %d, con %d" % [q1.pietra, q2.pietra])
	_ok("  ed e' segnalato nel preventivo", q2.terrapieno_free_applied)

	# ev_secolarizzazioni: restauro gratuito dei ruderi Religione
	var gs4 := _game().gs
	_flat(gs4, Enums.Terrain.PIANURA)
	var rel := _put(gs4, _card_of_class("religione"), 1, 0, Enums.BuildingState.RUDERE)
	var civ := _put(gs4, _card_of_class("civico"), 3, 0, Enums.BuildingState.RUDERE)
	gs4.current_event = CardDB.events["ev_diluvio"]
	var pieno := ActionRules.quote_restore(gs4, 0, rel)
	gs4.current_event = CardDB.events["ev_secolarizzazioni"]
	var gratis := ActionRules.quote_restore(gs4, 0, rel)
	var altro := ActionRules.quote_restore(gs4, 0, civ)
	_ok("senza l'evento il restauro Religione costa", pieno.pietra + pieno.oro > 0)
	_eq("  con ev_secolarizzazioni costa 0", [gratis.pietra, gratis.oro], [0, 0])
	_ok("  ma solo per la classe indicata", altro.pietra + altro.oro > 0)

# ---- registro degli override non applicati --------------------------
func _test_pending() -> void:
	# Il registro e' calcolato dai dati, non scritto a mano: se qualcuno
	# struttura un effetto nuovo senza implementarlo, compare qui da solo.
	var pend := Effects.pending()
	print("     inerti oggi (%d): %s" % [pend.size(), ", ".join(pend)])
	_ok("il registro dei pendenti si calcola dai dati", pend.size() > 0)
	for k in Effects.APPLIED_HOOK_OPS:
		_ok("  applicato: %s" % k, not k in pend)
	for n in Effects.APPLIED_OVERRIDES:
		_ok("  applicato: %s" % n, not n in pend)
	# i due override degli eventi noti come inerti devono restare segnalati
	for n in ["no_production_last_round", "free_upgrade_on_loss"]:
		_ok("  ancora inerte, e segnalato: %s" % n, n in pend)

	# i 25 personaggi hanno tutti effetti strutturati
	var senza: Array[String] = []
	for id in CardDB.characters:
		if CardDB.characters[id].get("is_dynasty", false): continue
		if CardDB.characters[id].get("effects", []).is_empty(): senza.append(id)
	_eq("tutti i 25 personaggi hanno un campo effects", senza, [] as Array[String])

	# "Subito:" applicato davvero
	var ctl := _game()
	var gs := ctl.gs
	var p: PlayerState = gs.players[0]
	p.pietra = 0
	p.oro = 0
	Effects.apply_on_acquire(gs, 0, CardDB.characters["pe_banchiere"])
	_eq("Banchiere: Subito +3 oro", [p.pietra, p.oro], [0, 3])
	Effects.apply_on_acquire(gs, 0, CardDB.characters["pe_capotribu"])
	_eq("  Capotribu: Subito +2 pietra", [p.pietra, p.oro], [2, 3])
	var vp0: int = p.vp
	Effects.apply_on_acquire(gs, 0, CardDB.characters["pe_mecenate"])
	_eq("  Mecenate: Subito +1 cultura", p.vp, vp0 + 1)
	Effects.apply_on_acquire(gs, 0, CardDB.characters["pe_sciamano"])
	_eq("  Sciamano non ha 'Subito', quindi non cambia nulla", [p.pietra, p.oro], [2, 3])

# ---- chiusura dello schema ------------------------------------------
func _test_schema_closed() -> void:
	var schema = JSON.parse_string(FileAccess.open("res://data/cards.schema.json", FileAccess.READ).get_as_text())
	var data = JSON.parse_string(FileAccess.open("res://data/cards.json", FileAccess.READ).get_as_text())
	var cases := {
		"hook inesistente": func(d): d["events"][0]["effects"][0]["hook"] = "on_pioggia",
		"op inesistente": func(d): d["events"][0]["effects"][0]["op"] = "teletrasporto",
		"override non in elenco": func(d): d["events"][0]["effects"][0] = {"hook": "on_event", "op": "rule_override", "name": "inventato"},
		"predicato di selettore inventato": func(d): d["events"][0]["effects"][0]["target"] = {"colore": ["rosso"]},
		"classe inesistente nel selettore": func(d): d["events"][0]["effects"][0]["target"] = {"class": ["agricoltura"]},
		"campo effects mancante su un evento": func(d): d["events"][0].erase("effects"),
	}
	for label in cases:
		var copy: Dictionary = data.duplicate(true)
		cases[label].call(copy)
		var v := SchemaValidator.new()
		_ok("rifiuta: %s" % label, not v.validate(copy, schema))


# ---- aure degli edifici ---------------------------------------------
func _test_auras() -> void:
	# Castrum: "+1 res ai tuoi edifici in questa colonna"
	var ctl := _game()
	var gs := ctl.gs
	_flat(gs, Enums.Terrain.PIANURA)
	_set_event(gs, "ev_diluvio")                 # evento su fiume: qui non morde
	var castrum := _put(gs, "ed_castrum", 1)     # occupa le colonne 1-2
	var mio := _put(gs, "ed_capanne", 1)
	var lontano := _put(gs, "ed_capanne", 5)
	var altrui := _put(gs, "ed_capanne", 2)
	altrui.owner = 1
	_eq("Castrum · mio edificio nella stessa colonna → +1", Effects.aura_resistance_modifier(gs, mio), 1)
	_eq("  mio edificio lontano → 0", Effects.aura_resistance_modifier(gs, lontano), 0)
	_eq("  edificio altrui nella colonna → 0", Effects.aura_resistance_modifier(gs, altrui), 0)
	# Lettura letterale: "ai tuoi edifici in questa colonna" comprende il Castrum
	# stesso, che e' uno dei tuoi edifici in quella colonna (domande-aperte 24).
	_eq("  il Castrum potenzia anche se stesso", Effects.aura_resistance_modifier(gs, castrum), 1)

	# la sorgente spenta non protegge piu'
	castrum.state = Enums.BuildingState.RUDERE
	_eq("  Castrum ridotto a rudere → l'aura si spegne", Effects.aura_resistance_modifier(gs, mio), 0)

	# Mura: "+1 res agli edifici adiacenti (anche altrui)"
	var ctl2 := _game()
	var gs2 := ctl2.gs
	_flat(gs2, Enums.Terrain.PIANURA)
	_set_event(gs2, "ev_diluvio")
	_put(gs2, "ed_mura", 2)                      # colonna 2
	var vicino := _put(gs2, "ed_capanne", 3)
	var nemico := _put(gs2, "ed_capanne", 1)
	nemico.owner = 1
	var stessa := _put(gs2, "ed_capanne", 2)
	_eq("Mura · adiacente mio → +1", Effects.aura_resistance_modifier(gs2, vicino), 1)
	_eq("  adiacente altrui → +1 (le Mura proteggono tutti)", Effects.aura_resistance_modifier(gs2, nemico), 1)
	_eq("  stessa colonna → 0: adiacente non vuol dire sovrapposto",
		Effects.aura_resistance_modifier(gs2, stessa), 0)

	# Arsenale: solo i propri Militari adiacenti
	var ctl3 := _game()
	var gs3 := ctl3.gs
	_flat(gs3, Enums.Terrain.PIANURA)
	_set_event(gs3, "ev_diluvio")
	_put(gs3, "ed_arsenale", 0)                  # colonne 0-1
	var mil := _put(gs3, _card_of_class("militare"), 2)
	var civ := _put(gs3, _card_of_class("civico"), 2)
	_eq("Arsenale · Militare adiacente → +1", Effects.aura_resistance_modifier(gs3, mil), 1)
	_eq("  non Militare adiacente → 0", Effects.aura_resistance_modifier(gs3, civ), 0)

	# l'aura arriva davvero fino alla risoluzione dell'evento
	var ctl4 := _game()
	var gs4 := ctl4.gs
	_flat(gs4, Enums.Terrain.PIANURA)
	_set_event(gs4, "ev_faide_tribali")          # Civico -2
	_put(gs4, "ed_villaggio_palizzato", 0)       # Quartiere: +1 ai propri adiacenti
	var civico := _put(gs4, "ed_capanne", 2)
	_eq("l'evento e l'aura si sommano nel modificatore finale",
		Effects.event_resistance_modifier(gs4, civico), -1)

# ---- terrain_adjacent ------------------------------------------------
func _test_terrain_adjacent() -> void:
	var mulino: Dictionary = CardDB.buildings["ed_mulino"]
	_eq("il Mulino dichiara il requisito nel campo, non nel testo",
		mulino.get("terrain_adjacent"), "fiume")

	# pianura con fiume accanto: legale
	var ctl := _game()
	var gs := ctl.gs
	_flat(gs, Enums.Terrain.PIANURA)
	gs.era = int(mulino["era"])
	gs.grid.terrains[2] = Enums.Terrain.FIUME
	var q := BuildRules.quote_rail(gs, 0, mulino, 1)
	_ok("pianura con una colonna fiume adiacente: legale", q.legal, q.reason)

	# pianura senza fiume accanto: rifiutato
	var ctl2 := _game()
	var gs2 := ctl2.gs
	_flat(gs2, Enums.Terrain.PIANURA)
	gs2.era = int(mulino["era"])
	var q2 := BuildRules.quote_rail(gs2, 0, mulino, 1)
	_ok("pianura senza fiume adiacente: rifiutato", not q2.legal)

	# fiume nella colonna stessa, ma non adiacente: non basta
	var ctl3 := _game()
	var gs3 := ctl3.gs
	_flat(gs3, Enums.Terrain.PIANURA)
	gs3.era = int(mulino["era"])
	gs3.grid.terrains[4] = Enums.Terrain.FIUME
	_ok("fiume a due colonne di distanza: rifiutato",
		not BuildRules.quote_rail(gs3, 0, mulino, 1).legal)


# ---- punteggio finale degli edifici ---------------------------------
# Restituisce i PV del canale "effetti finali" per giocatore.
func _final(gs: GameState) -> Array[int]:
	Effects.apply_final_scoring(gs)
	var out: Array[int] = []
	for p in gs.players:
		out.append(int(p.vp_breakdown.get(Effects.VP_CHANNEL, 0)))
	return out

func _scena() -> GameState:
	var gs := _game().gs
	_flat(gs, Enums.Terrain.PIANURA)
	return gs

func _test_final_scoring() -> void:
	# Osservatorio: "Eco: +2 PV se ancora in piedi a fine partita"
	var a := _scena()
	_put(a, "ed_osservatorio", 1)
	_eq("Osservatorio intatto → +2", _final(a)[0], 2)
	var b := _scena()
	_put(b, "ed_osservatorio", 1, 0, Enums.BuildingState.RUDERE)
	_eq("  ridotto a rudere → 0", _final(b)[0], 0)
	var c := _scena()
	var oss := _put(c, "ed_osservatorio", 1)
	oss.is_buried = true
	_eq("  sotterrato → 0", _final(c)[0], 0)

	# Caffè letterario: "+1 PV se adiacente a un edificio Cultura"
	var d := _scena()
	_put(d, "ed_caffe_letterario", 2)
	_put(d, _card_of_class("cultura"), 3)
	_eq("Caffe letterario con un Cultura accanto → +1", _final(d)[0], 1)
	var e := _scena()
	_put(e, "ed_caffe_letterario", 2)
	_put(e, _card_of_class("militare"), 3)
	_eq("  con un Militare accanto → 0", _final(e)[0], 0)

	# Monumento ai caduti: "+1 PV per ogni ALTRO tuo edificio Militare"
	var f := _scena()
	_put(f, "ed_monumento_ai_caduti", 1)     # e' Militare+Religione
	_put(f, _card_of_class("militare"), 4)
	_put(f, _card_of_class("militare"), 6)
	_eq("Monumento ai caduti con 2 altri Militari → +2", _final(f)[0], 2)
	var g := _scena()
	_put(g, "ed_monumento_ai_caduti", 1)
	_eq("  da solo → 0, non conta se stesso", _final(g)[0], 0)

	# Museo: "+2 PV per ogni edificio Sotterrato sotto di se'"
	var h := _scena()
	var sotto1 := _put(h, "ed_capanne", 2, 0)
	var sotto2 := _put(h, "ed_capanne", 2, 1)
	sotto1.is_buried = true
	sotto2.is_buried = true
	_put(h, "ed_museo", 2, 2)
	_eq("Museo con 2 sotterrati sotto → +4", _final(h)[0], 4)
	var i := _scena()
	var accanto := _put(i, "ed_capanne", 5, 0)
	accanto.is_buried = true
	_put(i, "ed_museo", 2, 2)
	_eq("  un sotterrato in un'altra colonna non conta", _final(i)[0], 0)

	# Biblioteca: "+1 PV per classe diversa fra i tuoi edifici in questa colonna"
	var j := _scena()
	_put(j, "ed_biblioteca", 3)                      # cultura
	_put(j, _card_of_class("militare"), 3)
	_put(j, _card_of_class("religione"), 3)
	_eq("Biblioteca con 3 classi diverse in colonna → +3", _final(j)[0], 3)

	# Università: "+1 PV per ogni tuo personaggio reclutato"
	var k := _scena()
	_put(k, "ed_universita", 2)
	k.players[0].recruited_total = 3
	_eq("Universita con 3 reclutamenti → +3", _final(k)[0], 3)

	# Fondazione d'arte: "I tuoi potenziamenti valgono +1 PV"
	var l := _scena()
	_put(l, "ed_fondazione_darte", 1)
	var con_pot := _put(l, "ed_capanne", 4)
	con_pot.upgrades.append("po_idolo")
	con_pot.upgrades.append("po_statua")
	_eq("Fondazione d'arte con 2 potenziamenti in gioco → +2", _final(l)[0], 2)

	# Piazza monumentale: "+1 PV per tuo edificio in cima adiacente"
	var m := _scena()
	_put(m, "ed_piazza_monumentale", 1)              # occupa 1-2
	_put(m, "ed_capanne", 3)                         # adiacente, ed e' in cima
	_eq("Piazza monumentale con un mio edificio in cima accanto → +1", _final(m)[0], 1)

	# Parco archeologico: "fino a 2 tuoi edifici non Sotterrati adiacenti
	# valgono il loro Scavo" — il limite e' sul NUMERO, non sui punti
	var n := _scena()
	_put(n, "ed_parco_archeologico", 1)              # occupa 1-2
	for c2 in [3, 3, 3]:
		_put(n, "ed_grotte_dipinte", c2)             # Scavo 6 ciascuno
	var atteso: int = 2 * int(CardDB.buildings["ed_grotte_dipinte"]["scavo"])
	_eq("Parco archeologico conta al massimo 2 edifici", _final(n)[0], atteso)

	# Grattacielo: "+1 PV per livello" e "−1 PV agli edifici in cima adiacenti altrui"
	var o := _scena()
	_put(o, "ed_grattacielo", 2, 3)
	_eq("Grattacielo a livello 3 → +3 al proprietario", _final(o)[0], 3)
	var q := _scena()
	_put(q, "ed_grattacielo", 2, 3)
	var avversario := _put(q, "ed_capanne", 3)
	avversario.owner = 1
	var r := _final(q)
	_eq("  il malus colpisce l'avversario in cima accanto", r[1], -1)
	_eq("  e non tocca il proprietario del Grattacielo", r[0], 3)


# ---- potenziamenti ---------------------------------------------------
func _posa(gs: GameState, upg: String, host: Building) -> void:
	host.upgrades.append(upg)
	Effects.apply_on_acquire(gs, host.owner, CardDB.upgrades[upg], host)

func _test_upgrades() -> void:
	var senza := _card_of_class("civico")       # ne' Religione ne' Militare
	var rel := _card_of_class("religione")
	var mil := _card_of_class("militare")

	# Struttura: il cubetto nero
	var a := _scena()
	var h := _put(a, senza, 1)
	var prima := h.bonus_res
	_posa(a, "po_palizzata", h)
	_eq("Struttura: +1 resistenza all'ospite", h.bonus_res, prima + 1)

	# po_cannoniere: "+1 res (+2 su edificio Militare)"
	var b := _scena()
	var civ := _put(b, senza, 1)
	var m := _put(b, mil, 4)
	var r0 := civ.bonus_res
	var r1 := m.bonus_res
	_posa(b, "po_cannoniere", civ)
	_posa(b, "po_cannoniere", m)
	_eq("Cannoniere su edificio non Militare → +1", civ.bonus_res, r0 + 1)
	_eq("  su edificio Militare → +2", m.bonus_res, r1 + 2)

	# Arte: punti secchi
	var c := _scena()
	var h2 := _put(c, senza, 1)
	var v0: int = c.players[0].vp
	_posa(c, "po_statua", h2)
	_eq("Arte: Statua → +2 PV", c.players[0].vp, v0 + 2)
	_posa(c, "po_opera_darte", h2)
	_eq("  Opera d'arte → +3 PV", c.players[0].vp, v0 + 5)

	# po_idolo: "+1 PV (+1 extra su edificio Religione)"
	var d := _scena()
	var nr := _put(d, senza, 1)
	var v1: int = d.players[0].vp
	_posa(d, "po_idolo", nr)
	_eq("Idolo su edificio non Religione → +1 PV", d.players[0].vp, v1 + 1)
	var e2 := _scena()
	var sr := _put(e2, rel, 1)
	var v2: int = e2.players[0].vp
	_posa(e2, "po_idolo", sr)
	_eq("  su edificio Religione → +2 PV", e2.players[0].vp, v2 + 2)

	# po_reliquia: "+2 PV su edificio Religione, altrimenti +1"
	var f := _scena()
	var f1 := _put(f, senza, 1)
	var f2 := _put(f, rel, 4)
	var v3: int = f.players[0].vp
	_posa(f, "po_reliquia", f1)
	_eq("Reliquia su edificio non Religione → +1 PV", f.players[0].vp, v3 + 1)
	_posa(f, "po_reliquia", f2)
	_eq("  su edificio Religione → +2 PV", f.players[0].vp, v3 + 3)

	# po_iscrizione: "Scavo dell'edificio +2"
	var g := _scena()
	var h3 := _put(g, senza, 1)
	var s0 := h3.scavo_value()
	_posa(g, "po_iscrizione", h3)
	_eq("Iscrizione: Scavo dell'ospite +2", h3.scavo_value(), s0 + 2)

	# ibrido: "+1 PV e +1 res"
	var i := _scena()
	var h4 := _put(i, senza, 1)
	var v4: int = i.players[0].vp
	var rr := h4.bonus_res
	_posa(i, "po_campanile", h4)
	_ok("Campanile: ibrido, +1 PV e +1 res",
		i.players[0].vp == v4 + 1 and h4.bonus_res == rr + 1,
		"PV %d->%d, res %d->%d" % [v4, i.players[0].vp, rr, h4.bonus_res])

	# po_targa_storica: "+2 Scavo a ogni edificio Sotterrato sotto questo edificio"
	var j := _scena()
	var sotto := _put(j, senza, 2, 0)
	sotto.is_buried = true
	var sopra := _put(j, senza, 2, 1)
	sopra.upgrades.append("po_targa_storica")
	var ss := sotto.scavo_value()
	Effects.apply_scavo_modifiers(j)
	_eq("Targa storica: +2 Scavo al sotterrato sotto di se'", sotto.scavo_value(), ss + 2)
	var k := _scena()
	var altrove := _put(k, senza, 5, 0)
	altrove.is_buried = true
	var alto := _put(k, senza, 2, 1)
	alto.upgrades.append("po_targa_storica")
	var s2 := altrove.scavo_value()
	Effects.apply_scavo_modifiers(k)
	_eq("  non tocca i sotterrati di altre colonne", altrove.scavo_value(), s2)

	# end-to-end attraverso il comando, non solo la regola pura
	var ctl := _game()
	var gs := ctl.gs
	_flat(gs, Enums.Terrain.PIANURA)
	var target := _put(gs, senza, 2)
	target.owner = gs.current_index
	gs.upg_row = ["po_statua"]
	ctl.place_worker(2)
	var pl: PlayerState = gs.current_player()
	pl.oro = 9
	var v5: int = pl.vp
	_ok("il comando upgrade applica l'effetto", ctl.upgrade("po_statua", target))
	_eq("  +2 PV arrivati davvero", pl.vp, v5 + 2)
