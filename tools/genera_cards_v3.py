#!/usr/bin/env python3
# Genera data/proposte/cards-v3-era1.json: la v2 (data/cards-v2.json, a sua
# volta generata) con l'ERA 1 riscritta secondo la scheda della v3
# (docs/proposte/v3-era-1.md) e il metro (docs/proposte/v3-metro.md).
# Non si edita a mano: si cambia qui, si rigenera, si committa tutto.
#
#   python3 tools/genera_cards_v2.py && python3 tools/genera_cards_v3.py
#
# La v3, parole del designer (1 ottobre 2026): le risorse nascono e muoiono
# nell'era; i Personaggi si prendono con un draft a passaggio (4 a testa, se ne
# tiene uno e si passa) e sono gli unici lavoratori, con produzione e azione
# quando si piazzano; ogni edificio ha produzione e azione, che scattano per il
# proprietario a ogni attivazione della colonna. Qui c'e' solo l'era 1 scritta
# cosi': le ere 2-5 restano quelle della v2, con i Personaggi della v2 piu'
# dei "Lavoratori" senza niente per arrivare a 16, cosi' una partita lasciata
# andare oltre l'era 1 non si rompe. Si misura con `--fino_era 1`.
import json, os

RADICE = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..")
base = json.load(open(os.path.join(RADICE, "data/cards-v2.json"), encoding="utf-8"))
v3 = json.loads(json.dumps(base))
v3["meta"]["ruleset"] = "v3-era1-prova"
v3["meta"]["origine"] = "generato da tools/genera_cards_v3.py da data/cards-v2.json: non modificare a mano"

# ---- le costanti della prova (scheda, "Le regole della prova") ----------
c = v3["constants"]
c["turno_v3"] = True                       # il lavoratore e' un Personaggio: produce e agisce
c["draft_passaggio"] = {"mano": 4, "direzione": "alternata"}   # 1,3,5 a destra; 2,4 a sinistra
c["personaggi_per_era"] = 16
c["risorse_muoiono"] = True                # a fine era le risorse vanno a zero, niente dispersione
c["resource_cap"] = 99                     # nessun tetto dentro l'era
c["resource_cap_per_resource"] = 0
c["avanzo_idee"] = False
c["azione_edificio"] = "proprietario"      # l'azione dell'edificio scatta per chi lo possiede
c["start_resources"] = {"pietra": 0, "oro": 0, "idee": 0}   # si parte da zero, anche nell'era 1
c["second_player_bonus_2p"] = {"oro": 0}
# IL SOFFIO NON VALE PER LA RESISTENZA 1 (registro 193). Il designer: "questi
# edifici a resistenza 1 nell'era preistorica non dovrebbero sopravvivere
# all'era moderna". Chi ha resistenza stampata sotto questa soglia, se
# fallisce l'evento crolla, anche di 1 solo; gli altri reggono per un soffio.
c["soffio_resistenza_min"] = 2
# GLI EVENTI DELL'ERA 5 (registro 196). Il designer: "vorrei gli eventi anche
# per la 5 era, non mi piace che ce ne sia solo uno, bisogna allinearlo con le
# altre ere". Al posto del solo Giudizio del tempo (registro 149: forza 4,
# nessun effetto) sei eventi come nelle altre ere - tre lievi e tre gravi, uno
# geografico, uno di classe e uno di comportamento per gruppo. FORZA 3, come
# l'era 4 (registro 198): a forza 4 - quella che il Giudizio del tempo aveva -
# le carte dell'era 5, quasi tutte da 3, vivevano solo per il soffio e con un
# -1 qualunque crollava meta' dell'era Moderna (misure 62-63); a forza 3
# crolla un edificio su sette e i finali restano (64ª). Gli effetti usano solo
# i selettori che il motore ha gia' (terreno, classe, protezione, produzione,
# colonna).
c.pop("evento_finale", None)
c["event_force_by_era"]["5"] = 3          # la forza che il bot si aspetta per l'era 5 (registro 197)
EVENTI_ERA_5 = [
    {"id": "ev_subsidenza", "name": "Subsidenza", "era": 5, "force": 3, "severity": "lieve", "kind": "geografico",
     "effect_text": "Forza 3. Edifici su pianura e fiume: −1 res.",
     "effects": [{"hook": "on_event", "op": "resistance", "value": -1, "target": {"terrain": ["pianura", "fiume"]}}]},
    {"id": "ev_globalizzazione", "name": "Globalizzazione", "era": 5, "force": 3, "severity": "lieve", "kind": "classe",
     "effect_text": "Forza 3. Commercio +1 res · Cultura −1 res.",
     "effects": [{"hook": "on_event", "op": "resistance", "value": 1, "target": {"class": ["commercio"]}},
                 {"hook": "on_event", "op": "resistance", "value": -1, "target": {"class": ["cultura"]}}]},
    {"id": "ev_crisi_energetica", "name": "Crisi energetica", "era": 5, "force": 3, "severity": "lieve", "kind": "comportamentale",
     "effect_text": "Forza 3. Edifici non protetti che producono risorse: −1 res.",
     "effects": [{"hook": "on_event", "op": "resistance", "value": -1, "target": {"protected": False, "produces": True}}]},
    {"id": "ev_innalzamento_dei_mari", "name": "Innalzamento dei mari", "era": 5, "force": 3, "severity": "grave", "kind": "geografico",
     "effect_text": "Forza 3. Edifici su fiume: −2 res · su pianura: −1 res.",
     "effects": [{"hook": "on_event", "op": "resistance", "value": -2, "target": {"terrain": ["fiume"]}},
                 {"hook": "on_event", "op": "resistance", "value": -1, "target": {"terrain": ["pianura"]}}]},
    {"id": "ev_crisi_dello_stato", "name": "Crisi dello Stato", "era": 5, "force": 3, "severity": "grave", "kind": "classe",
     "effect_text": "Forza 3. Civico −2 res · Militare −1 res · Ingegneria +1 res.",
     "effects": [{"hook": "on_event", "op": "resistance", "value": -2, "target": {"class": ["civico"]}},
                 {"hook": "on_event", "op": "resistance", "value": -1, "target": {"class": ["militare"]}},
                 {"hook": "on_event", "op": "resistance", "value": 1, "target": {"class": ["ingegneria"]}}]},
    {"id": "ev_guerra_mondiale", "name": "Guerra mondiale", "era": 5, "force": 3, "severity": "grave", "kind": "comportamentale",
     "effect_text": "Forza 3. Nelle colonne con edifici di 2+ giocatori: tutti −1 res. Militare −1 res.",
     "effects": [{"hook": "on_event", "op": "resistance", "value": -1, "target": {"column": {"min_owners": 2}}},
                 {"hook": "on_event", "op": "resistance", "value": -1, "target": {"class": ["militare"]}}]},
]
v3["events"].extend(EVENTI_ERA_5)
#   --variante senza_soffio  o dentro o fuori (registro 199): resistenza sotto la forza = crolla, anche di 1;
#                            niente "regge per un soffio", forze com'erano
def senza_soffio(v):
    v["constants"]["rovina_gap"] = 1
    v["constants"].pop("soffio_resistenza_min", None)
#   --variante senza_soffio_forze  come senza_soffio, ma ogni evento scende di 1 di forza: e' il conto di oggi
#                                  scritto pulito (chi reggeva per un soffio regge, chi crollava crolla)
def senza_soffio_forze(v):
    senza_soffio(v)
    for k in list(v["constants"]["event_force_by_era"]):
        v["constants"]["event_force_by_era"][k] = int(v["constants"]["event_force_by_era"][k]) - 1
    for e in v["events"]:
        if "force" in e and int(e["force"]) > 0:
            nuova = int(e["force"]) - 1
            e["effect_text"] = e["effect_text"].replace("Forza %d." % int(e["force"]), "Forza %d." % nuova)
            e["force"] = nuova
#   --variante eventi5_forza4  i sei eventi dell'era 5 a forza 4, la forza del Giudizio (misure 62-63: meta' dell'era 5 crolla)
def eventi5_forza4(v):
    v["constants"]["event_force_by_era"]["5"] = 4
    for e in v["events"]:
        if int(e["era"]) == 5:
            e["force"] = 4
            e["effect_text"] = e["effect_text"].replace("Forza 3.", "Forza 4.")
#   --variante giudizio_solo  l'era 5 col solo Giudizio del tempo (forza 4, nessun effetto), com'era prima del registro 196
def giudizio_solo(v):
    v["events"] = [e for e in v["events"] if int(e["era"]) != 5]
    v["constants"]["event_force_by_era"]["5"] = 4     # il Giudizio e' di forza 4
    v["constants"]["evento_finale"] = json.loads(json.dumps(base["constants"]["evento_finale"]))
# Niente Dinastia nella prova: la carta resta (il motore la cerca) ma senza copie.
for ch in v3["characters"]:
    if ch.get("is_dynasty"):
        ch["copies"] = 0

# ---- il vocabolario delle azioni (metro) ---------------------------------
# Un'azione e' un dizionario con `tipo` e i suoi parametri; `testo` e' per la
# carta stampata. Le scelte che un'azione richiede (quale risorsa cambiare,
# quale edificio proteggere) le fanno i bot con una regola fissa, scritta in
# scripts/rules/personaggi_v3.gd; per le persone verranno dopo, come domande.
def risorsa(pietra=0, oro=0, idee=0, se=None):
    a = {"tipo": "risorsa", "pietra": pietra, "oro": oro, "idee": idee}
    if se: a["se"] = se                     # "proprio" = solo se chi attiva sei tu; "altrui" = solo se non sei tu
    return a
def cambio(n=1, da=None, a=None):
    x = {"tipo": "cambio", "n": n}
    if da: x["da"] = da; x["a"] = a
    return x
def pv(n=1, classe=None, dove="colonna", minimo=1):
    x = {"tipo": "pv", "n": n}
    if classe: x["se"] = {"classe": classe, "dove": dove, "min": minimo}
    return x
def resistenza(n=1, a="uno", classe=None):
    x = {"tipo": "resistenza", "n": n, "a": a}   # uno | tutti | abitato | adiacente | adiacenti
    if classe: x["classe"] = classe
    return x
