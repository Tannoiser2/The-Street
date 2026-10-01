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
# REGISTRO 142: via la Prosperita' Urbana. Il designer: "togli la Prosperita'
# se il denaro e' abbondante e avanza a ogni era". Misurato senza: a fine era
# avanzano 3-6 Denaro a testa dall'era 2 in poi, a zero in meno del 10% dei
# casi, e i PV non si muovono (ventottesima misura).
v2["constants"]["prosperity"] = dict(v2["constants"]["prosperity"], attiva=False)
# REGISTRO 150: LE GILDE DELL'ERA MODERNA. Il designer: "gli edifici dell'era 5
# dovrebbero funzionare come una specie di gilda di 7 Wonders, che oltre a
# riscoprire le rovine danno PV in base ad alcune condizioni". Otto su
# quattordici lo facevano gia'; queste quattro non avevano niente (le due case
# restano case).
def gilde_era5(v):
    eb = {b["id"]: b for b in v["buildings"]}
    def gilda(bid, effetti, testo):
        eb[bid]["effects"] = effetti
        eb[bid]["effect_text"] = testo
    gilda("ed_condominio", [{"hook": "on_final_scoring", "op": "vp_per", "value": 1, "cap": 4,
        "target": {"owner": "self", "class": ["civico"], "state": ["intatto"], "buried": False}}],
        "A fine partita: +1 PV per ogni tuo edificio Civico in piedi (max +4).")
    gilda("ed_officina", [{"hook": "on_final_scoring", "op": "vp_per", "value": 1, "cap": 4,
        "target": {"owner": "self", "class": ["ingegneria"], "is_self": False}}],
        "A fine partita: +1 PV per ogni altro tuo edificio Ingegneria, in piedi o sotterrato (max +4).")
    gilda("ed_ponte_in_acciaio", [{"hook": "on_final_scoring", "op": "vp_per", "value": 2,
        "target": {"owner": "self", "state": ["rovina"], "scavata": True, "same_column_as_self": True}}],
        "A fine partita: +2 PV per ogni tua rovina riportata alla luce nelle sue colonne.")
    # La Stazione tiene il suo rule_override (solo sopra): la gilda si aggiunge.
    gilda("ed_stazione", [e for e in eb["ed_stazione"]["effects"] if e["hook"] != "on_final_scoring"] + [{"hook": "on_final_scoring", "op": "vp_per", "value": 1, "cap": 5,
        "target": {"state": ["intatto"], "buried": False, "same_column_as_self": True, "is_self": False}}],
        "Solo sopra: al livello 1 o piu'. A fine partita: +1 PV per ogni edificio in piedi nelle sue colonne, di chiunque (max +5).")

# REGISTRO 149: l'evento finale. Il designer: "a cosa serve la resistenza negli
# edifici di era 5? O si mette un evento anche alla fine oppure va eliminato.
# Procedi con evento finale". Un evento solo, senza effetti speciali, di forza
# 4 come il Medioevo: crolla chi resta sotto di due (resistenza 2 o meno senza
# protezioni). Si risolve prima del conto finale, quindi prima del censimento
# finale e dello Scavo: quel che crolla smette di rendere e diventa rovina da
# contare.
v2["constants"]["evento_finale"] = {"id": "ev_giudizio_del_tempo", "name": "Il giudizio del tempo",
    "era": 5, "force": 4, "effects": [],
    "text": "Fine dell'era Moderna: ogni edificio in piedi affronta la forza 4, poi si contano i punti."}
# ---- le varianti di prova per la scarsita' di sagome a quattro (registro 110) --
# A quattro giocatori sedici turni per era contro dodici sagome. Due idee del
# designer, ognuna un file a parte in data/proposte/, che il file v2 non tocca:
#   --variante premio_meta / premio_meta_tessere  il premio di scavo a 1 PV per tessera, e le tessere doppie (registro 145)
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

def forme(v):
    per_id = {b["id"]: b for b in v["buildings"]}
    assert set(FORME) <= set(per_id), set(FORME) - set(per_id)
    for bid, (w, d) in FORME.items():
        per_id[bid]["width"] = w
        per_id[bid]["depth"] = d
    for bid in SOLO_SU_ROVINE:
        per_id[bid]["solo_su_rovine"] = True
    v["constants"]["caselle"] = True

# I POTENZIAMENTI RADDOPPIATI (registro 123): il designer chiede altri 25
# potenziamenti, cinque per era, per un mazzo di dieci carte diverse per era.
# Stessa economia dei 25 di prima: costo 1 nelle ere 1-3 e 2 nelle ere 4-5,
# nella risorsa della famiglia (Arte in Idee, Struttura in Costruzione, il
# resto in Denaro); forza pari a quella dei potenziamenti della stessa era.
# Gli effetti usano solo operazioni che il motore gia' conosce.
def _se_classe(classe):
    return {"op": "count_matching", "min": 1, "target": {"is_self": True, "class": [classe]}}

def _se_terreno(terreno):
    return {"op": "count_matching", "min": 1, "target": {"is_self": True, "terrain": [terreno]}}

def _pv(n, se=None):
    e = {"hook": "on_acquire", "op": "vp", "value": n}
    if se: e["condition"] = se
    return e

def _res(n, se=None):
    e = {"hook": "on_acquire", "op": "resistance", "value": n, "duration": "permanent", "target": {"is_self": True}}
    if se: e["condition"] = se
    return e

