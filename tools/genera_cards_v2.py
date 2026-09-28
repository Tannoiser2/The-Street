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
    3: (("Case di legno",    {"pietra": 1, "oro": 0, "idee": 0}, 2, 1),
        ("Casa torre",       {"pietra": 1, "oro": 1, "idee": 0}, 3, 2)),
    4: (("Casa borghese",    {"pietra": 0, "oro": 0, "idee": 1}, 2, 2),
        ("Palazzetto",       {"pietra": 0, "oro": 1, "idee": 1}, 3, 3)),
    5: (("Palazzina",        {"pietra": 0, "oro": 0, "idee": 1}, 3, 2),
        ("Condominio popolare", {"pietra": 0, "oro": 1, "idee": 1}, 4, 3)),
}
# La casa con lo Scavo (Scavo 2, e dal registro 117 anche il Lampo della
# piccola): costa e regge come la piccola.
# Non c'e' nell'era Moderna: "lo scavo nell'era 5 non vale" (nessuno costruisce
# sopra dopo l'ultima era), quindi li' restano solo la piccola e la grande.
CASE_SCAVO = {1: "Ripari", 2: "Tuguri", 3: "Casupole", 4: "Case popolari"}

# Tre modi (registro 112, "prova tutto"): "lampo" come sopra; "scavo" le stesse
# case senza Lampo e con Scavo 2 e 3, un rientro che paga solo se qualcuno ci
# costruisce sopra; "nulle" quattro case piccole per era che costano 1 e non
# danno niente (Lampo 0, Scavo 1): puro suolo, e Continuita' per chi le
# impila.
def case(v, modo="lampo"):
    for era, taglie in CASE.items():
        for t, (nome, costo, res, lampo) in enumerate(taglie):
            if modo == "nulle":
                nome, costo, res = taglie[0][0], taglie[0][1], taglie[0][2]
            for k in (1, 2):
                v["buildings"].append({
                    "id": "ed_casa_e%d_%s%d" % (era, "pg"[t], k), "name": nome, "era": era,
                    "classes": ["civico"], "terrain": None, "width": 1,
                    "cost": dict(costo), "flexible": False, "resistance": res,
                    "rendita": 0,
                    "lampo": lampo if modo == "lampo" else 0,
                    "scavo": {"lampo": 1 + t, "scavo": 2 + t, "nulle": 1}[modo],
                    "level_required": 0,
                    "production": {"pietra": 0, "oro": 0, "cultura": 0, "idee": 0},
                    "exhaustible": 0, "min_players": 4,
                })

def case_scavo(v): case(v, "scavo")
def case_nulle(v): case(v, "nulle")

# LE CASE PER TUTTI (registro 115): la decisione del designer dopo le prove a
# quattro. Tre tipi per era, per ogni numero di giocatori (niente
# `min_players`: le regole sono le stesse a due, tre e quattro): la casa
# piccola (costa 1, Lampo 1), la casa grande (costa 2, Lampo 2) e la casa con
# Scavo (costa 1, Lampo 1, Scavo 2); resistenza bassa,
# niente produzione, niente Rendita. Nell'era Moderna manca la casa con Scavo
# (lo Scavo li' non vale): quattordici case in tutto.
# Registro 116: le case stanno nel file v2, per tutti, NELLA RISERVA (sempre
# disponibili, non nel mazzo dell'era) con due copie ciascuna: "due copie di
# ognuna e poi il giocatore decide cosa comprare; sono sempre disponibili,
# non vengono pescate".
def case_tutti(v, riserva=False, copie=1):
    for era, taglie in CASE.items():
        (nome_p, costo_p, res_p, lampo_p), (nome_g, costo_g, res_g, lampo_g) = taglie
        # Registro 117, dopo la sedicesima misura: la grande non supera Lampo 2
        # (con 3 nelle ere 4-5 finiva quasi ogni partita) e la casa con lo
        # Scavo prende anche il Lampo della piccola (con Lampo 0 non la
        # comprava nessuno). La tabella CASE resta com'era per le varianti
        # di prova gia' misurate.
        tipi = [("p", nome_p, costo_p, res_p, lampo_p, 1),
                ("g", nome_g, costo_g, res_g, min(lampo_g, 2), 1)]
        if era in CASE_SCAVO:
            tipi.append(("s", CASE_SCAVO[era], costo_p, res_p, lampo_p, 2))
        for sigla, nome, costo, res, lampo, scavo in tipi:
            b = {
                "id": "ed_casa_e%d_%s" % (era, sigla), "name": nome, "era": era,
                "classes": ["civico"], "terrain": None, "width": 1,
                "cost": dict(costo), "flexible": False, "resistance": res,
                "rendita": 0, "lampo": lampo, "scavo": scavo, "level_required": 0,
                "production": {"pietra": 0, "oro": 0, "cultura": 0, "idee": 0},
                "exhaustible": 0,
            }
            if riserva:
                b["riserva"] = True
                b["copie"] = copie
            v["buildings"].append(b)