def sconto(n=1, se=None):
    x = {"tipo": "sconto", "n": n}
    if se: x["se"] = se                     # "fiume" (costruzione su fiume) | "arte" (potenziamento Arte)
    return x
def scavo(n=1, a="uno"):
    return {"tipo": "scavo", "n": n, "a": a}
def lampo(n=1):
    return {"tipo": "lampo", "n": n}
def altri(oro=1, massimo=2, se=None):
    x = {"tipo": "altri", "oro": oro, "max": massimo}
    if se: x["se"] = se
    return x
NESSUNA = {"tipo": "nessuna"}

def prod(pietra=0, oro=0, idee=0):
    return {"pietra": pietra, "oro": oro, "idee": idee}

# ---- i 16 Personaggi dell'era 1 (scheda, "I 16 Personaggi") ---------------
PERSONAGGI_E1 = [
    ("pe_capotribu", "Capotribù", "civico", prod(pietra=1), resistenza(1, "uno"),
     "Produce 1 Costruzione. +1 resistenza fino a fine era a un tuo edificio in questa colonna."),
    ("pe_anziana_del_villaggio", "Anziana del villaggio", "civico", prod(pietra=1), cambio(1),
     "Produce 1 Costruzione. Cambia 1 risorsa in un'altra."),
    ("pe_cacciatore", "Cacciatore", "civico", prod(pietra=1), lampo(1),
     "Produce 1 Costruzione. +1 Lampo all'edificio che costruisci in questo turno."),
    ("pe_sciamano", "Sciamano", "religione", prod(idee=1), pv(1, "religione", "colonna", 1),
     "Produce 1 Idea. +1 PV se hai un edificio Religione in piedi in questa colonna."),
    ("pe_guardiano_del_fuoco", "Guardiano del fuoco", "religione", prod(pietra=1), resistenza(1, "tutti", "religione"),
     "Produce 1 Costruzione. +1 resistenza fino a fine era a ogni tuo Religione in questa colonna."),
    ("pe_custode_delle_ossa", "Custode delle ossa", "religione", prod(idee=1), scavo(1, "uno"),
     "Produce 1 Idea. +1 Scavo permanente a un tuo edificio in questa colonna."),
    ("pe_mercante_di_ossidiana", "Mercante di ossidiana", "commercio", prod(oro=1), cambio(2),
     "Produce 1 Denaro. Fino a 2 cambi 1:1."),
    ("pe_barattatore", "Barattatore", "commercio", prod(pietra=1, oro=1), NESSUNA,
     "Produce 1 Costruzione e 1 Denaro. Nessuna azione."),
    ("pe_portatore_di_sale", "Portatore di sale", "commercio", prod(oro=1), altri(1, 2),
     "Produce 1 Denaro. +1 Denaro per ogni altro giocatore con un edificio in questa colonna (max 2)."),
    ("pe_incisore", "Incisore", "cultura", prod(idee=1), scavo(2, "uno"),
     "Produce 1 Idea. +2 Scavo permanente a un tuo edificio in questa colonna."),
    ("pe_cantastorie", "Cantastorie", "cultura", prod(idee=1), pv(1),
     "Produce 1 Idea. +1 PV."),
    ("pe_pittore_delle_grotte", "Pittore delle grotte", "cultura", prod(idee=1), sconto(1, "arte"),
     "Produce 1 Idea. Il potenziamento Arte che compri in questo turno costa 1 in meno."),
    ("pe_costruttore_di_zattere", "Costruttore di zattere", "ingegneria", prod(pietra=1), sconto(1, "fiume"),
     "Produce 1 Costruzione. −1 Costruzione se costruisci su fiume in questo turno."),
    ("pe_tagliapietre", "Tagliapietre", "ingegneria", prod(pietra=1), sconto(1),
     "Produce 1 Costruzione. −1 Costruzione alla costruzione di questo turno."),
    ("pe_guerriero", "Guerriero", "militare", prod(pietra=1), resistenza(2, "abitato"),
     "Produce 1 Costruzione. +2 resistenza fino a fine era all'edificio su cui sta."),
    ("pe_sentinella", "Sentinella", "militare", prod(oro=1), resistenza(1, "tutti"),
     "Produce 1 Denaro. +1 resistenza fino a fine era a ogni tuo edificio in questa colonna."),
]
assert len(PERSONAGGI_E1) == 16

def personaggio(cid, nome, classe, era, produzione, azione, testo):
    return {"id": cid, "name": nome, "era": era, "class": classe, "is_dynasty": False,
            "timing": "v3", "imprint": False, "effect_text": testo, "effects": [],
            "scavo": 0, "produzione": produzione, "azione": azione}

altri_personaggi = [ch for ch in v3["characters"] if ch.get("era") != 1]
nuovi = [personaggio(cid, nome, cl, 1, pr, az, testo) for cid, nome, cl, pr, az, testo in PERSONAGGI_E1]
# Le ere 2-5 restano quelle della v2 (5 Personaggi l'una, con i loro effetti);
# si arriva a 16 con dei Lavoratori senza produzione e senza azione, cosi' il
# draft a passaggio funziona anche li' e la partita puo' continuare.
riempitivi = []
for era in range(6, 6):    # nessuna era da riempire: tutte e cinque hanno i loro 16 (registro 163)
    quanti = sum(1 for ch in altri_personaggi if ch.get("era") == era)
    for k in range(quanti, c["personaggi_per_era"]):
        riempitivi.append(personaggio("pe_lavoratore_e%d_%02d" % (era, k + 1), "Lavoratore", "civico", era,
                                      prod(), NESSUNA, "Un lavoratore qualunque (riempitivo della prova)."))
v3["characters"] = nuovi + altri_personaggi + riempitivi

# ---- i 15 edifici dell'era 1 (scheda, "I 15 edifici") ----------------------
AZIONI_E1 = {
    "ed_capanne": cambio(1),
    "ed_palafitte": risorsa(oro=1),
    "ed_focolare_comune": risorsa(pietra=1),
    "ed_dolmen": resistenza(1, "adiacente"),
    "ed_menhir": risorsa(idee=1),
    "ed_circolo_di_pietre": pv(1, "religione", "ovunque", 2),
    "ed_approdo": risorsa(oro=1, se="altrui"),
    "ed_cava": cambio(1, "pietra", "oro"),
    "ed_grotte_dipinte": risorsa(idee=1),
    "ed_tumulo_funerario": scavo(1, "adiacente"),
    "ed_trappole_da_pesca": risorsa(pietra=1, se="proprio"),
    "ed_villaggio_palizzato": resistenza(1, "adiacenti"),
}
TESTI_E1 = {
    "ed_capanne": "A ogni attivazione: cambia 1 risorsa in un'altra.",
    "ed_palafitte": "A ogni attivazione: +1 Denaro.",
    "ed_focolare_comune": "A ogni attivazione: +1 Costruzione.",
    "ed_dolmen": "A ogni attivazione: +1 resistenza fino a fine era a un tuo edificio adiacente.",
    "ed_menhir": "A ogni attivazione: +1 Idea.",
    "ed_circolo_di_pietre": "A ogni attivazione: +1 PV se hai 2+ edifici Religione in piedi.",
    "ed_approdo": "A ogni attivazione di un avversario: +1 Denaro.",
    "ed_cava": "A ogni attivazione: cambia 1 Costruzione in 1 Denaro.",
    "ed_grotte_dipinte": "A ogni attivazione: +1 Idea.",
    "ed_tumulo_funerario": "A ogni attivazione: +1 Scavo permanente a un tuo edificio adiacente.",
    "ed_trappole_da_pesca": "A ogni tua attivazione: +1 Costruzione.",
    "ed_villaggio_palizzato": "A ogni attivazione: +1 resistenza fino a fine era ai tuoi edifici adiacenti.",
}
# Rendita da 2 a 1 su Dolmen e Menhir (metro: la Rendita dell'era 1 vale fino
# a 4 censimenti), da misurare contro il 2 di oggi. Il Circolo resta a 2.
RENDITA_E1 = {"ed_dolmen": 1, "ed_menhir": 1}
for b in v3["buildings"]:
    if b["era"] != 1: continue
    if b["id"] in AZIONI_E1:
        b["azione"] = AZIONI_E1[b["id"]]
        # L'effetto "negli eventi" o "quando lo attivi" di oggi e' sostituito
        # dall'azione: via gli effetti vecchi, cosi' non scattano due volte.
        b["effects"] = []
        b["effect_text"] = TESTI_E1[b["id"]]
    else:
        b["azione"] = NESSUNA                  # le case sono case
    if b["id"] in RENDITA_E1:
        b["rendita"] = RENDITA_E1[b["id"]]

# ---- la catena e i costi misti nel file base (registri 156-157) --------------
# Il designer, letta la misura delle leve del pozzo: "catena si' e costi misti",
# "l'acquisto extra non si fa sempre, ci vuole un effetto di una carta o
# personaggio o edificio o tessera", "i giocatori devono poter comprare sempre
# almeno un edificio, magari le case di fango o qualcosa che costa poco".
# Il terreno di base non produce: resta la tessera dell'era.
for t in v3["terrains"]:
    t["produzione_base"] = {"pietra": 0, "oro": 0, "idee": 0}
    t["base_production_by_era"] = {e: {"pietra": 0, "oro": 0, "idee": 0} for e in "12345"}
# Spianare caro (registro 152): niente sconto a chi spiana il proprio edificio.
c["spianare_costo"] = 1
# I costi misti: +1 della seconda risorsa della classe (Commercio e Civico
# Denaro, Religione e Cultura Idee, Ingegneria e Militare Costruzione). Le case
# della riserva restano come sono: una casa deve restare comprabile sempre.
SECONDA = {"commercio": "oro", "civico": "oro", "religione": "idee", "cultura": "idee",
           "ingegneria": "pietra", "militare": "pietra"}
for b in v3["buildings"]:
    if b["era"] != 1 or b.get("riserva"): continue
    b["cost"][SECONDA[b["classes"][0]]] += 1
