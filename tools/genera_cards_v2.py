#!/usr/bin/env python3
# Genera data/cards-v2.json: la v1.5 (data/cards.json) con i costi in tre
# risorse della proposta (data/proposte/costi-tre-risorse.json), le tessere
# che producono secondo una curva per era, e il mix di terreni che garantisce
# il bosco. Tutto il resto e' identico alla v1.5: regole, carte, eventi.
# Le regole nuove (senza rudere, premio di scavo...) restano manopole da riga
# di comando, cosi' ogni lotto dichiara esattamente cosa gioca.
#
#   python3 tools/genera_cards_v2.py
#
# Decisioni del designer (registro 90): Idee = Cultura resa risorsa; le tessere
# producono per tipo con la curva dell'audit (D4, D21), approvata cosi':
#   fiume e collina -> Costruzione 2/2/1/1/1
#   pianura         -> Denaro 0/1/1/2/2 (e 1 Costruzione nelle ere 1-2, se no
#                      nell'era 1 non produrrebbe nulla)
#   bosco           -> Idee 1/2/2/3/3
# Il mix v1.5 non ha bosco in 2 giocatori e ne ha uno in 3: senza bosco niente
# Idee, quindi il mix v2 ne garantisce almeno uno e in 3 giocatori due.
import json, os

RADICE = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..")
base = json.load(open(os.path.join(RADICE, "data/cards.json"), encoding="utf-8"))
costi = json.load(open(os.path.join(RADICE, "data/proposte/costi-tre-risorse.json"), encoding="utf-8"))
per_id = {b["id"]: b for b in costi["buildings"]}

CURVA = {
    "fiume":   {e: {"pietra": c, "oro": 0, "idee": 0} for e, c in zip("12345", [2, 2, 1, 1, 1])},
    "collina": {e: {"pietra": c, "oro": 0, "idee": 0} for e, c in zip("12345", [2, 2, 1, 1, 1])},
    "pianura": {e: {"pietra": c, "oro": d, "idee": 0} for e, c, d in zip("12345", [1, 1, 0, 0, 0], [0, 1, 1, 2, 2])},
    "bosco":   {e: {"pietra": 0, "oro": 0, "idee": i} for e, i in zip("12345", [1, 2, 2, 3, 3])},
}
REGOLE = {
    "fiume": "Costruzione, tanta all'inizio e poco dopo. Requisito 'fiume' stretto.",
    "collina": "Costruzione come il fiume, e ogni edificio costruito qui ha +1 resistenza permanente.",
    "pianura": "Denaro, poco all'inizio e molto dopo. Edifici da 2 o 3 caselle costano 1 in meno.",
    "bosco": "Idee, in aumento con le ere. Vetusta massima +4 e ristrutturazione -1.",
}
MIX = {"2": {"pianura": 2, "fiume": 1, "collina": 1, "bosco": 1},
       "3": {"pianura": 2, "fiume": 2, "collina": 1, "bosco": 2},
       "4": {"pianura": 3, "fiume": 2, "collina": 2, "bosco": 2}}

v2 = json.loads(json.dumps(base))
v2["meta"]["ruleset"] = "v2-tre-risorse"
v2["meta"]["origine"] = "generato da tools/genera_cards_v2.py: non modificare a mano"
for b in v2["buildings"]:
    c = per_id[b["id"]]["cost"]
    b["cost"] = {"pietra": c["costruzione"], "oro": c["denaro"], "idee": c["idee"]}
    p = per_id[b["id"]]["production"]
    b["production"] = {"pietra": p["costruzione"], "oro": p["denaro"], "cultura": 0, "idee": p["idee"]}
for t in v2["terrains"]:
    t["base_production_by_era"] = CURVA[t["id"]]
    t["rule"] = REGOLE[t["id"]]
v2["constants"]["terrain_mix_by_players"] = MIX
v2["constants"]["start_resources"] = {"pietra": 2, "oro": 0, "idee": 0}
out = os.path.join(RADICE, "data/cards-v2.json")
json.dump(v2, open(out, "w", encoding="utf-8"), indent=2, ensure_ascii=False)
open(out, "a").write("\n")
n_idee = sum(1 for b in v2["buildings"] if b["cost"]["idee"])
print(f"scritto data/cards-v2.json: {n_idee} edifici con Idee nel costo, mix {MIX['3']} a 3 giocatori")
