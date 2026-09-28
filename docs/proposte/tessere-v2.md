# Le tessere della v2: terreni fissi, 35 tessere dell'era in due copie

Proposta del 28 settembre, dalla dima del designer (`Dima_terreni.pdf`) e dalla sua correzione:
"raddoppiamo le 7 tessere; non sono collegate al tipo di terreno; il terreno ha una produzione di
base, le tessere aggiungono altre icone di produzione e l'effetto". Non è ancora nel motore né in
`data/cards-v2.json`: si scrive qui, il designer la corregge, poi si implementa e si misura.

## Come sono fatte

**La tessera terreno** è lunga quanto la colonna e non cambia mai. Porta:
- in cima il nome e **la produzione di base** del terreno;
- sotto, i cinque binari dove si appoggiano le sagome;
- in fondo, una casella vuota.

| terreno | produzione di base | quante |
|---|---|--:|
| Pianura | 1 Costruzione | 3 |
| Fiume | 1 Denaro | 2 |
| Collina | 1 Costruzione | 3 |
| Bosco | 1 Idea | 2 |

Il requisito "fiume" delle sagome resta stretto; gli altri restano morbidi (colonna o adiacente).

**La tessera dell'era** è grande come una carta edificio (194 x 116 pt) e **non ha terreno**. Porta
da zero a una icona di **produzione in più** e un **effetto**. Ogni era ha 7 tessere diverse, stampate
in **due copie**: 14 per era, 70 in tutto. A inizio era si mescolano le 14 dell'era e se ne mette
una nella casella di ogni colonna, sopra quella dell'era prima: 5 colonne a due giocatori, 7 a tre,
9 a quattro.

**Chi attiva una colonna** prende la produzione di base del terreno più quella della tessera. L'effetto
scatta **una volta per era, alla prima occasione**, poi la tessera si gira, come oggi (registro 100).

**Perché questi numeri.** A tre giocatori (2 Pianure, 2 Fiumi, 1 Collina, 2 Boschi) la produzione
totale di base più tessere è **la stessa di oggi** in ogni era, risorsa per risorsa. L'unica
differenza è l'era 1: il Fiume dà Denaro fin da subito, quindi 2 Denaro al posto di 2 Costruzione.
Il Fiume diventa la fonte del Denaro, come era la sua regola di oggi (+1 Denaro a chi lo attiva);
la Pianura, Costruzione (decisione del designer).
A due e a quattro giocatori le tessere si pescano, quindi il conto è uguale in media.

| era | oggi a tre giocatori | base + tessere |
|--:|---|---|
| 1 | 8 C, 2 I | 6 C, 2 D, 2 I |
| 2 | 8 C, 2 D, 4 I | uguale |
| 3 | 3 C, 2 D, 4 I | uguale |
| 4 | 3 C, 4 D, 6 I | uguale |
| 5 | 3 C, 4 D, 6 I | uguale |

C = Costruzione, D = Denaro, I = Idee.

**Stampa.** Le cinque pagine della dima, ciascuna con due tessere terreno e le sette tessere di
un'era, danno 3 Pianure, 3 Colline, 2 Fiumi, 2 Boschi e una copia delle 35 tessere. La seconda copia
delle tessere dell'era si stampa a parte: cinque pagine con le sole tessere, oppure la stessa
pagina ristampata lasciando vuote le due colonne dei terreni.

## Le 35 tessere

"Qui" vuol dire la colonna dove sta la tessera. "Chi attiva per primo" è il primo giocatore che
piazza un lavoratore su questa colonna nell'era. I nomi non evocano più un terreno, perché la
tessera può stare su qualunque colonna. Le quattro regole dei terreni di oggi restano, ciascuna in
una tessera: Campi arati, Sentiero dei pastori, Recinto di pietre, Restauratori.

### Era 1 — La fondazione (in più: 3 Costruzione)

| # | nome | in più | effetto, una volta per era |
|--:|---|:-:|---|
| 1 | Campi arati | 1 C | Il primo edificio da 2 o 3 caselle costruito qui costa 1 Costruzione in meno. |
| 2 | Radura | — | Il primo edificio Civico costruito qui dà +1 Lampo. |
| 3 | Sentiero dei pastori | — | Chi attiva per primo prende +1 Denaro. |
| 4 | Terra di nessuno | — | Il primo edificio costruito qui ignora il requisito di terreno. |
| 5 | Recinto di pietre | 1 C | Il primo edificio costruito qui ha +1 resistenza fino a fine era. |
| 6 | Luogo sacro | — | Il primo edificio Religione costruito qui costa 1 Idea in meno. |
| 7 | Raccoglitori | 1 C | Chi attiva per primo può cambiare 1 Idea in 1 Costruzione. |

### Era 2 — L'impero (in più: 5 Costruzione, 2 Idee)

