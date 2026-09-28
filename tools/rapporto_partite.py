#!/usr/bin/env python3
"""Il rapporto delle partite simulate (registro 125).

    python3 tools/rapporto_partite.py p2.err p3.err p4.err > rapporto.json

Legge le righe "J {...}" che `audit_partita --rapporto 1` scrive su stderr,
una per partita, e le riassume per numero di giocatori: strategie, canali dei
punti, fonti e usi delle risorse, edifici (quanti se ne costruiscono, quanto
durano, quanto rendono), potenziamenti, personaggi, eventi e tessere.
I nomi delle carte vengono da data/cards-v2.json.
"""
import json, sys, os, collections

RADICE = os.path.join(os.path.dirname(__file__), "..")
V2 = json.load(open(os.path.join(RADICE, "data/cards-v2.json"), encoding="utf-8"))
NOMI = {}
for blocco in ("buildings", "upgrades", "characters", "events", "monuments", "legacies"):
    righe = V2.get(blocco, [])
    for c in (righe.values() if isinstance(righe, dict) else righe):
        NOMI[c["id"]] = c.get("name", c["id"])
for t in V2.get("tessere_era", []):
    NOMI[t["id"]] = t["name"]
EDIFICI = {b["id"]: b for b in V2["buildings"]}
POTENZ = {u["id"]: u for u in V2["upgrades"]}
RISORSE = ("pietra", "oro", "idee")


def leggi(percorso):
    for riga in open(percorso, encoding="utf-8", errors="replace"):
        if riga.startswith("J "):
            yield json.loads(riga[2:])


def media(xs):
    xs = list(xs)
    return sum(xs) / len(xs) if xs else 0.0


