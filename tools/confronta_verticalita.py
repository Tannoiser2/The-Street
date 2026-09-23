#!/usr/bin/env python3
# Mette a confronto lo stesso lotto di partite giocato con tabelle della
# Verticalita' diverse. I semi sono gli stessi in tutti i lotti, quindi le
# carte escono nello stesso ordine: l'unica differenza e' quanto paga salire
# (e come i bot ci reagiscono).
#
#   for t in 2,6,12,20 2,5,9,14 2,5,8,11 2,4,6,8; do
#     godot --headless res://scenes/audit_partita.tscn -- \
#       --players 3 --games 1000 --seed 400000 --verticalita $t > vt_$t.csv
#   done
#   python3 tools/confronta_verticalita.py vt_*.csv
import sys, collections, statistics as st

def leggi(f):
    righe = [l.strip() for l in open(f) if l.strip()]
    tabella = "?"
    for l in righe:
        if l.startswith("# verticality_vp"):
            tabella = "/".join(l.split("{")[1].strip(" }").replace('"', "").split(", ")[i].split(": ")[1]
                               for i in range(4))
    dati = [l for l in righe if ";" in l]
    hdr = dati[0].split(";")
    out = []
    for l in dati[1:]:
        d = dict(zip(hdr, l.split(";")))
        for k in hdr:
            if k != "strategia": d[k] = int(d[k])
        out.append(d)
    return tabella, hdr, out

lotti = [leggi(f) for f in sys.argv[1:]]
canali = [k for k in lotti[0][1]
          if k not in ("seme", "posto", "giocatore", "pv", "strategia", "sopra", "quota_max", "costruiti")]

print("%-12s %7s %7s %8s %8s %8s %8s %8s %8s" % (
    "tabella", "primo", "ultimo", "distacco", "dist/pri", "vertic.", "quota V", "sopra", "quota max"))
riassunto = []
for tabella, hdr, dati in lotti:
    partite = collections.defaultdict(list)
    for d in dati: partite[d["seme"]].append(d)
    gaps, primi, ultimi = [], [], []
    for g in partite.values():
        g.sort(key=lambda x: x["posto"])
        gaps.append(g[0]["pv"] - g[-1]["pv"])
        primi.append(g[0]["pv"])
        ultimi.append(g[-1]["pv"])
    pv = st.mean(d["pv"] for d in dati)
    vert = st.mean(d["verticalita"] for d in dati)
    print("%-12s %7.1f %7.1f %8.1f %7.0f%% %8.1f %7.0f%% %8.2f %8.2f" % (
        tabella, st.mean(primi), st.mean(ultimi), st.mean(gaps),
        100 * st.mean(gaps) / st.mean(primi), vert, 100 * vert / pv,
        st.mean(d["sopra"] for d in dati), st.mean(d["quota_max"] for d in dati)))
    riassunto.append((tabella, dati, partite))

print()
print("quota di ogni canale sul punteggio:")
print("%-12s %s" % ("tabella", " ".join("%10s" % c[:10] for c in canali)))
for tabella, dati, _ in riassunto:
    pv = st.mean(d["pv"] for d in dati)
    print("%-12s %s" % (tabella, " ".join(
        "%9.1f%%" % (100 * st.mean(d[c] for d in dati) / pv) for c in canali)))

print()
print("vittorie per strategia:")
strategie = sorted({d["strategia"] for d in lotti[0][2]})
print("%-12s %s" % ("tabella", " ".join("%11s" % s for s in strategie)))
for tabella, dati, partite in riassunto:
    vinte, giocate = collections.Counter(), collections.Counter()
    for g in partite.values():
        g.sort(key=lambda x: x["posto"])
        vinte[g[0]["strategia"]] += 1
        for d in g: giocate[d["strategia"]] += 1
    print("%-12s %s" % (tabella, " ".join(
        "%10.1f%%" % (100 * vinte[s] / giocate[s]) for s in strategie)))
