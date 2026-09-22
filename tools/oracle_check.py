#!/usr/bin/env python3
"""Confronto fra il punteggio di Godot e quello dell'oracolo Python (M3).

Non esegue il simulatore su partite proprie: sarebbe un confronto fra partite
diverse. Prende gli stati finali esportati da Godot e vi riapplica le FORMULE
di punteggio del simulatore, trascritte verbatim da
reference/simulatore_riferimento.py (modo verticalita' C, righe 527-570).

Cosi' il confronto isola le regole dalla calibrazione dei dati: lo Scavo
diverge fra cards_simulatore_legacy.json (scala 0-4) e data/cards.json
(scala 0-6), quindi si usa il valore v1.5 su entrambi i lati.

Uso:  python3 tools/oracle_check.py stati.json [stati2.json ...]
Esce 1 se una divergenza non e' fra quelle attese e documentate.
"""
import json, sys, os
from collections import Counter, defaultdict

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
CONST = json.load(open(os.path.join(ROOT, "data", "cards.json"), encoding="utf-8"))["constants"]
VBONUS = {int(k): int(v) for k, v in CONST["verticality_vp"].items()}
CONTV = {int(k): int(v) for k, v in CONST["continuity_vp"].items()}


def _is_intact(b):
    return b["state"] == "intatto" and not b["buried"]


def _is_sotterrata(b):
    return b["buried"] and not b["razed"]


def _is_spianata(b):
    return b["buried"] and b["razed"]


def _covers(b, c):
    return b["col_from"] <= c < b["col_to"]


def oracle_score(game):
    """Punteggio secondo le formule del simulatore. Valori in virgola mobile:
    l'oracolo non arrotonda, il gioco fisico sì (vedi domande-aperte punto 2)."""
    n = game["players"]
    sc = [defaultdict(float) for _ in range(n)]
    bs = game["buildings"]

    # censimento finale: "if b.state=='intact': rendita += r + vet"
    for b in bs:
        if _is_intact(b):
            if b["rendita"]:
                sc[b["owner"]]["rendita"] += b["rendita"] + b["vetusta"]
        elif _is_sotterrata(b) or _is_spianata(b):
            # "scavo += (0 if spianata else scavo*SCAVOX)"
            sc[b["owner"]]["scavo"] += 0 if _is_spianata(b) else b["scavo"]

    # verticalita', modo C. Calcolata in due varianti, per separare due effetti
    # distinti (vedi il commento in fondo al file):
    #   "verticalita"        altezza = len(stack), come il simulatore
    #   "verticalita_livelli" altezza = livello massimo, come il regolamento v1.5
    for c in range(game["n_cols"]):
        stack = [b for b in bs if _covers(b, c) and b["level"] >= 1]
        stack.sort(key=lambda b: b["level"])
        h_sim = len(stack)
        h_liv = max([b["level"] for b in bs if _covers(b, c)] or [0])
        if h_sim != h_liv:
            sc[0]["_altezza_divergente"] += 1
        cnt = Counter()
        for b in bs:
            if _covers(b, c):
                cnt[b["owner"]] += 1                            # rail + stack, ogni stato
        tot = sum(cnt.values())
        top = stack[-1] if stack else None
        for key, h in (("verticalita", h_sim), ("verticalita_livelli", h_liv)):
            if h < 1:
                continue
            bonus = VBONUS.get(min(h, 4), VBONUS[4])
            if top is not None:
                sc[top["owner"]][key] += bonus * 0.5
            for ow, k in cnt.items():
                sc[ow][key] += bonus * 0.5 * k / max(1, tot)
        # una quota arrotondata per colonna: errore massimo 0.5 ciascuna.
        # La meta' della cima e' esatta, perche' i premi (2/6/12/20) sono pari.
        if h_liv >= 1:
            for ow in cnt:
                sc[ow]["_quote"] += 1

    # continuita' di luogo
    for c in range(game["n_cols"]):
        for p in range(n):
            cc = Counter()
            for b in bs:
                if b["owner"] == p and _covers(b, c):
                    for cl in b["classes"]:
                        cc[cl] += 1
            if cc:
                mx = max(cc.values())
                if mx >= 3:
                    sc[p]["continuita"] += CONTV[3]
                elif mx >= 2:
                    sc[p]["continuita"] += CONTV[2]

    # scheletri
    for b in bs:
        if b["buried_character_era"] and (_is_sotterrata(b) or _is_spianata(b)):
            sc[b["owner"]]["scheletri"] += 6 - b["buried_character_era"]

    return sc


# Si confronta il SOLO punteggio di fine partita (`final_only`): il breakdown
# completo include anche i censimenti delle ere 1-4, gia' sul segnapunti, che
# l'oracolo non ricalcola.
# "lampo" resta fuori: Godot lo segna alla costruzione, il simulatore a fine
# partita; e' la stessa cosa contata in momenti diversi.
CHANNELS = ["rendita", "scavo", "verticalita", "continuita", "scheletri"]
# Variante dell'oracolo che usa la definizione di altezza del regolamento.
VARIANTS = {"verticalita": "verticalita_livelli"}