# I COSTI RIMODULATI (registro 161). Il designer: "rimodulare i costi tu in modo
# da rendere risorse prodotte e spese nella giusta proporzione". Con i costi
# misti puri (sopra) la domanda era 5,0 Costruzione, 1,5 Denaro, 2,5 Idee a
# testa contro un'offerta di 4,3 / 2,6 / 3,0: la Costruzione mancava, il Denaro
# avanzava, e le carte da 2 Idee (Dolmen, Menhir, Grotte, Tumulo) restavano
# nel mercato. Qui ogni carta del mazzo chiede due o tre risorse di tipo
# diverso, mai due uguali, e la domanda si avvicina all'offerta; la tabella e'
# il punto di partenza da cui si misura e si ritocca.
# Secondo giro dei costi: l'edificio chiede la risorsa che i SUOI potenziamenti
# non chiedono (`potenziamento_stessa_classe`: Civico e Commercio prendono i
# potenziamenti "altro" a 1 Denaro, Religione e Cultura l'Arte a 1 Idea), cosi'
# quel che resta dopo la costruzione compra il potenziamento. Nel primo giro
# (Civico 1 Costruzione 1 Denaro, Religione 1 Costruzione 1 Idea) morivano 1,6
# Idee a testa e i potenziamenti restavano a 0,7.
COSTI_E1 = {
    "ed_capanne":             prod(pietra=1, idee=1),
    "ed_palafitte":           prod(pietra=1, idee=1),
    "ed_focolare_comune":     prod(pietra=1),            # terzo giro: a 2 risorse non si costruiva (0,13)
    "ed_approdo":             prod(pietra=1, idee=1),
    "ed_cava":                prod(pietra=1, idee=1),
    "ed_trappole_da_pesca":   prod(pietra=1),            # terzo giro: idem (0,03); produce 1, Scavo 0
    "ed_dolmen":              prod(pietra=1, oro=1),
    "ed_menhir":              prod(pietra=1, oro=1),
    "ed_circolo_di_pietre":   prod(pietra=2, oro=1, idee=1),
    "ed_grotte_dipinte":      prod(pietra=1, oro=1),
    "ed_tumulo_funerario":    prod(pietra=1, oro=1),
    "ed_villaggio_palizzato": prod(pietra=2),
}
for b in v3["buildings"]:
    if b["id"] in COSTI_E1:
        b["cost"] = dict(COSTI_E1[b["id"]])
# Non si spiana un edificio della stessa era, solo quelli delle ere precedenti.
c["spiana_solo_ere_precedenti"] = True
# La casa che si compra sempre: i Ripari costano 1, Costruzione o Denaro a scelta.
for b in v3["buildings"]:
    if b["id"] == "ed_casa_e1_s":
        b["flexible"] = True
# L'acquisto extra solo da un effetto: due Personaggi (il Capotribu' organizza,
# il Mercante fa comprare), due edifici quando li attiva il proprietario (le
# Capanne e la Cava), e una tessera dell'era (il Sentiero dei pastori).
ACQUISTO = {"tipo": "acquisto", "n": 1}
EXTRA_PERSONAGGI = {
    "pe_capotribu": "Produce 1 Costruzione. In questo turno puoi comprare ancora un potenziamento o una casa.",
    "pe_mercante_di_ossidiana": "Produce 1 Denaro. In questo turno puoi comprare ancora un potenziamento o una casa.",
}
for ch in v3["characters"]:
    if ch["id"] in EXTRA_PERSONAGGI:
        ch["azione"] = dict(ACQUISTO)
        ch["effect_text"] = EXTRA_PERSONAGGI[ch["id"]]
EXTRA_EDIFICI = {
    "ed_capanne": "A ogni tua attivazione: puoi comprare ancora un potenziamento o una casa.",
    "ed_cava": "A ogni tua attivazione: puoi comprare ancora un potenziamento o una casa.",
}
for b in v3["buildings"]:
    if b["id"] in EXTRA_EDIFICI:
        b["azione"] = dict(ACQUISTO)
        b["effect_text"] = EXTRA_EDIFICI[b["id"]]
for t in v3["tessere_era"]:
    if t["id"] == "te_sentiero_dei_pastori":
        t["effetto"] = {"quando": "attiva", "extra": 1}
        t["testo"] = "Chi attiva per primo puo' comprare ancora un potenziamento o una casa in quel turno."

# ---- gli sconti (registro 161) -------------------------------------------------
# Il designer: "alcuni effetti potrebbero scontare dei tipi di potenziamenti o
# edifici". Due Personaggi che il draft lasciava per ultimi: il Guardiano del
# fuoco sconta gli edifici Religione, il Custode delle ossa sconta un
# potenziamento qualunque. Il Pittore delle grotte scontava gia' l'Arte.
SCONTI = {
    "pe_guardiano_del_fuoco": (sconto(1, "classe:religione"),
        "Produce 1 Idea. −1 al costo dell'edificio Religione che costruisci in questo turno."),
    "pe_custode_delle_ossa": (sconto(1, "potenziamento"),
        "Produce 1 Idea. Il potenziamento che compri in questo turno costa 1 in meno."),
}
for ch in v3["characters"]:
    if ch["id"] in SCONTI:
        ch["azione"], ch["effect_text"] = SCONTI[ch["id"]]

# ---- il tuning delle risorse (registro 159) ------------------------------------
# Il designer, letta la trentaduesima misura ("un'era di case", potenziamenti a
# zero): "un tuning delle risorse: se Idee e Denaro sono poco bisogna alzarle,
# poi i potenziamenti devono essere comprati". Si producevano 5,5 Costruzione,
# 1,5 Denaro e 1,7 Idee a testa, e le carte del mazzo chiedono Denaro o Idee.
# Le quattro tessere dell'era 1 che non producevano niente ora danno Denaro o
# Idee; tre Personaggi passano dalla Costruzione a Denaro e Idee (fra i 16, in
# unita': Costruzione 5, Denaro 6, Idee 7, invece di 10/4/5).
# Secondo giro (registro 161): la Radura torna a Costruzione e l'Anziana del
# villaggio pure, perche' con i costi rimodulati mancava Costruzione (4,0
# prodotte contro 4,8 chieste) e avanzavano Idee.
TESSERE_PRODUZIONE = {"te_radura": prod(pietra=1), "te_sentiero_dei_pastori": prod(oro=1),
                      "te_terra_di_nessuno": prod(oro=1), "te_luogo_sacro": prod(idee=1)}
for t in v3["tessere_era"]:
    if t["id"] in TESSERE_PRODUZIONE:
        t["produzione"] = TESSERE_PRODUZIONE[t["id"]]
PERSONAGGI_PRODUZIONE = {"pe_guardiano_del_fuoco": prod(idee=1), "pe_anziana_del_villaggio": prod(pietra=1),
                         "pe_barattatore": prod(oro=1, idee=1)}
TESTI_PRODUZIONE = {"pe_guardiano_del_fuoco": "Produce 1 Idea. −1 al costo dell'edificio Religione che costruisci in questo turno.",
                    "pe_anziana_del_villaggio": "Produce 1 Costruzione. Cambia 1 risorsa in un'altra.",
                    "pe_barattatore": "Produce 1 Denaro e 1 Idea. Nessuna azione."}
for ch in v3["characters"]:
    if ch["id"] in PERSONAGGI_PRODUZIONE:
        ch["produzione"] = PERSONAGGI_PRODUZIONE[ch["id"]]
        ch["effect_text"] = TESTI_PRODUZIONE[ch["id"]]
# I potenziamenti si comprano anche nelle colonne accanto a quella attivata
# (registro 126): nell'era 1 i propri edifici stanno sulle colonne gia'
# attivate, e senza questo nessuno li compra.
c["potenzia_adiacente"] = True

# ---- il potenziamento insieme alla costruzione (registro 160) ----------------
# Il designer: "i potenziamenti non sono un'azione a parte ma possono essere
# presi insieme agli edifici se il giocatore ha risorse sufficienti. Se non
# bastano rimetterei la produzione base dei terreni". La costante apre, dopo
# ogni costruzione, l'acquisto di un potenziamento (pagato, senza lavoratore);
# la variante `terreno_produce` rimette la produzione base dei terreni della v2.
c["potenziamento_con_costruzione"] = True

# ---- gli scheletri: lo Scavo dei Personaggi (registro 162) ---------------------
# A fine partita una tessera scavo con lo scheletro vale lo Scavo stampato del
# Personaggio preso in quell'era (registro 135). I Personaggi della v3 ne hanno
# uno ciascuno; e' anche una leva del draft: chi arriva ultimo nel draft vale di
# piu' da scheletro.
SCAVO_V3 = {
    "pe_guerriero": 2, "pe_cacciatore": 2, "pe_tagliapietre": 2, "pe_capotribu": 3,
    "pe_costruttore_di_zattere": 3, "pe_anziana_del_villaggio": 3, "pe_cantastorie": 3,
    "pe_incisore": 4, "pe_portatore_di_sale": 4, "pe_sentinella": 4, "pe_sciamano": 5,
    "pe_guardiano_del_fuoco": 5, "pe_pittore_delle_grotte": 5, "pe_barattatore": 5,
    "pe_custode_delle_ossa": 6, "pe_mercante_di_ossidiana": 6,
}