def _scavo(n):
    return {"hook": "on_acquire", "op": "scavo_delta", "value": n, "duration": "permanent", "target": {"is_self": True}}

def _abiti(risorsa, n, se=None):
    e = {"hook": "on_activate", "op": "resource", risorsa: n, "target": {"is_self": True}}
    if se: e["condition"] = se
    return e

def _conta_come(classe):
    return {"hook": "on_acquire", "op": "rule_override", "name": "counts_as_class",
            "target": {"is_self": True}, "adds_class": [classe]}

POTENZIAMENTI_NUOVI = [
    # era, id, nome, famiglia, classe, testo, effetti
    (1, "totem", "Totem", "arte", "religione", "Arte: +1 PV (+1 extra su edificio Civico).",
     [_pv(1), _pv(1, _se_classe("civico"))]),
    (1, "argine", "Argine", "struttura", "ingegneria", "Struttura: +1 res.", [_res(1)]),
    (1, "focolare", "Focolare", "altro", "civico", "Quando abiti questo edificio, +1 Idea.",
     [_abiti("idee", 1)]),
    (1, "recinto", "Recinto per il bestiame", "altro", "commercio", "Quando abiti questo edificio, +1 Denaro.",
     [_abiti("oro", 1)]),
    (1, "ossario", "Ossario", "altro", "religione", "Scavo dell'edificio +2.", [_scavo(2)]),
    (2, "mosaico", "Mosaico", "arte", "cultura", "Arte: +2 PV su edificio Cultura, altrimenti +1.",
     [_pv(1), _pv(1, _se_classe("cultura"))]),
    (2, "terme", "Terme private", "altro", "civico", "Quando abiti questo edificio, +1 Idea.",
     [_abiti("idee", 1)]),
    (2, "mura_di_cinta", "Mura di cinta", "struttura", "militare", "Struttura: +1 res (+1 extra su edificio Militare).",
     [_res(1), _res(1, _se_classe("militare"))]),
    (2, "mulino_ad_acqua", "Mulino ad acqua", "altro", "ingegneria", "Solo su slot fiume: quando abiti qui, +1 Costruzione.",
     [_abiti("pietra", 1, _se_terreno("fiume"))]),
    (2, "lapide", "Lapide funeraria", "altro", "religione", "Finale: +2 Scavo a ogni edificio Sotterrato sotto questo edificio.",
     [{"hook": "on_final_scoring", "op": "scavo_delta", "value": 2, "target": {"buried": True, "below_self": True}}]),
    (3, "vetrata", "Vetrata", "arte", "religione", "Arte: +1 PV. Scavo dell'edificio +2.", [_pv(1), _scavo(2)]),
    (3, "arco_rampante", "Arco rampante", "struttura", "ingegneria", "Struttura: +1 res. L'edificio conta anche come Religione.",
     [_res(1), _conta_come("religione")]),
    (3, "portico", "Portico", "altro", "commercio", "Quando abiti questo edificio, +1 Denaro (+1 extra su edificio Commercio).",
     [_abiti("oro", 1), _abiti("oro", 1, _se_classe("commercio"))]),
    (3, "torre_di_guardia", "Torre di guardia", "struttura", "militare", "Struttura: +1 res (+1 extra su edificio Militare).",
     [_res(1), _res(1, _se_classe("militare"))]),
    (3, "stemma", "Stemma di famiglia", "arte", "civico", "Arte: +2 PV su edificio Civico, altrimenti +1.",
     [_pv(1), _pv(1, _se_classe("civico"))]),
    (4, "pala_d_altare", "Pala d'altare", "arte", "religione", "Arte: +2 PV (+1 extra su edificio Religione).",
     [_pv(2), _pv(1, _se_classe("religione"))]),
    (4, "loggia", "Loggia", "altro", "civico", "+1 PV. L'affitto incassato da questo edificio è +1.",
     [_pv(1), {"hook": "on_acquire", "op": "rendita_delta", "value": 1, "duration": "permanent", "target": {"is_self": True}}]),
    (4, "bastione_a_stella", "Bastione a stella", "struttura", "militare", "Struttura: +2 res.", [_res(2)]),
    (4, "fontana", "Fontana monumentale", "arte", "civico", "Arte: +2 PV. Scavo dell'edificio +2.", [_pv(2), _scavo(2)]),
    (4, "stamperia", "Stamperia", "altro", "cultura", "Quando abiti questo edificio, +2 Idee.", [_abiti("idee", 2)]),
    (5, "murale", "Murale", "arte", "cultura", "Arte: +2 PV (+1 extra su edificio Cultura).",
     [_pv(2), _pv(1, _se_classe("cultura"))]),
    (5, "pannelli_solari", "Pannelli solari", "altro", "ingegneria", "Quando abiti questo edificio, +2 Costruzione.",
     [_abiti("pietra", 2)]),
    (5, "cemento_armato", "Cemento armato", "struttura", "ingegneria", "Struttura: +2 res.", [_res(2)]),
    (5, "terrazza", "Terrazza panoramica", "altro", "civico", "+2 PV su edificio Civico, altrimenti +1.",
     [_pv(1), _pv(1, _se_classe("civico"))]),
    (5, "archivio_storico", "Archivio storico", "altro", "cultura", "Scavo dell'edificio +3.", [_scavo(3)]),
]
assert len(POTENZIAMENTI_NUOVI) == 25 and all(sum(1 for u in POTENZIAMENTI_NUOVI if u[0] == e) == 5 for e in range(1, 6))

