# La terza risorsa: la v2 gioca sullo stesso motore

> Prima misura con i **dati nuovi**: `data/cards-v2.json`, generato da `tools/genera_cards_v2.py`
> dalla v1.5 e dalla tabella dei costi in tre risorse approvata dal designer
> (`proposte/costi-tre-risorse.md`: le Idee sostituiscono, esplodono nelle ere 4-5). Le tessere
> producono per tipo con la curva dell'audit, fiume e collina Costruzione 2/2/1/1/1, pianura
> Denaro 0/1/1/2/2 (più 1 Costruzione nelle ere 1-2), bosco Idee 1/2/2/3/3; il mix di terreni
> garantisce il bosco, due a tre giocatori. Tutto il resto è la v1.5: con `cards.json` il motore
> gioca il lotto di riferimento identico riga per riga.

Quattro lotti a parità di semi, 2 000 partite `--vita` e 750 di torneo, 3 giocatori:

| | dati | regole |
|---|---|---|
| **A** oggi | v1.5 | v1.5 |
| **B** | **v2** | v1.5: isola la terza risorsa |
| **C** | v1.5 | il pacchetto scelto finora: senza rudere a soglia 2, spianato a 0, Verticalità a zero, premio S×L |
| **D** | **v2** | lo stesso pacchetto |

## Il torneo

| per giocatore | A oggi | B v2 | C pacchetto | D v2 + pacchetto |
|---|--:|--:|--:|--:|
| PV medi | 85,7 | 88,1 | 74,6 | 77,8 |
| Rendita | 22,1 | 17,7 | 22,5 | 18,4 |
| Verticalità | 25,1 | 27,5 | 0 | 0 |
| Scavo | 6,8 | 8,0 | 19,6 | 22,5 |
| Lampo | 12,0 | 14,1 | 12,6 | 15,1 |
| costruiti | 9,9 | 10,4 | 10,3 | 10,9 |
| costruiti sopra un altro | 5,1 | 5,5 | 5,7 | 6,0 |
| altezza massima | 3,9 | 4,0 | 4,1 | 4,2 |
| basi proprie | 4,2 | 4,3 | 5,0 | 5,1 |
| **basi altrui** | 2,0 | **2,5** | 2,0 | **2,5** |
| propri intatti spianati | 2,5 | 2,4 | 3,7 | 3,7 |
| Idee prodotte / spese | — | 10,7 / 8,8 | — | 10,7 / 8,7 |
| vince Rendita | 41 % | 39 % | 37 % | 45 % |
| vince Bilanciata | 39 % | 41 % | 38 % | 46 % |
| vince Obiettivi | 34 % | 38 % | 41 % | 34 % |
| vince Verticale | 31 % | 30 % | 26 % | 29 % |
| vince Scavo | 29 % | 25 % | 29 % | 22 % |
| vince Lampo | 27 % | 28 % | 29 % | 25 % |

## La vita degli edifici

| per partita | A oggi | B v2 | C pacchetto | D v2 + pacchetto |
|---|--:|--:|--:|--:|
| costruiti | 29,5 | 31,1 | 30,6 | 32,7 |
| in piedi a fine partita | 9,3 | 9,1 | 8,4 | 9,1 |
| cade nell'era in cui nasce | 17 % | 18 % | 33 % | 33 % |
| sepolti | 51 % | 54 % | 52 % | 55 % |
| sepolti da un altro | n.d. | 23 % | 19 % | 22 % |
| spianati dal proprietario | 25 % | 23 % | 36 % | 34 % |
| Rendita | 66 | 53 | 67 | 55 |
| Lampo | 36 | 42 | 38 | 45 |
| Scavo | 20,5 | 23,9 | 59,6 | 68,6 |
| Scheletri | 8,3 | 6,0 | 7,0 | 4,7 |

Il kingmaker con D: 53 % del premio nell'era 5, bottino dell'ultima era del vincitore ≥ distacco
nel 44 % delle partite, senza l'era 5 il vincitore cambierebbe nel **22 %** (con C: 48 %, 31 %,
17 %).

## Cosa salta all'occhio

**1. La terza risorsa da sola sposta poco, e nella direzione giusta.** B contro A: +2 punti,
+1,6 edifici a partita, altezza 4,0, vittorie entro l'errore. Le Idee non mancano: se ne
producono 10,7 a giocatore e se ne spendono 8,8, l'82 %. Il Lampo sale (+6 a partita) e la
Rendita scende (−13): con più risorse si costruisce di più e gli edifici vivono meno (ere
intatto 1,57 contro 1,68). **Le basi altrui salgono da 2,0 a 2,5** per giocatore, senza nessuna
regola che lo chieda: con tre risorse da incastrare si costruisce dove si può, non solo sul
proprio.

**2. Il pacchetto di regole si comporta con le carte nuove come con le vecchie.** D contro C:
stessa forma (altezza 4,2, spianati 3,7, sepolti 55 %), Scavo un po' più alto (22,5 contro
19,6), basi altrui 2,5 contro 2,0. Le conclusioni delle misure con le carte vecchie reggono: il
premio S×L rimette in piedi la città, la neutralità fra proprio e altrui resta, e la terza risorsa
aggiunge mezza base altrui.

**3. Il kingmaker peggiora con i dati nuovi.** Da 17 % a 22 % di partite decise dall'ultima era,
con il 53 % del premio incassato nell'era 5: le carte dell'era 5 costano poco in Costruzione e
le Idee sono abbondanti, quindi nell'ultima era si costruisce di più e sulle pile più alte. La
correzione all'ultima era, già proposta (premio dimezzato nell'era 5, o solo fino all'era 4),
diventa necessaria, non facoltativa.

