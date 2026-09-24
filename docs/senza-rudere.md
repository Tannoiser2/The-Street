# Senza rudere: le prime misure della nuova meccanica

> La proposta del designer (`proposte/nuova-meccanica.md`, punto 11) toglie lo stato di rudere:
> restano attivo, rovina e sotterrato. Qui quel punto è misurato **da solo**, sul motore di oggi,
> prima di toccare qualsiasi altra cosa: è la D15 dell'audit. Manopola `senza_rudere` in
> `data/cards.json`, spenta; accesa con `--senza_rudere 1`. Le partite con la manopola spenta
> sono identiche al lotto di riferimento della v1.5, riga per riga.

**Il rudere si può togliere in due modi, e vanno in direzioni opposte.** Oggi chi fallisce
l'evento di 1 o 2 diventa rudere e chi fallisce di 3 crolla (`rovina_gap` 3). Senza lo stato
intermedio, il fallimento piccolo deve finire da una parte o dall'altra:

- **soglia 3, "senza rudere"**: chi fallisce di 1 o 2 **resta intatto** (senza Vetustà: non ha
  superato l'evento, l'ha scampato); chi fallisce di 3 crolla come oggi;
- **soglia 1, "ogni fallimento fa rovina"**: la lettura letterale del punto 9 della proposta
  ("se non resistono si girano sottosopra"). È `--gap 1`, senza bisogno della manopola.

## Il metodo

Tre lotti, **stessi semi**, stessi bot (StrategyBot versione 2, sei strategie a rotazione),
3 giocatori: 2 000 partite in modalità `--vita` (semi da 200000) e 750 di torneo (semi da 700000)
per variante. Il primo lotto è il gioco di oggi. Le tabelle della vita le stampa
`tools/confronta_vita.py`, quelle del torneo `tools/confronta_strategie.py`. Su 750 partite una
percentuale di vittoria ha ±5 punti di errore: sotto, è rumore.

```bash
godot --headless res://scenes/audit_partita.tscn -- --players 3 --vita 2000 --seed 200000 > con.csv
godot --headless res://scenes/audit_partita.tscn -- --players 3 --vita 2000 --seed 200000 --senza_rudere 1 > senza.csv
godot --headless res://scenes/audit_partita.tscn -- --players 3 --vita 2000 --seed 200000 --gap 1 > gap1.csv
python3 tools/confronta_vita.py con.csv senza.csv gap1.csv
```

## La vita degli edifici

| misura | oggi (rudere, rovina a −3) | senza rudere, rovina a −3 | ogni fallimento fa rovina |
|---|--:|--:|--:|
| costruiti per partita | 29,52 | 30,63 (+1,11) | 29,75 (+0,23) |
| **in piedi a fine partita** | **9,26** | **11,23 (+1,97)** | **7,08 (−2,18)** |
| intatti a fine partita | 8,57 | 11,23 (+2,66) | 7,08 (−1,50) |
| **cade nell'era in cui nasce** | **17 %** | **17 %** | **48 %** |
| ere intatto | 1,68 | 2,16 (+0,47) | 1,68 |
| ere in piedi | 2,07 | 2,16 (+0,08) | 1,68 (−0,40) |
| caduti (non più intatti) | 76 % | 63 % | 76 % |
| finiti in rovina | 69 % | 63 % | 76 % |
| **sepolti** | **51 %** | **50 %** | **51 %** |
| **Scavo per edificio sepolto** | **1,35** | **0,42 (−0,93)** | **1,46** |
| cubetti Vetustà per partita | 16,2 | 20,7 (+4,5) | 19,0 (+2,8) |
| PV delle carte per partita | 205,4 | 209,2 (+3,8) | 204,4 (−1,0) |
| di cui Rendita | 66,4 | **81,9 (+15,4)** | 65,8 (−0,6) |
| Lampo | 35,8 | 40,2 (+4,4) | 35,9 |
| Verticalità | 74,4 | 73,4 (−1,0) | 74,7 (+0,3) |
| Scavo | 20,5 | **6,5 (−14,0)** | 22,1 (+1,7) |
| Scheletri | 8,3 | 7,3 (−1,0) | 5,9 (−2,4) |

## Il torneo

Punti per giocatore, canale per canale, e vittorie per strategia.