def riassumi(partite):
    n = partite[0]["n"]
    G = len(partite)
    out = {"giocatori": n, "partite": G}
    # ---- panoramica
    vincitori = [min(p["giocatori"], key=lambda x: x["posto"]) for p in partite]
    tutti = [g for p in partite for g in p["giocatori"]]
    distacco = []
    for p in partite:
        o = sorted(p["giocatori"], key=lambda x: x["posto"])
        distacco.append(o[0]["vp"] - o[1]["vp"])
    out["panoramica"] = {
        "pv_medi": media(g["vp"] for g in tutti),
        "pv_vincitore": media(g["vp"] for g in vincitori),
        "pv_ultimo": media(max(p["giocatori"], key=lambda x: x["posto"])["vp"] for p in partite),
        "distacco_medio": media(distacco),
        "partite_strette": sum(1 for d in distacco if d <= 3) / G,
        "edifici_a_testa": media(sum(1 for b in p["edifici"] if b["own"] == g["i"]) for p in partite for g in p["giocatori"]),
        "edifici_sopra": media(sum(1 for b in p["edifici"] if b["lv"] > 0) for p in partite) / n,
        "livello_max": media(max((b["lv"] for b in p["edifici"]), default=0) for p in partite),
        "in_piedi_fine": media(sum(1 for b in p["edifici"] if b["stato"] == "intatto") for p in partite),
        "costruiti_partita": media(len(p["edifici"]) for p in partite),
    }
    # ---- strategie
    st = collections.defaultdict(lambda: {"giocate": 0, "vinte": 0, "pv": 0, "canali": collections.Counter(), "posto": 0})
    for p in partite:
        for g in p["giocatori"]:
            s = st[g["strategia"]]
            s["giocate"] += 1; s["pv"] += g["vp"]; s["posto"] += g["posto"]
            if g["posto"] == 1: s["vinte"] += 1
            s["canali"].update(g["canali"])
    out["strategie"] = sorted([{
        "nome": k, "giocate": v["giocate"], "vince": v["vinte"] / v["giocate"],
        "atteso": 1 / n, "pv": v["pv"] / v["giocate"], "posto": v["posto"] / v["giocate"],
        "canali": {c: x / v["giocate"] for c, x in v["canali"].items()}}
        for k, v in st.items()], key=lambda x: -x["vince"])
    # ---- canali dei punti
    canali = collections.Counter(); canali_v = collections.Counter()
    for g in tutti: canali.update(g["canali"])
    for g in vincitori: canali_v.update(g["canali"])
    out["canali"] = {c: {"tutti": canali[c] / len(tutti), "vincitori": canali_v[c] / G}
                     for c in sorted(set(canali) | set(canali_v))}
    # ---- risorse: entrate per fonte, uscite per uso
    ent = collections.defaultdict(collections.Counter)
    usc = collections.defaultdict(collections.Counter)
    for g in tutti:
        for k, v in g["cnt"].items():
            parti = k.split("_")
            if parti[0] in ("in", "out") and parti[-1] in RISORSE:
                (ent if parti[0] == "in" else usc)["_".join(parti[1:-1])][parti[-1]] += v
    out["entrate"] = {f: {r: c[r] / len(tutti) for r in RISORSE} for f, c in ent.items()}
    out["uscite"] = {u: {r: c[r] / len(tutti) for r in RISORSE} for u, c in usc.items()}
    out["risorse_finali"] = {r: media(g["finali"][i] for g in tutti) for i, r in enumerate(RISORSE)}
    azioni = collections.Counter()
    for g in tutti:
        for k, v in g["cnt"].items():
            if k.startswith("az_"): azioni[k[3:]] += v
    out["azioni"] = {k: v / len(tutti) for k, v in azioni.items()}
    # ---- edifici
    ed = collections.defaultdict(lambda: collections.Counter())
    for p in partite:
        vinc = min(p["giocatori"], key=lambda x: x["posto"])["i"]
        ultima = max(int(e) for e in p["eventi"]) if p["eventi"] else 5
        for b in p["edifici"]:
            c = ed[b["id"]]
            c["n"] += 1
            if b["own"] == vinc: c["del_vincitore"] += 1
            c["pv"] += sum(b["vp"].values())
            for k, v in b["vp"].items(): c["pv_" + k] += v
            if b["lv"] > 0: c["sopra"] += 1
            if b["stato"] == "intatto": c["intatto_fine"] += 1
            if b["stato"] == "sepolto": c["sepolto"] += 1
            if b["spianato"]: c["spianato"] += 1
            elif b["rovina"]:
                c["crollato"] += 1                   # in rovina per l'evento (o esaurito)
                c["ere_prima_crollo"] += b["rovina"] - b["era"]
                if b["rovina"] == b["era"]: c["crollo_subito"] += 1
            fine = b["rovina"] or b["sepolto"] or ultima + 1
            c["ere_in_piedi"] += max(0, fine - b["era"])
            c["upg"] += len(b["upg"])
    righe = []
    for bid, c in ed.items():
        d = EDIFICI.get(bid, {})
        righe.append({"id": bid, "nome": NOMI.get(bid, bid), "era": d.get("era"), "costruiti": c["n"] / G,
            "del_vincitore": c["del_vincitore"] / c["n"], "pv": c["pv"] / c["n"],
            "pv_canali": {k[3:]: v / c["n"] for k, v in c.items() if k.startswith("pv_")},
            "crollato": c["crollato"] / c["n"], "crollo_subito": c["crollo_subito"] / c["n"],
            "ere_prima_crollo": c["ere_prima_crollo"] / c["crollato"] if c["crollato"] else None,
            "intatto_fine": c["intatto_fine"] / c["n"], "sepolto": c["sepolto"] / c["n"],
            "spianato": c["spianato"] / c["n"], "sopra": c["sopra"] / c["n"],
            "ere_in_piedi": c["ere_in_piedi"] / c["n"], "potenziamenti": c["upg"] / c["n"],
            "resistenza": d.get("resistance"), "lampo": d.get("lampo"), "rendita": d.get("rendita"),
            "scavo": d.get("scavo"), "copie": d.get("copie", 1)})
    for bid, d in EDIFICI.items():
        if bid not in ed:
            righe.append({"id": bid, "nome": d["name"], "era": d["era"], "costruiti": 0.0})
    out["edifici"] = sorted(righe, key=lambda x: (x["era"] or 0, -x["costruiti"]))
    # ---- potenziamenti
    up = collections.defaultdict(collections.Counter)
    for p in partite:
        vinc = min(p["giocatori"], key=lambda x: x["posto"])["i"]
        for b in p["edifici"]:
            for u in b["upg"]:
                up[u]["n"] += 1
                if b["own"] == vinc: up[u]["del_vincitore"] += 1
    out["potenziamenti"] = sorted([{"id": u, "nome": d["name"], "era": d["era"], "famiglia": d["family"],
        "presi": up[u]["n"] / G, "del_vincitore": up[u]["del_vincitore"] / up[u]["n"] if up[u]["n"] else None}
        for u, d in POTENZ.items()], key=lambda x: (x["era"], -x["presi"]))
    # ---- personaggi
    pe = collections.defaultdict(collections.Counter)
    for p in partite:
        for g in p["giocatori"]:
            for cid in g["pers"]:
                pe[cid]["n"] += 1
                if g["posto"] == 1: pe[cid]["vince"] += 1
                pe[cid]["pv"] += g["vp"]
    out["personaggi"] = sorted([{"id": c, "nome": NOMI.get(c, c), "presi": v["n"] / G,
        "vince": v["vince"] / v["n"], "pv": v["pv"] / v["n"]} for c, v in pe.items()],
        key=lambda x: -x["presi"])
    # ---- eventi e rovine per era
    ev = collections.defaultdict(collections.Counter)
    for p in partite:
        for era, eid in p["eventi"].items():
            crolli = sum(1 for b in p["edifici"] if b["rovina"] == int(era) and not b["spianato"])
            ev[eid]["n"] += 1; ev[eid]["crolli"] += crolli; ev[eid]["era"] = int(era)
    out["eventi"] = sorted([{"id": e, "nome": NOMI.get(e, e), "era": v["era"], "uscito": v["n"] / G,
        "crolli": v["crolli"] / v["n"]} for e, v in ev.items() if e], key=lambda x: (x["era"], -x["crolli"]))
    per_era = collections.Counter(); costruiti_era = collections.Counter()
    for p in partite:
        for b in p["edifici"]:
            costruiti_era[b["era"]] += 1
            if b["rovina"] and not b["spianato"]: per_era[b["rovina"]] += 1
    out["ere"] = [{"era": e, "costruiti": costruiti_era[e] / G, "crolli": per_era[e] / G} for e in range(1, 6)]
    # ---- tessere dell'era
    te = collections.Counter()
    for p in partite: te.update(p["tessere"])
    out["tessere"] = sorted([{"id": t, "nome": NOMI.get(t, t), "scatta": te[t] / G} for t in
        [x["id"] for x in V2.get("tessere_era", [])]], key=lambda x: -x["scatta"])
    # ---- eredita' e monumenti
    er = collections.defaultdict(collections.Counter)
    mo = collections.Counter()
    for g in tutti:
        if g["eredita"]:
            er[g["eredita"]]["n"] += 1
            if g["canali"].get("eredita", 0) > 0: er[g["eredita"]]["riuscita"] += 1
            if g["posto"] == 1: er[g["eredita"]]["vince"] += 1
        mo.update(g["monumenti"])
    out["eredita"] = sorted([{"id": k, "nome": NOMI.get(k, k), "riuscita": v["riuscita"] / v["n"],
        "vince": v["vince"] / v["n"]} for k, v in er.items()], key=lambda x: -x["riuscita"])
    out["monumenti"] = sorted([{"id": k, "nome": NOMI.get(k, k), "presi": v / G} for k, v in mo.items()],
        key=lambda x: -x["presi"])
    return out


if __name__ == "__main__":
    risultato = []
    for percorso in sys.argv[1:]:
        partite = list(leggi(percorso))
        if partite: risultato.append(riassumi(partite))
    json.dump(risultato, sys.stdout, ensure_ascii=False, indent=1)
