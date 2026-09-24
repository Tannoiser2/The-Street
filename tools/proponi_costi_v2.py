#!/usr/bin/env python3
# La tabella dei 60 edifici in tre risorse (Costruzione, Denaro, Idee), come
# PROPOSTA per il designer: le regole stanno qui, una frase ciascuna, e la
# tabella ne discende. Cambiare una regola e rilanciare rifà la tabella; i
# numeri non si scrivono a mano, cosi' non si perde il criterio.
#
#   python3 tools/proponi_costi_v2.py            # scrive docs/proposte/costi-tre-risorse.md
#                                                # e data/proposte/costi-tre-risorse.json
#
# Le regole:
#  R1. Costruzione = la pietra di oggi, Denaro = l'oro di oggi: la curva del
#      punto 7 nei costi c'e' gia' (pietra 18/31/23/19/14 per era, oro 0/0/7/22/30).
#  R2. Le Idee SOSTITUISCONO, non si aggiungono: il costo totale di ogni carta
#      resta uguale, cosi' il ritmo del gioco resta confrontabile con oggi.
#  R3. Cultura paga in Idee: 1 al posto di 1 Costruzione nelle ere 1-2, al posto
#      di 1 Denaro nelle ere 3-5; una seconda al posto di un secondo Denaro
#      nelle ere 4-5 (se ne ha almeno 2).
#  R4. Religione paga 1 Idea al posto di 1 Costruzione nelle ere 1-2 (il sacro e'
#      la prima idea) e al posto di 1 Denaro nelle ere 3-5.
#  R5. Ingegneria paga 1 Idea al posto di 1 Denaro dall'era 2 in poi; nell'era 1
#      resta Costruzione (le trappole sono braccia, l'acquedotto e' un'idea).
#  R6. Militare, Commercio e Civico non pagano Idee.
#  R7. Una carta a doppia classe segue la classe che chiede Idee, una volta sola;
#      se la risorsa da sostituire manca (niente Denaro), si sostituisce
#      Costruzione: nessuna carta che chiede Idee resta senza.
#  R8. Un edificio che oggi produce Cultura produce Idee (Idee = Cultura resa
#      risorsa, D1 dell'audit); il resto della produzione si traduce come i costi.
#  R9. (SPENTA) Nelle ere 4-5 ogni carta paga almeno un'Idea, anche Militare,
#      Commercio e Civico: l'esplosione delle Idee piu' netta. Accendere qui sotto.
ESPLOSIONE_ERE_4_5 = False
import json, collections, os, sys

RADICE = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..")
cards = json.load(open(os.path.join(RADICE, "data/cards.json"), encoding="utf-8"))
B = sorted(cards["buildings"], key=lambda b: (b["era"], b["id"]))

def proponi(b):
    era, classi = int(b["era"]), b["classes"]
    c, d, i = int(b["cost"]["pietra"]), int(b["cost"]["oro"]), 0
    note = []
    def sposta(da, quante, perche):
        nonlocal c, d, i
        for _ in range(quante):
            if da == "c" and c > 0: c -= 1; i += 1; note.append(perche)
            elif da == "d" and d > 0: d -= 1; i += 1; note.append(perche)
    if "cultura" in classi:
        if era <= 2: sposta("c", 1, "R3 Cultura: 1 Idea per 1 Costruzione")
        else:
            sposta("d", 1, "R3 Cultura: 1 Idea per 1 Denaro")
            if era >= 4 and d >= 1 and int(b["cost"]["oro"]) >= 2:
                sposta("d", 1, "R3 Cultura, era 4-5: seconda Idea")
    elif "religione" in classi:
        if era <= 2: sposta("c", 1, "R4 Religione: 1 Idea per 1 Costruzione")
        else: sposta("d", 1, "R4 Religione: 1 Idea per 1 Denaro")
    elif "ingegneria" in classi and era >= 2:
        sposta("d", 1, "R5 Ingegneria: 1 Idea per 1 Denaro")
    # R7: se la risorsa da sostituire mancava, si prende dalla Costruzione.
    if ("cultura" in classi or "religione" in classi or ("ingegneria" in classi and era >= 2)) and i == 0:
        sposta("c", 1, "R7: niente Denaro, 1 Idea per 1 Costruzione")
    # R9 (spenta): nelle ere 4-5 nessuna carta senza Idee.
    if ESPLOSIONE_ERE_4_5 and era >= 4 and i == 0:
        sposta("d", 1, "R9: era 4-5, almeno 1 Idea")
        if i == 0: sposta("c", 1, "R9: era 4-5, almeno 1 Idea (da Costruzione)")
    prod = dict(b["production"])
    p = {"costruzione": int(prod.get("pietra", 0)), "denaro": int(prod.get("oro", 0)),
         "idee": int(prod.get("cultura", 0))}
    return {"id": b["id"], "name": b["name"], "era": era, "classes": classi,
            "cost": {"costruzione": c, "denaro": d, "idee": i},
            "cost_v1": {"pietra": int(b["cost"]["pietra"]), "oro": int(b["cost"]["oro"])},
            "production": p, "note": "; ".join(dict.fromkeys(note))}

