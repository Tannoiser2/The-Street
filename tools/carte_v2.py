#!/usr/bin/env python3
"""Il documento unico delle carte della v2: docs/carte-v2.md.

    python3 tools/carte_v2.py

Per ogni carta c'e' TUTTO quello che serve per rifarla: i numeri vengono da
`data/cards-v2.json` (che e' quello che gioca il motore), i testi sono quelli
di oggi dove restano validi e il testo nuovo proposto dove la v2 li cambia,
con il motivo. Un documento solo, per decisione del designer: se una carta
cambia, si cambia qui. I numeri pero' li legge il motore dal JSON, quindi un
cambio deciso qui va portato nel JSON (`tools/genera_cards_v2.py` per i
costi e le tessere) e il documento si rigenera.

I PDF in `materiali/` servono solo per la grafica: i dati non si leggono da li'.
"""
import json, os, collections

RADICE = os.path.join(os.path.dirname(__file__), "..")
V2 = json.load(open(os.path.join(RADICE, "data/cards-v2.json"), encoding="utf-8"))
V1 = json.load(open(os.path.join(RADICE, "data/cards.json"), encoding="utf-8"))
K = V2["constants"]

# ---- le sigle del motivo ------------------------------------------------
SIGLE = [
    ("3R", "tre risorse: il costo o l'effetto nomina pietra/oro dove ora ci sono Costruzione, Denaro e Idee"),
    ("RUD", "nomina il rudere, il restauro del rudere, la spoliazione o la Vetustà come oggi"),
    ("LAV", "presuppone il lavoratore sulla colonna: \"abiti qui\", \"questo lavoratore\""),
    ("DRA", "presuppone il reclutamento come azione (classe nella colonna, 1 oro) invece del draft"),
    ("TES", "presuppone le tessere di oggi (abilità permanente, mix fisso)"),
    ("CUL", "dice \"cultura\" per i punti: con le Idee come risorsa la parola va cambiata (proposta: \"PV\")"),
]

