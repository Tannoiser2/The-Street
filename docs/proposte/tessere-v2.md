# Le tessere della v2: terreni fissi, 35 tessere dell'era

Proposta del 28 settembre, dalla dima del designer (`Dima_terreni.pdf`). Non è ancora nel motore
né in `data/cards-v2.json`: si scrive qui, il designer la corregge, e solo dopo si implementa e si
misura.

## Come sono fatte

**Due oggetti diversi.**

- **La tessera terreno** è lunga quanto la colonna e non cambia mai: in cima il nome del terreno,
  sotto i cinque binari dove si appoggiano le sagome, in fondo una casella vuota.
- **La tessera dell'era** è grande come una carta edificio (194 x 116 pt). Porta la **produzione**
  di quel terreno in quell'era e un **effetto**. A inizio era si mette nella casella in fondo alla
  colonna del suo terreno, sopra quella dell'era prima.

L'effetto scatta **una volta per era, alla prima occasione**, poi la tessera si gira, come oggi
(registro 100). La produzione vale per tutta l'era, a ogni attivazione.

**Stampa: cinque pagine A4**, ciascuna con due tessere terreno e sette tessere dell'era.

| pagina | tessere terreno | tessere dell'era |
|--:|---|---|
| 1 | Pianura, Collina | 7 dell'era 1 |
| 2 | Fiume, Bosco | 7 dell'era 2 |
| 3 | Pianura, Collina | 7 dell'era 3 |
| 4 | Fiume, Bosco | 7 dell'era 4 |
| 5 | Pianura, Collina | 7 dell'era 5 |

In tutto 3 Pianure, 3 Colline, 2 Fiumi, 2 Boschi e 35 tessere dell'era.

**Quante per terreno.** Ogni era ha 2 Pianure, 2 Fiumi, 1 Collina e 2 Boschi: è la strada a tre
giocatori (7 colonne), che così si copre esattamente. A due giocatori (5 colonne: 2 Pianure,
1 Fiume, 1 Collina, 1 Bosco) si pesca a caso fra quelle del terreno giusto.

**La produzione** è la tabella di oggi, terreno per era (C = Costruzione, D = Denaro, I = Idee):

| terreno | era 1 | era 2 | era 3 | era 4 | era 5 |
|---|:-:|:-:|:-:|:-:|:-:|
| Pianura | 1 C | 1 C + 1 D | 1 D | 2 D | 2 D |
| Fiume | 2 C | 2 C | 1 C | 1 C | 1 C |
| Collina | 2 C | 2 C | 1 C | 1 C | 1 C |
| Bosco | 1 I | 2 I | 2 I | 3 I | 3 I |

## Le 35 tessere

"Qui" vuol dire la colonna della tessera. "Chi attiva per primo" è il primo giocatore che
piazza un lavoratore su questa colonna nell'era. Le quattro regole di oggi restano, ciascuna in
una tessera sola: Campi arati, Guado, Altura, Selva.

### Era 1 — La fondazione

| # | terreno | nome | produce | effetto, una volta per era |
|--:|---|---|---|---|
| 1 | Pianura | Campi arati | 1 C | Il primo edificio da 2 o 3 caselle costruito qui costa 1 Costruzione in meno. |
| 2 | Pianura | Radura | 1 C | Il primo edificio Civico costruito qui dà +1 Lampo. |
| 3 | Fiume | Guado | 2 C | Chi attiva per primo prende +1 Denaro. |
| 4 | Fiume | Canneto | 2 C | Il primo edificio costruito qui ignora il requisito di terreno. |
| 5 | Collina | Altura | 2 C | Il primo edificio costruito qui ha +1 resistenza fino a fine era. |
| 6 | Bosco | Bosco sacro | 1 I | Il primo edificio Religione costruito qui costa 1 Idea in meno. |
| 7 | Bosco | Sottobosco | 1 I | Chi attiva per primo può cambiare 1 Idea in 1 Costruzione. |

### Era 2 — L'impero

| # | terreno | nome | produce | effetto, una volta per era |
|--:|---|---|---|---|
| 8 | Pianura | Centuriazione | 1 C + 1 D | Il primo edificio Ingegneria costruito qui costa 1 Costruzione in meno. |
| 9 | Pianura | Via consolare | 1 C + 1 D | Chi attiva per primo prende anche la produzione di una colonna adiacente a scelta. |
| 10 | Fiume | Porto fluviale | 2 C | Il primo edificio Commercio costruito qui dà +1 Denaro a chi lo costruisce. |
| 11 | Fiume | Mulini ad acqua | 2 C | Chi attiva per primo può cambiare 1 Costruzione in 1 Denaro. |
| 12 | Collina | Cava di marmo | 2 C | Il primo edificio costruito qui sopra un altro edificio costa 1 Costruzione in meno. |
| 13 | Bosco | Selva | 2 I | Una ristrutturazione di un edificio qui costa 1 Costruzione in meno. |
| 14 | Bosco | Lucus | 2 I | Il primo edificio costruito qui ha Scavo +1, per sempre. |

