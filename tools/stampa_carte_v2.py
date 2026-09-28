#!/usr/bin/env python3
"""Le carte della v2 da stampare: docs/carte-v2-da-stampare.md.

    python3 tools/stampa_carte_v2.py

Un documento solo, per decisione del designer (registro 124): tutti gli
edifici e tutti i potenziamenti, con le sole cose da scrivere sulle carte.
Niente note, niente testi delle versioni precedenti: quelli stanno in
docs/carte-v2.md. Tutto viene da data/cards-v2.json, cioe' da quello che
gioca il motore; per cambiare una carta si cambia tools/genera_cards_v2.py
e si rigenerano i due documenti.
"""
import json, os

RADICE = os.path.join(os.path.dirname(__file__), "..")
V2 = json.load(open(os.path.join(RADICE, "data/cards-v2.json"), encoding="utf-8"))
ERE = {1: "Prima era", 2: "Seconda era", 3: "Terza era", 4: "Quarta era", 5: "Quinta era"}
RISORSE = [("pietra", "Costruzione", "Costruzione"), ("oro", "Denaro", "Denaro"), ("idee", "Idea", "Idee")]

def risorse(d):
    pezzi = []
    for k, uno, tanti in RISORSE:
        n = int(d.get(k, 0))
        if n: pezzi.append(f"{n} {uno if n == 1 else tanti}")
    return ", ".join(pezzi) or "—"

def costo(c):
    return f"{c['pietra']} / {c['oro']} / {c['idee']}"

def cella(s):
    return (s or "—").replace("|", "\\|")

out = []
w = out.append
w("# Le carte della v2 da stampare")
w("")
w("> Generato da `tools/stampa_carte_v2.py` da `data/cards-v2.json`. Qui c'è solo quello che va")
w("> scritto sulle carte.")
w("")
w("Come si leggono le colonne:")
w("")
w("- **Costo** si legge Costruzione / Denaro / Idee.")
w("- **Forma** si legge colonne × binari: 1×2 è una colonna per due binari, 2×2 sono quattro caselle.")
w("- **Produzione:** risorse che l'edificio dà al proprietario ogni volta che si attiva la sua colonna.")
w("- **Rendita:** PV al proprietario a fine di ogni era, se l'edificio è in piedi.")
w("- **Lampo:** PV una volta sola, quando lo costruisci.")
w("- **Testo:** gli effetti permanenti e quelli \"A fine partita\".")
w("")
edifici = sorted(V2["buildings"], key=lambda b: (b["era"], b["name"]))
potenz = sorted(V2["upgrades"], key=lambda u: (u["era"], u["name"]))
for era in range(1, 6):
    w(f"## {ERE[era]}")
    w("")
    w(f"### Edifici")
    w("")
    w("| nome | classi | luogo | forma | costo C/D/I | produzione | resistenza | Scavo | Rendita | Lampo | testo | copie |")
    w("|---|---|---|---|--:|---|--:|--:|--:|--:|---|---|")
    for b in [x for x in edifici if x["era"] == era]:
        classi = " / ".join(c.capitalize() for c in b["classes"])
        luogo = (b["terrain"] or "qualsiasi").capitalize()
        forma = f"{b['width']}×{b.get('depth', 1)}"
        pr = {k: v for k, v in b["production"].items() if k in ("pietra", "oro", "idee")}
        extra = []
        if b.get("riserva"): extra.append("RIS")
        if int(b.get("exhaustible", 0)): extra.append(f"Esaur. {b['exhaustible']}")
        copie = str(int(b.get("copie", 1))) + (" (" + ", ".join(extra) + ")" if extra else "")
        w(f"| **{b['name']}** | {classi} | {luogo} | {forma} | {costo(b['cost'])} | {risorse(pr)} | "
          f"{b['resistance']} | {b['scavo']} | {b['rendita'] or '—'} | {b['lampo'] or '—'} | {cella(b.get('effect_text'))} | {copie} |")
    w("")
    w("### Potenziamenti")
    w("")
    w("| nome | famiglia | classe | costo | testo |")
    w("|---|---|---|---|---|")
    for u in [x for x in potenz if x["era"] == era]:
        w(f"| **{u['name']}** | {u['family'].capitalize()} | {u['class'].capitalize()} | {risorse(u['cost'])} | {cella(u.get('effect_text'))} |")
    w("")
open(os.path.join(RADICE, "docs/carte-v2-da-stampare.md"), "w", encoding="utf-8").write("\n".join(out))
print(f"scritto docs/carte-v2-da-stampare.md: {len(edifici)} edifici, {len(potenz)} potenziamenti")