# ---- i testi nuovi proposti, carta per carta (id -> (testo v2, sigle, nota)) --
# Dove la carta non e' qui, il testo di oggi resta valido cosi' com'e'.
TESTI = {
    # edifici
    "ed_focolare_comune": ("Quartiere: +1 Costruzione quando lo attivi.", "LAV 3R",
        "\"quando abiti qui\": il lavoratore sta sulla colonna, quindi \"quando attivi la colonna\""),
    "ed_acquedotto": ("Colossale: 2 slot adiacenti (3 pagando +1 Costruzione; in 2 giocatori il terzo slot è vietato), almeno uno con fiume. Eco: +2 PV (lampo) se ancora in piedi nel Moderno.", "3R", ""),
    "ed_ospedale_dei_pellegrini": ("Quando lo attivi, +1 Denaro.", "LAV 3R", ""),
    "ed_bottega_dartista": ("I tuoi potenziamenti costano 1 in meno, nella loro risorsa.", "3R",
        "i potenziamenti pagano per famiglia: Arte in Idee, Struttura in Costruzione, il resto in Denaro"),
    "ed_palazzo_signorile": (None, "3R", "produce 1 Idea al posto di 1 cultura (già nel file v2)"),
    "ed_universita": ("+1 PV per ogni tuo Personaggio preso nel draft. Richiede livello 1+.", "DRA", ""),
    "ed_abbazia": (None, "", "Rendita 3 → 2 (registro 97: le carte care)"),
    "ed_castello": (None, "", "Rendita 3 → 2 (registro 97)"),
    "ed_fortezza_bastionata": (None, "", "Rendita 3 → 2 (registro 97)"),
    "ed_ponte_monumentale": (None, "", "Rendita 3 → 2 (registro 97)"),
    "ed_duomo": (None, "", "Rendita 4 → 2 (registro 97)"),
    "ed_insulae": (None, "", "Lampo 1 → 2 (registro 100)"),
    "ed_emporio": (None, "", "Lampo 1 → 2 (registro 100)"),
    "ed_borgo": (None, "", "Lampo 2 → 3 (registro 100)"),
    "ed_torre_civica": (None, "", "Lampo 2 → 3 (registro 100)"),
    "ed_loggia": (None, "", "Lampo 2 → 3 (registro 100)"),
    "ed_banco": (None, "", "Lampo 2 → 3 (registro 100)"),
    "ed_condominio": (None, "", "resta: si costruisce sopra le rovine con lo sconto di metà resistenza (punto 10); Lampo 2 → 3 (registro 100)"),
    "ed_officina": (None, "", "Lampo 2 → 3 (registro 100)"),
    # personaggi
    "pe_capotribu": ("Subito: +2 Costruzione. Per l'era: il primo edificio che costruisci ha +1 res.", "LAV 3R",
        "è così nel motore: senza lavoratore che abita, il protettore si lega al primo edificio costruito nell'era"),
    "pe_legionario": ("Per l'era: il primo edificio che costruisci ha +1 res; se sopravvive all'evento, +1 PV.", "LAV CUL",
        "oggi \"la sua protezione vale +3 invece di +2\": il +2 del lavoratore sulla colonna resta, questo è il +1 in più"),
    "pe_cavaliere": ("Per l'era: il primo edificio che costruisci ha +2 res; se sopravvive all'evento, +1 PV.", "LAV CUL", ""),
    "pe_incisore": ("Impronta: infila questa carta sotto il primo edificio che costruisci in quest'era; Scavo +3 permanente. Max 1 impronta per edificio.", "DRA",
        "a inizio era 1 nessuno ha edifici: nel draft la carta si offre solo a chi ha un edificio, quindi va riscritta"),
    "pe_retore": ("Impronta: infila questa carta sotto il primo edificio Cultura che costruisci in quest'era; Scavo +5 permanente. Max 1 impronta per edificio.", "DRA", "come l'Incisore"),
    "pe_mercante_di_ossidiana": ("Subito: +1 Denaro. Per l'era: fino a 2 scambi alla pari fra due risorse qualsiasi.", "3R", ""),
    "pe_costruttore_di_zattere": ("Subito: +1 Costruzione. Per l'era: −1 Costruzione alle costruzioni su slot con fiume.", "3R", ""),
    "pe_architetto": ("Subito: +1 Costruzione. Per l'era: −1 Costruzione agli edifici da 2 o 3 caselle.", "3R", ""),
    "pe_mastro_costruttore": ("Subito: +1 Costruzione. Per l'era: la tua prima costruzione ha +1 res permanente.", "3R",
        "\"puoi costruire in qualsiasi slot\" non serve più: i binari sono liberi"),
    "pe_sacerdotessa": ("Subito: +1 Denaro. Per l'era: il primo edificio Religione che costruisci ti rimborsa 1 Idea.", "3R",
        "Religione paga Idee: il rimborso va nella risorsa che paga"),
    "pe_console": ("Subito: +1 Denaro. Per l'era: quando attivi una colonna con un tuo strato Civico, +1 Denaro (max 2).", "3R", ""),
    "pe_vescovo": ("Subito: il prossimo potenziamento su un tuo edificio Religione in quest'era costa 0. Per l'era: capienza dei tuoi Religione +1.", "", "resta: vale nella risorsa del potenziamento"),
    "pe_mercante": ("Subito: +1 Denaro. Per l'era: quando un avversario attiva una colonna con tuoi strati visibili, +1 Denaro (max 2).", "3R", ""),
    "pe_cronista": ("Subito: se la colonna contiene edifici di 3+ ere diverse, +1 PV. Per l'era: quando attivi una colonna che contiene edifici di 3+ ere diverse (in qualsiasi condizione), +1 PV (max 2 ulteriori).", "CUL", ""),
    "pe_mecenate": ("Subito: +1 PV. Per l'era: i potenziamenti Arte che acquisti valgono +1 PV.", "CUL", ""),
    "pe_banchiere": ("Subito: +3 Denaro.", "3R", ""),
    "pe_cardinale": ("Subito: +1 Denaro. Per l'era: −1 Idea agli edifici Religione (minimo 0).", "3R", "Religione paga Idee"),
    "pe_artista_di_corte": ("Subito: +1 PV. Per l'era: il primo potenziamento che piazzi su un edificio altrui è gratis e incassi 1 Denaro dal proprietario.", "3R CUL", ""),
    "pe_industriale": ("Subito: +2 Denaro. Per l'era: le tue prime 2 produzioni di Denaro danno +1.", "3R", ""),
    "pe_dinastia": ("Sempre disponibile, fuori dal draft, al posto dell'azione. Costo in Idee: era 1 = 4 · era 2 = 3 · era 3 = 3 · era 4 = 3. Nessuna abilità: aggiunge un quinto lavoratore, permanente e attivo da subito. Massimo una a testa.", "3R",
        "con quattro lavoratori di base (registro 94) è il quinto"),
    # potenziamenti
    "po_granaio_comune": ("Quando attivi questo edificio, +1 Costruzione.", "LAV 3R", ""),
    "po_banchina": ("Solo su slot fiume: quando attivi questo edificio, +1 Denaro.", "LAV 3R", ""),
    "po_boutique": ("Quando attivi questo edificio, +2 Denaro.", "LAV 3R", ""),
    # eventi
    "ev_inverno_lungo": ("Forza 2. Edifici su bosco e collina: −1 res. Tutti i giocatori perdono 1 Costruzione.", "3R", ""),
    "ev_migrazione": (None, "LAV", "\"non protetti\" resta: protegge il lavoratore messo sopra un proprio edificio in piedi, come oggi"),
    "ev_invasione": (None, "LAV", "come Migrazione"),
    "ev_carestia_primitiva": (None, "LAV", "come Migrazione"),
    "ev_secolarizzazioni": ("Forza 5. Religione −2 res · durante l'era, ristrutturare una propria rovina Religione non costa risorse (richiede comunque l'azione).", "RUD", ""),
    "ev_speculazione_edilizia": (None, "RUD", "registro 99: senza Vetustà non colpiva nessuno, ora colpisce chi ha costruito sopra il costruito (nel file v2)"),
    "ev_anni_della_fame": (None, "", "resta: i round ci sono ancora (quattro lavoratori, quattro giri)"),
    # monumenti
    "mo_colosseo": (None, "RUD", "registro 99: contava la Vetustà 3, ora premia l'edificio che resiste per costruzione (nel file v2)"),
    "mo_pantheon": ("Primo ad avere un edificio dell'era 1 o 2 ancora attivo all'inizio dell'era Moderna.", "RUD", ""),
    "mo_cloaca_massima": ("Primo ad aver speso almeno 3 Costruzione complessive in costi di terrapieno.", "3R", ""),
    "mo_acropoli": (None, "", "resta: i livelli restano, la Verticalità no"),
    # eredita'
    "er_il_guardiano": ("un tuo edificio attivo costruito nell'era 1 o 2.", "RUD", ""),
    "er_il_silvicoltore": (None, "RUD TES", "registro 99: contava la Vetustà 3, ora è il vecchio del bosco (nel file v2)"),
    "er_il_restauratore": ("hai ristrutturato 2+ tue rovine.", "RUD", ""),
    "er_il_verticalista": (None, "", "resta: il nome ricorda un canale che non c'è più, la condizione vale"),
    "er_il_demolitore": (None, "", "resta: lo spianato è il terrapieno della v2 (registro 87)"),
}

