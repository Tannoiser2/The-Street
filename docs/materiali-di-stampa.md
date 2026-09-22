# Materiali di stampa: cosa c'è nel PDF e cosa manca

I PDF in `materiali/` sono la fonte **grafica**, mai quella dei dati (`Carte.pdf`
è a una calibrazione precedente alla v1.5: vedi `docs/domande-aperte.md` punto
20). Sono due:

- `materiali/Carte.pdf` — 54 pagine — tutto il resto del gioco;
- `materiali/Potenziamenti.pdf` — 2 pagine — i soli potenziamenti, che hanno un
  formato a parte: 28×68 mm, la linguetta stretta e alta che si infila sotto la
  sagoma dell'edificio.

Qui c'è la mappa di cosa contengono, ricavata misurando la geometria e
**leggendo i nomi stampati sulle carte**, una per una.

`tools/estrai_grafica.py` estrae tutto e lo salva per id dove la mappatura è
nota. Le posizioni e gli id stanno in `data/carte_pdf.json` e
`data/sagome.json`.

## Cosa c'è

| gruppo | pagine | pezzi | mappatura |
|---|---|---|---|
| sagome a colori | 1, 3, …, 17 | 60 | `data/sagome.json` |
| sagome in grigio | 2, 4, …, 18 | 60 | stessa, per posizione |
| edifici, faccia intatta | 19, 21, 23, 25, 27 | 60 | verificata, ordine JSON con la 5ª spostata in 7ª |
| edifici, lato rovina | 20, 22, 24, 26 | 48 | stessa delle facce, verificata su due ere |
| eventi | 29, 31 | 24 | `data/carte_pdf.json`, ordine JSON |
| personaggi | 39, 41, 43 | 25 | idem, ordine JSON tranne le posizioni 4-6 |
| monumenti | 37 | 14 | idem, ordine proprio |
| eredità | 33, 35 | 16 | idem, ordine proprio |
| Dinastia | 45, 46 | 1 (×4 copie) | — |
| tessere colonna | 47, 49, 51, 53 | 11 tessere + 1 ristampa + 2 segnalini | `data/tessere_pdf.json`, lette a vista |
| dorsi | 28, 30, 32, 34, 36, 38, 40, 42, 44 | uno per mazzo o per era | — |
| potenziamenti | `Potenziamenti.pdf` 1 | 25 posizioni, 20 carte | `data/carte_pdf.json`, ordine JSON, cinque per era |
| dorsi dei potenziamenti | `Potenziamenti.pdf` 2 | 5 (uno per era) | — |

## Cosa manca

### ~~Cinque potenziamenti non ci sono~~ — risolto il 22 settembre

`Potenziamenti.pdf` è stato rifatto: **25 posizioni, 25 carte distinte**, nell'ordine
esatto di `data/cards.json`. Le cinque ristampe sono sparite e le cinque carte che
mancavano — *Fondamenta in pietra, Iscrizione, Reliquia, Cannoniere, Memoriale* — ci
sono. Il testo coincide con i dati carta per carta; due voci sono riscritte meglio e
dicono la stessa cosa (*Reliquia*: «Arte +2 PV su edificio Religione, altrimenti +1»;
*Cannoniere*: «Struttura +1 res., +2 su edificio Militare»).

Quello che segue è il difetto com'era, tenuto perché è lo stesso schema che gli eventi
hanno ancora.

#### Com'era: cinque potenziamenti mancanti, uno per era

`Potenziamenti.pdf` ha 25 posizioni per 25 carte, ma non sono 25 carte diverse:
in ogni era la **prima carta è stampata due volte** e un potenziamento manca.