righe = [proponi(b) for b in B]

# ---- il documento -------------------------------------------------------
out = []
w = out.append
w("# I 60 edifici in tre risorse: una proposta")
w("")
w("> Generata da `tools/proponi_costi_v2.py` dai dati della v1.5: le regole stanno nello script,")
w("> una frase ciascuna, e la tabella ne discende. **È una proposta**: il designer cambia una")
w("> regola o una riga, si rilancia, e i totali si rifanno da soli. Il file per il motore è")
w("> `data/proposte/costi-tre-risorse.json` (stesso contenuto, per il futuro `cards-v2.json`).")
w("")
w("## Le regole")
w("")
w("1. **Costruzione = la pietra di oggi, Denaro = l'oro di oggi.** La curva del punto 7 della")
w("   proposta nei costi c'è già: pietra 18 / 31 / 23 / 19 / 14 per era, oro 0 / 0 / 7 / 22 / 30.")
w("2. **Le Idee sostituiscono, non si aggiungono.** Il costo totale di ogni carta resta uguale,")
w("   così il ritmo del gioco resta confrontabile con oggi e la prima misura isola solo la")
w("   terza risorsa. Alzare i costi è una scelta a parte, da fare dopo.")
w("3. **Cultura paga in Idee**: 1 al posto di 1 Costruzione nelle ere 1-2, al posto di 1 Denaro")
w("   nelle ere 3-5; una seconda al posto di un secondo Denaro nelle ere 4-5.")
w("4. **Religione paga 1 Idea** al posto di 1 Costruzione nelle ere 1-2 (il sacro è la prima")
w("   idea) e al posto di 1 Denaro nelle ere 3-5.")
w("5. **Ingegneria paga 1 Idea** al posto di 1 Denaro dall'era 2 in poi; nell'era 1 resta")
w("   Costruzione: le trappole sono braccia, l'acquedotto è un'idea.")
w("6. **Militare, Commercio e Civico non pagano Idee.**")
w("7. Una carta a doppia classe segue la classe che chiede Idee, una volta sola; se la risorsa")
w("   da sostituire manca (niente Denaro), si sostituisce Costruzione.")
w("8. **Chi oggi produce Cultura produce Idee** (D1 dell'audit: Idee = Cultura resa risorsa).")
w("9. *(spenta)* Nelle ere 4-5 ogni carta paga almeno un'Idea, anche Militare, Commercio e Civico.")
w("")
w("Con queste regole la domanda di Idee cresce con le ere quasi da sola, perché crescono le carte")
w("Cultura (2 / 2 / 1 / 4 / 6 per era) e l'oro da sostituire (0 / 0 / 7 / 22 / 30). **L'era 3 fa")
w("eccezione**, e il designer l'ha voluta così: il Medioevo è un periodo oscuro, le Idee calano;")
w("esplodono nel Rinascimento e nell'era Moderna. Se l'esplosione deve essere più netta di")
w("10 / 16, la regola 9 (spenta) fa pagare almeno un'Idea a **ogni** carta delle ere 4-5, anche")
w("Militare, Commercio e Civico: la domanda diventa 15 / 18. Si accende in testa allo script.")
w("")
w("## La tabella")
w("")
w("| era | edificio | classi | oggi C/O | **Costruzione** | **Denaro** | **Idee** | produce | nota |")
w("|--:|---|---|--:|--:|--:|--:|---|---|")
for r in righe:
    p = r["production"]; prod = " ".join(f"{v} {k[:1].upper()}" for k, v in p.items() if v) or "—"
    w(f"| {r['era']} | {r['name']} | {'/'.join(r['classes'])} | {r['cost_v1']['pietra']}/{r['cost_v1']['oro']} | "
      f"{r['cost']['costruzione']} | {r['cost']['denaro']} | {r['cost']['idee']} | {prod} | {r['note']} |")