def potenziamenti_nuovi(v):
    ids = {u["id"] for u in v["upgrades"]}
    for era, ident, nome, fam, classe, testo, effetti in POTENZIAMENTI_NUOVI:
        uid = "po_" + ident
        assert uid not in ids, uid
        costo = {"pietra": 0, "oro": 0, "idee": 0}
        costo[RISORSA_FAMIGLIA[fam]] = 1 if era <= 3 else 2
        v["upgrades"].append({"id": uid, "name": nome, "era": era, "class": classe, "cost": costo,
                              "family": fam, "effect_text": testo, "effects": effetti})

# I TESTI DA STAMPARE (registro 124). Il designer: "correggi tutti i testi";
# tre tempi e basta. Il Lampo (punti subito, una volta) e la Rendita (punti a
# fine di ogni era, se in piedi) stanno nelle icone, non nel testo; nel testo
# restano gli effetti permanenti e quelli "A fine partita". Niente frasi di
# colore, niente parole della v1.5 (pietra, oro, res, lampo per un finale,
# "abiti qui"), niente ripetizioni di quello che dice gia' un'icona o la forma
# della carta. Ogni testo dice quello che fa il motore, parola per parola.
SOLO_SOPRA = "Solo sopra: mai a terra. Sopra di lui si costruisce solo quando è in rovina."
TESTI_V2 = {
    # edifici: "" = nessun testo sulla carta
    "ed_circolo_di_pietre": "",
    "ed_menhir": "",
    "ed_focolare_comune": "Quando lo attivi: +1 Costruzione.",
    "ed_villaggio_palizzato": "Negli eventi, i tuoi edifici adiacenti hanno +1 Resistenza.",
    "ed_acquedotto": "A fine partita, se è in piedi: +2 PV.",
    "ed_anfiteatro": SOLO_SOPRA,
    "ed_castrum": "Negli eventi, i tuoi edifici nelle sue colonne hanno +1 Resistenza.",
    "ed_ponte": "Gli edifici adiacenti producono 1 in più di ogni risorsa che già producono.",
    "ed_torre_di_vedetta": "Negli eventi, i tuoi edifici adiacenti hanno +1 Resistenza.",
    "ed_arsenale": "Negli eventi, i tuoi edifici Militari adiacenti hanno +1 Resistenza.",
    "ed_castello": SOLO_SOPRA,
    "ed_mura": "Negli eventi, tutti gli edifici adiacenti, anche altrui, hanno +1 Resistenza.",
    "ed_ospedale_dei_pellegrini": "Quando lo attivi: +1 Denaro.",
    "ed_bottega_dartista": "I tuoi potenziamenti costano 1 in meno, nella loro risorsa.",
    "ed_duomo": "Solo sopra: al livello 2 o più.",
    "ed_fortezza_bastionata": SOLO_SOPRA,
    "ed_giardino_allitaliana": "",
    "ed_osservatorio": "A fine partita, se è in piedi: +2 PV.",
    "ed_piazza_monumentale": "Solo sopra: al livello 1 o più. A fine partita: +1 PV per ogni tuo edificio in cima a una colonna adiacente.",
    "ed_biblioteca": "A fine partita: +1 PV per ogni classe diversa fra i tuoi edifici nelle sue colonne, sotterrati compresi.",
    "ed_caffe_letterario": "A fine partita: +1 PV se è adiacente a un edificio Cultura.",
    "ed_condominio": "",
    "ed_fondazione_darte": "A fine partita: +1 PV per ogni tuo potenziamento.",
    "ed_grattacielo": "Solo sopra: al livello 2 o più, mai a terra. A fine partita: +1 PV per ogni livello a cui è costruito; ogni edificio altrui in cima a una colonna adiacente toglie 1 PV al suo proprietario.",
    "ed_monumento_ai_caduti": "A fine partita: +1 PV per ogni altro tuo edificio Militare, in piedi o sotterrato.",
    "ed_museo": "Solo sopra: al livello 1 o più. A fine partita: +2 PV per ogni edificio sotterrato sotto di lui.",
    "ed_parco_archeologico": "A fine partita: fino a 2 tuoi edifici non sotterrati nelle colonne adiacenti valgono il loro Scavo come se fossero sotterrati.",
    "ed_stazione": "Solo sopra: al livello 1 o più.",
    "ed_universita": "Solo sopra: al livello 1 o più. A fine partita: +1 PV per ogni tuo Personaggio.",
    # potenziamenti: la famiglia (Arte, Struttura, Altro) e' l'etichetta della
    # carta, non si ripete nel testo. I PV dei potenziamenti arrivano subito.
    "po_pittura_rupestre": "Subito: +1 PV. L'edificio ha +2 Scavo.",
    "po_palizzata": "L'edificio ha +1 Resistenza.",
    "po_idolo": "Subito: +1 PV, +2 PV se l'edificio è Religione.",
    "po_granaio_comune": "Quando attivi l'edificio: +1 Costruzione.",
    "po_fondamenta_in_pietra": "L'edificio ha +1 Resistenza.",
    "po_statua": "Subito: +2 PV.",
    "po_altare": "Subito: +1 PV. L'edificio ha +2 Scavo.",
    "po_bastioni": "L'edificio ha +1 Resistenza.",
    "po_banchina": "Quando attivi l'edificio, se tocca il Fiume: +1 Denaro.",
    "po_iscrizione": "L'edificio ha +2 Scavo.",
    "po_contrafforte": "L'edificio ha +1 Resistenza.",
    "po_campanile": "Subito: +1 PV. L'edificio ha +1 Resistenza.",
    "po_merlatura": "L'edificio ha +1 Resistenza e conta anche come Militare.",
    "po_stalli_mercantili": "L'edificio ha +1 Rendita.",
    "po_reliquia": "Subito: +1 PV, +2 PV se l'edificio è Religione.",
    "po_opera_darte": "Subito: +3 PV.",
    "po_affreschi": "Subito: +2 PV.",
    "po_cupola": "Subito: +2 PV. L'edificio ha +1 Resistenza.",
    "po_giardino_pensile": "Subito: +2 PV.",
    "po_cannoniere": "L'edificio ha +1 Resistenza, +2 se è Militare.",
    "po_installazione": "Subito: +3 PV.",
    "po_targa_storica": "A fine partita: +2 Scavo a ogni edificio sotterrato sotto l'edificio.",
    "po_ascensore_panoramico": "Subito: +2 PV.",
    "po_boutique": "Quando attivi l'edificio: +2 Denaro.",
    "po_memoriale": "Subito: +2 PV.",
    "po_totem": "Subito: +1 PV, +2 PV se l'edificio è Civico.",
    "po_argine": "L'edificio ha +1 Resistenza.",
    "po_focolare": "Quando attivi l'edificio: +1 Idea.",
    "po_recinto": "Quando attivi l'edificio: +1 Denaro.",
    "po_ossario": "L'edificio ha +2 Scavo.",
    "po_mosaico": "Subito: +1 PV, +2 PV se l'edificio è Cultura.",
    "po_terme": "Quando attivi l'edificio: +1 Idea.",
    "po_mura_di_cinta": "L'edificio ha +1 Resistenza, +2 se è Militare.",
    "po_mulino_ad_acqua": "Quando attivi l'edificio, se tocca il Fiume: +1 Costruzione.",
    "po_lapide": "A fine partita: +2 Scavo a ogni edificio sotterrato sotto l'edificio.",
    "po_vetrata": "Subito: +1 PV. L'edificio ha +2 Scavo.",
    "po_arco_rampante": "L'edificio ha +1 Resistenza e conta anche come Religione.",
    "po_portico": "Quando attivi l'edificio: +1 Denaro, +2 se è Commercio.",
    "po_torre_di_guardia": "L'edificio ha +1 Resistenza, +2 se è Militare.",
    "po_stemma": "Subito: +1 PV, +2 PV se l'edificio è Civico.",
    "po_pala_d_altare": "Subito: +2 PV, +3 PV se l'edificio è Religione.",
    "po_loggia": "Subito: +1 PV. L'edificio ha +1 Rendita.",
    "po_bastione_a_stella": "L'edificio ha +2 Resistenza.",
    "po_fontana": "Subito: +2 PV. L'edificio ha +2 Scavo.",
    "po_stamperia": "Quando attivi l'edificio: +2 Idee.",
    "po_murale": "Subito: +2 PV, +3 PV se l'edificio è Cultura.",
    "po_pannelli_solari": "Quando attivi l'edificio: +2 Costruzione.",
    "po_cemento_armato": "L'edificio ha +2 Resistenza.",
    "po_terrazza": "Subito: +1 PV, +2 PV se l'edificio è Civico.",
    "po_archivio_storico": "L'edificio ha +3 Scavo.",
}