| canale | oggi | senza rudere | ogni fallimento fa rovina |
|---|--:|--:|--:|
| Verticalità | 25,1 | 24,5 | 24,8 |
| Rendita | 22,1 | **27,2** | 21,9 |
| Lampo | 12,0 | 13,4 | 11,9 |
| Continuità | 8,9 | 9,7 | 9,2 |
| Scavo | 6,8 | **2,1** | 7,3 |
| Scheletri | 2,8 | 2,4 | 2,0 |
| PV medi | 85,7 | 88,9 | 85,2 |

| strategia | oggi | senza rudere | ogni fallimento fa rovina |
|---|--:|--:|--:|
| Rendita | 41,3 % | **46,1 %** | 42,7 % |
| Bilanciata | 38,7 % | 30,7 % | 36,3 % |
| Obiettivi | 33,6 % | 36,5 % | 36,0 % |
| Verticale | 30,7 % | **23,7 %** | 25,6 % |
| Scavo | 28,5 % | **38,9 %** | 34,4 % |
| Lampo | 27,2 % | 24,0 % | 25,1 % |

La forma del tavolo non cambia: edifici costruiti sopra un altro per giocatore 5,1 / 5,3 / 5,0,
altezza massima 3,9 in tutte e tre. Il Centro Urbano paga di più senza rudere (2,7 attivazioni
pagate per giocatore contro 1,7): con più edifici in piedi ci sono più Centri.

## Cosa salta all'occhio

**1. Senza rudere a soglia 3 l'archeologia sparisce, e non perché si seppellisca di meno.** I
sepolti restano al 50 %, ma lo Scavo per sepolto passa da 1,35 a 0,42 e il canale cade da 20,5
a 6,5 punti a partita. Il meccanismo è nelle regole di oggi: **sopra un edificio vivo non si
costruisce**, salvo il proprio, che si spiana (`was_razed`) e vale Scavo 0. Con il rudere, chi
fallisce di poco diventa una base per chiunque, e la sua sepoltura paga il proprietario. Senza,
chi fallisce di poco resta vivo e blocca la colonna agli altri: per salire si spiana il proprio,
e la memoria sotto la città vale zero. Nelle ere 1 e 2 lo Scavo per sepolto scende a 0,22 e 0,04:
quasi tutto ciò che è sotto è stato spianato dal suo padrone. Il rudere è **la porta
dell'archeologia**, non solo uno stato intermedio.

**2. Gli stessi punti si spostano sulla Rendita.** +2 edifici in piedi a fine partita, +4,5
cubetti di Vetustà, Rendita +15 per partita. Il punteggio totale sale di 4 e le vittorie vanno
alla strategia Rendita (46 %), mentre la Verticale scende sotto un quarto. Curioso: la strategia
Scavo vince di più (39 %) prendendo **meno** Scavo (2,7 punti contro 7,6): i suoi edifici, non
più ruderi, restano in piedi e pagano Rendita. Insegue un canale che non c'è più e vince per
un altro.

**3. Ogni fallimento fa rovina lascia l'equilibrio dov'è e raddoppia le morti premature.** I
canali stanno tutti entro un punto e le vittorie entro l'errore, ma gli edifici che cadono
nell'era in cui nascono passano dal 17 % al **48 %**, e a fine partita ne restano in piedi 7
invece di 9. È la stessa curva di `quanto-punisce-il-gioco.md` (soglia 2: 31 %), un gradino
più in là. Gli Scheletri perdono un quarto: meno edifici in piedi sotto cui seppellire.

## Cosa vuol dire per la proposta

Il punto 11 ("togliamo il rudere") **non è una semplificazione neutra**: la sua lettura
letterale (punto 9, ogni fallimento è rovina) rende il gioco molto più punitivo di quello che il
designer ha già giudicato troppo severo; la lettura morbida (rovina solo a −3) spegne il canale
dello Scavo, cioè metà del tema del gioco. La decisione da prendere è doppia, D15 e D16 insieme:

1. **la soglia** con un passo solo: 1, 2 o 3;
2. **se spianare un proprio edificio attivo conserva lo Scavo.** Oggi no. La proposta dice
   "sotterrato: attiva il valore di Scavo a fine gioco" senza distinguere chi l'ha sepolto: se
   vale anche per il proprio spianato, l'archeologia torna per un'altra porta. È una manopola da
   una riga (`was_razed`), e sarebbe la misura successiva.

