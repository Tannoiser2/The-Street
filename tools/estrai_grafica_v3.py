#!/usr/bin/env python3
"""Ritaglia le carte della v3 dai PDF rifatti dal designer con Codex.

I PDF stanno in DA_PASSARE_A_CLAUDE_GODOT/PDF_COMPONENTI/: pagine dispari i
fronti, pari i retri. Servono SOLO per la grafica (regola del repo: i numeri
e i testi si leggono dai dati, mai dai PDF). Le carte non sono immagini
incorporate ma composte da piu' pezzi, quindi non si estraggono: si
renderizza la pagina e si taglia il riquadro di ogni carta.

COME SI TROVA UNA CARTA. Ogni carta ha un rettangolo vettoriale che la
contorna (194 x 116 pt l'edificio da una casella, 115 x 194 il Personaggio,
e cosi' via): si prendono i rettangoli abbastanza grandi, si tengono i piu'
esterni, e dentro ognuno si cerca il nome stampato, confrontandolo coi nomi
dei dati. Il nome dice l'id; la grafica finisce in
assets/carte/v3/<gruppo>/<id>.png (fronte) e <id>_retro.png (retro). Nessun
numero viene letto: si guarda solo il nome per sapere quale carta e'.

  python3 tools/estrai_grafica_v3.py            # tutto
  python3 tools/estrai_grafica_v3.py edifici    # un gruppo
"""
import json, os, re, sys, unicodedata
import pymupdf

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
PDF_DIR = os.path.join(ROOT, "DA_PASSARE_A_CLAUDE_GODOT", "PDF_COMPONENTI")
DEST = os.path.join(ROOT, "assets", "carte", "v3")
DATI = os.path.join(ROOT, "data", "proposte", "cards-v3-era1.json")
DPI = 200

# gruppo -> (pdf, sezioni dei dati i cui nomi cercare, ha il retro)
GRUPPI = {
    "edifici": ("Edifici_v3_Fronte_Retro_A4.pdf", ["buildings"], True),
    "personaggi": ("Personaggi_v3_Fronte_Retro_A4.pdf", ["characters"], True),
    "potenziamenti": ("Potenziamenti_v3_Fronte_Retro_A4.pdf", ["upgrades"], True),
    "eventi": ("Eventi_v3_Fronte_Retro_A4.pdf", ["events"], True),
    "obiettivi": ("Obiettivi_Milestones_v3_Fronte_Retro_A4.pdf", ["monuments", "legacies"], True),
    "tessere_era": ("Tessere_Era_v3_Fronte_Retro_A4.pdf", ["tessere_era"], True),
    "tessere_scavo": ("Tessere_Scavo_80_Fronte_Retro_A4.pdf", ["characters"], True),
}


def norm(t):
    t = unicodedata.normalize("NFKD", t).encode("ascii", "ignore").decode()
    return re.sub(r"[^a-z0-9]+", " ", t.lower()).strip()


def nomi(dati, sezioni):
    out = {}
    for s in sezioni:
        for c in dati[s]:
            if c.get("is_dynasty"): continue
            out[norm(c["name"])] = c["id"]
    return out


def riquadri(pg):
    """I rettangoli delle carte: grandi, non la pagina intera, i piu' esterni."""
    pag = pg.rect
    rs = []
    for d in pg.get_drawings():
        r = d["rect"]
        if r.width < 60 or r.height < 60: continue
        if r.width > pag.width * 0.9 and r.height > pag.height * 0.9: continue
        rs.append(r)
    rs.sort(key=lambda r: -r.width * r.height)
    tenuti = []
    for r in rs:
        if any(t.contains(r) or (abs(t.x0 - r.x0) < 4 and abs(t.y0 - r.y0) < 4 and abs(t.x1 - r.x1) < 4 and abs(t.y1 - r.y1) < 4) for t in tenuti):
            continue
        tenuti.append(r)
    return tenuti


def nome_in(pg, r, conosciuti):
    """Il nome dei dati stampato dentro il riquadro: il piu' lungo che compare."""
    testo = " " + norm(pg.get_textbox(r)) + " "
    meglio = None
    for n in conosciuti:
        if " " + n + " " in testo and (meglio is None or len(n) > len(meglio)):
            meglio = n
    return meglio


def estrai(gruppo, dati):
    pdf, sezioni, ha_retro = GRUPPI[gruppo]
    doc = pymupdf.open(os.path.join(PDF_DIR, pdf))
    conosciuti = nomi(dati, sezioni)
    dest = os.path.join(DEST, gruppo)
    os.makedirs(dest, exist_ok=True)
    trovati, retri, senza_nome = {}, {}, 0
    fronte_prima = []          # (riquadro, id) della pagina di fronte appena vista
    for i, pg in enumerate(doc):
        retro = ha_retro and i % 2 == 1
        W = pg.rect.width
        posti = []
        for r in riquadri(pg):
            n = nome_in(pg, r, conosciuti)
            cid = conosciuti[n] if n is not None else None
            # IL RETRO SENZA NOME (edifici, eventi: un dorso per era) si
            # riconosce dalla posizione: il retro sta dove sta il fronte nella
            # pagina prima, specchiato in orizzontale, come in tipografia.
            if cid is None and retro:
                for fr, fid in fronte_prima:
                    if abs((W - fr.x1) - r.x0) < 6 and abs(fr.y0 - r.y0) < 6 and abs(fr.width - r.width) < 6:
                        cid = fid
                        break
            if cid is None:
                senza_nome += 1
                # La tessera scavo ha il fronte "ROVINA" uguale per tutte (il
                # nome sta sul retro): se ne tiene uno solo.
                if gruppo == "tessere_scavo" and not retro and not os.path.exists(os.path.join(dest, "fronte.png")):
                    pg.get_pixmap(clip=r, dpi=DPI).save(os.path.join(dest, "fronte.png"))
                continue
            if not retro: posti.append((r, cid))
            tabella = retri if retro else trovati
            if cid in tabella: continue          # copie: basta la prima
            nome_file = cid + ("_retro" if retro else "") + ".png"
            pix = pg.get_pixmap(clip=r, dpi=DPI)
            pix.save(os.path.join(dest, nome_file))
            tabella[cid] = (i + 1, [round(x) for x in r])
        if not retro:
            # anche le copie servono a riconoscere il retro dalla posizione
            fronte_prima = posti
    attesi = set(conosciuti.values())
    # Della tessera scavo conta il retro, uno per Personaggio.
    mancano = sorted(attesi - set(retri if gruppo == "tessere_scavo" else trovati))
    print("%-14s fronti %3d/%3d  retri %3d  riquadri senza nome %d%s" % (
        gruppo, len(trovati), len(attesi), len(retri), senza_nome,
        ("  MANCANO: " + ", ".join(mancano[:12])) if mancano else ""))
    return trovati, retri


def main():
    dati = json.load(open(DATI, encoding="utf-8"))
    quali = sys.argv[1:] or list(GRUPPI)
    for g in quali:
        estrai(g, dati)


if __name__ == "__main__":
    main()