**4. Le strategie dei bot sono tarate sulla v1.5.** Bilanciata e Rendita vincono di più in D
perché le altre inseguono canali che non ci sono più (Verticale) o che hanno cambiato regola
(Scavo). Le percentuali di vittoria di D si leggono come "chi soffre meno il cambio", non come
un bilanciamento: le strategie vanno riscritte per la v2 prima di leggere le vittorie.

## Cosa resta da decidere

- **La correzione all'ultima era** del premio di scavo (punto 3): due manopole da una riga.
- **Il tetto delle risorse** (D5 dell'audit): oggi 5 in tutto, Idee comprese, e il 18 % delle
  Idee prodotte non si spende. Se il tetto sale a 6, si misura.
- **Potenziamenti, Dinastia, ristrutturazione** (D2): ancora in oro. Se passano alle Idee, la
  domanda di Idee cresce e l'82 % speso può diventare scarsità.

## Seconda misura: le decisioni del registro 91

Il designer: correggere l'ultima era; "tetto a tre"; i potenziamenti pagano secondo cosa sono
(Arte in Idee, Struttura in Costruzione, il resto in Denaro); la Dinastia in Idee; la
ristrutturazione in Costruzione e Denaro. Le prime quattro sono nel file dati v2 rigenerato
(tetto 3 per risorsa alla dispersione, con il totale di 5 che resta; importi come oggi), la
quinta e la correzione nel motore (`premio_era5`: intero, dimezzato, niente). Tre lotti sulla
base D (v2 + pacchetto), stessi semi:

| per giocatore | D (v2 di prima) | E1 nuovi dati, era 5 intera | E2 era 5 dimezzata | E3 era 5 senza premio |
|---|--:|--:|--:|--:|
| PV medi | 77,8 | 78,9 | 74,4 | 70,4 |
| Scavo | 22,5 | 22,5 | 18,0 | 13,6 |
| Rendita | 18,4 | 18,7 | 18,7 | 19,6 |
| premio incassato scavando | 16,8 | 16,7 | 12,2 | 7,9 |
| di cui nell'era 5 | 9,0 (53 %) | 8,9 (53 %) | 4,3 (36 %) | 0 |
| altezza massima | 4,18 | 4,18 | 4,17 | **3,99** |
| basi proprie | 5,1 | 5,2 | 5,2 | 5,2 |
| basi altrui | 2,5 | 2,4 | 2,4 | **2,0** |
| Idee prodotte / spese | 10,7 / 8,7 | 11,4 / 9,6 | 11,4 / 9,6 | 11,4 / 9,5 |
| bottino dell'era 5 del vincitore ≥ distacco | 44 % | 41 % | **20 %** | 0 % |
| senza l'era 5 cambierebbe il vincitore | 22 % | 21 % | **12 %** | 0 % |
| vince Rendita / Lampo / Bilanciata | 45 / 25 / 46 % | 40 / 27 / 44 % | 39 / 28 / 40 % | 32 / 34 / 38 % |

Per partita: sepolti 55 / 55 / 55 / 53 %, sepolti da un altro 22 / 22 / 21 / 18 %, edifici in
piedi a fine partita 9,1 / 9,2 / 9,2 / 9,4.

**1. Le decisioni sui dati sono neutre.** E1 contro D: un punto di differenza, stessa forma,
stesse basi. Il tetto a 3 per risorsa non morde (le Idee spese passano dall'81 all'85 %), i
potenziamenti per famiglia e la Dinastia in Idee non spostano le vittorie oltre l'errore.

**2. Il premio dimezzato nell'era 5 è la correzione giusta.** E2: il kingmaker scende dal 21 al
12 % (era l'11 % di S+L, senza rinunciare alla scala di S×L), il bottino dell'ultima era del
vincitore supera il distacco in una partita su cinque invece di due su cinque, e la città non
cambia: altezza 4,17, basi altrui 2,4, sepolti 55 %. Costa 4,5 punti di Scavo a giocatore.

**3. Senza premio nell'ultima era la città smette di salire.** E3: altezza da 4,2 a 4,0, basi
altrui da 2,4 a 2,0, sepolti da un altro dal 22 al 18 %: nell'era 5 non c'è più motivo di
costruire sopra, e vince chi costruisce e basta (Lampo 34 %). Il kingmaker sparisce per
costruzione, ma con lui l'ultima era.

## Le regole della v2 stanno nel file v2

Dopo la decisione del designer ("dimezzato"), `data/cards-v2.json` porta come costanti tutte le
regole scelte finora: senza rudere, rovina a −2, spianato a 0, Verticalità a zero, premio S×L
dimezzato nell'era 5, tetto 3 per risorsa. `--dati data/cards-v2.json` gioca la v2 senza
manopole, e le 120 partite di prova escono identiche a quelle con le manopole. Le manopole
restano per le prove sulla v1.5.

## Come rifare il conto

```bash
python3 tools/genera_cards_v2.py                       # rigenera data/cards-v2.json
A="--players 3 --vita 2000 --seed 200000"              # o --games 750 --seed 700000
godot --headless res://scenes/audit_partita.tscn -- $A --dati data/cards-v2.json > B.csv
godot --headless res://scenes/audit_partita.tscn -- $A --dati data/cards-v2.json \
  --senza_rudere 1 --gap 2 --verticalita 0,0,0,0 --premio per_livello > D.csv
python3 tools/confronta_vita.py A.csv B.csv C.csv D.csv
# seconda misura, con i dati rigenerati (tetto 3, potenziamenti per famiglia, Dinastia in Idee):
godot --headless res://scenes/audit_partita.tscn -- $A --dati data/cards-v2.json \
  --senza_rudere 1 --gap 2 --verticalita 0,0,0,0 --premio per_livello --premio_era5 dimezzato > E2.csv
```