### Era 3 — I castelli

| # | terreno | nome | produce | effetto, una volta per era |
|--:|---|---|---|---|
| 15 | Pianura | Fiera | 1 D | Chi attiva per primo prende +1 Denaro per ogni altro giocatore con un edificio intatto qui. |
| 16 | Pianura | Borgo franco | 1 D | Il primo edificio costruito qui sopra una rovina altrui costa 1 Costruzione in meno. |
| 17 | Fiume | Mulino | 1 C | Chi attiva per primo prende +1 Idea per ogni edificio Ingegneria intatto qui. |
| 18 | Fiume | Ponte levatoio | 1 C | Il primo edificio Militare costruito qui ha +2 resistenza fino a fine era. |
| 19 | Collina | Rocca | 1 C | Il primo edificio costruito qui è protetto all'evento di fine era. |
| 20 | Bosco | Eremo | 2 I | Il primo edificio Religione o Cultura costruito qui dà +2 Lampo. |
| 21 | Bosco | Bosco del conte | 2 I | Chi seppellisce per primo un edificio qui prende +1 al premio di scavo. |

### Era 4 — Le signorie

| # | terreno | nome | produce | effetto, una volta per era |
|--:|---|---|---|---|
| 22 | Pianura | Villa di campagna | 2 D | Il primo edificio Cultura costruito qui costa 1 Denaro in meno. |
| 23 | Pianura | Piazza del mercato | 2 D | Chi attiva per primo, se ha meno punti di tutti, prende +2 Denaro. |
| 24 | Fiume | Canali | 1 C | Chi attiva per primo prende 1 risorsa a scelta. |
| 25 | Fiume | Darsena | 1 C | Il primo edificio Commercio costruito qui produce subito, una volta. |
| 26 | Collina | Belvedere | 1 C | Il primo edificio costruito qui al livello 3 o più dà +2 Lampo. |
| 27 | Bosco | Giardino all'italiana | 3 I | Il primo edificio ristrutturato qui torna in piedi con +1 resistenza. |
| 28 | Bosco | Parco del palazzo | 3 I | Il primo scheletro lasciato qui vale +1 punto a fine partita. |

### Era 5 — La città moderna

Nell'era Moderna lo Scavo non vale: nessuna tessera dell'era 5 ne parla.

| # | terreno | nome | produce | effetto, una volta per era |
|--:|---|---|---|---|
| 29 | Pianura | Periferia | 2 D | Il primo edificio Civico costruito qui costa 1 Idea in meno. |
| 30 | Pianura | Zona industriale | 2 D | Chi attiva per primo prende +1 Denaro per ogni edificio Ingegneria o Commercio intatto qui. |
| 31 | Fiume | Lungofiume | 1 C | Il primo edificio costruito qui dà +1 Lampo per ogni edificio altrui intatto qui. |
| 32 | Fiume | Chiusa | 1 C | Il primo edificio Ingegneria costruito qui costa 1 Denaro in meno. |
| 33 | Collina | Quartiere alto | 1 C | Il primo edificio costruito qui, se diventa il più alto della strada, dà +3 Lampo. |
| 34 | Bosco | Parco pubblico | 3 I | A fine partita chi ha l'edificio in cima a questa colonna prende +2 punti. |
| 35 | Bosco | Orto botanico | 3 I | Il primo potenziamento messo su un edificio qui costa 1 Idea in meno. |

## Da decidere

1. **A quattro giocatori le tessere dell'era non bastano.** La strada ha 9 colonne (3 Pianure,
   2 Fiumi, 2 Colline, 2 Boschi) e le tessere per era sono 7: mancano ogni era 1 Pianura e 1 Collina.
   Tre strade possibili:
   - **9 per era** (45 in tutto, 10 in più): la più pulita, ma serve una pagina in più ogni due ere.
   - A quattro, **le due colonne scoperte producono secondo la tabella e non hanno effetto**.
   - A quattro si torna a **8 colonne**.
2. **I nomi e gli effetti** sono proposte: cambiali, scambiali di era, tienine alcuni.
3. **Gli effetti nuovi vanno misurati.** Alcuni danno più di oggi: Via consolare, Fiera, Zona
   industriale e Quartiere alto. Una volta decise, le tessere entrano nel file v2 e si rigioca la
   misura standard a 2, 3 e 4.