def testi_v2(v):
    carte = {c["id"]: c for c in v["buildings"] + v["upgrades"]}
    # La Bottega d'artista sconta nella risorsa del potenziamento, come dice
    # la carta stampata, non piu' sempre in oro.
    for e in carte["ed_bottega_dartista"]["effects"]:
        if e["op"] == "cost_delta" and e.get("what") == "upgrade":
            e.pop("oro", None)
            e["propria"] = -1
    assert set(TESTI_V2) <= set(carte), set(TESTI_V2) - set(carte)
    for cid, testo in TESTI_V2.items():
        carte[cid]["effect_text"] = testo
    # Ogni potenziamento ha il suo testo scritto qui: nessuno resta con
    # quello della v1.5.
    senza = [u["id"] for u in v["upgrades"] if u["id"] not in TESTI_V2]
    assert not senza, senza

# IL TETTO AL LAMPO (registro 125): nessun edificio da' piu' di 2 Lampo. Dopo
# le caselle la strategia Lampo vinceva il 66/48/46 % a 2/3/4 giocatori;
# fra le tre strade provate (bot, Lampo tolto alle tessere, tetto sulle carte)
# la migliore e' il tetto a 2 insieme al bot ritarato. Le carte si ristampano
# comunque per le icone nuove, quindi i 16 numeri cambiano senza costo.
LAMPO_TETTO = 2

def lampo_tetto(v):
    for b in v["buildings"]:
        b["lampo"] = min(int(b["lampo"]), LAMPO_TETTO)

