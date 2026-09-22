# Materiali di stampa: cosa c'è nel PDF e cosa manca

`materiali/Carte.pdf` — 54 pagine — è la fonte **grafica**, mai quella dei dati
(il PDF è a una calibrazione precedente alla v1.5: vedi `docs/domande-aperte.md`
punto 20). Qui c'è la mappa di cosa contiene, ricavata misurando la geometria e
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
| tessere colonna | 47, 49, 51, 53 | 14 | numerate |
| dorsi | 28, 30, 32, 34, 36, 38, 40, 42, 44 | uno per mazzo o per era | — |

## Cosa manca

### I 25 potenziamenti non ci sono

Nel PDF **non c'è nessuna carta potenziamento**. Sono 25 nei dati, zero fra i
materiali. L'estrattore lo dice a ogni esecuzione.

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

### Due sagome portano il disegno di un'altra

Vedi `docs/mappatura-sagome.md`: mancano i disegni di **Ospedale dei
pellegrini** e **Mercato**, e la sagoma del **Ponte** raffigura un foro romano.

## Due cose che sembrano mancanze e non lo sono

**L'era 5 non ha il lato rovina** (pagina 28 porta il dorso del mazzo). Non è
una dimenticanza: l'era Moderna non ha evento, quindi un edificio dell'era 5
non diventa **mai** rudere — misurato, 0 casi su 113 edifici in 40 partite — e
l'unico modo in cui può finire in rovina è essere spianato da chi ci costruisce
sopra, cioè restando sepolto e invisibile. Quel lato non servirebbe a nessuno.

**Le pagine pari sono specchiate.** Sono il retro del foglio e devono combaciare
alla fustellatura. L'estrattore le legge al contrario; senza, otto sagome su
sessanta finivano accoppiate al rudere di un altro edificio.