# "mista": la piccola da' Lampo 1 (e Scavo 1), la grande niente Lampo e Scavo 3.
def case_mista(v):
    case(v, "lampo")
    for b in v["buildings"]:
        if b.get("min_players") and b["id"].startswith("ed_casa_") and "_g" in b["id"]:
            b["lampo"] = 0
            b["scavo"] = 3

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


# LE TESSERE DELL'ERA (registro 121, docs/proposte/tessere-v2.md). Il terreno
# ha una produzione di base fissa; ogni era ha 7 tessere, in due copie, non
# legate al terreno: a inizio era se ne mette una per colonna, e aggiunge la
# sua produzione (da zero a una icona) e un effetto che scatta una volta per
# era, alla prima occasione. Base e icone sono tarate perche' a tre
# giocatori la produzione totale di ogni era resti quella della curva di prima
# (solo l'era 1 cambia: il Fiume da' Denaro da subito).
# L'effetto e' un dizionario letto da scripts/rules/tessere_era.gd:
# "quando" dice l'innesco (attiva, costruisci, ristruttura, potenzia,
# scheletro, seppellisci, fine_partita), "se" le condizioni, il resto cosa da'.
PRODUZIONE_BASE = {"pianura": {"pietra": 1, "oro": 0, "idee": 0},
                   "fiume": {"pietra": 0, "oro": 1, "idee": 0},
                   "collina": {"pietra": 1, "oro": 0, "idee": 0},
                   "bosco": {"pietra": 0, "oro": 0, "idee": 1}}
