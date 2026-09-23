# Quanto paga salire

> **Esito: la tabella adottata è 2 / 5 / 9 / 14**, quella intermedia. `data/cards.json`
> porta questa; le misure qui sotto sono il confronto che ha portato alla scelta, e la
> colonna "2/6/12/20" è la tabella di prima.

La Verticalità si prende un terzo abbondante dei punti e **metà del distacco fra il primo
e l'ultimo**. La domanda che viene da sé è se la tabella sia troppo ripida: il premio della
colonna passa da 2 a 20 fra l'altezza 1 e la 4, e la metà se la prende chi sta in cima.

Quindi l'ho misurato. Quattro tabelle, **1000 partite ciascuna, con gli stessi semi**: le
carte escono nello stesso ordine, i bot sono gli stessi, l'unica cosa che cambia è quanto
paga salire — e i bot se ne accorgono, perché il valore di una costruzione se lo leggono
dalla tabella, non da un numero scritto nel loro codice.

| tabella | primo | ultimo | distacco | distacco / punti del primo | Verticalità | quota sul punteggio | edifici sopra | quota max raggiunta |
|---|--:|--:|--:|--:|--:|--:|--:|--:|
| **2 / 6 / 12 / 20** (quella attuale) | 110,1 | 63,1 | **47,0** | 43% | 32,8 | 38% | 4,95 | 3,75 |
| 2 / 5 / 9 / 14 | 96,8 | 57,1 | 39,7 | 41% | 23,0 | 30% | 4,92 | 3,69 |
| 2 / 5 / 8 / 11 | 90,7 | 54,8 | 35,9 | 40% | 18,7 | 26% | 4,90 | 3,63 |
| 2 / 4 / 6 / 8 (lineare) | 85,2 | 52,2 | **33,0** | 39% | 14,4 | 21% | 4,87 | 3,57 |

## Le tre cose che dicono i numeri

**1. Il distacco si stringe di un terzo, ma in proporzione quasi per niente.** Da 47 punti
a 33, che è molto — però i punteggi calano insieme, e il distacco *rispetto a quanto fa il
vincitore* passa dal 43% al 39%. Chi arriva ultimo prende meno della metà del primo in
tutte e quattro le tabelle. Se il fastidio è «il distacco è largo», appiattire la
Verticalità lo riduce in cifra assoluta ma non cambia la forma della partita.

**2. La strada resta alta lo stesso.** Ed è il risultato che non mi aspettavo:

| | 2/6/12/20 | 2/4/6/8 |
|---|--:|--:|
| edifici costruiti sopra, per giocatore | 4,95 | 4,87 |
| quota massima raggiunta | 3,75 | 3,57 |

Dimezzare il premio della cima cambia il comportamento di **meno del 2%**. Non si costruisce
in alto perché la Verticalità paga: si costruisce in alto perché a un certo punto **i
binari a terra sono pieni**, perché costruire sopra sotterra i propri ruderi (che valgono
Scavo) e perché è l'unico modo di togliere di mezzo la roba altrui. Il premio della cima è
la ricompensa di una cosa che si farebbe comunque. Cioè: **la tabella della Verticalità non
è una leva sul gioco, è una leva sul punteggio.**

**3. Quello che cambia davvero è quanto del distacco è Verticalità.**

| tabella | Verticalità del primo | dell'ultimo | quanta parte del distacco è solo Verticalità |
|---|--:|--:|--:|
| 2/6/12/20 | 46,5 | 21,3 | **54%** |
| 2/5/9/14 | 31,9 | 15,5 | 41% |
| 2/5/8/11 | 25,1 | 13,5 | 32% |
| 2/4/6/8 | 18,6 | 10,9 | 24% |

Con la tabella di adesso **più di metà della differenza fra il primo e l'ultimo è un canale
solo**. Con quella lineare scende a un quarto, e il resto del gioco — Rendita, Scavo,
Continuità — si prende lo spazio: la Rendita passa dal 21% al 27% del punteggio, lo Scavo
dall'11% al 14%, la Continuità dal 7,9% al 10,4%.

## E le strategie?

| tabella | Bilanciata | Rendita | Scavo | Lampo | Verticale |
|---|--:|--:|--:|--:|--:|
| 2/6/12/20 | 40,0% | 38,5% | 33,0% | 28,5% | 26,7% |
| 2/5/9/14 | 40,0% | 40,2% | 30,8% | 29,2% | 26,5% |
| 2/5/8/11 | 38,5% | 40,3% | 31,8% | 30,3% | 25,7% |
| 2/4/6/8 | 38,2% | 41,5% | 32,7% | 31,2% | 23,2% |

La strategia Verticale **peggiora** man mano che la tabella si appiattisce (26,7% → 23,2%),
il che è ovvio; la Rendita migliora (38,5% → 41,5%). Ma nessuna tabella ribalta la
classifica: la Bilanciata resta in testa o quasi in tutte e quattro. Appiattire la
Verticalità non crea né distrugge una linea di gioco.

## La scelta

L'obiettivo era **che il tavolo avesse più voci in gioco**, e la tabella intermedia
**2 / 5 / 9 / 14** fa quasi tutto il lavoro: il canale scende dal 38% al 30% del punteggio,
la parte di distacco che dipende da lui crolla dal 54% al 41%, e il punteggio del vincitore
resta sopra i 95 punti — cioè il gioco «pesa» ancora come adesso. La lineare 2/4/6/8 va
oltre: toglie 25 punti al vincitore e rende la salita quasi indifferente, e a quel punto
la cima della colonna smette di essere una cosa per cui valga la pena litigare.

Quello che questa scelta **non** fa è far costruire meno in alto: per quello nessuna di
queste tabelle serve: bisogna agire sul *costo* di salire (terrapieni, spoliazione, il tetto
di un livello per era), non sul premio.

## Rifare i conti

```
for t in 2,6,12,20 2,5,9,14 2,5,8,11 2,4,6,8; do
  godot --headless res://scenes/audit_partita.tscn -- \
    --players 3 --games 1000 --seed 400000 --verticalita $t > vt_$t.csv
done
python3 tools/confronta_verticalita.py vt_*.csv
```

`--verticalita` sostituisce la tabella solo per la durata della corsa: `data/cards.json`
resta l'unica fonte e non viene toccato.
