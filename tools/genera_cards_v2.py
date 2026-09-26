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
# LE TESSERE UNA VOLTA PER ERA (punto 6, registro 100): la produzione per era
# resta, l'abilita' permanente diventa un effetto che scatta una volta per
# era e poi la tessera si gira.
REGOLE = {
    "fiume": "Costruzione, tanta all'inizio e poco dopo. Una volta per era: +1 Denaro a chi la attiva. Requisito 'fiume' stretto.",
    "collina": "Costruzione come il fiume. Una volta per era: il primo edificio costruito qui ha +1 resistenza per l'era.",
    "pianura": "Denaro, poco all'inizio e molto dopo. Una volta per era: un edificio da 2 o 3 caselle costa 1 Costruzione in meno.",
    "bosco": "Idee, in aumento con le ere. Una volta per era: una ristrutturazione costa 1 Costruzione in meno.",
}
MIX = {"2": {"pianura": 2, "fiume": 1, "collina": 1, "bosco": 1},
       "3": {"pianura": 2, "fiume": 2, "collina": 1, "bosco": 2},
       "4": {"pianura": 3, "fiume": 2, "collina": 2, "bosco": 2}}

RENDITA_TETTO = 2
LAMPO_PIU = {"ed_insulae", "ed_emporio", "ed_borgo", "ed_torre_civica", "ed_loggia", "ed_banco",
             "ed_condominio", "ed_officina"}

v2 = json.loads(json.dumps(base))
v2["meta"]["ruleset"] = "v2-tre-risorse"
v2["meta"]["origine"] = "generato da tools/genera_cards_v2.py: non modificare a mano"
for b in v2["buildings"]:
    c = per_id[b["id"]]["cost"]
    b["cost"] = {"pietra": c["costruzione"], "oro": c["denaro"], "idee": c["idee"]}
    p = per_id[b["id"]]["production"]
    b["production"] = {"pietra": p["costruzione"], "oro": p["denaro"], "cultura": 0, "idee": p["idee"]}
    # LA RENDITA DELLE CARTE CARE (registro 97): tetto a 2. Abbazia, Castello,
    # Fortezza bastionata, Ponte monumentale (3) e Duomo (4) scendono a 2: la
    # strategia Rendita vinceva il 57% delle partite, con il tetto il 49%.
    b["rendita"] = min(int(b["rendita"]), RENDITA_TETTO)
    # IL LAMPO DI QUALCHE CARTA (registro 100): la strategia Lampo era la piu'
    # debole (27%) per la natura delle sue carte; otto carte a solo Lampo
    # salgono di 1.
    if b["id"] in LAMPO_PIU: b["lampo"] = int(b["lampo"]) + 1