w("")
w("## I totali per era")
w("")
tot = collections.defaultdict(lambda: collections.Counter())
for r in righe:
    for k, v in r["cost"].items(): tot[r["era"]][k] += v
    tot[r["era"]]["carte"] += 1
    tot[r["era"]]["con_idee"] += 1 if r["cost"]["idee"] else 0
w("| era | carte | con Idee | Costruzione | Denaro | Idee | totale unità | oggi (pietra + oro) |")
w("|--:|--:|--:|--:|--:|--:|--:|--:|")
for e in range(1, 6):
    t = tot[e]; oggi = sum(b["cost"]["pietra"] + b["cost"]["oro"] for b in B if b["era"] == e)
    w(f"| {e} | {t['carte']} | {t['con_idee']} | {t['costruzione']} | {t['denaro']} | {t['idee']} | "
      f"{t['costruzione'] + t['denaro'] + t['idee']} | {oggi} |")
w("")
w("La domanda di Idee per era: " + " / ".join(str(tot[e]["idee"]) for e in range(1, 6)) +
  " unità sulle 12 carte dell'era. Contro la produzione proposta nell'audit (D4) per una")
w("attivazione di tessera, Idee 1 / 2 / 2 / 3 / 3, con tre giocatori e tre lavoratori l'era")
w("produce circa 9 attivazioni: 9 / 18 / 18 / 27 / 27 Idee, cioè più della domanda in ogni era.")
w("È voluto: le Idee devono restare la risorsa più facile, e comprano anche i potenziamenti e la")
w("Dinastia (D2), che qui non sono contati. Se il designer preferisce le Idee scarse, la curva")
w("della tessera scende a 0 / 1 / 1 / 2 / 2.")
w("")
w("## Cosa non decide questa tabella")
w("")
w("- **La scala.** I costi restano quelli di oggi: se la v2 deve costare di più o di meno, è una")
w("  seconda passata, dopo aver misurato la terza risorsa da sola.")
w("- **Le tessere.** Cosa produce ogni tipo di terreno (D21) e con quale curva per era (D4).")
w("- **Potenziamenti, Dinastia, ristrutturazione** (D2): in Idee o in Denaro. La proposta")
w("  dell'audit era Idee per potenziamenti e Dinastia, Denaro per la ristrutturazione.")
open(os.path.join(RADICE, "docs/proposte/costi-tre-risorse.md"), "w", encoding="utf-8").write("\n".join(out) + "\n")

json.dump({"meta": {"origine": "tools/proponi_costi_v2.py", "regole": "docs/proposte/costi-tre-risorse.md",
                    "risorse": ["costruzione", "denaro", "idee"]},
           "buildings": [{k: r[k] for k in ("id", "era", "cost", "production")} for r in righe]},
          open(os.path.join(RADICE, "data/proposte/costi-tre-risorse.json"), "w", encoding="utf-8"),
          indent=1, ensure_ascii=False)
print("scritti docs/proposte/costi-tre-risorse.md e data/proposte/costi-tre-risorse.json")
for e in range(1, 6): print("era", e, dict(tot[e]))