# Le tessere: la curva e la regola stanno nel JSON (registro 100); qui solo
# cos'era la regola nella v1.5.
TESSERE_OGGI = {
    "pianura": "−1 pietra permanente agli edifici da 2 o 3 caselle",
    "fiume":   "\"unico terreno che produce oro\" (1 pietra 1 oro)",
    "collina": "+1 res permanente a ogni edificio costruito qui",
    "bosco":   "Vetustà massima +4 (la Vetustà non c'è più) e restauro −1 pietra",
}

NOME_RIS = {"pietra": "C", "oro": "D", "idee": "I"}
NOME_TER = {"pianura": "Pianura", "fiume": "Fiume", "collina": "Collina", "bosco": "Bosco", None: "qualsiasi"}

out = []
w = out.append

def costo(c):
    return "/".join(str(int(c.get(k, 0))) for k in ("pietra", "oro", "idee"))

def produzione(pr):
    pezzi = [f"{int(v)} {NOME_RIS[k]}" for k, v in pr.items() if k in NOME_RIS and int(v)]
    return " + ".join(pezzi) if pezzi else "—"

V1_PER_ID = {c["id"]: c for sez in ("buildings", "characters", "upgrades", "events", "monuments", "legacies") for c in V1[sez]}

def testo_e_nota(c, campo="effect_text"):
    # "oggi" e' il testo della v1.5; il testo della v2 e' quello del file v2,
    # o la proposta in TESTI se il file v2 non e' ancora cambiato.
    oggi = (V1_PER_ID.get(c["id"], c).get(campo) or "").strip()
    nuovo, sigle, nota = TESTI.get(c["id"], (None, "", ""))
    if not nuovo:
        nel_v2 = (c.get(campo) or "").strip()
        if nel_v2 != oggi: nuovo = nel_v2
    testo = nuovo if nuovo else oggi
    if nuovo and nuovo != oggi:
        testo = f"**{nuovo}**"
        nota = (f"oggi: \"{oggi.rstrip('.')}\"" if oggi else "") + (" — " if oggi and nota else "") + nota
    return testo or "—", sigle, nota