# ---- l'era 2 (registro 162, docs/proposte/v3-era-2.md) --------------------------
# Lo stesso schema dell'era 1: 16 Personaggi con produzione e azione, 15
# edifici con azione, costi con la regola "l'edificio chiede la risorsa che i
# suoi potenziamenti non chiedono", un gradino piu' cari dell'era 1. Cinque
# Personaggi sono quelli della v2 riscritti, undici nuovi.
PERSONAGGI_E2 = [
    ("pe_console", "Console", "civico", prod(oro=1), pv(1, "civico", "colonna", 1), 3,
     "Produce 1 Denaro. +1 PV se hai un edificio Civico in piedi in questa colonna."),
    ("pe_edile", "Edile", "civico", prod(pietra=1), ACQUISTO, 3,
     "Produce 1 Costruzione. In questo turno puoi comprare ancora un potenziamento o una casa."),
    ("pe_tribuno", "Tribuno della plebe", "civico", prod(pietra=1), cambio(1), 2,
     "Produce 1 Costruzione. Cambia 1 risorsa in un'altra."),
    ("pe_sacerdotessa", "Sacerdotessa", "religione", prod(idee=1), sconto(1, "classe:religione"), 5,
     "Produce 1 Idea. −1 al costo dell'edificio Religione che costruisci in questo turno."),
    ("pe_augure", "Augure", "religione", prod(pietra=1), resistenza(1, "uno"), 4,
     "Produce 1 Costruzione. +1 resistenza fino a fine era a un tuo edificio in questa colonna."),
    ("pe_pontefice", "Pontefice", "religione", prod(pietra=1), pv(1, "religione", "ovunque", 2), 5,
     "Produce 1 Costruzione. +1 PV se hai 2+ edifici Religione in piedi."),
    ("pe_negotiator", "Negotiator", "commercio", prod(oro=1), altri(1, 2), 4,
     "Produce 1 Denaro. +1 Denaro per ogni altro giocatore con un edificio in questa colonna (max 2)."),
    ("pe_armatore", "Armatore", "commercio", prod(pietra=1, oro=1), NESSUNA, 5,
     "Produce 1 Costruzione e 1 Denaro. Nessuna azione."),
    ("pe_argentario", "Argentario", "commercio", prod(oro=1), ACQUISTO, 6,
     "Produce 1 Denaro. In questo turno puoi comprare ancora un potenziamento o una casa."),
    ("pe_retore", "Retore", "cultura", prod(idee=1), scavo(2, "uno"), 4,
     "Produce 1 Idea. +2 Scavo permanente a un tuo edificio in questa colonna."),
    ("pe_poeta", "Poeta", "cultura", prod(idee=1), pv(1), 3,
     "Produce 1 Idea. +1 PV."),
    ("pe_mosaicista", "Mosaicista", "cultura", prod(idee=1), sconto(1, "arte"), 5,
     "Produce 1 Idea. Il potenziamento Arte che compri in questo turno costa 1 in meno."),
    ("pe_architetto", "Architetto", "ingegneria", prod(pietra=1), sconto(1), 2,
     "Produce 1 Costruzione. −1 Costruzione alla costruzione di questo turno."),
    ("pe_agrimensore", "Agrimensore", "ingegneria", prod(pietra=1), {"tipo": "adiacente"}, 3,
     "Produce 1 Costruzione. Prendi anche la produzione della tessera di una colonna accanto."),
    ("pe_legionario", "Legionario", "militare", prod(pietra=1), resistenza(2, "abitato"), 2,
     "Produce 1 Costruzione. +2 resistenza fino a fine era all'edificio su cui sta."),
    ("pe_centurione", "Centurione", "militare", prod(pietra=1), resistenza(1, "tutti"), 4,
     "Produce 1 Costruzione. +1 resistenza fino a fine era a ogni tuo edificio in questa colonna."),
]
assert len(PERSONAGGI_E2) == 16
def personaggio_scavo(cid, nome, classe, produzione, azione, sc, testo, era=2):
    ch = personaggio(cid, nome, classe, era, produzione, azione, testo)
    ch["scavo"] = sc
    return ch
v3["characters"] = [ch for ch in v3["characters"] if ch.get("era") != 2] + \
    [personaggio_scavo(*riga) for riga in PERSONAGGI_E2]   # via i cinque della v2 e i riempitivi dell'era 2
for ch in v3["characters"]:
    if ch["id"] in SCAVO_V3: ch["scavo"] = SCAVO_V3[ch["id"]]

# Gli edifici dell'era 2: costo, Rendita (2 solo dove costa 4 o piu'), azione.
# Terzo giro della coppia (registro 162): i costi come l'era 1 (due risorse di
# tipo diverso), un gradino in piu' solo alle carte grandi (Acquedotto, Ponte,
# Foro, Anfiteatro). Al secondo giro, con quasi tutto a tre risorse, si
# costruivano 2,8 edifici a testa e le case erano 3,6 su 7,3.
EDIFICI_E2 = {
    "ed_teatro":           (prod(pietra=1, oro=1),         None, pv(1),                        "A ogni attivazione: +1 PV."),
    "ed_acquedotto":       (prod(pietra=2, oro=1, idee=1), 2,    risorsa(idee=1),              "A ogni attivazione: +1 Idea."),
    "ed_terme":            (prod(pietra=1, idee=1),        None, cambio(1),                    "A ogni attivazione: cambia 1 risorsa in un'altra."),
    "ed_sacello":          (prod(pietra=1, oro=1),         None, resistenza(1, "adiacente"),   "A ogni attivazione: +1 resistenza fino a fine era a un tuo edificio adiacente."),
    "ed_torre_di_vedetta": (prod(pietra=2),                None, resistenza(1, "adiacenti"),   "A ogni attivazione: +1 resistenza fino a fine era ai tuoi edifici adiacenti."),
    "ed_tempio":           (prod(pietra=1, oro=1),         1,    pv(1, "religione", "ovunque", 2), "A ogni attivazione: +1 PV se hai 2+ edifici Religione in piedi."),
    "ed_ponte":            (prod(pietra=2, oro=1),         1,    risorsa(pietra=1),            "A ogni attivazione: +1 Costruzione."),
    "ed_emporio":          (prod(pietra=1, idee=1),        None, risorsa(oro=1, se="altrui"),  "A ogni attivazione di un avversario: +1 Denaro."),
    "ed_insulae":          (prod(pietra=1, idee=1),        None, risorsa(pietra=1),            "A ogni attivazione: +1 Costruzione."),
    "ed_foro":             (prod(pietra=2, oro=1, idee=1), 2,    altri(1, 2),                  "A ogni attivazione: +1 Denaro per ogni altro giocatore con un edificio in questa colonna (max 2)."),
    "ed_anfiteatro":       (prod(pietra=3, oro=1, idee=1), 2,    pv(1),                        "A ogni attivazione: +1 PV."),
    "ed_castrum":          (prod(pietra=2),                None, resistenza(1, "tutti"),       "A ogni attivazione: +1 resistenza fino a fine era ai tuoi edifici in questa colonna."),
}
for b in v3["buildings"]:
    if b["era"] != 2: continue
    if b["id"] in EDIFICI_E2:
        costo, rendita, azione, testo = EDIFICI_E2[b["id"]]
        b["cost"] = dict(costo)
        if rendita is not None: b["rendita"] = rendita
        b["azione"] = azione
        # Via gli effetti "negli eventi" e l'aura del Ponte: ora sono azioni.
        if b["id"] in ("ed_torre_di_vedetta", "ed_castrum", "ed_ponte"):
            b["effects"] = []
        b["effect_text"] = testo
    else:
        b["azione"] = NESSUNA                  # le case sono case
    if b["id"] == "ed_casa_e2_s": b["flexible"] = True   # i Tuguri a 1, Costruzione o Denaro
# Le tessere dell'era 2 producevano quasi solo Costruzione: due passano al Denaro.
for t in v3["tessere_era"]:
    if t["id"] == "te_cambiavalute": t["produzione"] = prod(oro=1)
    # Primo giro della coppia: nell'era 2 si producevano 13,5 risorse e ne
    # morivano 5,3 (2,9 Idee). Le tre tessere con l'effetto piu' forte non
    # producono (Via consolare, Cantiere, Necropoli), come quattro dell'era 1.
    if t["id"] in ("te_via_consolare", "te_cantiere", "te_necropoli"): t["produzione"] = prod()

# ---- le ere 3, 4 e 5 (registro 163) ---------------------------------------------
# Lo stesso schema delle ere 1 e 2. I 16 Personaggi di ogni era seguono uno
# STAMPO uguale (tre Civici, tre Religione, tre Commercio, tre Cultura, due
# Ingegneria, due Militare, con le stesse sedici azioni e la produzione 9/4/4
# che nell'era 2 ha dato il morto piu' basso): cambiano i nomi, e i cinque
# Personaggi della v2 di ogni era prendono il posto che gli spetta. I nomi e le
# azioni sono il punto di partenza per il designer, non una scelta fatta.
# Il numero dopo l'azione e' lo Scavo da scheletro (registro 135).
def stampo(era, nomi):
    # Secondo giro (registro 164): nelle ere 3-5 gli edifici delle ere passate
    # producono gia' Denaro e Idee a ogni attivazione, e morivano 2-3 Denaro e
    # Idee a testa: due ruoli passano alla Costruzione (11/3/3 invece di 9/4/4).
    ruoli = [
        ("civico",     prod(pietra=1),          pv(1, "civico", "colonna", 1), 3),
        ("civico",     prod(pietra=1),          ACQUISTO,                      3),
        ("civico",     prod(pietra=1),          cambio(1),                     2),
        ("religione",  prod(idee=1),            sconto(1, "classe:religione"), 5),
        ("religione",  prod(pietra=1),          resistenza(1, "uno"),          4),
        ("religione",  prod(pietra=1),          pv(1, "religione", "ovunque", 2), 5),
        ("commercio",  prod(oro=1),             altri(1, 2),                   4),
        ("commercio",  prod(pietra=1, oro=1),   NESSUNA,                       5),
        ("commercio",  prod(oro=1),             sconto(1, "potenziamento"),    6),
        ("cultura",    prod(idee=1),            sconto(1, "arte"),             5),
        ("cultura",    prod(pietra=1),          pv(1),                         3),
        ("cultura",    prod(idee=1),            scavo(2, "uno"),               4),
        ("ingegneria", prod(pietra=1),          sconto(1),                     2),
        ("ingegneria", prod(pietra=1),          {"tipo": "adiacente"},         3),
        ("militare",   prod(pietra=1),          resistenza(2, "abitato"),      2),
        ("militare",   prod(pietra=1),          resistenza(1, "tutti"),        4),
    ]
    TESTI = {
        "pv_colonna": "+1 PV se hai un edificio {c} in piedi in questa colonna.",
        "acquisto": "In questo turno puoi comprare ancora un potenziamento o una casa.",
        "cambio": "Cambia 1 risorsa in un'altra.",
        "sconto_classe": "-1 al costo dell'edificio Religione che costruisci in questo turno.",
        "res_uno": "+1 resistenza fino a fine era a un tuo edificio in questa colonna.",
        "pv_ovunque": "+1 PV se hai 2+ edifici Religione in piedi.",
        "altri": "+1 Denaro per ogni altro giocatore con un edificio in questa colonna (max 2).",
        "nessuna": "Nessuna azione.",
        "sconto_pot": "Il potenziamento che compri in questo turno costa 1 in meno.",
        "sconto_arte": "Il potenziamento Arte che compri in questo turno costa 1 in meno.",
        "pv": "+1 PV.",
        "scavo": "+2 Scavo permanente a un tuo edificio in questa colonna.",
        "sconto": "-1 Costruzione alla costruzione di questo turno.",
        "adiacente": "Prendi anche la produzione della tessera di una colonna accanto.",
        "res_abitato": "+2 resistenza fino a fine era all'edificio su cui sta.",
        "res_tutti": "+1 resistenza fino a fine era a ogni tuo edificio in questa colonna.",
    }
    chiavi = ["pv_colonna", "acquisto", "cambio", "sconto_classe", "res_uno", "pv_ovunque", "altri",
              "nessuna", "sconto_pot", "sconto_arte", "pv", "scavo", "sconto", "adiacente", "res_abitato", "res_tutti"]
    out = []
    for (cid, nome), (classe, produzione, azione, sc), k in zip(nomi, ruoli, chiavi):
        pr = ", ".join(x for x in ["1 Costruzione" if produzione["pietra"] else "", "1 Denaro" if produzione["oro"] else "",
                                   "1 Idea" if produzione["idee"] else ""] if x)
        testo = "Produce %s. %s" % (pr, TESTI[k].format(c="Civico"))
        out.append(personaggio_scavo(cid, nome, classe, produzione, dict(azione), sc, testo, era))
    return out

