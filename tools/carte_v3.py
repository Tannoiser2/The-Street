#!/usr/bin/env python3
"""Il documento unico delle carte della v3: docs/carte-v3.md.

    python3 tools/carte_v3.py

Per ogni carta c'e' TUTTO quello che serve per rifarla: i numeri e i testi
vengono da `data/proposte/cards-v3-era1.json`, che e' quello che gioca il
motore e che `tools/genera_cards_v3.py` scrive. Un cambio deciso qui va fatto
nel generatore, poi si rigenerano il JSON e questo documento. I PDF in
`materiali/` servono solo per la grafica: i dati non si leggono da li'.
"""
import json, os, collections

RADICE = os.path.join(os.path.dirname(__file__), "..")
V3 = json.load(open(os.path.join(RADICE, "data/proposte/cards-v3-era1.json"), encoding="utf-8"))
K = V3["constants"]

NOME_RIS = {"pietra": "C", "oro": "D", "idee": "I"}
NOME_TER = {"pianura": "Pianura", "fiume": "Fiume", "collina": "Collina", "bosco": "Bosco", None: "qualsiasi"}
CLASSE = {"civico": "Civico", "religione": "Religione", "commercio": "Commercio", "cultura": "Cultura",
          "ingegneria": "Ingegneria", "militare": "Militare"}
FAMIGLIA = {"arte": "Arte", "struttura": "Struttura", "altro": "Altro"}

out = []
w = out.append

def cella(s):
    return str(s).replace("|", "\\|").replace("\n", " ")

def costo(c):
    pezzi = [f"{int(c.get(k, 0))} {NOME_RIS[k]}" for k in ("pietra", "oro", "idee") if int(c.get(k, 0))]
    return " ".join(pezzi) if pezzi else "gratis"

def produzione(pr):
    pezzi = [f"{int(pr.get(k, 0))} {NOME_RIS[k]}" for k in ("pietra", "oro", "idee") if int(pr.get(k, 0))]
    return " + ".join(pezzi) if pezzi else "—"

def caselle(b):
    w_, d = int(b["width"]), int(b.get("depth", 1))
    if w_ == 1 and d == 1: return "1"
    return f"{w_} col. x {d} bin."

def dove(b):
    if b.get("a_terra_o_sopra"): return "a terra o sopra"
    if b.get("solo_su_rovine"): return "solo sopra (rovine)"
    if int(b["level_required"]) > 0: return "solo sopra, liv. %d" % int(b["level_required"])
    return "a terra o sopra"

def classi(b):
    return ", ".join(CLASSE.get(c, c) for c in b["classes"])

w("# Le carte della v3, tutte in un documento")
w("")
w("> Generato da `tools/carte_v3.py` da `data/proposte/cards-v3-era1.json`, che è quello che gioca il")
w("> motore e che `tools/genera_cards_v3.py` scrive. Per ogni carta c'è tutto quello che serve per")
w("> rifarla: numeri e testo. Se una carta cambia, si cambia il generatore, si rigenera il JSON e si")
w("> rigenera questo documento. I PDF in `materiali/` servono solo per la grafica.")
w("")
w("Le regole della v3 che le carte presuppongono (registri 153-179, `docs/proposte/v3-metro.md`):")
w("tre risorse, Costruzione (C), Denaro (D), Idee (I), che **muoiono a fine era** (ere 1-4); i")
w("**Personaggi sono i lavoratori**: a inizio era il draft a passaggio (mano di %d, se ne tiene una, le" % int(K.get("draft_passaggio", {}).get("mano", 4)))
w("altre passano al vicino), poi ognuno piazza i suoi %d Personaggi, uno per turno, su una colonna;" % int(K.get("workers_base", 4)))
w("chi attiva incassa la tessera, poi la **produzione e l'azione del Personaggio**, poi **usa UN edificio**")
w("in piedi della colonna, suo o altrui, che resta bruciato fino a fine giro; dopo compra: un edificio,")
w("un potenziamento, o tutti e due. Catena dei costi: i terreni producono zero, spianare costa")
w("%s per casella e solo edifici di ere passate; il ⊕ apre un acquisto in più con lo sconto; lo" % K.get("spianare_costo", 1))
w("sconto senza condizione vale su quel che si compra nel turno. Costanti: " + ", ".join(
    f"`{k}` {K[k]}" for k in ("workers_base", "personaggi_per_era", "market_size", "rails", "spianare_costo",
                              "terrapieno_cost_pietra", "azione_edificio") if k in K) + ".")
