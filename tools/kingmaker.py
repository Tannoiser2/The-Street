#!/usr/bin/env python3
# Quanto decide l'ultima era. Legge uno o piu' lotti `audit_partita --games`
# (una riga per giocatore, con i contatori `scavo_scavato` e `scavo_e5`) e per
# ogni lotto stampa tre numeri:
#   quota era5         quanto del premio di scavo si incassa nell'era 5;
#   bottino>=distacco  in quante partite il bottino di scavo dell'era 5 del
#                      vincitore vale almeno il suo distacco dal secondo;
#   cambia vincitore   in quante partite, tolto lo Scavo dell'era 5 a tutti,
#                      vincerebbe un altro.
# E' la misura del "kingmaker": l'ultimo che costruisce prende tutto il
# bottino? Nasce nella prima misura della terza risorsa (la-terza-risorsa.md)
# e da allora ogni misura la riporta; stava fuori dal repo fino al 27 settembre.
#
#   python3 tools/kingmaker.py lotto_p2.csv lotto_p3.csv lotto_p4.csv
import sys


def leggi(f):
    righe = [l.strip() for l in open(f) if ";" in l and not l.startswith("#")]
    hdr = righe[0].split(";")
    return [dict(zip(hdr, l.split(";"))) for l in righe[1:]]


for f in sys.argv[1:]:
    d = leggi(f)
    g = {}
    for r in d:
        g.setdefault(r["seme"], []).append(r)
    n = len(g)
    a = b = 0
    premio = e5 = 0
    for rows in g.values():
        rows = sorted(rows, key=lambda r: -int(r["pv"]))
        w = rows[0]
        dist = int(w["pv"]) - int(rows[1]["pv"])
        if int(w["scavo_e5"]) >= dist and int(w["scavo_e5"]) > 0:
            a += 1
        senza = sorted(rows, key=lambda r: -(int(r["pv"]) - int(r["scavo_e5"])))
        if senza[0]["giocatore"] != w["giocatore"]:
            b += 1
        premio += sum(int(r["scavo_scavato"]) for r in rows)
        e5 += sum(int(r["scavo_e5"]) for r in rows)
    print(f.split("/")[-1], "partite", n,
          "quota era5 %.0f%%" % (100 * e5 / max(1, premio)),
          "bottino>=distacco %.0f%%" % (100 * a / n),
          "cambia vincitore %.0f%%" % (100 * b / n))
