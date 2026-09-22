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
	_run("effetti per l'era dei personaggi", _test_characters_era)
	_run("hook di attivazione", _test_on_activate)
	_run("lavoratore ed edificio protetto", _test_protection)
	_run("Impronte", _test_imprints)
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
	for k in Effects.APPLIED:
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

# Prepara il terreno richiesto dalla carta: senza, il preventivo e' illegale e
# il test passerebbe a vuoto confrontando due zeri.
func _terreno_per(gs: GameState, card_id: String) -> void:
	var req = CardDB.buildings[card_id].get("terrain")
	if req != null: _flat(gs, Enums.terrain_from_string(req))

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


# ---- effetti per l'era dei personaggi ---------------------------------
func _test_characters_era() -> void:
	var rel := _card_of_class("religione")
	var mil := _card_of_class("militare")
	var civ := _card_of_class("civico")

	# Sciamano: "Per l'era: i tuoi edifici Religione hanno +1 res".
	# E' il caso che il registro nascondeva: prima non dava nulla.
	var a := _scena()
	_set_event(a, "ev_diluvio")
	var mio_rel := _put(a, rel, 1)
	var mio_civ := _put(a, civ, 3)
	var suo_rel := _put(a, rel, 5)
	suo_rel.owner = 1
	a.players[0].specialized_characters = ["pe_sciamano"] as Array[String]
	_eq("Sciamano: il mio Religione → +1", Effects.character_resistance_modifier(a, mio_rel), 1)
	_eq("  il mio Civico → 0", Effects.character_resistance_modifier(a, mio_civ), 0)
	_eq("  il Religione altrui → 0", Effects.character_resistance_modifier(a, suo_rel), 0)
	_eq("  e arriva nel modificatore finale dell'evento",
		Effects.event_resistance_modifier(a, mio_rel), 1)

	# Ingegnere militare: "i tuoi edifici Militari hanno +1 res"
	var b := _scena()
	_set_event(b, "ev_diluvio")
	var m := _put(b, mil, 2)
	b.players[0].specialized_characters = ["pe_ingegnere_militare"] as Array[String]
	_ok("Ingegnere militare: il mio Militare guadagna resistenza",
		Effects.character_resistance_modifier(b, m) >= 1)

	# Cardinale: "−1 oro agli edifici Religione (minimo 0)"
	var c := _scena()
	_terreno_per(c, rel)
	c.era = int(CardDB.buildings[rel]["era"])
	var pieno := BuildRules.quote_rail(c, 0, CardDB.buildings[rel], 1)
	c.players[0].specialized_characters = ["pe_cardinale"] as Array[String]
	var scontato := BuildRules.quote_rail(c, 0, CardDB.buildings[rel], 1)
	_ok("preventivi legali", pieno.legal and scontato.legal, pieno.reason + " / " + scontato.reason)
	_eq("Cardinale: 1 oro in meno sui Religione", scontato.oro, max(0, pieno.oro - 1))
	var non_rel := _card_of_class("commercio")
	var d := _scena()
	_terreno_per(d, non_rel)
	d.era = int(CardDB.buildings[non_rel]["era"])
	var p1 := BuildRules.quote_rail(d, 0, CardDB.buildings[non_rel], 1)
	d.players[0].specialized_characters = ["pe_cardinale"] as Array[String]
	var p2 := BuildRules.quote_rail(d, 0, CardDB.buildings[non_rel], 1)
	_ok("  preventivo legale anche qui", p1.legal and p2.legal, p1.reason)
	_eq("  non tocca le altre classi", p2.oro, p1.oro)

	# Architetto: "−1 pietra agli edifici da 2 o 3 caselle"
	var e2 := _scena()
	var largo: String = ""
	for id in CardDB.buildings:
		if int(CardDB.buildings[id]["width"]) >= 2 and int(CardDB.buildings[id]["cost"]["pietra"]) >= 1:
			largo = id; break
	_ok("trovato un edificio largo con costo in pietra", largo != "")
	_terreno_per(e2, largo)
	e2.era = int(CardDB.buildings[largo]["era"])
	var q1 := BuildRules.quote_rail(e2, 0, CardDB.buildings[largo], 1)
	e2.players[0].specialized_characters = ["pe_architetto"] as Array[String]
	var q2 := BuildRules.quote_rail(e2, 0, CardDB.buildings[largo], 1)
	_ok("Architetto: preventivo legale", q1.legal and q2.legal, q1.reason)
	_eq("  1 pietra in meno sugli edifici larghi", q2.pietra, max(0, q1.pietra - 1))

	# Bottega d'artista: "I tuoi potenziamenti costano 1 oro in meno"
	var f := _scena()
	var host := _put(f, civ, 2)
	f.upg_row = ["po_statua"]
	var u1 := ActionRules.quote_upgrade(f, 0, "po_statua", host)
	_put(f, "ed_bottega_dartista", 5)
	var u2 := ActionRules.quote_upgrade(f, 0, "po_statua", host)
	_eq("Bottega d'artista: 1 oro in meno sui potenziamenti", u2.oro, max(0, u1.oro - 1))

	# Vescovo: "capienza dei tuoi Religione +1"
	var g := _scena()
	var chiesa := _put(g, rel, 2)
	var base := ActionRules.upgrade_capacity_for(g, 0, chiesa)
	g.players[0].specialized_characters = ["pe_vescovo"] as Array[String]
	_eq("Vescovo: capienza +1 sui Religione",
		ActionRules.upgrade_capacity_for(g, 0, chiesa), base + 1)
	var h := _scena()
	var caserma := _put(h, mil, 2)
	var base2 := ActionRules.upgrade_capacity_for(h, 0, caserma)
	h.players[0].specialized_characters = ["pe_vescovo"] as Array[String]
	_eq("  non tocca le altre classi", ActionRules.upgrade_capacity_for(h, 0, caserma), base2)

	# Veterano: "Finale: +1 PV per ogni tuo edificio Militare in piedi (max +4)"
	var i := _scena()
	for c2 in [1, 2, 3]: _put(i, mil, c2)
	i.players[0].final_characters = ["pe_veterano"] as Array[String]
	_eq("Veterano: +1 PV per Militare in piedi", _final(i)[0], 3)
	var j := _scena()
	for c3 in range(6): _put(j, mil, c3)
	j.players[0].final_characters = ["pe_veterano"] as Array[String]
	_eq("  ma non oltre il tetto di 4", _final(j)[0], 4)

	# i personaggi dell'era 5 devono arrivare al conteggio (punto 26)
	var k := _game().gs
	k.era = 5
	k.current_event = {}
	k.players[0].specialized_characters = ["pe_veterano"] as Array[String]
	EraRules.end_era(k)
	_eq("a fine era 5 i personaggi passano all'elenco finale",
		k.players[0].final_characters, ["pe_veterano"] as Array[String])
	_eq("  e specialized_characters si azzera come sempre",
		k.players[0].specialized_characters, [] as Array[String])