# LE TRE CARTE CHE CONTAVANO LA VETUSTA' (registro 99), che nella v2 non
# esiste: il Colosseo premia l'edificio che resiste per costruzione, Il
# Silvicoltore il vecchio del bosco, Speculazione edilizia colpisce chi ha
# costruito sopra il costruito. Decisione del designer sulle proposte di
# docs/carte-v2.md. I dati v1.5 non cambiano.
TRE_CARTE = {
    "mo_colosseo": {
        "condition_text": "Primo ad avere un edificio attivo con resistenza 7 o più.",
        "condition": {"op": "count_matching", "min": 1,
                      "target": {"owner": "self", "state": ["intatto"], "buried": False, "resistance": {"min": 7}}}},
    "er_il_silvicoltore": {
        "condition_text": "un tuo edificio attivo su bosco costruito nell'era 1 o 2.",
        "condition": {"op": "count_matching", "min": 1,
                      "target": {"owner": "self", "terrain": ["bosco"], "state": ["intatto"], "buried": False,
                                 "era": {"max": 2}}}},
    "ev_speculazione_edilizia": {
        "effect_text": "Forza 5. Ogni edificio con 2+ potenziamenti: −1 res.",
        "effects": [{"hook": "on_event", "op": "resistance", "value": -1, "target": {"upgrades": {"min": 2}}}]},
}
for sezione in ("monuments", "legacies", "events"):
    for c in v2[sezione]:
        if c["id"] in TRE_CARTE: c.update(TRE_CARTE[c["id"]])
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
# Registro 96: lo scheletro conta SEMPRE, comunque finisca l'edificio (6 meno
# l'era): cosi' potenziare e' una scelta, non un resto.
v2["constants"]["scheletro_conta"] = "sempre"
# Registro 100: le tessere scattano una volta per era (REGOLE qui sopra); il
# "+1 per il disturbo" non esiste piu' (la costante sparisce da tutti e due i file).
v2["constants"]["tessere_una_volta_per_era"] = True
v2["constants"].pop("disturbo_vp", None)
v2["constants"]["vetusta_max"] = 0
v2["constants"]["vetusta_max_bosco"] = 0
# ---- le varianti di prova per la scarsita' di sagome a quattro (registro 110) --
# A quattro giocatori sedici turni per era contro dodici sagome. Due idee del
# designer, ognuna un file a parte in data/proposte/, che il file v2 non tocca:
#   --variante doppioni    per era, una seconda copia della chiesa e del villaggio
#                          piu' economici (1 casella: civico e religione, o cultura
#                          dove la religione manca);
#   --variante abitazioni  per era, due abitazioni generiche nuove, che costano
#                          poco e rendono poco.
# Le sagome in piu' portano `min_players` 4: entrano nel mazzo solo a quattro,
# come le tessere in piu'; a due e a tre il gioco non cambia.
ABITAZIONI = {
    1: ("Capanne di fango",  {"pietra": 1, "oro": 0, "idee": 0}, 1, {"pietra": 1, "oro": 0}),
    2: ("Case a schiera",    {"pietra": 1, "oro": 0, "idee": 0}, 2, {"pietra": 1, "oro": 0}),
    3: ("Case a graticcio",  {"pietra": 1, "oro": 1, "idee": 0}, 2, {"pietra": 0, "oro": 1}),
    4: ("Casa borghese",     {"pietra": 1, "oro": 0, "idee": 1}, 3, {"pietra": 0, "oro": 1}),
    5: ("Palazzina",         {"pietra": 0, "oro": 1, "idee": 1}, 3, {"pietra": 0, "oro": 1}),
}

def _costo_totale(b):
    return sum(b["cost"].values())

def _piu_economico(edifici, classe):
    # A parita' di costo vince chi produce (le Insulae, non le Terme): sono
    # "villaggi", case, non edifici pubblici.
    quali = [b for b in edifici if b["width"] == 1 and classe in b["classes"]]
    return min(quali, key=lambda b: (_costo_totale(b), -sum(b["production"].values()))) if quali else None

def doppioni(v):
    extra = []
    for era in range(1, 6):
        dell_era = [b for b in v["buildings"] if b["era"] == era]
        scelti = [_piu_economico(dell_era, "civico"),
                  _piu_economico(dell_era, "religione") or _piu_economico(dell_era, "cultura")]
        for b in scelti:
            c = json.loads(json.dumps(b))
            c["id"] = b["id"] + "_bis"
            c["name"] = b["name"] + " (II)"
            c["min_players"] = 4
            c["sagoma_di"] = b["id"]
            extra.append(c)
    v["buildings"].extend(extra)

def abitazioni(v):
    for era, (nome, costo, res, prod) in ABITAZIONI.items():
        for k in (1, 2):
            v["buildings"].append({
                "id": "ed_abitazioni_e%d_%d" % (era, k), "name": nome, "era": era,
                "classes": ["civico"], "terrain": None, "width": 1,
                "cost": dict(costo), "flexible": False, "resistance": res,
                "rendita": 0, "lampo": 1, "scavo": 1, "level_required": 0,
                "production": {"pietra": prod["pietra"], "oro": prod["oro"], "cultura": 0, "idee": 0},
                "exhaustible": 0, "min_players": 4,
            })