Le manopole ci sono già tutte: `--senza_rudere 1 --gap 2` misura la soglia intermedia,
`--senza_rudere 1` con una manopola sullo spianamento misura la seconda domanda.

## Seconda misura: lo Scavo che non si azzera mai

Decisione del designer dopo la prima misura: gli stati sono attivo, rovina e sotterrato, e **lo
Scavo non si azzera mai**; poi il dubbio: "bisogna controllare se non si spinge troppo a
sotterrare i propri edifici e basta". E la variante: "gli edifici vivi spianati mettono lo Scavo
a zero, diventano terrapieni", che è la Spolia di oggi (spianare un proprio intatto sconta metà
della resistenza e vale Scavo 0). Manopola `spianare_conserva_scavo`, spenta nei dati
(`--scavo_spianato 1`); il bot, quando è accesa, smette di contare lo spianato come perso. Per
rispondere al dubbio il torneo conta per giocatore **su che basi** ha costruito (proprie,
altrui, propri intatti spianati) e la vita delle carte quanti edifici sono stati spianati dal
proprietario. Stessi semi e stessi lotti della prima misura, sei varianti:

| | rudere | soglia di rovina | spianato |
|---|---|---|---|
| **A** oggi | sì | 3 | Scavo 0 |
| **B** | no | 3 | Scavo 0 |
| **C** | no | 3 | vale |
| **D** | no | 2 | vale |
| **E** | no | 2 | Scavo 0 |
| **F** ogni fallimento fa rovina | no | 1 | vale |

### La vita degli edifici

| per partita | A oggi | B | C | D | E | F |
|---|--:|--:|--:|--:|--:|--:|
| in piedi a fine partita | 9,26 | 11,23 | 10,88 | 8,76 | 9,11 | 6,70 |
| cade nell'era in cui nasce | 17 % | 17 % | 18 % | 32 % | 32 % | 48 % |
| sepolti | 51 % | 50 % | 52 % | 52 % | 51 % | 53 % |
| **spianati dal proprietario** | **25 %** | 42 % | **44 %** | 35 % | 33 % | 25 % |
| Scavo per sepolto | 1,35 | 0,42 | 3,19 | 3,24 | 0,91 | 3,26 |
| PV delle carte | 205 | 209 | **255** | 249 | 211 | 233 |
| Rendita | 66 | 82 | 77 | 72 | 77 | 62 |
| Verticalità | 74 | 73 | 79 | 80 | 75 | 79 |
| Scavo | 20,5 | 6,5 | **51,7** | **52,0** | 13,9 | **51,4** |
| Lampo | 36 | 40 | 40 | 38 | 38 | 36 |
| Scheletri | 8,3 | 7,3 | 7,5 | 7,3 | 6,9 | 6,2 |

### Il torneo

| per giocatore | A oggi | B | C | D | E | F |
|---|--:|--:|--:|--:|--:|--:|
| PV medi | 85,7 | 88,9 | **104,8** | 101,6 | 89,1 | 94,7 |
| Scavo | 6,8 | 2,1 | 17,6 | 17,7 | 4,7 | 17,3 |
| Rendita | 22,1 | 27,2 | 25,5 | 24,0 | 25,6 | 20,5 |
| Verticalità | 25,1 | 24,5 | 26,5 | 26,8 | 25,2 | 26,2 |
| basi proprie | 4,2 | 5,0 | 5,4 | 5,0 | 4,6 | 4,4 |
| basi altrui | 2,0 | 1,1 | 1,1 | 1,6 | 1,6 | 2,1 |
| **propri intatti spianati** | **2,5** | 4,3 | **4,6** | 3,6 | 3,4 | 2,6 |
| vince Rendita | 41 % | 46 % | 47 % | 50 % | 44 % | 48 % |
| vince Scavo | 28 % | 39 % | 42 % | 42 % | 38 % | 38 % |
| vince Verticale | 31 % | 24 % | 27 % | 29 % | 23 % | 33 % |
| vince Bilanciata | 39 % | 31 % | 29 % | 33 % | 33 % | 33 % |
| vince Lampo | 27 % | 24 % | 23 % | 19 % | 25 % | 21 % |
| vince Obiettivi | 34 % | 37 % | 32 % | 28 % | 37 % | 29 % |

