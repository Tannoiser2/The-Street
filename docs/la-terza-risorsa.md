# La terza risorsa: la v2 gioca sullo stesso motore

> Prima misura con i **dati nuovi**: `data/cards-v2.json`, generato da `tools/genera_cards_v2.py`
> dalla v1.5 e dalla tabella dei costi in tre risorse approvata dal designer
> (`carte-v2.md`, le regole dei costi: le Idee sostituiscono, esplodono nelle ere 4-5). Le tessere
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

## Quinta misura: quattro lavoratori che attivano e poi agiscono

Decisione del designer dopo la quarta misura (registro 94): il turno resta quello della v1.5, il
lavoratore attiva la colonna e poi si costruisce, potenzia o ristruttura lì o accanto; i
lavoratori diventano **quattro**; il Personaggio resta quello del draft. Il file v2 spegne
`turno_v2` (che resta come manopola) e porta `workers_base` a 4. Tre lotti sugli stessi semi:
S (il lotto v2 di riferimento: tre lavoratori, Reclutare come azione), U3 (tre lavoratori e il
draft, il controllo che isola il draft) e U4 (quattro lavoratori e il draft, la v2 di oggi):

| per giocatore | S v2 di riferimento | U3 3 lavoratori + draft | **U4 4 lavoratori + draft** |
|---|--:|--:|--:|
| PV medi | 74,3 | 87,0 | **97,1** |
| Rendita | 18,7 | 23,5 | 27,9 |
| Lampo | 15,3 | 16,8 | 19,2 |
| Scavo | 17,0 | 15,1 | 15,6 |
| Continuità | 10,3 | 11,2 | 12,9 |
| Scheletri | 1,8 | 5,8 | 4,6 |
| costruiti | 10,8 | 11,7 | 13,6 |
| costruiti sopra un altro | 5,8 | 5,7 | 6,1 |
| altezza massima | 4,09 | 4,11 | 4,24 |
| basi proprie / altrui | 5,0 / 2,3 | 5,2 / 2,1 | 5,5 / 2,2 |
| premio incassato scavando | 11,5 | 9,9 | 10,4 |
| Idee prodotte / spese | 11,6 / 9,7 | 12,9 / 11,6 | 16,4 / 14,2 |
| senza l'era 5 cambierebbe il vincitore | 11 % | 11 % | 11 % |
| vince Rendita / Lampo / Bilanciata | 35 / 28 / 37 % | 44 / 23 / 38 % | **47** / 23 / 38 % |

Per partita (2 000 `--vita`, S contro U4): costruiti 32,4 → 40,9; in piedi a fine partita 9,5 →
14,6; cade nell'era in cui nasce 33 → 33 %; sepolti 54 → 44 %; sepolti da un altro 21 → 15 %;
spianati dal proprietario 33 → 27 %; Scavo per sepolto 2,96 → 2,66; Scheletri 5,7 → 14,1.