def cella(s):
    return s.replace("|", "\\|").replace("\n", " ")

w("# Le carte della v2, tutte in un documento")
w("")
w("> Generato da `tools/carte_v2.py` da `data/cards-v2.json` (i numeri che gioca il motore) e")
w("> `data/cards.json` (i testi di oggi). Per ogni carta c'è tutto quello che serve per rifarla:")
w("> numeri, testo, e dove la v2 cambia il testo, **il testo nuovo in grassetto** con il motivo.")
w("> È l'unico documento delle carte: se una carta cambia, si cambia qui e nel JSON, e il")
w("> documento si rigenera. I PDF in `materiali/` servono solo per la grafica.")
w("")
w("Le regole della v2 che i testi presuppongono (registro 87-94): tre risorse, Costruzione (C),")
w("Denaro (D), Idee (I); tre stati, attivo, rovina, sotterrato, niente rudere; niente Verticalità,")
w("premio di scavo S×L a chi costruisce sopra, dimezzato nell'era 5; quattro lavoratori che")
w("attivano la colonna e poi agiscono; il Personaggio preso a inizio era nel draft, gratis, e non")
w("seppellito; niente Vetustà;")
w("le tessere pescate a caso, che producono per era; tetto 3 per risorsa e 5 in tutto alla")
w("dispersione. Costanti: " + ", ".join(f"`{k}` {K[k]}" for k in (
    "workers_base", "resource_cap", "resource_cap_per_resource", "protection_bonus", "rovina_gap",
    "market_size", "side_rows", "terrapieno_cost_pietra")) + ".")
w("")
w("Sigle del motivo di un cambio:")
w("")
w("| sigla | perché |")
w("|---|---|")
for s, d in SIGLE: w(f"| **{s}** | {d} |")
w("")

# ---- edifici ------------------------------------------------------------
w("## I %d edifici" % len(V2["buildings"]))
w("")
w("Ogni edificio è una sagoma unica (punto 2 della proposta): costo, produzione, resistenza,")
w("Rendita, Lampo e Scavo stanno sulla sagoma, che ruotata mostra il lato rovina con lo Scavo.")
w("Costo e produzione in C/D/I. \"Slot\" è la larghezza; \"liv.\" il livello minimo a cui va")
w("costruito; \"esaur.\" quante attivazioni produce prima di esaurirsi (la Cava). Classi e terreno")
w("richiesto sono quelli di oggi.")
w("")
riserva = [b for b in V2["buildings"] if b.get("riserva")]
if riserva:
    w("### Le case della riserva (registro 116)")
    w("")
    w("Le %d case (tre per era: la piccola, la grande e quella con lo Scavo) non stanno nel mazzo dell'era:" % len(riserva))
    w("sono **sempre disponibili**, tutte scoperte accanto al mercato, in %d copie ciascuna, e si" % riserva[0].get("copie", 1))
    w("comprano come dal mercato; a fine era le copie avanzate si scartano con le file. Non producono")
    w("e non rendono: danno Lampo (la piccola 1, la grande 2, 3 nelle ere 4-5) o Scavo (Ripari, Tuguri,")
    w("Casupole, Case popolari, Case operaie: 2). Classe civico, nessun terreno richiesto. Nelle tabelle")
    w("portano la sigla **RIS**.")
    w("")