# ---- hook di attivazione ---------------------------------------------
func _ric(gs: GameState, i: int) -> Array[int]:
	var p: PlayerState = gs.players[i]
	return [p.pietra, p.oro] as Array[int]

func _test_on_activate() -> void:
	var civ := _card_of_class("civico")

	# Focolare comune: "+1 pietra quando abiti qui"
	var a := _scena()
	_put(a, "ed_focolare_comune", 2)
	var pre := _ric(a, 0)
	Effects.apply_on_activate(a, 0, 2)
	_eq("Focolare: chi lo abita prende +1 pietra", _ric(a, 0), [pre[0] + 1, pre[1]] as Array[int])
	var b := _scena()
	_put(b, "ed_focolare_comune", 2)
	var pre_b := _ric(b, 0)
	Effects.apply_on_activate(b, 0, 5)
	_eq("  attivando un'altra colonna → nulla", _ric(b, 0), pre_b)
	var c := _scena()
	_put(c, "ed_focolare_comune", 2)
	var pre_c := _ric(c, 0)
	Effects.apply_on_activate(c, 1, 2)          # attiva un avversario
	_eq("  se attiva un altro → nulla al proprietario", _ric(c, 0), pre_c)

	# Ospedale dei pellegrini: "+1 oro quando abiti qui"
	var d := _scena()
	_put(d, "ed_ospedale_dei_pellegrini", 1)
	var pre_d := _ric(d, 0)
	Effects.apply_on_activate(d, 0, 1)
	_eq("Ospedale: +1 oro", _ric(d, 0), [pre_d[0], pre_d[1] + 1] as Array[int])

	# po_boutique sull'ospite
	var e2 := _scena()
	var host := _put(e2, civ, 3)
	host.upgrades.append("po_boutique")
	var pre_e := _ric(e2, 0)
	Effects.apply_on_activate(e2, 0, 3)
	_eq("Boutique: +2 oro a chi abita l'edificio", _ric(e2, 0), [pre_e[0], pre_e[1] + 2] as Array[int])

	# po_banchina: solo su colonna fiume
	var f := _scena()
	f.grid.terrains[2] = Enums.Terrain.FIUME
	var hf := _put(f, civ, 2)
	hf.upgrades.append("po_banchina")
	var pre_f := _ric(f, 0)
	Effects.apply_on_activate(f, 0, 2)
	_eq("Banchina su fiume: +1 oro", _ric(f, 0), [pre_f[0], pre_f[1] + 1] as Array[int])
	var g := _scena()                            # tutto pianura
	var hg := _put(g, civ, 2)
	hg.upgrades.append("po_banchina")
	var pre_g := _ric(g, 0)
	Effects.apply_on_activate(g, 0, 2)
	_eq("  fuori dal fiume → nulla", _ric(g, 0), pre_g)

	# Console: "+1 oro quando attivi una colonna con un tuo strato Civico (max 2)"
	var h := _scena()
	_put(h, civ, 4)
	h.players[0].specialized_characters = ["pe_console"] as Array[String]
	var pre_h := _ric(h, 0)
	for i in 4: Effects.apply_on_activate(h, 0, 4)
	_eq("Console: il tetto di 2 oro per era regge", _ric(h, 0), [pre_h[0], pre_h[1] + 2] as Array[int])
	var i2 := _scena()
	_put(i2, _card_of_class("militare"), 4)
	i2.players[0].specialized_characters = ["pe_console"] as Array[String]
	var pre_i := _ric(i2, 0)
	Effects.apply_on_activate(i2, 0, 4)
	_eq("  senza un Civico in colonna → nulla", _ric(i2, 0), pre_i)

	# Mercante: scatta quando attiva un AVVERSARIO
	var j := _scena()
	var mio := _put(j, civ, 3)
	mio.owner = 0
	j.players[0].specialized_characters = ["pe_mercante"] as Array[String]
	var pre_j := _ric(j, 0)
	Effects.apply_on_activate(j, 1, 3)           # attiva il giocatore 1
	_eq("Mercante: +1 oro quando attiva un avversario", _ric(j, 0), [pre_j[0], pre_j[1] + 1] as Array[int])
	var k := _scena()
	var mio2 := _put(k, civ, 3)
	mio2.owner = 0
	k.players[0].specialized_characters = ["pe_mercante"] as Array[String]
	var pre_k := _ric(k, 0)
	Effects.apply_on_activate(k, 0, 3)           # attiva il proprietario
	_eq("  ma non quando attiva lui stesso", _ric(k, 0), pre_k)

	# Cronista: "+1 cultura se la colonna ha edifici di 3+ ere diverse"
	var l := _scena()
	for era in [1, 2, 3]:
		var b2 := _put(l, civ, 2)
		b2.era_built = era
	l.players[0].specialized_characters = ["pe_cronista"] as Array[String]
	var vp0: int = l.players[0].vp
	Effects.apply_on_activate(l, 0, 2)
	_eq("Cronista: 3 ere diverse in colonna → +1 cultura", l.players[0].vp, vp0 + 1)
	var m := _scena()
	for era2 in [1, 1]:
		var b3 := _put(m, civ, 2)
		b3.era_built = era2
	m.players[0].specialized_characters = ["pe_cronista"] as Array[String]
	var vp1: int = m.players[0].vp
	Effects.apply_on_activate(m, 0, 2)
	_eq("  con 2 ere soltanto → nulla", m.players[0].vp, vp1)

	# e arriva davvero attraverso EraRules.activate, non solo chiamando il motore
	var n := _scena()
	_put(n, "ed_ospedale_dei_pellegrini", 1)
	var pre_n := _ric(n, 0)
	EraRules.activate(n, 0, 1)
	_ok("l'attivazione vera include l'effetto", n.players[0].oro > pre_n[1])


