#!/usr/bin/env python3
"""Estrae la grafica dai PDF di stampa in materiali/ per l'interfaccia (M5).

Produce tre cose, con gradi di affidabilità molto diversi.

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

3. POTENZIAMENTI (materiali/Potenziamenti.pdf) — mappatura VERIFICATA.
   Stanno in un PDF a parte perché hanno un formato tutto loro: 28x68 mm, la
   linguetta stretta e alta che si infila sotto la sagoma dell'edificio.
   Una pagina di facce e una di dorsi, 25 posizioni ciascuna, cinque per era
   in ordine di dati.
   Le 25 posizioni NON sono 25 carte diverse: la prima carta di ogni era è
   stampata due volte (le posizioni 2, 7, 12, 17 e 22 sono la copia byte per
   byte della posizione precedente) e al suo posto manca un potenziamento per
   era - Fondamenta in pietra, Iscrizione, Reliquia, Cannoniere, Memoriale.
   Le facce distinte sono quindi 20 su 25. È lo stesso difetto degli eventi
   dell'era 2, e va segnalato al designer, non aggirato.
   I dorsi sono 5 disegni distinti, uno per era, ognuno ripetuto cinque volte.
   Il testo stampato sulle 20 carte presenti coincide con data/cards.json,
   controllato voce per voce: qui, a differenza delle carte edificio, i numeri
   del PDF non sono obsoleti.

Uso:  python3 tools/estrai_grafica.py [cartella_destinazione]
      (default: assets/)
"""
import hashlib, json, os, sys

try:
    import pymupdf
except ImportError:
    sys.exit("serve PyMuPDF:  pip install pymupdf")

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
PDF = os.path.join(ROOT, "materiali", "Carte.pdf")
PDF_POTENZIAMENTI = os.path.join(ROOT, "materiali", "Potenziamenti.pdf")
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


def illustrazioni_di_pagina(doc, n_pagina, specchiata=False):
    """Le immagini incorporate della pagina, ordinate per riga e poi colonna.

    Le pagine in grigio sono il RETRO del foglio, quindi impaginate
    specchiate: i due lati devono combaciare alla fustellatura. Ordinandole
    per x crescente come le altre, le righe con più pezzi escono invertite, e
    il rudere di un edificio finisce accoppiato al disegno di un altro. Con
    `specchiata` la x si legge al contrario, e i due stati tornano allineati.
    """
    pg = doc[n_pagina - 1]
    trovate = []
    for x in pg.get_images(full=True):
        rects = pg.get_image_rects(x[0])
        if rects:
            trovate.append((rects[0], doc.extract_image(x[0])))
    verso = (lambda r: -r.x0) if specchiata else (lambda r: r.x0)
    trovate.sort(key=lambda t: (round(t[0].y0 / 20), verso(t[0])))
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


# IL BANNER DELLO SCAVO: una striscia di terra e macerie per valore, dallo 0
# in su, con il numero in fondo a destra.
#
# L'immagine del designer e' DISEGNATA, non impaginata: le strisce sono
# separate da righe bianche e sono alte una diversa dall'altra (fra 80 e 117
# pixel nell'originale a dieci valori). Prendendola a fette uguali il numero
# finirebbe mezzo tagliato, e a valori diversi in modo diverso.
#
# Qui si trovano i separatori, si ritaglia striscia per striscia e si
# ricompone un atlante con righe TUTTE UGUALI. Cosi' la vista prende la riga
# del valore N con una divisione e non sa niente di come era fatta l'immagine
# di partenza; e se il designer ne manda una nuova, le strisce si ritrovano
# da sole.
SCAVO_RIGHE_ATTESE = 10