# LE CARTE MORTE (registro 126). Il rapporto delle partite (registro 125) ha
# trovato carte che non si giocano mai; qui la correzione per ognuna, approvata
# dal designer ("le proposte sulle carte vanno bene, procedi").
def carte_vive(v):
    per_id = {c["id"]: c for c in v["buildings"] + v["upgrades"]}
    # Le case piccole erano identiche alle case dello Scavo della stessa era,
    # con meno Scavo: nessuno le prendeva. Ora si pagano in Denaro, che
    # avanza, invece che in Costruzione.
    for bid in ("ed_casa_e1_p", "ed_casa_e2_p", "ed_casa_e3_p"):
        per_id[bid]["cost"] = {"pietra": 0, "oro": 1, "idee": 0}
    # Gli edifici Militari che proteggono costavano troppo per quello che danno.
    per_id["ed_villaggio_palizzato"]["cost"] = {"pietra": 1, "oro": 0, "idee": 0}
    per_id["ed_villaggio_palizzato"]["scavo"] = 3
    per_id["ed_castrum"]["cost"] = {"pietra": 2, "oro": 0, "idee": 0}
    per_id["ed_torre_di_vedetta"]["lampo"] = 2
    per_id["ed_mura"]["lampo"] = 2
    # Il Museo chiedeva 2 Idee, la risorsa che manca.
    per_id["ed_museo"]["cost"] = {"pietra": 1, "oro": 1, "idee": 1}
    # Secondo ritocco (misura a 200 partite): chi restava quasi morto.
    # Nell'era 1 il Denaro non c'e': le Capanne di fango tornano in
    # Costruzione, ma piu' solide dei Ripari (resistenza 2 contro 1, Scavo 1
    # contro 2); cosi' le Case a schiera rispetto ai Tuguri.
    per_id["ed_casa_e1_p"]["cost"] = {"pietra": 1, "oro": 0, "idee": 0}
    per_id["ed_casa_e1_p"]["resistance"] = 2
    per_id["ed_casa_e2_p"]["cost"] = {"pietra": 1, "oro": 0, "idee": 0}
    per_id["ed_casa_e2_p"]["resistance"] = 3
    per_id["ed_castrum"]["lampo"] = 2
    per_id["ed_villaggio_palizzato"]["lampo"] = 2
    per_id["ed_torre_di_vedetta"]["cost"] = {"pietra": 1, "oro": 0, "idee": 0}
    # Il Cemento armato dava Resistenza nell'era 5, che non ha evento.
    ca = per_id["po_cemento_armato"]
    # Il designer (registro 129): +2 Resistenza, come e' stampato.
    ca["effects"] = [{"hook": "on_acquire", "op": "resistance", "value": 2, "duration": "permanent", "target": {"is_self": True}}]
    ca["effect_text"] = "L'edificio ha +2 Resistenza."
    # Le tessere dell'era che non scattavano.
    per_t = {t["id"]: t for t in v["tessere_era"]}
    r = per_t["te_raccoglitori"]
    r["testo"] = "Chi attiva per primo può cambiare 1 Costruzione in 1 Idea."
    r["effetto"] = {"quando": "attiva", "cambio": ["pietra", "idee"]}
    r = per_t["te_restauratori"]
    r["testo"] = "Il primo edificio costruito qui sopra un altro costa 1 Idea in meno."
    r["effetto"] = {"quando": "costruisci", "se": {"sopra": True}, "sconto": {"idee": 1}}
    r = per_t["te_giardino_all_italiana"]
    r["testo"] = "Il primo edificio costruito qui ha +2 resistenza fino a fine era."
    r["effetto"] = {"quando": "costruisci", "resistenza_era": 2}
    # Le Eredita' quasi impossibili.
    per_l = {l["id"]: l for l in (v["legacies"] if isinstance(v["legacies"], list) else v["legacies"].values())}
    c = per_l["er_il_condottiero"]
    c["condition"] = {"op": "count_matching", "target": {"owner": "self", "class": ["militare"]}, "min": 2}
    c["condition_text"] = "2+ tuoi edifici Militari, in qualsiasi stato."
    c = per_l["er_lantiquario"]
    c["condition"]["target"]["scavo"] = {"min": 5}
    c["condition_text"] = "un tuo edificio Sotterrato con Scavo 5 o più."
    c = per_l["er_il_restauratore"]
    c["condition"]["min"] = 1
    c["condition_text"] = "hai ristrutturato una tua rovina."
    # I potenziamenti dell'era 1 non si usavano mai (nell'era 1 i propri
    # edifici stanno sulle colonne gia' attivate): la fila dei potenziamenti
    # non si scarta a fine era e resta accanto alla nuova per un'era. La prima
    # prova, potenziare anche nella colonna adiacente, faceva salire gli
    # Scheletri da 8 a 22 PV a testa e affondava la Rendita.
    v["constants"]["fila_potenziamenti_resta"] = True

# GLI EVENTI DELL'ERA 4 E L'AVANZO IN IDEE (registro 126). Nell'era 4 la
# forza 5 faceva crollare l'87 % degli edifici costruiti in quell'era: a
# forza 3 ne crolla uno su cinque, e l'era 3 (forza 4) resta la piu' dura.
# L'era 5 resta senza evento. Il tetto a fine era buttava meta' della
# Costruzione: ora ogni 2 risorse sopra il tetto diventano 1 Idea, la
# risorsa che manca, e solo il resto si butta.
def eventi_e_avanzo(v):
    v["constants"]["event_force_by_era"]["4"] = 3
    evs = v["events"] if isinstance(v["events"], list) else list(v["events"].values())
    for e in evs:
        if int(e.get("era", 0)) == 4 and "force" in e:
            e["force"] = 3
            for k in ("effect_text", "text"):
                if isinstance(e.get(k), str):
                    e[k] = e[k].replace("Forza 5.", "Forza 3.")
    v["constants"]["avanzo_idee"] = True