Su 750 partite una percentuale di vittoria ha ±5 punti: le differenze fra strategie entro
quella soglia sono rumore.

### Cosa salta all'occhio

**1. Il dubbio era fondato: con lo Scavo che vale, si seppellisce se stessi.** Già oggi un
edificio su quattro viene spianato dal suo proprietario (la Spolia è usata, non è una regola di
nicchia). Con lo Scavo conservato (C) diventano il 44 %, e nell'era 2 il **69 %** degli edifici
costruiti finisce spianato da chi lo ha costruito. Le basi altrui scendono da 2,0 a 1,1 per
giocatore: si costruisce sopra i propri, non sopra gli altri. Il motivo è che spianare il proprio
intatto dà tutto insieme: lo sconto della Spolia (metà della resistenza in pietra), il livello
di Verticalità **e** lo Scavo pieno. Il canale Scavo passa da 20 a **52 punti a partita**, più
del doppio, e il punteggio totale sale di 50: la partita cambia scala.

**2. La soglia non cambia questo esito.** C, D e F hanno tutte lo Scavo a 52: a soglia 3, 2 o 1
l'archeologia che vale la fanno gli spianamenti, non gli eventi. La soglia decide solo quanti
edifici muoiono giovani: 18 %, 32 %, 48 %.

**3. La variante del designer, spianato a zero e soglia 2 (E), è la più vicina al gioco di
oggi.** Edifici in piedi 9,1 contro 9,3, punteggio +5, Rendita +10, Verticalità e Lampo ferme,
vittorie entro l'errore. Paga due prezzi: lo Scavo scende da 20,5 a 13,9 (le rovine da evento
sono la sola archeologia che vale, e a soglia 2 ce ne sono meno di quante ne facevano i ruderi)
e il 32 % degli edifici cade nell'era in cui nasce, contro il 17 % di oggi. A soglia 3 (B) lo
Scavo sparisce; a soglia 1 con spianato a zero (misurato nella prima parte) lo Scavo resta a 22
ma muore il 48 %.

**4. Terrapieno o rovina non cambia i numeri.** Uno spianato a Scavo 0 e un terrapieno valgono
uguale nel conteggio; la differenza è solo in chi conta gli strati: Archeologo, Demolitore
("3+ tuoi spianati", che con lo Scavo conservato diventerebbe un premio gratis), Soprintendente,
e la metà della Verticalità divisa fra i proprietari degli strati. Da decidere a regolamento,
non da misurare.

### Cosa resta da decidere

- **Lo Scavo dello spianato.** A zero (la Spolia di oggi, la variante E) l'archeologia vale
  solo quando arriva dagli eventi; pieno, raddoppia il canale e premia chi seppellisce se
  stesso. C'è una via di mezzo da misurare, se interessa: **Scavo pieno ma senza lo sconto
  della Spolia** (spianare costa quanto costruire su una rovina altrui), oppure Scavo dimezzato.
- **La soglia.** Con lo spianato a zero è la soglia a fare l'archeologia: 2 è il compromesso
  fra Scavo e morti premature; il punto 10 della proposta (sconto pari a metà della resistenza
  della rovina) rende le rovine altrui più appetibili e potrebbe spostare le basi dai propri
  agli altrui. Si misura quando i costi della v2 esistono.

## Terza misura: perché costruire sopra gli altri

Il designer: "dobbiamo evitare che un giocatore costruisca sempre sui suoi edifici in rovina;
quale motivo lo spingerebbe a costruire sugli altrui?", con il timore che "l'ultimo che
costruisce sopra prende tutto il bottino, la mossa finale è un kingmaker". Due leve, misurate
sulla base scelta (senza rudere, soglia 2, spianato a Scavo 0):

- **lo Scavo a chi scava** (`scavo_a_chi_scava`, `--scavo_scava 1`): chi completa la sepoltura
  di un edificio altrui ne incassa lo Scavo; il proprio sepolto da sé vale 0. Il motore ora
  registra chi ha sepolto chi e in che era (`Building.buried_by`, `buried_era`);
