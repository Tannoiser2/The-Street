#!/usr/bin/env python3
"""Estrae la grafica da materiali/Carte.pdf per l'interfaccia (M5).

Produce due cose, con due gradi di affidabilità molto diversi.

1. FACCE DELLE CARTE (pagine 19, 21, 23, 25, 27) — mappatura VERIFICATA.
   Ogni pagina porta 12 immagini incorporate, una per carta, 334x363 px: non
   sono illustrazioni isolate ma la carta intera, testo e numeri compresi.
   L'ordine di impaginazione non è quello di cards.json ma segue una regola
   esatta: è l'ordine del JSON con la quinta carta spostata in settima
   posizione. Verificata su tutte e cinque le ere, 60 corrispondenze su 60.

   ATTENZIONE: queste immagini portano numeri OBSOLETI. Il PDF è a una
   calibrazione precedente alla v1.5 — su 44 edifici su 60 lo Scavo stampato
   differisce da data/cards.json, e due carte dell'era 1 stampano la larghezza
   sbagliata (docs/domande-aperte.md punto 20). Il designer ha confermato che
   la fonte giusta sono i dati e che ricorreggerà le carte.
   Vanno quindi usate come riferimento, NON come faccia della carta in gioco:
   quella va disegnata a runtime dai dati.

2. SAGOME (pagine 1-17 dispari a colori, 2-18 pari in grigio) — mappatura
   RICAVATA A VISTA, in data/sagome.json. Sono 60 + 60, arte pulita senza testo né numeri, nei due stati:
   il grigio è il lato inattivo del rudere. Sono l'asset giusto per il
   tabellone.
   Il loro ordine però non segue né le ere né l'ordine delle carte: sono
   impaccate per forma, per risparmiare cartoncino (il Teatro dell'era 2 sta in
   dodicesima posizione, in mezzo all'era 1). Un accoppiamento automatico per
   somiglianza con l'arte delle carte è stato provato e ha fallito: 10
   biiezioni su 60, margini sotto lo 0,02. Le sagome sono fustellate con sfondo
   vuoto e proporzioni diverse dalla banda d'arte della carta.
   Vengono estratte con numerazione stabile in ordine di lettura; la
   corrispondenza numero -> id sta in data/sagome.json, ricavata riconoscendo
   le illustrazioni una per una e chiudendo il resto per esclusione sulla
   larghezza (vedi docs/mappatura-sagome.md).
   Escono come PNG con TRASPARENZA: il fondo bianco viene tolto con un
   riempimento dai bordi, non per colore, altrimenti si bucherebbero le nuvole
   bianche dentro il disegno.

Uso:  python3 tools/estrai_grafica.py [cartella_destinazione]
      (default: assets/)
"""
import json, os, sys

try:
    import pymupdf
except ImportError:
    sys.exit("serve PyMuPDF:  pip install pymupdf")

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
PDF = os.path.join(ROOT, "materiali", "Carte.pdf")
PAGINE_EDIFICI = {1: 19, 2: 21, 3: 23, 4: 25, 5: 27}
PAGINE_SAGOME_COLORE = list(range(1, 19, 2))
PAGINE_SAGOME_GRIGIO = list(range(2, 19, 2))


def ordine_pdf(ids):
    """L'ordine del JSON con la quinta carta spostata in settima posizione.
    JSON [1,2,3,4,5,6,7,...] -> PDF [1,2,3,4,6,7,5,8,...]"""
    if len(ids) < 7:
        return list(ids)
    r = list(ids)
    quinta = r.pop(4)
    r.insert(6, quinta)
    return r


def illustrazioni_di_pagina(doc, n_pagina):
    """Le immagini incorporate della pagina, ordinate per riga e poi colonna."""
    pg = doc[n_pagina - 1]
    trovate = []
    for x in pg.get_images(full=True):
        rects = pg.get_image_rects(x[0])
        if rects:
            trovate.append((rects[0], doc.extract_image(x[0])))
    trovate.sort(key=lambda t: (round(t[0].y0 / 20), t[0].x0))
    return trovate