# I POTENZIAMENTI DI CLASSE (registro 129). Il designer, dopo il confronto
# con le carte stampate: "valgono i dati, togli i bonus di classe, i
# potenziamenti si possono mettere solo su edifici della stessa classe".
# Il bonus "+1 in piu' se l'edificio e' ..." sparisce (sulle carte non c'e'),
# resta la condizione del fiume (stampata come icona dell'acqua).
TESTI_SENZA_BONUS = {
    "po_idolo": "Subito: +1 PV.", "po_reliquia": "Subito: +1 PV.",
    "po_totem": "Subito: +1 PV.", "po_mosaico": "Subito: +1 PV.",
    "po_stemma": "Subito: +1 PV.", "po_terrazza": "Subito: +1 PV.",
    "po_pala_d_altare": "Subito: +2 PV.", "po_murale": "Subito: +2 PV.",
    "po_cannoniere": "L'edificio ha +1 Resistenza.",
    "po_mura_di_cinta": "L'edificio ha +1 Resistenza.",
    "po_torre_di_guardia": "L'edificio ha +1 Resistenza.",
    "po_portico": "Quando attivi l'edificio: +1 Denaro.",
}

def potenziamenti_di_classe(v):
    for u in v["upgrades"]:
        prima = len(u["effects"])
        u["effects"] = [e for e in u["effects"]
                        if "class" not in e.get("condition", {}).get("target", {})]
        if len(u["effects"]) != prima:
            u["effect_text"] = TESTI_SENZA_BONUS[u["id"]]
    assert all(uid in {u["id"] for u in v["upgrades"]} for uid in TESTI_SENZA_BONUS)
    v["constants"]["potenziamento_stessa_classe"] = True

# LE ROVINE E I FLUSSI (registri 130-133), decisioni del designer:
# - TESSERE SCAVO: ogni giocatore ha un mazzetto di 20 tessere del suo colore,
#   da 0 a 3 (media 1,4); quattro scheletri (uno per era), quattro arte.
#   Quando un edificio va in rovina il proprietario ne pesca una per casella
#   e le mette coperte; un edificio dell'era 5 costruito sopra le scopre; a
#   fine partita le scoperte valgono per intero, le coperte a meta', e le
#   icone solo sulle scoperte.
# - PREMIO DI CHI COSTRUISCE SOPRA: la carta della rovina se ne va, quindi si
#   contano le tessere sotto: 2 PV a tessera x livello, meta' nell'era 5 (con
#   1 PV il premio scendeva da 9 a 4 PV e la Lampo crollava).
# - CARTE RESTITUITE: la carta della rovina torna al proprietario; per le
#   regole di mappa le rovine non contano; niente ristrutturare; i
#   potenziamenti sono token che il proprietario riscatta al crollo.
# - IL VALORE DI SCAVO sui Personaggi e sui potenziamenti arte, per l'era (5
#   l'era 1, 1 l'era 5): lo scheletro scoperto fa incassare il miglior
#   Personaggio avuto, l'arte scoperta il miglior token arte riscattato. Gli
#   altri token riscattati non valgono niente.
# - UN POTENZIAMENTO PER CASELLA: la capienza e' larghezza x profondita'.
# - I FLUSSI DI PV: Lampo, Rendita, Scavo e Continuita' devono pesare piu' o
#   meno uguale; il Lampo faceva il doppio della Rendita (22 contro 11 PV).
#   Il Lampo delle ere 4 e 5 (tutte carte da 2) scende a 1; la Rendita 1 sale
#   a 2 (con +1 su tutte la Rendita arrivava a 24 PV); la Continuita' diventa
#   una collezione: per ogni classe, i tuoi edifici in piedi piu' le carte
#   restituite, a soglie.
# Il mazzetto (registro 135): 20 tessere, valore medio 1,4. Quattro scheletri,
# UNO PER ERA ("s": l'era, 1-4): la tessera segna con una linea lo strato
# dell'era e vale lo Scavo del Personaggio preso in quell'era. Quattro arte:
# un giocatore riscatta in media 0,5-0,7 token arte e ne pesca 4 tessere, 4
# icone su 20 gliene fanno trovare 0,8. Due tessere hanno tutte e due.
MAZZO_SCAVO = (
    [{"v": 0}] * 2 + [{"v": 0, "s": 1, "p": True}, {"v": 0, "s": 2}, {"v": 0, "p": True}]
    + [{"v": 1}] * 4 + [{"v": 1, "s": 3}, {"v": 1, "p": True}]
    + [{"v": 2}] * 4 + [{"v": 2, "s": 4, "p": True}]
    + [{"v": 3}] * 4)
assert len(MAZZO_SCAVO) == 20
CONTINUITA_COLLEZIONE = {"3": 3, "5": 5, "7": 8, "9": 12}

def scavo_per_era(era):
    return 6 - int(era) if era else 0