| # | nome | in più | effetto, una volta per era |
|--:|---|:-:|---|
| 8 | Centuriazione | 1 C | Il primo edificio Ingegneria costruito qui costa 1 Costruzione in meno. |
| 9 | Via consolare | 1 C | Chi attiva per primo prende anche la produzione di una colonna adiacente a scelta. |
| 10 | Statio | 1 C | Il primo edificio Commercio costruito qui dà +1 Denaro a chi lo costruisce. |
| 11 | Cambiavalute | 1 C | Chi attiva per primo può cambiare 1 Costruzione in 1 Denaro. |
| 12 | Cantiere | 1 C | Il primo edificio costruito qui sopra un altro edificio costa 1 Costruzione in meno. |
| 13 | Restauratori | 1 I | Una ristrutturazione di un edificio qui costa 1 Costruzione in meno. |
| 14 | Necropoli | 1 I | Il primo edificio costruito qui ha Scavo +1, per sempre. |

### Era 3 — I castelli (in più: 2 Idee)

| # | nome | in più | effetto, una volta per era |
|--:|---|:-:|---|
| 15 | Fiera | — | Chi attiva per primo prende +1 Denaro per ogni altro giocatore con un edificio intatto qui. |
| 16 | Borgo franco | — | Il primo edificio costruito qui sopra una rovina altrui costa 1 Costruzione in meno. |
| 17 | Scuola dei mastri | 1 I | Chi attiva per primo prende +1 Idea per ogni edificio Ingegneria intatto qui. |
| 18 | Mura | — | Il primo edificio Militare costruito qui ha +2 resistenza fino a fine era. |
| 19 | Rocca | — | Il primo edificio costruito qui è protetto all'evento di fine era. |
| 20 | Eremo | 1 I | Il primo edificio Religione o Cultura costruito qui dà +2 Lampo. |
| 21 | Spoglio delle rovine | — | Chi seppellisce per primo un edificio qui prende +1 al premio di scavo. |

### Era 4 — Le signorie (in più: 2 Denaro, 4 Idee)

| # | nome | in più | effetto, una volta per era |
|--:|---|:-:|---|
| 22 | Villa di campagna | 1 D | Il primo edificio Cultura costruito qui costa 1 Denaro in meno. |
| 23 | Piazza del mercato | — | Chi attiva per primo, se ha meno punti di tutti, prende +2 Denaro. |
| 24 | Bottega | 1 I | Chi attiva per primo prende 1 risorsa a scelta. |
| 25 | Fondaco | 1 D | Il primo edificio Commercio costruito qui produce subito, una volta. |
| 26 | Belvedere | 1 I | Il primo edificio costruito qui al livello 3 o più dà +2 Lampo. |
| 27 | Giardino all'italiana | 1 I | Il primo edificio ristrutturato qui torna in piedi con +1 resistenza. |
| 28 | Cappella di famiglia | 1 I | Il primo scheletro lasciato qui vale +1 punto a fine partita. |

### Era 5 — La città moderna (in più: 2 Denaro, 4 Idee)

Nell'era Moderna lo Scavo non vale: nessuna tessera dell'era 5 ne parla.

| # | nome | in più | effetto, una volta per era |
|--:|---|:-:|---|
| 29 | Periferia | 1 D | Il primo edificio Civico costruito qui costa 1 Idea in meno. |
| 30 | Zona industriale | — | Chi attiva per primo prende +1 Denaro per ogni edificio Ingegneria o Commercio intatto qui. |
| 31 | Isolato | 1 I | Il primo edificio costruito qui dà +1 Lampo per ogni edificio altrui intatto qui. |
| 32 | Scuola politecnica | 1 D | Il primo edificio Ingegneria costruito qui costa 1 Denaro in meno. |
| 33 | Quartiere alto | 1 I | Il primo edificio costruito qui, se diventa il più alto della strada, dà +3 Lampo. |
| 34 | Parco pubblico | 1 I | A fine partita chi ha l'edificio in cima a questa colonna prende +2 punti. |
| 35 | Orto botanico | 1 I | Il primo potenziamento messo su un edificio qui costa 1 Idea in meno. |

## Da decidere

1. ~~La produzione di base~~: deciso dal designer, Pianura 1 Costruzione e Fiume 1 Denaro.
2. **Il Denaro tardo a due e a quattro giocatori.** Con il Denaro sul Fiume, e i Fiumi meno delle
   Pianure, a due e a quattro giocatori le ere 3–5 hanno meno Denaro di oggi (media per era):

   | | era 3 | era 4 | era 5 |
   |---|:-:|:-:|:-:|
   | a due: oggi / nuovo | 2 / 1 | 4 / 2,4 | 4 / 2,4 |
   | a quattro: oggi / nuovo | 3 / 2 | 6 / 4,6 | 6 / 4,6 |

   A tre è identico. Se la misura lo conferma come un problema, la correzione più semplice è
   spostare un'icona da Idee a Denaro nelle tessere delle ere 4 e 5.
3. **I nomi e gli effetti** sono proposte: cambiali, scambiali di era, tienine alcuni.
4. **Come si stampano le seconde copie** delle tessere dell'era (vedi "Stampa").
5. **Gli effetti nuovi vanno misurati.** Alcuni danno più di oggi (Via consolare, Fiera, Zona
   industriale, Quartiere alto). Una volta decise, le tessere entrano nel file v2 e si rigioca la
   misura standard a 2, 3 e 4 giocatori.