def main(paths):
    totals = Counter()
    diffs = defaultdict(list)
    n_games = 0
    height_mismatch = 0
    over_bound = []

    for path in paths:
        data = json.load(open(path, encoding="utf-8"))
        for game in data["games"]:
            n_games += 1
            oracle = oracle_score(game)
            height_mismatch += int(oracle[0].get("_altezza_divergente", 0))
            for s in game["godot_scores"]:
                p = s["index"]
                got = s["final_only"]
                for ch in CHANNELS:
                    g = float(got.get(ch, 0))
                    o = float(oracle[p].get(ch, 0))
                    totals[ch + "_godot"] += g
                    totals[ch + "_oracolo"] += o
                    if abs(g - o) > 1e-9:
                        diffs[ch].append((game["seed"], p, g, o))
                    if ch in VARIANTS:
                        v = float(oracle[p].get(VARIANTS[ch], 0))
                        totals[ch + "_variante"] += v
                        if abs(g - v) > 1e-9:
                            diffs[ch + "_variante"].append((game["seed"], p, g, v))
                            bound = 0.5 * oracle[p].get("_quote", 0)
                            if abs(g - v) > bound + 1e-9:
                                over_bound.append((game["seed"], p, g, v, bound))

    print(f"Partite confrontate: {n_games}  ({len(paths)} file)\n")
    print(f"{'canale':14s} {'Godot':>10s} {'oracolo':>10s} {'scarto':>9s}  {'partite con scarto':>20s}")
    exact = True
    for ch in CHANNELS:
        g, o = totals[ch + "_godot"], totals[ch + "_oracolo"]
        nd = len({(s, p) for s, p, _, _ in diffs[ch]})
        if nd:
            exact = False
        print(f"{ch:14s} {g:10.1f} {o:10.1f} {g - o:+9.1f}  {nd:20d}")

    print(f"\nColonne con altezza calcolata diversamente (len(stack) vs livello massimo): {height_mismatch}")
    gv = totals["verticalita_godot"]
    ov = totals["verticalita_oracolo"]
    vv = totals["verticalita_variante"]
    nd_v = len({(s, p) for s, p, _, _ in diffs["verticalita_variante"]})
    print("\nVerticalita', scomposizione dello scarto:")
    print(f"  oracolo con altezza = numero di edifici sopraelevati : {ov:8.1f}")
    print(f"  oracolo con altezza = livello massimo (regolamento)  : {vv:8.1f}   <- differenza di MODELLO: {vv - ov:+.1f}")
    print(f"  Godot                                                : {gv:8.1f}   <- ARROTONDAMENTO: {gv - vv:+.1f}")
    if diffs["verticalita_variante"]:
        worst_v = max(abs(a - b) for _, _, a, b in diffs["verticalita_variante"])
        print(f"  a parita' di modello restano {nd_v} casi, scarto massimo {worst_v:.2f} PV")

    for ch in CHANNELS:
        if not diffs[ch]:
            continue
        ex = diffs[ch][:4]
        worst = max(abs(g - o) for _, _, g, o in diffs[ch])
        print(f"\n— {ch}: {len(diffs[ch])} scarti, massimo {worst:.2f}")
        for seed, p, g, o in ex:
            print(f"    seme {seed} giocatore {p}: Godot {g:g} · oracolo {o:g} · scarto {g - o:+g}")

    # L'unico scarto atteso e' l'arrotondamento della verticalita'.
    unexpected = [ch for ch in CHANNELS if ch != "verticalita" and diffs[ch]]
    if exact:
        print("\nOK: tutti i canali coincidono esattamente.")
        return 0
    if unexpected:
        print(f"\nFALLITO: scarti non attesi nei canali {unexpected}.")
        return 1
    worst_v = max((abs(a - b) for _, _, a, b in diffs["verticalita_variante"]), default=0.0)
    print("\nSolo la verticalita' diverge, per due cause entrambe documentate:")
    print("  1. MODELLO - il simulatore tratta la colonna come pila contigua, quindi")
    print("     l'altezza e' il numero di edifici sopraelevati. In v1.5 un edificio")
    print("     largo sta tutto al livello \"piu' alto delle basi + 1\", quindi una")
    print("     colonna puo' saltare un livello e l'altezza NON e' un conteggio.")
    print("     Il simulatore non puo' rappresentare quel salto: e' un limite suo,")
    print("     non una divergenza di regola. Vedi docs/domande-aperte.md punto 16.")
    print("  2. ARROTONDAMENTO - l'oracolo tiene i decimali, Godot arrotonda la quota")
    print("     di ciascun proprietario: il gioco fisico non ha mezzi punti.")
    print("     Vedi docs/domande-aperte.md punto 2.")
    print(f"\nA parita' di modello resta il solo arrotondamento: scarto massimo {worst_v:.2f} PV.")
    print(f"\nA parita' di modello, ogni scarto e' confrontato col suo limite teorico:")
    print(f"  0,5 PV per ciascuna colonna in cui il giocatore riceve una quota.")
    if over_bound:
        print(f"FALLITO: {len(over_bound)} scarti superano il limite di arrotondamento.")
        for seed, p, g, v, b in over_bound[:5]:
            print(f"    seme {seed} giocatore {p}: scarto {abs(g - v):.2f} > limite {b:.2f}")
        return 1
    print(f"OK: tutti i {len(diffs['verticalita_variante'])} scarti rientrano nel limite."
          f" Massimo osservato {worst_v:.2f} PV.")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:] or ["stati.json"]))
