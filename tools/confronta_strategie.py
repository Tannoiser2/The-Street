#!/usr/bin/env python3
# Legge il CSV di `audit_partita --games N [--candidate]` e dice come se la
# sono cavata le strategie: vittorie, punti, e quanto ognuna prende dal canale
# che insegue.
#
#   godot --headless res://scenes/audit_partita.tscn -- --players 3 --games 600 --candidate > strat.csv
#   python3 tools/confronta_strategie.py strat.csv
import sys, collections, statistics as st

# Il canale che ogni strategia insegue. La Bilanciata non ne insegue nessuno:
# e' il controllo, e serve a sapere se specializzarsi conviene.
PROPRIO = {"rendita": "rendita", "lampo": "lampo", "scavo": "scavo",
           "verticale": "verticalita", "bilanciata": None,
           "continuita": "continuita", "obiettivi": "monumenti"}

righe = [l.strip() for l in open(sys.argv[1]) if ";" in l and not l.startswith("#")]
hdr = righe[0].split(";")
dati = [dict(zip(hdr, l.split(";"))) for l in righe[1:]]
for d in dati:
    for k in hdr:
        if k != "strategia": d[k] = int(d[k])

partite = collections.defaultdict(list)
for d in dati: partite[d["seme"]].append(d)
# `piano` dice chi ha pianificato, e forma del tavolo non sono punti: fuori.
canali = [k for k in hdr if k not in ("seme", "posto", "giocatore", "pv", "strategia",
                                      "sopra", "quota_max", "costruiti", "piano")]

vinte, giocate, punti = collections.Counter(), collections.Counter(), collections.defaultdict(list)
per_canale = collections.defaultdict(collections.Counter)
distacchi = []
for s, g in partite.items():
    g.sort(key=lambda x: x["posto"])
    vinte[g[0]["strategia"]] += 1
    distacchi.append(g[0]["pv"] - g[-1]["pv"])
    for d in g:
        giocate[d["strategia"]] += 1
        punti[d["strategia"]].append(d["pv"])
        for c in canali: per_canale[d["strategia"]][c] += d[c]

n_gioc = len(next(iter(partite.values())))
print(f"{len(partite)} partite a {n_gioc} giocatori · attesa per strategia: {100/n_gioc:.1f}%")
print()
print("strategia     vittorie        PV medi   il canale che insegue")
for s in sorted(giocate, key=lambda s: -vinte[s] / giocate[s]):
    n = giocate[s]
    q = vinte[s] / n
    ic = 196 * (q * (1 - q) / n) ** 0.5
    c = PROPRIO.get(s)
    suo = f"{c} {per_canale[s][c]/n:.1f}" if c else "(nessuno: e' il controllo)"
    print(f"{s:<12} {100*q:5.1f}% ±{ic:.1f}   {st.mean(punti[s]):6.1f}   {suo}")
print()
print("media di ogni canale, strategia per strategia:")
print("%-12s %s" % ("", " ".join("%10s" % c[:10] for c in canali)))
for s in giocate:
    print("%-12s %s" % (s, " ".join("%10.1f" % (per_canale[s][c] / giocate[s]) for c in canali)))
print()
distacchi.sort()
print("distacco primo-ultimo: media %.1f · mediana %.0f · decili %s" % (
    st.mean(distacchi), st.median(distacchi),
    [distacchi[int(len(distacchi) * q / 10)] for q in range(1, 10)]))