NOMI_E3 = [("pe_cronista", "Cronista"), ("pe_podesta", "Podesta'"), ("pe_borgomastro", "Borgomastro"),
           ("pe_vescovo", "Vescovo"), ("pe_abate", "Abate"), ("pe_frate", "Frate predicatore"),
           ("pe_mercante", "Mercante"), ("pe_cambiatore", "Cambiatore"), ("pe_speziale", "Speziale"),
           ("pe_miniatore", "Miniatore"), ("pe_trovatore", "Trovatore"), ("pe_maestro_vetraio", "Maestro vetraio"),
           ("pe_mastro_costruttore", "Mastro costruttore"), ("pe_capomastro", "Capomastro"),
           ("pe_cavaliere", "Cavaliere"), ("pe_balestriere", "Balestriere")]
NOMI_E4 = [("pe_gonfaloniere", "Gonfaloniere"), ("pe_provveditore", "Provveditore"), ("pe_notaio", "Notaio"),
           ("pe_cardinale", "Cardinale"), ("pe_priore", "Priore"), ("pe_predicatore", "Predicatore"),
           ("pe_banchiere", "Banchiere"), ("pe_mercante_veneziano", "Mercante veneziano"), ("pe_orafo", "Orafo"),
           ("pe_mecenate", "Mecenate"), ("pe_umanista", "Umanista"), ("pe_artista_di_corte", "Artista di corte"),
           ("pe_ingegnere_idraulico", "Ingegnere idraulico"), ("pe_cartografo", "Cartografo"),
           ("pe_ingegnere_militare", "Ingegnere militare"), ("pe_condottiero", "Condottiero")]
NOMI_E5 = [("pe_sindaco", "Sindaco"), ("pe_urbanista", "Urbanista"), ("pe_assessore", "Assessore"),
           ("pe_parroco", "Parroco"), ("pe_sagrestano", "Sagrestano"), ("pe_missionario", "Missionario"),
           ("pe_industriale", "Industriale"), ("pe_imprenditore", "Imprenditore"), ("pe_commercialista", "Commercialista"),
           ("pe_archeologo", "Archeologo"), ("pe_scrittore", "Scrittore"), ("pe_restauratore", "Restauratore"),
           ("pe_soprintendente", "Soprintendente"), ("pe_geometra", "Geometra"),
           ("pe_veterano", "Veterano"), ("pe_carabiniere", "Carabiniere")]
v3["characters"] = [ch for ch in v3["characters"] if ch.get("era") not in (3, 4, 5)] + \
    stampo(3, NOMI_E3) + stampo(4, NOMI_E4) + stampo(5, NOMI_E5)

# Gli edifici delle ere 3-5: costo con la regola (Civico e Commercio Costruzione
# e Idea, Religione e Cultura Costruzione e Denaro, Ingegneria e Militare
# Costruzione), due risorse le carte piccole, tre le medie, quattro le grandi;
# Rendita 2 solo dove si paga 4 o piu'; un'azione dal vocabolario, col sapore
# della classe. Gli effetti "negli eventi" di Mura e Arsenale diventano azioni;
# gli effetti di fine partita (Osservatorio, Piazza monumentale, le gilde
# dell'era 5, registro 150) e la Bottega d'artista restano.
EDIFICI_345 = {
    # era 3
    "ed_borgo":                   (prod(pietra=1, idee=1),         None, pv(1, "civico", "colonna", 1), "A ogni attivazione: +1 PV se hai un altro Civico in piedi in questa colonna."),
    "ed_mura":                    (prod(pietra=2),                 None, resistenza(1, "adiacenti"),   "A ogni attivazione: +1 resistenza fino a fine era ai tuoi edifici adiacenti."),
    "ed_cappella":                (prod(pietra=1, oro=1),          None, resistenza(1, "adiacente"),   "A ogni attivazione: +1 resistenza fino a fine era a un tuo edificio adiacente."),
    "ed_torre_civica":            (prod(pietra=1, idee=1),         None, pv(1, "civico", "colonna", 1), "A ogni attivazione: +1 PV se hai un altro Civico in piedi in questa colonna."),
    "ed_conceria":                (prod(pietra=1, idee=1),         None, risorsa(oro=1, se="altrui"),  "A ogni attivazione di un avversario: +1 Denaro."),
    "ed_mulino":                  (prod(pietra=1, idee=1),         None, risorsa(pietra=1),            "A ogni attivazione: +1 Costruzione."),
    "ed_chiesa":                  (prod(pietra=2, oro=1),          1,    pv(1, "religione", "ovunque", 2), "A ogni attivazione: +1 PV se hai 2+ edifici Religione in piedi."),
    "ed_mercato":                 (prod(pietra=1, idee=1),         None, altri(1, 2),                  "A ogni attivazione: +1 Denaro per ogni altro giocatore con un edificio qui (max 2)."),
    "ed_ospedale_dei_pellegrini": (prod(pietra=2, idee=1),         None, resistenza(1, "adiacente"),   "A ogni attivazione: +1 resistenza fino a fine era a un tuo edificio adiacente."),
    "ed_castello":                (prod(pietra=3, oro=1),          2,    resistenza(1, "tutti"),       "A ogni attivazione: +1 resistenza fino a fine era ai tuoi edifici in questa colonna."),
    "ed_abbazia":                 (prod(pietra=2, oro=1, idee=1),  2,    risorsa(idee=1),              "A ogni attivazione: +1 Idea."),
    "ed_arsenale":                (prod(pietra=3),                 None, resistenza(1, "adiacenti"),   "A ogni attivazione: +1 resistenza fino a fine era ai tuoi edifici adiacenti."),
    # era 4
    "ed_bottega_dartista":        (prod(pietra=1, oro=1),          None, risorsa(idee=1),              "A ogni attivazione: +1 Idea. I tuoi potenziamenti costano 1 in meno."),
    "ed_giardino_allitaliana":    (prod(pietra=1, oro=1),          None, pv(1),                        "A ogni attivazione: +1 PV."),
    "ed_loggia":                  (prod(pietra=1, idee=1),         None, cambio(1),                    "A ogni attivazione: cambia 1 risorsa in un'altra."),
    "ed_osservatorio":            (prod(pietra=2, oro=1),          None, risorsa(idee=1),              "A ogni attivazione: +1 Idea. A fine partita, se e' in piedi: +2 PV."),
    "ed_banco":                   (prod(pietra=1, idee=1),         None, cambio(1),                    "A ogni attivazione: cambia 1 risorsa in un'altra."),
    "ed_villa":                   (prod(pietra=2, idee=1),         None, pv(1),                        "A ogni attivazione: +1 PV."),
    "ed_palazzo_signorile":       (prod(pietra=2, idee=1),         None, pv(1, "civico", "colonna", 1), "A ogni attivazione: +1 PV se hai un altro Civico in piedi in questa colonna."),
    "ed_ponte_monumentale":       (prod(pietra=3, oro=1),          2,    risorsa(pietra=1),            "A ogni attivazione: +1 Costruzione."),
    "ed_accademia":               (prod(pietra=2, oro=1),          None, scavo(1, "uno"),              "A ogni attivazione: +1 Scavo permanente a un tuo edificio in questa colonna."),
    "ed_duomo":                   (prod(pietra=3, oro=2),          2,    pv(1, "religione", "ovunque", 2), "A ogni attivazione: +1 PV se hai 2+ edifici Religione in piedi."),
    "ed_fortezza_bastionata":     (prod(pietra=4),                 2,    resistenza(1, "tutti"),       "A ogni attivazione: +1 resistenza fino a fine era ai tuoi edifici in questa colonna."),
    "ed_piazza_monumentale":      (prod(pietra=2, idee=2),         2,    altri(1, 2),                  "A ogni attivazione: +1 Denaro per ogni altro giocatore con un edificio qui (max 2). A fine partita: +1 PV per ogni tuo edificio in piedi nelle sue colonne."),
    # era 5 (le gilde del registro 150 tengono il loro effetto di fine partita)
    "ed_fondazione_darte":        (prod(pietra=1, oro=1),          None, pv(1),                        "A ogni attivazione: +1 PV. A fine partita: +1 PV per ogni tuo potenziamento."),
    "ed_condominio":              (prod(pietra=1, idee=1),         None, pv(1, "civico", "colonna", 1), "A ogni attivazione: +1 PV se hai un altro Civico in piedi in questa colonna. A fine partita: +1 PV per ogni tuo Civico in piedi (max 4)."),
    "ed_caffe_letterario":        (prod(pietra=1, oro=1),          None, risorsa(idee=1),              "A ogni attivazione: +1 Idea. A fine partita: +1 PV se e' adiacente a un edificio Cultura."),
    "ed_officina":                (prod(pietra=2),                 None, risorsa(pietra=1),            "A ogni attivazione: +1 Costruzione. A fine partita: +1 PV per ogni altro tuo Ingegneria (max 4)."),
    "ed_monumento_ai_caduti":     (prod(pietra=2, oro=1),          None, resistenza(1, "adiacenti"),   "A ogni attivazione: +1 resistenza fino a fine era ai tuoi edifici adiacenti. A fine partita: +1 PV per ogni altro tuo Militare."),
    "ed_museo":                   (prod(pietra=2, oro=1),          None, scavo(1, "uno"),              "A ogni attivazione: +1 Scavo permanente a un tuo edificio in questa colonna. A fine partita: +2 PV per ogni tua rovina riscoperta."),
    "ed_grattacielo":             (prod(pietra=3, idee=1),         None, altri(1, 2),                  "A ogni attivazione: +1 Denaro per ogni altro giocatore con un edificio qui (max 2). A fine partita: +1 PV per ogni livello a cui e' costruito; ogni edificio altrui in cima a una colonna adiacente toglie 1 PV al suo proprietario."),
    "ed_biblioteca":              (prod(pietra=2, oro=1),          None, pv(1),                        "A ogni attivazione: +1 PV. A fine partita: +1 PV per ogni classe diversa fra i tuoi edifici."),
    "ed_ponte_in_acciaio":        (prod(pietra=3),                 None, risorsa(pietra=1),            "A ogni attivazione: +1 Costruzione. A fine partita: +2 PV per ogni tua rovina riportata alla luce nelle sue colonne."),
    "ed_stazione":                (prod(pietra=3, idee=1),         None, risorsa(pietra=1),            "A ogni attivazione: +1 Costruzione. A fine partita: +1 PV per ogni edificio in piedi nelle sue colonne (max 5)."),
    "ed_parco_archeologico":      (prod(pietra=2, oro=1),          None, scavo(1, "adiacente"),        "A ogni attivazione: +1 Scavo permanente a un tuo edificio adiacente. A fine partita: fino a 2 tuoi edifici non sotterrati nelle colonne adiacenti valgono il loro Scavo come se fossero sotterrati."),
    "ed_universita":              (prod(pietra=2, oro=1, idee=1),  None, pv(1),                        "A ogni attivazione: +1 PV. Solo sopra, al livello 1 o piu'. A fine partita: +1 PV per ogni tuo Personaggio reclutato."),
}
# Terzo giro (registro 164): sulla partita intera il Denaro moriva 10 a testa, e
# veniva per 7 dalle azioni degli edifici e per 4,4 dalla PRODUZIONE della v2
# rimasta sulle carte (Mulino 2, Officina 2, Stazione 2...), che si sommava
# all'azione. Dall'era 2 in su l'azione e' la produzione: il campo della v2 va
# a zero (l'era 1 resta com'e' stata misurata).
for b in v3["buildings"]:
    if b["era"] >= 2 and not b.get("riserva"):
        b["production"] = {"pietra": 0, "oro": 0, "cultura": 0, "idee": 0}
