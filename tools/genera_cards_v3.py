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
def altri(oro=1, massimo=2):
    return {"tipo": "altri", "oro": oro, "max": massimo}
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
for era in range(2, 6):
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

# ---- le varianti del pozzo (registro 156) ----------------------------------
# Il designer: "Ci deve essere una mancanza di risorse, non un surplus";
# "anche gli edifici potrebbero costare di piu'"; la catena dei Castelli di
# Borgogna, "far fare piu' azioni o acquisti oltre i 4 consentiti".
#   --variante costi      ogni edificio dell'era 1 costa 1 Costruzione in piu'
#   --variante terreno    il terreno di base non produce: resta la tessera dell'era
#   --variante acquisto   dopo l'azione si compra ancora un potenziamento o una casa
#   --variante pacchetto  tutte e tre insieme
#   --variante acquisto_caro / pacchetto_caro   come sopra, con lo spianare caro (registro 152)
#   --variante catena     terreno + acquisto + spianare caro, costi com'erano
#   --variante costi_misti   +1 della seconda risorsa della classe (Denaro o Idee o Costruzione)
#   --variante catena_misti  catena + costi misti
import sys
variante = sys.argv[sys.argv.index("--variante") + 1] if "--variante" in sys.argv else ""

def costi(v):
    for b in v["buildings"]:
        if b["era"] == 1: b["cost"]["pietra"] += 1
def terreno(v):
    for t in v["terrains"]:
        t["produzione_base"] = {"pietra": 0, "oro": 0, "idee": 0}
        t["base_production_by_era"] = {e: {"pietra": 0, "oro": 0, "idee": 0} for e in "12345"}
def acquisto(v):
    v["constants"]["acquisto_extra"] = True
def pacchetto(v):
    costi(v); terreno(v); acquisto(v)
# Lo spianare caro (registro 152, costante `spianare_costo`): i bot usavano
# l'acquisto extra per spianare i propri Dolmen e Circoli con una casa.
def caro(v):
    v["constants"]["spianare_costo"] = 1
def acquisto_caro(v):
    acquisto(v); caro(v)
def pacchetto_caro(v):
    pacchetto(v); caro(v)
# La catena: terreno che non produce, acquisto extra, spianare caro, costi
# com'erano. E i costi misti: la seconda risorsa della classe (Commercio e
# Civico +1 Denaro, Religione e Cultura +1 Idea, Ingegneria e Militare +1
# Costruzione), cosi' nell'era 1 anche Denaro e Idee hanno dove andare.
def catena(v):
    terreno(v); acquisto(v); caro(v)
SECONDA = {"commercio": "oro", "civico": "oro", "religione": "idee", "cultura": "idee",
           "ingegneria": "pietra", "militare": "pietra"}
def costi_misti(v):
    for b in v["buildings"]:
        if b["era"] != 1: continue
        b["cost"][SECONDA[b["classes"][0]]] += 1
def catena_misti(v):
    catena(v); costi_misti(v)
VARIANTI = {"costi": costi, "terreno": terreno, "acquisto": acquisto, "pacchetto": pacchetto,
            "acquisto_caro": acquisto_caro, "pacchetto_caro": pacchetto_caro,
            "catena": catena, "costi_misti": costi_misti, "catena_misti": catena_misti}
if variante:
    VARIANTI[variante](v3)
    v3["meta"]["ruleset"] = "v3-era1-prova-" + variante

out = os.path.join(RADICE, "data/proposte/cards-v3-era1%s.json" % ("-" + variante if variante else ""))
json.dump(v3, open(out, "w", encoding="utf-8"), indent=2, ensure_ascii=False)
print("scritto", os.path.relpath(out, RADICE), "-", len(v3["characters"]), "Personaggi,",
      sum(1 for b in v3["buildings"] if b.get("azione")), "edifici con azione")