def rovine_e_flussi(v):
    v["constants"]["tessere_scavo"] = {"mazzo": [dict(t) for t in MAZZO_SCAVO],
        "premio": "tessere", "per_tessera": 2, "carte_restituite": True,
        # REGISTRO 147: lo spianato lascia le tessere del proprietario come
        # ogni rovina (senza premio: chi spiana costruisce sopra il proprio).
        # Il designer: "il Terrapieno e' solo ed esclusivamente quando si crea
        # un buco". Prima l'Acquedotto spianato da un edificio largo una
        # colonna diventava tre terrapieni.
        "spianato_lascia_tessere": True}
    v["constants"]["potenziamenti_per_casella"] = True
    for c in v["characters"]:
        c["scavo"] = scavo_per_era(c.get("era"))
    for u in v["upgrades"]:
        if u.get("family") == "arte": u["scavo"] = scavo_per_era(u["era"])
    for b in v["buildings"]:
        if b["era"] >= 4 and b["lampo"] >= 2: b["lampo"] = 1
        if b["rendita"] == 1: b["rendita"] = 2
    v["constants"]["continuita_collezione"] = dict(CONTINUITA_COLLEZIONE)
    # GLI SCHELETRI STANNO SULLE TESSERE (registro 137). Il designer: "le
    # pedine scheletro non servono piu'". Il lavoratore che potenzia non
    # resta piu' sotto l'edificio: gli scheletri sono le icone delle tessere.
    v["constants"]["scheletro_potenziamento"] = False
    # Senza ristrutturare, due carte parlavano di una mossa che non c'e' piu'.
    # Il Restauratore diventa chi vede riportate alla luce le proprie rovine
    # (scoperte dall'era moderna, da chiunque); le Secolarizzazioni tengono
    # solo il colpo alla resistenza.
    l = {x["id"]: x for x in v["legacies"]}["er_il_restauratore"]
    l["condition"] = {"op": "counter", "name": "rovine_scoperte", "min": 2}
    l["condition_text"] = "almeno 2 tue rovine riportate alla luce da un edificio dell'era Moderna."
    e = {x["id"]: x for x in v["events"]}["ev_secolarizzazioni"]
    e["effects"] = [x for x in e["effects"] if x.get("name") != "free_restore_of_class"]
    e["effect_text"] = "Forza 3. Religione −2 res."

# LO SPIANATO CON LE TESSERE (registro 134, da valutare): lo spianato lascia
# le tessere scavo del proprietario come ogni rovina, invece di restare un
# terrapieno senza tessere. Il premio non lo paga comunque.
def spianato_tessere(v):
    v["constants"]["tessere_scavo"]["spianato_lascia_tessere"] = True

# I PERSONAGGI E L'ARTE (registro 138). Misura senza pedine scheletro (750
# partite per tavolo): forti Architetto, Archeologo, Costruttore di zattere,
# Cavaliere; deboli Console, Vescovo, Sacerdotessa, Cardinale, Sciamano,
# Veterano, i due Mercanti, Banchiere, Cronista, Soprintendente, Urbanista.
# Il designer approva: lo Scavo stampato carta per carta (meno ai forti, piu'
# ai deboli; l'era 5 non ne ha, non ci sono scheletri dell'era 5), i testi
# rotti dalle regole nuove, i deboli rinforzati, i forti limati; l'arte vale
# il suo "Subito" + 2.
SCAVO_PERSONAGGI = {
    "pe_capotribu": 5, "pe_costruttore_di_zattere": 4, "pe_mercante_di_ossidiana": 6,
    "pe_sciamano": 6, "pe_incisore": 5,
    "pe_architetto": 2, "pe_legionario": 4, "pe_console": 6, "pe_sacerdotessa": 6, "pe_retore": 4,
    "pe_cavaliere": 2, "pe_mastro_costruttore": 3, "pe_cronista": 4, "pe_mercante": 5, "pe_vescovo": 5,
    "pe_artista_di_corte": 2, "pe_mecenate": 2, "pe_ingegnere_militare": 2, "pe_banchiere": 3,
    "pe_cardinale": 4,
}

