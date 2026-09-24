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

## Terza misura: le strategie della v2

Le sei strategie erano tarate sulla v1.5: la Verticale inseguiva un canale che nella v2 non
esiste e la Scavo inseguiva lo Scavo di chi viene sepolto, non il premio di chi scava. Registro
92: con il file v2 caricato il canone è **Rendita, Lampo, Scavo, Continuità, Bilanciata,
Obiettivi**; la Scavo insegue il premio S×L (le pile ricche e alte), la Continuità entra al posto
della Verticale. Quale canone vale lo dice il file dati. Stesso lotto v2 (tutte le regole nel
file), stessi semi, due canoni:

| per giocatore | canone v1.5 | canone v2 |
|---|--:|--:|
| PV medi | 74,4 | 74,3 |
| Scavo | 18,0 | 17,0 |
| Continuità | 9,6 | 10,3 |
| altezza massima | 4,17 | 4,09 |
| basi proprie / altrui | 5,2 / 2,4 | 5,0 / 2,3 |
| senza l'era 5 cambierebbe il vincitore | 12 % | 10 % |

| strategia | vittorie (canone v2) | PV medi | il canale che insegue |
|---|--:|--:|--:|
| Bilanciata | 36,8 % | 73,7 | (il controllo) |
| Continuità | 36,0 % | 75,8 | Continuità 13,8 |
| Obiettivi | 35,7 % | 74,4 | Monumenti 2,8 |
| Rendita | 34,7 % | 74,8 | Rendita 28,5 |
| Scavo | 29,3 % | 72,1 | Scavo 23,2 |
| Lampo | 27,5 % | 75,3 | Lampo 25,9 |

Attesa per strategia 33,3 %, errore ±5.

**1. La v2, così com'è, è equilibrata fra le strategie.** Sei su sei entro l'errore, con il
Lampo sul bordo. Nella v1.5 la Rendita stava a 41 % e la Lampo a 27 %: la v2 stringe la
forbice. La Scavo, che con il canone vecchio inseguiva la regola sbagliata (23,7 %), inseguendo
il premio torna nella media (29,3 %).

**2. Il canone non cambia la città.** Stesso punteggio, stessa forma (altezza 4,1, sepolti 54 %,
basi altrui 2,3), il kingmaker al 10 %. Le misure fatte con il canone vecchio restano valide
per la forma del gioco; quelle sulle vittorie per strategia si leggono da qui in poi.

**3. Nessuna strategia domina, e nessuna è morta.** È il punto di partenza che serviva per le
prossime domande dell'audit (le cinque azioni, il draft dei Personaggi, la ristrutturazione
delle rovine): ogni cambiamento si misura contro questo lotto.

## Quarta misura: il turno a un'azione e il draft dei Personaggi

Il punto 8 della proposta, letto alla lettera: "ogni turno un giocatore può fare **una** delle
seguenti cose", con il lavoratore che va dove agisce (`turno_v2` nel file v2: attiva una colonna;
costruisce ovunque e il lavoratore sta sull'edificio nuovo con +2 e attiva solo quello; potenzia e
il lavoratore resta sotto come scheletro; ristruttura una propria rovina; compra la Dinastia;
passa e incassa 1 Costruzione più 1 risorsa a scelta). Tre lavoratori, tre turni per era. Poi la
decisione del designer sul draft: il Personaggio si prende a inizio era, gratis e senza lavoratore
(`draft_personaggi`), e Reclutare sparisce dalle azioni. Stesso lotto v2 di prima, stessi semi:

| per giocatore | S canone v2 | T turno a un'azione | T + draft |
|---|--:|--:|--:|
| PV medi | 74,3 | 32,1 | 44,3 |
| Rendita | 18,7 | 5,3 | 6,4 |
| Lampo | 15,3 | 10,0 | 10,9 |
| Scavo | 17,0 | 3,1 | 2,6 |
| Scheletri | 1,8 | 2,6 | **9,4** |
| costruiti | 10,8 | 6,8 | 7,5 |
| costruiti sopra un altro | 5,8 | 4,1 | 4,5 |
| altezza massima | 4,09 | 3,76 | 4,03 |
| basi proprie | 5,0 | 3,9 | 4,4 |
| **basi altrui** | 2,3 | **0,6** | **0,6** |
| premio incassato scavando | 11,5 | 2,1 | 1,7 |
| Idee prodotte / spese | 11,6 / 9,7 | 6,1 / 3,9 | 6,2 / 4,2 |
| azioni: colonna / costruisci / potenzia / ristruttura / recluta / passa | — | 5,4 / 6,8 / 0,5 / 0,2 / 1,4 / 0,8 | 5,0 / 7,5 / 1,1 / 0,3 / — / 1,2 |
| senza l'era 5 cambierebbe il vincitore | 11 % | 12 % | 10 % |
| vince Rendita / Lampo / Bilanciata | 35 / 28 / 37 % | 29 / 38 / 33 % | 39 / 33 / 36 % |

