#!/usr/bin/env python3
# Confronta due o piu' lotti `audit_partita --games N` a parita' di semi:
# punti per canale, vittorie per strategia e, se il lotto li ha, sopra chi si
# e' costruito (basi proprie, basi altrui, propri intatti spianati). E' il
# compagno di confronta_vita.py per il torneo; per un lotto solo c'e'
# confronta_strategie.py, che dice di piu' su ogni strategia.
#
#   python3 tools/confronta_torneo.py oggi.csv variante.csv [altra.csv ...]
import sys, collections

FUORI = ("seme", "posto", "giocatore", "pv", "strategia", "sopra", "quota_max",
         "costruiti", "piano", "centro_attivato", "oro_centro",
         "sopra_propri", "sopra_altrui", "spianati", "scavo_scavato", "scavo_e5")

def leggi(f):
    regole = {}
    righe = []
    for l in open(f):
        l = l.strip()
        if l.startswith("# ") and " = " in l:
            k, v = l[2:].split(" = ", 1); regole[k] = v
        elif ";" in l and not l.startswith("#"):
            righe.append(l)
    hdr = righe[0].split(";")
    dati = [dict(zip(hdr, l.split(";"))) for l in righe[1:]]
    canali = [k for k in hdr if k not in FUORI]
    n = len(dati)
    partite = len(set(d["seme"] for d in dati))
    media = lambda k: sum(int(d[k]) for d in dati) / n
    vinte, giocate = collections.Counter(), collections.Counter()
    for d in dati:
        giocate[d["strategia"]] += 1
        if int(d["posto"]) == 1: vinte[d["strategia"]] += 1
    m = {"PV medi": media("pv")}
    for c in canali: m["  " + c] = media(c)
    m["costruiti"] = media("costruiti")
    m["costruiti sopra un altro"] = media("sopra")
    m["altezza massima"] = media("quota_max")
    if "sopra_propri" in hdr:
        m["basi proprie"] = media("sopra_propri")
        m["basi altrui"] = media("sopra_altrui")
        m["propri intatti spianati"] = media("spianati")
    if "scavo_scavato" in hdr:
        m["Scavo incassato scavando"] = media("scavo_scavato")
        m["  di cui nell'era 5"] = media("scavo_e5")
    for s in sorted(giocate): m["vince " + s] = vinte[s] / giocate[s]
    return regole, partite, m

NOMI_PREMIO = {"per_livello": "premio S×L", "piu_livello": "premio S+L", "per_livello_meno_uno": "premio S×(L−1)"}

def etichetta(regole):
    pezzi = []
    if regole.get("rovina_gap") == "1": pezzi.append("ogni fallimento fa rovina")
    elif regole.get("senza_rudere") == "true": pezzi.append("senza rudere")
    if regole.get("rovina_gap") not in (None, "1"): pezzi.append(f"rovina a −{regole['rovina_gap']}")
    if regole.get("spianare_conserva_scavo") == "true": pezzi.append("Scavo mai azzerato")
    if regole.get("scavo_a_chi_scava") == "true": pezzi.append("Scavo a chi scava")
    if regole.get("sconto_macerie_solo_altrui") == "true": pezzi.append("sconto solo sulle altrui")
    if regole.get("disturbo_vp", "0") != "0": pezzi.append(f"disturbo {regole['disturbo_vp']}")
    if regole.get("verticality_vp", "").count(": 0") == 4: pezzi.append("senza Verticalità")
    if regole.get("premio_scavo", "nessuno") != "nessuno": pezzi.append(NOMI_PREMIO.get(regole["premio_scavo"], regole["premio_scavo"]))
    # Il file dati: la riga "# dati = ..." c'e' solo quando non e' cards.json.
    if "dati" in regole: pezzi.insert(0, "v2 tre risorse" if "v2" in regole["dati"] else regole["dati"])
    return ", ".join(pezzi) if pezzi else "oggi"

lotti = [leggi(f) for f in sys.argv[1:]]
if len(lotti) < 2: sys.exit("servono almeno due CSV --games")
rif = lotti[0][2]
print("| per giocatore | " + " | ".join(f"{etichetta(r)} ({p} partite)" for r, p, _ in lotti) + " |")
print("|---|" + "--:|" * len(lotti))
for k in rif:
    celle = []
    for j, (_, _, m) in enumerate(lotti):
        v = m.get(k)
        if v is None: celle.append("—"); continue
        pct = k.startswith("vince ")
        cella = f"{v:.1%}" if pct else f"{v:.2f}"
        if j > 0: cella += f" ({v - rif[k]:+.1%})" if pct else f" ({v - rif[k]:+.2f})"
        celle.append(cella)
    print(f"| {k} | " + " | ".join(celle) + " |")