C, D, I, N = {"pietra": 1}, {"oro": 1}, {"idee": 1}, {}
TESSERE_ERA = [
    # era 1 - la fondazione
    (1, "campi_arati", "Campi arati", C, "Il primo edificio da 2 o 3 caselle costruito qui costa 1 Costruzione in meno.",
     {"quando": "costruisci", "se": {"larghezza_min": 2}, "sconto": {"pietra": 1}}),
    (1, "radura", "Radura", N, "Il primo edificio Civico costruito qui dà +1 Lampo.",
     {"quando": "costruisci", "se": {"classi": ["civico"]}, "lampo": 1}),
    (1, "sentiero_dei_pastori", "Sentiero dei pastori", N, "Chi attiva per primo prende +1 Denaro.",
     {"quando": "attiva", "guadagno": {"oro": 1}}),
    (1, "terra_di_nessuno", "Terra di nessuno", N, "Il primo edificio costruito qui ignora il requisito di terreno.",
     {"quando": "costruisci", "ignora_terreno": True}),
    (1, "recinto_di_pietre", "Recinto di pietre", C, "Il primo edificio costruito qui ha +1 resistenza fino a fine era.",
     {"quando": "costruisci", "resistenza_era": 1}),
    (1, "luogo_sacro", "Luogo sacro", N, "Il primo edificio Religione costruito qui costa 1 Idea in meno.",
     {"quando": "costruisci", "se": {"classi": ["religione"]}, "sconto": {"idee": 1}}),
    (1, "raccoglitori", "Raccoglitori", C, "Chi attiva per primo può cambiare 1 Idea in 1 Costruzione.",
     {"quando": "attiva", "cambio": ["idee", "pietra"]}),
    # era 2 - l'impero
    (2, "centuriazione", "Centuriazione", C, "Il primo edificio Ingegneria costruito qui costa 1 Costruzione in meno.",
     {"quando": "costruisci", "se": {"classi": ["ingegneria"]}, "sconto": {"pietra": 1}}),
    (2, "via_consolare", "Via consolare", C, "Chi attiva per primo prende anche la produzione di una colonna adiacente a scelta.",
     {"quando": "attiva", "produzione_adiacente": True}),
    (2, "statio", "Statio", C, "Il primo edificio Commercio costruito qui dà +1 Denaro a chi lo costruisce.",
     {"quando": "costruisci", "se": {"classi": ["commercio"]}, "guadagno": {"oro": 1}}),
    (2, "cambiavalute", "Cambiavalute", C, "Chi attiva per primo può cambiare 1 Costruzione in 1 Denaro.",
     {"quando": "attiva", "cambio": ["pietra", "oro"]}),
    (2, "cantiere", "Cantiere", C, "Il primo edificio costruito qui sopra un altro edificio costa 1 Costruzione in meno.",
     {"quando": "costruisci", "se": {"sopra": True}, "sconto": {"pietra": 1}}),
    (2, "restauratori", "Restauratori", I, "Una ristrutturazione di un edificio qui costa 1 Costruzione in meno.",
     {"quando": "ristruttura", "sconto": {"pietra": 1}}),
    (2, "necropoli", "Necropoli", I, "Il primo edificio costruito qui ha Scavo +1, per sempre.",
     {"quando": "costruisci", "scavo": 1}),
    # era 3 - i castelli
    (3, "fiera", "Fiera", N, "Chi attiva per primo prende +1 Denaro per ogni altro giocatore con un edificio intatto qui.",
     {"quando": "attiva", "per_altrui_intatti": "oro"}),
    (3, "borgo_franco", "Borgo franco", N, "Il primo edificio costruito qui sopra una rovina altrui costa 1 Costruzione in meno.",
     {"quando": "costruisci", "se": {"su_rovina_altrui": True}, "sconto": {"pietra": 1}}),
    (3, "scuola_dei_mastri", "Scuola dei mastri", I, "Chi attiva per primo prende +1 Idea per ogni edificio Ingegneria intatto qui.",
     {"quando": "attiva", "per_classe_intatti": {"classi": ["ingegneria"], "risorsa": "idee"}}),
    (3, "mura", "Mura", N, "Il primo edificio Militare costruito qui ha +2 resistenza fino a fine era.",
     {"quando": "costruisci", "se": {"classi": ["militare"]}, "resistenza_era": 2}),
    (3, "rocca", "Rocca", N, "Il primo edificio costruito qui è protetto all'evento di fine era.",
     {"quando": "costruisci", "immune_evento": True}),
    (3, "eremo", "Eremo", I, "Il primo edificio Religione o Cultura costruito qui dà +2 Lampo.",
     {"quando": "costruisci", "se": {"classi": ["religione", "cultura"]}, "lampo": 2}),
    (3, "spoglio_delle_rovine", "Spoglio delle rovine", N, "Chi seppellisce per primo un edificio qui prende +1 al premio di scavo.",
     {"quando": "seppellisci", "premio": 1}),
    # era 4 - le signorie
    (4, "villa_di_campagna", "Villa di campagna", D, "Il primo edificio Cultura costruito qui costa 1 Denaro in meno.",
     {"quando": "costruisci", "se": {"classi": ["cultura"]}, "sconto": {"oro": 1}}),
    (4, "piazza_del_mercato", "Piazza del mercato", N, "Chi attiva per primo, se ha meno punti di tutti, prende +2 Denaro.",
     {"quando": "attiva", "se": {"ultimo_in_punti": True}, "guadagno": {"oro": 2}}),
    (4, "bottega", "Bottega", I, "Chi attiva per primo prende 1 risorsa a scelta.",
     {"quando": "attiva", "a_scelta": 1}),
    (4, "fondaco", "Fondaco", D, "Il primo edificio Commercio costruito qui produce subito, una volta.",
     {"quando": "costruisci", "se": {"classi": ["commercio"]}, "produce_subito": True}),
    (4, "belvedere", "Belvedere", I, "Il primo edificio costruito qui al livello 3 o più dà +2 Lampo.",
     {"quando": "costruisci", "se": {"livello_min": 3}, "lampo": 2}),
    (4, "giardino_all_italiana", "Giardino all'italiana", I, "Il primo edificio ristrutturato qui torna in piedi con +1 resistenza.",
     {"quando": "ristruttura", "resistenza": 1}),
    (4, "cappella_di_famiglia", "Cappella di famiglia", I, "Il primo scheletro lasciato qui vale +1 punto a fine partita.",
     {"quando": "scheletro", "punti": 1}),
    # era 5 - la citta' moderna (niente Scavo: nell'era 5 non vale)
    (5, "periferia", "Periferia", D, "Il primo edificio Civico costruito qui costa 1 Idea in meno.",
     {"quando": "costruisci", "se": {"classi": ["civico"]}, "sconto": {"idee": 1}}),
    (5, "zona_industriale", "Zona industriale", N, "Chi attiva per primo prende +1 Denaro per ogni edificio Ingegneria o Commercio intatto qui.",
     {"quando": "attiva", "per_classe_intatti": {"classi": ["ingegneria", "commercio"], "risorsa": "oro"}}),
    (5, "isolato", "Isolato", I, "Il primo edificio costruito qui dà +1 Lampo per ogni edificio altrui intatto qui.",
     {"quando": "costruisci", "lampo_per_altrui": 1}),
    (5, "scuola_politecnica", "Scuola politecnica", D, "Il primo edificio Ingegneria costruito qui costa 1 Denaro in meno.",
     {"quando": "costruisci", "se": {"classi": ["ingegneria"]}, "sconto": {"oro": 1}}),
    (5, "quartiere_alto", "Quartiere alto", I, "Il primo edificio costruito qui, se diventa il più alto della strada, dà +3 Lampo.",
     {"quando": "costruisci", "se": {"il_piu_alto": True}, "lampo": 3}),
    (5, "parco_pubblico", "Parco pubblico", I, "A fine partita chi ha l'edificio in cima a questa colonna prende +2 punti.",
     {"quando": "fine_partita", "cima_punti": 2}),
    (5, "orto_botanico", "Orto botanico", I, "Il primo potenziamento messo su un edificio qui costa 1 Idea in meno.",
     {"quando": "potenzia", "sconto": {"idee": 1}}),
]
assert len(TESSERE_ERA) == 35 and all(sum(1 for t in TESSERE_ERA if t[0] == e) == 7 for e in range(1, 6))