# Il designer (registro 165): "le carte ere 3-4 vanno rimodulate per costare un
# po' di piu'". Le carte da due risorse delle ere 3 e 4 ne prendono una terza,
# quella fra Denaro e Idee che non chiedevano (sono le due che muoiono):
# Civico e Commercio +1 Denaro, Religione e Cultura +1 Idea, Ingegneria e
# Militare +1 Denaro. Le carte da tre e quattro restano.
SECONDA_TERZA = {"civico": "oro", "commercio": "oro", "religione": "idee", "cultura": "idee",
                 "ingegneria": "oro", "militare": "oro"}
for bid, (costo, rendita, azione, testo) in list(EDIFICI_345.items()):
    era_b = next(b["era"] for b in v3["buildings"] if b["id"] == bid)
    if era_b in (3, 4) and sum(costo.values()) == 2:
        classe = next(b["classes"][0] for b in v3["buildings"] if b["id"] == bid)
        nuovo = dict(costo); nuovo[SECONDA_TERZA[classe]] += 1
        EDIFICI_345[bid] = (nuovo, rendita, azione, testo)
CASE_FLESSIBILI = {"ed_casa_e3_s", "ed_casa_e4_s", "ed_casa_e5_p"}
# Le case delle ere 3-5 nella stessa economia (registro 164): nella v2
# costavano Denaro e Idee ed erano l'unica cosa che le assorbiva (due a partita
# ciascuna nelle ere 4 e 5). Ora la piccola costa 1 Costruzione o Denaro, le
# altre 1 o 2 Costruzione secondo il Lampo.
CASE_345 = {"ed_casa_e3_p": prod(pietra=1), "ed_casa_e3_g": prod(pietra=2),
            "ed_casa_e4_p": prod(pietra=2), "ed_casa_e4_g": prod(pietra=3),   # terzo giro: a 1 e 2 battevano il mazzo (2,0 e 1,9 a partita)
            "ed_casa_e5_g": prod(pietra=3)}
for b in v3["buildings"]:
    if b["era"] not in (3, 4, 5): continue
    if b["id"] in EDIFICI_345:
        costo, rendita, azione, testo = EDIFICI_345[b["id"]]
        b["cost"] = dict(costo)
        if rendita is not None: b["rendita"] = rendita
        elif int(b.get("rendita", 0)) > 0: b["rendita"] = 1
        b["azione"] = azione
        if b["id"] in ("ed_mura", "ed_arsenale"): b["effects"] = []
        b["effect_text"] = testo
        # Le carte fragili delle ere 3 e 5 (resistenza 1-2 contro la forza 4)
        # crollavano all'82-99%: +1, cosi' con un 🛡 dei Personaggi reggono.
        if b["era"] in (3, 5) and int(b["resistance"]) <= 2: b["resistance"] = int(b["resistance"]) + 1
    else:
        b["azione"] = NESSUNA
        if b["id"] in CASE_FLESSIBILI:
            b["cost"] = prod(pietra=1); b["flexible"] = True
        elif b["id"] in CASE_345:
            b["cost"] = dict(CASE_345[b["id"]])
# Le tessere delle ere 3-5: cinque su sette producono, con tutte e tre le risorse.
# Secondo giro (registro 164): tre su sette, quasi solo Costruzione; con cinque
# su sette le ere 3-5 producevano 13-14,5 e ne morivano 5,6-6,3.
TESSERE_345 = {
    "te_fiera": prod(), "te_borgo_franco": prod(pietra=1), "te_scuola_dei_mastri": prod(idee=1),
    "te_mura": prod(pietra=1), "te_rocca": prod(), "te_eremo": prod(), "te_spoglio_delle_rovine": prod(),
    "te_villa_di_campagna": prod(), "te_piazza_del_mercato": prod(), "te_bottega": prod(),
    "te_fondaco": prod(oro=1), "te_belvedere": prod(pietra=1), "te_giardino_all_italiana": prod(pietra=1),
    "te_cappella_di_famiglia": prod(),
    "te_periferia": prod(oro=1), "te_zona_industriale": prod(pietra=1), "te_isolato": prod(),
    "te_scuola_politecnica": prod(), "te_quartiere_alto": prod(pietra=1), "te_parco_pubblico": prod(),
    "te_orto_botanico": prod(),
}
for t in v3["tessere_era"]:
    if t["id"] in TESSERE_345: t["produzione"] = TESSERE_345[t["id"]]

# LE CARTE GRANDI "A TERRA OPPURE SOPRA" (registro 166). Nella v2 i 2x2
# (Anfiteatro, Castello, Fortezza) e il Grattacielo non andavano mai a terra
# e la Stazione chiedeva il livello 1: si poggiavano spianando due propri
# edifici dell'era stessa, con lo sconto. Nella v3 spianare costa e non si
# spiana la stessa era, e si costruivano 0,01-0,26 volte a partita. Il
# designer: "a terra oppure sopra". Il campo `a_terra_o_sopra` lo legge
# BuildRules.quote_rail: a terra valgono le regole di tutti (terreno, binari
# liberi); sopra restano quelle della v2, e sopra di loro si costruisce ancora
# solo quando sono in rovina.
A_TERRA = {"ed_anfiteatro", "ed_castello", "ed_fortezza_bastionata", "ed_grattacielo", "ed_stazione"}
for b in v3["buildings"]:
    if b["id"] in A_TERRA: b["a_terra_o_sopra"] = True

# L'UNIVERSITA' (registro 182): "+1 PV per ogni tuo Personaggio reclutato"
# nella v3 vale +20 fissi, perche' col draft tutti ne reclutano 20 (nei replay
# del seme 2530 chi la costruisce prende 20 PV e vince). Ora conta i
# Personaggi con Scavo 5 o piu': sono 26 su 80, cinque o sei per era, e
# prenderli al draft e' una scelta (sono anche gli scheletri che valgono).
# IL GRATTACIELO (registro 183): costava 3 Costruzione e 1 Idea, meta' del
# budget dell'era 5, e nessuno le aveva mai insieme (seme 2530 a quattro: in
# vetrina tutta l'era con 3-4 posti, mai comprato). Ora 2 Costruzione e 1 Idea,
# come l'Universita'; il finale stampato resta.
for b in v3["buildings"]:
    if b["id"] == "ed_universita":
        for e in b["effects"]:
            if e.get("hook") == "on_final_scoring" and e.get("per") == "recruited_character":
                e["per"] = "recruited_scavo_min"
                e["min_scavo"] = 5
                e["cap"] = 5
        b["effect_text"] = b["effect_text"].replace("+1 PV per ogni tuo Personaggio reclutato.",
            "+1 PV per ogni tuo Personaggio con Scavo 5 o piu' (max 5).")
    # IL TETTO AI DUE FINALI PIU' GRASSI (registro 187): con lo spianamento
    # parziale le rovine riscoperte sono 2,9 a giocatore e il Museo ("+2 PV
    # per ogni tua rovina riscoperta") rendeva 6,9 PV a costruzione,
    # l'Universita' 7,4; le altre carte con finale stanno fra 1 e 4,8 e la
    # Stazione ha gia' il suo tetto (max 5). Museo max 6, Universita' max 5.
    if b["id"] == "ed_museo":
        for e in b["effects"]:
            if e.get("hook") == "on_final_scoring": e["cap"] = 6
        b["effect_text"] = b["effect_text"].replace("+2 PV per ogni tua rovina riscoperta.",
            "+2 PV per ogni tua rovina riscoperta (max 6).")
    if b["id"] == "ed_grattacielo":
        b["cost"] = prod(pietra=2, idee=1)

