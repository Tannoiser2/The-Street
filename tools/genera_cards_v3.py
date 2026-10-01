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

# ---- il tuning delle risorse (registro 159) ------------------------------------
# Il designer, letta la trentaduesima misura ("un'era di case", potenziamenti a
# zero): "un tuning delle risorse: se Idee e Denaro sono poco bisogna alzarle,
# poi i potenziamenti devono essere comprati". Si producevano 5,5 Costruzione,
# 1,5 Denaro e 1,7 Idee a testa, e le carte del mazzo chiedono Denaro o Idee.
# Le quattro tessere dell'era 1 che non producevano niente ora danno Denaro o
# Idee; tre Personaggi passano dalla Costruzione a Denaro e Idee (fra i 16:
# Costruzione 7, Denaro 6, Idee 6, invece di 10/4/5).
TESSERE_PRODUZIONE = {"te_radura": prod(idee=1), "te_sentiero_dei_pastori": prod(oro=1),
                      "te_terra_di_nessuno": prod(oro=1), "te_luogo_sacro": prod(idee=1)}
for t in v3["tessere_era"]:
    if t["id"] in TESSERE_PRODUZIONE:
        t["produzione"] = TESSERE_PRODUZIONE[t["id"]]
PERSONAGGI_PRODUZIONE = {"pe_guardiano_del_fuoco": prod(idee=1), "pe_anziana_del_villaggio": prod(oro=1),
                         "pe_barattatore": prod(oro=1, idee=1)}
TESTI_PRODUZIONE = {"pe_guardiano_del_fuoco": "Produce 1 Idea. +1 resistenza fino a fine era a ogni tuo Religione in questa colonna.",
                    "pe_anziana_del_villaggio": "Produce 1 Denaro. Cambia 1 risorsa in un'altra.",
                    "pe_barattatore": "Produce 1 Denaro e 1 Idea. Nessuna azione."}
for ch in v3["characters"]:
    if ch["id"] in PERSONAGGI_PRODUZIONE:
        ch["produzione"] = PERSONAGGI_PRODUZIONE[ch["id"]]
        ch["effect_text"] = TESTI_PRODUZIONE[ch["id"]]
# I potenziamenti si comprano anche nelle colonne accanto a quella attivata
# (registro 126): nell'era 1 i propri edifici stanno sulle colonne gia'
# attivate, e senza questo nessuno li compra.
c["potenzia_adiacente"] = True

# ---- le controprove ----------------------------------------------------------
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
def senza_tuning(v):
    for t in v["tessere_era"]:
        if t["id"] in TESTI_PRODUZIONE or t["id"] in TESSERE_PRODUZIONE:
            t["produzione"] = prod()
    for ch in v["characters"]:
        if ch["id"] == "pe_guardiano_del_fuoco": ch["produzione"] = prod(pietra=1)
        if ch["id"] == "pe_anziana_del_villaggio": ch["produzione"] = prod(pietra=1)
        if ch["id"] == "pe_barattatore": ch["produzione"] = prod(pietra=1, oro=1)
    v["constants"]["potenzia_adiacente"] = False
VARIANTI = {"extra_sempre": extra_sempre, "senza_extra": senza_extra, "costi_vecchi": costi_vecchi,
            "case_seconda": case_seconda, "case_lampo1": case_lampo1, "senza_tuning": senza_tuning}
if variante:
    VARIANTI[variante](v3)
    v3["meta"]["ruleset"] = "v3-era1-prova-" + variante

out = os.path.join(RADICE, "data/proposte/cards-v3-era1%s.json" % ("-" + variante if variante else ""))
json.dump(v3, open(out, "w", encoding="utf-8"), indent=2, ensure_ascii=False)
print("scritto", os.path.relpath(out, RADICE), "-", len(v3["characters"]), "Personaggi,",
      sum(1 for b in v3["buildings"] if b.get("azione")), "edifici con azione")