w("### Da dove vengono i costi")
w("")
w("Dalle regole di `tools/proponi_costi_v2.py` (registro 90), che scrive `data/proposte/costi-tre-risorse.json`:")
w("")
for r in [
    "Costruzione = la pietra di oggi, Denaro = l'oro di oggi; le Idee **sostituiscono**, il totale di ogni carta resta uguale.",
    "Cultura paga in Idee: 1 al posto di 1 Costruzione nelle ere 1-2, al posto di 1 Denaro nelle ere 3-5; una seconda al posto di un secondo Denaro nelle ere 4-5.",
    "Religione paga 1 Idea al posto di 1 Costruzione nelle ere 1-2 e al posto di 1 Denaro nelle ere 3-5.",
    "Ingegneria paga 1 Idea al posto di 1 Denaro dall'era 2 in poi.",
    "Militare, Commercio e Civico non pagano Idee, salvo la regola dell'esplosione.",
    "Una carta a doppia classe segue la classe che chiede Idee, una volta sola; se la risorsa da sostituire manca, si sostituisce Costruzione.",
    "Chi oggi produce Cultura produce Idee.",
    "Nelle ere 4-5 ogni carta paga almeno un'Idea (l'esplosione delle Idee: \"15 e 18\"); l'era 3 è il periodo oscuro, le Idee calano.",
]:
    w(f"- {r}")
w("")
tot = collections.defaultdict(collections.Counter)
for b in V2["buildings"]:
    for k in ("pietra", "oro", "idee"): tot[b["era"]][k] += int(b["cost"].get(k, 0))
w("Domanda per era (C / D / I): " + " · ".join(
    f"era {e}: {tot[e]['pietra']} / {tot[e]['oro']} / {tot[e]['idee']}" for e in range(1, 6)) + ".")
w("")
for era in range(1, 6):
    w(f"### Era {era}")
    w("")
    w("| edificio | classi | terreno | slot | costo C/D/I | res | Rendita | Lampo | Scavo | produce | liv. | esaur. | testo | motivo | nota |")
    w("|---|---|---|--:|--:|--:|--:|--:|--:|---|--:|--:|---|---|---|")
    for b in sorted([b for b in V2["buildings"] if b["era"] == era], key=lambda b: b["name"]):
        testo, sigle, nota = testo_e_nota(b)
        if b.get("riserva"):
            sigle = ("RIS x%d" % b.get("copie", 1)) if not sigle else sigle + ", RIS x%d" % b.get("copie", 1)
            nota = nota or "nuova: in riserva, sempre disponibile; niente lato di oggi"
        w("| %s | %s | %s | %d | %s | %d | %d | %d | %d | %s | %d | %s | %s | %s | %s |" % (
            b["name"], ", ".join(b["classes"]), NOME_TER.get(b.get("terrain")), b["width"], costo(b["cost"]),
            b["resistance"], b["rendita"], b["lampo"], b["scavo"], produzione(b["production"]),
            b["level_required"], b.get("exhaustible") or "—", cella(testo), sigle, cella(nota)))
    w("")

# ---- tessere -------------------------------------------------------------
w("## Le tessere terreno")
w("")
w("Si pescano a caso (punto 6); il mix garantisce il bosco: " + "; ".join(
    f"{n} giocatori " + ", ".join(f"{v} {k}" for k, v in m.items()) for n, m in K["terrain_mix_by_players"].items()) + ".")
w("Ogni tessera produce per tipo, con una curva per era, a chi la attiva, e ha un effetto che")
w("scatta **una volta per era** alla prima occasione, poi la tessera si gira (registro 100).")
w("")
w("| tessera | era 1 | era 2 | era 3 | era 4 | era 5 | regola (nel file v2) | oggi |")
w("|---|---|---|---|---|---|---|---|")
for t in V2["terrains"]:
    curva = [produzione(t["base_production_by_era"][str(e)]) for e in range(1, 6)]
    w(f"| {NOME_TER[t['id']]} | " + " | ".join(curva) + f" | {t['rule']} | {TESSERE_OGGI[t['id']]} |")
w("")

# ---- personaggi ----------------------------------------------------------
w("## I 26 Personaggi")
w("")
w("Si prendono nel **draft** a inizio era (registro 93): in ordine di turno, uno a testa fra i")
w("cinque dell'era, gratis e senza lavoratore; gli avanzi si scartano a fine era. Niente classe")
w("richiesta nella colonna, niente costo: la classe resta stampata come informazione. A fine era")
w("il Personaggio si scarta: **non si seppellisce** (registro 95); lo scheletro lo lascia il")
w("lavoratore del potenziamento.")
w("")
w("| era | Personaggio | classe | quando | testo | motivo | nota |")
w("|--:|---|---|---|---|---|---|")
for c in V2["characters"]:
    testo, sigle, nota = testo_e_nota(c)
    w("| %s | %s | %s | %s | %s | %s | %s |" % (
        c.get("era") or "—", c["name"], c["class"], c.get("timing", ""), cella(testo), sigle, cella(nota)))
w("")