# GLI SCHELETRI SONO I PERSONAGGI (registro 188). Il designer: "tienila". Una
# tessera per Personaggio, nel sacchetto quando viene reclutato; la rovina
# pesca al crollo; la tessera riportata alla luce paga il suo Scavo a chi ha
# quel Personaggio. Il mazzetto da 20 per colore non serve piu'.
c["tessere_scavo"]["scheletri"] = "personaggi"

# LO SPIANAMENTO PARZIALE (registro 180). Nella v2 un proprio intatto spianato
# andava in rovina tutto intero, Scavo 0 e senza tessere, anche se la carta
# nuova ne copriva una casella sola: le altre restavano Terrapieni a vista
# (una volta a partita). Il designer: le caselle coperte sono terrapieno
# ("stai usando il suo materiale e lo stai coprendo"), quelle rimaste libere
# restano rovina con le loro tessere ("NON ci hai costruito sopra").
c["tessere_scavo"]["spianato"] = "parziale"

#   --variante extra_sempre   l'acquisto extra a ogni turno, senza carte (la "catena" del registro 156)
#   --variante senza_extra    nessun acquisto extra: le quattro carte tornano com'erano nella scheda
#   --variante costi_vecchi   i costi della scheda, senza il +1 della seconda risorsa
# Le varianti del primo giro (costi, terreno, acquisto, pacchetto...) erano
# relative al file base di prima che assorbisse la catena: le rigenera il
# generatore al commit 2db6223.
import sys
variante = sys.argv[sys.argv.index("--variante") + 1] if "--variante" in sys.argv else ""

def extra_sempre(v):
    v["constants"]["acquisto_extra"] = True
def senza_extra(v):
    for ch in v["characters"]:
        if ch["id"] == "pe_capotribu": ch["azione"] = resistenza(1, "uno")
        if ch["id"] == "pe_mercante_di_ossidiana": ch["azione"] = cambio(2)
    for b in v["buildings"]:
        if b["id"] == "ed_capanne": b["azione"] = cambio(1)
        if b["id"] == "ed_cava": b["azione"] = cambio(1, "pietra", "oro")
    for t in v["tessere_era"]:
        if t["id"] == "te_sentiero_dei_pastori": t["effetto"] = {"quando": "attiva", "guadagno": {"oro": 1}}
def costi_vecchi(v):
    for b in v["buildings"]:
        if b["era"] != 1 or b.get("riserva"): continue
        b["cost"][SECONDA[b["classes"][0]]] -= 1
#   --variante case_seconda   anche le case con +1 Denaro, tranne i Ripari (la casa di salvataggio)
#   --variante case_lampo1    il Lampo di tutte le case a 1
#   --variante senza_tuning   la produzione di prima del registro 159 (controllo)
def case_seconda(v):
    for b in v["buildings"]:
        if b["era"] == 1 and b.get("riserva") and b["id"] != "ed_casa_e1_s":
            b["cost"]["oro"] += 1
def case_lampo1(v):
    for b in v["buildings"]:
        if b["era"] == 1 and b.get("riserva"):
            b["lampo"] = min(int(b["lampo"]), 1)
def terreno_produce(v):
    for t, t2 in zip(v["terrains"], base["terrains"]):
        t["produzione_base"] = dict(t2["produzione_base"])
        t["base_production_by_era"] = json.loads(json.dumps(t2["base_production_by_era"]))
def senza_potenziamento_insieme(v):
    v["constants"]["potenziamento_con_costruzione"] = False
def senza_tuning(v):
    for t in v["tessere_era"]:
        if t["id"] in TESTI_PRODUZIONE or t["id"] in TESSERE_PRODUZIONE:
            t["produzione"] = prod()
    for ch in v["characters"]:
        if ch["id"] == "pe_guardiano_del_fuoco": ch["produzione"] = prod(pietra=1)
        if ch["id"] == "pe_anziana_del_villaggio": ch["produzione"] = prod(pietra=1)
        if ch["id"] == "pe_barattatore": ch["produzione"] = prod(pietra=1, oro=1)
    v["constants"]["potenzia_adiacente"] = False
# LE AZIONI DEGLI EDIFICI CHE DANNO RISORSE SCATTANO SOLO QUANDO ATTIVI TU
# (registro 166, quarantesima misura). L'Acquedotto (tre colonne, in piedi
# dall'era 2 alla 5, "+1 Idea a ogni attivazione di chiunque") dava 17 Idee a
# partita al suo padrone; senza le azioni degli edifici Denaro e Idee prodotti
# pareggiavano quasi quel che se ne spendeva. Con "a ogni TUA attivazione" il
# morto delle ere 2-5 scende da 2,7-3,8 a 2,0-2,5 e le vittorie stanno fra 26
# e 39. Vale per `risorsa` e `altri` senza condizione (quelle "altrui" restano);
# PV, resistenza, cambio, scavo scattano ancora a ogni attivazione di chiunque.
PROPRIO_IDS = set()
def _proprio(v, anche_pietra=True, togli=False):
    for b in v["buildings"]:
        az = b.get("azione") or {}
        if togli:
            if b["id"] in PROPRIO_IDS:
                del az["se"]; b["effect_text"] = b["effect_text"].replace("A ogni tua attivazione:", "A ogni attivazione:")
            continue
        if az.get("tipo") not in ("risorsa", "altri") or az.get("se"): continue
        if az["tipo"] == "risorsa" and not anche_pietra and not (az.get("oro") or az.get("idee")): continue
        az["se"] = "proprio"; PROPRIO_IDS.add(b["id"])
        b["effect_text"] = b["effect_text"].replace("A ogni attivazione:", "A ogni tua attivazione:")
_proprio(v3)

# ---- le controprove ----------------------------------------------------------
# IL LAMPO VALE IL COSTO, E DUE TESSERE IN COSTRUZIONE (registro 167, quarantunesima
# misura). Il metro: "un edificio a una casella rende in Lampo il suo costo in
# Costruzione"; nelle ere 4-5 tutte le carte Lampo del mazzo valevano 1 anche a
# costo 3 (dallo stampo della v2). Ora il Lampo delle carte Lampo del mazzo
# delle ere 3-5 vale almeno il costo in Costruzione: +2 PV a testa per tutti.
# Nell'era 4 morivano 1,4 Denaro a testa e il Fondaco era l'unica tessera a
# produrne; nell'era 5 0,8 con la Periferia: tutte e due producono Costruzione,
# che e' quel che manca (si passava 1,2 volte a testa). Il morto delle ere 4-5
# scende da 2,5 a 2,2 e 2,1. `--variante lampo_vecchio` rifa' il file di prima.
LAMPO_VECCHIO = {}
for b in v3["buildings"]:
    if b["era"] in (3, 4, 5) and not b.get("riserva") and int(b["lampo"]) > 0 and int(b["rendita"]) == 0:
        LAMPO_VECCHIO[b["id"]] = int(b["lampo"])
        b["lampo"] = max(int(b["lampo"]), int(b["cost"]["pietra"]))
for t in v3["tessere_era"]:
    if t["id"] in ("te_fondaco", "te_periferia"): t["produzione"] = prod(pietra=1)

#   --variante lampo_vecchio  il Lampo dello stampo della v2 e Fondaco e Periferia in Denaro (fino alla quarantesima misura)
def lampo_vecchio(v):
    for b in v["buildings"]:
        if b["id"] in LAMPO_VECCHIO: b["lampo"] = LAMPO_VECCHIO[b["id"]]
    for t in v["tessere_era"]:
        if t["id"] in ("te_fondaco", "te_periferia"): t["produzione"] = prod(oro=1)
# LA "SCELTA" STILE CAYLUS E' IL FILE BASE (registro 171, dalla quarantaquattresima
# misura). Chi attiva usa UN edificio della colonna, di chiunque, e lo brucia
# fino a fine giro; niente al padrone. Le condizioni "a ogni tua attivazione" e
# "di un avversario" non hanno piu' senso e cadono: ogni carta dice "Usa:".
# `--variante proprietario` rifa' la regola di prima (l'azione al padrone).
SE_VECCHI = {}
def scelta(v):
    v["constants"]["azione_edificio"] = "scelta"
    v["constants"]["azione_edificio_compenso"] = "nessuno"
    for b in v["buildings"]:
        az = b.get("azione") or {}
        if az.get("tipo") in ("risorsa", "altri") and az.get("se") in ("proprio", "altrui"):
            SE_VECCHI[b["id"]] = az["se"]; del az["se"]
        az.pop("chi", None)
        t = b.get("effect_text", "")
        for vecchio in ("A ogni tua attivazione:", "A ogni attivazione di un avversario:", "A ogni attivazione:"):
            t = t.replace(vecchio, "Usa:")
        if t: b["effect_text"] = t
scelta(v3)