# LE CASE (registro 111, seconda idea del designer dopo la misura): abitazioni
# generiche che NON producono - "non fanno consumare risorse" - e danno solo
# Lampo, cioe' punti subito, un rientro annacquato. Due taglie per era, due
# copie ciascuna: la piccola costa poco e da' poco Lampo, la grande costa un
# po' di piu' e ne da' un po' di piu'. Venti sagome in piu', solo a quattro:
# la stima della dodicesima misura per sedici turni contro dodici sagome.
CASE = {
    # era: (nome piccola, costo, res, lampo), (nome grande, costo, res, lampo)
    1: (("Capanne di fango", {"pietra": 1, "oro": 0, "idee": 0}, 1, 1),
        ("Case di pietra",   {"pietra": 2, "oro": 0, "idee": 0}, 2, 2)),
    2: (("Case a schiera",   {"pietra": 1, "oro": 0, "idee": 0}, 2, 1),
        ("Domus",            {"pietra": 2, "oro": 0, "idee": 0}, 3, 2)),
    3: (("Case a graticcio", {"pietra": 1, "oro": 0, "idee": 0}, 2, 1),
        ("Casa torre",       {"pietra": 1, "oro": 1, "idee": 0}, 3, 2)),
    4: (("Casa borghese",    {"pietra": 0, "oro": 0, "idee": 1}, 2, 2),
        ("Palazzetto",       {"pietra": 0, "oro": 1, "idee": 1}, 3, 3)),
    5: (("Palazzina",        {"pietra": 0, "oro": 0, "idee": 1}, 3, 2),
        ("Condominio popolare", {"pietra": 0, "oro": 1, "idee": 1}, 4, 3)),
}

def case(v):
    for era, taglie in CASE.items():
        for t, (nome, costo, res, lampo) in enumerate(taglie):
            for k in (1, 2):
                v["buildings"].append({
                    "id": "ed_casa_e%d_%s%d" % (era, "pg"[t], k), "name": nome, "era": era,
                    "classes": ["civico"], "terrain": None, "width": 1,
                    "cost": dict(costo), "flexible": False, "resistance": res,
                    "rendita": 0, "lampo": lampo, "scavo": 1 + t, "level_required": 0,
                    "production": {"pietra": 0, "oro": 0, "cultura": 0, "idee": 0},
                    "exhaustible": 0, "min_players": 4,
                })

# I doppioni "di edifici che non siano enormi o speciali, tipo chiese": per
# era una seconda copia dei due edifici da una casella di classe religione
# (o cultura dove la religione manca), senza cariche, i piu' economici.
def doppioni_chiese(v):
    extra = []
    for era in range(1, 6):
        dell_era = [b for b in v["buildings"] if b["era"] == era and b["width"] == 1
                    and not b.get("exhaustible") and not b.get("min_players")]
        chiese = sorted([b for b in dell_era if "religione" in b["classes"]], key=_costo_totale)
        if len(chiese) < 2:
            chiese += sorted([b for b in dell_era if "cultura" in b["classes"] and b not in chiese],
                             key=_costo_totale)
        for b in chiese[:2]:
            c = json.loads(json.dumps(b))
            c["id"] = b["id"] + "_bis"
            c["name"] = b["name"] + " (II)"
            c["min_players"] = 4
            c["sagoma_di"] = b["id"]
            extra.append(c)
    v["buildings"].extend(extra)

def case_doppioni(v):
    case(v)
    doppioni_chiese(v)

import sys
variante = sys.argv[sys.argv.index("--variante") + 1] if "--variante" in sys.argv else ""
if variante:
    {"doppioni": doppioni, "abitazioni": abitazioni, "case": case,
     "case_doppioni": case_doppioni}[variante](v2)
    v2["meta"]["ruleset"] = "v2-" + variante
    v2["meta"]["origine"] = "generato da tools/genera_cards_v2.py --variante %s: non modificare a mano" % variante
    out = os.path.join(RADICE, "data/proposte/cards-v2-%s.json" % variante)
else:
    out = os.path.join(RADICE, "data/cards-v2.json")
json.dump(v2, open(out, "w", encoding="utf-8"), indent=2, ensure_ascii=False)
open(out, "a").write("\n")
n_idee = sum(1 for b in v2["buildings"] if b["cost"]["idee"])
print(f"scritto {os.path.relpath(out, RADICE)}: {n_idee} edifici con Idee nel costo, mix {MIX['3']} a 3 giocatori")