- **lo sconto macerie solo sulle rovine altrui** (`sconto_macerie_solo_altrui`,
  `--sconto_altrui 1`): la pietra di sconto di oggi non vale sulle proprie.

Il torneo conta per giocatore le basi proprie, le altrui, gli spianati, e quanto Scavo si
incassa scavando e quanto di quello nell'era 5.

| per giocatore | oggi | E: base | E + Scavo a chi scava | E + sconto solo altrui | tutte e due |
|---|--:|--:|--:|--:|--:|
| basi proprie | 4,2 | 4,6 | **3,5** | 4,4 | 3,4 |
| **basi altrui** | **2,0** | 1,6 | **1,7** | 1,7 | 1,8 |
| propri intatti spianati | 2,5 | 3,4 | 2,7 | 3,3 | 2,7 |
| costruiti sopra un altro | 5,1 | 5,2 | **4,4** | 5,2 | 4,4 |
| altezza massima | 3,9 | 3,9 | **3,5** | 3,9 | 3,5 |
| PV medi | 85,7 | 89,1 | 86,6 | 88,8 | 86,7 |
| Verticalità | 25,1 | 25,2 | **21,3** | 25,2 | 21,2 |
| Rendita | 22,1 | 25,6 | 28,7 | 25,6 | 28,8 |
| Scavo | 6,8 | 4,7 | 3,1 | 4,6 | 3,3 |
| vince Rendita | 41 % | 44 % | **53 %** | 42 % | 54 % |
| vince Lampo | 27 % | 25 % | **16 %** | 26 % | 16 % |

Per partita (vita delle carte): sepolti da un altro 15 % → 17 % con lo Scavo a chi scava, in
piedi a fine partita 9,1 → 10,1, Verticalità 75 → 63, Scavo 13,9 → 9,5, Rendita 77 → 86.

### Cosa salta all'occhio

**1. Nessuna delle due leve porta a costruire sugli altri.** Le basi altrui restano fra 1,6 e
1,8 per giocatore, sotto le 2,0 di oggi. Lo Scavo a chi scava ottiene l'altra metà del
desiderio, smettere di seppellire se stessi (basi proprie 4,6 → 3,5, spianati 3,4 → 2,7), ma
non lo trasforma in sepolture altrui: si costruisce **meno sopra**, le colonne si fermano
mezzo livello più in basso e la Verticalità perde 4 punti a giocatore. Il gioco scivola verso la
Rendita (vince il 53 %) e il Lampo crolla. Lo sconto di una pietra non muove nulla: è una leva
troppo piccola.

**2. Il motivo è strutturale, e non è lo Scavo.** Costruire nella colonna di un altro divide la
Verticalità: metà del premio va a chi ha la cima, l'altra metà si spartisce fra **tutti** i
proprietari degli strati, sotterrati compresi. Nella propria colonna il premio è tutto proprio.
Con la Verticalità al 34 % dei punti, il primo canale del gioco dice "sali sul tuo". A questo si
aggiungono la Continuità di classe (nella propria colonna) e la geometria: un livello per era
per colonna. Finché il premio della colonna si divide con chi sta sotto, nessuno Scavo basta.

**3. Il kingmaker, con i numeri.** Con lo Scavo a chi scava il 40 % dello Scavo scavato arriva
nell'era 5, ma sono 1,3 punti a giocatore; il vincitore ha scavato nell'era 5 nel 54 % delle
partite, e il suo bottino dell'ultima era supera il suo distacco dal secondo nel **6 %**;
togliendo a tutti lo Scavo dell'era 5 il vincitore cambierebbe nel **2 %** delle partite, con
un distacco mediano di 18 punti. Il rischio esiste ma è piccolo, perché il canale è piccolo:
tornerebbe grande se lo Scavo tornasse grande.

### Cosa proporre

La leva da provare è **il premio della colonna**: la Verticalità non si divide con gli strati
sotto (tutto a chi ha la cima), o si divide solo fra chi ha costruito **sopra** qualcun altro.
Così salire sulla colonna altrui non regala punti a chi sta sotto, e lo Scavo a chi scava
diventa un motivo in più invece che l'unico. È una manopola sul conteggio, da misurare a
parità di semi; il costo è che il timore del kingmaker si sposta lì, e va rimisurato.