w("")

# ---- edifici ------------------------------------------------------------
mazzo = [b for b in V3["buildings"] if not b.get("riserva")]
riserva = [b for b in V3["buildings"] if b.get("riserva")]
w("## I %d edifici (%d nel mazzo, %d case della riserva)" % (len(V3["buildings"]), len(mazzo), len(riserva)))
w("")
w("Ogni edificio è la sua carta distesa sulla casella (colonna x binario). Costo in C/D/I; \"caselle\"")
w("quante ne occupa; Lampo **o** Rendita, mai tutti e due (il Lampo vale il costo in Costruzione per")
w("le carte del mazzo delle ere 3-5); lo Scavo è quello stampato; \"dove\" dice se va a terra o solo")
w("sopra; l'azione la usa chi attiva la colonna (\"Usa:\"), i finali si contano a fine partita. Le case")
w("della riserva (**RIS**) sono sempre disponibili in %d copie, senza azione; la piccola si paga in" % (riserva[0].get("copie", 1) if riserva else 2))
w("Costruzione o Denaro (◈).")
w("")
tot = collections.defaultdict(collections.Counter)
for b in mazzo:
    for k in ("pietra", "oro", "idee"): tot[b["era"]][k] += int(b["cost"].get(k, 0))
w("Domanda del mazzo per era (C / D / I): " + " · ".join(
    f"era {e}: {tot[e]['pietra']} / {tot[e]['oro']} / {tot[e]['idee']}" for e in range(1, 6)) + ".")
w("")
for era in range(1, 6):
    w(f"### Era {era}")
    w("")
    w("| edificio | classi | terreno | caselle | costo | res | Lampo | Rendita | Scavo | dove | azione e finali |")
    w("|---|---|---|---|---|--:|--:|--:|--:|---|---|")
    for b in sorted([b for b in V3["buildings"] if b["era"] == era], key=lambda b: (bool(b.get("riserva")), b["name"])):
        nome = b["name"] + (" **RIS**" if b.get("riserva") else "")
        c = costo(b["cost"]) + (" ◈" if b.get("flexible") else "")
        testo = b.get("effect_text", "") or "—"
        if b.get("riserva"): testo = "—"
        w("| %s | %s | %s | %s | %s | %d | %d | %d | %d | %s | %s |" % (
            nome, classi(b), NOME_TER.get(b.get("terrain")), caselle(b), c, b["resistance"],
            b["lampo"], b["rendita"], b["scavo"], dove(b), cella(testo)))
    w("")

# ---- personaggi ----------------------------------------------------------
pers = [c for c in V3["characters"] if c.get("produzione") is not None]
w("## I %d Personaggi (%d per era)" % (len(pers), int(K.get("personaggi_per_era", 16))))
w("")
w("Sono i lavoratori. Ogni Personaggio ha una **produzione** (quel che incassi quando lo piazzi) e")
w("un'**azione** (scatta subito dopo, nella colonna attivata). Lo **Scavo** è il valore dello")
w("scheletro: a fine partita una tessera scavo con lo scheletro ritrovata vale lo Scavo del Personaggio")
w("preso in quell'era. Il ⊕ è l'acquisto in più, con lo sconto dentro.")
w("")
for era in range(1, 6):
    w(f"### Era {era}")
    w("")
    w("| Personaggio | classe | produce | Scavo | azione |")
    w("|---|---|---|--:|---|")
    for c in [c for c in pers if c.get("era") == era]:
        testo = c.get("effect_text", "")
        # il testo porta gia' "Produce ...": qui l'azione da sola
        az = testo.split(". ", 1)[1] if testo.startswith("Produce ") and ". " in testo else testo
        w("| %s | %s | %s | %s | %s |" % (c["name"], CLASSE.get(c["class"], c["class"]),
            produzione(c["produzione"]), c.get("scavo", "—"), cella(az)))
    w("")