# ---- lavoratore ed edificio protetto ---------------------------------
# Prepara un turno reale: colonna con un edificio della classe voluta, gia'
# intatto e del giocatore di turno, e il personaggio disponibile nella fila.
func _turno_con(cid: String) -> Array:
	var ctl := _game()
	var gs := ctl.gs
	_flat(gs, Enums.Terrain.PIANURA)
	var cls: String = CardDB.characters[cid]["class"]
	var b := _put(gs, _card_of_class(cls), 2)
	b.owner = gs.current_index
	gs.char_row = [cid]
	gs.char_decks[gs.era] = []
	return [ctl, gs, b]

func _test_protection() -> void:
	var base := int(CardDB.constants["protection_bonus"])

	# abitare un proprio edificio: +2 e il legame registrato
	var a := _turno_con("pe_legionario")
	var ctl: GameController = a[0]
	var gs: GameState = a[1]
	var b: Building = a[2]
	_ok("lavoratore piazzato sull'edificio", ctl.place_worker(2, b))
	_eq("  protezione +%d" % base, b.protection, base)
	_eq("  e l'edificio sa chi lo abita", b.protected_by, gs.current_index)

	# edificio altrui: niente protezione
	var c := _turno_con("pe_legionario")
	var ctl2: GameController = c[0]
	var gs2: GameState = c[1]
	var b2: Building = c[2]
	b2.owner = (gs2.current_index + 1) % gs2.n_players
	ctl2.place_worker(2, b2)
	_eq("un edificio altrui non si abita", b2.protection, 0)

	# edificio in un'altra colonna: niente protezione
	var d := _turno_con("pe_legionario")
	var ctl3: GameController = d[0]
	var gs3: GameState = d[1]
	var lontano := _put(gs3, _card_of_class("civico"), 5)
	lontano.owner = gs3.current_index
	ctl3.place_worker(2, lontano)
	_eq("un edificio di un'altra colonna non si abita", lontano.protection, 0)

	# Legionario: "la sua protezione vale +3 invece di +2"
	var e2 := _turno_con("pe_legionario")
	var ctl4: GameController = e2[0]
	var gs4: GameState = e2[1]
	var b4: Building = e2[2]
	ctl4.place_worker(2, b4)
	gs4.current_player().oro = 9
	_ok("Legionario reclutato", ctl4.recruit("pe_legionario"))
	_eq("  la protezione sale a %d" % (base + 1), b4.protection, base + 1)

	# Cavaliere: +4 invece di +2
	var f := _turno_con("pe_cavaliere")
	var ctl5: GameController = f[0]
	var gs5: GameState = f[1]
	var b5: Building = f[2]
	ctl5.place_worker(2, b5)
	gs5.current_player().oro = 9
	_ok("Cavaliere reclutato", ctl5.recruit("pe_cavaliere"))
	_eq("  la protezione sale a %d" % (base + 2), b5.protection, base + 2)

	# Capotribu: "+1 res all'edificio protetto da questo lavoratore"
	var g := _turno_con("pe_capotribu")
	var ctl6: GameController = g[0]
	var gs6: GameState = g[1]
	var b6: Building = g[2]
	ctl6.place_worker(2, b6)
	gs6.current_player().oro = 9
	_ok("Capotribu reclutato", ctl6.recruit("pe_capotribu"))
	_eq("  +1 solo all'edificio abitato", b6.protection, base + 1)

	# "se l'edificio protetto sopravvive all'evento, +1 cultura"
	var h := _turno_con("pe_legionario")
	var ctl7: GameController = h[0]
	var gs7: GameState = h[1]
	var b7: Building = h[2]
	ctl7.place_worker(2, b7)
	gs7.current_player().oro = 9
	ctl7.recruit("pe_legionario")
	var pl: PlayerState = gs7.players[gs7.players.size() - 1]
	for p2 in gs7.players:
		if p2.character_targets.has("pe_legionario"): pl = p2
	var vp0: int = pl.vp
	Effects.apply_era_end_characters(gs7)
	_eq("Legionario: l'edificio ha retto → +1 cultura", pl.vp, vp0 + 1)

	var i2 := _turno_con("pe_legionario")
	var ctl8: GameController = i2[0]
	var gs8: GameState = i2[1]
	var b8: Building = i2[2]
	ctl8.place_worker(2, b8)
	gs8.current_player().oro = 9
	ctl8.recruit("pe_legionario")
	var pl2: PlayerState = gs8.players[0]
	for p3 in gs8.players:
		if p3.character_targets.has("pe_legionario"): pl2 = p3
	b8.state = Enums.BuildingState.RUDERE      # l'evento lo ha ferito
	var vp1: int = pl2.vp
	Effects.apply_era_end_characters(gs8)
	_eq("  ridotto a rudere → nessuna cultura", pl2.vp, vp1)

	# il selettore "non protetto" ora discrimina davvero
	var j := _scena()
	_set_event(j, "ev_migrazione")             # "Edifici non protetti: -1 res extra"
	var nudo := _put(j, _card_of_class("civico"), 1)
	var abitato := _put(j, _card_of_class("civico"), 3)
	abitato.protection = base
	_eq("evento sui non protetti: colpisce il nudo", Effects.event_resistance_modifier(j, nudo), -1)
	_eq("  risparmia quello abitato", Effects.event_resistance_modifier(j, abitato), 0)