## Quarta misura: via la Verticalità, il premio di scavo al suo posto

Il designer: "toglierei proprio la Verticalità: si prendono punti per lo Scavo, e più le pile
sono alte più dovremmo premiare chi sta in quella pila". La formulazione scelta: **chi
costruisce al livello L sopra un edificio con Scavo S lo incassa subito**, come il Lampo; il
proprietario dell'edificio sepolto tiene lo Scavo stampato a fine partita come oggi. Manopola
`premio_scavo` ("nessuno" nei dati, `--premio …`), con i tre moltiplicatori chiesti: S×L, S+L,
S×(L−1). Lo spianato (S 0) non paga. Verticalità a zero con la manopola che c'era già
(`--verticalita 0,0,0,0`); base: senza rudere, soglia 2, spianato a zero. Il bot conta il premio
quasi per intero e non conta più l'altezza, quindi gioca la regola che misura.

| per giocatore | base | senza Verticalità | + premio S×L | + premio S+L | + premio S×(L−1) |
|---|--:|--:|--:|--:|--:|
| PV medi | 89,1 | **65,7** | 74,6 | 70,4 | 72,3 |
| Verticalità | 25,2 | 0 | 0 | 0 | 0 |
| Scavo | 4,7 | 4,6 | **19,6** | 15,6 | 13,0 |
| Rendita | 25,6 | 28,8 | 22,5 | 22,0 | 26,5 |
| costruiti sopra un altro | 5,2 | **4,4** | 5,7 | 5,9 | 4,8 |
| altezza massima | 3,9 | **3,1** | 4,1 | 4,1 | 3,7 |
| basi proprie | 4,6 | 4,0 | 5,0 | 5,2 | 4,2 |
| **basi altrui** | 1,6 | **1,0** | **2,0** | 2,0 | 1,7 |
| propri intatti spianati | 3,4 | 2,5 | 3,7 | 3,9 | 3,0 |
| premio incassato scavando | 0 | 0 | 14,8 | 10,7 | 8,3 |
| di cui nell'era 5 | 0 | 0 | 7,1 (48 %) | 4,5 (42 %) | 4,9 (60 %) |
| vince Rendita | 44 % | 32 % | 37 % | 39 % | 38 % |
| vince Lampo | 25 % | **35 %** | 29 % | 27 % | 27 % |
| vince Scavo | 38 % | 42 % | 29 % | 36 % | 33 % |
| vince Bilanciata | 33 % | 29 % | 38 % | 37 % | 37 % |

Per partita (vita delle carte): sepolti 51 % → 43 % senza Verticalità → 52 / 54 / 47 % con i tre
premi; sepolti da un altro 15 % → 10 % → 19 / 18 / 17 %; in piedi a fine partita 9,1 → 9,9 →
8,4 / 8,3 / 9,3; il canale Scavo 13,9 → 13,7 → 59,6 / 47,7 / 38,6 punti a partita, contro i 74,9
della Verticalità tolta.

**Il kingmaker, misurato** (torneo, 750 partite): quanto del premio arriva nell'era 5, in quante
partite il bottino dell'ultima era del vincitore supera il suo distacco dal secondo, e in quante
il vincitore cambierebbe togliendo a tutti il premio dell'era 5.

| | S×L | S+L | S×(L−1) |
|---|--:|--:|--:|
| premio nell'era 5 | 48 % | 42 % | 60 % |
| bottino dell'era 5 del vincitore ≥ distacco | **31 %** | 22 % | 27 % |
| senza l'era 5 cambierebbe il vincitore | **17 %** | **11 %** | 16 % |
| bottino massimo visto in un'era 5 | 50 | 28 | 33 |
| distacco mediano primo-secondo | 16 | 14 | 13 |

Con lo Scavo a chi scava della terza misura erano 6 % e 2 %.

### Cosa salta all'occhio

**1. Senza rimpiazzo la città si appiattisce.** Verticalità a zero e basta: −23 punti a
giocatore, altezza massima da 3,9 a 3,1, basi altrui a 1,0, sepolti dal 51 % al 43 %. Vince chi
costruisce e basta (Lampo 35 %). Il premio della colonna era il motore del salire.