Per partita (2 000 `--vita`): costruiti 32,4 / 20,5 / 22,4; cade nell'era in cui nasce 33 / 13 /
12 %; spianati dal proprietario 33 / 49 / 51 %; **sepolti da un altro 21 / 8 / 7 %**; Scavo per
sepolto 2,96 / 0,85 / 0,59; Scheletri 5,7 / 7,8 / 28,4.

**0. Prima il bot, poi la regola.** La prima corsa di T dava 15,6 punti a giocatore: il bot
pagava le risorse a prezzo fisso anche con tredici pietre in mano che la dispersione avrebbe
tagliato a tre, e passava l'era a incassare. Nel turno v2 incassare costa il turno, quindi ora le
unità oltre quello che il mercato chiede (o oltre il tetto, con l'ultimo lavoratore) valgono
quasi niente. Con questo sconto il bot costruisce 6,8 edifici invece di 3,5, e la misura è
quella qui sopra.

**1. Con un'azione per lavoratore la partita si dimezza.** Tre azioni per era invece di tre
attivazioni più tre azioni: 7 edifici a giocatore invece di 11, 32-44 punti invece di 74. Non è
un difetto del bot: con 5 lavoratori (`--lavoratori 5`, prova a parte) si torna a 10 edifici e
54 punti, con 6 a 11 e 65. Il designer ha detto che i lavoratori restano tre: quindi il turno
non può essere "una cosa sola per lavoratore", e la sua lettura del punto 8 va scritta (vedi
registro 93).

**2. L'archeologia si spegne.** Le basi altrui passano da 2,3 a 0,6 a giocatore, i sepolti da un
altro dal 21 al 7 %, lo Scavo da 17 a 3 punti: con tre azioni per era si costruisce sul proprio,
al livello che c'è, e il premio S×L non si incassa quasi più (1,7 a giocatore). Le pile alte
(altezza 4,0) sono spianature dei propri edifici (51 %), non sepolture altrui. Il kingmaker resta
al 10-12 % solo perché il premio è piccolo.

**3. Il draft regala scheletri.** Un Personaggio gratis a era, cinque a partita, seppellito a fine
era sotto un edificio in piedi vale 6 meno l'era: gli Scheletri salgono da 1,8 a 9,4 punti a
giocatore (28 a partita), il canale più grosso dopo il Lampo. Con il draft la regola degli
scheletri (D12) va decisa: o il Personaggio non si seppellisce più (lo scheletro è il lavoratore
sul potenziamento, come dice la proposta), o il draft costa qualcosa.

**4. Il resto tiene.** Le sei strategie restano entro l'errore (28-39 %), gli eventi abbattono
di meno (cade nell'era in cui nasce 12 % contro 33 %: si costruisce meno, e gli edifici nuovi
sono protetti), la città ha la stessa altezza. Tutto il resto della v2 (tre risorse, niente
rudere, premio S×L) non cambia lettura.

## Come rifare il conto

```bash
python3 tools/genera_cards_v2.py                       # rigenera data/cards-v2.json
A="--players 3 --vita 2000 --seed 200000"              # o --games 750 --seed 700000
godot --headless res://scenes/audit_partita.tscn -- $A --dati data/cards-v2.json > B.csv
godot --headless res://scenes/audit_partita.tscn -- $A --dati data/cards-v2.json \
  --senza_rudere 1 --gap 2 --verticalita 0,0,0,0 --premio per_livello > D.csv
python3 tools/confronta_vita.py A.csv B.csv C.csv D.csv
# terza misura: le regole stanno nel file v2, il canone segue il file
godot --headless res://scenes/audit_partita.tscn -- --players 3 --games 750 --seed 700000 --dati data/cards-v2.json > S.csv
python3 tools/confronta_strategie.py S.csv
# seconda misura, con i dati rigenerati (tetto 3, potenziamenti per famiglia, Dinastia in Idee):
godot --headless res://scenes/audit_partita.tscn -- $A --dati data/cards-v2.json \
  --senza_rudere 1 --gap 2 --verticalita 0,0,0,0 --premio per_livello --premio_era5 dimezzato > E2.csv
# quarta misura: il turno v2 e il draft stanno ORA nel file v2, quindi il comando di S
# oggi produce T (S e' stato giocato prima che il turno entrasse nel file);
# `--lavoratori 5` prova un altro numero di lavoratori per era
godot --headless res://scenes/audit_partita.tscn -- --players 3 --games 750 --seed 700000 --dati data/cards-v2.json > T.csv
python3 tools/confronta_torneo.py S.csv T.csv
```
