#!/usr/bin/env python3
# La tabella dell'era di prova della v3 (docs/proposte/v3-era-1.md, "Che cosa
# si misura"): legge le righe `J {...}` del rapporto (stderr di audit_partita
# con --rapporto 1, di solito con --fino_era N) e stampa, a giocatore e per
# strategia, quanto si e' prodotto, speso e lasciato morire, i PV per canale,
# le costruzioni e i crolli, i Personaggi presi e a quale giro del draft, le
# azioni scattate, le vittorie con l'errore.
#
#   python3 tools/misura_era.py e1.err [--era 2]
#
# Dall'era 2 in su l'era e' la DIFFERENZA fra due fotografie di fine era
# (contatori `snap_e<N>_*`, `cum_e<N>_*`, `pv_e<N>*`, registro 162): quel che
# l'era ha dato, non il cumulato della partita.
import json, sys, math, os
from collections import defaultdict

args = sys.argv[1:]
era = 1
if "--era" in args:
    i = args.index("--era"); era = int(args[i + 1]); del args[i:i + 2]
righe = [json.loads(l[2:]) for f in args for l in open(f, encoding="utf-8") if l.startswith("J ")]
if not righe:
    sys.exit("nessuna riga J nel file")
E, E0 = str(era), str(era - 1)
nomi, era_di = {}, {}
for cand in ["data/proposte/cards-v3-era1.json", "data/cards-v2.json"]:
    p = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", cand)
    if os.path.exists(p):
        d = json.load(open(p, encoding="utf-8"))
        nomi = {c["id"]: c["name"] for c in d["characters"]}
        nomi.update({b["id"]: b["name"] for b in d["buildings"]})
        era_di = {c["id"]: c.get("era") for c in d["characters"]}
        break

def nome(cid): return nomi.get(cid, cid)

def delta(c, k):
    """Il contatore cumulativo `k` nell'era: la fotografia a fine era meno quella dell'era prima."""
    return c.get("snap_e%s_%s" % (E, k), 0) - (c.get("snap_e%s_%s" % (E0, k), 0) if era > 1 else 0)

acc = defaultdict(lambda: defaultdict(float))   # strategia -> voce -> somma
n = defaultdict(int)                             # strategia -> giocatori
vitt = defaultdict(int)
pers_presi = defaultdict(int); pers_giro = defaultdict(float)
pers_strat = defaultdict(lambda: defaultdict(int))
az = defaultdict(int)
crolli = defaultdict(int); costruiti_id = defaultdict(int)
rovine_era = 0.0
sopra_rovine = 0
for r in righe:
    rovine_era += r.get("rovine_era", {}).get(E, 0)
    for e in r["edifici"]:
        if e["era"] != era: continue
        costruiti_id[e["id"]] += 1
        if e["rovina"] == era: crolli[e["id"]] += 1
        if e["lv"] > 0: sopra_rovine += 1
    for g in r["giocatori"]:
        s = g["strategia"]; n[s] += 1; n["tutte"] += 1
        c = g["cnt"]
        fotografie = any(k.startswith("snap_e%s_" % E) for k in c)
        for st in (s, "tutte"):
            a = acc[st]
            for ris in ("pietra", "oro", "idee"):
                # La produzione dell'era: tutte le entrate `in_<fonte>_<risorsa>` tranne
                # avanzo e cambio (conversioni). Nell'era 1 le entrate sono tutte dell'era;
                # dall'era 2 il cumulato `cum_e<N>` meno quello dell'era prima.
                if era == 1 and not fotografie:
                    a["prod_" + ris] += sum(v for k, v in c.items() if k.startswith("in_") and k.endswith("_" + ris)
                                            and not k.startswith("in_avanzo") and not k.startswith("in_cambio"))
                    for fonte in ("terreno", "tessera", "personaggi", "edifici", "azioni", "effetti", "passa", "centro"):
                        a["fonte_" + fonte] += c.get("in_%s_%s" % (fonte, ris), 0)
                elif era == 1:
                    a["prod_" + ris] += c.get("cum_e1_%s" % ris, 0)
                else:
                    a["prod_" + ris] += c.get("cum_e%s_%s" % (E, ris), 0) - c.get("cum_e%s_%s" % (E0, ris), 0)
                a["morto_" + ris] += c.get("morte_e%s_%s" % (E, ris), c.get("resta_e%s_%s" % (E, ris), 0))
            if not fotografie:
                # rapporti vecchi, senza fotografie: i cumulati sono dell'era 1
                a["costruiti"] += c.get("az_costruisci", 0); a["potenziati"] += c.get("az_potenzia", 0)
                a["passati"] += c.get("az_passa", 0); a["cambi"] += c.get("cambi", 0); a["sconti"] += c.get("sconti_v3", 0)
                a["extra_aperti"] += c.get("extra_aperti", 0); a["extra_usati"] += c.get("extra_usati", 0)
                a["pv"] += g["vp"]
                for k, v in g["canali"].items(): a["pv_" + k] += v
            else:
                for k in ("az_costruisci", "az_potenzia", "az_passa", "cambi", "sconti_v3", "extra_aperti", "extra_usati", "scavo_scavato"):
                    a[k] += delta(c, k)
                a["costruiti"] = a["az_costruisci"]; a["potenziati"] = a["az_potenzia"]; a["passati"] = a["az_passa"]
                a["sconti"] = a["sconti_v3"]
                a["pv"] += c.get("pv_e%s" % E, 0) - (c.get("pv_e%s" % E0, 0) if era > 1 else 0)
                for k in g["canali"]:
                    a["pv_" + k] += c.get("pv_e%s_%s" % (E, k), 0) - (c.get("pv_e%s_%s" % (E0, k), 0) if era > 1 else 0)
            if g["posto"] == 1: vitt[st] += 1
        for k, v in c.items():
            if k.startswith("az3_"): az[k[4:]] += v
            if k.startswith("draft_g"):
                giro, cid = k[7:].split("_", 1)
                if era_di and era_di.get(cid) not in (None, era): continue   # solo i Personaggi dell'era misurata
                pers_presi[cid] += v; pers_giro[cid] += int(giro) * v; pers_strat[cid][s] += v

