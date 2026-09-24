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
    "bosco": "Idee, in aumento con le ere. Ristrutturazione -1.",
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
# Registro 91, decisioni del designer:
# - "tetto a tre": ogni risorsa al massimo 3 alla dispersione (il totale resta 5);
v2["constants"]["resource_cap_per_resource"] = 3
# - i potenziamenti "dipende da cosa sono": Arte in Idee, Struttura in
#   Costruzione, il resto in Denaro; l'importo e' quello di oggi (1, 2 nelle ere 4-5);
RISORSA_FAMIGLIA = {"arte": "idee", "struttura": "pietra", "altro": "oro"}
for u in v2["upgrades"]:
    quanto = sum(int(v) for v in u["cost"].values())
    u["cost"] = {"pietra": 0, "oro": 0, "idee": 0}
    u["cost"][RISORSA_FAMIGLIA[u["family"]]] = quanto
# - la Dinastia si paga in Idee, stesse unita' di oggi (4 / 3 / 3 / 3);
for c in v2["characters"]:
    if c.get("is_dynasty"):
        c["cost_by_era"] = {e: {"pietra": 0, "oro": 0, "idee": int(v["pietra"]) + int(v["oro"])}
                            for e, v in c["cost_by_era"].items()}
        c["effect_text"] = c["effect_text"].split("Costo a scalare")[0] + "Costo a scalare in Idee: era 1 = 4 · era 2 = 3 · era 3 = 3 · era 4 = 3. Nessuna abilita': aggiunge un quarto lavoratore, permanente e attivo da subito. Massimo una a testa."
# - la ristrutturazione in Costruzione e Denaro: e' nel motore (ActionRules.quote_restore).
# LE REGOLE DELLA V2, decise e misurate (registro 87-91), stanno nel file v2
# come costanti: cosi' `--dati data/cards-v2.json` gioca la v2 senza manopole,
# e le manopole restano per le prove sulla v1.5.
v2["constants"]["senza_rudere"] = True                 # stati: attivo, rovina, sotterrato
v2["constants"]["rovina_gap"] = 2                      # si crolla fallendo di 2
v2["constants"]["spianare_conserva_scavo"] = False     # lo spianato vale 0 (terrapieno)
v2["constants"]["verticality_vp"] = {"1": 0, "2": 0, "3": 0, "4": 0}   # via la Verticalita'
v2["constants"]["premio_scavo"] = "per_livello"        # S x L a chi costruisce sopra
v2["constants"]["premio_era5"] = "dimezzato"           # la correzione all'ultima era
# IL TURNO (registro 94): decisione del designer dopo la misura del turno a
# un'azione (registro 93, `turno_v2`, che resta come manopola): QUATTRO
# lavoratori, e ogni lavoratore attiva la colonna e poi fa un'azione
# (costruire, potenziare, ristrutturare), come nella v1.5. Passare incassa
# 1 Costruzione piu' 1 risorsa a scelta solo nel turno a un'azione (D14).
v2["constants"]["turno_v2"] = False
v2["constants"]["workers_base"] = 4
v2["constants"]["passa_incasso_pietra"] = 1
v2["constants"]["passa_incasso_scelta"] = 1
# IL DRAFT DEI PERSONAGGI (punto 8, registro 93): a inizio era, in ordine di
# turno, uno a testa fra tutti quelli dell'era, gratis e senza lavoratore.
# Reclutare come azione sparisce.
v2["constants"]["draft_personaggi"] = True
# REGISTRO 95: il Personaggio del draft non si seppellisce a fine era (niente
# scheletri regalati), e la Vetusta' non esiste piu': il tetto a 0 la spegne
# senza toccare il motore. Colosseo, Il Silvicoltore e Speculazione edilizia
# la nominano e vanno rifatti (docs/carte-v2.md).
v2["constants"]["personaggi_sepolti"] = False
# Gli scheletri restano: "se scelgo il potenziamento il lavoratore genera uno
# scheletro" (punto 8, registro 95): 6 meno l'era se l'edificio finisce sotterrato.
v2["constants"]["scheletro_potenziamento"] = True
v2["constants"]["vetusta_max"] = 0
v2["constants"]["vetusta_max_bosco"] = 0
out = os.path.join(RADICE, "data/cards-v2.json")
json.dump(v2, open(out, "w", encoding="utf-8"), indent=2, ensure_ascii=False)
open(out, "a").write("\n")
n_idee = sum(1 for b in v2["buildings"] if b["cost"]["idee"])
print(f"scritto data/cards-v2.json: {n_idee} edifici con Idee nel costo, mix {MIX['3']} a 3 giocatori")
