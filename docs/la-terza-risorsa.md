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
```