def personaggi_e_arte(v):
    ch = {c["id"]: c for c in v["characters"]}
    for c in v["characters"]:
        c["scavo"] = SCAVO_PERSONAGGI.get(c["id"], 0)
    def eff(cid, effetti, testo):
        ch[cid]["effects"] = effetti
        ch[cid]["effect_text"] = testo
    eff("pe_urbanista", [{"hook": "on_final_scoring", "op": "vp_per", "value": 1, "cap": 4, "per": "distinct_era",
        "target": {"owner": "self", "state": ["intatto"], "buried": False}}],
        "Finale: +1 PV per ogni era diversa fra i tuoi edifici in piedi (max +4).")
    e = ch["pe_cronista"]["effects"]
    e[1]["target"] = {"column": {"min_eras": 2}}
    ch["pe_cronista"]["effect_text"] = ("Subito: +1 cultura. Per l'era: quando attivi una colonna che contiene "
        "edifici in piedi di 2+ ere diverse, +1 cultura (max 2).")
    eff("pe_console", [{"hook": "on_acquire", "op": "resource", "pietra": 0, "oro": 1},
        {"hook": "on_activate", "op": "vp", "value": 1, "duration": "era", "cap": 2,
         "target": {"owner": "self", "class": ["civico"]}}],
        "Subito: +1 Denaro. Per l'era: quando attivi una colonna con un tuo edificio Civico in piedi, +1 PV (max 2).")
    ch["pe_mercante"]["effects"][1]["cap"] = 3
    ch["pe_mercante"]["effect_text"] = ("Subito: +1 Denaro. Per l'era: quando un avversario attiva una colonna "
        "con tuoi edifici in piedi, +1 Denaro (max 3).")
    ch["pe_sacerdotessa"]["effects"][1].pop("times", None)
    ch["pe_sacerdotessa"]["effect_text"] = ("Subito: +1 Denaro. Per l'era: ogni edificio Religione che costruisci "
        "ti rimborsa 1 Denaro.")
    eff("pe_vescovo", [{"hook": "on_acquire", "op": "vp", "value": 2},
        {"hook": "on_build", "op": "rule_override", "name": "free_upgrade_of_class", "times": 1,
         "target": {"owner": "self", "class": ["religione"]}}],
        "Subito: +2 cultura. Per l'era: il prossimo potenziamento su un tuo edificio Religione costa 0.")
    ch["pe_cardinale"]["effects"][1]["pietra"] = -1
    ch["pe_cardinale"]["effect_text"] = ("Subito: +1 Denaro. Per l'era: −1 Costruzione e −1 Denaro agli edifici "
        "Religione (minimo 0).")
    eff("pe_banchiere", [{"hook": "on_acquire", "op": "resource", "pietra": 0, "oro": 3, "idee": 1}],
        "Subito: +3 Denaro e +1 Idea.")
    ch["pe_mercante_di_ossidiana"]["effects"][0]["idee"] = 1
    ch["pe_mercante_di_ossidiana"]["effect_text"] = ("Subito: +1 Denaro e +1 Idea. Per l'era: fino a 2 scambi "
        "Costruzione↔Denaro alla pari.")
    ch["pe_sciamano"]["effects"].insert(0, {"hook": "on_acquire", "op": "vp", "value": 1})
    ch["pe_sciamano"]["effect_text"] = "Subito: +1 cultura. Per l'era: i tuoi edifici Religione hanno +1 res."
    eff("pe_veterano", [{"hook": "on_final_scoring", "op": "vp_per", "value": 1, "cap": 5,
        "target": {"owner": "self", "class": ["militare"]}}],
        "Finale: +1 PV per ogni tuo edificio Militare, in piedi o restituito (max +5).")
    eff("pe_soprintendente", [{"hook": "on_final_scoring", "op": "scavo_delta", "value": 2,
        "target": {"owner": "self", "state": ["rovina"]}, "times": 4}],
        "Finale: fino a 4 tue rovine valgono +2 Scavo.")
    ch["pe_architetto"]["effects"][1]["times"] = 1
    ch["pe_architetto"]["effect_text"] = ("Subito: +1 Costruzione. Per l'era: −1 Costruzione al primo edificio "
        "da 2 o 3 caselle.")
    ch["pe_archeologo"]["effects"][0]["cap"] = 4
    ch["pe_archeologo"]["effect_text"] = ("Finale: scegli una tua rovina non sotterrata: vale il suo Scavo "
        "(max 4). Se hai gia' 3+ edifici sotterrati, +1 PV.")
    ch["pe_cavaliere"]["effects"][0]["value"] = 1
    ch["pe_cavaliere"]["effect_text"] = ("Per l'era: la sua protezione vale +3 invece di +2; se l'edificio "
        "protetto sopravvive, +1 cultura.")
    for u in v["upgrades"]:
        if u.get("family") != "arte": continue
        subito = sum(int(x.get("value", 0)) for x in u.get("effects", [])
                     if x["hook"] == "on_acquire" and x["op"] == "vp" and not x.get("condition"))
        u["scavo"] = subito + 2

import sys
variante = sys.argv[sys.argv.index("--variante") + 1] if "--variante" in sys.argv else ""
# Le case in riserva stanno nel file v2 di tutti (registro 116); le varianti di
# prova ci si aggiungono sopra, come misura.
case_tutti(v2, riserva=True, copie=2)
tessere_era(v2)
forme(v2)
potenziamenti_nuovi(v2)
testi_v2(v2)
lampo_tetto(v2)
carte_vive(v2)
eventi_e_avanzo(v2)
potenziamenti_di_classe(v2)
rovine_e_flussi(v2)
personaggi_e_arte(v2)
gilde_era5(v2)
# ---- le varianti del premio di scavo (registro 145) ---------------------
# Il designer: "chi vince e' sempre quello che ha avuto il premio di scavo
# piu' alto [...] nel gioco si deve dare valore a quello che si riscopre a
# fine partita e non viceversa". Misurato: il vincitore ha il premio piu'
# alto nel 59% delle partite a tre (55% a quattro), e il premio vale 10-11 PV
# contro 6 della scoperta di fine partita.
# "premio_meta": il premio scende a 1 PV per tessera (per livello).
# "premio_meta_tessere": in piu' ogni tessera del mazzetto vale il doppio.
def premio_meta(v):
    v["constants"]["tessere_scavo"]["per_tessera"] = 1

def premio_meta_tessere(v):
    premio_meta(v)
    for t in v["constants"]["tessere_scavo"]["mazzo"]:
        t["v"] = 2 * int(t["v"])

if variante:
    {"doppioni": doppioni, "abitazioni": abitazioni, "case": case,
     "case_doppioni": case_doppioni, "case_scavo": case_scavo, "case_nulle": case_nulle,
     "case_mista": case_mista, "case_tutti": case_tutti, "spianato_tessere": spianato_tessere,
     "premio_meta": premio_meta, "premio_meta_tessere": premio_meta_tessere}[variante](v2)
    v2["meta"]["ruleset"] = "v2-" + variante
    v2["meta"]["origine"] = "generato da tools/genera_cards_v2.py --variante %s: non modificare a mano" % variante
    out = os.path.join(RADICE, "data/proposte/cards-v2-%s.json" % variante)
else:
    out = os.path.join(RADICE, "data/cards-v2.json")
json.dump(v2, open(out, "w", encoding="utf-8"), indent=2, ensure_ascii=False)
open(out, "a").write("\n")
n_idee = sum(1 for b in v2["buildings"] if b["cost"]["idee"])
print(f"scritto {os.path.relpath(out, RADICE)}: {n_idee} edifici con Idee nel costo, mix {MIX['3']} a 3 giocatori")
