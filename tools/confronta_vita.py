#!/usr/bin/env python3
# Confronta due (o piu') lotti `audit_partita --vita` a parita' di semi e ne
# stampa il quadro d'insieme in una tabella: quanti edifici restano in piedi,
# quanti cadono nell'era in cui nascono, quanti finiscono sepolti e quanto
# rende ogni canale di punteggio. E' la tabella di `quanto-punisce-il-gioco.md`
# resa eseguibile: prima si ricalcolava a mano.
#
#   python3 tools/confronta_vita.py con.csv senza.csv [altro.csv ...]
#
# La prima colonna e' il riferimento, le altre portano anche la differenza.
# Le etichette delle colonne vengono dall'intestazione dei lotti (`rovina=`,
# `rudere=`): due lotti che dichiarano le stesse regole si chiamano uguali,
# ed e' giusto cosi' - vuol dire che si sta misurando il rumore.
import sys, collections

CHIAVI = ["n", "ere_intatto", "ere_piedi", "n_rudere", "n_rovina", "n_sepolto",
          "n_subito", "n_in_piedi_fine", "n_intatto_fine", "vetusta", "vp",
          "vp_rendita", "vp_lampo", "vp_verticalita", "vp_scavo", "vp_scheletri",
          "n_spianato", "n_sepolto_altrui"]     # assenti nei CSV vecchi: valgono 0

def leggi(f):
    righe = [l.rstrip("\n") for l in open(f) if l.strip()]
    meta = [l for l in righe if l.startswith("# partite=")][0]
    partite = int(meta.split("partite=")[1].split()[0])
    regole = dict(kv.split("=", 1) for kv in meta.split()[1:] if "=" in kv)
    i = righe.index([l for l in righe if l.startswith("id;")][0])
    hdr = righe[i].split(";")
    tot = collections.Counter()
    for l in righe[i + 1:]:
        v = dict(zip(hdr, l.split(";")))
        for k in CHIAVI: tot[k] += int(v.get(k, 0))
    n = tot["n"]
    # ATTENZIONE: `n_rudere` conta chi NON E' PIU' INTATTO (rudere o rovina),
    # non chi e' passato per lo stato rudere: senza rudere vale quanto n_rovina.
    return regole, partite, {
        "costruiti/partita": (n / partite, "{:.2f}"),
        "in piedi a fine": (tot["n_in_piedi_fine"] / partite, "{:.2f}"),
        "intatti a fine": (tot["n_intatto_fine"] / partite, "{:.2f}"),
        "cade nella sua era": (tot["n_subito"] / n, "{:.0%}"),
        "ere intatto": (tot["ere_intatto"] / n, "{:.2f}"),
        "ere in piedi": (tot["ere_piedi"] / n, "{:.2f}"),
        "caduti (non piu' intatti)": (tot["n_rudere"] / n, "{:.0%}"),
        "finiti in rovina": (tot["n_rovina"] / n, "{:.0%}"),
        "sepolti": (tot["n_sepolto"] / n, "{:.0%}"),
        "spianati dal proprietario": (tot["n_spianato"] / n, "{:.0%}"),
        "sepolti da un altro": (tot["n_sepolto_altrui"] / n, "{:.0%}"),
        "Scavo per sepolto": (tot["vp_scavo"] / max(1, tot["n_sepolto"]), "{:.2f}"),
        "cubetti Vetusta'/partita": (tot["vetusta"] / partite, "{:.1f}"),
        "PV delle carte/partita": (tot["vp"] / partite, "{:.1f}"),
        "  Rendita": (tot["vp_rendita"] / partite, "{:.1f}"),
        "  Lampo": (tot["vp_lampo"] / partite, "{:.1f}"),
        "  Verticalita'": (tot["vp_verticalita"] / partite, "{:.1f}"),
        "  Scavo": (tot["vp_scavo"] / partite, "{:.1f}"),
        "  Scheletri": (tot["vp_scheletri"] / partite, "{:.1f}"),
    }

NOMI_PREMIO = {"per_livello": "premio S×L", "piu_livello": "premio S+L", "per_livello_meno_uno": "premio S×(L−1)"}

def etichetta(regole):
    # A soglia 1 il rudere non esiste di fatto: fallire di 1 e' gia' rovina.
    if regole.get("rovina") == "1": pezzi = ["ogni fallimento fa rovina"]
    else:
        pezzi = ["senza rudere" if regole.get("rudere", "si") == "no" else "con il rudere"]
        if "rovina" in regole: pezzi.append(f"rovina a −{regole['rovina']}")
    if regole.get("spianato") == "vale": pezzi.append("Scavo mai azzerato")
    if regole.get("scavo") == "scavatore": pezzi.append("Scavo a chi scava")
    if regole.get("sconto") == "altrui": pezzi.append("sconto solo sulle altrui")
    if regole.get("disturbo", "0") != "0": pezzi.append(f"disturbo {regole['disturbo']}")
    if regole.get("verticalita") == "0/0/0/0": pezzi.append("senza Verticalità")
    if regole.get("premio", "nessuno") != "nessuno": pezzi.append(NOMI_PREMIO.get(regole["premio"], regole["premio"]))
    if regole.get("era5", "intero") != "intero": pezzi.append(f"era 5 {regole['era5']}")
    if regole.get("tetto", "0") != "0": pezzi.append(f"tetto {regole['tetto']} per risorsa")
    if regole.get("turno") == "v2": pezzi.append("turno a un'azione")
    if regole.get("lavoratori", "3") != "3": pezzi.append(f"{regole['lavoratori']} lavoratori")
    if regole.get("dati", "").startswith("v2"): pezzi.insert(0, "v2 tre risorse")
    return ", ".join(pezzi)

lotti = [leggi(f) for f in sys.argv[1:]]
if len(lotti) < 2:
    sys.exit("servono almeno due CSV --vita")
rif = lotti[0]
print("| misura | " + " | ".join(f"{etichetta(r)} ({p} partite)" for r, p, _ in lotti) + " |")
print("|---|" + "--:|" * len(lotti))
for k in rif[2]:
    celle = []
    for j, (_, _, m) in enumerate(lotti):
        val, fmt = m[k]
        cella = fmt.format(val)
        if j > 0:
            d = val - rif[2][k][0]
            fd = ("{:+.0%}" if "%" in fmt else "{:+.2f}" if ".2f" in fmt else "{:+.1f}").format(d)
            cella += f" ({fd})"
        celle.append(cella)
    print(f"| {k} | " + " | ".join(celle) + " |")