def tessere_era(v):
    for t in v["terrains"]:
        t["produzione_base"] = dict(PRODUZIONE_BASE[t["id"]])
    v["tessere_era"] = []
    for era, ident, nome, prod, testo, eff in TESSERE_ERA:
        p = {"pietra": 0, "oro": 0, "idee": 0}
        p.update(prod)
        v["tessere_era"].append({"id": "te_" + ident, "name": nome, "era": era,
                                 "produzione": p, "testo": testo, "effetto": eff,
                                 "copie": 2})
    v["constants"]["tessere_era"] = True

# LE FORME DELLE CARTE STAMPATE (registro 122). Una casella e' una colonna per
# un binario; le carte nuove ne coprono piu' d'uno in profondita'. Decisioni
# del designer: le "quadrate" occupano una colonna e due binari; il Colosseo
# (Anfiteatro) passa da 3 a 2 colonne ed e' 2x2 come Castello e Fortezza; il
# Grattacielo e' una colonna per tre binari. Acquedotto e Stazione restano
# larghi 3. I binari non sono le ere: si costruisce nel binario che si vuole.
# `depth` = binari occupati. `solo_su_rovine`: mai a terra, solo sopra, con le
# regole di sempre (almeno una base vera: una rovina o un proprio attivo da
# spianare; terrapieno sulle caselle vuote); e sopra di lui non si costruisce
# finche' non e' a sua volta in rovina.
FORME = {
    "ed_circolo_di_pietre": (1, 2), "ed_villaggio_palizzato": (1, 2),
    "ed_castrum": (1, 2), "ed_foro": (1, 2), "ed_abbazia": (1, 2),
    "ed_arsenale": (1, 2), "ed_duomo": (1, 2), "ed_piazza_monumentale": (1, 2),
    "ed_universita": (1, 2), "ed_parco_archeologico": (1, 2),
    "ed_anfiteatro": (2, 2), "ed_castello": (2, 2), "ed_fortezza_bastionata": (2, 2),
    "ed_grattacielo": (1, 3),
}
SOLO_SU_ROVINE = {"ed_anfiteatro", "ed_castello", "ed_fortezza_bastionata", "ed_grattacielo"}
TESTI_FORME = {
    "ed_acquedotto": "Colossale: 3 slot adiacenti, almeno uno con fiume. Eco: +2 PV (lampo) se ancora in piedi nel Moderno.",
    "ed_stazione": "Colossale: 3 slot adiacenti, si attiva da tutte le colonne. Produce 2 oro. Richiede livello 1+.",
}