| era | posizione ripetuta | manca |
|---|---|---|
| 1 | 2 (copia di 1, *Pittura rupestre*) | **Fondamenta in pietra** |
| 2 | 7 (copia di 6, *Statua*) | **Iscrizione** |
| 3 | 12 (copia di 11, *Contrafforte*) | **Reliquia** |
| 4 | 17 (copia di 16, *Opera d'arte*) | **Cannoniere** |
| 5 | 22 (copia di 21, *Installazione*) | **Memoriale** |

Le ripetizioni qui sono copie **byte per byte**, non illustrazioni rigenerate
come nel caso degli eventi qui sotto: è la stessa immagine incorporata due
volte. Le facce distinte sono quindi **20 su 25**. Nessuna carta stampata è
estranea ai dati.

Il testo delle 20 presenti **coincide con `data/cards.json`**, controllato voce
per voce: qui, a differenza delle carte edificio, i numeri del PDF non sono
obsoleti.

### Tre eventi dell'era 2 non ci sono

Le posizioni 10, 11 e 12 dovrebbero portare i tre eventi *gravi* dell'era 2 e
portano invece una **seconda stampa** di tre carte dell'era 3:

| posizione | dovrebbe essere | porta invece |
|---|---|---|
| 10 | **Eruzione** | Grande incendio (era 3) |
| 11 | **Persecuzioni** | Scisma (era 3) |
| 12 | **Guerra civile** | Anni della fame (era 3) |

Non sono copie byte per byte: stessa carta, stesso testo, stessa forza, con
l'illustrazione **rigenerata**. Da qui la differenza con le sagome, dove i
duplicati sono identici al byte.

### Una tessera fiume in meno, e una collina di troppo

Le tessere colonna sono **11 disegni distinti su 12 posizioni**: la **7** è una
seconda stampa di *Collina delle Cave*, copia byte per byte della **6**. (La
**11** invece è la seconda copia del segnalino pietra/oro, che non è una
tessera: quella è voluta.)

Il mix a quattro giocatori chiede pianura 3, fiume 3, collina 2, bosco 1.
Stampate: pianura 4, collina 2, **fiume 2**, bosco 3. Manca **un fiume**, ed è
esattamente la posizione che il duplicato spreca — lo stesso difetto dei
potenziamenti e degli eventi. Vedi `docs/domande-aperte.md` punto 73.

### ~~Due sagome portano il disegno di un'altra~~ — risolto il 22 settembre

Erano tre difetti e sono stati corretti tutti: **Ospedale dei pellegrini** e
**Mercato** hanno ora un disegno proprio invece di ripetere quello di un altro, e la
sagoma del **Ponte** raffigura un ponte e non più un foro romano.

Sono **60 disegni distinti per 60 edifici**, e le larghezze sul cartone — 41 da 1
slot, 16 da 2, 3 da 3 — combaciano una per una con `width` in `data/cards.json`.

Il PDF nuovo ha cambiato **sei posizioni e solo quelle**: 23, 24, 33, 34, 35, 36.
Tutto il resto di `Carte.pdf` è identico al byte, confrontato posizione per posizione
con la copia precedente.

## Due cose che sembrano mancanze e non lo sono

**L'era 5 non ha il lato rovina** (pagina 28 porta il dorso del mazzo). Non è
una dimenticanza: l'era Moderna non ha evento, quindi un edificio dell'era 5
non diventa **mai** rudere — misurato, 0 casi su 113 edifici in 40 partite — e
l'unico modo in cui può finire in rovina è essere spianato da chi ci costruisce
sopra, cioè restando sepolto e invisibile. Quel lato non servirebbe a nessuno.

**Le pagine pari sono specchiate.** Sono il retro del foglio e devono combaciare
alla fustellatura. L'estrattore le legge al contrario; senza, otto sagome su
sessanta finivano accoppiate al rudere di un altro edificio.

## Il controllo che accorge quando un PDF cambia

La mappatura di questi materiali è ricavata **a vista**, e una mappatura a
vista invecchia in silenzio: basta che un PDF venga rifatto perché le posizioni
si spostino senza che niente lo dica. `tools/estrai_grafica.py` fa quindi due
controlli a ogni estrazione.

**L'impronta dei PDF** (`_impronte_pdf`): se non combacia, il file è cambiato e
tutto ciò che era stato letto a occhio va ricontrollato.

**Le ristampe riconoscibili a macchina** (`_copie_byte`): dove una posizione
porta la copia *byte per byte* di un'altra, l'impronta la tradisce. Se
un'attesa sparisce — cioè una posizione che prima era una copia ora è una carta
sua — il PDF è stato corretto e il tool lo dice.

Restano fuori le ristampe con l'**illustrazione rigenerata**, come i tre eventi
dell'era 2: hanno impronte diverse e nessuna macchina le distingue da una carta
vera. Quelle sono dichiarate a mano fra i `null`.

## Le tessere colonna: undici varianti di quattro terreni

Ogni tessera stampata è una **variante nominata** di uno dei quattro terreni
del modello — *Pianura dei Cantieri*, *Collina del Castello*, *Fiume Porto*,
*Bosco Sacro*… La produzione coincide sempre col terreno; la regola quasi mai.
La mappatura tessera → terreno, con la regola stampata trascritta, sta in
`data/tessere_pdf.json`; la domanda che ne nasce è al punto 72 delle domande
aperte.

La plancia le usa come **grafica del terreno**: a ogni colonna tocca la k-esima
tessera del suo terreno, dove k conta quante colonne dello stesso terreno
vengono prima. Deterministico, quindi due pianure vicine non portano lo stesso
disegno — e quando le tessere di un terreno finiscono si ricomincia da capo,
che è come il difetto del punto 73 si vede a schermo.