#   --variante proprietario  l'azione di ogni edificio al suo padrone a ogni attivazione (fino alla quarantatreesima misura)
#   --variante compenso_pv   la scelta con 1 PV al padrone quando lo usa un altro (quarantaquattresima: troppo)
def proprietario(v):
    v["constants"]["azione_edificio"] = "proprietario"
    del v["constants"]["azione_edificio_compenso"]
    TESTI_SE = {"proprio": "A ogni tua attivazione:", "altrui": "A ogni attivazione di un avversario:"}
    for b in v["buildings"]:
        az = b.get("azione") or {}
        if b["id"] in SE_VECCHI:
            az["se"] = SE_VECCHI[b["id"]]
            b["effect_text"] = b["effect_text"].replace("Usa:", TESTI_SE[az["se"]], 1)
        elif az.get("tipo") == "acquisto":       # il ⊕ scatta solo per chi attiva anche con il padrone
            b["effect_text"] = b["effect_text"].replace("Usa:", "A ogni tua attivazione:", 1)
        elif az and az.get("tipo") != "nessuna" and "effect_text" in b:
            b["effect_text"] = b["effect_text"].replace("Usa:", "A ogni attivazione:", 1)
def compenso_pv(v):
    v["constants"]["azione_edificio_compenso"] = "pv"

# GLI SCONTI SENZA CONDIZIONE E IL ⊕ CON LO SCONTO (registro 171, quarantaseiesima
# misura). Il designer: "mancano gli sconti, che sono essenziali"; sette sconti
# condizionati non muovevano nulla (quarantatreesima e quarantacinquesima).
# Dieci carte hanno lo sconto senza condizione, "-1 a quel che compri in questo
# turno", che con la scelta va a chi usa l'edificio, cioe' a chi compra: usati
# 2,9 a partita invece di 1,6, forbice delle vittorie da 28-44 a 29-40. Il ⊕
# porta anche lo sconto ("compri una cosa in piu' e paghi 1 in meno"): si usa
# il 68% delle volte invece del 39%, costruzioni 15,6 a partita invece di 15,1.
# `--variante senza_sconti` rifa' il file della quarantaquattresima.
SCONTI_EDIFICI = {
    "ed_trappole_da_pesca": "Usa: -1 a quel che compri in questo turno.",
    "ed_terme":             "Usa: -1 a quel che compri in questo turno.",
    "ed_insulae":           "Usa: -1 a quel che compri in questo turno.",
    "ed_mulino":            "Usa: -1 a quel che compri in questo turno.",
    "ed_mercato":           "Usa: -1 a quel che compri in questo turno.",
    "ed_bottega_dartista":  "Usa: -1 a quel che compri in questo turno.",
    "ed_loggia":            "Usa: -1 a quel che compri in questo turno.",
    "ed_banco":             "Usa: -1 a quel che compri in questo turno.",
    "ed_officina":          "Usa: -1 a quel che compri in questo turno. A fine partita: +1 PV per ogni altro tuo Ingegneria (max 4).",
    "ed_caffe_letterario":  "Usa: -1 a quel che compri in questo turno. A fine partita: +1 PV se e' adiacente a un edificio Cultura.",
}
PRIMA_DEGLI_SCONTI = {}
TESTO_EXTRA = ("puoi comprare ancora un potenziamento o una casa", "puoi comprare ancora un potenziamento o una casa, e paghi 1 in meno")
for b in v3["buildings"]:
    if b["id"] in SCONTI_EDIFICI:
        PRIMA_DEGLI_SCONTI[b["id"]] = (json.loads(json.dumps(b["azione"])), b["effect_text"], json.loads(json.dumps(b.get("effects"))))
        b["azione"] = sconto(1); b["effect_text"] = SCONTI_EDIFICI[b["id"]]
        if b["id"] == "ed_bottega_dartista": b["effects"] = []   # lo sconto permanente della v2 diventa l'azione
for carta in v3["characters"] + v3["buildings"]:
    az = carta.get("azione") or {}
    if az.get("tipo") == "acquisto":
        az["sconto"] = 1
        carta["effect_text"] = str(carta.get("effect_text", "")).replace(TESTO_EXTRA[0], TESTO_EXTRA[1])

#   --variante senza_sconti  le dieci carte con l'azione di prima e il ⊕ senza sconto (quarantaquattresima)
def senza_sconti(v):
    for b in v["buildings"]:
        if b["id"] in PRIMA_DEGLI_SCONTI:
            b["azione"], b["effect_text"], eff = PRIMA_DEGLI_SCONTI[b["id"]]
            if eff is not None: b["effects"] = eff
    for carta in v["characters"] + v["buildings"]:
        az = carta.get("azione") or {}
        if az.get("tipo") == "acquisto":
            az.pop("sconto", None)
            carta["effect_text"] = str(carta.get("effect_text", "")).replace(TESTO_EXTRA[1], TESTO_EXTRA[0])
# LE TRE CARTE GRANDI RARE (registro 174, quarantottesima misura): Fortezza (⚒4 su
# collina, 2x2), Grattacielo (3 binari) e Stazione (3 colonne di pianura) si
# costruivano 0,03-0,17 volte a partita per terreno e forma. Ora la Stazione va
# su qualunque terreno e la Fortezza costa ⚒3 🪙1 (Fortezza 0,11, la Stazione
# resta a 0,03: sono le tre colonne). Il Grattacielo era passato a 2 binari
# (0,26 a partita): il designer lo rivuole a tre, com'e' stampato (registro 178).
# Il Grattacielo (registro 179): tre binari com'e' stampato, ma su qualunque
# terreno e al livello 1 invece di 2; il designer, "prova con tre binari e
# livello 1 e misura, terreno qualunque".
for b in v3["buildings"]:
    if b["id"] == "ed_stazione": b["terrain"] = None
    if b["id"] == "ed_fortezza_bastionata": b["cost"] = prod(pietra=3, oro=1)
    if b["id"] == "ed_grattacielo":
        b["terrain"] = None; b["level_required"] = 1
        b["effect_text"] = b["effect_text"].replace("A fine partita: come nella v2.", "Richiede livello 1. A fine partita: come nella v2.")

#   --variante grandi_vecchie  le tre carte grandi ritoccate come nella v2 (Stazione in pianura, Fortezza ⚒4,
#                              Grattacielo in pianura al livello 2)
def grandi_vecchie(v):
    for b in v["buildings"]:
        if b["id"] == "ed_stazione": b["terrain"] = "pianura"
        if b["id"] == "ed_fortezza_bastionata": b["cost"] = prod(pietra=4)
        if b["id"] == "ed_grattacielo":
            b["terrain"] = "pianura"; b["level_required"] = 2
            b["effect_text"] = b["effect_text"].replace("Richiede livello 1. ", "")
#   --variante spianato_intero  lo spianato di prima: tutta la carta terrapieno, Scavo 0, niente tessere
def spianato_intero(v):
    v["constants"]["tessere_scavo"].pop("spianato", None)
#   --variante scheletri_personaggi  gli scheletri sono i Personaggi (registro 188): una tessera per
#                                    Personaggio nel sacchetto dei reclutati, paga il suo Scavo a chi lo ha
def scheletri_personaggi(v):
    v["constants"]["tessere_scavo"]["scheletri"] = "personaggi"
#   --variante soffio_per_tutti  il "regge per un soffio" anche per la resistenza 1, com'era prima del registro 193
def soffio_per_tutti(v):
    v["constants"]["soffio_resistenza_min"] = 0
#   --variante tutto_in_vendita  il mercato mostra tutte le 12 carte del mazzo dell'era, senza pescare di volta in volta
def tutto_in_vendita(v):
    v["constants"]["market_size"] = 12
#   --variante evento_coperto  l'evento dell'era si scopre a fine era, quando colpisce; durante l'era si sa solo la forza
def evento_coperto(v):
    v["constants"]["evento_a_fine_era"] = True
#   --variante mazzetti_colorati  le tessere scavo di prima: mazzetto da 20 per colore, valore 0-3, scheletri con l'era
def mazzetti_colorati(v):
    v["constants"]["tessere_scavo"].pop("scheletri", None)
#   --variante finali_senza_tetto  Museo e Universita' senza il tetto del registro 187
def finali_senza_tetto(v):
    for b in v["buildings"]:
        if b["id"] in ("ed_museo", "ed_universita"):
            for e in b["effects"]:
                if e.get("hook") == "on_final_scoring": e.pop("cap", None)
            b["effect_text"] = b["effect_text"].replace(" (max 6)", "").replace(" (max 5)", "")
#   --variante grattacielo_caro  il Grattacielo a 3 Costruzione e 1 Idea, com'era prima del registro 183
def grattacielo_caro(v):
    for b in v["buildings"]:
        if b["id"] == "ed_grattacielo": b["cost"] = prod(pietra=3, idee=1)
VARIANTI = {"senza_soffio": senza_soffio, "senza_soffio_forze": senza_soffio_forze, "eventi5_forza4": eventi5_forza4, "giudizio_solo": giudizio_solo, "soffio_per_tutti": soffio_per_tutti, "tutto_in_vendita": tutto_in_vendita, "evento_coperto": evento_coperto, "scheletri_personaggi": scheletri_personaggi, "mazzetti_colorati": mazzetti_colorati, "finali_senza_tetto": finali_senza_tetto, "spianato_intero": spianato_intero, "grattacielo_caro": grattacielo_caro, "grandi_vecchie": grandi_vecchie, "proprietario": proprietario, "compenso_pv": compenso_pv, "senza_sconti": senza_sconti,
            "lampo_vecchio": lampo_vecchio, "extra_sempre": extra_sempre, "senza_extra": senza_extra, "costi_vecchi": costi_vecchi,
            "case_seconda": case_seconda, "case_lampo1": case_lampo1, "senza_tuning": senza_tuning,
            "terreno_produce": terreno_produce, "senza_potenziamento_insieme": senza_potenziamento_insieme}
if variante:
    VARIANTI[variante](v3)
    v3["meta"]["ruleset"] = "v3-era1-prova-" + variante

out = os.path.join(RADICE, "data/proposte/cards-v3-era1%s.json" % ("-" + variante if variante else ""))
json.dump(v3, open(out, "w", encoding="utf-8"), indent=2, ensure_ascii=False)
print("scritto", os.path.relpath(out, RADICE), "-", len(v3["characters"]), "Personaggi,",
      sum(1 for b in v3["buildings"] if b.get("azione")), "edifici con azione")