altri = [c for c in V3["characters"] if c.get("produzione") is None]
if altri:
    w("Fuori dal draft: " + ", ".join(f"{c['name']} ({c.get('effect_text', '')})" for c in altri) + ".")
    w("")

# ---- potenziamenti -------------------------------------------------------
w("## I %d potenziamenti" % len(V3["upgrades"]))
w("")
w("Si comprano insieme a una costruzione o da soli; il costo è nella risorsa della famiglia (Arte in")
w("Idee, Struttura in Costruzione, il resto in Denaro). Lo **Scavo** del token Arte è quel che vale")
w("se un'icona arte lo ritrova a fine partita. Quando l'edificio va in rovina il token torna al")
w("proprietario.")
w("")
w("| era | potenziamento | famiglia | costo | Scavo | testo |")
w("|--:|---|---|---|--:|---|")
for u in sorted(V3["upgrades"], key=lambda u: (u["era"], u["family"], u["name"])):
    w("| %d | %s | %s | %s | %s | %s |" % (u["era"], u["name"], FAMIGLIA.get(u["family"], u["family"]),
        costo(u["cost"]), u.get("scavo", "—"), cella(u.get("effect_text", ""))))
w("")

# ---- tessere -------------------------------------------------------------
w("## Le %d tessere dell'era (%d copie ciascuna)" % (len(V3["tessere_era"]), V3["tessere_era"][0].get("copie", 1)))
w("")
w("I terreni producono zero (la catena dei costi); a ogni era si posa su ogni colonna una tessera che")
w("produce a chi attiva e ha un effetto, una volta per era. Quattro tessere dell'era 1 e quattro per")
w("era dalle 3 in su non producono: hanno l'effetto più forte.")
w("")
w("| era | tessera | produce | effetto, una volta per era |")
w("|--:|---|---|---|")
for t in sorted(V3["tessere_era"], key=lambda t: (t["era"], t["name"])):
    w("| %d | %s | %s | %s |" % (t["era"], t["name"], produzione(t["produzione"]), cella(t["testo"])))
w("")

# ---- eventi, monumenti, eredita' ---------------------------------------
w("## Gli eventi")
w("")
w("| era | evento | forza | testo |")
w("|--:|---|--:|---|")
for e in sorted(V3["events"], key=lambda e: (e["era"], e["name"])):
    w("| %d | %s | %d | %s |" % (e["era"], e["name"], e["force"], cella(e.get("effect_text", ""))))
w("")
for titolo, sez, intro in (
    ("I Monumenti", "monuments", "Se ne rivelano tanti quanti i giocatori meno uno; li prende il primo che soddisfa la condizione."),
    ("Le Eredità", "legacies", "Due a testa, se ne tiene una segreta; si conta a fine partita."),
):
    w(f"## {titolo}")
    w("")
    w(intro)
    w("")
    w("| carta | PV | condizione |")
    w("|---|--:|---|")
    for c in V3[sez]:
        w("| %s | %d | %s |" % (c["name"], c["vp"], cella(c.get("condition_text", ""))))
    w("")

open(os.path.join(RADICE, "docs/carte-v3.md"), "w", encoding="utf-8").write("\n".join(out) + "\n")
print("scritto docs/carte-v3.md: %d edifici, %d Personaggi, %d potenziamenti, %d tessere" % (
    len(V3["buildings"]), len(pers), len(V3["upgrades"]), len(V3["tessere_era"])))