# ---- Impronte ---------------------------------------------------------
func _turno_impronta(cid: String) -> Array:
	var ctl := _game()
	var gs := ctl.gs
	_flat(gs, Enums.Terrain.PIANURA)
	var cls: String = CardDB.characters[cid]["class"]
	var b := _put(gs, _card_of_class(cls), 2)     # soddisfa la classe richiesta
	b.owner = gs.current_index
	gs.char_row = [cid]
	gs.char_decks[gs.era] = []
	ctl.place_worker(2, b)
	gs.current_player().oro = 9
	return [ctl, gs, b]

func _test_imprints() -> void:
	# Incisore: Scavo +3 sull'edificio scelto, e solo su quello
	var a := _turno_impronta("pe_incisore")
	var ctl: GameController = a[0]
	var gs: GameState = a[1]
	var b: Building = a[2]
	var altro := _put(gs, _card_of_class("civico"), 5)
	altro.owner = gs.current_index
	var s0 := b.scavo_value()
	var s_altro := altro.scavo_value()
	_ok("Incisore posato sull'edificio scelto", ctl.recruit("pe_incisore", b))
	_eq("  Scavo +3 sul bersaglio", b.scavo_value(), s0 + 3)
	_eq("  nessun altro edificio e' toccato", altro.scavo_value(), s_altro)
	_eq("  l'edificio registra l'Impronta", b.imprint, "pe_incisore")

	# Retore: +5, ma solo su edificio Cultura
	var c := _turno_impronta("pe_retore")
	var ctl2: GameController = c[0]
	var gs2: GameState = c[1]
	var b2: Building = c[2]
	var s1 := b2.scavo_value()
	_ok("Retore su edificio Cultura", ctl2.recruit("pe_retore", b2))
	_eq("  Scavo +5", b2.scavo_value(), s1 + 5)

	var d := _turno_impronta("pe_retore")
	var ctl3: GameController = d[0]
	var gs3: GameState = d[1]
	var non_cult := _put(gs3, _card_of_class("militare"), 4)
	non_cult.owner = gs3.current_index
	_ok("Retore rifiutato su edificio non Cultura", not ctl3.recruit("pe_retore", non_cult))

	# senza bersaglio, e su edificio altrui
	var e2 := _turno_impronta("pe_incisore")
	var ctl4: GameController = e2[0]
	_ok("Impronta senza bersaglio: rifiutata", not ctl4.recruit("pe_incisore"))
	var f := _turno_impronta("pe_incisore")
	var ctl5: GameController = f[0]
	var gs5: GameState = f[1]
	var altrui := _put(gs5, _card_of_class("cultura"), 4)
	altrui.owner = (gs5.current_index + 1) % gs5.n_players
	_ok("Impronta su edificio altrui: rifiutata", not ctl5.recruit("pe_incisore", altrui))

	# "Un edificio puo' portarne una sola"
	var g := _turno_impronta("pe_incisore")
	var ctl6: GameController = g[0]
	var gs6: GameState = g[1]
	var b6: Building = g[2]
	ctl6.recruit("pe_incisore", b6)
	var q := ActionRules.quote_recruit(gs6, b6.owner, "pe_incisore", 2, b6)
	_ok("un secondo Impronta sullo stesso edificio: rifiutato", not q.legal, q.reason)

	# la carta e' gia' sotto l'edificio: non va sepolta di nuovo come scheletro
	var h := _turno_impronta("pe_incisore")
	var ctl7: GameController = h[0]
	var gs7: GameState = h[1]
	var b7: Building = h[2]
	var chi := gs7.current_index
	ctl7.recruit("pe_incisore", b7)
	_eq("l'Impronta non resta fra i personaggi dell'era",
		gs7.players[chi].specialized_characters, [] as Array[String])
	gs7.era = 2
	EraRules.bury_characters(gs7)
	_eq("  e quindi non diventa anche scheletro", b7.buried_character, "")

	# ma conta come reclutamento, per l'Universita'
	_eq("  conta comunque come personaggio reclutato",
		gs7.players[chi].recruited_total, 1)