P = len(righe)
print("partite %d, era %d, %d giocatori a partita" % (P, era, n["tutte"] // P))
strategie = [s for s in sorted(n) if s != "tutte"] + ["tutte"]

def riga(voce, f, fmt="%10.1f"):
    print("%-22s" % voce + " ".join(fmt % f(acc[s], n[s]) for s in strategie))

print("\n%-22s" % "" + " ".join("%10s" % s[:10] for s in strategie))
for ris, et in (("pietra", "Costruzione"), ("oro", "Denaro"), ("idee", "Idee")):
    riga("prodotto " + et, lambda a, k, r=ris: a["prod_" + r] / k)
riga("prodotto in tutto", lambda a, k: sum(a["prod_" + r] for r in ("pietra", "oro", "idee")) / k)
for fonte in ("terreno", "tessera", "personaggi", "edifici", "azioni", "effetti", "passa", "centro"):
    if acc["tutte"]["fonte_" + fonte] > 0:
        riga("  da " + fonte, lambda a, k, f=fonte: a["fonte_" + f] / k)
riga("speso", lambda a, k: sum(a["prod_" + r] - a["morto_" + r] for r in ("pietra", "oro", "idee")) / k)
for ris, et in (("pietra", "Costruzione"), ("oro", "Denaro"), ("idee", "Idee")):
    riga("MORTO " + et, lambda a, k, r=ris: a["morto_" + r] / k)
riga("morto in tutto", lambda a, k: sum(a["morto_" + r] for r in ("pietra", "oro", "idee")) / k)
print()
riga("costruiti", lambda a, k: a["costruiti"] / k, "%10.2f")
riga("potenziati", lambda a, k: a["potenziati"] / k, "%10.2f")
riga("passati", lambda a, k: a["passati"] / k, "%10.2f")
riga("cambi fatti", lambda a, k: a["cambi"] / k, "%10.2f")
riga("sconti usati", lambda a, k: a["sconti"] / k, "%10.2f")
if acc["tutte"]["extra_aperti"] > 0:
    riga("extra aperti", lambda a, k: a["extra_aperti"] / k, "%10.2f")
    riga("extra usati", lambda a, k: a["extra_usati"] / k, "%10.2f")
if acc["tutte"]["scavo_scavato"] > 0:
    riga("bonus scavo (PV)", lambda a, k: a["scavo_scavato"] / k, "%10.2f")
print()
riga("PV dell'era", lambda a, k: a["pv"] / k)
canali = sorted({k[3:] for s in acc for k in acc[s] if k.startswith("pv_")})
for ch in canali:
    riga("  " + ch, lambda a, k, c=ch: a["pv_" + c] / k)
print()
def vittoria(s):
    k = n[s]; q = 100.0 * vitt[s] / k
    err = 100.0 * math.sqrt(q / 100 * (1 - q / 100) / k)
    return "%5.0f±%-3.0f" % (q, err)
print("%-22s" % "vittorie %" + " ".join("%10s" % vittoria(s) for s in strategie))
print("   (atteso %.0f con %d giocatori; con --fino_era le vittorie sono a era chiusa)" % (100.0 / (n["tutte"] // P), n["tutte"] // P))

print("\nEDIFICI dell'era %d: costruiti a partita, e quanti crollano all'evento dell'era" % era)
for cid, v in sorted(costruiti_id.items(), key=lambda x: -x[1]):
    print("  %-24s %5.2f  crolla %3.0f%%" % (nome(cid), v / P, 100.0 * crolli[cid] / v))
print("  rovine lasciate dall'era: %.1f a partita; costruiti sopra (livello 1+): %.1f a partita" % (rovine_era / P, sopra_rovine / P))

print("\nPERSONAGGI dell'era %d: quante volte presi (a partita), giro medio del draft (1 = prima scelta), da chi" % era)
for cid, v in sorted(pers_presi.items(), key=lambda x: pers_giro[x[0]] / x[1]):
    chi = ", ".join("%s %d" % (s[:4], k) for s, k in sorted(pers_strat[cid].items(), key=lambda x: -x[1])[:3])
    print("  %-24s %5.2f  giro %4.2f  %s" % (nome(cid), v / P, pers_giro[cid] / v, chi))

print("\nAZIONI scattate a partita (tutta la partita giocata):")
for k, v in sorted(az.items(), key=lambda x: -x[1]):
    print("  %-12s %6.2f" % (k, v / P))