def strisce_orizzontali(pix, soglia=235, quota=0.9, minimo=20):
    """Le fasce di contenuto fra le righe quasi bianche. Restituisce
    [(y0, y1), ...] dall'alto in basso."""
    larghezza, altezza, n = pix.width, pix.height, pix.n
    dati = pix.samples
    passo = max(1, larghezza // 400)          # non serve guardarli tutti
    bianca = []
    for y in range(altezza):
        chiari = campioni = 0
        base = y * pix.stride
        for x in range(0, larghezza, passo):
            i = base + x * n
            campioni += 1
            if dati[i] > soglia and dati[i + 1] > soglia and dati[i + 2] > soglia:
                chiari += 1
        bianca.append(chiari / campioni > quota)
    fasce, inizio = [], None
    for y in range(altezza):
        if not bianca[y] and inizio is None:
            inizio = y
        elif bianca[y] and inizio is not None:
            if y - inizio >= minimo:
                fasce.append((inizio, y))
            inizio = None
    if inizio is not None and altezza - inizio >= minimo:
        fasce.append((inizio, altezza))

    # Si stringe ancora un po' da sopra e da sotto: fra una striscia e l'altra
    # c'e' una sfumatura di due o tre pixel che non e' bianca abbastanza da
    # contare come separatore ma sul tavolo si vede eccome - una riga chiara
    # fra una basetta e quella sopra, che sembra un buco nella costruzione.
    def chiara(y, quanto=0.22):
        chiari = campioni = 0
        base = y * pix.stride
        for x in range(0, larghezza, passo):
            i = base + x * n
            campioni += 1
            if dati[i] > soglia and dati[i + 1] > soglia and dati[i + 2] > soglia:
                chiari += 1
        return chiari / campioni > quanto

    strette = []
    for y0, y1 in fasce:
        while y0 < y1 - minimo and chiara(y0):
            y0 += 1
        while y1 - 1 > y0 + minimo and chiara(y1 - 1):
            y1 -= 1
        # E comunque due pixel per parte: il confine fra la terra e il bianco
        # non e' netto, e quel che resta della sfumatura da ingrandito torna a
        # sembrare una riga di luce fra una basetta e l'altra.
        orlo = 2
        if y1 - y0 > 2 * orlo + minimo:
            y0, y1 = y0 + orlo, y1 - orlo
        strette.append((y0, y1))
    return strette


def normalizza_scavo(fonte, uscita):
    if not os.path.exists(fonte):
        print("banner dello Scavo: manca materiali/Scavo.png")
        return
    pix = pymupdf.Pixmap(fonte)
    fasce = strisce_orizzontali(pix)
    if not fasce:
        print(f"banner dello Scavo: {pix.width}x{pix.height} px, nessuna "
              "striscia riconosciuta - copiato tale e quale")
        with open(fonte, "rb") as a, open(uscita, "wb") as b:
            b.write(a.read())
        return
    # L'altezza della riga e' la MEDIANA delle strisce, non la massima: una
    # sola striscia un po' piu' alta delle altre - l'ultima, che si porta
    # dietro il margine del foglio - allargherebbe tutte le righe del 40% e
    # il disegno uscirebbe stirato in verticale. Con la mediana le strisce
    # tengono le proporzioni che hanno sul foglio, che sono poi quelle della
    # basetta da tre slot.
    altezze = sorted(y1 - y0 for y0, y1 in fasce)
    alta = altezze[len(altezze) // 2]
    doc = pymupdf.open()
    pagina = doc.new_page(width=pix.width, height=alta * len(fasce))
    for i, (y0, y1) in enumerate(fasce):
        # La fetta si ritaglia copiando le righe di pixel: il costruttore
        # che prende un rettangolo non c'e' in tutte le versioni di pymupdf.
        fetta = pymupdf.Pixmap(pix.colorspace, pix.width, y1 - y0,
                               pix.samples[y0 * pix.stride:y1 * pix.stride],
                               pix.alpha)
        # keep_proportion=False: la fetta deve RIEMPIRE la riga. Lasciandolo
        # vero, una striscia piu' alta delle altre veniva rimpicciolita e
        # centrata, e sul tavolo si vedeva un banner piu' corto degli altri.
        pagina.insert_image(
            pymupdf.Rect(0, i * alta, pix.width, (i + 1) * alta), pixmap=fetta,
            keep_proportion=False)
    pagina.get_pixmap(matrix=pymupdf.Identity).save(uscita)
    print(f"banner dello Scavo: {len(fasce)} strisce (valori 0-{len(fasce) - 1}) "
          f"da {pix.width}x{alta} px")
    if len(fasce) != SCAVO_RIGHE_ATTESE:
        print(f"  ATTENZIONE: la vista ne aspetta {SCAVO_RIGHE_ATTESE} "
              f"(BoardLayout3D.SCAVO_RIGHE): aggiorna la costante")


def estrai_sagome(doc, dest):
    """Sagome nei due stati, numerate in ordine di lettura. La corrispondenza
    col nome della carta non è derivabile: vedi il commento in testa."""
    out = {}
    for variante, pagine in (("colore", PAGINE_SAGOME_COLORE),
                             ("grigio", PAGINE_SAGOME_GRIGIO)):
        cartella = os.path.join(dest, "sagome", variante)
        os.makedirs(cartella, exist_ok=True)
        _svuota(cartella)
        n = 0
        for p in pagine:
            for _, info in illustrazioni_di_pagina(doc, p, variante == "grigio"):
                n += 1
                grezzo = os.path.join(cartella, f"_tmp.{info['ext']}")
                with open(grezzo, "wb") as f:
                    f.write(info["image"])
                nome = f"{n:02d}.png"
                senza_fondo(grezzo).save(os.path.join(cartella, nome))
                os.remove(grezzo)
                out.setdefault(variante, {})[n] = nome
        print(f"estratte {n} sagome ({variante})")
    _verifica_stati(doc)
    return out


# I due stati sono lo stesso pezzo di cartone visto dai due lati: alla stessa
# posizione devono avere la stessa sagoma, quindi la stessa misura. Se non
# combaciano l'ordinamento e' sbagliato e un rudere mostrerebbe il disegno di
# un altro edificio - un difetto silenzioso, che senza questo controllo si
# nota solo guardando la plancia.
def _verifica_stati(doc):
    def misure(pagine, specchiata):
        out = []
        for p in pagine:
            for rect, _ in illustrazioni_di_pagina(doc, p, specchiata):
                out.append((round(rect.width, 1), round(rect.height, 1)))
        return out

    col = misure(PAGINE_SAGOME_COLORE, False)
    gri = misure(PAGINE_SAGOME_GRIGIO, True)
    if len(col) != len(gri):
        print(f"  ATTENZIONE: {len(col)} sagome a colori e {len(gri)} in grigio")
    # Uno scarto di qualche decimo è il bordo del disegno; uno scarto grosso
    # vuol dire che le due posizioni sono pezzi diversi.
    scarti = []
    for i in range(min(len(col), len(gri))):
        d = max(abs(col[i][0] - gri[i][0]), abs(col[i][1] - gri[i][1]))
        if d > 0.5:
            scarti.append((i + 1, round(d * 25.4 / 72.0, 1)))
    grossi = [n for n, d in scarti if d > 5.0]
    if grossi:
        print(f"  ATTENZIONE: colore e grigio sono pezzi diversi alle posizioni {grossi}")
    if scarti:
        detta = ", ".join(f"{n} ({d} mm)" for n, d in scarti)
        print(f"  i due stati combaciano tranne uno scarto di bordo alla posizione {detta}")
    else:
        print(f"  i due stati combaciano in tutte le {len(col)} posizioni")


# Tutti i gruppi di materiale del PDF, con la pagina e quanti pezzi aspettarsi.
# Le pagine PARI sono il retro del foglio e vanno lette a specchio: vedi
# illustrazioni_di_pagina. Il conteggio atteso non è decorativo - è il
# controllo che accorge se il PDF cambia sotto i piedi.
GRUPPI = [
    ("edifici",          [19, 21, 23, 25, 27], False, 60),
    ("eventi",           [29, 31],             False, 24),
    ("personaggi",       [39, 41, 43],         False, 25),
    ("monumenti",        [37],                 False, 14),
    ("eredita",          [33, 35],             False, 16),
    ("tessere",          [47, 49, 51, 53],     False, 14),
]
# I dorsi: una sola immagine ripetuta, o poche (una per era).
GRUPPI_DORSI = [
    ("edifici",     [28],             True),
    ("eventi",      [30, 32],         True),
    ("personaggi",  [40, 42, 44],     True),
    ("monumenti",   [38],             True),
    ("eredita",     [34, 36],         True),
    ("dinastia",    [45, 46],         False),
]
# Il secondo PDF ha una pagina sola per parte, e non è impaginato a specchio.
GRUPPI_POTENZIAMENTI = [("potenziamenti", [1], False, 25)]
GRUPPI_DORSI_POTENZIAMENTI = [("potenziamenti", [2], False)]


# La cartella si svuota prima di riempirla. Senza, il giorno che la mappatura
# cambia - ed e' appena successo con le tessere, passate da numerate a per id -
# restano a terra i file vecchi: nessuno li aggiorna piu' e nessuno se ne
# accorge, finche' qualcosa non carica quelli invece dei nuovi.
def _svuota(cartella):
    if not os.path.isdir(cartella):
        return
    for f in os.listdir(cartella):
        if f.lower().endswith((".png", ".jpg", ".jpeg", ".webp")):
            os.remove(os.path.join(cartella, f))


def estrai_gruppo(doc, dest, nome, pagine, specchiata, attesi, ordine=None):
    """Estrae un gruppo. Col suo ordine salva per id, altrimenti numerato."""
    cartella = os.path.join(dest, "carte", nome)
    os.makedirs(cartella, exist_ok=True)
    _svuota(cartella)
    n, per_id, saltate = 0, 0, 0
    viste = {}          # impronta -> prima posizione in cui e' comparsa
    copie = {}          # posizione -> posizione di cui e' la copia identica
    for p in pagine:
        for _, info in illustrazioni_di_pagina(doc, p, specchiata):
            n += 1
            impronta = hashlib.sha256(info["image"]).hexdigest()
            if impronta in viste:
                copie[n] = viste[impronta]
            else:
                viste[impronta] = n
            etichetta = f"{n:02d}"
            if ordine and n <= len(ordine):
                if ordine[n - 1] is None:
                    saltate += 1          # porta il disegno di un'altra carta
                    continue
                etichetta = ordine[n - 1]
                per_id += 1
            grezzo = os.path.join(cartella, f"_tmp.{info['ext']}")
            with open(grezzo, "wb") as f:
                f.write(info["image"])
            senza_fondo(grezzo).save(os.path.join(cartella, f"{etichetta}.png"))
            os.remove(grezzo)
    stato = "OK" if n == attesi else f"ATTESI {attesi}"
    come = f", {per_id} per id" if per_id else ", numerate"
    salto = f", {saltate} saltate (disegno di un'altra carta)" if saltate else ""
    print(f"  {nome}: {n} pezzi ({stato}){come}{salto}")
    return n, per_id, copie


# Una posizione che porta la stampa di un'altra carta a volte si riconosce da
# sola: quando la copia e' byte per byte, l'impronta della seconda coincide con
# quella della prima. Quali siano sta scritto in data/carte_pdf.json sotto
# `_copie_byte`, e qui si controlla che il PDF dica ancora la stessa cosa.
#
# Serve a una cosa sola, ma importante: quando il designer ricarica un PDF
# corretto, la mappatura fatta a vista diventa vecchia in silenzio. Con questo
# controllo il PDF nuovo lo dice da solo, e non tocca rileggere le carte una
# per una per accorgersene.
#
# Le ristampe con l'ILLUSTRAZIONE RIGENERATA (i tre eventi dell'era 2) hanno
# impronte diverse e nessuna macchina le vede: restano dichiarate a mano.
def verifica_ristampe(nome, copie, atteso):
    trovate = sorted(copie)
    if atteso is None:
        if trovate:
            print(f"  {nome}: posizioni ripetute {trovate}, non censite in "
                  f"data/carte_pdf.json (`_copie_byte`)")
        return
    atteso = sorted(atteso)
    if trovate == atteso:
        return
    nuove = [n for n in trovate if n not in atteso]
    sparite = [n for n in atteso if n not in trovate]
    print(f"  ATTENZIONE {nome}: le ristampe non sono piu' quelle dichiarate.")
    if sparite:
        print(f"    non sono piu' copie: {sparite} -> il PDF e' cambiato, "
              f"la mappatura in data/carte_pdf.json va rifatta a vista")
    if nuove:
        print(f"    copie nuove: {', '.join(f'{n} = {copie[n]}' for n in nuove)}")


# I PDF sono la fonte grafica e cambiano sotto i piedi quando il designer ne
# ricarica uno. L'impronta e' l'unico modo per accorgersene senza riaprire le
# carte: se non combacia, tutto cio' che e' stato ricavato a vista va rivisto.
def verifica_pdf(ordini):
    attese = ordini.get("_impronte_pdf", {})
    for percorso in (PDF, PDF_POTENZIAMENTI):
        nome = os.path.basename(percorso)
        h = hashlib.sha256()
        with open(percorso, "rb") as f:
            for blocco in iter(lambda: f.read(1 << 20), b""):
                h.update(blocco)
        ora = h.hexdigest()[:16]
        prima = attese.get(nome)
        if prima is None:
            print(f"  {nome}: impronta {ora}, non ancora censita")
        elif prima != ora:
            print(f"  ATTENZIONE {nome}: impronta {ora}, era {prima}. "
                  f"Il PDF e' stato rifatto: la mappatura ricavata a vista "
                  f"(data/carte_pdf.json, data/sagome.json) va ricontrollata.")


def estrai_dorsi(doc, dest, nome, pagine, specchiata):
    """Di un dorso basta una copia per disegno distinto."""
    cartella = os.path.join(dest, "carte", "dorsi")
    os.makedirs(cartella, exist_ok=True)
    visti, scritti = set(), 0
    for p in pagine:
        for _, info in illustrazioni_di_pagina(doc, p, specchiata):
            h = hashlib.sha256(info["image"]).hexdigest()
            if h in visti:
                continue
            visti.add(h)
            scritti += 1
            grezzo = os.path.join(cartella, f"_tmp.{info['ext']}")
            with open(grezzo, "wb") as f:
                f.write(info["image"])
            senza_fondo(grezzo).save(
                os.path.join(cartella, f"{nome}_{scritti}.png"))
            os.remove(grezzo)
    return scritti


def main(dest):
    cards = json.load(open(os.path.join(ROOT, "data", "cards.json"), encoding="utf-8"))
    per_era = {}
    for b in cards["buildings"]:
        per_era.setdefault(b["era"], []).append(b)

    doc = pymupdf.open(PDF)

    # Gli edifici sono l'unico gruppo con la mappatura VERIFICATA: si salvano
    # direttamente col proprio id invece che numerati.
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
    print(f"estratte {scritti} facce di edificio, mappate per id")

    # Il lato ROVINA sta sul retro dello stesso foglio, quindi impaginato a
    # specchio. Letto al contrario torna nello stesso ordine delle facce:
    # verificato leggendo i nomi stampati sulle carte dell'era 1, dove le
    # dodici posizioni coincidono una a una. Si salvano percio' anch'esse
    # per id, non numerate.
    # L'era 5 non ha lato rovina, e non e' una dimenticanza: l'era Moderna non
    # ha evento, quindi un edificio dell'era 5 non diventa mai rudere e la sua
    # rovina resterebbe comunque sepolta sotto chi ci costruisce sopra. Quello
    # spazio porta infatti il dorso del mazzo.
    rov_dest = os.path.join(dest, "carte", "edifici_rovina")
    os.makedirs(rov_dest, exist_ok=True)
    rovine = 0
    for era, pagina in PAGINE_EDIFICI.items():
        if era >= 5:
            continue
        ordinati = ordine_pdf(per_era[era])
        imgs = illustrazioni_di_pagina(doc, pagina + 1, True)
        if len(imgs) != 12:
            sys.exit(f"pagina {pagina + 1}: attese 12 rovine, trovate {len(imgs)}")
        for b, (_, info) in zip(ordinati, imgs):
            with open(os.path.join(rov_dest, f"{b['id']}.{info['ext']}"), "wb") as f:
                f.write(info["image"])
            indice[b["id"]]["rovina"] = f"{b['id']}.{info['ext']}"
            rovine += 1
    print(f"estratti {rovine} lati rovina, mappati per id (l'era 5 non ne ha)")

    # Gli altri gruppi hanno la mappatura in data/carte_pdf.json, ricavata
    # leggendo i nomi stampati sulle carte. Dove c'è si salva per id; dove la
    # posizione porta il disegno di un'altra carta (`null`) si salta.
    ordini = {}
    percorso_ordini = os.path.join(ROOT, "data", "carte_pdf.json")
    if os.path.exists(percorso_ordini):
        ordini = json.load(open(percorso_ordini, encoding="utf-8"))

    # Le tessere colonna hanno la loro mappatura a parte, perche' non sono
    # carte di cards.json ma varianti nominate dei quattro terreni: l'ordine
    # si ricava da li' cosi' escono col proprio id invece che numerate.
    percorso_tessere = os.path.join(ROOT, "data", "tessere_pdf.json")
    if os.path.exists(percorso_tessere):
        tess = json.load(open(percorso_tessere, encoding="utf-8"))
        ordini["tessere"] = [t["id"] for t in tess["tessere"]]

    print("impronte dei PDF:")
    verifica_pdf(ordini)

    copie_attese = ordini.get("_copie_byte", {})
    print("altri gruppi:")
    conteggi = {"edifici": scritti}
    per_id = {"edifici": scritti}
    for nome, pagine, specchiata, attesi in GRUPPI:
        if nome == "edifici":
            continue
        conteggi[nome], per_id[nome], copie = estrai_gruppo(
            doc, dest, nome, pagine, specchiata, attesi, ordini.get(nome))
        verifica_ristampe(nome, copie, copie_attese.get(nome))
    for nome, pagine, specchiata in GRUPPI_DORSI:
        estrai_dorsi(doc, dest, nome, pagine, specchiata)

    # I potenziamenti stanno nel secondo PDF, con lo stesso trattamento.
    doc_pot = pymupdf.open(PDF_POTENZIAMENTI)
    print("potenziamenti (PDF a parte):")
    for nome, pagine, specchiata, attesi in GRUPPI_POTENZIAMENTI:
        conteggi[nome], per_id[nome], copie = estrai_gruppo(
            doc_pot, dest, nome, pagine, specchiata, attesi, ordini.get(nome))
        verifica_ristampe(nome, copie, copie_attese.get(nome))
    for nome, pagine, specchiata in GRUPPI_DORSI_POTENZIAMENTI:
        d = estrai_dorsi(doc_pot, dest, nome, pagine, specchiata)
        print(f"  dorsi: {d} disegni distinti (uno per era)")

    # Quello che nei PDF non c'è. Meglio dirlo a ogni estrazione che scoprirlo
    # quando serve. Si conta quante carte sono uscite COL PROPRIO ID: le
    # posizioni ci sono tutte, sono le carte a mancare.
    mancanti = []
    for chiave, etichetta in (("upgrades", "potenziamenti"), ("events", "eventi")):
        nei_dati = len(cards[chiave])
        estratte = per_id.get(etichetta, 0)
        if estratte < nei_dati:
            senza = ordini.get("_mancanti", {}).get(etichetta, [])
            nomi = ", ".join(senza) if senza else "non censite"
            mancanti.append(f"{etichetta}: {nei_dati - estratte} su {nei_dati} ({nomi})")
    if mancanti:
        print("NEI PDF NON CI SONO -> " + "; ".join(mancanti))

    # Lo sfondo del cielo e il banner dello Scavo stanno in materiali/ come
    # gli altri originali, ma quella cartella ha un .gdignore: Godot non ci
    # guarda dentro. Vanno quindi copiati fra gli asset, dove il resto della
    # grafica gia' vive. Non si ritagliano qui: il banner e' una striscia
    # sola con cinque righe, e a prendere la riga giusta ci pensa la vista
    # con le coordinate della texture - cosi' aggiungerne una domani vuol dire
    # cambiare l'immagine e basta.
    sfondo = os.path.join(ROOT, "materiali", "Sfondo.png")
    if os.path.exists(sfondo):
        os.makedirs(dest, exist_ok=True)
        with open(sfondo, "rb") as a, open(os.path.join(dest, "sfondo.png"), "wb") as b:
            b.write(a.read())
        pix = pymupdf.Pixmap(sfondo)
        print(f"sfondo del cielo: {pix.width}x{pix.height} px "
              f"(rapporto {pix.width / pix.height:.3f})")
    else:
        print("sfondo del cielo: manca materiali/Sfondo.png")

    normalizza_scavo(os.path.join(ROOT, "materiali", "Scavo.png"),
                     os.path.join(dest, "scavo.png"))

    # Il terrapieno ha un disegno suo: una sezione di terra senza macerie e
    # senza numero, perche' li' non c'e' niente da contare. Una striscia sola,
    # quindi si copia e basta.
    terra = os.path.join(ROOT, "materiali", "Terrapieno.png")
    if os.path.exists(terra):
        with open(terra, "rb") as a, open(os.path.join(dest, "terrapieno.png"), "wb") as b:
            b.write(a.read())
        pix = pymupdf.Pixmap(terra)
        print(f"terra del terrapieno: {pix.width}x{pix.height} px "
              f"(rapporto {pix.width / pix.height:.2f})")
    else:
        print("terra del terrapieno: manca materiali/Terrapieno.png")

    sag = estrai_sagome(doc, dest)
    with open(os.path.join(dest, "indice.json"), "w", encoding="utf-8") as f:
        json.dump({"carte_edifici": indice,
                   "sagome": sag,
                   "conteggi": conteggi,
                   "per_id": per_id,
                   "nota_sagome": "numerazione in ordine di lettura; la "
                                  "corrispondenza con gli id sta in "
                                  "data/sagome.json"},
                  f, ensure_ascii=False, indent=2)
    print("indice.json scritto")


if __name__ == "__main__":
    main(sys.argv[1] if len(sys.argv) > 1 else os.path.join(ROOT, "assets"))