# ---- potenziamenti -------------------------------------------------------
w("## I 25 potenziamenti")
w("")
w("Si paga nella risorsa della famiglia (registro 91): Arte in Idee, Struttura in Costruzione, il")
w("resto in Denaro; importi di oggi (1 nelle ere 1-3, 2 nelle ere 4-5). Il lavoratore che lo")
w("piazza resta sotto l'edificio come scheletro (punto 8, registri 95-96): uno per edificio, non")
w("nell'era Moderna, vale 6 meno l'era comunque finisca l'edificio. Sulla sagoma serve il posto.")
w("")
w("| era | potenziamento | famiglia | costo C/D/I | testo | motivo | nota |")
w("|--:|---|---|--:|---|---|---|")
for u in V2["upgrades"]:
    testo, sigle, nota = testo_e_nota(u)
    w("| %d | %s | %s | %s | %s | %s | %s |" % (
        u["era"], u["name"], u["family"], costo(u["cost"]), cella(testo), sigle, cella(nota)))
w("")

# ---- eventi --------------------------------------------------------------
w("## I 24 eventi")
w("")
w("Uno per era nelle ere 1-4, forza 2/3/4/5; chi non regge cade in rovina con un passo solo")
w("(`rovina_gap` %d: fallire di meno resta attivo, senza Vetustà)." % K["rovina_gap"])
w("")
w("| era | evento | forza | testo | motivo | nota |")
w("|--:|---|--:|---|---|---|")
for e in V2["events"]:
    testo, sigle, nota = testo_e_nota(e)
    w("| %d | %s | %d | %s | %s | %s |" % (e["era"], e["name"], e["force"], cella(testo), sigle, cella(nota)))
w("")

# ---- monumenti e eredita' -------------------------------------------------
for titolo, sez, intro in (
    ("I 14 Monumenti", "monuments", "Se ne rivelano tanti quanti i giocatori meno uno; li prende il primo che soddisfa la condizione."),
    ("Le 16 Eredità", "legacies", "Due a testa, se ne tiene una segreta; si conta a fine partita."),
):
    w(f"## {titolo}")
    w("")
    w(intro)
    w("")
    w("| carta | PV | condizione | motivo | nota |")
    w("|---|--:|---|---|---|")
    for c in V2[sez]:
        testo, sigle, nota = testo_e_nota(c, "condition_text")
        w("| %s | %d | %s | %s | %s |" % (c["name"], c["vp"], cella(testo), sigle, cella(nota)))
    w("")

# ---- il regolamento ------------------------------------------------------
w("## Quello che non sta su una carta")
w("")
for r in [
    "**\"+1 per ogni edificio altrui sotterrato\"** (il disturbo): tolto dal designer (registro 100), non c'è più né nel regolamento né nel motore.",
    "**La Vetustà non esiste più** (registro 95): niente cubetti a chi regge l'evento, la Rendita è solo quella stampata. Colosseo, Il Silvicoltore e Speculazione edilizia la contavano e sono stati rifatti (registro 99, nel file v2); il bosco perde il +4.",
    "**\"Cultura\"**: oggi è un canale di punti e il nome di una classe; con le Idee come risorsa i punti si chiamano PV e Cultura resta la classe.",
    "**\"Protetto\"**: come oggi, il lavoratore messo sopra un proprio edificio in piedi della colonna attivata (+%d); i tre protettori del draft si legano al primo edificio costruito nell'era." % K["protection_bonus"],
    "**Reclutare** non è un'azione; **la Dinastia** resta un acquisto al posto dell'azione; **passare** è non fare l'azione dopo l'attivazione.",
    "**Gli scheletri** (registri 95-96): il Personaggio del draft non si seppellisce; lo scheletro è il lavoratore che piazza un potenziamento, che resta sotto l'edificio (uno per edificio, non nell'era Moderna) e vale 6 meno l'era **comunque finisca l'edificio**.",
]:
    w(f"- {r}")
w("")

open(os.path.join(RADICE, "docs/carte-v2.md"), "w", encoding="utf-8").write("\n".join(out) + "\n")
print("scritto docs/carte-v2.md: %d edifici, %d personaggi, %d potenziamenti, %d eventi, %d monumenti, %d eredita'" % (
    len(V2["buildings"]), len(V2["characters"]), len(V2["upgrades"]), len(V2["events"]),
    len(V2["monuments"]), len(V2["legacies"])))