# Il fondo delle sagome è bianco pieno, ma bianco c'è anche dentro il disegno
# (nuvole, pietra chiara). Togliere "tutto il bianco" bucherebbe il cielo:
# si parte quindi dai BORDI e si propaga solo attraverso pixel contigui, così
# si rimuove il fondo e nient'altro.
def senza_fondo(percorso, soglia=232):
    from collections import deque
    pix = pymupdf.Pixmap(percorso)
    if pix.n > 3:
        pix = pymupdf.Pixmap(pymupdf.csRGB, pix)
    w, h, s, n = pix.width, pix.height, pix.samples, pix.n
    fondo = bytearray(w * h)
    coda = deque()

    def chiaro(i):
        b = i * n
        return s[b] >= soglia and s[b + 1] >= soglia and s[b + 2] >= soglia

    bordo = [y * w + x for x in range(w) for y in (0, h - 1)]
    bordo += [y * w + x for y in range(h) for x in (0, w - 1)]
    for i in bordo:
        if not fondo[i] and chiaro(i):
            fondo[i] = 1
            coda.append(i)
    while coda:
        i = coda.popleft()
        x, y = i % w, i // w
        for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
            nx, ny = x + dx, y + dy
            if nx < 0 or ny < 0 or nx >= w or ny >= h:
                continue
            j = ny * w + nx
            if fondo[j] or not chiaro(j):
                continue
            fondo[j] = 1
            coda.append(j)
    rgba = bytearray(w * h * 4)
    for i in range(w * h):
        b = i * n
        rgba[i * 4] = s[b]
        rgba[i * 4 + 1] = s[b + 1]
        rgba[i * 4 + 2] = s[b + 2]
        rgba[i * 4 + 3] = 0 if fondo[i] else 255
    return pymupdf.Pixmap(pymupdf.csRGB, w, h, bytes(rgba), True)


def estrai_sagome(doc, dest):
    """Sagome nei due stati, numerate in ordine di lettura. La corrispondenza
    col nome della carta non è derivabile: vedi il commento in testa."""
    out = {}
    for variante, pagine in (("colore", PAGINE_SAGOME_COLORE),
                             ("grigio", PAGINE_SAGOME_GRIGIO)):
        cartella = os.path.join(dest, "sagome", variante)
        os.makedirs(cartella, exist_ok=True)
        n = 0
        for p in pagine:
            for _, info in illustrazioni_di_pagina(doc, p):
                n += 1
                grezzo = os.path.join(cartella, f"_tmp.{info['ext']}")
                with open(grezzo, "wb") as f:
                    f.write(info["image"])
                nome = f"{n:02d}.png"
                senza_fondo(grezzo).save(os.path.join(cartella, nome))
                os.remove(grezzo)
                out.setdefault(variante, {})[n] = nome
        print(f"estratte {n} sagome ({variante})")
    return out


def main(dest):
    cards = json.load(open(os.path.join(ROOT, "data", "cards.json"), encoding="utf-8"))
    per_era = {}
    for b in cards["buildings"]:
        per_era.setdefault(b["era"], []).append(b)

    doc = pymupdf.open(PDF)
    carte_dest = os.path.join(dest, "carte", "edifici")
    os.makedirs(carte_dest, exist_ok=True)
    scritti, indice = 0, {}
    for era, pagina in PAGINE_EDIFICI.items():
        edifici = per_era[era]
        if len(edifici) != 12:
            sys.exit(f"era {era}: attese 12 carte, trovate {len(edifici)}")
        ordinati = ordine_pdf(edifici)
        imgs = illustrazioni_di_pagina(doc, pagina)
        if len(imgs) != 12:
            sys.exit(f"pagina {pagina}: attese 12 illustrazioni, trovate {len(imgs)}")
        for b, (_, info) in zip(ordinati, imgs):
            nome = f"{b['id']}.{info['ext']}"
            with open(os.path.join(carte_dest, nome), "wb") as f:
                f.write(info["image"])
            indice[b["id"]] = {"file": nome, "nome": b["name"], "era": era,
                               "px": [info["width"], info["height"]]}
            scritti += 1

    sag = estrai_sagome(doc, dest)
    with open(os.path.join(dest, "indice.json"), "w", encoding="utf-8") as f:
        json.dump({"carte_edifici": indice,
                   "sagome": sag,
                   "nota_sagome": "numerazione in ordine di lettura; la "
                                  "corrispondenza con gli id non e' derivata"},
                  f, ensure_ascii=False, indent=2)
    print(f"estratte {scritti} facce di carta in {os.path.relpath(carte_dest, ROOT)}")
    print("indice.json: carte mappate per id (verificato), sagome solo numerate")


if __name__ == "__main__":
    main(sys.argv[1] if len(sys.argv) > 1 else os.path.join(ROOT, "assets"))