**1. La v2 torna una partita intera.** 13,6 edifici e 97 punti a giocatore, la città alta 4,2 con
le basi altrui a 2,2 come nella v2 di riferimento: il quarto lavoratore rimette in piedi tutto
quello che il turno a un'azione aveva spento, e l'archeologia riparte (premio scavato 10,4,
kingmaker fermo all'11 %). Si costruisce di più e si seppellisce di meno (44 % contro 54 %):
con quattro turni per era conviene più allargare che coprire.

**2. Il draft da solo vale 13 punti.** U3 contro S: +4 Scheletri (il Personaggio gratis
seppellito vale 6 meno l'era), +5 Rendita, +2,4 Cultura (i "+1 cultura" dei Personaggi presi
ogni era). Non è il quarto lavoratore, è il regalo: un Personaggio a testa per era senza pagare
nulla. Da decidere se il Personaggio del draft si seppellisce ancora a fine era.

**3. La Rendita domina.** Vince il 47 % delle partite (atteso 33, errore 5), il Lampo scende al
23 %. Quattro attivazioni per era pagano più censimenti a chi tiene in piedi gli edifici (Rendita
27,9 contro 18,7), e la Rendita è già il canale più grosso. Il Lampo, che vince costruendo,
paga di più il ritmo: il mercato scorre più in fretta e le carte a Lampo alto finiscono a tutti.
È il primo squilibrio da correggere nella v2 a quattro lavoratori: la Vetustà (24 cubetti a
partita contro 17) è la prima manopola da provare, perché è quella che gonfia la Rendita.

**4. Le Idee bastano ancora.** Prodotte 16,4, spese 14,2 (87 %): con quattro attivazioni le
Idee crescono, e si spendono. Il tetto a 3 non morde.

## Sesta misura: niente Personaggi sepolti, niente Vetustà, lo scheletro del potenziamento

Tre decisioni del designer (registro 95): il Personaggio del draft **non si seppellisce**; la
**Vetustà non esiste più** ("non mi è mai piaciuta, semplifichiamo": tetto a 0, il motore non
cambia); gli scheletri ci sono e li lascia **il lavoratore che piazza un potenziamento**, che
resta sotto l'edificio, uno per edificio, non nell'era Moderna, e vale 6 meno l'era se
l'edificio finisce sotterrato. Sulla base U4 (quattro lavoratori e draft), stessi semi, una
decisione alla volta:

| per giocatore | U4 | Va senza sepolture | Vb + senza Vetustà | **W + scheletro del potenziamento** |
|---|--:|--:|--:|--:|
| PV medi | 97,1 | 92,5 | 79,0 | **81,3** |
| Rendita | 27,9 | 27,9 | 10,6 | 10,3 |
| Lampo | 19,2 | 19,2 | 20,8 | 20,7 |
| Scavo | 15,6 | 15,6 | 17,4 | 17,4 |
| Scheletri | 4,6 | 0 | 0 | **2,8** |
| costruiti | 13,6 | 13,6 | 14,2 | 14,0 |
| altezza massima | 4,24 | 4,24 | 4,66 | 4,64 |
| basi proprie / altrui | 5,5 / 2,2 | 5,5 / 2,2 | 6,4 / 2,3 | 6,3 / 2,3 |
| premio incassato scavando | 10,4 | 10,4 | 12,2 | 12,2 |
| senza l'era 5 cambierebbe il vincitore | 11 % | 9 % | 16 % | 15 % |
| vince Rendita / Lampo / Bilanciata | 47 / 23 / 38 % | 48 / 24 / 36 % | 54 / 22 / 30 % | **56** / 26 / 33 % |

Per partita (2 000 `--vita`, U4 → W): costruiti 40,9 → 41,9; in piedi a fine partita 14,6 →
13,7; sepolti 44 → 49 %; spianati dal proprietario 27 → 32 %; cubetti Vetustà 24,1 → 0;
Rendita 83 → 31; Scheletri 14,1 → 8,5.

**1. Le sepolture del draft erano solo punti regalati.** Va contro U4: identico in tutto, meno
4,6 punti di Scheletri. I bot non giocavano intorno ai Personaggi da seppellire, quindi la
regola non cambiava la partita: la toglie e basta.

**2. La Vetustà era due terzi della Rendita.** Vb contro Va: la Rendita scende da 27,9 a 10,6,
la partita da 92 a 79 punti. Senza cubetti si tiene meno agli edifici vecchi: si costruisce di
più sopra (altezza 4,66, sepolti 49 %), il premio di scavo sale a 12,2 e il kingmaker
dell'ultima era torna al 15-16 %, perché il premio pesa di più su un totale più basso.

**3. La Rendita domina ancora di più, e non è la Vetustà.** La strategia Rendita vince il 54-56
% delle partite (atteso 33, errore 5) con 8 punti di vantaggio: senza cubetti la sua Rendita
è 23,6 contro 8-11 delle altre. Il motivo è la protezione: quattro lavoratori proteggono
quattro edifici per era (+2), e chi costruisce edifici a Rendita alta e li tiene in piedi
incassa quattro censimenti. La prossima manopola è la protezione (`protection_bonus` 2, oggi
per ogni lavoratore) o il censimento; la Vetustà non c'entrava.

**4. Lo scheletro del potenziamento vale 2,8 punti a giocatore** (8,5 a partita), poco più
della metà di quello che valevano i Personaggi sepolti, e non cambia la forma della città.

## Settima misura: la protezione a +1, e quanto valgono gli scheletri

Due domande del designer sulla base W (la v2 di oggi: quattro lavoratori, draft, niente
sepolture, niente Vetustà, scheletro del potenziamento): la protezione del lavoratore a +1
invece di +2 (`--protezione 1`), contro la Rendita che vince il 56 %; e se gli scheletri
sono un valore aggiunto o vanno valorizzati di più. Per la seconda una prova: lo scheletro
**conta sempre** (`--scheletro sempre`, costante `scheletro_conta`), cioè paga 6 meno l'era
comunque finisca l'edificio, non solo se viene sotterrato. Stessi semi:

| per giocatore | W | X1 protezione +1 | X2 protezione +1, scheletro conta sempre |
|---|--:|--:|--:|
| PV medi | 81,3 | 81,0 | **86,5** |
| Rendita | 10,3 | 10,0 | 9,7 |
| Lampo | 20,7 | 20,7 | 20,4 |
| Scavo | 17,4 | 17,8 | 17,2 |
| Scheletri | 2,8 | 2,8 | **9,6** |
| costruiti | 14,0 | 14,0 | 13,7 |
| potenziamenti per giocatore | n.d. | 2,8 | 3,4 |
| altezza massima | 4,64 | 4,64 | 4,58 |
| basi proprie / altrui | 6,3 / 2,3 | 6,2 / 2,4 | 6,1 / 2,4 |
| senza l'era 5 cambierebbe il vincitore | 15 % | 16 % | 13 % |
| vince Rendita / Lampo / Continuità | 56 / 26 / 32 % | 54 / 21 / 32 % | 53 / 22 / 37 % |

Per partita (2 000 `--vita`, W → X1): costruiti 41,9 → 42,0; in piedi a fine 13,7 → 13,3; cade
nell'era in cui nasce 35 → 35 %; sepolti 49 → 49 %; Scheletri 8,5 → 8,4.

**1. La protezione non c'entra.** X1 contro W: stessi punti, stessa città, stessa vita delle
carte, la Rendita vince ancora il 54 %. La strategia Rendita costruisce meno edifici (12
contro 14-17) ma cari e duraturi, con la Rendita stampata alta (22 punti contro 8-11 delle
altre), e con quattro lavoratori le risorse per comprarli ci sono sempre (Idee spese 14 su
16). È un fatto delle carte, non del lavoratore: la prossima manopola è il valore di Rendita
delle carte care, o il censimento.

**2. Gli scheletri oggi contano poco.** 2,8 punti a giocatore, il 3 % del totale: circa tre
potenziamenti a partita a testa, e lo scheletro paga solo se l'edificio finisce sotterrato
(la metà dei casi). Non sono un motivo per potenziare: il potenziamento si sceglie per il
suo effetto, lo scheletro è un resto.

**3. Se lo scheletro conta sempre, diventa una scelta.** X2: 9,6 punti a giocatore, l'11 %
del totale; i potenziamenti passano da 2,8 a 3,4 a giocatore (la strategia Rendita ne fa
4,5), la città non cambia (altezza 4,58, basi altrui 2,4), nessuna strategia si deforma, e
il kingmaker dell'ultima era scende dal 16 al 13 % perché il premio pesa su un totale più
alto. Un lavoratore che diventa 6 meno l'era di punti sicuri è una decisione vera, e
premia chi potenzia presto. Raccomandato: **conta sempre**.

## Ottava misura: la Rendita delle carte care

Decisione del designer (registro 96): lo scheletro **conta sempre**, nel file v2. Poi la prova
chiesta: la Rendita stampata delle carte care, contro la strategia Rendita che vince il 57 %.
Manopola `--rendita_tetto N`: la Rendita di ogni carta si taglia a N. A 2 si toccano cinque
carte (Abbazia, Castello, Fortezza bastionata, Ponte monumentale da 3, Duomo da 4); a 1 otto
(anche Anfiteatro, Chiesa e Piazza monumentale da 2).
Stessi semi, base Z (la v2 di oggi):

| per giocatore | W (scheletro da sotterrato) | **Z scheletro conta sempre** | Y2 Rendita al massimo 2 | Y1 Rendita al massimo 1 |
|---|--:|--:|--:|--:|
| PV medi | 81,3 | 87,0 | 85,6 | 84,1 |
| Rendita | 10,3 | 9,9 | 7,8 | 4,9 |
| Lampo | 20,7 | 20,4 | 20,7 | 21,4 |
| Scavo | 17,4 | 16,7 | 17,5 | 18,0 |
| Scheletri | 2,8 | **10,0** | 9,8 | 9,9 |
| costruiti | 14,0 | 13,6 | 13,7 | 13,8 |
| potenziamenti per giocatore | n.d. | 3,6 | 3,5 | 3,5 |
| altezza massima | 4,64 | 4,57 | 4,59 | 4,60 |
| basi proprie / altrui | 6,3 / 2,3 | 6,1 / 2,3 | 6,1 / 2,4 | 6,2 / 2,4 |
| senza l'era 5 cambierebbe il vincitore | 15 % | 12 % | 13 % | 17 % |
| vince Rendita | 56 % | **57 %** | 49 % | 44 % |
| vince Obiettivi / Bilanciata / Continuità | 29 / 33 / 32 % | 32 / 33 / 36 % | 35 / 36 / 33 % | 37 / 33 / 34 % |
| vince Lampo / Scavo | 26 / 24 % | 25 / 17 % | 25 / 22 % | 30 / 21 % |

Per strategia in Z: la Rendita fa 94,6 punti con 21,3 di Rendita, 12,0 di Scheletri (4,9
potenziamenti) e 11,5 edifici; le altre 80-87 con 3-11 di Rendita e 14-16 edifici. Per partita
(2 000 `--vita`, W → Z): Scheletri 8,5 → 29,8, tutto il resto uguale (costruiti 41, sepolti 49 %).

**1. Lo scheletro che conta sempre fa quello che prometteva.** Z contro W: +7 punti di
Scheletri a giocatore, 3,6 potenziamenti a testa, città identica, kingmaker al 12 %.

**2. La Rendita delle carte care conta, ma non è tutto.** Tagliando a 2 la strategia Rendita
scende dal 57 al 49 %, tagliando a 1 al 44 %: ancora 11 sopra l'atteso, con il canale Rendita
ridotto a 5 punti su 84, cioè quasi cancellato. Il resto del vantaggio non è la Rendita: è lo
**stile** di quella strategia, meno edifici (11,5 contro 14-16) e più potenziamenti (4,9 contro
2,7-3,8), che con lo scheletro che conta sempre valgono 12 punti. Con quattro lavoratori e le
risorse che bastano, costruire poco e bene batte costruire tanto.

**3. La Scavo è la strategia debole**, 17-22 % e 80 punti: passa il doppio delle altre (6,8 turni
di solo incasso) e costruisce poco. Non è una regola da cambiare, è il bot da ritarare quando
il canone della v2 si chiude.

**4. Da decidere.** Se la Rendita delle cinque carte care scende a 2 (Y2: un cambio piccolo,
cinque righe in `carte-v2.md`), la forbice si stringe di 8 punti senza toccare la città; il
resto è taratura dei bot, non regola.

## Nona misura: le carte care a 2 e le strategie rifatte per la v2

Decisioni del designer (registro 97-98): le cinque carte care scendono a Rendita 2 nel file v2, e
le strategie si rifanno. Le spinte delle strategie sono ora una tabella nel bot (una per la
v1.5, una per la v2) e la manopola `--spinta chiave=valore,...` le sovrascrive lotto per lotto:
tre giri di quattro tornei sugli stessi semi, poi la tabella scelta si scrive nel bot e il lotto
rigiocato senza manopola esce identico riga per riga.

**Il primo giro** (spinta della Rendita più bassa, la Scavo che costruisce a terra le carte con lo
Scavo alto invece di passare) ha dato la risposta sbagliata nel verso giusto: la Scavo dal 22 al
32 %, ma la Rendita **più forte** (95 punti, 54-56 %) con la spinta a 0,6 o 0,4. Quindi il
vantaggio non era la spinta: era il valutatore comune, che stima le rendite future di un edificio
come se restasse scoperto, mentre con quattro lavoratori quasi ogni edificio che conta viene
protetto; la strategia Rendita vinceva perché ci credeva più del valutatore. **Il secondo giro**
mette nel valutatore una protezione attesa (+1 o +2 di resistenza nel conto delle rendite): a +2
la Rendita scende al 40 % senza toccare la sua spinta. **Il terzo giro** (Lampo più morbido,
Rendita a 0,7) non migliora niente: il Lampo resta il più debole perché le sue carte costano poco
e cadono, non per la spinta.

| strategia | Z (la v2 prima) | B0 carte care a 2 | **F carte a 2 e strategie rifatte** | PV medi in F |
|---|--:|--:|--:|--:|
| Rendita | 57 % | 49 % | **40 %** | 88,6 |
| Obiettivi | 32 % | 35 % | 37 % | 86,7 |
| Scavo | 17 % | 22 % | **32 %** | 87,3 |
| Bilanciata | 33 % | 36 % | 32 % | 85,6 |
| Continuità | 36 % | 33 % | 31 % | 86,6 |
| Lampo | 25 % | 25 % | 27 % | 85,9 |

Attesa 33,3 %, errore ±5. La città non cambia (F contro Z: costruiti 13,8, altezza 4,57, basi
altrui 2,3, sepolti 47 %, kingmaker 11 %), e i punti nemmeno (86,8 contro 87,0): la taratura
cambia chi vince, non come si gioca.

La tabella v2 (`StrategyBot.SPINTE_V2`): protezione attesa 2; la Scavo a terra −0,5 invece di
−1,5, più 0,5 per punto di Scavo della carta; il resto come nella v1.5. La Rendita a 40 e il
Lampo a 27 restano un po' fuori dall'errore: la forbice si è chiusa da 57-17 a 40-27, e il
resto è la natura delle carte (la Rendita costruisce poco e caro, il Lampo tanto e fragile).

## Decima misura: le tessere una volta per era, via il disturbo, più Lampo a otto carte

Tre decisioni del designer (registro 100). **Le tessere** (punto 6 della proposta, D20-D22): la
produzione per era resta, l'abilità permanente diventa un effetto che scatta una volta per era
alla prima occasione, poi la tessera si gira e si rigira a inizio era (`tessere_una_volta_per_era`,
`--tessere 0` la spegne): pianura −1 Costruzione a una carta da 2 o 3 caselle, fiume +1 Denaro a
chi la attiva, collina +1 resistenza per l'era al primo edificio costruito qui, bosco −1
Costruzione a una ristrutturazione. **Via il "+1 per il disturbo"**, mai contato: il lotto di
riferimento v1.5 esce identico. **Più Lampo** (+1) a otto carte a solo Lampo (Insulae, Emporio,
Borgo, Torre civica, Loggia, Banco, Condominio, Officina), per la strategia Lampo che era la più
debole. Stessi semi, una decisione alla volta:

| per giocatore | F la v2 di prima | Ga Lampo +1, tessere permanenti | **Gb + tessere una volta per era** |
|---|--:|--:|--:|
| PV medi | 86,8 | 89,1 | 89,0 |
| Lampo | 19,4 | 22,1 | 22,2 |
| Rendita / Scavo / Scheletri | 9,9 / 16,4 / 10,2 | 9,8 / 16,6 / 9,9 | 9,6 / 16,7 / 9,8 |
| costruiti | 13,8 | 14,0 | 14,0 |
| altezza massima | 4,57 | 4,59 | 4,57 |
| basi proprie / altrui | 6,0 / 2,3 | 6,1 / 2,3 | 6,1 / 2,4 |
| senza l'era 5 cambierebbe il vincitore | 11 % | 15 % | 14 % |
| vince Rendita / Lampo | 40 / 27 % | 38 / 24 % | 37 / 23 % |
| vince Obiettivi / Scavo / Bilanciata / Continuità | 37 / 32 / 32 / 31 % | 41 / 33 / 30 / 34 % | 36 / 36 / 34 / 35 % |

Per partita (2 000 `--vita`, F → Gb): costruiti 41,5 → 42,1; in piedi a fine 14,0 → 13,6; sepolti
47 → 47 %; Lampo 58 → 67; il resto uguale.

**1. Le tessere una volta per era non cambiano la partita.** Gb contro Ga: stessi punti, stessa
città, stesse vittorie entro l'errore. È il risultato giusto: l'effetto una tantum toglie una
regola permanente che pesava poco (uno sconto, un +1) e mette al suo posto una scelta di
tempo (chi attiva per primo il fiume prende il Denaro), senza spostare l'economia. Le tessere
hanno ora un motivo per essere pescate a caso: cambiano dove conviene andare per primi.

**2. Più Lampo a otto carte alza il Lampo di tutti, non della strategia Lampo.** Ga contro F:
+2,7 punti di Lampo a giocatore per ogni strategia, perché quelle otto carte le costruiscono
tutti; la strategia Lampo passa da 29,5 a 33 di Lampo ma resta ultima (86,7 punti contro 88-91),
al 23-24 % di vittorie. Il suo problema non è il valore delle carte: è che costruisce 16 edifici
a bassa resistenza che cadono (Rendita 3, Scheletri 8, contro 9-16 e 10 delle altre). Le otto
carte restano a +1 come deciso; se il Lampo deve vincere di più, la strada è il bot (che
potenzi e protegga come gli altri), non le carte.

## Undicesima misura: la strategia Lampo potenzia

Dopo la decima misura (alzare il Lampo delle carte alza il Lampo di tutti) il designer ha detto di
andare avanti sul bot (registro 101). Due spinte nuove nella tabella delle strategie, solo per la
Lampo: `lampo_potenzia` (ai potenziamenti, che con lo scheletro che conta sempre sono punti
sicuri) e `lampo_sopra` (al costruire sopra). Quattro tornei con `--spinta`, stessi semi:

| strategia | Gb (prima) | potenzia 1,5 | **potenzia 3** | potenzia 1,5 + sopra 1,5 | potenzia 3 + sopra 1,5 |
|---|--:|--:|--:|--:|--:|
| Rendita | 37 % | 38 % | 38 % | 38 % | 38 % |
| Obiettivi | 36 % | 34 % | 33 % | 34 % | 34 % |
| Scavo | 36 % | 33 % | 30 % | 36 % | 32 % |
| Bilanciata | 34 % | 34 % | 34 % | 34 % | 34 % |
| Continuità | 35 % | 35 % | 34 % | 33 % | 34 % |
| Lampo | 23 % | 27 % | **31 %** | 25 % | 28 % |
| la Lampo: PV, Lampo, Scheletri, potenziamenti | 86,7 / 33 / 8,2 / 2,5 | 87,9 / 32 / 9,7 / 3,1 | **90,0 / 31 / 11,1 / 3,6** | 87,7 / 32 / 9,2 / 3,0 | 88,7 / 32 / 10,2 / 3,4 |

La tabella v2 prende `lampo_potenzia` 3 e lascia `lampo_sopra` a 0 (H, il lotto rigiocato con
la tabella scritta nel bot, è identico riga per riga a quello della manopola). Per giocatore la
partita non cambia (89,0 → 89,3 punti, costruiti 14,0 → 13,9, altezza 4,57 → 4,56, basi altrui
2,4); per partita (2 000 `--vita`) Scheletri 29,5 → 31,1, il resto uguale.

**1. Sei strategie entro l'errore, per la prima volta.** Rendita 38, Continuità 34, Bilanciata 34,
Obiettivi 33, Lampo 31, Scavo 30: tutte fra 30 e 38 con l'atteso a 33 e l'errore a 5. La Lampo
resta la Lampo (31 punti di Lampo, 15 edifici) e aggiunge il canale che le mancava.

**2. Costruire sopra non era il problema.** Le due varianti con `lampo_sopra` non aiutano: la
Lampo costruisce già sopra quanto gli altri (2,1-2,2 basi altrui). Quello che non faceva era
potenziare, perché il suo valutatore preferiva sempre una carta nuova a un potenziamento; ora,
con lo scheletro che conta sempre, la spinta la porta a 3,6 potenziamenti a partita.

## Dodicesima misura: la v2 a 2 e a 4 giocatori

Tutte le misure fin qui sono a tre giocatori. Il designer ha chiesto le altre due (registro 108).
Stessi lotti della v2 di oggi (H: la tabella delle spinte nel bot, il file v2 com'è): 750 partite
di torneo (seme 700000) e 2 000 di vita (seme 200000) a 2, 3 e 4 giocatori, e per confronto la
v1.5 (`data/cards.json`) agli stessi numeri e semi.

### Il torneo, per giocatore

| per giocatore | v2 a 2 | **v2 a 3 (H)** | v2 a 4 | v1.5 a 2 | v1.5 a 3 | v1.5 a 4 |
|---|--:|--:|--:|--:|--:|--:|
| PV | 83,4 | 89,3 | 78,4 | 87,0 | 85,7 | 82,0 |
| costruiti | 12,9 | 13,9 | 12,2 | 10,3 | 9,9 | 9,4 |
| costruiti sopra un altro | 6,6 | 6,6 | 6,1 | 5,6 | 5,1 | 5,0 |
| altezza massima | 4,58 | 4,56 | 4,41 | 4,02 | 3,88 | 3,97 |
| basi proprie / altrui | 6,9 / 1,6 | 6,0 / 2,3 | 5,3 / 2,3 | 5,2 / 1,7 | 4,2 / 2,0 | 3,8 / 2,3 |
| premio di scavo (di cui era 5) | 10,3 (3,9) | 11,4 (4,3) | 9,9 (3,6) | – | – | – |
| Idee prodotte / spese | 10,8 / 10,5 | 16,2 / 14,5 | 14,5 / 13,1 | – | – | – |
| azioni: costruisci / potenzia / ristruttura | 12,9 / 3,7 / 0,8 | 13,9 / 3,7 / 0,7 | 12,2 / 3,5 / 0,7 | 10,3 / 0,5 / 0,5 | 9,9 / 0,4 / 0,8 | 9,4 / 0,5 / 0,8 |
| Dinastia / passa | 0,12 / 2,8 | 0,63 / 3,1 | 0,75 / **5,1** | 0,08 / 1,3 | 0,04 / 1,0 | 0,06 / 1,0 |
| kingmaker (cambia vincitore senza il bottino dell'era 5) | 10 % | 13 % | **18 %** | – | – | – |

### Le strategie

| vince | v2 a 2 (atteso 50 ± 6) | v2 a 3 (33 ± 5) | v2 a 4 (25 ± 4) | v1.5 a 2 | v1.5 a 3 | v1.5 a 4 |
|---|--:|--:|--:|--:|--:|--:|
| Rendita | 55 % | 38 % | 30 % | 47 % | 41 % | 30 % |
| Continuità | **58 %** | 34 % | 27 % | – | – | – |
| Bilanciata | 48 % | 34 % | 26 % | 52 % | 39 % | 29 % |
| Obiettivi | **40 %** | 33 % | 25 % | 54 % | 34 % | 33 % |
| Scavo | 44 % | 30 % | 22 % | 46 % | 29 % | **15 %** |
| Lampo | 54 % | 31 % | 20 % | 50 % | 27 % | 20 % |
| Verticale | – | – | – | 52 % | 31 % | 23 % |

### La vita degli edifici, per partita

| per partita | v2 a 2 | v2 a 3 | v2 a 4 | v1.5 a 2 | v1.5 a 3 | v1.5 a 4 |
|---|--:|--:|--:|--:|--:|--:|
| costruiti | 25,8 | 41,7 | 48,9 | 20,5 | 29,5 | 37,6 |
| in piedi a fine | 7,7 | 13,6 | 16,3 | 5,7 | 9,3 | 11,4 |
| cade nell'era in cui nasce | 34 % | 35 % | 34 % | 19 % | 17 % | 18 % |
| sepolti (spianati dal proprietario / da un altro) | 51 % (37 / 13) | 47 % (31 / 17) | 48 % (32 / 19) | 53 % (27 / 15) | 51 % (25 / 19) | 54 % (25 / 24) |
| PV delle carte: Rendita / Lampo / Scavo / Scheletri | 22 / 39 / 30 / 20 | 29 / 66 / 50 / 31 | 33 / 76 / 59 / 38 | 38 / 26 / 14 / 6 | 66 / 36 / 21 / 8 | 73 / 48 / 29 / 15 |

### Cosa salta all'occhio

**1. La città della v2 ha la stessa forma a 2, 3 e 4 giocatori.** Altezza 4,4–4,6, un terzo
degli edifici cade nell'era in cui nasce (34–35 %, contro il 17–19 % della v1.5: è la rovina a
−2 senza il rudere), 6–7 edifici costruiti sopra un altro per giocatore, i canali nelle stesse
proporzioni. Il numero di giocatori cambia l'affollamento (basi altrui 1,6 a due, 2,3 a tre e
quattro), non il gioco. Le regole non hanno una dipendenza nascosta dal tre.

**2. A due giocatori le strategie si aprono.** Continuità 58 % e Obiettivi 40 % stanno fuori
dall'errore (atteso 50 ± 6); nella v1.5 a due sono tutte fra 46 e 54. I due casi hanno cause
diverse. Obiettivi insegue i Monumenti e a due giocatori se ne rivela uno solo (giocatori meno
uno): il suo canale vale 1,7 punti, e senza la Verticalità che nella v1.5 la reggeva (25 punti)
resta la strategia più povera (77,9 PV contro 81–88). Continuità gode delle cinque colonne: con
poco suolo e nessun avversario nella colonna costruisce sopra i propri (basi proprie 6,9 contro
6,0 a tre), e la classe in colonna paga. Da decidere se è un difetto delle regole a due
(Monumenti rivelati: due invece di uno; da misurare) o solo dei bot.

**3. A quattro giocatori le strategie tengono, ma si passa il doppio.** Rendita 30 e Lampo 20
stanno sul bordo dell'errore (25 ± 4), le altre dentro; meglio della v1.5 a quattro, dove la
Scavo vince il 15 %. Ma ogni giocatore passa 5,1 volte a partita (3,1 a tre, 2,8 a due): un
turno per era a testa senza niente da fare. Il motivo è aritmetico: **quattro giocatori per
quattro lavoratori fanno sedici turni per era, e le sagome dell'era sono dodici.** A tre i turni
sono dodici, a due otto. Si costruiscono 49 delle 60 sagome (41,7 a tre): il mazzo dell'era si
svuota, il mercato si restringe e il bot, che non ha più niente che valga, passa (nella partita
raccontata con `--perche`, seme 700003: 20 passaggi a quattro, 6 a tre, tutti "nessuna mossa
vale più di zero"). Nella v1.5 la valvola era Reclutare (3,6 azioni a giocatore a quattro): nel
draft non c'è più. Il kingmaker sale al 18 % (10 % a due, 13 % a tre): con quattro giocatori
il distacco fra primo e secondo è più piccolo e il bottino dell'ultima era lo copre più spesso.

**4. Le Idee si spendono.** Prodotte 10,8 / 16,2 / 14,5 per giocatore, spese il 97 / 90 / 90 %:
nessuna scarsità e nessun avanzo a nessun numero di giocatori.

**5. La partita si accorcia con i giocatori, come nella v1.5.** 89 punti a tre, 83 a due, 78
a quattro (v1.5: 86 / 87 / 82): meno suolo a testa a quattro, meno attivazioni altrui a due.

**6. Controprova: tre lavoratori invece di quattro** (`--lavoratori 3`, stessi semi).

| per giocatore | a 4: 4 lav. | **a 4: 3 lav.** | a 2: 4 lav. | **a 2: 3 lav.** |
|---|--:|--:|--:|--:|
| PV | 78,4 | 69,9 | 83,4 | 70,6 |
| costruiti / passa | 12,2 / 5,1 | 10,8 / 1,9 | 12,9 / 2,8 | 10,9 / 1,1 |
| altezza / basi altrui | 4,41 / 2,3 | 4,36 / 2,2 | 4,58 / 1,6 | 4,44 / 1,5 |
| kingmaker | 18 % | 17 % | 10 % | 9 % |
| vince: Rendita / Continuità / Bilanciata / Obiettivi / Scavo / Lampo | 30 / 27 / 26 / 25 / 22 / 20 | 29 / 27 / 24 / 27 / 21 / 23 | 55 / 58 / 48 / 40 / 44 / 54 | 52 / 55 / 46 / 45 / 43 / 58 |

A quattro giocatori con tre lavoratori i passaggi cadono da 5,1 a 1,9, ma la partita si
assottiglia (70 punti, 10,8 edifici) e le strategie non si muovono: con dodici turni si
costruiscono comunque 10,8 sagome, cioè i quattro turni in più di prima erano per tre quarti
passaggi. Il mercato corto è confermato, ma togliere un lavoratore toglie anche gioco: se si
vuole intervenire, la strada è dare qualcosa da fare al quarto lavoratore (un incasso quando
si passa, come nel turno a un'azione: `passa_incasso_*` c'è già) o più sagome a quattro, non un
lavoratore in meno. A due giocatori con tre lavoratori la forbice si chiude (Continuità 55,
Obiettivi 45, tutte entro 50 ± 6 tranne Lampo a 58) ma la partita perde 13 punti: la forbice a
due è in parte un effetto dei quattro turni per otto turni d'era, non solo dei Monumenti.
Da decidere, con la seconda controprova (un secondo Monumento rivelato a due) ancora da fare:
vuole una costante, oggi "giocatori meno uno" è nel codice.

## Tredicesima misura: le controprove a quattro e a due

Le due domande lasciate dalla dodicesima misura, più le due idee del designer per la scarsità di
sagome a quattro (registro 109-110). Stessi lotti (750 partite di torneo, seme 700000), stessi
semi dei lotti di confronto.

### L'incasso al passaggio (`--passa_incasso 1`, costante `passa_incasso`)

Nel turno della v1.5 chi non fa l'azione dopo l'attivazione incassa 1 Costruzione più 1 risorsa
a scelta, come nel turno a un'azione. Il bot la valuta come una mossa fra le altre.

| per giocatore | a 4: base | **a 4: incasso** | a 3: H | a 3: incasso | a 2: base | a 2: incasso |
|---|--:|--:|--:|--:|--:|--:|
| PV | 78,4 | 78,3 | 89,3 | 88,0 | 83,4 | 82,8 |
| costruiti / passa | 12,2 / 5,1 | 12,2 / 5,3 | 13,9 / 3,1 | 13,6 / 3,4 | 12,9 / 2,8 | 12,9 / 3,2 |
| Idee spese | 13,1 | 12,6 | 14,5 | 13,7 | 10,5 | 9,5 |
| kingmaker | 18 % | 15 % | 13 % | 15 % | 10 % | 10 % |
| vince: Rendita / Continuità / Bilanciata / Obiettivi / Scavo / Lampo | 30 / 27 / 26 / 25 / 22 / 20 | 31 / 28 / 22 / 29 / 19 / 21 | 38 / 34 / 34 / 33 / 30 / 31 | 30 / 32 / 37 / 34 / 30 / 37 | 55 / 58 / 48 / 40 / 44 / 54 | 54 / 59 / 47 / 42 / 43 / 56 |

**Non cambia niente, a nessun numero di giocatori.** A quattro i passaggi restano cinque a testa
e gli edifici 12,2: il vincolo non sono le risorse, sono le sagome, e le due risorse incassate
si perdono alla dispersione (tetto 3 per risorsa). A tre la Rendita scende da 38 a 30 e la Lampo
sale da 31 a 37, tutte e due sul bordo dell'errore, con la partita uguale: rumore o un piccolo
spostamento, non un effetto. Non entra nel file v2.

### Il secondo Monumento a due (`--monumenti 2`, costante `monumenti_rivelati_by_players`)

La regola rivela "giocatori meno uno" Monumenti: a due, uno solo. Con due rivelati, stessi semi:

| per giocatore, a 2 | base (1 Monumento) | **2 Monumenti** |
|---|--:|--:|
| PV | 83,4 | 85,0 |
| di cui Monumenti | 1,6 | 3,1 |
| costruiti / sopra / altezza / basi altrui | 12,9 / 6,6 / 4,58 / 1,6 | 12,9 / 6,6 / 4,58 / 1,6 |
| vince: Continuità / Rendita / Lampo / Bilanciata / Scavo / Obiettivi | 58 / 55 / 54 / 48 / 44 / 40 | 58 / 53 / 54 / 48 / 45 / 42 |
| PV della Obiettivi (le altre) | 77,9 (81–88) | 79,6 (83–90) |

**Non risolve.** La partita è la stessa carta per carta (costruiti, altezza, basi: identici), il
canale Monumenti raddoppia per tutti, e la Obiettivi guadagna due punti su cento: resta la più
povera di 4–10 punti. Il suo problema a due non sono i Monumenti che mancano ma il modo in cui
li insegue: costruisce per soddisfare condizioni e perde altrove. È un difetto del bot a due
giocatori, non delle regole; si ritara con le spinte, come si è fatto per la Lampo (undicesima
misura), se e quando serve. La costante resta come manopola, spenta.

### Più sagome a quattro: doppioni o abitazioni (`data/proposte/cards-v2-*.json`)

Le due idee del designer per i sedici turni contro dodici sagome. Tutte e due aggiungono dieci
sagome con `min_players` 4, che entrano nel mazzo solo a quattro giocatori: a due e a tre il
gioco non cambia. **Doppioni**: per era una seconda copia della chiesa e del villaggio più
economici da una casella (Capanne, Dolmen; Insulae, Sacello; Borgo, Cappella; Loggia, Bottega
d'artista; Condominio, Monumento ai caduti). **Abitazioni**: per era due case generiche nuove,
civiche, senza terreno, che costano 1–2 e producono 1 (Capanne di fango, Case a schiera, Case a
graticcio, Casa borghese, Palazzina; resistenza 1–3, Lampo 1, Scavo 1). Generate da
`tools/genera_cards_v2.py --variante doppioni|abitazioni`.

| per giocatore, a 4 | base (60 sagome) | **doppioni (70)** | abitazioni (70) |
|---|--:|--:|--:|
| PV | 78,4 | 84,7 | 80,8 |
| Lampo / Scavo / Continuità / Scheletri | 19,1 / 14,6 / 11,1 / 9,6 | 21,5 / 18,2 / 11,9 / 9,3 | 19,9 / 15,8 / 12,4 / 9,2 |
| costruiti / passa | 12,2 / 5,1 | 13,2 / 4,1 | 13,4 / 3,9 |
| sopra / altezza / basi altrui | 6,1 / 4,41 / 2,3 | 6,4 / 4,41 / 2,5 | 6,5 / 4,37 / 2,5 |
| premio di scavo (era 5) | 9,9 (3,6) | 12,5 (4,1) | 10,7 (3,8) |
| kingmaker | 18 % | 15 % | 13 % |
| vince: Rendita / Continuità / Bilanciata / Obiettivi / Scavo / Lampo (atteso 25 ± 4) | 30 / 27 / 26 / 25 / 22 / 20 | 32 / 26 / 29 / 28 / 20 / **15** | **36** / **18** / 22 / 28 / 26 / 19 |

**1. Dieci sagome in più danno un edificio in più a testa e tolgono un passaggio.** Da 12,2 a
13,2–13,4 edifici, da 5,1 a 4 passaggi a testa: il mercato corto era il vincolo, e le sagome
sono la leva giusta (l'incasso non muoveva niente). Non basta: quattro passaggi a testa sono
ancora uno per era, perché sedici turni chiedono più di quattordici sagome; la stima è sedici
per era, cioè venti in più e non dieci.

**2. I doppioni sono meglio delle abitazioni.** +6 punti a giocatore contro +2, il premio di
scavo sale (12,5, con più basi altrui: 2,5), il kingmaker scende al 15 %. Le abitazioni
spostano le strategie: Rendita 36 e Continuità 18, tutte e due fuori dall'errore, perché una
casa da 1 che produce 1 è la carta che la Rendita compra e la Continuità (classe civico in
colonna) non sa usare quanto pensa. I doppioni costano niente da disegnare: sono sagome che ci
sono già.

**3. Ma i doppioni scelti così affossano la Lampo**: 15 % contro 20 di prima e 25 atteso. Le
copie sono chiese e villaggi economici con poco Lampo (0–3): il Lampo di tutti sale (+2,4) per
la carta in più, ma la Lampo, che vive di carte a Lampo alto, trova il mercato pieno di carte
che non le servono e le altre strategie con più edifici. Da decidere come scegliere i doppioni:
non per classe ma per Lampo (una copia delle due carte a Lampo più alto da una casella per
era), oppure quattro copie per era invece di due, e poi ricontrollare la Lampo. Il file v2 non
cambia finché non si decide.

### Le case: solo Lampo, due taglie, con e senza i doppioni delle chiese

Seconda idea del designer (registro 111): abitazioni generiche che **non producono** e danno
solo Lampo, cioè punti subito, "un rientro annacquato"; due taglie per era, due copie
ciascuna: la piccola costa 1 e dà Lampo 1, la grande costa 2 e dà Lampo 2 (3 nelle ere 4–5).
Venti sagome, la stima per sedici turni. Poi le stesse più una seconda copia dei due edifici da
una casella di religione (o cultura dove manca) più economici di ogni era, non esauribili:
trenta. Tutte solo a quattro (`--variante case`, `--variante case_doppioni`).

| per giocatore, a 4 | base | doppioni (10) | **case (20)** | case + chiese (30) |
|---|--:|--:|--:|--:|
| PV | 78,4 | 84,7 | 83,4 | 84,3 |
| Lampo di tutti / della strategia Lampo | 19,1 / 27,5 | 21,5 / – | 23,1 / 32,3 | 22,2 / – |
| costruiti / passa | 12,2 / 5,1 | 13,2 / 4,1 | 13,9 / 3,5 | 13,9 / 3,5 |
| sopra / altezza / basi altrui | 6,1 / 4,41 / 2,3 | 6,4 / 4,41 / 2,5 | 6,6 / 4,38 / 2,4 | 6,6 / 4,32 / 2,4 |
| kingmaker | 18 % | 15 % | 16 % | 14 % |
| vince: Rendita / Continuità / Bilanciata / Obiettivi / Scavo / Lampo (25 ± 4) | 30 / 27 / 26 / 25 / 22 / 20 | 32 / 26 / 29 / 28 / 20 / 15 | **34** / 22 / 30 / 26 / 24 / **14** | **36** / 22 / 29 / 29 / 21 / **13** |

**1. Le case fanno il loro mestiere sul mercato.** Venti sagome in più: 13,9 edifici a testa,
3,5 passaggi (da 5,1), +5 punti, la città uguale. Le case si costruiscono: la strategia Lampo ne
mette 15,3 edifici a partita (13,9 prima). Aggiungere le chiese non aggiunge niente: 13,9 e
3,5 anche a trenta, perché i passaggi che restano non sono più del mercato vuoto ma del bot che
non trova niente che valga (una casa vale poco, e a volte niente vale più di zero).

**2. Ma il Lampo diventa di tutti, e la strategia Lampo affonda.** Con le case tutti prendono
4 punti di Lampo in più; la Lampo ne prende 5 (32,3) ma resta la più povera (80,8 contro
82–87) e vince il 14 %, poi il 13 % con le chiese. È lo stesso effetto della decima misura
(alzare il Lampo delle carte alza il Lampo di tutti) portato all'estremo: se il Lampo si compra
con una casa da 1, specializzarsi nel Lampo non è più una strategia. E la Rendita, che con
quattro lavoratori ha sempre di che comprare, vince il 34–36 %.

**3. Cosa se ne ricava.** La scarsità di sagome a quattro si risolve con venti sagome in più,
e le case generiche la risolvono; il prezzo è che le case non devono dare quello che una
strategia insegue. Le alternative da misurare, in ordine: case che danno **Scavo** invece di
Lampo (un rientro ancora più annacquato, che paga solo se qualcuno ci costruisce sopra), o
case **senza niente** (costano 1, resistenza 1, Scavo 1: puro suolo e Continuità), o il bot
Lampo ritarato a quattro come si è fatto a tre. Da decidere.

La vita delle carte con le case (2 000 partite a quattro): 55,7 edifici a partita invece di
48,9, in piedi a fine 17,8 invece di 16,3, il 37 % cade nell'era in cui nasce (34 % prima:
le case piccole reggono poco), sepolti 46 %, Lampo per partita da 76 a 93 punti, il resto
uguale.

### "Prova tutto": case con Scavo, case senza niente, il bot Lampo ritarato

Registro 112. Le tre alternative, stessi semi, a quattro. **Case con Scavo**: le stesse venti
case senza Lampo e con Scavo 2 (piccola) e 3 (grande). **Case senza niente**: venti case
piccole, costano 1, Lampo 0, Scavo 1. **Bot Lampo ritarato** sul file delle case con Lampo:
`--spinta lampo=2.5`, `lampo_potenzia=5`, tutte e due.

| per giocatore, a 4 | base | case Lampo | **case Scavo** | case nulle | Lampo: lampo 2,5 | potenzia 5 | entrambe |
|---|--:|--:|--:|--:|--:|--:|--:|
| PV | 78,4 | 83,4 | 78,1 | 76,8 | 84,1 | 83,4 | 83,6 |
| Lampo di tutti | 19,1 | 23,1 | 17,8 | 18,0 | – | – | – |
| costruiti / passa | 12,2 / 5,1 | 13,9 / 3,5 | 13,0 / 4,5 | 12,6 / 5,1 | 14,1 / 3,4 | 13,9 / 3,4 | 13,9 / 3,4 |
| kingmaker | 18 % | 16 % | 18 % | 18 % | 17 % | 17 % | 18 % |
| vince: Rendita / Continuità / Bilanciata / Obiettivi / Scavo / Lampo (25 ± 4) | 30 / 27 / 26 / 25 / 22 / 20 | 34 / 22 / 30 / 26 / 24 / 14 | 32 / 23 / 29 / 25 / **18** / 23 | 31 / 25 / 27 / 23 / 20 / 25 | 35 / 24 / 29 / 30 / 24 / **7** | 38 / 20 / 29 / 27 / 19 / 18 | 34 / 24 / 29 / 27 / 23 / 12 |

**1. Le case senza niente non si costruiscono.** Passaggi 5,1 come senza case, edifici 12,6:
il bot non compra suolo nudo, e non lo farebbe nemmeno un giocatore. Le strategie tornano
tutte nell'errore perché la partita è quella di prima, meno due punti. Inutili.

**2. Le case con Scavo sono il compromesso.** La Lampo torna al 23 % (il Lampo non è più di
tutti: 17,8 a testa), tutte le strategie stanno nell'errore tranne la Scavo al 18 %, i punti
restano 78 come senza case. Ma si costruiscono meno delle case con Lampo (13,0 contro 13,9)
e i passaggi restano 4,5: una casa che paga solo se qualcuno ci costruisce sopra vale poco
per chi la compra, e il bot spesso preferisce passare. Il mercato corto è mezzo risolto.

**3. Ritarare il bot Lampo non serve.** Dare più peso al Lampo delle carte (lampo 2,5) lo fa
comprare più case e vincere il 7 %; il peso ai potenziamenti lo porta al 18 % e basta. Il
problema non è come il bot Lampo sceglie: è che con le case a Lampo il canale non distingue
più nessuno.

**4. Quello che resta da capire** è se esiste una casa che i giocatori comprano (come quella
con Lampo) senza regalare a tutti il canale di una strategia (come quella con Scavo non fa).
La variante mista, piccola con Lampo 1 e grande con Scavo 3, sta in mezzo e non aiuta:
80,1 punti, 13,5 edifici, 3,9 passaggi, Lampo 19 %, ma Rendita 34 % e Scavo 18 %, tutte e
due fuori dall'errore. Ogni casa che si compra volentieri regala qualcosa alla Rendita, che a
quattro lavoratori compra sempre: la Rendita sta al 30 % già senza case, e ogni sagoma in più
la porta a 32–36. Se si vuole il mercato pieno a quattro, la domanda vera è la Rendita a
quattro giocatori, non le case.

| variante | punti | edifici / passa | fuori dall'errore (25 ± 4) |
|---|--:|--:|---|
| nessuna | 78 | 12,2 / 5,1 | Rendita 30, Lampo 20 (bordo) |
| doppioni per classe | 85 | 13,2 / 4,1 | Lampo 15 |
| abitazioni che producono | 81 | 13,4 / 3,9 | Rendita 36, Continuità 18 |
| case con Lampo | 83 | 13,9 / 3,5 | Lampo 14, Rendita 34 |
| case con Lampo + chiese | 84 | 13,9 / 3,5 | Lampo 13, Rendita 36 |
| **case con Scavo** | 78 | 13,0 / 4,5 | Scavo 18 |
| case senza niente | 77 | 12,6 / 5,1 | nessuna (ma non si costruiscono) |
| case miste | 80 | 13,5 / 3,9 | Rendita 34, Scavo 18 |

## Quattordicesima misura: il calendario del torneo, e i bot a due e a quattro

Il designer ha chiesto di sistemare i bot a due e a quattro (registro 114), dove la dodicesima
misura dava Continuità 58 % e Obiettivi 40 % a due, Rendita 30 % e Lampo 20 % a quattro.

### Il calendario era sbagliato

Il torneo assegnava le strategie a **finestre consecutive della lista**: la partita g dava al
posto i la strategia (i + g) mod 6. Con meno posti che strategie ogni strategia incontrava
solo le vicine di lista, sempre le stesse. A due: Continuità giocava solo contro Scavo e
Bilanciata (e le batteva il 55 e il 62 %), Obiettivi solo contro Bilanciata e Rendita (e
perdeva il 58 e il 62 %). A quattro sei quaterne fisse. Il 58 e il 40 erano accoppiamenti,
non forza; per questo le spinte non li muovevano.

Il torneo ha ora il giro `--giro tutte`: la partita g prende una delle combinazioni di k
strategie fra le sei, in ordine, e ruota i posti quando le ha fatte tutte (15 coppie, 20
terne, 15 quaterne, ognuna giocata lo stesso numero di volte). Il giro vecchio resta dove non
si chiede, così i lotti precedenti si rigiocano uguali. **Anche il lotto a tre andava rifatto**:
"tutte nell'errore" era misurato col calendario vecchio.

| vince (atteso 50 / 33 / 25) | a 2, vicini | **a 2, tutte** | a 3, vicini (H) | **a 3, tutte** | a 4, vicini | **a 4, tutte** |
|---|--:|--:|--:|--:|--:|--:|
| Rendita | 55 | 55 | 38 | 37 | 30 | **36** |
| Bilanciata | 48 | 55 | 34 | 38 | 26 | 29 |
| Obiettivi | 40 | 56 | 33 | 35 | 25 | 26 |
| Continuità | 58 | 49 | 34 | 34 | 27 | 22 |
| Lampo | 54 | 46 | 31 | 30 | 20 | **18** |
| Scavo | 44 | **38** | 30 | **26** | 22 | 20 |

La partita è identica (punti, edifici, altezza, basi: uguali al decimale): cambia solo a chi
si attribuiscono le vittorie. La mappa vera: la Scavo è la debole a due e a tre, a quattro la
Rendita è forte e la Lampo debole. Continuità e Obiettivi erano a posto.

### Le spinte sono handicap, non aiuti

Sul calendario corretto, stessi semi. Spingere di più la Scavo (premio 1,2, Scavo a terra
0,8) la peggiora: 26 → 24 → 22 a tre, 38 → 37 → 30 a due. La protezione attesa a 3 non
cambia niente (a +2 gli edifici che contano reggono già). I potenziamenti della Lampo a 5
danno +2 a quattro. La Bilanciata, che non ha spinte, è la più forte o quasi a ogni tavolo:
**le spinte tolgono, non aggiungono**, e la taratura giusta è verso il basso.

| vince | a 2: base | Scavo a metà | a 3: base | Scavo a metà | a 4: base | Lampo 0,8 + pot. 5 | Rendita 0,6 | tutte e due |
|---|--:|--:|--:|--:|--:|--:|--:|--:|
| Scavo | 38 | **53** | 26 | **34** | 20 | 18 | 20 | 20 |
| Lampo | 46 | 44 | 30 | 30 | 18 | **26** | 19 | 25 |
| Rendita | 55 | 53 | 37 | 35 | 36 | 32 | 35 | 32 |

Le tabelle del bot: `SPINTE_V2` con la Scavo a metà (`scavo_premio` 0,4, `scavo_terra_scavo`
0,25), che vale a ogni tavolo; `SPINTE_V2_PER_GIOCATORI[4]` con `lampo` 0,8 e
`lampo_potenzia` 5, solo a quattro. Rigiocato senza manopole:

| vince (atteso 50 / 33 / 25, errore 6 / 5 / 4) | a 2 | a 3 | a 4 |
|---|--:|--:|--:|
| Rendita | 53 | 35 | 27 |
| Bilanciata | 54 | 37 | 25 |
| Obiettivi | 53 | 32 | 25 |
| Continuità | 44 | 32 | 21 |
| Lampo | 44 | 30 | 28 |
| Scavo | 53 | 34 | 23 |
| kingmaker | 12 % | 15 % | 15 % |

**Tutte entro l'errore a tutti e tre i tavoli**, con Continuità e Lampo a due e Continuità a
quattro sul bordo. Abbassare ancora la Rendita a quattro (0,6 e penalità dimezzata) la
rialza a 29: si lascia. La v1.5 non cambia (`SPINTE_V1` uguale, riferimento identico), e
nemmeno la partita: i lotti nuovi hanno gli stessi edifici, altezza e basi di prima.

## Quindicesima misura: le case per tutti

Decisione del designer dopo la tredicesima misura (registro 115): le case generiche entrano
per tutti i tavoli, senza regole diverse per numero di giocatori; se qualcosa dipende dal
numero di giocatori è la misura del mercato. Tre tipi per era, una copia ciascuno, per ogni
numero di giocatori (`--variante case_tutti`, 75 sagome): la **casa piccola** (costa 1,
resistenza 1–3, Lampo 1), la **casa grande** (costa 2, resistenza 2–4, Lampo 2, 3 nelle ere
4–5) e la **casa del borgo** (costa 1, Lampo 0, Scavo 2). Niente produzione, niente Rendita,
classe civico, nessun terreno. Misurato sul torneo corretto con i bot tarati (quattordicesima
misura), stessi semi; a quattro anche col mercato a 8 sagome (`--mercato 8`).

| per giocatore | a 2: senza | **a 2: case** | a 3: senza | **a 3: case** | a 4: senza | **a 4: case** | a 4: case, mercato 8 |
|---|--:|--:|--:|--:|--:|--:|--:|
| PV | 83,3 | 80,4 | 88,7 | 89,3 | 78,3 | 80,5 | 80,4 |
| Lampo / Rendita / Scavo / Continuità | 19,5 / 10,7 / 14,5 / 12,7 | 20,4 / 9,3 / 13,7 / 12,7 | 21,9 / 9,5 / 16,4 / 13,2 | 23,8 / 8,8 / 16,2 / 14,1 | 18,8 / 8,3 / 14,6 / 11,1 | 20,7 / 8,1 / 14,7 / 12,3 | – |
| costruiti / passa | 12,8 / 3,0 | 12,9 / 3,2 | 13,8 / 3,2 | 14,7 / 2,5 | 12,0 / 5,4 | 13,2 / 4,1 | 13,2 / 4,2 |
| altezza / basi altrui | 4,58 / 1,6 | 4,43 / 1,6 | 4,56 / 2,4 | 4,51 / 2,4 | 4,40 / 2,3 | 4,34 / 2,3 | – |
| kingmaker | 12 % | 8 % | 15 % | 12 % | 15 % | 13 % | 16 % |
| vince: Rendita / Continuità / Bilanciata / Obiettivi / Scavo / Lampo | 53 / 44 / 54 / 53 / 53 / 44 | 49 / 45 / 51 / 56 / 49 / 50 | 35 / 32 / 37 / 32 / 34 / 30 | 36 / 29 / 33 / 36 / 33 / 33 | 27 / 21 / 25 / 25 / 23 / 28 | **30** / 21 / 26 / 25 / 22 / 25 | 34 / 18 / 25 / 27 / 20 / 26 |

**1. Le case reggono a tutti e tre i tavoli.** A due e a tre tutte le strategie stanno
nell'errore (a 2: 45–56; a 3: 29–36); a quattro la Rendita sta al 30 contro il 29 di bordo,
le altre dentro. Il kingmaker scende ovunque (8 / 12 / 13 %). La forma della città non
cambia: stesse basi altrui, altezza un decimo più bassa.

**2. A tre e a quattro danno l'edificio in più che mancava.** A quattro 13,2 edifici a testa
invece di 12,0 e i passaggi da 5,4 a 4,1; a tre 14,7 invece di 13,8 e i passaggi da 3,2 a
2,5. Le case si costruiscono. A due, dove il mercato non era corto, tolgono tre punti: quindici
carte deboli su settantacinque diluiscono il mercato, e la Rendita perde 1,3.

**3. Il mercato a 8 non fa niente.** A quattro con le case, 8 sagome scoperte invece di 6:
stessi edifici (13,2), stessi passaggi (4,2), la Rendita sale a 34. I passaggi che restano non
sono del mercato stretto: sono del mazzo dell'era, che con quindici case in più ha quindici
sagome per era contro sedici turni. La misura del mercato si lascia a 6.

**4. Il Lampo non è più di tutti.** Con una copia per tipo e i bot tarati, il Lampo sale di
1–2 punti a testa e la strategia Lampo resta nell'errore (50 / 33 / 25): il problema della
tredicesima misura era il calendario e le venti case a Lampo, non l'idea.

Da decidere: se le case entrano nel file v2 così (tre per era, una copia), o con due copie
della piccola (venti sagome, per chiudere del tutto il mercato a quattro al costo di
diluire di più a due).

## Sedicesima misura: le case in riserva

Decisione del designer dopo la quindicesima misura (registro 116): le case stanno nel file v2
per tutti i tavoli, ma **non nel mazzo dell'era**: sono in una riserva sempre scoperta accanto
al mercato, in **due copie ciascuna**, e il giocatore sceglie cosa comprare; non si pescano, non
si rimpiazzano, a fine era le avanzate si scartano. Tre tipi per era (piccola, grande, con lo
Scavo), due nell'era Moderna dove lo Scavo non vale: quattordici case, 74 sagome. Misurato sul
torneo corretto con i bot tarati, stessi semi della quindicesima; nelle colonne "mazzo" le case
della quindicesima misura (una copia, nel mazzo dell'era), in "riserva" quelle di oggi.

| per giocatore | a 2: senza | a 2: mazzo | **a 2: riserva** | a 3: senza | a 3: mazzo | **a 3: riserva** | a 4: senza | a 4: mazzo | **a 4: riserva** |
|---|--:|--:|--:|--:|--:|--:|--:|--:|--:|
| PV | 83,3 | 80,4 | 84,1 | 88,7 | 89,3 | 90,4 | 78,3 | 80,5 | 81,3 |
| Lampo / Rendita / Scavo / Continuità | 19,5 / 10,7 / 14,5 / 12,7 | 20,4 / 9,3 / 13,7 / 12,7 | 21,9 / 10,4 / 13,8 / 14,2 | 21,9 / 9,5 / 16,4 / 13,2 | 23,8 / 8,8 / 16,2 / 14,1 | 25,1 / 9,1 / 15,5 / 15,3 | 18,8 / 8,3 / 14,6 / 11,1 | 20,7 / 8,1 / 14,7 / 12,3 | 21,8 / 8,1 / 14,2 / 13,3 |
| costruiti / passa | 12,8 / 3,0 | 12,9 / 3,2 | 13,6 / 2,5 | 13,8 / 3,2 | 14,7 / 2,5 | 15,1 / 2,0 | 12,0 / 5,4 | 13,2 / 4,1 | 13,4 / 3,9 |
| altezza / basi altrui | 4,58 / 1,6 | 4,43 / 1,6 | 4,57 / 1,6 | 4,56 / 2,4 | 4,51 / 2,4 | 4,56 / 2,3 | 4,40 / 2,3 | 4,34 / 2,3 | 4,39 / 2,3 |
| kingmaker | 12 % | 8 % | 10 % | 15 % | 12 % | 14 % | 15 % | 13 % | 15 % |
| vince: Rendita / Continuità / Bilanciata / Obiettivi / Scavo / Lampo | 53 / 44 / 54 / 53 / 53 / 44 | 49 / 45 / 51 / 56 / 49 / 50 | 53 / 46 / 49 / 50 / 50 / 52 | 35 / 32 / 37 / 32 / 34 / 30 | 36 / 29 / 33 / 36 / 33 / 33 | 30 / 29 / 36 / 35 / 31 / **39** | 27 / 21 / 25 / 25 / 23 / 28 | 30 / 21 / 26 / 25 / 22 / 25 | **33** / 21 / 25 / 26 / 21 / 24 |

**1. La riserva si compra più del mazzo, e a due non toglie più niente.** Le case in riserva
danno l'edificio in più a tutti i tavoli (a 2: 13,6 contro 12,8; a 3: 15,1 contro 13,8; a 4:
13,4 contro 12,0) e tagliano i passaggi (a 4 da 5,4 a 3,9, a 3 da 3,2 a 2,0). A due i tre punti
persi dalla quindicesima misura tornano (84,1 contro 83,3): il mercato non è più diluito, perché
le case non stanno nel mazzo dell'era. La città non cambia forma: stessa altezza, stesse basi
altrui.

**2. I punti in più sono Lampo e Continuità.** Il Lampo sale di 2–3 punti a testa e la
Continuità di 1,5–2: le case sono suolo economico che si impila. Lo Scavo cala di mezzo punto
(meno Idee spese, meno Potenzia): con una casa sempre disponibile a 1, il bot costruisce invece
di potenziare.

**3. Due strategie toccano il bordo.** A tre il Lampo vince il 39 % (bordo 38) e a quattro la
Rendita il 33 % (bordo 29), che era già al 30 con le case nel mazzo; a quattro lo Scavo sta al
21, sul bordo basso. A due tutto dentro (46–53). Con quattordici case sempre disponibili il
Lampo a tre ha sempre qualcosa da comprare, e a quattro la Rendita — che ignora le case — è
l'unica a non spendere turni su sagome da 1–2 punti mentre gli altri riempiono. Sono due
scostamenti di un punto sul bordo, su sei strategie per tre tavoli: da rimisurare se si
ritoccano i bot, non da correggere nelle regole.

**4. Il kingmaker non si muove.** 10 / 14 / 15 % contro 12 / 15 / 15 % senza case: la riserva
non aggiunge bottino all'ultima era (quota era 5: 42 / 38 / 36 %).

**5. Quali case si comprano (vita delle carte a tre, 2000 partite).** Copie costruite su
4000 disponibili (due per partita), per era: piccola / grande / con lo Scavo.

| era | 1 | 2 | 3 | 4 | 5 |
|---|--:|--:|--:|--:|--:|
| piccola | 181 | 1182 | 206 | 3097 | 3234 |
| grande | 1611 | 411 | 3147 | **3989** | **3969** |
| con lo Scavo | 0 | 2 | 0 | 96 | – |
| case a partita | 0,9 | 0,8 | 1,7 | 3,6 | 3,6 |

Tre cose. **Le case con lo Scavo non le compra nessuno**: 98 costruzioni su 16 000 copie. Alla
stessa spesa c'è la piccola con Lampo 1, e Scavo 2 paga solo se qualcuno costruisce sopra una
sagoma da resistenza 1–2: per il bot non vale mai, e il ragionamento regge anche per un
giocatore. **Le case delle ere 4–5 finiscono quasi ogni partita**: il Palazzetto (1 Denaro,
1 Idea, Lampo 3) e il Condominio popolare escono in 3989 e 3969 copie su 4000, la Casa borghese
e la Palazzina in tre su quattro; nelle ere 4–5 si costruiscono 3,6 case a partita, più di una
a testa per era. Nelle ere 1–3 le case sono un ripiego (0,8–1,7 a partita), come dovevano
essere. In tutto **10,7 case a partita a tre, 3,6 a testa** su 15,1 edifici: le case danno
8,1 Lampo a testa, un terzo del Lampo totale. Il Lampo 3 a costo 2 nelle ere 4–5 è più
efficiente di gran parte del mazzo, ed è per questo che tutti lo comprano.

Da decidere: se le case con lo Scavo restano (oggi sono quattro sagome che non si giocano), e
se il Lampo delle case grandi nelle ere 4–5 va portato a 2 per farne un ripiego anche lì.

## Diciassettesima misura: le case ritoccate

Decisione del designer dopo la sedicesima misura (registro 117): le case con lo Scavo, che
nessuno comprava, prendono anche il Lampo della piccola (Ripari, Tuguri, Casupole: Lampo 1 e
Scavo 2; Case popolari: Lampo 2 e Scavo 2), allo stesso costo e resistenza; le case grandi delle
ere 4–5 (Palazzetto, Condominio popolare), che finivano quasi ogni partita, scendono da Lampo 3 a
2. Stessi tornei della sedicesima misura, stessi semi; "riserva" è la sedicesima, "ritocco" è oggi.

| per giocatore | a 2: senza | a 2: riserva | **a 2: ritocco** | a 3: senza | a 3: riserva | **a 3: ritocco** | a 4: senza | a 4: riserva | **a 4: ritocco** |
|---|--:|--:|--:|--:|--:|--:|--:|--:|--:|
| PV | 83,3 | 84,1 | 83,4 | 88,7 | 90,4 | 90,2 | 78,3 | 81,3 | 81,8 |
| Lampo / Rendita / Scavo / Continuità | 19,5 / 10,7 / 14,5 / 12,7 | 21,9 / 10,4 / 13,8 / 14,2 | 20,5 / 10,4 / 14,2 / 14,1 | 21,9 / 9,5 / 16,4 / 13,2 | 25,1 / 9,1 / 15,5 / 15,3 | 23,9 / 9,1 / 16,2 / 15,3 | 18,8 / 8,3 / 14,6 / 11,1 | 21,8 / 8,1 / 14,2 / 13,3 | 21,1 / 8,1 / 15,2 / 13,6 |
| costruiti / passa | 12,8 / 3,0 | 13,6 / 2,5 | 13,6 / 2,4 | 13,8 / 3,2 | 15,1 / 2,0 | 15,2 / 2,0 | 12,0 / 5,4 | 13,4 / 3,9 | 13,7 / 3,7 |
| altezza / basi altrui | 4,58 / 1,6 | 4,57 / 1,6 | 4,58 / 1,6 | 4,56 / 2,4 | 4,56 / 2,3 | 4,56 / 2,3 | 4,40 / 2,3 | 4,39 / 2,3 | 4,41 / 2,4 |
| kingmaker | 12 % | 10 % | 10 % | 15 % | 14 % | 16 % | 15 % | 15 % | 15 % |
| vince: Rendita / Continuità / Bilanciata / Obiettivi / Scavo / Lampo | 53 / 44 / 54 / 53 / 53 / 44 | 53 / 46 / 49 / 50 / 50 / 52 | 56 / 46 / 47 / 52 / 52 / 46 | 35 / 32 / 37 / 32 / 34 / 30 | 30 / 29 / 36 / 35 / 31 / **39** | 35 / 29 / 33 / 32 / 31 / **40** | 27 / 21 / 25 / 25 / 23 / 28 | **33** / 21 / 25 / 26 / 21 / 24 | **32** / 21 / 26 / 26 / **19** / 26 |

**1. Il ritocco toglie Lampo senza togliere case.** Il Lampo a testa scende di 1–1,5 punti
rispetto alla riserva (a 3: 25,1 → 23,9), i PV totali tornano quasi a quelli senza case a due
(83,4) e restano sopra a tre e a quattro; edifici, passaggi, altezza e basi altrui non si
muovono. Lo Scavo risale di mezzo punto (a 4: 14,2 → 15,2): le case con lo Scavo ora si
comprano e qualcuno ci costruisce sopra.

**2. Quali case si comprano (vita delle carte a tre, 2000 partite).** Copie costruite su 4000.

| era | 1 | 2 | 3 | 4 | 5 |
|---|--:|--:|--:|--:|--:|
| piccola | **0** | 87 | **4** | 2617 | 3890 |
| grande | 1610 | 401 | 3176 | 562 | 2569 |
| con lo Scavo | 232 | 1588 | 526 | **3884** | – |
| case a partita | 0,9 | 1,0 | 1,9 | 3,5 | 3,2 |

Come previsto nel registro 117, **la casa con lo Scavo ha sostituito la piccola nelle ere
1–3**: a pari costo e resistenza vale di più, e la piccola non si compra più (0 / 87 / 4 copie).
Nelle ere 4–5 la grande non è più la prima scelta: il Palazzetto scende da 3989 a 562 copie
(costa un Denaro in più della Casa borghese per lo stesso Lampo 2), il Condominio da 3969 a 2569,
comprato quando le due Palazzine sono finite. Le Case popolari (Lampo 2, Scavo 2, costa un'Idea)
sono la casa più comprata del gioco: 3884 copie su 4000, e da sole 1,9 PV di Scavo a partita a chi
ci costruisce sopra. In tutto 10,6 case a partita, 3,5 a testa: come prima.

**3. Le strategie sul bordo restano sul bordo.** A tre il Lampo vince il 40 % (39 con la
riserva, bordo 38); a quattro la Rendita il 32 % (33, bordo 29) e lo Scavo il 19 (bordo 21). A due
tutto dentro (46–56). Non è il Lampo delle case: con il Lampo tagliato la strategia Lampo a tre
sale di un punto. È la loro presenza: a tre chi punta al Lampo non passa più mai (2,0 passaggi
contro 3,2), a quattro la Rendita è l'unica che non spende turni in case e la sua rendita vale
di più con un mercato che gli altri lasciano stare. Le tabelle dei bot per tre e quattro
giocatori (quattordicesima misura) sono state tarate senza le case: il prossimo passo, se si
vuole rientrare nell'errore, è ritararle, non toccare le case.

Deciso dal designer: la piccola nelle ere 1–3, che oggi non si compra, resta come terza e
quarta copia della casa da 1.

## Diciottesima misura: i bot con le case

Il designer ha chiesto di ritarare i bot a tre e a quattro (registro 118): con le case della
riserva la Lampo vinceva il 40 % a tre (bordo 38) e a quattro la Rendita il 32 % (bordo 29) e
la Scavo il 19 (bordo 21). Stesso metodo della quattordicesima misura: le spinte sono handicap
rispetto al valutatore comune, quindi si spinge di più chi vince troppo e di meno chi vince
poco. Torneo `--giro tutte`, 750 partite, seme 700000, file v2 con le case ritoccate.

| vince a tre (atteso 33, errore 28–38) | base | Lampo 2,0 | Lampo 2,5 | pot. Lampo 2 | Lampo 2,0 + pot. 2 | Lampo 2,0 + Rendita 1,2 |
|---|--:|--:|--:|--:|--:|--:|
| Lampo | **40** | 30 | 22 | 35 | 22 | 30 |
| Rendita | 35 | 38 | 37 | 38 | 38 | 37 |
| Bilanciata / Obiettivi / Scavo / Continuità | 33 / 32 / 31 / 29 | 35 / 35 / 32 / 30 | 39 / 35 / 34 / 33 | 35 / 33 / 31 / 29 | 36 / 38 / 35 / 32 | 35 / 34 / 33 / 30 |

| vince a quattro (atteso 25, errore 21–29) | base | Rendita 1,2 | Rendita 1,5 | Scavo ¼ | Rendita 1,2 + Scavo ¼ | **Rendita 1,5 + Scavo ¼** | + Lampo 1,0 |
|---|--:|--:|--:|--:|--:|--:|--:|
| Rendita | **32** | 29 | 28 | 31 | 30 | 28 | 32 |
| Scavo | **19** | 19 | 19 | 23 | 23 | 23 | 23 |
| Lampo | 26 | 27 | 29 | 25 | 26 | 28 | 28 |
| Bilanciata / Obiettivi / Continuità | 26 / 26 / 21 | 26 / 25 / 23 | 25 / 25 / 24 | 26 / 25 / 20 | 25 / 24 / 22 | 25 / 23 / 23 | 24 / 23 / 20 |

**1. A tre basta la spinta Lampo a 2,0.** Da 1,6 a 2,0 la Lampo scende da 40 a 30 e tutte le
altre restano dentro (Rendita 38 sul bordo); a 2,5 crolla a 22 e la Bilanciata sale a 39. I
potenziamenti a 2 da soli non bastano (35). Aggiungere la Rendita a 1,2 non sposta niente
(37): si lascia la spinta sola.

**2. A quattro servono due cose.** La Rendita si abbassa solo a 1,5 (32 → 28), lo Scavo si
rialza solo con le spinte a un quarto (premio 0,2, Scavo a terra 0,1: 19 → 23); insieme tutte
e sei le strategie stanno fra 23 e 28. Riportare il Lampo a 1,0 rialza la Rendita a 32 senza
toccare il Lampo: non si fa.

**3. La partita non cambia.** PV, edifici, passaggi, altezza e basi altrui sono gli stessi
al decimale in tutti i lotti (a 3: 90,2–91,2 PV; a 4: 81,5–81,8): le spinte spostano solo chi
vince, non come si gioca. Kingmaker 14 % a tre e 17 % a quattro.

Le tabelle del bot: `SPINTE_V2_PER_GIOCATORI[3]` con `lampo` 2,0; `[4]` con `lampo` 0,8,
`lampo_potenzia` 5, `rendita_per_era` 1,5, `scavo_premio` 0,2, `scavo_terra_scavo` 0,1. A due
la tabella base va bene (46–56, tutte dentro). Rigiocato senza manopole:

| vince (atteso 50 / 33 / 25, errore 6 / 5 / 4) | a 2 | a 3 | a 4 |
|---|--:|--:|--:|
| Rendita | 56 | 38 | 28 |
| Bilanciata | 47 | 35 | 25 |
| Obiettivi | 52 | 35 | 23 |
| Continuità | 46 | 30 | 23 |
| Lampo | 46 | 30 | 28 |
| Scavo | 52 | 32 | 23 |

**Tutte entro l'errore a tutti e tre i tavoli**, con la Rendita a due e a tre sul bordo alto.
La v1.5 non cambia (`SPINTE_V1` uguale, riferimento identico).

## Diciannovesima misura: le tessere dell'era

Decisione del designer (registro 121, `docs/proposte/tessere-v2.md`): il terreno ha una
produzione di base fissa (Pianura e Collina 1 Costruzione, Fiume 1 Denaro, Bosco 1 Idea) e ogni
era su ogni colonna si posa una tessera dell'era, pescata fra le 14 dell'era (7 diverse in due
copie), che aggiunge da zero a una icona di produzione e un effetto una volta per era, solo per
la colonna scelta dal giocatore. A tre giocatori la produzione totale è tarata per restare
quella di prima, era per era. Le scelte delle tessere ("può cambiare", "a scelta") sono
automatiche e prudenti. Torneo `--giro tutte`, 750 partite, seme 700000, bot tarati della
diciottesima misura; "senza" è il file v2 di prima (`--tessere_era 0` lo rigioca identico).

| per giocatore | a 2: senza | **a 2: tessere** | a 3: senza | **a 3: tessere** | a 4: senza | **a 4: tessere** |
|---|--:|--:|--:|--:|--:|--:|
| PV | 83,4 | **91,1** | 90,6 | 93,0 | 81,6 | 86,2 |
| Lampo / Rendita / Scavo / Continuità | 20,5 / 10,4 / 14,2 / 14,1 | 24,9 / 10,1 / 16,0 / 15,5 | 24,4 / 9,0 / 16,5 / 15,4 | 25,8 / 8,7 / 17,6 / 15,4 | 21,0 / 8,2 / 15,1 / 13,5 | 23,6 / 7,7 / 16,6 / 14,0 |
| costruiti / passa | 13,6 / 2,4 | 15,1 / 1,7 | 15,2 / 2,0 | 15,4 / 1,8 | 13,6 / 3,8 | 14,3 / 3,0 |
| altezza / basi altrui | 4,58 / 1,6 | 4,65 / 1,9 | 4,55 / 2,4 | 4,58 / 2,5 | 4,39 / 2,3 | 4,57 / 2,6 |
| kingmaker (cambia vincitore) | 10 % | 10 % | 15 % | 14 % | 17 % | **18 %** |
| vince: Rendita / Continuità / Bilanciata / Obiettivi / Scavo / Lampo | 56 / 46 / 47 / 52 / 52 / 46 | 50 / 42 / 46 / 53 / 48 / **61** | 38 / 30 / 35 / 35 / 32 / 30 | 36 / 29 / 38 / **28** / 30 / **41** | 28 / 23 / 25 / 23 / 23 / 28 | 27 / 20 / 23 / 26 / 25 / 30 |

**1. La partita si arricchisce, soprattutto a due.** Più punti a tutti i tavoli (+7,8 a testa a
due, +2,4 a tre, +4,6 a quattro), più edifici e meno passaggi. A due i Fiumi sono uno solo e le
Pianure due, quindi nelle ultime ere arriva più Costruzione e meno Denaro di prima (la stima
del documento delle tessere), e sopra ci sono gli effetti: un edificio e mezzo in più a testa.
La città cresce di più in altezza e sopra gli altri (basi altrui +0,3 a due e a quattro).

**2. La Lampo ne approfitta.** Cinque tessere danno Lampo (Radura, Eremo, Belvedere, Isolato,
Quartiere alto) e gli sconti fanno costruire di più: la strategia Lampo vince il **61 %** a due
(bordo 56) e il **41 %** a tre (bordo 38); a quattro sta al 30, sul bordo. A tre la Obiettivi
scende al **28 %** (bordo 28). Le altre stanno nell'errore.

**3. Il kingmaker non cambia** a due e a tre (10 e 14 %); a quattro sale da 17 a 18 %, e il bottino
dell'ultima era copre il distacco in una partita su tre (34 % contro 30).

**4. Quante volte scatta ogni tessera (a partita).**

| era | tessera | a 2 | a 3 | a 4 |
|--:|---|--:|--:|--:|
| 1 | Sentiero dei pastori / Terra di nessuno / Recinto di pietre / Luogo sacro | 0,6–0,7 | 0,9–1,0 | 1,1–1,3 |
| 1 | Campi arati / Radura | 0,3 | 0,4–0,5 | 0,4–0,7 |
| 1 | **Raccoglitori** | **0** | **0** | **0** |
| 2 | Via consolare / Cambiavalute / Necropoli / Cantiere | 0,5–0,7 | 0,7–1,0 | 0,8–1,3 |
| 2 | Centuriazione / Statio | 0,1 | 0,2 | 0,2–0,4 |
| 2 | **Restauratori** | **0,01** | **0,02** | **0,03** |
| 3 | Rocca / Fiera | 0,5–0,6 | 0,8–0,9 | 1,0–1,1 |
| 3 | Eremo / Scuola dei mastri / Borgo franco / Mura | 0,1–0,4 | 0,1–0,5 | 0,2–0,6 |
| 3 | **Spoglio delle rovine** | **0,02** | **0,03** | **0,06** |
| 4 | Bottega / Piazza del mercato / Belvedere | 0,5–0,7 | 0,7–1,0 | 0,7–1,2 |
| 4 | Cappella di famiglia / Villa di campagna / Fondaco | 0,1 | 0,1–0,2 | 0,1–0,3 |
| 4 | **Giardino all'italiana** | **0,01** | **0,01** | **0,02** |
| 5 | Parco pubblico / Isolato / Periferia / Zona industriale | 0,4–0,7 | 0,6–1,0 | 0,8–1,3 |
| 5 | Scuola politecnica / Quartiere alto / Orto botanico | 0,1–0,2 | 0,1–0,3 | 0,2–0,3 |

Quattro tessere **non scattano quasi mai**. Raccoglitori mai: la scelta automatica cambia l'Idea
in Costruzione solo se le Idee sono più della Costruzione, e non succede. Restauratori e
Giardino all'italiana chiedono una ristrutturazione nella colonna scelta, e nella v2 se ne fanno
0,4 a partita. Spoglio delle rovine chiede una sepoltura con premio nella colonna scelta.

Da decidere: se sostituire le quattro tessere che non scattano; se togliere Lampo dalle tessere
(o ritarare il bot Lampo a due e a tre); se il più di punti a due giocatori va bene o si
riduce la produzione delle tessere.

## Ventesima misura: le caselle

Decisioni del designer (registro 122): la strada diventa una griglia di caselle (colonna per
binario) e ogni casella ha la sua pila. Il binario lo sceglie chi costruisce. Le carte quadrate
occupano una colonna per due binari. Colosseo, Castello e Fortezza sono 2x2, il Grattacielo è
1x3; questi quattro vanno solo sopra, con le regole di sempre, e si coprono solo in rovina. Il
terrapieno si paga per casella vuota. Torneo `--giro tutte`, 750 partite, seme 700000, contro la
diciannovesima misura (tessere dell'era).

| per giocatore | a 2: tessere | **a 2: caselle** | a 3: tessere | **a 3: caselle** | a 4: tessere | **a 4: caselle** |
|---|--:|--:|--:|--:|--:|--:|
| PV | 91,1 | 93,7 | 93,0 | 95,3 | 86,2 | 88,9 |
| Lampo / Rendita / Scavo / Continuità | 24,9 / 10,1 / 16,0 / 15,5 | 25,7 / 9,9 / 21,1 / 14,6 | 25,8 / 8,7 / 17,6 / 15,4 | 26,7 / 8,8 / 21,7 / 14,8 | 23,6 / 7,7 / 16,6 / 14,0 | 24,1 / 8,0 / 21,6 / 13,2 |
| altezza massima / basi altrui | 4,65 / 1,9 | 3,51 / 2,2 | 4,58 / 2,5 | 3,65 / 2,8 | 4,57 / 2,6 | 3,52 / 3,0 |
| kingmaker (cambia vincitore) | 10 % | 10 % | 14 % | 13 % | 18 % | 13 % |
| vince: Rendita / Continuità / Bilanciata / Obiettivi / Scavo / Lampo | 50 / 42 / 46 / 53 / 48 / 61 | 42 / 43 / 49 / 50 / 49 / **66** | 36 / 29 / 38 / 28 / 30 / 41 | 30 / **25** / 32 / 35 / 31 / **48** | 27 / 20 / 23 / 26 / 25 / 30 | 23 / 19 / 22 / 23 / 22 / **41** |

**1. Più Scavo, città più bassa.** Ogni casella ha la sua pila, quindi si costruisce sopra più
spesso e più in basso: lo Scavo sale di 4-5 punti a testa, l'altezza massima scende di un
livello. I punti crescono di 2,3-2,7 a testa.

**2. La Lampo esce dall'errore a tutti i tavoli**: 66 % a due (bordo 56), 48 % a tre (bordo 38),
41 % a quattro (bordo 31). A tre la Continuità scende al 25 % (bordo 28). Il kingmaker scende a
quattro (da 18 a 13 %).

**3. Le carte grandi si costruiscono.** In 750 partite a tre: Colosseo 387, Castello 333,
Fortezza 221, Grattacielo 336; le quadrate da 12 (Castrum) a 749 (Circolo di pietre). Con la
prima lettura, "una rovina sotto ogni casella", il Colosseo si costruiva 2 volte e il Castello
12: la regola è diventata "solo sopra, con le regole di sempre".

Da decidere: come riportare la Lampo nell'errore (ritarare il bot, togliere Lampo dalle
tessere, o abbassare i Lampo alti delle carte).

## Ventunesima misura: i potenziamenti raddoppiati

Richiesta del designer (registro 123): altri 25 potenziamenti, dieci diversi per era, con la
stessa economia e la stessa forza dei primi 25. Torneo `--giro tutte`, 750 partite, seme
700000, contro la ventesima misura (caselle).

| per giocatore | a 2: caselle | **a 2: potenziamenti** | a 3: caselle | **a 3: potenziamenti** | a 4: caselle | **a 4: potenziamenti** |
|---|--:|--:|--:|--:|--:|--:|
| PV | 93,7 | 93,3 | 95,3 | 95,1 | 88,9 | 89,1 |
| PV dai potenziamenti (cultura) / Idee prodotte | 4,6 / 12,5 | 3,9 / 13,1 | 5,0 / 14,6 | 4,3 / 15,2 | 4,3 / 13,6 | 3,8 / 14,2 |
| kingmaker (cambia vincitore) | 10 % | 8 % | 13 % | 14 % | 13 % | 15 % |
| vince: Rendita / Continuità / Bilanciata / Obiettivi / Scavo / Lampo | 42 / 43 / 49 / 50 / 49 / 66 | **36** / 43 / 52 / 52 / 52 / **66** | 30 / 25 / 32 / 35 / 31 / 48 | 31 / 28 / 33 / 32 / 30 / **48** | 23 / 19 / 22 / 23 / 22 / 41 | 27 / **15** / **18** / 24 / 20 / **46** |

**1. Cambia poco.** I punti restano gli stessi (meno di mezzo punto di differenza). I
potenziamenti nuovi danno qualche PV subito in meno e qualche Idea in più (Focolare, Terme,
Stamperia).

**2. La Lampo resta fuori dall'errore** a tutti i tavoli, come nella ventesima misura. A due la
Rendita scende al 36 % (bordo 44); a quattro Continuità e Bilanciata scendono al 15 e 18 %
(bordo 19). È lo stesso squilibrio della ventesima misura, non viene dai potenziamenti.

## Ventiduesima misura: il Lampo al massimo 2

Dopo le caselle la strategia Lampo vinceva il 66/48/46 % a 2/3/4 giocatori (ventesima e
ventunesima misura). Il designer: "prova le tre strade e applica quella migliore o la
combinazione migliore" (registro 125). Prima uno screening a 300 partite per tavolo (torneo
`--giro tutte`, seme 700000), poi la scelta a 750.

| vince la Lampo (a 2 / 3 / 4) | PV a testa a 3 |
|---|--:|
| oggi: 67 / 44 / 48 % | 95,4 |
| bot ritarato (`--spinta lampo=2.6`): 46 / 38 / 36 % | 95,4 |
| niente Lampo dalle tessere dell'era (`--tessere_lampo 0`): 67 / 41 / 48 % | 94,4 |
| Lampo delle carte al massimo 3 (`--lampo_tetto 3`): 68 / 49 / 46 % | 92,2 |
| Lampo delle carte al massimo 2 (`--lampo_tetto 2`): 56 / 45 / 39 % | 86,8 |
| **tetto 2 e bot ritarato**: 48 / 30 / 32 % | 87,2 |

Le tessere e il tetto a 3 non cambiano niente. Il tetto a 2 è l'unica correzione del gioco che
morde, ma da sola non basta; con il bot ritarato a 3 giocatori tutte e sei le strategie stanno
fra il 30 e il 38 %. Applicato: nessun edificio dà più di 2 Lampo (16 carte, da ristampare
comunque per le icone), spinta del bot Lampo 2,6 a 2 e 3 giocatori e 3,2 a 4.

Controllo a 750 partite:

| vince (a 2 / 3 / 4) | prima | **dopo** |
|---|--:|--:|
| Lampo | 66 / 48 / 46 | **49 / 30 / 25** |
| Rendita | 36 / 31 / 27 | 40 / 35 / 29 |
| Continuità | 43 / 28 / 15 | 52 / 35 / 19 |
| Bilanciata | 52 / 33 / 18 | 50 / 33 / 24 |
| Obiettivi | 52 / 32 / 24 | 54 / 34 / 31 |
| Scavo | 52 / 30 / 20 | 55 / 32 / 22 |
| PV a testa | 93,3 / 95,1 / 89,1 | 86,2 / 87,2 / 82,6 |
| kingmaker | 8 / 14 / 15 % | 9 / 15 / 17 % |

A tre giocatori tutte nell'errore. A due la Rendita resta sotto (40 %, bordo 44), a quattro la
Continuità sotto (19 %, bordo 21) e la Obiettivi sopra (31 %, bordo 29): di poco, e sono
aggiustamenti del bot. I punti scendono di 6-8 a testa: è il Lampo tolto alle 16 carte.

## Ventitreesima misura: l'era 4, le risorse e le carte morte

Il rapporto delle partite (registro 125) ha trovato tre problemi; il designer: "rivediamo gli
eventi dell'era 4 [...] per il tetto delle risorse sì, è il problema più serio [...] e poi le
carte morte bisogna sistemarle" (registro 126). Screening a 200-300 partite per tavolo col
rapporto acceso, poi la scelta a 750.

**Gli eventi dell'era 4.** Un edificio crolla se la forza supera la sua resistenza di 2; la
forza sale di 1 a ogni era (2, 3, 4, 5), la resistenza media degli edifici resta fra 2,5 e 2,9.
A forza 5 crollava l'87 % degli edifici dell'era 4 nell'evento della loro era.

| forza degli eventi | crollano gli edifici dell'era 3 / dell'era 4 |
|---|--:|
| 4 e 5 (prima) | 45-56 % / 87 % |
| 4 e 4 | 45-56 % / 66-74 % |
| 3 e 4 | 14-22 % / 66-75 % |
| 3 e 3 | 13-14 % / 17-20 % |
| **4 e 3 (scelta)** | 42-51 % / 16-17 % |

**Il tetto delle risorse.** Si buttavano a fine era 11-12 Costruzione e 6-9 Denaro a testa; le
Idee mai. Alzare il tetto (4 e 8, 5 e 10) toglieva poco (8-10 buttate), perché la Costruzione
entra più di quanto si spende; la Collina a Idee spostava produzione senza fermare lo spreco.
**L'avanzo in Idee** (ogni 2 risorse oltre il tetto diventano 1 Idea) le dimezza: 7 buttate,
4 Idee in più a testa.

**Le carte morte.** Correzioni approvate dal designer, più un secondo ritocco su quelle che
restavano ferme. Le case piccole delle ere 1-3 erano identiche alle case dello Scavo con meno
Scavo. Per i potenziamenti dell'era 1 la prima prova (potenziare anche nella colonna adiacente)
faceva salire gli Scheletri da 8 a 22 PV a testa e affondava la Rendita (36/21/14 %): scartata;
la scelta è la fila dei potenziamenti che resta un'era.

Controllo a 750 partite (a quattro, due metà di 375 semi):

| a 2 / 3 / 4 giocatori | prima (ventiduesima) | **dopo** |
|---|--:|--:|
| vince Obiettivi | 54 / 34 / 31 | 59 / 38 / 32 |
| vince Continuità | 52 / 35 / 17 | 46 / 36 / 24 |
| vince Scavo | 55 / 32 / 21 | 53 / 36 / 21 |
| vince Bilanciata | 50 / 33 / 26 | 54 / 33 / 23 |
| vince Rendita | 40 / 35 / 29 | 50 / 27 / 25 |
| vince Lampo | 49 / 30 / 26 | 38 / 30 / 25 |
| PV a testa | 86,1 / 87,2 / 82,6 | 87,5 / 85,3 / 81,6 |
| edifici costruiti a testa | 15,7 / 15,8 / 14,6 | 17,0 / 16,6 / 15,7 |
| Costruzione / Denaro buttati | 12,5 / 6,0 · 10,9 / 9,3 · 11,4 / 8,4 | 8,0 / 7,0 · 7,0 / 9,3 · 6,9 / 8,4 |
| Scavo / Lampo (PV a testa) | 20,6 / 21,2 · 21,4 / 21,3 · 21,0 / 19,9 | 14,5 / 23,2 · 14,3 / 22,7 · 14,3 / 21,8 |
| kingmaker (cambia vincitore) | 9 / 15 / 17 % | **6 / 6 / 10 %** |

Fuori di poco: a due Obiettivi (59, bordo 56) e Lampo (38, bordo 44); a tre Rendita (27, bordo
28); a quattro Obiettivi (32, bordo 29). Aggiustamenti da bot. Restano ferme Capanne di fango e
Case a schiera, i tre potenziamenti Struttura dell'era 1 e il Cemento armato; il Restauratore
riesce una volta su cinque. Resoconto completo nell'artifact del rapporto delle partite.

## Ventiquattresima misura: i bot ritarati

Dopo la ventitreesima misura restavano piccoli scarti fra le strategie; il designer: "ritara i
bot" (registro 127). Screening a 300 partite per tavolo: il peso della Obiettivi va abbassato
per indebolirla (0,6 a quattro la porta da 32 a 29 %), il Lampo a due va abbassato (2,0 la
riporta da 38 a 51 %). Scelti: a due Lampo 2,0 e Obiettivi 0,6; a tre Obiettivi 0,7; a
quattro Lampo 2,8 e Obiettivi 0,6. Controllo a 750 partite (a quattro, due metà di 375 semi):

| vince (a 2 / 3 / 4) | prima | **dopo** |
|---|--:|--:|
| Lampo | 38 / 30 / 25 | 54 / 31 / 30 |
| Rendita | 50 / 27 / 25 | 46 / 27 / 28 |
| Continuità | 46 / 36 / 24 | 44 / 36 / 24 |
| Bilanciata | 54 / 33 / 23 | 52 / 33 / 21 |
| Obiettivi | 59 / 38 / 32 | 54 / 36 / 27 |
| Scavo | 53 / 36 / 21 | 51 / 38 / 20 |
| scarto massimo | 21 / 11 / 11 | 10 / 10 / 9 |
| kingmaker | 6 / 6 / 10 % | 5 / 5 / 9 % |

A due tutte nell'errore; a tre la Rendita (27, bordo 28) e a quattro Lampo (30, bordo 29) e
Scavo (20, bordo 21) stanno a un punto dal bordo, dentro il rumore della misura. Le regole non
cambiano: sono pesi del bot.

## Venticinquesima misura: i potenziamenti solo sulla stessa classe

Il designer, sul confronto con i potenziamenti stampati (registro 129): valgono i dati, via i
dodici bonus di classe, ogni potenziamento va solo su un edificio della sua classe, Cemento
armato +2 Resistenza. Stessi semi e stessi bot della ventiquattresima, 750 partite per tavolo
(a tre e a quattro ripresi con `--da` dopo un'interruzione: la partita 700554 rigiocata e'
identica):

| a 2 / 3 / 4 | prima | **dopo** |
|---|--:|--:|
| vince Lampo | 54 / 31 / 30 | 48 / 28 / 22 |
| vince Rendita | 46 / 27 / 28 | 46 / 29 / 24 |
| vince Continuità | 44 / 36 / 24 | 50 / 37 / 25 |
| vince Bilanciata | 52 / 33 / 21 | 49 / 35 / 26 |
| vince Obiettivi | 54 / 36 / 27 | 55 / 35 / 29 |
| vince Scavo | 51 / 38 / 20 | 53 / 36 / 24 |
| scarto massimo | 10 / 10 / 9 | 9 / 9 / 7 |
| kingmaker | 5 / 5 / 9 % | 4 / 7 / 11 % |
| potenziamenti per giocatore | 2,9 / 2,9 / 2,9 | 2,3 / 2,2 / 2,0 |
| PV dagli Scheletri | 8,5 / 8,3 / 8,0 | 6,3 / 6,0 / 5,3 |
| PV medi | 87 / 85 / 82 | 86 / 84 / 79 |

Tutte le strategie dentro l'errore a ogni tavolo, per la prima volta anche a quattro senza
nessuna al bordo. Si potenzia un quarto in meno (il bersaglio giusto non c'e' sempre), e con
meno potenziamenti calano gli Scheletri, che nascono da li'. Quello che cambia di piu' e'
*quali* potenziamenti si prendono: prima i "struttura" erano quasi morti (Fondamenta in
pietra 0,02 a partita a quattro, Argine 0,03, Cemento armato 0,01) perche' i bonus di classe
facevano vincere gli altri; ora Fondamenta 0,20, Argine 0,15, Cemento armato 0,04. Sotto il 3%
delle partite restano 5 / 3 / 1 potenziamenti su 50 (prima 4 / 4 / 4); il piu' raro e' la
Palizzata (0,01 a quattro). Il kingmaker a quattro sale di due punti, dentro il rumore.

## Ventiseiesima misura: le tessere scavo

La proposta del designer (registro 130, `docs/proposte/tessere-scavo.md`): la rovina pesca dal
mazzetto del proprietario una tessera coperta per casella, un edificio dell'era 5 costruito
sopra le scopre, a fine partita il proprietario incassa le scoperte per intero e le coperte a
metà, più scheletri e potenziamenti delle tessere scoperte. Variante
`data/proposte/cards-v2-tessere_scavo.json`, stessi semi della venticinquesima. I bot non
guardano le tessere, quindi le partite sono le stesse e cambia solo il conto finale: il
confronto è a coppie, partita per partita.

| a 2 / 3 / 4 | Scavo stampato | **tessere** |
|---|--:|--:|
| PV di fine partita dal proprio Scavo | 5,2 / 5,2 / 5,2 | 5,0 / 5,7 / 5,5 |
| la loro dispersione (dev. std.) | 3,3 / 3,6 / 3,6 | 3,9 / 4,4 / 4,3 |
| di cui da tessere scoperte | – | 84 / 82 / 80 % |
| tessere pescate per giocatore | – | 3,6 / 3,8 / 3,8 (max 12) |
| vince la Scavo | 53 / 36 / 24 | 52 / 34 / 24 |
| scarto massimo fra strategie | 9 / 9 / 7 | 8 / 9 / 6 |
| kingmaker | 4 / 7 / 11 % | 3 / 7 / 12 % |
| vincitore diverso dallo Scavo stampato | – | 7 / 12 / 12 % |

I punti restano gli stessi in media: le tessere valgono quanto lo Scavo stampato che
sostituiscono, con un po' più di dispersione (+0,6–0,8 PV di deviazione). Un giocatore guadagna
o perde fino a 12–15 PV rispetto allo Scavo stampato, ma la differenza tipica è di 3 PV. Il
vincitore cambia nel 7 / 12 / 12 % delle partite: sono quelle chiuse, perché il distacco fra
primo e secondo è di 2 PV o meno nell'8 / 14 / 17 % delle partite. L'equilibrio fra le
strategie non si muove. Quattro quinti dei punti vengono da tessere scoperte: l'era 5 scava
quasi tutto, quindi la metà delle coperte pesa poco. Il mazzetto da 20 è largo: se ne pescano
meno di 4. Non misurato: un giocatore umano che costruisce apposta sulle proprie rovine per
scoprirle, cosa che i bot non fanno.

## Ventisettesima misura: le rovine a tessere, i flussi e i bot ritarati

Il pacchetto dei registri 130-136 nel file v2: la rovina lascia le tessere scavo del proprietario
(mazzetto di 20, scheletri per era e arte) e la sua carta torna al proprietario; il premio di chi
costruisce sopra conta 2 PV per tessera x livello; i potenziamenti sono token, uno per casella, e
quelli arte riscattati si ritrovano con le icone; niente ristrutturare; le rovine non contano per
le regole di mappa; la Continuita' e' una collezione a soglie (3/5/7/9 edifici della stessa classe:
3/5/8/12 PV); il Lampo delle ere 4-5 scende a 1 e la Rendita 1 sale a 2.

Prima misura con i bot di prima (circa 300 partite per tavolo): la Continuita' di colonna crollava
da 16 a 3 PV (registro 131, da cui la collezione), la Lampo vinceva il 22 / 10 % a tre e quattro, la
Rendita il 20 % a ogni tavolo. Ritaratura in tre giri da 300 partite: la Rendita scartava le carte
senza Rendita (l'80 % del mazzo) e restava al 20 % qualunque peso avesse; senza quella penalita'
torna in media. Il premio di scavo nel bot rafforzava la Scavo (34-39 % a quattro con peso 0,6):
a zero la riporta al 26 %. La Lampo torna in media con meno peso. Conferma a 750 partite:

| PV medi per giocatore (a 2 / 3 / 4) | |
|---|--:|
| Lampo | 13,5 / 14,5 / 15,2 |
| Rendita | 24,3 / 20,2 / 16,9 |
| Scavo (premio + tessere) | 13,2 / 15,4 / 16,0 |
| Continuita' | 15,9 / 16,1 / 15,6 |
| Scheletri | 9,0 / 8,7 / 8,7 |
| Personaggi e potenziamenti (cultura) | 5,4 / 5,7 / 5,0 |
| effetti finali | 5,1 / 4,9 / 4,9 |
| Eredita' | 2,8 / 2,9 / 2,7 |
| Monumenti | 1,4 / 1,9 / 2,4 |
| di cui arte ritrovata | 0,5 / 0,5 / 0,4 |
| totale | 90 / 90 / 87 |

| vince (a 2 / 3 / 4) | |
|---|--:|
| Lampo | 52 / 27 / 18 |
| Rendita | 51 / 32 / 27 |
| Continuita' | 44 / 34 / 27 |
| Bilanciata | 45 / 33 / 25 |
| Obiettivi | 55 / 35 / 30 |
| Scavo | 52 / 38 / 24 |
| kingmaker | 3 / 6 / 7 % |

I quattro flussi principali stanno fra 13 e 17 PV a tre e quattro giocatori; a due la Rendita
arriva a 24, perche' crollano meno edifici e restano in piedi piu' a lungo (le regole non cambiano
col numero di giocatori). A due tutte le strategie dentro l'errore; a tre e a quattro la Lampo sta
appena sotto la banda e gli Obiettivi appena sopra a quattro. Il kingmaker scende (era 4 / 7 / 11 %).
Un giocatore riscatta in media 0,5-0,7 token arte e pesca 3,5-3,9 tessere (al massimo 12).

## Ventottesima misura: senza la Prosperita' Urbana

Il designer: "togli la Prosperita' se il denaro e' abbondante e avanza a ogni
era". Si conta il Denaro che ogni giocatore ha in mano a fine era, prima delle
entrate di fine era (contatore `oro_avanzo_eN`), con la Prosperita' e senza
(`--prosperita 99`, nessuna colonna e' un Centro). Seme 700000, tutte le
strategie; 72/31/15 partite a 2/3/4 giocatori con, 73/32/15 senza.

| giocatori | | era 1 | era 2 | era 3 | era 4 | era 5 | oro dal Centro | PV |
|---|---|---|---|---|---|---|---|---|
| 2 | con | 1,8 | 4,7 | 5,4 | 8,2 | 8,1 | 9,3 | 87,1 |
| 2 | senza | 1,8 | 3,6 | 3,3 | 5,7 | 4,9 | – | 86,9 |
| 3 | con | 2,3 | 5,5 | 6,6 | 8,7 | 10,8 | 11,1 | 86,3 |
| 3 | senza | 2,3 | 4,3 | 4,0 | 5,8 | 6,5 | – | 85,9 |
| 4 | con | 1,7 | 4,9 | 5,7 | 8,1 | 9,6 | 9,7 | 87,9 |
| 4 | senza | 1,7 | 3,9 | 3,6 | 5,5 | 6,5 | – | 86,2 |

Il Centro dava 9-11 Denaro a partita a testa, e quasi tutto avanzava: senza,
a fine era restano comunque 3-6 Denaro dall'era 2 in poi. Chi chiude un'era a
zero e' raro (al massimo 8% in un'era a quattro; l'era 1, 12% a quattro, e'
uguale con e senza perche' li' il Centro non si forma quasi mai). I PV medi
non si muovono (meno di 2). La condizione del designer e' soddisfatta: la
Prosperita' esce dal file v2 (`prosperity.attiva = false`; la v1.5 non
cambia).

## Ventinovesima misura: Lampo 2 sulle carte dell'era 4

La strategia Lampo vinceva poco (registro 136). Proposta: le 11 carte
dell'era 4 tagliate a Lampo 1 (registro 132) tornano a Lampo 2, l'era 5
resta a 1 (`--variante lampo_era4`). Seme 700000, tutte le strategie; 299/300
partite a 3 giocatori, 179 a 4. "Vince" e' la quota di partite vinte su
quelle giocate (alla pari: 33% a tre, 25% a quattro).

| | Lampo a 3 | vince Lampo a 3 | Lampo a 4 | vince Lampo a 4 | PV medi |
|---|---|---|---|---|---|
| regole attuali | 15,7 | 24% | 16,3 | 13% | 85,8 / 83,5 |
| Lampo 2 all'era 4 | 18,7 | 25% | 19,5 | 14% | 88,3 / 87,1 |

Il Lampo sale di 3 PV per TUTTI: il bot Lampo ne prende 22 contro 17-20
degli altri, la stessa distanza di prima (19 contro 14-17). La strategia
Lampo non perde perche' il Lampo vale poco, ma perche' inseguendolo lascia
4-6 PV altrove (82,6 contro 86-87 a tre; 78,6 contro 83-85 a quattro). Una
regola che alza il Lampo per tutti non la aiuta: la variante non entra nel
file v2.

## Trentesima misura: le regole semplici dello scavo, l'evento finale, lo spianare caro

Tutte con l'evento finale (forza 4) e le gilde dell'era Moderna (registri
149-150), contro le regole di main di allora (spianato con tessere, premio
2 PV per tessera per livello). Seme 700000, tutte le strategie, 3 giocatori;
236 partite la base, 199 le regole semplici, 153 le tessere doppie, 200
ciascuna le ultime tre. Medie a giocatore, salvo dove detto.

| | base | semplici 1 PV | tessere doppie | spianare caro | strada corta | caro + corta |
|---|---|---|---|---|---|---|
| bonus/premio di scavo | 10,4 | 2,6 | 2,6 | 4,1 | 2,4 | 4,0 |
| riscoperta | 19,7 | 4,7 | 7,5 | 5,0 | 4,2 | 4,8 |
| Rendita | 20,4 | 13,5 | 13,7 | 20,0 | 13,9 | 19,3 |
| PV totali | 99,5 | 69,1 | 71,9 | 72,9 | 63,1 | 68,6 |
| spianati (a partita) | - | 21,5 | - | 8,9 | 18,6 | 7,5 |
| rovine riscoperte (a partita) | - | 5,4 | - | 5,4 | 4,8 | 5,2 |
| vittorie per strategia | 23-39% | 28-37% | 26-41% | 19-44% | 20-44% | 24-39% |

Le regole semplici portano lo Scavo da 30 a 7 PV: il bonus e' piccolo e si
riscoprono solo circa 5 rovine a partita. Il collo di bottiglia e' l'era 5:
vi si costruiscono 6-7 edifici in tutto (circa 2 a giocatore), e un terzo
delle rovine nasce dall'evento finale, quando nessuno costruisce piu'. Lo
spianare caro (1 Costruzione per casella, niente sconto) riduce gli spianati
da 21,5 a 8,9 e porta piu' costruzioni sulle rovine altrui; la Rendita torna
a 20. La strada corta (una pianura in meno) da sola toglie gioco a tutti e
non aiuta lo Scavo. A 2 e 4 giocatori le regole semplici danno gli stessi
andamenti (Scavo 7-8, Rendita giu' di 7 PV). Proposta al designer: spianare
caro nel file v2, strada invariata, e per la riscoperta lo scavo dell'era
Moderna su tutte le colonne dell'edificio (da misurare).

## Trentunesima misura: l'era 1 della v3, da sola

La prima misura della v3 (registri 153-154): il file generato
`data/proposte/cards-v3-era1.json` con l'era 1 riscritta secondo la scheda
(`docs/proposte/v3-era-1.md`), giocata **da sola** con `--fino_era 1`: la
partita si ferma a era chiusa, evento compreso, e i punti sono quelli presi
nell'era (Lampo, PV prodotti, censimento, Monumenti). Scavo, Continuita' e
finali non si contano: si misureranno con la coppia 1-2. 300 partite, 3
giocatori, seme 700000, tutte le strategie a rotazione. La tabella la fa
`tools/misura_era.py` sulle righe `J` del rapporto. Medie a giocatore.

Due avvertenze sui bot, che spiegano una parte dei numeri: il bot **non sa
che le risorse muoiono** (valuta le mosse come nella v2, dove si portavano
avanti) e **non compra potenziamenti nell'era 1** (si potenzia solo nella
colonna attivata, e i propri edifici stanno sulle colonne gia' attivate;
registro 126 lo diceva gia'). Il Personaggio e la colonna li sceglie provando
ogni coppia su una copia della partita, il draft con una valutazione fissa
della produzione e dell'azione.

### Il budget dell'era

| a giocatore, era 1 | v2 oggi | v3 prova | budget del metro |
|---|---|---|---|
| prodotto | 9,3 | **14,0** (⚒ 8,3 · 🪙 3,2 · 💡 2,5) | 10-12 |
| di cui: terreno / tessera / Personaggi / edifici / azioni | n.d. per era | 4,0 / 3,1 / 4,2 / 1,6 / 1,1 | |
| speso | - | 5,4 | 8-10 |
| **morto** a fine era | (restavano 6,5) | **8,7** (⚒ 3,3 · 🪙 3,5 · 💡 1,8) | 1-2 |
| costruzioni / potenziamenti / passi | - | 3,92 / **0** / 0,08 | 3 / 1 / 0 |
| cambi 1:1 fatti | - | 1,26 | |
| PV dell'era | - | 4,3 (Lampo 2,7 · censimento 1,1 · PV prodotti 0,4) | |
| rovine lasciate all'era 2 | 3,1 | 3,5 | |

Si produce **piu'** di prima (il terreno e la tessera producono come nella
v2, e i Personaggi aggiungono 4,2) e si spende **meno** del budget: quattro
costruzioni da 1-2 Costruzione e nessun potenziamento. Il Denaro muore quasi
tutto (3,5 su 3,2 prodotti piu' i cambi), le Idee per meta'. Il pozzo manca:
e' il punto 6 del metro, confermato al primo colpo.

### Le strategie nell'era 1

| | Bilanciata | Continuita' | Lampo | Obiettivi | Rendita | Scavo |
|---|---|---|---|---|---|---|
| PV dell'era | 3,7 | 3,7 | **6,6** | 4,4 | 3,8 | 3,6 |
| di cui Lampo / censimento | 2,1 / 1,1 | 2,2 / 1,0 | 5,6 / 0,6 | 2,2 / 1,2 | 2,2 / 1,2 | 1,9 / 1,2 |
| morto | 8,7 | 9,2 | 7,8 | 9,1 | 8,5 | 8,8 |
| vittorie (atteso 33, errore ±4) | 25 | 20 | **73** | 35 | 24 | 23 |

La Lampo vince il 73% delle ere 1 giocate da sole: e' atteso, perche' qui si
contano solo i punti dell'era e il Lampo e' l'unico canale che paga subito. La
misura utile non e' chi vince ma il **budget per strategia**: Lampo 5,6 PV
subito contro il budget di 10-12; Rendita 1,2 PV di censimento (contro i 3
del metro), cioe' 4,8 se gli edifici reggono fino alla fine. Tutte le
strategie stanno sotto il metro, e la Rendita a meta'.

### Le carte

Edifici: tutti e dodici del mazzo si costruiscono (le Grotte dipinte 0,74 a
partita, il Focolare 0,44); le case della riserva poco (Case di pietra 0,63,
Ripari 0,37, Capanne di fango mai). All'evento di forza 2 crollano Approdo
61%, Trappole da pesca 54%, Capanne 52%, Ripari 49%, Cava 45% (resistenza 1);
Villaggio palizzato 4% e Grotte dipinte 1% (il 🛡 dei Personaggi va a loro).

Personaggi, giro medio del draft (1 = prima scelta, 4 = l'ultima carta che
arriva da sola): Guerriero **1,11**, Cacciatore 1,22, Tagliapietre 1,43,
Guardiano del fuoco 1,74, Capotribu' 1,79, Anziana 1,82, Costruttore di
zattere 1,99, Barattatore 2,40, Cantastorie 2,70, Incisore 2,91, Portatore di
sale 3,09, Mercante di ossidiana 3,40, Sciamano 3,44, Sentinella 3,53, Pittore
delle grotte 3,60, Custode delle ossa **3,77**. Il Guerriero (+2 resistenza
all'edificio abitato) e' preso quasi sempre per primo da tutte le strategie;
gli ultimi quattro arrivano per scarto. Le azioni scattate a partita:
resistenza 4,1, cambio 3,6, Scavo 2,8, risorsa 2,5, sconto 2,3, PV 1,1,
Lampo 0,8, altri 0,7.

### Cosa dice la misura

1. **Il pozzo e' la prima cosa da sistemare**: 8,7 risorse morte a testa su
   14 prodotte. Tre vie, non esclusive, tutte da misurare: i potenziamenti
   comprabili anche nella colonna adiacente (`--potenzia_adiacente 1`,
   controprova sotto); meno produzione dal tabellone (il terreno di base
   produce 4 e la tessera 3: con i Personaggi che producono 4, il terreno
   potrebbe non produrre piu'); piu' azioni ⇄ e ★ nelle carte.
2. **Il Guerriero e' troppo forte** per il bot (primo a 1,11) e il Custode
   delle ossa troppo debole (3,77): lo Scavo permanente non vale niente in
   una misura che si ferma all'era 1, quindi questo numero va riletto con la
   coppia 1-2.
3. **Il bot va insegnato**: deve sapere che le risorse muoiono (spendere
   all'ultimo giro vale piu' che tenere) e deve potenziare. Finche' non lo sa,
   il morto e' in parte suo e non delle regole.

### Controprova: i potenziamenti nella colonna adiacente

Stesse 300 ere, con `--potenzia_adiacente 1` (registro 126: si potenzia anche
nelle colonne accanto a quella attivata).

| a giocatore | base | potenzia adiacente |
|---|---|---|
| prodotto | 14,0 | 13,9 |
| speso | 5,4 | 5,3 |
| **morto** | 8,7 | **8,6** (⚒ 3,7 · 🪙 3,2 · 💡 1,7) |
| costruzioni / potenziamenti | 3,92 / 0 | 3,52 / 0,45 |
| PV dell'era | 4,3 | 4,1 (Lampo 2,3 · censimento 1,1 · PV prodotti 0,5) |
| vittorie Lampo | 73 | 49 (le altre 23-39) |

I potenziamenti si comprano (0,45 a testa, la Lampo quasi uno) ma **al posto**
di una costruzione, non in piu': con quattro azioni per era si spende lo
stesso, e il morto non si muove. La Lampo perde il 24% delle vittorie perche'
potenzia invece di costruire e fa meno Lampo (3,9 contro 5,6): il
potenziamento Arte da 1 PV vale meno di una casa da 2. Il pozzo quindi non e'
"dove si spende" ma "quanto si puo' spendere con quattro azioni": 14 risorse
prodotte contro circa 6 che quattro azioni assorbono. Le vie restano due: meno
produzione dal tabellone (il terreno di base, 4 a testa, e' la candidata), o
una spesa che non consuma l'azione (le azioni ⇄ e ★ delle carte, o una
conversione libera risorse → PV a fine era, da scrivere nel metro). Da
decidere con il designer.


### Le leve del pozzo (registro 156)

Il designer, letta la misura: "Ci deve essere una mancanza di risorse, non un
surplus" (Dune Imperium: tre lavoratori e la scarsita' si sente); "anche gli
edifici potrebbero costare di piu'"; la catena dei Castelli di Borgogna, che
"quando si comprano edifici ti permette di prenderne o comprarne altri";
"trova modi per spendere piu' risorse o far fare piu' azioni o acquisti oltre
i 4 consentiti". Tre leve, da sole e insieme, stesse 300 ere, stessi semi, in
altrettanti file generati (`tools/genera_cards_v3.py --variante ...`):

- **costi**: ogni edificio dell'era 1 costa 1 Costruzione in piu';
- **terreno**: il terreno di base non produce piu', resta la tessera dell'era;
- **acquisto**: l'acquisto extra (costante `acquisto_extra`), fatta l'azione del
  turno si puo' ancora comprare un potenziamento o una casa della riserva,
  pagando, senza consumare il lavoratore. Il bot lo usa con la stessa testa
  delle altre mosse.

Il primo giro ha mostrato un effetto collaterale: con l'acquisto extra il bot
compra una casa e la mette **sopra un proprio Dolmen o Circolo**, spianandolo
(il Circolo spianato nell'81% delle partite), perche' spianare sconta meta'
della resistenza. E' lo stesso difetto del registro 152, qui amplificato, e
la cura e' la stessa: **spianare caro** (`spianare_costo` 1). Le varianti con
`_caro` lo hanno acceso; **catena** e' terreno + acquisto + caro con i costi
com'erano; **costi misti** alza di 1 la seconda risorsa della classe (Commercio
e Civico +1 Denaro, Religione e Cultura +1 Idea, Ingegneria e Militare +1
Costruzione), cosi' anche Denaro e Idee hanno dove andare.

| a giocatore | base | costi | terreno | acquisto | acquisto + caro | pacchetto (tre) | pacchetto + caro | **catena** | catena + costi misti |
|---|---|---|---|---|---|---|---|---|---|
| prodotto | 14,0 | 14,1 | 10,3 | 12,3 | 13,2 | 9,4 | 10,1 | 10,1 | 9,3 |
| speso | 5,4 | 7,2 | 5,2 | 6,5 | 8,4 | 5,9 | 6,2 | 7,0 | 7,0 |
| **morto** | 8,7 | 6,8 | 5,0 | 5,9 | 4,8 | 3,4 | 3,8 | **3,1** | **2,3** |
| di cui ⚒ / 🪙 / 💡 | 3,3/3,5/1,8 | 1,9/3,2/1,8 | 1,6/2,5/1,0 | 2,2/2,5/1,1 | 1,0/2,5/1,2 | 0,6/1,8/1,0 | 0,8/1,9/1,1 | 0,6/1,8/0,8 | 1,3/0,4/0,6 |
| costruzioni / potenziamenti / passi | 3,9 / 0 / 0,1 | 3,0 / 0 / 1,0 | 3,9 / 0 / 0,1 | 5,8 / 0,65 / 0,1 | 5,3 / 0,74 / 0,1 | 3,1 / 0,24 / 1,8 | 2,3 / 0,44 / 1,7 | 4,7 / 0,60 / 0,3 | 2,8 / 0,21 / 1,3 |
| acquisti extra usati | - | - | - | 2,6 | 2,1 | 1,2 | 0,4 | 1,5 | 0,3 |
| edifici a partita (di cui case) | 11,8 (1,0) | 9,0 (0,3) | 11,7 (1,0) | 17,5 (6,0) | 15,8 (4,7) | 9,3 (2,9) | 6,9 (0,2) | 14,0 (3,6) | 8,5 (1,4) |
| spianati / crollati a partita | 0,9 / 2,5 | 0,9 / 1,8 | 0,9 / 2,7 | **4,8** / 3,3 | 2,3 / 3,1 | 2,9 / 2,2 | 0,0 / 1,5 | 1,1 / 3,2 | 0,2 / 2,3 |
| PV dell'era (Lampo / censimento) | 4,3 (2,7/1,1) | 3,3 (1,8/1,1) | 4,3 (2,6/1,1) | 6,1 (5,0/0,4) | 6,3 (4,2/1,3) | 2,7 (2,1/0,3) | 2,8 (1,2/1,1) | 5,4 (3,3/1,3) | 3,6 (2,2/0,9) |
| vittorie Lampo (le altre) | 73 (20-35) | 72 (19-35) | 77 (20-34) | 63 (24-29) | 65 (23-31) | 65 (23-35) | 59 (23-35) | 62 (21-31) | **55** (21-38) |

Cosa dicono i numeri:
- **Una leva sola non basta.** Costi +1 taglia una costruzione (da 3,9 a 3,0) e
  fa passare un turno su quattro: muore meno (6,8) perche' si produce uguale e
  si compra una carta in piu' di prezzo, non perche' si spenda meglio. Il
  terreno a zero toglie 4 risorse e il morto scende a 5,0 senza toccare il
  gioco (stesse costruzioni, stessi PV). L'acquisto extra da solo apre la
  spesa (6,5) ma viene usato per spianare.
- **La catena** (terreno a zero + acquisto extra + spianare caro) e' la prima
  combinazione in cui si spende piu' di quanto muore: 7,0 contro 3,1, con 4,7
  costruzioni e 0,6 potenziamenti a testa, 5,4 PV, Lampo al 62%. La
  Costruzione e' scarsa (0,6 morta); Denaro (1,8) e Idee (0,8) ancora no,
  perche' nell'era 1 quasi niente costa Denaro.
- **I costi misti** sopra la catena portano il morto a 2,3 e il Denaro a 0,4:
  la scarsita' arriva su tutte e tre le risorse, e la Lampo scende al 55%, il
  minimo visto. Il prezzo: 2,8 costruzioni a testa, 1,3 passi, 8,5 edifici a
  partita su 12 nel mazzo; Grotte dipinte (0,13) e Tumulo (0,11) quasi non
  si costruiscono piu' perche' chiedono 2 Idee. E' un'era povera: forse
  troppo, forse e' quel che il designer vuole ("la scarsita' si sente").
- Il pacchetto con costi +1 Costruzione (con o senza caro) e' peggio della
  catena: fa passare quasi due turni su quattro.

Raccomandazione: la **catena** come base dell'era 1 (terreno che non produce,
acquisto extra, spianare caro), e sui costi una via di mezzo fra "com'erano"
e "misti": alzare di 1 la seconda risorsa solo alle carte che oggi costano 1
(le piu' costruite), lasciando a 1 Idea le Grotte e il Tumulo. Da misurare al
prossimo giro, con il bot che sa che le risorse muoiono. Le strategie: in
tutte le varianti la Lampo vince da sola perche' l'era 1 da sola paga solo
il Lampo; il numero che conta e' il **divario** fra Lampo e le altre, che va
da 73-20 nella base a 55-21 con la catena e i costi misti.

## Trentaduesima misura: l'era 1 con la catena, i costi misti e l'acquisto extra dalle carte

Le decisioni del designer dopo le leve del pozzo (registro 157), nel file
base `data/proposte/cards-v3-era1.json`: terreno di base a zero, spianare caro,
+1 della seconda risorsa della classe sugli edifici del mazzo (case come
sono), i Ripari a 1 pagabile in Costruzione o Denaro, e l'**acquisto extra
solo da una carta**: l'azione ⊕ del Capotribu' e del Mercante di ossidiana,
delle Capanne e della Cava quando le attiva il proprietario, e della tessera
Sentiero dei pastori. In piu' il bot **sa che le risorse muoiono**: sconta
quel che non potra' spendere nei piazzamenti rimasti, e all'ultimo lavoratore
spende tutto quel che puo' (`StrategyBot._fattore_morte`). Stesse 300 ere 1,
3 giocatori, seme 700000. Tre controprove: `extra_sempre` (l'extra a ogni
turno, senza carte), `senza_extra` (le cinque carte tornano com'erano),
`costi_vecchi` (senza il +1 della seconda risorsa).

| a giocatore | primo giro (reg. 155) | catena + misti (reg. 156) | **base** | extra sempre | senza extra | costi vecchi |
|---|---|---|---|---|---|---|
| prodotto | 14,0 | 9,3 | **8,7** (tessera 2,8 · Personaggi 4,2 · edifici 1,0 · azioni 0,6) | 8,6 | 9,2 | 9,4 |
| speso | 5,4 | 7,0 | **7,2** | 7,4 | 7,2 | 6,3 |
| **morto** | 8,7 | 2,3 | **1,5** (⚒ 0,5 · 🪙 0,5 · 💡 0,5) | 1,2 | 2,0 | 3,1 |
| costruzioni / potenziamenti / passi | 3,9 / 0 / 0,1 | 2,8 / 0,2 / 1,3 | 3,8 / **0,03** / 0,4 | 3,9 / 0,20 / 0,8 | 3,7 / 0 / 0,3 | 4,2 / 0,10 / 0,1 |
| acquisti extra aperti / usati | - | - | 0,74 / **0,25** | 3,22 / 0,86 | - | 0,80 / 0,41 |
| edifici a partita (di cui case) | 11,8 (1,0) | 8,5 (1,4) | 11,4 (**5,1**) | 11,6 (5,5) | 11,2 (4,4) | 12,7 (2,5) |
| spianati / crollati a partita | 0,9 / 2,5 | 0,2 / 2,3 | 0,2 / 3,0 | 0,4 / 2,9 | 0,0 / 3,2 | 0,7 / 3,0 |
| PV dell'era (Lampo / censimento) | 4,3 (2,7/1,1) | 3,6 (2,2/0,9) | 5,0 (3,8/0,8) | 5,1 (3,8/0,7) | 4,8 (3,5/0,9) | 5,3 (3,3/1,3) |
| vittorie Lampo (le altre) | 73 (20-35) | 55 (21-38) | 61 (23-33) | 59 (24-33) | 61 (23-37) | 69 (21-31) |

Cosa dicono i numeri:
- **La mancanza c'e'.** Si produce 8,7 e se ne spende 7,2: muore 1,5 a testa,
  mezza risorsa per tipo, dentro il budget del metro (1-2). Il bot che sa
  che le risorse muoiono fa la sua parte: con le stesse regole del giro
  prima (catena + misti) il morto scende da 2,3 a 1,5 e i passi da 1,3 a
  0,4. Nessun giocatore resta senza niente da comprare: i Ripari si
  costruiscono in tutte le partite, tutte e due le copie.
- **Ma l'era e' diventata un'era di case.** Cinque case a partita su undici
  edifici: Ripari 1,98, Case di pietra 1,56, Capanne di fango 1,55, mentre
  Dolmen 0,49, Grotte dipinte 0,25, Tumulo 0,10. Le case costano 1-2
  Costruzione e nient'altro; le carte del mazzo chiedono due risorse. Con
  poco in mano si compra quel che costa una cosa sola, e il Lampo delle case
  (3,8 PV su 5,0) tiene la Lampo al 61%. Con i costi vecchi si costruiscono
  12,7 edifici e solo 2,5 case, ma muore il doppio (3,1) e la Lampo sale al
  69%: i costi misti fanno il loro lavoro sul morto, non sulle case.
- **I potenziamenti sono spariti** (0,03 a testa): costano 1 Denaro o 1 Idea,
  le stesse risorse che ora chiedono gli edifici, e con 8,7 risorse per
  quattro costruzioni non ne resta per loro. L'acquisto extra si apre 0,74
  volte a testa e si usa 0,25: quando si apre, non c'e' piu' niente in mano.
  Con l'extra a ogni turno (controprova) si usa 0,86 volte su 3,22 aperte:
  la catena c'e', manca cosa metterci dentro.
- **Il draft**: il Capotribu' (⊕) e' preso per primo nel 95% dei casi (giro
  1,05); il bot valuta l'extra 1,2 e poi lo usa un quarto delle volte. Da
  tarare. Il Custode delle ossa resta ultimo (3,81): e' lo Scavo, che l'era 1
  da sola non paga.

Proposte al designer, da misurare una per volta:
1. **Le case nella stessa economia**: anche le case con la seconda risorsa
   (Civico: +1 Denaro), tenendo i Ripari a 1 ◈ come casa di salvataggio; o il
   Lampo delle case a 1 per tutte. Riporta le carte del mazzo al centro.
2. **L'extra con lo sconto**: l'acquisto extra costa 1 in meno (o il
   potenziamento comprato nell'extra e' gratis). Da' un senso alla catena
   quando si apre a mani vuote, come la casa gratis dei Castelli di Borgogna.
3. **Potenziamenti a 0 nell'era 1** o pagabili in Costruzione: oggi nessuno li
   compra e la fila resta ferma (la regola della fila che resta un'era in
   piu', registro 126, li porta all'era 2).
4. Il bot: l'azione ⊕ vale 1,2 al draft, va portata a quel che rende (0,3-0,5
   finche' l'extra non si usa di piu').

## Trentatreesima misura: il tuning delle risorse e i potenziamenti

Il designer, letta la trentaduesima: "un tuning delle risorse: se Idee e
Denaro sono poco bisogna alzarle, poi i potenziamenti devono essere comprati,
anche questo e' un difetto da riparare" (registro 159). Nel file base: le
quattro tessere dell'era 1 che non producevano niente danno Denaro (Sentiero
dei pastori, Terra di nessuno) o Idee (Radura, Luogo sacro); tre Personaggi
passano dalla Costruzione a Denaro e Idee (Guardiano del fuoco 💡, Anziana del
villaggio 🪙, Barattatore 🪙💡: fra i 16 ora Costruzione 5, Denaro 6, Idee 7,
invece di 10/4/5); i potenziamenti si comprano anche nelle colonne accanto a
quella attivata (`potenzia_adiacente`, registro 126). Nel bot: le Idee contano
nella domanda del mercato come il Denaro (il Barattatore, Denaro e Idea, finiva
ultimo nel draft), e l'azione ⊕ vale 0,4 invece di 1,2 (si usa un quarto delle
volte che si apre). Stesse 300 ere 1, 3 giocatori, seme 700000. Una
controprova: `case_seconda`, anche le case con +1 Denaro tranne i Ripari.

| a giocatore | reg. 158 | tuning | **tuning + bot** | + case con +1 Denaro |
|---|---|---|---|---|
| prodotto ⚒ / 🪙 / 💡 | 5,5 / 1,5 / 1,7 | 4,4 / 2,7 / 2,9 | **4,3 / 2,6 / 3,0** | 4,2 / 2,7 / 3,1 |
| prodotto in tutto | 8,7 | 10,0 | 9,8 | 10,0 |
| speso | 7,2 | 7,6 | 7,6 | 8,0 |
| morto (⚒ / 🪙 / 💡) | 1,5 (0,5/0,5/0,5) | 2,4 (0,4/1,1/1,0) | **2,2** (0,3/0,9/1,0) | 2,0 (0,4/0,7/0,9) |
| costruzioni / **potenziamenti** / passi | 3,8 / 0,03 / 0,4 | 3,5 / 0,44 / 0,2 | 3,6 / **0,46** / 0,1 | 3,5 / **0,53** / 0,2 |
| acquisti extra aperti / usati | 0,74 / 0,25 | 0,72 / 0,15 | 0,78 / 0,23 | 0,79 / 0,21 |
| edifici a partita (di cui case) | 11,4 (5,1) | 10,6 (3,2) | 10,9 (3,6) | 10,6 (2,6) |
| PV dell'era (Lampo / censimento / prodotti) | 5,0 (3,8/0,8/0,2) | 4,4 (2,7/1,1/0,4) | 4,7 (3,1/1,0/0,4) | 4,5 (2,7/1,1/0,5) |
| vittorie: Bil / Cont / **Lampo** / Obi / Rend / Scavo | 26/33/**61**/31/23/27 | 33/36/**49**/31/23/27 | 41/41/**37**/37/26/19 | 43/42/**38**/38/19/19 |

Cosa dicono i numeri:
- **Denaro e Idee alzati, i potenziamenti tornano.** Da 1,5 e 1,7 a 2,6 e 3,0
  prodotti a testa; i potenziamenti da 0,03 a 0,46 (budget del metro: 1), con
  le case con +1 Denaro 0,53. Il morto sale da 1,5 a 2,2, sul bordo alto del
  budget: quel che muore ora e' Denaro e Idee (0,9 e 1,0), mezza unita' l'una
  piu' di prima, perche' se ne producono di piu' e non sempre si combinano.
- **L'era non e' piu' di case.** Le case scendono da 5,1 a 3,6 a partita (2,6
  con il +1 Denaro); Dolmen 0,78, Menhir 0,89, Circolo 0,63, Grotte dipinte
  0,44, Tumulo 0,37 risalgono. Le Trappole da pesca non si costruiscono piu'
  (0,00: 2 Costruzione per una produzione di 1).
- **La Lampo non domina piu' nemmeno nell'era 1 da sola**: 37% con le sei
  strategie fra 19 e 41. Il bot che valuta le Idee ha fatto la meta' del
  lavoro (da 49 a 37): Bilanciata e Continuita' ora comprano Dolmen e Menhir.
  La Scavo e' al 19% per costruzione della misura (lo Scavo non paga
  nell'era 1); la Rendita al 26 e' sul bordo basso.
- **L'acquisto extra resta debole**: si apre 0,78 volte e si usa 0,23. Il
  Mercante di ossidiana (⊕) e' ora l'ultima scelta del draft (3,89), il
  Capotribu' (⊕) a meta' (2,12): il bot lo valuta per quel che rende. Perche'
  renda di piu' serve una delle due cose dette nella trentaduesima: lo sconto
  sull'acquisto extra, o potenziamenti piu' economici.
- Le case con +1 Denaro migliorano tutto di poco (morto 2,0, potenziamenti
  0,53, case 2,6) e portano la Rendita al 19: da tenere come opzione, non
  come base, finche' la Rendita non ha il suo bot.

Stato dopo tre giri: produzione 9,8 (budget 10-12), spesa 7,6 (budget 8-10),
morto 2,2 (budget 1-2), 3,6 costruzioni e 0,46 potenziamenti (budget 3 e 1):
l'economia dell'era 1 e' nel metro o sul suo bordo. Restano il Guerriero
sempre primo nel draft (1,11), le Trappole da pesca mai costruite, l'extra che
non si usa, e la misura della coppia 1-2 per Scavo e scheletri.

## Trentaquattresima misura: il potenziamento insieme alla costruzione

Il designer (registro 160): "i potenziamenti non sono un'azione a parte ma
possono essere presi insieme agli edifici se il giocatore ha risorse
sufficienti. Se non bastano rimetterei la produzione base dei terreni". Nel
file base la costante `potenziamento_con_costruzione`: chi costruisce puo'
comprare subito un potenziamento (pagandolo, nella colonna attivata o accanto)
senza consumare il lavoratore. Variante `terreno_produce`: in piu', la
produzione base dei terreni della v2 (era 1: fiume e collina 2 Costruzione,
pianura 1, bosco 1 Idea). Stesse 300 ere 1, 3 giocatori, seme 700000.

| a giocatore | reg. 159 | **potenziamento insieme** | + terreno che produce |
|---|---|---|---|
| prodotto (⚒ / 🪙 / 💡) | 9,8 (4,3/2,6/3,0) | 9,8 (4,3/2,6/3,0) | 14,0 (6,1/3,8/4,1) |
| speso | 7,6 | 7,9 | 10,1 |
| morto (⚒ / 🪙 / 💡) | 2,2 (0,3/0,9/1,0) | **2,0** (0,3/0,8/0,9) | 3,9 (0,7/1,6/1,5) |
| costruzioni / **potenziamenti** / passi | 3,6 / 0,46 / 0,1 | 3,7 / **0,71** / 0,1 | 4,1 / **1,07** / 0,0 |
| occasioni di potenziare dopo una costruzione: aperte / usate | - | 3,57 / 0,50 | 3,79 / 1,18 |
| edifici a partita (di cui case) / spianati | 10,9 (3,6) / 0,0 | 11,0 (3,7) / 0,0 | 12,3 (3,3) / **0,5** |
| PV dell'era (Lampo / censimento / prodotti) | 4,7 (3,1/1,0/0,4) | 4,8 (3,1/1,0/0,5) | 5,9 (3,7/1,3/0,7) |
| vittorie: Bil / Cont / Lampo / Obi / Rend / Scavo | 41/41/37/37/26/19 | 37/43/42/37/23/18 | 23/41/**51**/41/20/24 |

Cosa dicono i numeri:
- **Il potenziamento insieme alla costruzione funziona a meta'**: da 0,46 a
  0,71 a testa (budget del metro: 1), con lo stesso morto o meno (2,0) e
  tutto il resto fermo. Si apre 3,6 volte a testa e si usa una su sette:
  dopo aver pagato l'edificio, con due risorse di tipo diverso, restano di
  rado il Denaro o l'Idea che il potenziamento chiede.
- **Con il terreno che produce le risorse bastano**, i potenziamenti arrivano
  a 1,07 e si costruisce di piu' (12,3 edifici, 4,1 a testa), ma si torna al
  surplus: morto 3,9, Lampo al 51%, e tornano gli spianati (0,5 a partita: con
  Costruzione in piu', il bot mette case sopra i propri edifici anche se
  spianare costa). Le Grotte dipinte scendono a 0,13: con piu' Costruzione in
  giro si comprano le carte da Costruzione.
- La via di mezzo non e' stata misurata: un terreno che produce **meta'** (1
  Costruzione su fiume e collina, niente su pianura, 1 Idea sul bosco), o un
  potenziamento che nell'extra costa 1 in meno. Sono le due prove successive,
  se il designer vuole arrivare a 1 potenziamento a testa senza surplus.

## Trentacinquesima misura: i costi rimodulati, il bot che aspetta, gli sconti, lo spianare

Il designer (registro 161): "dovresti rimodulare i costi tu in modo da rendere
risorse prodotte e spese nella giusta proporzione; le risorse possono essere
tenute per poter comprare meglio con il lavoratore successivo; alcuni effetti
potrebbero scontare dei tipi di potenziamenti o edifici; non si possono
spianare edifici della stessa era, ma solo ere precedenti". Quattro cose nel
file base e nel bot, poi tre giri di costi sugli stessi 300 semi.

- **Non si spiana la stessa era** (costante `spiana_solo_ere_precedenti`): la
  casa sopra il proprio Dolmen appena costruito non si puo' piu' mettere.
- **Gli sconti**: il Guardiano del fuoco sconta di 1 l'edificio Religione del
  turno, il Custode delle ossa sconta di 1 il potenziamento del turno (erano
  gli ultimi del draft, con 🛡 e ⚱). Lo sconto sui potenziamenti vale sulla
  risorsa che il potenziamento chiede, qualunque sia.
- **Il bot che aspetta**: se una carta del mazzo che oggi non puo' pagare, ma
  che il prossimo incasso rende pagabile, vale piu' della mossa di adesso
  (scontata a 0,4, con un margine di 1), tiene le risorse e passa.
- **I costi, tre giri.** Il principio trovato al secondo giro: **l'edificio
  chiede la risorsa che i suoi potenziamenti non chiedono**. Con i
  potenziamenti della stessa classe (registro 125), Civico e Commercio
  prendono gli "altro" a 1 Denaro, Religione e Cultura l'Arte a 1 Idea: se il
  Dolmen costa 1 Costruzione e 1 Denaro, dopo averlo costruito resta l'Idea
  per l'Idolo; se costasse 1 Idea (primo giro) l'Idea non ci sarebbe piu' e
  morirebbe. Costi finali dell'era 1: Capanne, Palafitte, Approdo, Cava 1⚒ 1💡;
  Focolare e Trappole 1⚒ (a due risorse non si costruivano); Dolmen, Menhir,
  Grotte dipinte, Tumulo 1⚒ 1🪙; Circolo 2⚒ 1🪙 1💡; Villaggio 2⚒; case come
  prima. Produzione: la Radura torna a 1 Costruzione e l'Anziana del villaggio
  pure, perche' al primo giro mancava Costruzione e avanzavano Idee.

| a giocatore | reg. 160 | giro 1 (costi misti puri) | giro 2 (la regola) | **giro 3 (base)** |
|---|---|---|---|---|
| prodotto (⚒ / 🪙 / 💡) | 9,8 (4,3/2,6/3,0) | 9,6 (4,0/2,7/2,9) | 9,8 (4,9/2,3/2,6) | **10,1** (5,1/2,4/2,6) |
| speso | 7,9 | 7,0 | 7,6 | **7,8** |
| morto (⚒ / 🪙 / 💡) | 2,0 (0,3/0,8/0,9) | 2,6 (0,4/0,6/**1,6**) | 2,2 (0,6/0,7/0,8) | **2,3** (0,7/0,8/0,9) |
| costruzioni / potenziamenti / passi | 3,7 / 0,71 / 0,1 | 3,0 / 0,71 / **1,0** | 3,3 / 0,81 / 0,7 | **3,6 / 0,77 / 0,5** |
| occasioni di potenziare aperte / usate | 3,6 / 0,5 | 2,9 / 0,7 | 3,1 / 0,85 | 3,4 / 0,83 |
| edifici a partita (di cui case) / spianati | 11,0 (3,7) / 0,0 | 9,1 (1,7) / 0,0 | 10,0 (2,1) / 0,0 | **10,7 (2,2) / 0,0** |
| PV dell'era (Lampo / censimento / prodotti) | 4,8 (3,1/1,0/0,5) | 4,2 (2,1/1,3/0,6) | 4,9 (2,7/1,3/0,6) | 5,1 (2,9/1,3/0,6) |
| vittorie: Bil / Cont / Lampo / Obi / Rend / Scavo | 37/43/42/37/23/18 | 29/39/46/41/27/19 | 26/29/51/40/31/23 | 22/37/**54**/39/29/19 |

Cosa dicono i numeri:
- **La proporzione c'e'.** Si producono 10,1 risorse, se ne spendono 7,8 e ne
  muoiono 2,3, quasi uguali per tipo (0,7 / 0,8 / 0,9): nessuna risorsa e'
  in surplus. Rispetto al metro: produzione 10-12 ✓, spesa 8-10 (7,8), morto
  1-2 (2,3), 3 costruzioni ✓, 1 potenziamento (0,77). Il primo giro mostra
  perche' la regola dei costi conta: con Religione a 1 Idea morivano 1,6 Idee.
- **Il mazzo torna al centro**: Dolmen, Menhir, Circolo, Capanne, Cava,
  Palafitte a 1,0 a partita, Tumulo 0,81, le case a 2,2 su 10,7. Restano fuori
  le Grotte dipinte (0,09: lo Scavo non paga nell'era 1 da sola) e le Capanne
  di fango (0,09: a 1 Costruzione per Lampo 1 i Ripari a costo flessibile
  bastano).
- **Il bot che aspetta passa 0,5 turni a testa** (giro 3; con lo sconto a 0,6
  passava 1,0): e' la regola voluta dal designer, ma nell'era 1 da sola
  aspettare non paga, perche' la carta comprata dopo rende meno di una casa
  comprata subito. La Lampo, che non aspetta mai, ne approfitta: dal 42% al
  54%. E' un effetto della misura ferma all'era 1, da rileggere sulla coppia
  1-2; se restasse, lo sconto dell'attesa va abbassato ancora.
- **Nessuno spiana piu'** (0,00 a partita): la regola della stessa era basta.

## Trentaseiesima misura: la coppia di ere 1-2

La prima misura su due ere (registro 162). L'era 2 e' scritta nello stesso
schema dell'era 1 (`docs/proposte/v3-era-2.md`: 16 Personaggi con produzione,
azione e Scavo da scheletro, 15 edifici con azione, costi con la regola
"l'edificio chiede la risorsa che i suoi potenziamenti non chiedono"). Il
rapporto fotografa a fine era i contatori e i punti per canale, e
`tools/misura_era.py --era 2` misura l'era 2 come differenza (per questo i
numeri dell'era 1 sono gli stessi della trentacinquesima: stessi semi). 300
partite a 3 giocatori fermate a fine era 2, tre giri sull'era 2.

| a giocatore | era 1 | era 2, giro 1 | era 2, giro 2 | **era 2, giro 3** |
|---|---|---|---|---|
| prodotto (⚒ / 🪙 / 💡) | 10,1 (5,1/2,4/2,6) | 13,5 (6,0/3,6/3,9) | 11,6 (5,1/3,7/2,8) | **12,0** (6,2/3,0/2,8) |
| speso | 7,8 | 8,2 | 7,7 | **8,5** |
| morto (⚒ / 🪙 / 💡) | 2,3 (0,7/0,8/0,9) | 5,3 (0,6/1,8/2,9) | 3,9 (0,5/1,9/1,5) | **3,5** (0,9/1,3/1,4) |
| costruzioni / potenziamenti / passi | 3,6 / 0,77 / 0,5 | 3,0 / 1,16 / 0,8 | 2,8 / 1,08 / 1,0 | **3,3 / 1,07 / 0,65** |
| occasioni di potenziare aperte / usate | 3,4 / 0,8 | 2,9 / 0,9 | 2,7 / 0,8 | 3,1 / 1,0 |
| edifici a partita (di cui case) | 10,7 (2,2) | 9,0 (3,6) | 8,3 (3,6) | 10,9 (3,3) |
| rovine dell'era 1 coperte / bonus scavo (PV) | - | 3,6 / 0,67 | 3,6 / 0,68 | 4,1 / 0,72 |
| PV dell'era (Lampo / censimento / prodotti / scavo) | 5,1 (2,9/1,3/0,6/-) | 6,7 (3,0/1,3/1,3/0,7) | 7,5 (2,8/2,4/1,3/0,7) | **8,9** (3,9/2,5/1,3/0,7) |
| vittorie a fine era 2: Bil / Cont / Lampo / Obi / Rend / Scavo | (era 1 sola: 22/37/54/39/29/19) | 30/31/31/44/31/33 | 27/33/35/41/37/27 | **31/32/39/41/27/30** |

I tre giri: al primo le tessere dell'era 2 producevano tutte e i Personaggi
davano 7 Idee: 13,5 prodotte, 5,3 morte. Al secondo tre tessere senza
produzione (Via consolare, Cantiere, Necropoli) e due Personaggi passati alla
Costruzione, ma i costi a tre risorse facevano costruire 2,8 edifici e 3,6
case su 8,3. Al terzo i costi a due risorse come l'era 1 (tre solo per
Acquedotto, Ponte, Foro, Anfiteatro), lo Statio e il Centurione alla
Costruzione: 3,3 costruzioni, le case 3,3 su 10,9, il morto 3,5.

Cosa dicono i numeri:
- **La coppia riequilibra le strategie.** A fine era 2 le sei vincono fra il 27
  e il 41%: la Lampo, al 54% nell'era 1 da sola, qui e' al 39; la Rendita
  incassa il secondo censimento (2,5 PV nell'era 2) e la Scavo il bonus di chi
  costruisce sulle rovine dell'era 1 (0,7 PV, 4,1 rovine coperte a partita su
  2,5 lasciate). Lo scheletro e la riscoperta pagano solo a fine partita, e si
  vedranno con le ere 3-5.
- **L'era 2 spende di piu' e muore di piu'**: 8,5 spese e 3,5 morte contro 7,8
  e 2,3 dell'era 1. I potenziamenti sono a 1,07 a testa, il budget del metro.
  Il morto e' Denaro e Idee (1,3 e 1,4): la prossima correzione e' un'altra
  tessera dell'era 2 senza produzione, o un Personaggio in meno su Denaro.
- **Le carte**: Insulae, Tempio, Terme, Foro, Teatro 0,8-0,9 a partita,
  Acquedotto e Ponte 0,6; deboli Castrum 0,29 (2 Costruzione, Lampo 2, nessuna
  casa a quel prezzo lo batte... ma la Domus a 2 e' a 1,14), Sacello 0,18,
  Torre di vedetta 0,08, Anfiteatro 0,03 (solo sopra: nell'era 2 ci sono
  poche rovine larghe due). I Tuguri 1,6 a partita: la casa a costo flessibile
  resta la carta di salvataggio, come i Ripari.
- **Il draft dell'era 2**: Legionario primo (1,02, come il Guerriero),
  Architetto 1,36; ultimi Argentario (3,98, ⊕), Mosaicista, Sacerdotessa,
  Console. Il ⊕ resta l'azione meno voluta anche qui.

## Trentasettesima misura: la partita intera della v3, prima stesura delle ere 3-5

Le ere 3, 4 e 5 scritte con uno stampo uguale per i 16 Personaggi (le stesse
sedici azioni, produzione 9/4/4, i cinque della v2 al posto del loro ruolo) e
gli edifici con la regola dei costi (`docs/proposte/v3-ere-3-5.md`, registro
163). 300 partite intere a 3 giocatori, seme 700000, tutte le strategie a
rotazione. La v2 di main, stesso lotto (trentunesima misura, 90 partite):
69,5 PV a testa, Lampo 16,4, Continuita' 17,8, Rendita 13,9, Scavo 7,7.

**La partita**: 74,7 PV a testa. Lampo 17,4, Continuita' 15,8, Rendita 11,7,
**Scavo 11,6** (tessere 7,1, scheletri 2,2, arte 1,4, piu' il bonus di chi
costruisce sulle rovine), PV prodotti dalle azioni 10,5, finali 3,3,
Eredita' 2,5, Monumenti 1,8. Vittorie: Bilanciata 39, Rendita 38,
Obiettivi 37, Continuita' 35, Scavo 27, **Lampo 23** (errore ±4, atteso 33).
Lo Scavo, che nella v2 era a 8 PV, con gli scheletri dei Personaggi e il
bonus delle rovine arriva a 12; la Lampo, che nell'era 1 da sola vinceva il
54%, sulla partita intera e' l'ultima.

| a giocatore | era 1 | era 2 | era 3 | era 4 | era 5 |
|---|---|---|---|---|---|
| prodotto (⚒ / 🪙 / 💡) | 10,1 (5,1/2,4/2,6) | 12,0 (6,2/3,0/2,8) | **14,5** (5,8/4,7/4,0) | 13,3 (5,1/4,7/3,4) | 14,0 (5,2/5,1/3,7) |
| speso | 7,8 | 8,5 | 8,9 | 7,6 | 7,7 |
| morto (⚒ / 🪙 / 💡) | 2,3 | 3,5 | **5,6** (0,9/2,4/2,2) | **5,7** (1,4/3,0/1,2) | **6,3** (1,4/2,4/2,5) |
| costruzioni / potenziamenti / passi | 3,6 / 0,77 / 0,5 | 3,3 / 1,07 / 0,65 | 3,4 / 1,29 / 0,4 | 3,1 / 0,97 / 0,6 | 2,7 / 1,15 / 0,8 |
| PV dell'era (Lampo / censimento / prodotti / scavo) | 5,1 (2,9/1,3/0,6/-) | 8,9 (3,9/2,5/1,3/0,7) | 10,7 (4,6/2,5/2,5/0,7) | 10,9 (2,9/3,0/2,8/1,9) | 8,0 (3,1/-/3,3/1,2) |
| edifici a partita: costruiti / in rovina a fine partita / sotterrati | 10,7 / 8,8 / 8,2 | 9,9 / 6,3 / 5,4 | 10,2 / 7,7 / 6,4 | 9,3 / 5,4 / 2,0 | 8,0 / 2,6 / 0 |

Cosa dicono i numeri:
- **Le ere 1 e 2 tengono, le ere 3-5 no**: producono 13-14,5 e ne lasciano
  morire 5,6-6,3, Denaro e Idee soprattutto (2,4-3,0 e 1,2-2,5). E' lo stesso
  problema dell'era 2 al primo giro, e si cura allo stesso modo: meno tessere
  che producono, Personaggi dello stampo spostati su Costruzione, i costi
  delle carte da ritoccare dove non si costruiscono.
- **Le case delle ere 4 e 5 dominano**: Case popolari 1,99 e Casa borghese
  1,95 a partita nell'era 4, Palazzina 1,97 e Condominio popolare 1,91
  nell'era 5, contro 0,1-0,6 delle carte del mazzo. Costano Denaro e Idee
  (i costi della v2: 0/0/1, 0/1/1) e sono l'unica cosa che assorbe quelle
  risorse: vanno nella stessa economia (una casa a 1 flessibile, le altre con
  la Costruzione).
- **Nell'era 5 il mazzo non si costruisce**: Stazione 0,01, Grattacielo 0,07,
  Museo 0,12, Universita' 0,27 (tutti "solo sopra"), e quel che si costruisce
  a terra con resistenza 1-2 crolla al Giudizio del tempo al 93-99%
  (Caffe' letterario, Fondazione, Condominio, Officina, Parco archeologico).
  Si costruiscono 2,7 edifici a testa, meno che in ogni altra era.
- **L'era 3 crolla**: forza 4, e Case di legno, Casupole, Cappella, Borgo,
  Ospedale cadono all'82-95%: 7,7 rovine su 10,2 costruiti. E' il materiale
  dello Scavo (6,4 sotterrati), ma anche il segno che la resistenza delle
  carte dell'era 3 e' quella della v2, non pensata per un'era di forza 4
  senza il +2 del lavoratore su ogni edificio.
- **Il draft**: in ogni era il Militare "+2 all'edificio su cui sta" e' la
  prima scelta (Cavaliere 1,10, Ingegnere militare 1,14, Veterano 1,12), e
  gli ultimi sono gli sconti e il ⊕. Lo stampo e' uguale, il draft pure.

Proposta: il giro di tuning delle ere 3-5 come per l'era 2 (tessere,
Personaggi, costi, case nella stessa economia), poi la resistenza dell'era 3
e le carte "solo sopra" dell'era 5. Una misura intera dura 37 minuti.

## Trentottesima misura: il tuning delle ere 3-5, due giri

Il designer: "Vai". Stesse 300 partite intere della trentasettesima, due giri
sulle ere 3-5 (registro 164).

**Primo giro**: tessere delle ere 3-5 da cinque a tre su sette che producono,
quasi solo Costruzione; nello stampo dei Personaggi due ruoli dalla
produzione di Denaro e Idee alla Costruzione (11/3/3 invece di 9/4/4); le case
delle ere 3-5 nella stessa economia (la piccola 1 flessibile, le altre 1 o 2
Costruzione invece di Denaro e Idee); +1 resistenza alle carte delle ere 3 e 5
con resistenza 1-2. Risultato: quasi niente. Le ere 3-5 producevano ancora
13,5-14,2 e ne morivano 5,0-6,5, e il Denaro moriva **di piu'** (2,6 / 3,8 /
3,2). Il conto delle entrate su tutta la partita ha detto perche': del Denaro
incassato (20 a testa) 7,0 veniva dalle **azioni degli edifici** e 4,4 dalla
**produzione della v2 rimasta sulle carte** (Mulino 2, Officina 2, Stazione
2, Emporio, Foro, Borgo...), che si sommava all'azione; tessere e Personaggi
ne davano 8. Dall'era 3 in su gli edifici in piedi sono quindici-venti e ogni
attivazione ne paga due o tre: l'economia degli edifici si accumula.

**Secondo giro**: la produzione della v2 a zero su tutti gli edifici del
mazzo dall'era 2 in su (l'azione e' la loro produzione; l'era 1 resta com'e'
stata misurata); sette azioni "+1 Denaro" diventano altro (Terme e Banco ⇄,
Borgo e Condominio ★ se Civico in colonna, Ospedale 🛡, Villa ★, Stazione ⚒);
le case delle ere 4 e 5 a 2 e 3 Costruzione (a 1 e 2 battevano il mazzo).

| a giocatore | era 1 | era 2 prima → ora | era 3 prima → ora | era 4 prima → ora | era 5 prima → ora |
|---|---|---|---|---|---|
| prodotto | 10,1 | 12,0 → 11,3 | 14,5 → **11,2** | 13,3 → **10,9** | 14,0 → **11,0** |
| di cui 🪙 / 💡 | 2,4 / 2,6 | 3,0 / 2,8 → 2,6 / 2,8 | 4,7 / 4,0 → 2,2 / 3,2 | 4,7 / 3,4 → 3,0 / 2,5 | 5,1 / 3,7 → 2,8 / 2,7 |
| speso | 7,8 | 8,5 → 8,1 | 8,9 → 7,7 | 7,6 → 7,0 | 7,7 → 7,1 |
| morto | 2,3 | 3,5 → 3,2 | 5,6 → **3,5** | 5,7 → **3,9** | 6,3 → **4,0** |
| di cui ⚒ / 🪙 / 💡 | 0,7/0,8/0,9 | 0,9/1,3/1,4 → 0,8/1,0/1,5 | 0,9/2,4/2,2 → 0,6/1,2/1,7 | 1,4/3,0/1,2 → 0,9/1,8/1,2 | 1,4/2,4/2,5 → 1,0/1,1/1,9 |
| costruzioni / potenziamenti / passi | 3,6 / 0,77 / 0,5 | 3,3/1,07/0,65 → 3,2/1,02/0,7 | 3,4/1,29/0,4 → 3,0/1,10/0,6 | 3,1/0,97/0,6 → 2,7/0,90/0,9 | 2,7/1,15/0,8 → 2,4/0,95/1,0 |
| PV dell'era | 5,1 | 8,9 → 8,7 | 10,7 → 10,1 | 10,9 → 10,4 | 8,0 → 7,8 |

La partita intera: 72,7 PV a testa (prima 74,7; v2 69,5), Lampo 16,2,
Continuita' 14,4, Rendita 11,2, PV prodotti 11,1, Scavo 10,5 (tessere 6,5,
scheletri 2,1, arte 1,3), finali 5,0. Vittorie: Obiettivi 41, Continuita' 36,
Rendita 36, Bilanciata 35, Scavo 30, Lampo 23.

Cosa dicono i numeri:
- **Le ere 3-5 scendono a 11 prodotte e 3,5-4,0 morte**, da 14 e 6: il
  grosso l'ha fatto togliere la produzione doppia e le azioni in Denaro. Il
  morto resta sopra il budget (1-2) e sono ancora Denaro e Idee (1,1-1,8 e
  1,2-1,9): le azioni degli edifici in piedi delle ere passate continuano a
  pagarle, e dall'era 3 ce ne sono tanti. La via, se si vuole arrivare a 2,
  e' una delle due dette gia': le azioni "risorsa" degli edifici solo quando
  li attiva il proprietario, oppure un costo in piu' in Denaro e Idee sulle
  carte delle ere 3-5 (oggi quasi tutte Costruzione piu' una).
- **Si costruisce meno** nelle ere 4 e 5 (2,7 e 2,4 a testa) e si passa di
  piu' (0,9 e 1,0): con meno risorse e carte da 3-4 il bot aspetta. Le case
  piccole a 1 flessibile restano le piu' costruite (Casupole 1,9, Case
  popolari 2,0, Palazzina 2,0): sono la carta di salvataggio, ma due a
  partita sono tante.
- **Le carte mai costruite**: Conceria 0,03, Castello 0,02, Arsenale 0,08
  (era 3); Fortezza 0,01, Palazzetto 0,10, Osservatorio 0,13 (era 4);
  Stazione 0,02, Grattacielo 0,07, Ponte in acciaio 0,09 (era 5). Le "solo
  sopra" grandi non trovano dove salire; le altre costano troppo per quel
  che rendono. Vanno riscritte una per una, con il designer.
- **Le strategie** sulla partita intera: cinque fra 30 e 41, la Lampo al 23
  con 66,7 PV contro 71-77 delle altre. Il Lampo e' il canale che tutti
  prendono (16,2 PV a testa) e la strategia che lo insegue in piu' non ha
  piu' un vantaggio: va ritarata nel bot, non nelle regole, come si fece per
  la v2 (registro 114).

## Trentanovesima misura: i costi delle ere 3-4, le carte "solo sopra", la Lampo nel bot

Il designer (registro 165): "Le carte ere 3-4 vanno rimodulate per costare un
po' di piu'. Le grandi 'solo sopra' che vuol dire? Prima si trovava il modo di
costruire, perche' ora no? Le case piccole le teniamo cosi'. Ritara bot per
strategia Lampo." Stesse 300 partite intere.

**I costi.** Le carte da due risorse delle ere 3 e 4 ne prendono una terza, quella
fra Denaro e Idee che non chiedevano (Borgo ⚒1 🪙1 💡1, Mura ⚒2 🪙1, Loggia ⚒1 🪙1
💡1...); le carte da tre e quattro restano.

| a giocatore | era 3 prima → ora | era 4 prima → ora |
|---|---|---|
| prodotto | 11,2 → 11,2 | 10,9 → 10,7 |
| morto (⚒ / 🪙 / 💡) | 3,5 (0,6/1,2/1,7) → 3,4 (0,6/0,9/1,9) | 3,9 (0,9/1,8/1,2) → 3,4 (0,8/1,6/1,1) |
| costruzioni / potenziamenti / passi | 3,0 / 1,10 / 0,6 → 2,9 / 1,03 / 0,7 | 2,7 / 0,90 / 0,9 → 2,6 / 0,76 / 1,0 |
| case a partita | Casupole 1,9, Casa torre 1,0, Case di legno 1,1 → 2,0, **1,6, 1,5** | Case popolari 2,0, Casa borghese 1,2 → 2,0, **1,6** |
| carte del mazzo a partita | Cappella 0,84, Borgo 0,72, Chiesa 0,63, Mercato 0,25 → 0,62, 0,44, 0,57, **0,08** | Loggia 0,73, Bottega 0,75, Banco 0,63 → 0,61, 0,55, 0,44 |

Il morto quasi non si muove (3,4 in tutte e due) e la spesa passa dal mazzo
alle case: con le carte piu' care il bot compra Casa torre, Case di legno e
Casa borghese, che costano 1-3 Costruzione, e il Mercato e il Mulino a tre
risorse scendono a 0,08 e 0,07. Il surplus di Denaro e Idee non si
trasforma in spesa alzando i prezzi: si sposta su quel che costa una cosa
sola. E' lo stesso meccanismo visto nell'era 1 con i costi misti (registro
158). Le case piccole restano come sono per decisione del designer.

**Le carte "solo sopra".** Sono le carte della v2 che non si costruiscono a
terra: Anfiteatro, Castello, Fortezza (2x2, "mai a terra, sopra di lui si
costruisce solo quando e' in rovina"), Grattacielo (solo al livello 2 o
piu'), Duomo (livello 2), Piazza monumentale, Museo, Stazione, Universita'
(livello 1). Nella v2 di main si costruivano 0,2-0,7 volte a partita, nella
v3 0,01-0,26; eppure si costruisce sopra quanto prima (5-6 edifici per era
in tutte e due). La differenza e' **su cosa**: nella v2 un 2x2 si poggiava
spianando due propri edifici dell'era stessa, con lo sconto (il difetto del
registro 152, 21 spianati a partita); nella v3 spianare costa e non si
spiana la stessa era, quindi un 2x2 ha bisogno di due colonne adiacenti con
rovine delle ere passate o propri edifici vecchi, e capita di rado. Le carte
a una colonna di livello 1 (Museo, Universita', Piazza) si costruiscono
ancora, 0,2-0,3 a partita, meno che nella v2 perche' costano 3 risorse di
tipo diverso e il bot aspetta. La Stazione (3 colonne, livello 1) e il
Grattacielo (livello 2) sono quasi impossibili. Da decidere con il designer:
tenerle cosi' come carte rare, oppure riscriverle (una colonna, o "a terra
oppure sopra").

**La Lampo nel bot.** Tre lotti con la manopola `--spinta` sugli stessi semi:

| | base (lampo 1,6, potenzia 3) | lampo 1,0 | **lampo 0,8, potenzia 1,5** |
|---|---|---|---|
| vittorie Lampo | 30 | 31 | 30 |
| PV della Lampo | 65,6 | 66,2 | **69,1** |
| le altre (Bil / Cont / Obi / Rend / Scavo) | 37/32/43/33/25 | 38/35/41/34/21 | 36/33/43/32/25 |

Le tre tarature stanno nell'errore sulle vittorie (±4): con i costi nuovi la
Lampo e' gia' al 30%, dal 23 della trentottesima. La taratura a 0,8 e 1,5 da'
pero' 3,5 PV in piu' alla Lampo senza togliere niente alle altre: e' la
tabella `SPINTE_V3` del bot, che vale solo con `turno_v3`. Ora la piu' debole
e' la Scavo (25%, 68 PV), e la piu' forte la Obiettivi (43).

Partita intera con i costi nuovi e il bot nuovo: 71,3 PV a testa, Lampo 15,9,
Continuita' 14,1, Rendita 11,4, PV prodotti 10,4, Scavo 10,2.

## Quarantesima misura: "a terra oppure sopra", e le azioni degli edifici solo quando attivi tu

Il designer (registro 166): "A terra oppure sopra, vai con la seconda". Stesse
300 partite intere, stessi semi; il rapporto distingue ora le entrate per fonte
in ogni era (`snap_e<N>_in_<fonte>_<risorsa>`; `edifici_azione` sono le azioni
degli edifici in piedi, `azioni` quelle del Personaggio piazzato).

**Le carte grandi a terra.** Anfiteatro, Castello, Fortezza, Grattacielo e
Stazione prendono `a_terra_o_sopra`. Costruite a partita, prima → ora (di cui a
terra): Anfiteatro 0,02 → 0,46 (0,45), Castello 0,02 → 0,12 (0,11), Fortezza
0,03 → 0,05, Grattacielo 0,05 → 0,07, Stazione 0,02 → 0,03. Le due 2x2 piu'
economiche entrano in gioco; Fortezza (⚒4 su collina), Grattacielo (3 binari) e
Stazione (3 colonne di pianura) restano rare per il terreno e la forma, non per
la regola. Vittorie: Bilanciata 43, Obiettivi 35, Rendita 33, Continuita' 31,
Scavo 30, Lampo 27 (era 36/43/32/33/25/30): l'Anfiteatro e' Cultura, e lo
comprano Bilanciata e Scavo.

**Da dove vengono le Idee che muoiono.** Sulla trentanovesima misura chi aveva
l'Acquedotto (tre colonne, in piedi dall'era 2 alla 5, "+1 Idea a ogni
attivazione di chiunque") incassava 19,8 Idee dalle azioni contro 2,6 di chi non
lo aveva; la Piazza monumentale 14,6 contro 5,4, l'Abbazia 10,4 contro 5,3, il
Foro 8,2 Denaro contro 2,8. Sulla partita intera le azioni degli edifici davano
6,3 Idee e 4,2 Denaro a testa; senza di loro Idee e Denaro prodotti (7 e 8)
pareggiavano quasi quel che se ne spendeva (6,4 e 8,4). Il surplus era tutto li'.

**Due controprove**: le azioni degli edifici che danno Denaro o Idee scattano
solo quando attivi tu (`proprio_morte`), oppure tutte quelle che danno risorse,
Costruzione compresa (`proprio_tutte`). Le "altrui" (Approdo, Emporio,
Conceria) restano com'erano; PV, resistenza, cambio e scavo scattano ancora a
ogni attivazione di chiunque.

| a giocatore | era 1 | era 2 | era 3 | era 4 | era 5 |
|---|---|---|---|---|---|
| **a terra** prodotto / speso / morto | 10,1 / 7,8 / 2,3 | 11,2 / 8,5 / 2,7 | 10,9 / 7,5 / 3,4 | 10,4 / 7,0 / 3,5 | 10,5 / 6,7 / 3,8 |
| di cui dalle azioni degli edifici (⚒/🪙/💡) | 0,5 | 0,5/0,6/0,9 | 0,8/0,7/1,4 | 0,6/0,5/1,4 | 0,8/0,6/1,6 |
| **proprio_morte** prodotto / speso / morto | 9,7 / 7,8 / 2,0 | 10,5 / 8,3 / 2,1 | 9,8 / 7,4 / 2,4 | 9,4 / 6,7 / 2,7 | 9,3 / 6,5 / 2,9 |
| **proprio_tutte** prodotto / speso / morto | 9,7 / 7,8 / 2,0 | 10,1 / 8,1 / 2,0 | 9,4 / 7,2 / 2,2 | 9,1 / 6,5 / 2,5 | 8,9 / 6,3 / 2,5 |
| di cui dalle azioni degli edifici (⚒/🪙/💡) | 0,1 | 0,2/0,3/0,4 | 0,5/0,5/0,6 | 0,3/0,3/0,6 | 0,4/0,3/0,7 |
| costruzioni / potenziamenti (a terra → tutte) | 3,59 / 0,75 → 3,57 / 0,72 | 3,31 / 0,98 → 3,27 / 0,93 | 2,87 / 0,98 → 2,81 / 0,95 | 2,47 / 0,80 → 2,43 / 0,70 | 2,31 / 0,92 → 2,26 / 0,86 |

| partita intera | a terra | proprio_morte | proprio_tutte |
|---|---|---|---|
| PV a testa | 72,7 | 71,2 | 70,2 |
| Lampo / Continuita' / Rendita / PV prodotti / Scavo | 15,5 / 13,9 / 12,2 / 11,9 / 10,4 | 15,7 / 13,7 / 11,6 / 11,4 / 10,2 | 15,4 / 13,5 / 11,4 / 11,3 / 9,9 |
| vittorie Bil / Cont / Lampo / Obi / Rend / Scavo | 43 / 31 / 27 / 35 / 33 / 30 | 40 / 31 / 27 / 37 / 35 / 31 | 36 / 33 / 26 / 39 / 34 / 31 |
| Idee dell'Acquedotto al padrone (con / senza) | 19,8 / 2,7 | | 8,4 / 1,3 |

Il morto scende di 1-1,3 a testa in ogni era, da 2,7-3,8 a 2,0-2,5, e la spesa
quasi non cala (0,1-0,4): si tolgono risorse che non si spendevano. Costruzioni
e potenziamenti perdono 0,02-0,1 a era. Fra le due, `proprio_tutte` ha il morto
piu' basso, la regola piu' semplice ("a ogni TUA attivazione" per tutte le
risorse) e le vittorie piu' strette (26-39): **e' il file base** da questa
misura; `--variante chiunque` rifa' la regola di prima. Il budget del metro
(morto 1-2) e' quasi raggiunto nelle ere 1-3 (2,0-2,2) e manca di mezzo punto
nelle 4-5, dove muoiono 1,4 Denaro (era 4) e 1,1 Idee (era 5) e si passa 1,2
volte a testa: nelle ere tarde le case e il mazzo chiedono Costruzione e si
resta con l'altro.

La piu' debole e' ora la Lampo (26-27%, 66-68 PV; con le carte grandi a terra ha
perso 3 punti): da riguardare con la tabella `SPINTE_V3`, come la Scavo a 31.

## Quarantunesima misura: il Lampo vale il costo, Fondaco e Periferia in Costruzione

Dopo la quarantesima restavano il morto delle ere 4-5 (2,5 a testa: 1,4 Denaro
nell'era 4, 1,1 Idee nell'era 5) e la Lampo al 26%. Due cose viste nei dati:
la strategia Lampo chiude a 66 PV con 19,8 di Lampo ma 5,7 di Rendita (le
altre 10-16), e nelle ere 4 e 5 **tutte** le carte Lampo del mazzo valgono 1,
anche a costo 3 (lo stampo della v2), contro il metro ("un edificio rende in
Lampo il suo costo in Costruzione"). Nell'era 4 la tessera Fondaco e' l'unica a
produrre Denaro ed e' attivata 1,1 volte a testa per era; nell'era 5 lo stesso
per la Periferia. Tre controprove sugli stessi 300 semi, una sopra l'altra:

| a giocatore | era 3 | era 4 | era 5 | partita |
|---|---|---|---|---|
| **base** (quarantesima) prodotto / speso / morto | 9,4 / 7,2 / 2,2 | 9,1 / 6,5 / 2,5 (🪙 1,4) | 8,9 / 6,3 / 2,5 (💡 1,1) | 70,2 PV, Lampo 15,4 |
| **lampo_costo**: il Lampo del mazzo (ere 3-5) almeno pari al costo ⚒ | 9,4 / 7,2 / 2,2 | 9,1 / 6,7 / 2,4 | 8,9 / 6,5 / 2,4 | 72,2 PV, Lampo 17,3 |
| **+ Fondaco in Costruzione** | = | 9,1 / 7,0 / 2,2 (🪙 1,0) | 8,9 / 6,5 / 2,4 | 72,4 PV |
| **+ Periferia in Costruzione** | = | = | 8,9 / 6,7 / 2,1 (🪙 0,4) | 72,8 PV, Lampo 17,7 |
| costruzioni / potenziamenti / passi, base → tutte e tre | 2,81 / 0,95 / 0,75 → = | 2,43 / 0,70 / 1,16 → 2,58 / 0,60 / 1,07 | 2,26 / 0,86 / 1,17 → 2,42 / 0,69 / 1,14 | |

| vittorie | Bil | Cont | Lampo | Obi | Rend | Scavo |
|---|---|---|---|---|---|---|
| base | 36 | 33 | 26 | 39 | 34 | 31 |
| lampo_costo | 37 | 33 | 27 | 37 | 33 | 33 |
| + Fondaco | 39 | 31 | 26 | 39 | 36 | 29 |
| + Periferia | 39 | 34 | 25 | 35 | 37 | 30 |

Il Lampo pari al costo da' 2 PV a testa a **tutti** (17,7 di Lampo) e le carte
delle ere 4-5 si costruiscono il doppio (Osservatorio 0,11 → 0,28 a partita,
Villa 0,19 → 0,38, Ponte in acciaio 0,04 → 0,24, Grattacielo 0,05 → 0,14,
Biblioteca 0,30 → 0,41); la strategia Lampo guadagna 2 PV come le altre e
resta al 25-27%: il Lampo e' un canale che prendono tutti, non il suo
vantaggio. Le due tessere tolgono il Denaro che moriva (era 4: 1,4 → 1,0; era
5: 0,8 → 0,4) e lo danno in Costruzione, dove si passava: le costruzioni
salgono di 0,15 a era e i passi calano di 0,1. **Tutte e tre nel file base**;
`--variante lampo_vecchio` rifa' il file della quarantesima. Il morto e' ora
2,0 / 2,0 / 2,2 / 2,2 / 2,1: il budget del metro (1-2) e' a un passo.

## Quarantaduesima misura: la Lampo nel bot, `lampo_zero` a zero

Dopo la quarantunesima la Lampo era al 25% con 68 PV: 22,6 PV dal Lampo ma
5,6 di Rendita contro 10-16 delle altre, perche' la tabella `SPINTE_V3`
penalizzava di 1 ogni carta senza Lampo, cioe' tutte quelle a Rendita, le piu'
forti. Tre tarature con `--spinta` sul file base della quarantunesima, stessi
300 semi:

| | base | `lampo_zero=0` | `lampo=0.4, lampo_zero=0, lampo_potenzia=2.5` | `lampo=1.2, lampo_zero=-0.5` |
|---|---|---|---|---|
| vittorie Lampo | 25 | **31** | 31 | 29 |
| PV della Lampo | 68,3 | **71,0** | 70,7 | 69,8 |
| suoi canali: Lampo / Rendita / Cultura | 22,6 / 5,6 / 10,2 | 22,1 / 7,2 / 10,9 | 18,0 / 10,3 / 11,8 | 22,4 / 6,1 / 11,0 |
| le altre (Bil / Cont / Obi / Rend / Scavo) | 39 / 34 / 35 / 37 / 30 | 36 / 31 / 38 / 35 / 29 | 38 / 32 / 35 / 37 / 26 | 39 / 32 / 35 / 39 / 27 |

`lampo_zero` a zero e' la tabella da questa misura: +6 punti di vittorie e +2,7
PV, e la Lampo resta una Lampo (22 PV dal canale). La taratura bassa vince
uguale ma gioca come la Bilanciata (18 di Lampo, 10 di Rendita); quella alta
non rende. Vittorie ora fra 29 (Scavo) e 38 (Obiettivi); PV a testa 72,7.

## Quarantatreesima misura: gli sconti sugli edifici

Il designer (registro 169): "mancano gli sconti, che sono essenziali".
Variante `sconti_edifici`: sette azioni "+1 risorsa" o cambio diventano sconti
(Trappole da pesca su fiume, Insulae Civico, Mulino e Banco -1 Costruzione,
Bottega d'artista potenziamento, Officina Ingegneria, Caffe' letterario Arte),
validi per l'acquisto del turno e quindi solo quando attiva il padrone. Stessi
300 semi del file base (quarantaduesima: Lampo pari al costo, tessere in
Costruzione, `lampo_zero` 0).

| a giocatore | base | sconti_edifici |
|---|---|---|
| sconti usati a partita | 1,45 | 1,68 |
| morto per era | 2,0 / 2,0 / 2,2 / 2,2 / 2,2 | 2,0 / 2,0 / 2,2 / 2,2 / 2,1 |
| costruzioni per era | 3,56 / 3,28 / 2,83 / 2,58 / 2,41 | 3,56 / 3,27 / 2,80 / 2,55 / 2,44 |
| potenziamenti per era | 0,72 / 0,96 / 0,99 / 0,63 / 0,66 | 0,72 / 0,96 / 0,97 / 0,57 / 0,59 |
| PV a testa | 72,7 | 72,2 |
| vittorie Bil / Cont / Lampo / Obi / Rend / Scavo | 36 / 31 / 31 / 38 / 35 / 29 | 35 / 30 / 29 / 41 / 35 / 31 |

Niente si muove oltre l'errore. Il motivo e' nel ritmo: uno sconto sull'edificio
scatta solo se il padrone attiva quella colonna **e** compra in quel turno
una cosa che lo sconto copre; le sette carte si costruiscono 0,04-0,76 volte
a partita e insieme aggiungono 0,23 sconti usati. I potenziamenti delle ere
4-5 calano anzi di 0,06, perche' Bottega e Caffe' non danno piu' l'Idea con
cui li si pagava. **Il file base non cambia**: la decisione e' legata alla
quarantaquattresima (la "scelta"), dove lo sconto di un edificio va a chi lo
usa, cioe' a chi sta per comprare, e dovrebbe pesare molto di piu'.

Dal lotto base, con i contatori nuovi: il ⊕ da carta si apre 2,1 volte a
partita a giocatore e si usa 0,8 (39%); la finestra dopo la costruzione si
apre 12,2 e si usa 2,0 (16%).

## Quarantaquattresima misura: "stile Caylus", chi attiva usa un edificio della colonna

Il designer (registro 170): "se quando si attiva una colonna un giocatore possa
scegliere qualunque edificio, anche quelli non suoi, e brucia quell'effetto per
il turno? Quanti cambierebbe in meglio o in peggio?" Varianti `scelta` (niente
al padrone) e `scelta_pv` (1 PV al padrone quando lo usa un altro), stessi 300
semi del file base (quarantaduesima). Le condizioni "a ogni tua attivazione" e
"di un avversario" cadono: ogni carta dice "Usa:".

| a giocatore | base | scelta | scelta_pv |
|---|---|---|---|
| edifici usati a partita (propri / altrui) | 20 azioni ai padroni | 16,3 (6,1 / **10,2**) | uguale |
| attivazioni senza niente da usare | | 3,75 | uguale |
| azioni scattate: ★ / 🛡 / risorsa / ⚱ / ⇄ / ⊕ | 8,5 / 8,5 / 4,7 / 3,4 / 2,4 / 2,2 | 6,5 / 6,0 / 6,1 / 2,2 / 1,6 / 2,6 | uguale |
| prodotto per era | 9,8 / 10,2 / 9,5 / 9,1 / 8,9 | 10,8 / 11,2 / 9,9 / 9,5 / 9,2 | uguale |
| speso per era | 7,8 / 8,2 / 7,3 / 6,9 / 6,7 | 8,3 / 9,0 / 7,5 / 7,1 / 7,1 | uguale |
| morto per era | 2,0 / 2,0 / 2,2 / 2,2 / 2,2 | 2,5 / 2,2 / 2,4 / 2,4 / 2,1 | uguale |
| passi per era | 0,55 / 0,67 / 0,72 / 1,07 / 1,17 | 0,40 / 0,57 / 0,65 / 1,00 / 1,05 | uguale |
| costruzioni / potenziamenti a partita | 14,7 / 3,9 | 15,1 / 4,5 | uguale |
| PV a testa | 72,7 | 74,8 | **85,0** (10,2 di compenso) |
| canali: Lampo / Cont / Rendita / ★ / Scavo | 17,6 / 13,6 / 11,4 / 11,2 / 10,0 | 18,1 / 14,2 / 12,8 / 9,5 / 11,0 | + compenso 10,2 |
| vittorie Bil / Cont / Lampo / Obi / Rend / Scavo | 36 / 31 / 31 / 38 / 35 / 29 | 34 / **28** / 33 / **44** / 30 / 31 | 39 / **23** / 31 / 41 / 32 / 34 |

**Che cosa succede.** Si usano gli edifici degli altri due volte su tre (10,2
contro 6,1 propri): la colonna piena e' un menu per tutti. Chi attiva sceglie
risorse e ⊕ (da 4,7 a 6,1 e da 2,2 a 2,6) e lascia ★, 🛡, ⚱ e ⇄: si spende di
piu' (+0,5 a era nelle prime due, +0,4 nell'ultima), si costruisce e si
potenzia di piu' (15,1 e 4,5 contro 14,7 e 3,9), si passa di meno in tutte le
ere. Il morto sale di 0,2-0,5 nelle ere 1-4, perche' si producono piu' risorse
di quante il mercato ne assorba nel turno. La Rendita del censimento sale per
tutti (12,8 contro 11,4: piu' carte a Rendita costruite), i PV dalle ★ scendono
(9,5 contro 11,2). Il bot gioca la regola fino in fondo: 3,75 attivazioni a
partita trovano la colonna senza niente da usare (le prime dell'era 1, e le
colonne bruciate).

**Le strategie.** La Obiettivi sale a 44 e la Continuita' scende a 28 (la
Rendita a 30): la forbice da 9 punti diventa 16. Le due che perdono sono quelle
che vivevano delle ★ dei propri edifici in piedi, come previsto; la Scavo
guadagna 4 PV e la Lampo 1. Non e' ancora un giudizio sulla regola: le spinte
del bot sono tarate sulla regola di prima.

**Il compenso a 1 PV** non cambia una sola scelta dei bot (i numeri sono
identici: il bot non lo valuta, ne' quando usa ne' quando costruisce) e vale
10,2 PV a testa, il 14% del punteggio, distribuiti a chi ha gli edifici che
gli altri usano: la Continuita' scende a 23. Cosi' e' troppo. Se un compenso
serve, va piu' piccolo (1 PV ogni due usi, o 1 risorsa) e il bot deve
impararlo.

**In breve.** La regola funziona e fa quel che prometteva: una decisione in
piu' a turno (16 usi a partita, due terzi su edifici altrui), piu' spesa, meno
passi, interazione diretta. Costa 0,2-0,5 di morto a era e sposta
l'equilibrio verso Obiettivi e Scavo e via da Continuita' e Rendita, che si
ritarano nel bot. **Il file base non cambia**: la decisione e' del designer,
sui numeri. In corso la controprova `scelta_sconti`, la "scelta" con i sette
sconti sugli edifici (quarantatreesima), dove lo sconto va a chi sta per
comprare.

## Quarantacinquesima misura: la "scelta" con gli sconti sugli edifici

Controprova `scelta_sconti`: la "scelta" della quarantaquattresima piu' i sette
sconti della quarantatreesima, che qui vanno a chi usa l'edificio, cioe' a chi
sta per comprare. Stessi 300 semi.

| a giocatore | scelta | scelta_sconti |
|---|---|---|
| azioni sconto scattate / sconti usati a partita | 5,1 / 1,57 | 6,0 / 1,92 |
| morto per era | 2,5 / 2,2 / 2,4 / 2,4 / 2,1 | 2,5 / 2,2 / 2,3 / 2,3 / 2,0 |
| speso per era | 8,3 / 9,0 / 7,5 / 7,1 / 7,1 | 8,3 / 8,8 / 7,2 / 7,0 / 6,9 |
| costruzioni / potenziamenti a partita | 15,1 / 4,5 | 15,0 / 4,4 |
| PV a testa | 74,8 | 74,2 |
| vittorie Bil / Cont / Lampo / Obi / Rend / Scavo | 34 / 28 / 33 / 44 / 30 / 31 | 33 / 28 / 33 / 43 / 31 / 32 |

Anche qui poco: le sette carte vengono usate circa una volta a partita e lo
sconto si spende 0,35 volte in piu'. Chi sceglie preferisce una risorsa, che
si tiene, a uno sconto che vale solo se nel turno compra la cosa giusta. Il
morto cala di 0,1 nelle ere 3-5 e la spesa di 0,1-0,3: lo sconto ha sostituito
una risorsa che a volte si spendeva. **Per pesare, gli sconti dovrebbero stare
su piu' carte ed essere senza condizione** ("-1 a quel che compri in questo
turno"), oppure stare dentro il ⊕; da decidere con il designer.

## Quarantaseiesima misura: sconti senza condizione su dieci carte, e il ⊕ con lo sconto

Il designer (registro 171): "Ok vai". Il file base e' la "scelta" senza
compenso (= il lotto `scelta` della quarantaquattresima). Due controprove, una
sopra l'altra, stessi 300 semi: `sconti` (dieci carte con "-1 a quel che compri
in questo turno": Trappole, Terme, Insulae, Mulino, Mercato, Bottega, Loggia,
Banco, Officina, Caffe'; lo sconto vale per l'edificio o per il potenziamento)
e `sconti_extra` (anche il ⊕ porta lo sconto: "compri una cosa in piu' e paghi
1 in meno").

| a giocatore | base (scelta) | sconti | sconti_extra |
|---|---|---|---|
| sconti usati a partita | 1,57 | 2,88 | **5,02** |
| ⊕ aperto / usato a partita | 2,29 / 0,99 (43%) | 2,28 / 1,00 | 2,54 / **1,72 (68%)** |
| scelte vere (2+ edifici fra cui scegliere) | | 9,8 | 10,0 |
| costruzioni / potenziamenti a partita | 15,1 / 4,5 | 15,0 / 4,5 | **15,6** / 4,6 |
| speso per era | 8,3 / 9,0 / 7,5 / 7,1 / 7,1 | 8,3 / 8,6 / 7,2 / 6,9 / 6,7 | 8,0 / 8,2 / 6,9 / 6,7 / 6,6 |
| morto per era | 2,5 / 2,2 / 2,4 / 2,4 / 2,1 | 2,5 / 2,4 / 2,3 / 2,4 / 2,1 | 3,0 / 2,7 / 2,6 / 2,5 / 2,2 |
| PV a testa | 74,8 | 74,1 | 76,7 |
| vittorie Bil / Cont / Lampo / Obi / Rend / Scavo | 34 / 28 / 33 / 44 / 30 / 31 | 35 / 33 / 29 / 40 / 34 / 29 | 40 / 38 / 33 / 33 / 27 / 28 |

Gli sconti senza condizione si usano: 2,9 a partita invece di 1,6, e la
forbice delle vittorie si stringe da 28-44 a 29-40 (la Continuita' risale a
33, la Obiettivi scende a 40). Il ⊕ con lo sconto dentro e' la cosa che
mancava al ⊕: si usa il 68% delle volte invece del 43%, le costruzioni salgono a
15,6 (0,45 in piu' nell'era 1) e i PV a 76,7. Il "morto" sale di 0,1-0,5 ma per
un motivo contabile: con gli sconti si compra di piu' pagando di meno, e quel
che non si paga resta in mano a fine era. Il numero giusto da guardare e'
quello delle costruzioni e dei potenziamenti, che salgono. **Tutte e due nel
file base**; `--variante senza_sconti` rifa' la quarantaquattresima.

Le scelte vere sono 10 a partita a giocatore (su 16 usi): e' la decisione in
piu' che la regola promette. Le strategie: Bilanciata 40 e Continuita' 38 in
testa, Rendita 27 e Scavo 28 in coda. Le spinte della Rendita e della Scavo
sono tarate sulla regola di prima: quarantasettesima misura.

## Quarantasettesima misura: Rendita e Scavo nel bot, sulla regola nuova

Con la "scelta", gli sconti e il ⊕ nel file base (quarantaseiesima) la Rendita
era al 27% e la Scavo al 28, Bilanciata 40 e Continuita' 38. Cinque tarature
con `--spinta`, stessi 300 semi:

| | base | `rendita_per_era=1.3` | + `scavo_premio=0.8, scavo_terra_scavo=0.5` | + `scavo_premio=1.2, scavo_terra_scavo=0.5, scavo_terra=-0.2` |
|---|---|---|---|---|
| Bil / Cont / Lampo / Obi / Rend / Scavo | 40 / 38 / 33 / 33 / 27 / 28 | 38 / 37 / 31 / 33 / 33 / 27 | **35 / 35 / 33 / 31 / 37 / 29** | 36 / 33 / 33 / 32 / 38 / 27 |
| forbice | 27-40 | 27-38 | **29-37** | 27-38 |
| PV della Rendita / della Scavo | 75,2 / 75,6 | 74,9 / 75,2 | 76,8 / 74,0 | 76,7 / 74,1 |

(Un primo lotto con pesi "v1" della Scavo era identico alla base: con la v3 il
bot usa il ramo v2, `scavo_premio` e compagni; quei pesi erano codice morto e
sono stati tolti.)

La Rendita a 1,3 vale +6-10 punti alla Rendita. Le spinte della Scavo non
alzano la Scavo (29, e 1,5 PV in meno: insegue le pile ricche e lascia la
Rendita), ma cambiano le partite di tutti e stringono la forbice a **29-37**,
la piu' stretta misurata: otto punti, due volte l'errore. E' la tabella
`SPINTE_V3` da questa misura. La Scavo resta l'ultima perche' lo Scavo e' un
canale che prendono tutti (11-12 PV a testa), come il Lampo: la strategia non
ha un vantaggio suo, e il suo margine sta nei ritrovamenti, che nei bot non
ci sono ancora.

Il file base oggi, partita intera: 76,8 PV a testa, Lampo 18,9, Continuita'
14,8, Rendita 12,5, Scavo 11,5, PV prodotti 9,1; 16 usi di edifici a partita
a giocatore (10 con una scelta vera), 15,6 costruzioni, 4,6 potenziamenti,
5,0 sconti, il ⊕ usato il 68% delle volte.

## Quarantottesima misura: la Ritrovamenti nel bot, e le tre carte grandi

Il designer: "Ok procedi e poi mergia". Due cose, stessi 300 semi del file base
(quarantasettesima).

**La Ritrovamenti** (registro 173), settima strategia del canone v3: lo Scavo
stampato del Personaggio al draft (gli scheletri), le caselle dell'edificio che
lasceranno tessere, nell'era 5 costruire sopra le proprie rovine mai scavate (le
tessere valgono solo riportate alla luce), i token Arte, l'azione ⚱. Con sette
strategie e tre posti il torneo cambia combinazioni: i numeri delle altre non
si confrontano uno a uno con la quarantasettesima.

| vittorie (7 strategie) | Bil | Cont | Lampo | Obi | Rend | Ritro | Scavo |
|---|---|---|---|---|---|---|---|
| prima taratura (`ritro_caselle` 0,6) | 25 | 36 | 31 | 44 | 27 | **43** | 27 |
| PV | 76,7 | 78,2 | 75,5 | 79,5 | 74,1 | **78,9** | 73,6 |

La Ritrovamenti vince il 43% con 78,9 PV, ma non con gli scheletri: il suo
Scavo e' 12,5 contro 11,5 della Scavo, mentre la sua Rendita e' 14,2 (le altre
11-13) e i finali 5,7. Il peso sulle caselle (0,6 a casella) la porta sulle
carte larghe, che sono quelle a Rendita 2 (Castello, Anfiteatro, Fortezza...):
una Rendita con un nome diverso. La Bilanciata scende a 25 e la Rendita a 27,
perche' la Ritrovamenti compra le loro carte. Seconda taratura al ribasso, sul
file base con le carte grandi:

| vittorie (7 strategie) | Bil | Cont | Lampo | Obi | Rend | Ritro | Scavo |
|---|---|---|---|---|---|---|---|
| caselle 0,6 (prima) | 29 | 36 | 27 | 44 | 25 | 44 | 28 |
| caselle 0,3 | 30 | 38 | 27 | 42 | 25 | 42 | 30 |
| **caselle 0,2, arte 0,4, scheletro 0,3** | 32 | 37 | 28 | 43 | 32 | **33** | 28 |

Con le caselle quasi a zero la Ritrovamenti torna al 33% (76,8 PV) e restituisce
alla Rendita i suoi punti (25 → 32): e' la tabella `SPINTE_V3`. I suoi canali,
Scavo 12,4 e Rendita 14,0, dicono che e' ancora per meta' una Rendita: lo
scheletro e l'arte valgono 2,4 e 1,6 PV a partita, troppo poco per fare una
strategia da soli. La Obiettivi al 42-44 nel torneo a sette strategie (31-38 a
sei): con `obiettivi_peso` 0,8 scende a 40 (Bil 31, Cont 38, Lampo 30, Rend 33,
Ritro 34, Scavo 27), forbice 27-40. E' la tabella `SPINTE_V3` con cui la v3
va su main: sette strategie fra 27 e 40, con l'errore a 4.

Il file base alla chiusura della PR #73, partita intera a tre: 76,1 PV a testa,
Lampo 18,7, Continuita' 14,9, Rendita 12,6, Scavo 11,3, PV prodotti 9,3,
finali 4,7.

**Le tre carte grandi** (registro 174): la Stazione su qualunque terreno, il
Grattacielo a 2 binari, la Fortezza ⚒3 🪙1. Costruite a partita, prima → ora:
Fortezza 0,08 → 0,11, Grattacielo 0,17 → 0,26, Stazione 0,03 → 0,03 (le tre
colonne restano la sua forma, il terreno non era il collo). Vittorie uguali
entro l'errore. **Nel file base**; `--variante grandi_vecchie` rifa' le carte
della v2. (Registro 178: il Grattacielo e' tornato a tre binari, com'e'
stampato; restano la Stazione su qualunque terreno e la Fortezza ⚒3 🪙1.)

## Quarantanovesima misura: il file base rimisurato col bot corretto

Il registro 177 ha corretto il bot che, quando l'ultima presa del draft era
sua, giocava il primo piazzamento dell'era di chi era primo nell'ordine. Le
misure dalla quarantaquattresima alla quarantottesima erano state prese con
quel difetto (circa due ere su tre, il primo turno di un giocatore giocato
con la strategia di un altro). Stessi 300 semi, stesso file base e stessa
tabella `SPINTE_V3` della quarantottesima.

| a giocatore | prima (48ª) | ora |
|---|---|---|
| prodotto per era | 10,9 / 11,0 / 9,6 / 9,3 / 8,8 | 10,8 / 11,0 / 9,6 / 9,2 / 8,7 |
| speso per era | 8,0 / 8,3 / 7,0 / 6,7 / 6,6 | 8,0 / 8,3 / 6,9 / 6,6 / 6,6 |
| morto per era | 2,9 / 2,7 / 2,5 / 2,6 / 2,2 | 2,8 / 2,7 / 2,7 / 2,6 / 2,2 |
| costruzioni per era | 4,32 / 3,41 / 2,85 / 2,52 / 2,48 | 4,35 / 3,40 / 2,81 / 2,51 / 2,44 |
| PV a testa | 76,1 | 75,6 |
| canali Lampo / Cont / Rendita / Scavo / ★ | 18,7 / 14,9 / 12,6 / 11,3 / 9,3 | 18,6 / 14,7 / 12,6 / 11,2 / 9,2 |
| vittorie Bil / Cont / Lampo / Obi / Rend / Ritro / Scavo | 31 / 38 / 30 / 40 / 33 / 34 / 27 | 36 / 38 / 27 / 42 / 29 / 37 / 26 |

L'economia non si muove: produzione, spesa, morto, costruzioni e canali di PV
sono gli stessi entro un decimo. Si muovono un poco le vittorie: la
Bilanciata +5, la Rendita -4, la Ritrovamenti +3, la Lampo -3, tutte entro
o sul bordo dell'errore (4). La forbice e' 26-42: la Obiettivi in testa e la
Scavo in coda, come prima. Le conclusioni delle misure 44-48 (la "scelta", gli
sconti, il ⊕, il Lampo pari al costo, le tessere) restano: erano sull'economia,
che il difetto non toccava. Sulle vittorie la tabella va riguardata con questa
misura come base, se il designer vuole stringere ancora: le leve sono
`obiettivi_peso` (0,8) e la Scavo, che ha il suo margine nei ritrovamenti.

## Cinquantesima misura: il Grattacielo a tre binari, livello 1, qualunque terreno

Il registro 179: il designer, "prova con tre binari e livello 1 e misura,
terreno qualunque". Nel file base il Grattacielo passa da pianura/livello 2 a
terreno qualunque/livello 1, sempre tre binari (la carta stampata). Stessi 300
semi della quarantanovesima, stesso bot.

| a partita | 49ª (pianura, liv. 2) | ora (qualunque, liv. 1) |
|---|---|---|
| Grattacieli costruiti | 85 (0,28) | 85 (0,28) |
| partite con Grattacielo | 85 | 85, di cui 55 le stesse |
| terreno sotto: pianura / bosco / fiume / collina | 38 / 32 / 10 / 5 | 25 / 40 / 13 / 7 |
| livello: 0 / 1 / 2 / 3 / 4 | 42 / 0 / 22 / 12 / 9 | 50 / 6 / 16 / 7 / 6 |
| PV resi da ogni Grattacielo | 3,2 | 3,2 |
| PV a testa | 75,6 | 75,5 |
| vittorie Bil / Cont / Lampo / Obi / Rend / Ritro / Scavo | 36 / 38 / 27 / 42 / 29 / 37 / 26 | 32 / 37 / 27 / 43 / 29 / 39 / 27 |

Il numero non si muove: 85 Grattacieli in entrambi i lotti. Si muove solo
dove sta: meno in pianura (il terreno non e' piu' obbligato), un po' piu'
spesso a terra, qualche volta al livello 1 che prima era vietato. Economia e
canali di PV identici, vittorie entro l'errore.

Perche' non cambia nulla: i tre vincoli che spiegavamo al designer (tre binari
liberi, livello 2, pianura) non erano il collo di bottiglia. Con
`a_terra_o_sopra` (registro 166) il Grattacielo andava gia' a terra senza
guardare il livello, e la pianura e' il terreno piu' comune. Il freno e'
altrove: costa 3 Costruzione e 1 Idea, con la Stazione la carta piu' cara
dell'era 5, in un'era in cui un giocatore produce 8,7 risorse e ne spende
6,6; e il bot non pesa il suo finale (+1 PV per livello, -1 alle cime altrui
adiacenti): per lui vale il Lampo 3 meno il costo, e con Rendita 0 e tre
caselle da coprire conviene solo quando seppellisce molte tessere. Fra le quattordici carte dell'era 5 sta a meta' classifica:

| carta dell'era 5 | costruite in 300 partite |
|---|---|
| Case piccole (riserva) | 599 |
| Officina | 221 |
| Condominio, Monumento ai caduti | 186, 181 |
| Caffe' letterario, Parco archeologico, Case grandi | 150, 147, 141 |
| Fondazione d'arte, Biblioteca | 139, 137 |
| Museo, **Grattacielo** | 87, **85** |
| Ponte in acciaio, Universita' | 58, 53 |
| Stazione | 16 |

Il mercato dell'era 5 mostra 6 carte su 14 e si rifornisce a ogni acquisto:
con 7,3 costruzioni a partita quasi tutto il mazzo passa in vetrina, quindi
il Grattacielo si vede in gran parte delle partite e si compra in una su
quattro. La modifica non costa niente e non rende niente: la decisione se
tenerla (carta piu' libera) o tornare alla stampa (pianura, livello 2) e' del
designer. Se si vuole vederlo di piu', la leva e' il costo o il suo finale,
non il terreno.

## Cinquantunesima misura: lo spianamento parziale, terrapieno sotto e rovina accanto

Il registro 180: il designer, davanti a due Terrapieni soli lasciati da un
Acquedotto spianato da una Palazzina di una casella, "le caselle dove
effettivamente costruisci [sono] dei terrapieni, perche' stai effettivamente
usando il suo materiale e lo stai coprendo, mentre le caselle rimaste libere
diventano rovine perche' NON ci hai costruito sopra. In questo modo si formano
nuove rovine che possono valere qualcosa". Nel file base `tessere_scavo.spianato:
"parziale"`: le caselle coperte dalla carta nuova sono terrapieno, le altre
restano rovina del proprietario con la loro tessera. Stessi 300 semi della
quarantanovesima, stesso bot (che pesa lo Scavo perso solo per la parte
coperta). `--variante spianato_intero` rifa' la regola di prima.

| a partita | prima (49ª) | ora |
|---|---|---|
| spianamenti | 8,6 | 8,6 |
| di cui parziali (carta piu' larga della nuova) | 2,9 (*) | 2,9: 806 carte da 2 caselle, 72 da 3 |
| caselle rimaste rovina | 0 | 3,2 |
| spianati ancora a vista a fine partita | 1,05 | 1,06 |
| PV di Scavo resi dagli spianati parziali | 0 | 7,7 (2,6 a giocatore) |

(*) Nella 49ª il conteggio non c'era: lo si deduce dal fatto che il bot spiana
le stesse volte e lascia a vista lo stesso numero di carte (315 contro 317).
La regola non cambia che cosa fa il bot: cambia quanto valgono quelle caselle.

| a giocatore | prima (49ª) | ora |
|---|---|---|
| PV a testa | 75,6 | 78,7 |
| canale Scavo | 11,2 | 14,7 |
| di cui tessere / scheletri / arte / bonus in partita | 6,7 / 2,1 / 1,3 / 4,5 | 9,4 / 3,0 / 1,7 / 5,3 |
| rovine riscoperte nell'era 5 | 2,14 | 2,87 |
| canali Lampo / Cont / Rendita / ★ | 18,6 / 14,7 / 12,6 / 9,2 | 18,6 / 14,7 / 12,4 / 9,2 |
| bonus scavo nell'era 5 | 1,20 | 1,51 |
| prodotto / speso / morto nell'era 5 | 8,7 / 6,6 / 2,2 | 8,7 / 6,5 / 2,2 |
| vittorie Bil / Cont / Lampo / Obi / Rend / Ritro / Scavo | 36 / 38 / 27 / 42 / 29 / 37 / 26 | 34 / 42 / 23 / 37 / 28 / 39 / 31 |

Tutto il guadagno va nel canale Scavo: +3,5 PV a testa, e gli altri canali non
si muovono di un decimo. Le caselle rimaste rovina (3,2 a partita) portano
tessere che l'era 5 scopre (le rovine riscoperte salgono da 2,1 a 2,9 a
giocatore) e su cui si costruisce col bonus (1,20 -> 1,51 nell'era 5). Il
canale Scavo passa da 11,2 a 14,7 e raggiunge la Continuita'; il Lampo resta
primo a 18,6.

Per strategia il canale Scavo cresce per tutte (+2,5 la Continuita', +4,2 la
Ritrovamenti, +4,1 la Scavo). Le vittorie si muovono di conseguenza: la Scavo
risale da 26 a 31 e non e' piu' ultima, la Ritrovamenti 37 -> 39, la
Continuita' 38 -> 42 (tutte le sue rovine 1x2 spianate restano per meta'
sue); la Obiettivi scende 42 -> 37 e la Lampo 27 -> 23, ora la piu' debole.
La forbice e' 23-42, contro 26-42 di prima: la stessa larghezza, con la coda
spostata dalla Scavo alla Lampo.

La regola fa quel che il designer chiedeva: le rovine accanto valgono
qualcosa, lo spianamento di una carta larga per una stretta non e' piu'
gratis per la mappa e non e' piu' un buco a vista. Il prezzo e' 3,5 PV a testa
in piu' nel canale Scavo. Il designer: "tieni lo scavo a 14,7". Resta il
Lampo a 23: e' il bot (`SPINTE_V3`, `lampo`) da riguardare, perche' il canale
Lampo non e' cambiato.

## Cinquantaduesima misura: la taratura della Lampo nel bot

Dopo lo spianamento parziale (cinquantunesima) la Lampo era l'ultima, al 23%.
Il designer: "vai con la taratura della Lampo nel bot". Tre tarature con
`--spinta` sugli stessi 300 semi, file base della 51ª, bot senza i finali.

| vittorie | 51ª (`lampo` 0,8) | `lampo` 0,5 | `lampo` 1,1 | `lampo_potenzia` 0,5 |
|---|---|---|---|---|
| Bil / Cont / Lampo / Obi / Rend / Ritro / Scavo | 34 / 42 / 23 / 37 / 28 / 39 / 31 | 28 / 39 / **35** / 34 / 28 / 40 / 29 | 32 / 42 / 24 / 41 / 25 / 40 / 30 | 32 / 42 / 22 / 36 / 30 / 39 / 33 |
| PV della Lampo | 76,3 | 78,4 | 77,9 | 77,8 |
| canali della Lampo: Lampo / Rendita / Scavo | 24,2 / 7,1 / 13,0 | 20,7 / 11,0 / 13,0 | — | — |
| PV a testa | 78,7 | 78,6 | 79,0 | 78,9 |

`lampo` 0,5 porta la Lampo dal 23 al 35% e dai 76,3 ai 78,4 PV, la media del
tavolo. Resta una Lampo: 20,7 PV dal canale contro i 18-19 delle altre, ma
non butta piu' le carte a Rendita (11,0 contro 7,1 di prima). Spingere di
piu' (1,1) o frenare i potenziamenti (`lampo_potenzia` 0,5) non muove nulla.
La forbice passa da 23-42 a 28-40. Scelta: `lampo` 0,5 nella tabella
`SPINTE_V3` (registro 184).

## Cinquantatreesima misura: il bot che pesa i finali, a carte vecchie

Il registro 181: il bot non pesava gli effetti `on_final_scoring`. Stesso
file base della 51ª, bot coi finali (`finali_peso` 0,8, `finali_peso_prima`
0,4), tabella della 51ª.

| a giocatore | 51ª (bot cieco) | bot coi finali |
|---|---|---|
| PV a testa | 78,7 | 84,0 |
| canale effetti finali | 4,6 | 10,0 |
| altri canali Lampo / Cont / Scavo / Rendita | 18,6 / 14,7 / 14,7 / 12,4 | 18,8 / 14,6 / 14,8 / 12,4 |
| Universita' costruite in 300 partite | 46 | 185 |
| Grattacieli | 80 | 52 |
| vittorie Bil / Cont / Lampo / Obi / Rend / Ritro / Scavo | 34 / 42 / 23 / 37 / 28 / 39 / 31 | 40 / 26 / 19 / 37 / 39 / 42 / 29 |

Il canale dei finali raddoppia e i PV salgono di 5,3 a testa: e' quasi tutta
l'Universita', costruita in 185 partite su 300 appena il bot ne vede il
valore ("+1 PV per ogni tuo Personaggio reclutato": nella v3 tutti ne
reclutano 20, quindi +20 fissi a chi arriva primo, registro 182). Le
vittorie si rimescolano intorno a chi la prende: la Rendita sale a 39, la
Continuita' crolla a 26, la Lampo a 19. Il Grattacielo scende (80 -> 52):
coi finali il bot preferisce l'Universita' allo stesso prezzo. La misura non
vale come taratura, vale come prova: la carta era rotta e il bot cieco la
nascondeva. Da qui le decisioni dei registri 182 (Universita' sui Personaggi
con Scavo 5+) e 183 (Grattacielo a 2 Costruzione 1 Idea), misurate insieme
nella cinquantaquattresima.

## Cinquantaquattresima misura: tutto insieme, e la tabella che non entrava in gioco

Lampo 0,5 in tabella (registro 184), bot coi finali (181), Universita' sui
Personaggi con Scavo 5+ (182), Grattacielo a 2 Costruzione 1 Idea (183);
stessi 300 semi della 51ª. Due lotti: la tabella com'e', e `--spinta
lampo=0.8` per separare la taratura dalle carte.

| a giocatore | 51ª | tutto (tabella) | tutto, `--spinta lampo=0.8` |
|---|---|---|---|
| PV a testa | 78,7 | 81,1 | 81,0 |
| canale effetti finali | 4,6 | 6,9 | 6,8 |
| Lampo / Cont / Scavo / Rendita | 18,6 / 14,7 / 14,7 / 12,4 | 18,8 / 14,6 / 15,0 / 12,4 | 18,7 / 14,5 / 14,9 / 12,5 |
| Universita' costruite | 46 | 111 | 112 |
| Grattacieli costruiti, di cui al livello 2+ | 80, 30 | 106, 55 | 101, 51 |
| vittorie Bil / Cont / Lampo / Obi / Rend / Ritro / Scavo | 34 / 42 / 23 / 37 / 28 / 39 / 31 | 31 / 32 / 22 / 37 / 33 / 45 / 33 | 27 / 32 / 36 / 36 / 31 / 42 / 29 |
| canali della Lampo: Lampo / Rendita | 24,2 / 7,1 | 24,3 / 7,1 | 22,4 / 9,7 |

Le carte: l'Universita' nuova si costruisce 111 volte (46 prima, 185 col
+20) e il canale dei finali sale di 2,3 PV a testa, non piu' di 5,4; il
Grattacielo a 2 e 1 si costruisce 106 volte, e per la prima volta piu'
spesso in alto che a terra (55 al livello 2 o piu' contro 30), come lo
voleva il designer. Il resto dell'economia non si muove.

La sorpresa e' la Lampo: col lotto "tutto" sta al 22 e gioca ancora come a
0,8 (24,3 PV dal canale, 7,1 di Rendita), mentre `--spinta lampo=0.8` la
porta al 36 giocando piu' morbida (22,4 / 9,7). Due lotti identici nelle
carte e diversi solo nel modo di dare la spinta non potevano dare questo:
qualcosa leggeva la tabella in un altro modo. Era la tabella per numero di
giocatori della v2 (`SPINTE_V2_PER_GIOCATORI`), che entrava anche nella v3 e
a tre giocatori copriva quattro voci di `SPINTE_V3`: `lampo` 1,2,
`obiettivi_peso` 1,5, `rendita_zero` 0, `scavo_premio` 0. Le tarature
scritte in tabella dalla 47ª in poi non erano mai entrate in gioco; quelle
misurate con `--spinta` si' (vince su tutto). Quindi il lotto "tutto" ha
giocato la Lampo a 1,2, e tutte le misure dalla 49ª alla 53ª hanno giocato
con quei quattro valori, non con quelli scritti (registro 185). Corretto:
la tabella per giocatori resta alla v2. La misura con la tabella vera e' la
cinquantacinquesima.

## Cinquantacinquesima misura: la tabella `SPINTE_V3` senza coperture

Dopo il registro 185 la tabella scritta e' quella che gioca. Due lotti con
finali, Universita' e Grattacielo nuovi: la tabella com'era scritta
(`lampo` 0,5, `obiettivi_peso` 0,8, `rendita_zero` -1,5, `scavo_premio`
0,8) e la stessa con `--spinta lampo=0.8`. Confronto con la 54ª "spinta
0,8", che aveva i valori coperti (`obiettivi_peso` 1,5, `rendita_zero` 0,
`scavo_premio` 0) e lo stesso `lampo` 0,8.

| vittorie | 54ª, `lampo` 0,8 coi valori coperti | tabella scritta | tabella scritta, `lampo` 0,8 |
|---|---|---|---|
| Bil / Cont / Lampo / Obi / Rend / Ritro / Scavo | 27 / 32 / 36 / 36 / 31 / 42 / 29 | 36 / 39 / 35 / 37 / **22** / 48 / **18** | 34 / 36 / 36 / 36 / 26 / 45 / 21 |
| PV a testa | 81,0 | 80,5 | 80,3 |
| PV della Rendita, canali Lampo / Rendita / Cont | 80,6 · 15,9 / 15,9 / 13,3 | 74,7 · 11,9 / 17,9 / 9,9 | 75,2 |
| PV della Scavo | 79,1 | 77,2 | 76,9 |

I valori scritti e mai giocati fanno male: `rendita_zero` -1,5 fa scartare
alla Rendita ogni carta che non rende (Lampo 11,9 e Continuita' 9,9 contro
15,9 e 13,3) e la porta al 22% con 74,7 PV; `scavo_premio` 0,8 porta la
Scavo al 18. `lampo` 0,5 o 0,8 e' lo stesso (35-36): il 22-23% delle misure
51-54 veniva dall'1,2 coperto, non dallo 0,8 scritto. `obiettivi_peso` 0,8 o
1,5 non muove la Obiettivi (36-37).

Scelta (registro 186): in tabella vanno i valori davvero misurati, quelli
della 54ª "spinta 0,8": `lampo` 0,8, `obiettivi_peso` 1,5, `rendita_zero`
0, `scavo_premio` 0; restano `rendita_per_era` 1,3, `scavo_terra_scavo` 0,5,
`lampo_zero` 0 e i finali. E' la configurazione del lotto 54ª "spinta 0,8",
che diventa la base: vittorie 27 (Bil) - 42 (Ritro), PV 81,0, canali Lampo
18,7 / Scavo 14,9 / Cont 14,5 / Rendita 12,5 / ★ 9,1 / finali 6,8. Il
registro 184 (Lampo 0,5) e' superato: a 0,8 la Lampo sta al 36.

Quel che resta: la Ritrovamenti e' la piu' forte (42-48 in tutti i lotti
coi finali: i suoi 8,4 PV di finali sono i piu' alti, Museo e Parco
archeologico sono carte sue), la Bilanciata e la Scavo le piu' deboli
(27-29). Le leve sono `ritro_*` e il peso dei finali per strategia.

## Cinquantaseiesima misura: la taratura della Ritrovamenti

Il designer: "vai con la taratura della Ritrovamenti", poi "scegli tu".
Base: la 54ª "spinta 0,8" (tabella del registro 186): Ritro al 42% con
84,4 PV contro 79-81 delle altre. Tre giri sugli stessi 300 semi.

**Primo giro, le sue manopole.** `ritro_riscoperta` 0,8: 44 (84,8 PV);
con `ritro_caselle` 0,1: 43 (84,2); draft tiepido (`ritro_scheletro` 0,2,
`ritro_arte` 0,3, riscoperta 1,0): 42 (84,5). Niente.

**Secondo giro, piu' largo.** "Stretta" (caselle 0, riscoperta 0,8,
`ritro_azione_scavo` 0, nuova manopola per la spinta che era fissa): 40
(83,5). Finali pesati meno per tutti (0,6 / 0,3): 42 (84,0).
`ritro_scheletro` 0: 39 (82,1). Intanto l'audit ha il finale reso carta
per carta (`finale` nella riga J, campo `Building.finale_reso`):

| carta | finale medio a costruzione | costruite in 300 partite |
|---|---|---|
| Universita' | 7,4 | 112 |
| Museo | 6,9 | 183 |
| Stazione (max 5) | 4,8 | 14 |
| Parco archeologico | 4,4 | 185 |
| Condominio (max 4), Fondazione d'arte | 3,2 / 3,2 | 256 / 222 |
| le altre | 0 - 3,0 | |

La Ritro prendeva dall'Universita' 2,3 PV a partita contro 0,6-0,8 delle
altre (col draft archeologico ha 7-8 Personaggi con Scavo 5+) e dal Museo
1,3-2,0 (con lo spianamento parziale le rovine riscoperte sono 2,9 a
giocatore, e "+2 per rovina riscoperta" e' diventato grasso).

**Terzo giro, il tetto.** Museo max 6, Universita' max 5 (registro 187),
come la Stazione; `--variante finali_senza_tetto` li toglie.

| | base | tetto | tetto + `ritro_scheletro` 0 |
|---|---|---|---|
| finale medio Universita' / Museo | 7,4 / 6,9 | 4,6 / 5,8 | 4,9 / 5,7 |
| finali della Ritro / della Bilanciata | 7,9 / 6,4 | 6,3 / 6,0 | 6,2 / 6,0 |
| PV a testa, canale finali | 81,0 · 6,8 | 80,4 · 6,2 | 80,2 · 6,2 |
| PV della Ritro | 84,4 | 83,4 | 81,3 |
| vittorie Bil / Cont / Lampo / Obi / Rend / Ritro / Scavo | 27 / 32 / 36 / 36 / 31 / 42 / 29 | 28 / 32 / 34 / 33 / 30 / 44 / 31 | 29 / 36 / 32 / 38 / 28 / 40 / 30 |

Col tetto il vantaggio nei finali sparisce (6,3 contro 6,0) ma la Ritro
resta al 44 con 3 PV di margine: li prende dallo Scavo (16,3 contro 14,9)
e dalla Rendita (14,2 contro 12,5, le carte larghe sono quelle a Rendita
2). E' la strategia fatta per il canale che lo spianamento parziale ha
ingrassato, e che il designer ha voluto tenere a 14,7. Col draft a zero
scende al 40 con 1,1 PV sopra la media: forbice 28-40, la piu' stretta
misurata nel torneo a sette.

Scelta: tetti e `ritro_scheletro` 0 in tabella. La Ritro resta la piu'
forte di poco e lo e' per via delle rovine, non di una carta; il draft dei
Personaggi con Scavo alto torna a tutti, e l'Universita' smette di essere
la carta di una strategia sola (0,5 PV a partita per tutte). Base da qui:
il lotto "tetto + scheletro 0", 80,2 PV a testa.

## Cinquantasettesima misura: gli scheletri sono i Personaggi (il sacchetto)

Il registro 188: una tessera per Personaggio, nel sacchetto quando viene
reclutato; la rovina pesca al crollo; la tessera riportata alla luce paga il
suo Scavo a chi ha quel Personaggio, chiunque scavi; il proprietario della
rovina non incassa dalle tessere. Variante `scheletri_personaggi` contro la
base della 56ª, stessi 300 semi a 3 giocatori. Il designer chiedeva se cambia
lo spianare e il costruire sopra le rovine.

| a giocatore | base (56ª) | sacchetto |
|---|---|---|
| spianamenti / di cui parziali | 2,9 / 0,9 | 2,8 / 0,9 |
| costruzioni sopra rovine proprie / altrui | 5,1 / 3,0 | 5,0 / 3,1 |
| rovine riscoperte nell'era 5 | 2,93 | 2,81 |
| bonus scavo di chi costruisce sopra (PV) | 5,3 | 5,4 |
| tessere pescate / riportate alla luce | 7,5 / 3,0 | 7,6 / 3,0 |
| volte in cui il sacchetto era vuoto | - | 0 |
| PV a testa | 80,2 | 83,1 |
| canale Scavo, di cui dalle tessere | 14,8 · 9,5 | 16,9 · 11,4 |
| Lampo / Cont / Rendita / ★ / finali | 18,8 / 14,5 / 12,5 / 9,0 / 6,2 | 18,8 / 14,7 / 13,0 / 9,2 / 6,3 |
| vittorie Bil / Cont / Lampo / Obi / Rend / Ritro / Scavo | 29 / 36 / 32 / 38 / 28 / 40 / 30 | 41 / 32 / 30 / 37 / 39 / 27 / 27 |

Spianare e costruire sopra non cambiano di un decimo: il bot spiana e sale
sulle rovine come prima, perche' quel che lo muove e' il bonus scavo di chi
costruisce e il posto, non le tessere future del padrone della rovina. Il
sacchetto non resta mai vuoto, nemmeno nell'era 1. Le tessere scoperte sono
3 a testa come prima, e rendono 11,4 PV invece di 9,5 (lo Scavo medio dei
Personaggi e' 3,9 contro 1,5 delle tessere di oggi piu' gli scheletri): il
canale Scavo sale di 2 e i PV di 3 a testa.

La cosa che cambia davvero e' chi incassa: prima le tessere pagavano il
padrone della rovina, e la Ritrovamenti ci costruiva sopra la sua
strategia (riscoprire le proprie rovine); ora pagano chi ha i Personaggi, a
tutti allo stesso modo (canale Scavo fra 15,8 e 17,7 per ogni strategia).
La Ritrovamenti scende dal 40 al 27, la Scavo resta al 27, la Bilanciata
sale al 41 e la Rendita al 39: forbice 27-41, come prima ma con la coda
spostata sulle due strategie delle rovine, che hanno perso la loro nicchia.
Se la regola piace, le due strategie vanno ripensate attorno al draft dei
Personaggi con Scavo alto (il bot oggi lo pesa 0,15 a punto per tutti) e
allo scavare le pile altrui.

Controllo a 2 e 4 giocatori (100 partite ciascuno): tessere pescate 7,4 /
7,6 / 7,0 e scoperte 3,0 / 3,0 / 2,9 a giocatore a 2 / 3 / 4; scheletri
11,1 / 11,4 / 11,1 PV a testa; il sacchetto non e' mai vuoto. La quota di
ognuno non dipende dal numero di giocatori, com'era voluto.

## Cinquantottesima misura: Scavo e Ritrovamenti col sacchetto

Il registro 189: con le tessere che pagano chi ha i Personaggi, le due
strategie delle rovine erano al 27%. Manopola al draft: lo Scavo del
Personaggio vale per loro qualcosa in piu' dello 0,15 di tutti. Stessi 300
semi, base la 57ª (sacchetto).

| vittorie Bil / Cont / Lampo / Obi / Rend / Ritro / Scavo | PV a testa |
|---|---|
| base: 41 / 32 / 30 / 37 / 39 / 27 / 27 | 83,1 |
| 0,3 a tutte e due: 35 / 35 / 29 / 29 / 33 / **43** / 29 | 83,3 |
| 0,6 a tutte e due: 31 / 30 / 29 / 28 / 37 / **44** / 35 | 82,5 |
| 0,3 a tutte e due + riscoperta 2,0: 35 / 35 / 28 / 29 / 33 / 44 / 29 | 83,3 |
| Scavo 0,6, Ritro 0,15: **31 / 33 / 30 / 31 / 37 / 37 / 33** | 82,4 |
| Scavo 0,6, Ritro 0,1: 32 / 32 / 31 / 33 / 41 / 29 / 35 | 82,7 |

La leva del draft e' forte e asimmetrica: a 0,3 la Ritrovamenti passa dal 27
al 43 (i suoi scheletri rendono 14,5 PV contro 10,7) perche' la sua
valutazione della riscoperta si somma; la Scavo si muove poco (29 a 0,3, 35
a 0,6). Separate le manopole (`ritro_scheletro`, `scavo_scheletro`), la
coppia Scavo 0,6 e Ritro 0,15 da' 30-37: la forbice piu' stretta misurata
nel torneo a sette, con tutte le strategie fra il 30 e il 37 e i PV fra
81,5 e 83,2. Scelta: in tabella.

## Cinquantanovesima misura: tutto il mazzo in vendita

Il designer: "cosa cambia se durante un'era tutti gli edifici sono
disponibili all'acquisto, senza pescarli di volta in volta?". Variante
`tutto_in_vendita`: il mercato mostra le 12 carte dell'era. Base la 57ª.

| a giocatore | base (6 in vetrina) | 12 in vetrina |
|---|---|---|
| PV a testa | 83,1 | 86,6 |
| Scavo / Cont / Rendita / Lampo / finali | 16,9 / 14,7 / 13,0 / 18,8 / 6,3 | 18,2 / 15,1 / 13,9 / 18,5 / 7,1 |
| spianamenti / riscoperte | 2,8 / 2,81 | 3,0 / 3,12 |
| era 5: costruiti / passati / morto | 2,59 / 1,04 / 2,2 | 2,64 / 0,99 / 2,1 |
| vittorie Bil / Cont / Lampo / Obi / Rend / Ritro / Scavo | 41 / 32 / 30 / 37 / 39 / 27 / 27 | 36 / 42 / 32 / 37 / 32 / 32 / 22 |

Con tutto scoperto si gioca meglio: +3,5 PV a testa, un po' piu' di
costruzioni sopra e di riscoperte, meno passi. Guadagnano chi pianifica
(Continuita' 42, Obiettivi 37) e perde chi reagisce a quel che esce (Scavo
22); la forbice si allarga a 22-42. Nel reale sono 12 carte sul tavolo
invece di 6 per ogni era. Non e' nel file base: decisione del designer; la
variante resta.

## Sessantesima misura: l'evento scoperto a fine era

Il designer: "la variante che l'evento viene scoperto a fine era e non
all'inizio". Variante `evento_coperto` (manopola `evento_a_fine_era`):
durante l'era si sa solo la forza, uguale per tutti gli eventi di
quell'era; l'evento vero si scopre quando colpisce; nessun effetto in-era.
Base la 57ª.

| | base | evento coperto |
|---|---|---|
| partite identiche alla base, su 300 | - | 273 |
| PV a testa, canali | 83,1 | 83,0, uguali al decimo |
| crolli per era a partita | 10,3 / 6,2 / 6,1 / 4,7 / 0,5 | 10,4 / 6,2 / 6,1 / 4,8 / 0,4 |
| spianamenti / sopra / riscoperte | 2,8 / 8,1 / 2,81 | 2,8 / 8,1 / 2,81 |
| vittorie Bil / Cont / Lampo / Obi / Rend / Ritro / Scavo | 41 / 32 / 30 / 37 / 39 / 27 / 27 | 43 / 31 / 32 / 37 / 37 / 27 / 26 |

Nel simulatore non cambia quasi nulla: il bot difende gli edifici guardando
la forza, che e' la stessa per tutti gli eventi dell'era, non il tipo. Si
perdono gli effetti in-era (Inverno lungo, Bonifiche, Anni della fame,
Eruzione). Per i giocatori umani e' una scelta di gusto, piu' tensione e
meno controllo, a costo zero sui numeri. Non e' nel file base: decisione
del designer; la variante resta.

## Sessantunesima misura: il soffio non vale per la resistenza 1

Il designer, dopo il seme 925 (registro 192): "misura il soffio solo per
resistenza 1, questi edifici a resistenza 1 nell'era preistorica non
dovrebbero sopravvivere all'era moderna". Manopola `soffio_resistenza_min`
2 (registro 193): chi ha resistenza stampata 1 e fallisce l'evento crolla,
anche di 1 solo. Stessi 300 semi, base la 58ª.

| a giocatore | base (soffio a tutti) | soffio da 2 in su |
|---|---|---|
| PV a testa | 82,4 | 82,3 |
| Scavo / Cont / Rendita / Lampo / finali | 16,6 / 14,5 / 12,6 / 18,8 / 6,2 | 17,4 / 14,4 / 12,3 / 18,7 / 6,0 |
| spianamenti / riscoperte | 3,7 / 2,78 | 3,2 / 2,89 |
| edifici dell'era 1 in piedi a fine partita (a partita) | 2,51 | 2,70 |
| di cui a resistenza 1 | 0,08 | 0 |
| era 1: costruiti / in rovina / sotterrati (a partita) | 12,9 / 10,4 / 9,1 | 12,9 / 10,2 / 9,1 |
| vittorie Bil / Cont / Lampo / Obi / Rend / Ritro / Scavo | 31 / 33 / 30 / 31 / 37 / 37 / 33 | 29 / 37 / 34 / 36 / **27** / 36 / 35 |

Quello che il designer chiedeva c'e': nessun edificio a resistenza 1 arriva
alla fine (erano gia' pochi, 0,08 a partita: il seme 925 era un caso raro).
Dei 5,2 edifici a resistenza 1 costruiti nell'era 1 a partita, prima ne
reggeva qualcuno all'Inverno lungo per un soffio e viveva finche' il
proprietario passava in colonna; adesso crollano tutti al primo evento che
li supera, a meno di una protezione. Le rovine arrivano prima, e lo Scavo
sale di 0,8 (piu' tessere coperte nelle colonne giuste). Il costo lo paga la
Rendita: dal 37 al 27, perche' le sue carte dell'era 1 che rendono (Capanne,
Cava, Focolare, Trappole, Approdo) hanno tutte resistenza 1 e non
sopravvivono piu' all'era 1 senza il lavoratore sopra. La forbice e' 27-37,
contro il 30-37 della 58ª. Decisione del designer gia' presa ("non dovrebbero
sopravvivere"): la regola e' nel file base; se la Rendita va risollevata, si
ritara il bot (`rendita_per_era`) in una misura a parte, non la regola.

## Sessantaduesima misura: gli eventi dell'era 5

Il designer: "vorrei gli eventi anche per la 5 era, non mi piace che ce ne
sia solo uno, bisogna allinearlo con le altre ere". Sei eventi di forza 4
(registro 196) al posto del solo Giudizio del tempo. Stessi 300 semi, base
la 61ª (soffio). Il bot e' quello di sempre, che per l'era 5 si aspetta
forza 6 e non protegge niente (registro 197).

| a giocatore | Giudizio del tempo | sei eventi |
|---|---|---|
| PV a testa | 82,3 | 79,6 |
| Scavo / Cont / Rendita / Lampo / finali | 17,4 / 14,4 / 12,3 / 18,7 / 6,0 | 17,6 / 14,4 / 12,1 / 18,7 / **3,4** |
| edifici dell'era 5 a partita: costruiti / in rovina | 7,8 / 0,45 | 7,8 / **3,6** |
| in rovina per era (2 / 3 / 4) | 6,0 / 5,8 / 4,7 | 6,6 / 6,5 / 5,4 |
| vittorie Bil / Cont / Lampo / Obi / Rend / Ritro / Scavo | 29 / 37 / 34 / 36 / 27 / 36 / 35 | 24 / 35 / 39 / 37 / 24 / 38 / 36 |

I sei escono in parti uguali (40-60 volte ciascuno su 300). Con i
modificatori quasi la meta' degli edifici dell'era 5 crolla (3,6 su 7,8,
contro 0,45 col Giudizio senza effetti): le carte dell'era 5 hanno quasi
tutte resistenza 3, e un -1 di classe o di terreno le porta sotto la forza
4. Il canale che paga e' quello dei finali (Museo, Universita', Grattacielo:
6,0 -> 3,4), perche' il finale si incassa solo in piedi; -2,8 PV a testa,
forbice 24-39. Ma la misura dice piu' del bot che della regola: il bot
dell'era 5 pensava a forza 6 e non ha mai messo un lavoratore a protezione
(con 6 in testa nessuna protezione basta), ne' guardato i modificatori. Un
giocatore vero legge la carta e protegge il Museo. Per questo la 63ª.

## Sessantatreesima misura: il bot legge la forza dell'evento

Registro 197: il bot sapeva la forza a memoria (`era + 1`, niente nell'era
5) e nella v3 sbagliava di 2 nelle ere 4 e 5. Ora legge la carta girata, i
dati per le ere a venire e i modificatori dell'evento. Stessi 300 semi; due
lotti, col solo Giudizio del tempo (variante `giudizio_solo`) e coi sei
eventi dell'era 5, da confrontare con la 61ª e la 62ª (bot a memoria).

| a giocatore | Giudizio, bot a memoria (61ª) | Giudizio, bot legge | sei eventi, bot a memoria (62ª) | sei eventi, bot legge |
|---|---|---|---|---|
| PV a testa | 82,3 | 83,3 | 79,6 | 80,6 |
| finali / Rendita / Scavo | 6,0 / 12,3 / 17,4 | 6,4 / 12,7 / 17,9 | 3,4 / 12,1 / 17,6 | 3,6 / 12,6 / 18,0 |
| era 5: costruiti / in rovina (a partita) | 7,8 / 0,45 | 7,4 / 0,39 | 7,8 / 3,6 | 7,6 / 3,6 |
| vittorie Bil / Cont / Lampo / Obi / Rend / Ritro / Scavo | 29 / 37 / 34 / 36 / 27 / 36 / 35 | 26 / 29 / 35 / 36 / 34 / 36 / 37 | 24 / 35 / 39 / 37 / 24 / 38 / 36 | 27 / 36 / 36 / 38 / 32 / 33 / 32 |

Il bot che legge vale un punto a testa e rimette in piedi la Rendita (dal
27 al 34 col Giudizio: nell'era 4 non spreca piu' protezioni contro una
forza 5 che non c'e', e nell'era 5 protegge quello che rende). Coi sei
eventi la forbice torna a 27-38 e la Rendita al 32, ma il conto dell'era 5
non cambia: 3,6 edifici su 7,6 in rovina, i finali dimezzati, -2,7 PV a
testa rispetto al Giudizio. Non e' il bot: le carte dell'era 5 hanno quasi
tutte resistenza 3, contro la forza 4 vivono solo per il soffio, e qualunque
-1 di classe o di terreno le fa crollare. Con sei eventi che portano tutti
almeno un -1 a qualcuno, meta' dell'era Moderna cade; protezioni per
tutte non ce ne sono (tre Personaggi, quattro turni, e l'ultimo edificio
costruito non si protegge piu'). L'era 4 aveva lo stesso problema a forza
5 ed e' stata portata a 3 (misura 127). Variante `eventi5_forza3`: i sei
eventi a forza 3, misura sotto.

## Sessantaquattresima misura: i sei eventi dell'era 5 a forza 3

Registro 198. Stessi 300 semi, bot che legge (63ª); base il Giudizio del
tempo col bot che legge.

| a giocatore | Giudizio (F4, senza effetti) | sei eventi F4 | sei eventi F3 |
|---|---|---|---|
| PV a testa | 83,3 | 80,6 | 83,6 |
| finali / Rendita / Scavo / Cont | 6,4 / 12,7 / 17,9 / 14,4 | 3,6 / 12,6 / 18,0 / 14,5 | 6,1 / 12,7 / 18,0 / 14,6 |
| era 5: costruiti / in rovina (a partita) | 7,4 / 0,39 | 7,6 / 3,6 | 7,8 / 1,1 |
| era 4 in rovina a fine partita | 4,4 | 5,3 | 3,6 |
| vittorie Bil / Cont / Lampo / Obi / Rend / Ritro / Scavo | 26 / 29 / 35 / 36 / 34 / 36 / 37 | 27 / 36 / 36 / 38 / 32 / 33 / 32 | 31 / 31 / 34 / 40 / 30 / 31 / 36 |

A forza 3 gli eventi dell'era Moderna mordono senza falciare: un edificio
dell'era 5 su sette va in rovina (1,1 su 7,8, contro 0,4 col Giudizio e 3,6
a forza 4), chi prende un -2 o un -1 senza protezione crolla e gli altri
reggono; i finali tornano a 6,1 e i PV a 83,6. Le carte dell'era 4 in
rovina scendono da 4,4 a 3,6, perche' la forza 3 e' quella che hanno gia'
passato. Forbice 30-40 (Obiettivi 40, Rendita 30). Scelta: forza 3 nel
file base, come l'era 4; `--variante eventi5_forza4` per la forza del
Giudizio.

## Sessantacinquesima misura: o dentro o fuori

Il designer: "che senso ha fallire di un soffio, abbassa la resistenza di 1
oppure aumenta il danno. O sei dentro o sei fuori" (registro 199). Due
varianti pulite, `rovina_gap` 1 in tutte e due: `senza_soffio` con le forze
di prima (2, 3, 4, 3, 3) e `senza_soffio_forze` con tutte le forze scese di
1 (1, 2, 3, 2, 2). Stessi 300 semi, base la 64ª (soffio tranne la
resistenza 1, eventi dell'era 5 a forza 3, bot che legge).

| a giocatore | base (soffio) | senza soffio, forze di prima | senza soffio, forze -1 |
|---|---|---|---|
| PV a testa | 83,6 | **90,9** | 84,1 |
| Scavo / Rendita / finali / cultura | 18,0 / 12,7 / 6,1 / 9,0 | **29,2** / 11,5 / 4,1 / 7,8 | 16,4 / 13,3 / 6,5 / 9,6 |
| in rovina per era a fine partita (1-5) | 9,9 / 6,1 / 5,8 / 3,6 / 1,1 | 9,7 / 7,1 / 7,9 / 6,0 / 3,4 | 9,6 / 6,0 / 6,0 / 3,3 / 0,9 |
| spianamenti / sopra / riscoperte | 3,2 / 8,0 / 3,0 | 1,7 / 8,7 / 5,3 | 3,9 / 8,0 / 2,8 |
| resistenza 1 in piedi a fine partita (a partita) | 0,01 | 0,04 | **0,25** |
| vittorie Bil / Cont / Lampo / Obi / Rend / Ritro / Scavo | 31 / 31 / 34 / 40 / 30 / 31 / 36 | 34 / 31 / 33 / 37 / 25 / 33 / 41 | 38 / 25 / 34 / 30 / 39 / 33 / 35 |

Togliere il soffio e basta e' alzare il danno di 1 a tutti: le rovine
arrivano a fiumi (era 4: 6,0 in rovina, era 5: 3,4), nessuno spiana piu'
(1,7) perche' le rovine le fa l'evento, le riscoperte raddoppiano e lo Scavo
va a 29 PV su 91: il gioco cambia natura e la Rendita scende al 25. Abbassare
anche le forze di 1 rimette i numeri al loro posto (84,1 PV, canali come
prima) ma riapre la porta che il registro 193 aveva chiuso: a forza 1
l'era 1 la passano tutti, e un edificio a resistenza 1 su quattro partite
arriva alla fine (0,25 contro 0,01); la Rendita risale al 39 per lo stesso
motivo. Scelta di chi misura ("scegli tu"): niente soffio e forze 2, 2, 3,
2, 2, cioe' -1 solo dove il soffio attutiva. L'era 1 resta a 2 perche' la
resistenza 1 non deve passarla; le ere 2-5 scendono perche' li' chi reggeva
per un soffio deve continuare a reggere. E' il conto di oggi scritto senza
eccezioni: una regola sola, resistenza sotto la forza = crolla. Le manopole
`rovina_gap` e `soffio_resistenza_min` non servono piu' nel file base;
`--variante soffio` rifa' il conto di prima. La misura di conferma e' la
66ª.

## Sessantaseiesima misura: la conferma della base pulita

Il file base del registro 199: `rovina_gap` 1, forze 2, 2, 3, 2, 2. Stessi
300 semi, base la 64ª (soffio tranne la resistenza 1, forze 2, 3, 4, 3, 3).

| a giocatore | 64ª (soffio) | 66ª (o dentro o fuori) |
|---|---|---|
| PV a testa | 83,6 | 83,3 |
| Scavo / Cont / Rendita / Lampo / finali | 18,0 / 14,6 / 12,7 / 18,8 / 6,1 | 17,0 / 14,7 / 12,4 / 19,1 / 6,3 |
| in rovina per era a fine partita (1-5) | 9,9 / 6,1 / 5,8 / 3,6 / 1,1 | 9,8 / 5,6 / 5,9 / 3,2 / 1,0 |
| spianamenti / sopra / riscoperte | 3,2 / 8,0 / 3,0 | 3,3 / 7,9 / 2,8 |
| resistenza 1 in piedi a fine partita (a partita) | 0,01 | 0,08 |
| vittorie Bil / Cont / Lampo / Obi / Rend / Ritro / Scavo | 31 / 31 / 34 / 40 / 30 / 31 / 36 | 33 / 41 / 31 / 39 / 25 / 36 / 29 |

Il conto e' lo stesso: punti, canali, rovine per era e spianamenti al
decimo. Gli 0,08 edifici a resistenza 1 in piedi alla fine sono quelli con
l'Argine (1 + 1 = 2 passa la forza 2): la regola nuova guarda la resistenza
effettiva come tutto il resto, e l'Argine torna a valere anche su di loro;
e' il valore che la 58ª aveva prima del registro 193. Quel che si muove sono
le vittorie, 25-41 contro 30-40: la Continuita' sale al 41 e la Rendita
scende al 25 senza che il motore abbia cambiato chi crolla. E' il bot, che
ora legge forze esatte (197) dove prima ignorava il soffio e credeva morti
edifici che vivevano: pianifica meglio le colonne lunghe e protegge con
piu' giudizio. La ritaratura delle spinte (`rendita_per_era`,
`continuita_peso`) e' la prossima misura, non questa regola.

## Sessantasettesima misura: il tempo logora, primo giro

Registro 200, varianti `erosione` (logorio 2/1/0) ed `erosione_lieve`
(1/0/0): scala 1-10, modificatori raddoppiati, eventi lievi 3-7 per era e
gravi due punti sopra. Stessi 300 semi, base la 66ª.

| a giocatore | base (66ª) | erosione 2/1/0 | erosione 1/0/0 |
|---|---|---|---|
| PV a testa | 83,3 | **91,1** | 91,0 |
| Scavo / finali / Rendita / cultura | 17,0 / 6,3 / 12,4 / 9,3 | **34,0** / 1,7 / 9,9 / 7,5 | 33,5 / 1,8 / 10,4 / 7,4 |
| in rovina per era a fine partita (1-5) | 9,8 / 5,6 / 5,9 / 3,2 / 1,0 | 10,2 / 8,6 / 8,1 / 7,4 / **6,4** | 9,9 / 8,2 / 8,1 / 7,5 / 6,3 |
| spianamenti / sopra / riscoperte | 3,3 / 7,9 / 2,8 | 1,0 / 8,9 / 6,3 | 1,1 / 8,9 / 6,2 |
| era 1 in piedi alla fine, di cui megaliti | 3,13 / - | 2,74 / 2,67 | 2,97 / 2,83 |
| resistenza logorata in tutto, a giocatore | - | 7,1 | 2,8 |
| vittorie Bil / Cont / Lampo / Obi / Rend / Ritro / Scavo | 33 / 41 / 31 / 39 / 25 / 36 / 29 | 33 / 28 / 21 / 37 / 36 / 34 / 45 | 28 / 28 / 25 / 38 / 33 / 32 / 48 |

La parte che il designer chiedeva c'e': della preistoria arrivano alla fine
quasi solo i megaliti (2,67 su 2,74), le capanne spariscono, e il logorio
si vede (7 punti di resistenza persi a giocatore). Ma il resto e' un fiume
di rovine: l'era Moderna crolla per tre quarti (6,4 su 8,2), i finali
scendono a 1,7, nessuno spiana piu' (1,0: le rovine le fa l'evento), le
riscoperte raddoppiano e lo Scavo vale 34 punti su 91, la Scavo vince il
45-48 e la Lampo il 21. La differenza fra 2/1/0 e 1/0/0 e' piccola: non e'
il logorio che falcia, sono le forze. Con la scala 1-10 le carte dell'era 5
stanno a 6-7 (il Grattacielo a 10) e l'evento lieve dell'era 5 a 7, il grave
a 9: muore tutto, cemento armato compreso. La curva 3-7 era troppo ripida
per una scala in cui la pietra sta a 5-7. Secondo giro: `erosione_calma`,
logorio 2/1/0 e forze lievi 3, 3, 4, 4, 5 con gravi due punti sopra (68ª).

## Come rifare il conto

```bash
# misure 58-60: `--spinta scavo_scheletro=0.6,ritro_scheletro=0.15` (e le altre coppie), `--dati
#   data/proposte/cards-v3-era1-tutto_in_vendita.json`, `--dati data/proposte/cards-v3-era1-evento_coperto.json`
# cinquantasettesima misura: gli scheletri sono i Personaggi (registro 188), stesso comando della
#   quarantanovesima con `--dati data/proposte/cards-v3-era1-scheletri_personaggi.json`
# cinquantaseiesima misura: la Ritrovamenti (registro 187); stesso comando della quarantanovesima con
#   `--spinta ritro_...`; il tetto ai finali e' nel file base rigenerato, `--variante finali_senza_tetto` lo toglie
# cinquantacinquesima misura: la tabella senza coperture (registro 185), stesso comando della quarantanovesima;
#   la base e' il lotto della 54ª con `--spinta lampo=0.8`, ora uguale alla tabella (registro 186)
# cinquantaquattresima misura: tutto insieme (registri 181-184), stesso comando della quarantanovesima,
#   e lo stesso con `--spinta lampo=0.8`; la tabella per giocatori copriva ancora SPINTE_V3 (registro 185)
# cinquantaduesima e cinquantatreesima misura: tarature Lampo (`--spinta lampo=0.5`, `lampo=1.1`,
#   `lampo_potenzia=0.5`) e il bot coi finali (registro 181), stesso comando della quarantanovesima
# cinquantunesima misura: lo spianamento parziale (registro 180); stesso comando della quarantanovesima col
#   file base rigenerato (`python3 tools/genera_cards_v3.py`); `--variante spianato_intero` rifa' la regola di prima
# cinquantesima misura: il Grattacielo a tre binari, livello 1, qualunque terreno (registro 179);
#   stesso comando della quarantanovesima col file base rigenerato (`python3 tools/genera_cards_v3.py`)
# quarantanovesima misura: il file base col bot corretto (registro 177), stesso comando della quarantottesima
# quarantottesima misura: la Ritrovamenti (registro 173) e le carte grandi (174); il canone v3 ha sette
#   strategie, `--variante grandi_vecchie` rifa' le carte della v2
godot --headless res://scenes/audit_partita.tscn -- --players 3 --games 300 --seed 700000 --giro tutte \
  --dati data/proposte/cards-v3-era1.json --rapporto 1 > z.csv 2> z.err
# quarantasettesima misura: Rendita e Scavo nel bot (registro 172); la tabella SPINTE_V3 ha ora
#   rendita_per_era 1,3, scavo_premio 0,8, scavo_terra_scavo 0,5; questo rifa' la base della quarantaseiesima
godot --headless res://scenes/audit_partita.tscn -- --players 3 --games 300 --seed 700000 --giro tutte \
  --dati data/proposte/cards-v3-era1.json --rapporto 1 --spinta rendita_per_era=0.9,scavo_premio=0.4,scavo_terra_scavo=0.25 > x.csv 2> x.err
# quarantaseiesima misura: sconti senza condizione e ⊕ con lo sconto (registro 171); il file base e'
#   quello nuovo, `--variante senza_sconti` rifa' la quarantaquattresima
python3 tools/genera_cards_v3.py && python3 tools/genera_cards_v3.py --variante senza_sconti
godot --headless res://scenes/audit_partita.tscn -- --players 3 --games 300 --seed 700000 --giro tutte \
  --dati data/proposte/cards-v3-era1.json --rapporto 1 > w.csv 2> w.err
# quarantaquattresima misura: la "scelta" stile Caylus (registro 170), tre controprove sul file base
for v in scelta scelta_pv scelta_sconti; do python3 tools/genera_cards_v3.py --variante $v; done
godot --headless res://scenes/audit_partita.tscn -- --players 3 --games 300 --seed 700000 --giro tutte \
  --dati data/proposte/cards-v3-era1-scelta.json --rapporto 1 > u.csv 2> u.err      # e scelta_pv, scelta_sconti
for e in 1 2 3 4 5; do python3 tools/misura_era.py u.err --era $e; done
# quarantatreesima misura: gli sconti sugli edifici (registro 169), controprova sul file base
python3 tools/genera_cards_v3.py --variante sconti_edifici
godot --headless res://scenes/audit_partita.tscn -- --players 3 --games 300 --seed 700000 --giro tutte \
  --dati data/proposte/cards-v3-era1-sconti_edifici.json --rapporto 1 > s.csv 2> s.err
# quarantaduesima misura: le spinte della Lampo (registro 168); la tabella SPINTE_V3 ha ora lampo_zero=0,
#   `--spinta lampo_zero=-1` rifa' la base della quarantunesima
godot --headless res://scenes/audit_partita.tscn -- --players 3 --games 300 --seed 700000 --giro tutte \
  --dati data/proposte/cards-v3-era1.json --rapporto 1 --spinta lampo_zero=-1 > r.csv 2> r.err
# quarantunesima misura: il Lampo pari al costo e Fondaco/Periferia in Costruzione (registro 167);
#   il file base e' quello nuovo, `--variante lampo_vecchio` rifa' quello della quarantesima
python3 tools/genera_cards_v3.py && python3 tools/genera_cards_v3.py --variante lampo_vecchio
godot --headless res://scenes/audit_partita.tscn -- --players 3 --games 300 --seed 700000 --giro tutte \
  --dati data/proposte/cards-v3-era1.json --rapporto 1 > q.csv 2> q.err
for e in 3 4 5; do python3 tools/misura_era.py q.err --era $e; done
# quarantesima misura: le carte grandi a terra e le azioni degli edifici solo quando attivi tu
#   (registro 166); il file base e' quello nuovo, `--variante chiunque` rifa' la regola di prima
python3 tools/genera_cards_v3.py && python3 tools/genera_cards_v3.py --variante chiunque
godot --headless res://scenes/audit_partita.tscn -- --players 3 --games 300 --seed 700000 --giro tutte \
  --dati data/proposte/cards-v3-era1.json --rapporto 1 > p.csv 2> p.err
godot --headless res://scenes/audit_partita.tscn -- --players 3 --games 300 --seed 700000 --giro tutte \
  --dati data/proposte/cards-v3-era1-chiunque.json --rapporto 1 > pc.csv 2> pc.err
for e in 1 2 3 4 5; do python3 tools/misura_era.py p.err --era $e; python3 tools/misura_era.py pc.err --era $e; done
# trentanovesima misura: costi delle ere 3-4 e la Lampo nel bot (registro 165); le tarature con
#   --spinta lampo=1.0   e   --spinta lampo=0.8,lampo_potenzia=1.5   sullo stesso comando
# trentottesima misura: il tuning delle ere 3-5 (registro 164), stesso comando della trentasettesima
# trentasettesima misura: la partita intera (registro 163)
godot --headless res://scenes/audit_partita.tscn -- --players 3 --games 300 --seed 700000 --giro tutte \
  --dati data/proposte/cards-v3-era1.json --rapporto 1 > intera.csv 2> intera.err
for e in 1 2 3 4 5; do python3 tools/misura_era.py intera.err --era $e; done
# trentaseiesima misura: la coppia di ere 1-2 (registro 162)
godot --headless res://scenes/audit_partita.tscn -- --players 3 --games 300 --seed 700000 --giro tutte \
  --dati data/proposte/cards-v3-era1.json --rapporto 1 --fino_era 2 > e12.csv 2> e12.err
python3 tools/misura_era.py e12.err --era 1; python3 tools/misura_era.py e12.err --era 2
# trentacinquesima misura: il file base con i costi rimodulati (registro 161); i giri 1 e 2 sono
# i commit intermedi del ramo claude/v3-era-1 (costi in COSTI_E1 del generatore)
# trentaquattresima misura: il file base con il potenziamento insieme alla costruzione; variante terreno_produce
# trentatreesima misura: il file base con il tuning delle risorse (registro 159); controprova case_seconda
# (stessi comandi della trentaduesima; il file base di allora lo rigenera il generatore al commit b764ad7)
# trentaduesima misura: il file base con catena, costi misti ed extra dalle carte; tre controprove
python3 tools/genera_cards_v2.py && python3 tools/genera_cards_v3.py
for v in extra_sempre senza_extra costi_vecchi; do python3 tools/genera_cards_v3.py --variante $v; done
godot --headless res://scenes/audit_partita.tscn -- --players 3 --games 300 --seed 700000 --giro tutte \
  --dati data/proposte/cards-v3-era1.json --rapporto 1 --fino_era 1 > b.csv 2> b.err
python3 tools/misura_era.py b.err
# trentunesima misura, le leve del pozzo: una variante per file (le varianti del primo giro
# le rigenera il generatore al commit 2db6223; il file base di allora non aveva la catena)
for v in costi terreno acquisto acquisto_caro pacchetto pacchetto_caro catena costi_misti catena_misti; do
  python3 tools/genera_cards_v3.py --variante $v
  godot --headless res://scenes/audit_partita.tscn -- --players 3 --games 300 --seed 700000 --giro tutte \
    --dati data/proposte/cards-v3-era1-$v.json --rapporto 1 --fino_era 1 > e1_$v.csv 2> e1_$v.err
  python3 tools/misura_era.py e1_$v.err > e1_$v.txt
done
# trentunesima misura: l'era 1 della v3 da sola, e la controprova con i potenziamenti adiacenti
python3 tools/genera_cards_v2.py && python3 tools/genera_cards_v3.py
godot --headless res://scenes/audit_partita.tscn -- --players 3 --games 300 --seed 700000 --giro tutte \
  --dati data/proposte/cards-v3-era1.json --rapporto 1 --fino_era 1 > e1.csv 2> e1.err
godot --headless res://scenes/audit_partita.tscn -- --players 3 --games 300 --seed 700000 --giro tutte \
  --dati data/proposte/cards-v3-era1.json --rapporto 1 --fino_era 1 --potenzia_adiacente 1 > e1pa.csv 2> e1pa.err
python3 tools/misura_era.py e1.err; python3 tools/misura_era.py e1pa.err
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
# quinta misura: quattro lavoratori e il draft stanno nel file v2 (oggi il comando di S produce U4);
# `--lavoratori 3` e' il controllo U3, `--turno_v2 1` rigioca il turno a un'azione
godot --headless res://scenes/audit_partita.tscn -- --players 3 --games 750 --seed 700000 --dati data/cards-v2.json > U4.csv
python3 tools/confronta_torneo.py S.csv U4.csv
# sesta misura: le tre decisioni stanno nel file v2 (oggi il comando di U4 produce W);
# `--sepolti 1` riseppellisce i Personaggi, `--vetusta 3` rimette la Vetusta'
godot --headless res://scenes/audit_partita.tscn -- --players 3 --games 750 --seed 700000 --dati data/cards-v2.json > W.csv
python3 tools/confronta_torneo.py U4.csv W.csv
# settima misura: la protezione a +1 e lo scheletro che conta sempre, manopole sulla base W
godot --headless res://scenes/audit_partita.tscn -- --players 3 --games 750 --seed 700000 --dati data/cards-v2.json --protezione 1 --scheletro sempre > X2.csv
python3 tools/confronta_torneo.py W.csv X2.csv
# ottava misura: lo scheletro che conta sempre sta nel file v2; `--rendita_tetto 2` taglia le carte care
godot --headless res://scenes/audit_partita.tscn -- --players 3 --games 750 --seed 700000 --dati data/cards-v2.json --rendita_tetto 2 > Y2.csv
python3 tools/confronta_torneo.py Z.csv Y2.csv
# nona misura: la tabella delle spinte v2 sta nel bot; `--spinta chiave=valore,...` la sovrascrive
godot --headless res://scenes/audit_partita.tscn -- --players 3 --games 750 --seed 700000 --dati data/cards-v2.json > F.csv
python3 tools/confronta_strategie.py F.csv
# decima misura: le tessere una volta per era e il Lampo stanno nel file v2; `--tessere 0` rimette le regole permanenti
godot --headless res://scenes/audit_partita.tscn -- --players 3 --games 750 --seed 700000 --dati data/cards-v2.json --tessere 0 > Ga.csv
python3 tools/confronta_torneo.py F.csv Ga.csv Gb.csv
# undicesima misura: la spinta della Lampo sta nella tabella v2; `--spinta lampo_potenzia=0` la spegne
godot --headless res://scenes/audit_partita.tscn -- --players 3 --games 750 --seed 700000 --dati data/cards-v2.json > H.csv
python3 tools/confronta_strategie.py H.csv
# dodicesima misura: la v2 e la v1.5 a 2 e a 4 giocatori, stessi semi; `--lavoratori 3` e' la controprova a quattro
for p in 2 4; do godot --headless res://scenes/audit_partita.tscn -- --players $p --games 750 --seed 700000 --dati data/cards-v2.json > v2_p$p.csv; done
python3 tools/confronta_torneo.py v2_p2.csv H.csv v2_p4.csv
python3 tools/confronta_strategie.py v2_p4.csv
# tredicesima misura: l'incasso al passaggio, il secondo Monumento a due, le sagome in piu' a quattro
godot --headless res://scenes/audit_partita.tscn -- --players 4 --games 750 --seed 700000 --dati data/cards-v2.json --passa_incasso 1 > inc_p4.csv
godot --headless res://scenes/audit_partita.tscn -- --players 2 --games 750 --seed 700000 --dati data/cards-v2.json --monumenti 2 > mon2_p2.csv
python3 tools/genera_cards_v2.py --variante doppioni; python3 tools/genera_cards_v2.py --variante abitazioni
for v in doppioni abitazioni; do godot --headless res://scenes/audit_partita.tscn -- --players 4 --games 750 --seed 700000 --dati data/proposte/cards-v2-$v.json > ${v}_p4.csv; done
python3 tools/confronta_torneo.py v2_p4.csv doppioni_p4.csv abitazioni_p4.csv
python3 tools/genera_cards_v2.py --variante case; python3 tools/genera_cards_v2.py --variante case_doppioni
for v in case case_doppioni; do godot --headless res://scenes/audit_partita.tscn -- --players 4 --games 750 --seed 700000 --dati data/proposte/cards-v2-$v.json > ${v}_p4.csv; done
python3 tools/confronta_torneo.py v2_p4.csv doppioni_p4.csv case_p4.csv case_doppioni_p4.csv
for v in case_scavo case_nulle case_mista; do python3 tools/genera_cards_v2.py --variante $v; godot --headless res://scenes/audit_partita.tscn -- --players 4 --games 750 --seed 700000 --dati data/proposte/cards-v2-$v.json > ${v}_p4.csv; done
godot --headless res://scenes/audit_partita.tscn -- --players 4 --games 750 --seed 700000 --dati data/proposte/cards-v2-case.json --spinta lampo=2.5 > case_L25.csv
python3 tools/confronta_torneo.py case_p4.csv case_scavo_p4.csv case_nulle_p4.csv case_L25.csv
# quattordicesima misura: il giro su tutte le combinazioni; la taratura sta nelle tabelle del bot
for p in 2 3 4; do godot --headless res://scenes/audit_partita.tscn -- --players $p --games 750 --seed 700000 --dati data/cards-v2.json --giro tutte > tutte_p$p.csv; done
python3 tools/confronta_strategie.py tutte_p4.csv
# quindicesima misura: le case per tutti (tre tipi per era, per ogni tavolo); `--mercato 8` allarga il mercato
python3 tools/genera_cards_v2.py --variante case_tutti
for p in 2 3 4; do godot --headless res://scenes/audit_partita.tscn -- --players $p --games 750 --seed 700000 --dati data/proposte/cards-v2-case_tutti.json --giro tutte > case_p$p.csv; done
python3 tools/confronta_torneo.py tutte_p4.csv case_p4.csv
# sedicesima misura: le case in riserva stanno nel file v2 (oggi il comando di tutte_p$p produce riserva_p$p)
for p in 2 3 4; do godot --headless res://scenes/audit_partita.tscn -- --players $p --games 750 --seed 700000 --dati data/cards-v2.json --giro tutte > riserva_p$p.csv; done
python3 tools/confronta_torneo.py tutte_p4.csv case_p4.csv riserva_p4.csv
godot --headless res://scenes/audit_partita.tscn -- --players 3 --vita 2000 --seed 200000 --dati data/cards-v2.json > vita_riserva.csv
# diciassettesima misura: le case ritoccate stanno nel file v2 (oggi gli stessi comandi producono ritocco_p$p e vita_ritocco)
# diciottesima misura: la griglia delle spinte con le case; la taratura scelta sta nelle tabelle del bot
godot --headless res://scenes/audit_partita.tscn -- --players 3 --games 750 --seed 700000 --dati data/cards-v2.json --giro tutte --spinta lampo=2.0 > p3_L20.csv
godot --headless res://scenes/audit_partita.tscn -- --players 4 --games 750 --seed 700000 --dati data/cards-v2.json --giro tutte --spinta rendita_per_era=1.5,scavo_premio=0.2,scavo_terra_scavo=0.1 > p4_R15S.csv
python3 tools/confronta_torneo.py ritocco_p4.csv p4_R15S.csv
# diciannovesima misura: le tessere dell'era stanno nel file v2; `--tessere_era 0` rigioca il file di prima
for p in 2 3 4; do godot --headless res://scenes/audit_partita.tscn -- --players $p --games 750 --seed 700000 --dati data/cards-v2.json --giro tutte > tessere_p$p.csv; done
grep "^# tessere_scattate" tessere_p3.csv     # quante volte scatta ogni tessera nel lotto
# venticinquesima misura: i potenziamenti di classe stanno nel file v2; `--da N` riprende un lotto interrotto dalla partita N
for p in 2 3; do godot --headless res://scenes/audit_partita.tscn -- --players $p --games 750 --seed 700000 --dati data/cards-v2.json --giro tutte --rapporto 1 > classe_p$p.csv 2> classe_p$p.err; done
python3 tools/confronta_torneo.py tutte_p2.csv classe_p2.csv
# ventiseiesima misura: le tessere scavo, proposta
python3 tools/genera_cards_v2.py --variante tessere_scavo
for p in 2 3; do godot --headless res://scenes/audit_partita.tscn -- --players $p --games 750 --seed 700000 --dati data/proposte/cards-v2-tessere_scavo.json --giro tutte --rapporto 1 > scavo_p$p.csv 2> scavo_p$p.err; done
python3 tools/confronta_torneo.py classe_p3.csv scavo_p3.csv
# ventisettesima misura: le rovine a tessere e i flussi stanno nel file v2, i pesi dei bot nella tabella per tavolo
for p in 2 3; do godot --headless res://scenes/audit_partita.tscn -- --players $p --games 750 --seed 700000 --dati data/cards-v2.json --giro tutte --rapporto 1 > rovine_p$p.csv 2> rovine_p$p.err; done
python3 tools/rapporto_partite.py rovine_p2.err rovine_p3.err > rapporto.json
# ventottesima misura: il Denaro che avanza a fine era, con e senza la Prosperita'
for p in 2 3 4; do godot --headless res://scenes/audit_partita.tscn -- --players $p --games 150 --seed 700000 --dati data/cards-v2.json --giro tutte --rapporto 1 --prosperita 99 > senza_p$p.csv 2> senza_p$p.err; done
# ventinovesima misura: Lampo 2 sulle carte dell'era 4 (variante non adottata, non piu' nel generatore)
for p in 3 4; do godot --headless res://scenes/audit_partita.tscn -- --players $p --games 300 --seed 700000 --dati data/cards-v2.json --giro tutte --rapporto 1 > base_p$p.csv 2> base_p$p.err; done
# trentesima misura: regole semplici, tessere doppie, spianare caro, strada corta (evento finale e gilde nel file v2)
for v in tessere_doppie spianare_caro strada_corta caro_e_corta; do python3 tools/genera_cards_v2.py --variante $v; done
godot --headless res://scenes/audit_partita.tscn -- --players 3 --games 200 --seed 700000 --dati data/cards-v2.json --giro tutte --rapporto 1 > semplici_p3.csv 2> semplici_p3.err
for v in tessere_doppie spianare_caro strada_corta caro_e_corta; do godot --headless res://scenes/audit_partita.tscn -- --players 3 --games 200 --seed 700000 --dati data/proposte/cards-v2-$v.json --giro tutte --rapporto 1 > ${v}_p3.csv 2> ${v}_p3.err; done
```
