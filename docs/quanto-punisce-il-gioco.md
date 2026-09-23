# Quanto punisce il gioco

> Misure fatte col motore vero (`scripts/tools/audit_partita.gd --vita`), 2 000 partite
> a tre giocatori per variante, **stessi semi** (base 200 000) e stessi bot a strategie.
> Le manopole si girano da riga di comando e **non toccano `data/cards.json`**, che resta
> la fonte unica: `--rudere N`, `--gap N`, `--forza -1`.

## La domanda

A fine partita in tavola restano in piedi **7,3 edifici su 28,7 costruiti**: il 25%.
La città che si guarda alla fine è fatta quasi tutta di rovine, e il designer ha chiesto
se le soglie che mandano in rovina non siano troppo severe.

## Le tre manopole

| manopola | cos'è oggi | cosa fa |
|---|---|---|
| `rudere_penalty` | 2 | quanta resistenza perde un edificio già rudere |
| `rovina_gap` | 2 | di quanto si può fallire l'evento restando in piedi: fallire di 1 fa rudere, di 2+ fa rovina |
| forza degli eventi | 2/3/4/5 per era | il numero che la resistenza deve pareggiare |

La seconda era scritta dentro il codice (`gap == 1`) e adesso sta nei dati come le altre:
una regola di bilanciamento che non si può leggere né provare senza ricompilare non è
una manopola.

## Cosa cambia, misurato

| variante | costruiti | **in piedi a fine** | intatti a fine | in piedi | ere in piedi | rovine | sepolti | PV/partita |
|---|--:|--:|--:|--:|--:|--:|--:|--:|
| **attuale** | 28,69 | **7,30** | 7,10 | 25% | 1,79 | 75% | 57% | 198 |
| rudere −1 | 28,73 | 7,37 | 7,15 | 26% | 1,79 | 74% | 57% | 198 |
| rovina solo a −3 | 28,79 | 8,32 | 7,69 | 29% | 1,96 | 71% | 57% | 200 |
| eventi −1 | 29,68 | 9,32 | 8,89 | 31% | 1,98 | 69% | 57% | 207 |
| rudere −1 + rovina −3 | 28,74 | 8,44 | 7,78 | 29% | 1,97 | 71% | 57% | 199 |
| **tutte e tre** | 29,61 | **10,33** | 9,29 | 35% | 2,10 | 65% | 57% | 206 |

## Cosa dicono i numeri

**Il `rudere_penalty` non è il colpevole.** Toglierne uno cambia 7,30 in 7,37 edifici in
piedi: sette centesimi di edificio a partita. Il rudere non muore perché è debole, muore
perché l'evento dell'era dopo è più forte di quanto lui possa reggere comunque.

**La soglia della rovina vale un edificio.** Lasciando in piedi chi fallisce di 2 —
rudere invece che rovina — si passa a 8,3 in piedi e la vita media sale da 1,79 a 1,96
ere. È la manopola con il rapporto migliore fra quanto si tocca e quanto si ottiene: una
riga di dati, nessuna carta da ristampare.

**La forza degli eventi vale due edifici.** Scontando di 1 la forza di ogni evento si
arriva a 9,3 in piedi e i ruderi scendono dal 78% al 72%: è la manopola più forte, ma è
anche quella che tocca la carta stampata, e alza i punti (198 → 207) perché più edifici
vivi vuol dire più rendite e più censimenti.

**Insieme fanno 10,3 su 29,6: un terzo della città resta in piedi**, contro un quarto di
adesso, e la vita media passa da 1,79 a 2,10 ere.

## Il tetto vero non è la rovina: è la sepoltura

In tutte e sei le varianti la quota di **sepolti resta 57%**, immobile. Gli eventi
decidono chi crolla, ma non chi sparisce sotto la città: quello lo decide chi costruisce
sopra, ed è una scelta dei giocatori, non un tiro. Anche regalando la sopravvivenza a
tutti, più di metà degli edifici finirebbe comunque sotto uno strato.

Detto altrimenti: **la città non è fatta di macerie, è fatta di fondamenta.** Se si vuole
vedere più città in piedi alla fine, la manopola grossa non è la severità dell'evento ma
quanto conviene costruire in alto — la tabella della Verticalità (`docs/quanto-paga-salire.md`).

## Cosa consiglio

`rovina_gap` a **3** è il cambiamento che rende visibile il risultato senza spostare
l'equilibrio: +1 edificio in piedi a fine partita, +2 punti a partita su 198 (l'1%),
e nessuna carta da ristampare. Se si vuole la città davvero piena, la forza degli eventi
scontata di 1 porta a 9,3 — ma quella è una modifica al materiale stampato, e va decisa
prima della stampa, non dopo.