def forme(v):
    per_id = {b["id"]: b for b in v["buildings"]}
    assert set(FORME) <= set(per_id), set(FORME) - set(per_id)
    for bid, (w, d) in FORME.items():
        per_id[bid]["width"] = w
        per_id[bid]["depth"] = d
    for bid in SOLO_SU_ROVINE:
        per_id[bid]["solo_su_rovine"] = True
    for bid, testo in TESTI_FORME.items():
        per_id[bid]["effect_text"] = testo
    v["constants"]["caselle"] = True

import sys
variante = sys.argv[sys.argv.index("--variante") + 1] if "--variante" in sys.argv else ""
# Le case in riserva stanno nel file v2 di tutti (registro 116); le varianti di
# prova ci si aggiungono sopra, come misura.
case_tutti(v2, riserva=True, copie=2)
tessere_era(v2)
forme(v2)
if variante:
    {"doppioni": doppioni, "abitazioni": abitazioni, "case": case,
     "case_doppioni": case_doppioni, "case_scavo": case_scavo, "case_nulle": case_nulle,
     "case_mista": case_mista, "case_tutti": case_tutti}[variante](v2)
    v2["meta"]["ruleset"] = "v2-" + variante
    v2["meta"]["origine"] = "generato da tools/genera_cards_v2.py --variante %s: non modificare a mano" % variante
    out = os.path.join(RADICE, "data/proposte/cards-v2-%s.json" % variante)
else:
    out = os.path.join(RADICE, "data/cards-v2.json")
json.dump(v2, open(out, "w", encoding="utf-8"), indent=2, ensure_ascii=False)
open(out, "a").write("\n")
n_idee = sum(1 for b in v2["buildings"] if b["cost"]["idee"])
print(f"scritto {os.path.relpath(out, RADICE)}: {n_idee} edifici con Idee nel costo, mix {MIX['3']} a 3 giocatori")