**2. S×L rimette in piedi la città e porta le basi altrui al livello di oggi.** Altezza 4,1
(sopra la base), sepolti 52 %, sepolti da un altro 19 %, basi altrui 2,0 come nel gioco di oggi
e sopra la base senza rudere (1,6). Il canale Scavo vale 19,6 a giocatore, tre quarti della
Verticalità tolta; il totale resta 14 punti sotto. Ma è neutro, non parziale: crescono anche le
basi proprie (5,0) e gli spianati (3,7), perché la propria rovina sepolta da sé paga quanto
quella altrui. La quota di basi altrui sul totale passa dal 26 % della base al 29 %, contro il
32 % di oggi.

**3. Il kingmaker c'è, ed è grosso quanto il premio.** Con S×L quasi metà del premio arriva
nell'era 5, l'ultima mossa sulle pile alte vale fino a 50 punti, e in una partita su sei il
vincitore cambierebbe senza il bottino dell'ultima era. S+L lo dimezza (11 %) al prezzo di un
canale più piccolo (15,6). S×(L−1) è il peggiore in rapporto: paga poco e tardi (60 % nell'era
5), perché il primo livello non vale nulla e le pile alte arrivano alla fine.

**4. La strategia Scavo perde proprio quando lo Scavo vale.** Da 38 % a 29 % con S×L: insegue
lo Scavo di chi viene sepolto (la regola vecchia), non il premio di chi scava. Le strategie
dei bot vanno riscritte per la v2, e questa è la prima riga della lista.

### Cosa proporre

- **S×L come scala**, con una correzione all'ultima era da misurare: premio dimezzato nell'era
  5, oppure premio solo fino all'era 4 (l'era Moderna, che non ha evento, non seppellisce con
  premio). Sono due manopole da una riga.
- **S+L** se si preferisce un canale più piccolo e un finale più tranquillo, senza correzioni.
- Il totale dei punti scende di 14-19 a giocatore: se si vuole tornare alla scala di oggi, il
  premio si moltiplica (S×L×1,5) o si alza lo Scavo stampato delle carte tarde.

## Come rifare il conto

I lotti sono stati giocati il 24 settembre 2026 sul ramo `claude/niente-rudere` (main a
`d56bb94` più le manopole). Con gli stessi comandi del metodo escono identici, riga per riga:

```bash
A="--players 3 --vita 2000 --seed 200000"   # o --games 750 --seed 700000 per il torneo
godot --headless res://scenes/audit_partita.tscn -- $A > A.csv
godot --headless res://scenes/audit_partita.tscn -- $A --senza_rudere 1 > B.csv
godot --headless res://scenes/audit_partita.tscn -- $A --senza_rudere 1 --scavo_spianato 1 > C.csv
godot --headless res://scenes/audit_partita.tscn -- $A --senza_rudere 1 --gap 2 --scavo_spianato 1 > D.csv
godot --headless res://scenes/audit_partita.tscn -- $A --senza_rudere 1 --gap 2 > E.csv
godot --headless res://scenes/audit_partita.tscn -- $A --gap 1 --scavo_spianato 1 > F.csv
python3 tools/confronta_vita.py A.csv B.csv C.csv D.csv E.csv F.csv      # lotti --vita
python3 tools/confronta_torneo.py A.csv B.csv C.csv D.csv E.csv F.csv    # lotti --games
# terza misura, sulla base E:
godot --headless res://scenes/audit_partita.tscn -- $A --senza_rudere 1 --gap 2 --scavo_scava 1 > E1.csv
godot --headless res://scenes/audit_partita.tscn -- $A --senza_rudere 1 --gap 2 --sconto_altrui 1 > E4.csv
# quarta misura: Verticalita' a zero e il premio di scavo
V="--senza_rudere 1 --gap 2 --verticalita 0,0,0,0"
godot --headless res://scenes/audit_partita.tscn -- $A $V > V.csv
godot --headless res://scenes/audit_partita.tscn -- $A $V --premio per_livello > P1.csv
godot --headless res://scenes/audit_partita.tscn -- $A $V --premio piu_livello > P2.csv
godot --headless res://scenes/audit_partita.tscn -- $A $V --premio per_livello_meno_uno > P3.csv
```
