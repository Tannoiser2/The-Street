# La v3: il metro

Una pagina sola, da tenere accanto quando si scrive una carta della v3. Dice quanto
vale ogni cosa in punti vittoria (PV), così costi, produzione, Lampo, Rendita e Scavo
di ogni carta si scrivono per aritmetica e si correggono quando la misura dice altro.
Lo scopo, parole del designer (1 ottobre 2026): "più strategie da perseguire che siano
equilibrate fra di loro e che nessuna sia palesemente dominante": punti rapidi (Lampo),
punti lenti (Rendita), punti finali (Scavo), ritrovamenti (scheletri e arte),
combinazioni di generi (uguali o diversi).

Stato: **proposta**, da leggere e correggere. I numeri "oggi" vengono dalla v2 di main
(3 giocatori, 90 partite, seme 700000, `--giro tutte --rapporto 1`); gli altri sono
valori di partenza da misurare con l'era di prova (`docs/proposte/v3-era-1.md`).

## Il ritmo di un'era

Tutto quello che non cambia da un'era all'altra, e su cui il resto si appoggia.

| | |
|---|---|
| Personaggi dell'era | 16, mescolati; 4 a testa nel draft a passaggio, i restanti fuori senza guardarli |
| lavoratori a testa | 4, i Personaggi presi (la quarta carta arriva da sola ed è un lavoratore come le altre) |
| attivazioni per era | 4 a testa: 8 / 12 / 16 a 2 / 3 / 4 giocatori |
| azioni per era | al massimo 4 a testa (una per attivazione, facoltativa) |
| colonne | 5 / 7 / 9 |
| edifici dell'era | 12 nel mazzo, mercato a 6, più 3 case in riserva in 2 copie |
| potenziamenti dell'era | 10 |
| tessere dell'era | 7 tipi in 2 copie, una per colonna |
| risorse | nascono a 0 a inizio era e **muoiono a fine era**; nessun tetto dentro l'era |
| Dinastia | non c'è (per la prova; da ripensare dopo) |

Una colonna viene attivata in media 1,7 volte per era a 3 giocatori (12 attivazioni su 7
colonne): la produzione e l'azione di un edificio scattano circa due volte per era.

## Il cambio: quanto vale una cosa in PV

| cosa | vale | perché |
|---|---|---|
| 1 Costruzione | 1 PV | un edificio a una casella rende in Lampo il suo costo in Costruzione (Capanne 1 → Lampo 1, Case di pietra 2 → Lampo 2) |
| 1 Denaro | 1 PV | compra un potenziamento "altro" (1 Denaro) o un'azione speciale |
| 1 Idea | 1 PV | compra un potenziamento Arte: 1 Idea → 1 PV subito nell'era 1, 2 nell'era 2 |
| 1 azione (un piazzamento) | 2 PV | è il bene scarso: 4 per era, e una costruzione ne consuma una |
| 1 Rendita nell'era *e* | ere in piedi × 1 PV | paga a ogni censimento finché l'edificio sta in piedi: al massimo 6 − *e*; oggi un edificio dell'era 1 resta in piedi in media **2,2 ere** (il 96 % crolla prima della fine, quasi tutto all'evento dell'era 3, forza 4) |
| 1 Scavo | P(rovina) × P(riscoperta) PV | paga solo se l'edificio crolla **e** viene riscoperto (regole semplici, registro 151): oggi sulle carte dell'era 1 P(rovina) è 0,96 e l'81 % delle rovine finisce sotto un altro edificio, ma la riscoperta che paga lo Scavo stampato è solo quella dell'era 5, circa 5 rovine a partita |
| 1 Lampo | 1 PV | subito |
| 1 edificio di un genere | 1 → 1 → 1,5 PV | la collezione 3/5/7/9 = 3/5/8/12 PV: i primi edifici valgono 1 ciascuno, oltre i 7 valgono 2 |

Regole di scrittura che discendono dal cambio:
- Una carta che costa *c* risorse e consuma un'azione deve rendere, in valore atteso,
  **c + 2 PV** sull'intera partita. Non di più, altrimenti è dominante; non di meno,
  altrimenti nessuno la gioca (oggi quattro carte su 74 non si costruiscono mai).
- Il Lampo paga tutto subito e deve rendere **c** (non c + 2): il resto lo paga la
  produzione o l'azione dell'edificio, che scattano due volte per era finché sta in piedi.
- La Rendita nell'era 1 vale fino a 4 censimenti: Rendita 2 su un edificio che resiste è
  8 PV per 2-3 risorse; con la vita media di oggi (2,2 ere) sono 4,4 PV, e chi gioca
  Rendita li porta a 6-8 proteggendo e potenziando. È la carta che ha tenuto Rendita sul
  bordo alto in tutte le misure della v2. Nella v3 due strade da misurare una contro
  l'altra: **Rendita 1** sugli edifici dell'era 1 e 2 e Rendita 2 solo dall'era 3; oppure
  Rendita 2 lasciata com'è, su edifici con resistenza bassa che l'evento porta via.
- Lo Scavo paga solo se si crolla e si viene riscoperti. Per farne una strategia vera e non
  una consolazione servono due cose: edifici con Scavo alto **e** resistenza bassa
  (Grotte dipinte: res 2, Scavo 6, costo 1 Idea), e la riscoperta deve valere: le
  tessere scavo girate nell'era 5 (regola semplice) più gli scheletri dei Personaggi.

## Il budget di un'era

Quanto produce un giocatore in un'era e come lo spende. Oggi (v2, 3 giocatori):

| era | Costruzione | Denaro | Idee | totale | restano a fine era |
|---|---|---|---|---|---|
| 1 | 5,6 | 2,0 | 1,7 | 9,3 | 6,5 |
| 2 | 8,1 | 2,6 | 2,7 | 13,4 | 11,4 |
| 3 | 4,2 | 3,5 | 2,7 | 10,4 | 9,1 |
| 4 | 2,9 | 5,3 | 4,5 | 12,7 | 10,8 |
| 5 | 2,5 | 6,7 | 4,4 | 13,6 | 12,5 |

"Restano" è quel che si ha in mano quando l'era chiude, prima della dispersione: nella v2
si porta avanti fino al tetto (3 per risorsa, 5 in tutto) e il resto si butta, circa 12
risorse a testa in una partita; nella v3 è tutto quel che **muore**. Senza un pozzo, nella
v3 morirebbe più di quanto si spende: è il problema da cui nasce questo metro.

Il budget che propongo per l'era 1 della v3, a giocatore:
- **produzione 10-12 risorse**: 4 dai Personaggi (uno ciascuno), 3-4 dalle tessere delle
  colonne (0-1 per colonna), 2-3 dagli edifici in piedi (propri e altrui);
- **spesa 8-10**: 3 costruzioni (1-2 Costruzione l'una nell'era 1) e 1 potenziamento
  (1 risorsa), più le azioni speciali che cambiano risorse in PV o resistenza;
- **morte accettabile: 1-2 risorse** a testa. È il numero da guardare per primo nella
  misura: `resta_e1_*` nel rapporto.

Ogni era deve offrire a ciascuna strategia un cammino da circa lo stesso valore. Oggi
un giocatore chiude con 69 PV in cinque ere, 14 per era. Budget per era, per chi gioca
la strategia pura: **Lampo 10-12 PV nell'era** (tutto subito), **Rendita 3 PV di
censimento** (che diventano 12 se gli edifici reggono fino alla fine), **Scavo 2-3 PV
alla fine per ogni edificio con Scavo alto crollato**, **generi 1-1,5 PV per edificio**
(che diventano 12 con nove dello stesso genere). Le cifre sono la posta, non il risultato:
la misura dirà quali vanno alzate.

## I generi: a che cosa serve ciascuno

Il sapore di ogni classe, uguale per Personaggi, edifici e potenziamenti, così una carta
si legge dal colore prima che dal testo:

| classe | produce | azione tipica | strategia |
|---|---|---|---|
| Civico | Costruzione | Lampo, cambi 1:1, case | punti rapidi |
| Religione | Idee | Rendita, +1 resistenza per l'era | punti lenti |
| Commercio | Denaro | guadagni da ciò che fanno gli altri | economia, interazione |
| Cultura | Idee | Scavo, Arte, PV ritrovati | punti finali e ritrovamenti |
| Ingegneria | Costruzione | sconti, forme larghe, costruire sopra | costruire tanto |
| Militare | Costruzione | protezione propria e dei vicini | tenere in piedi |

## Il vocabolario delle azioni

Dieci voci in tutto, le stesse per Personaggi, edifici e tessere, ognuna con un'icona:
un turno che attiva una colonna con quattro edifici deve leggersi in dieci secondi.

| # | icona | azione | nota |
|---|---|---|---|
| 1 | ⚒ / 🪙 / 💡 | +1 Costruzione / Denaro / Idea | la produzione pura |
| 2 | ⇄ | cambia 1 risorsa in un'altra, 1:1 | il pozzo piccolo |
| 3 | ★ | +1 PV | il Lampo differito; con una condizione ("se hai 2+ Religione in piedi") |
| 4 | 🛡 | +1 resistenza fino a fine era a un tuo edificio in questa colonna | la protezione della v2, resa azione |
| 5 | − | −1 Costruzione alla costruzione di questo turno | lo sconto |
| 6 | ⤵ | prendi anche la produzione della tessera di una colonna adiacente | la Via consolare di oggi |
| 7 | ⚱ | +1 Scavo permanente a un tuo edificio in questa colonna | l'Ossario di oggi, reso azione |
| 8 | ✦ | +1 Lampo all'edificio che costruisci in questo turno | la Radura di oggi |
| 9 | 👥 | +1 Denaro per ogni altro giocatore con un edificio in questa colonna (max 2) | la Fiera di oggi: premia le colonne vive |
| 10 | ⟲ | la tessera di questa colonna, se già girata, scatta di nuovo | rimette in gioco la tessera dell'era |
| 11 | ⊕ | in questo turno puoi comprare ancora un potenziamento o una casa della riserva, pagando | l'acquisto extra (registro 157): la catena dei Castelli di Borgogna, solo da una carta, un edificio o una tessera, mai di diritto |

Le voci 2, 3 e 11 sono i **modi di spendere** oltre le quattro azioni. Dopo la trentunesima
misura (registri 155-157) la regola del designer è: **mancanza di risorse, non surplus**. Il
terreno di base non produce più (resta la tessera dell'era), spianare costa (registro 152), i
costi hanno una seconda risorsa (Commercio e Civico Denaro, Religione e Cultura Idee,
Ingegneria e Militare Costruzione), e l'acquisto extra arriva solo da una carta. Una casa della
riserva deve restare comprabile sempre: i Ripari costano 1, Costruzione o Denaro a scelta.
Due regole trovate misurando (registro 161): **l'edificio chiede la risorsa che i suoi
potenziamenti non chiedono**, così quel che resta dopo la costruzione compra il potenziamento;
e **non si spiana un edificio della stessa era**, solo quelli delle ere precedenti.

## La sagoma delle carte

**Personaggio**: era, classe, **produzione** (1 risorsa; 2 solo senza azione), **azione**
(una voce del vocabolario). Si piazza come lavoratore: la colonna produce e scatta, poi gli
edifici, poi lui. A fine era finisce fra gli scheletri possibili.

**Edificio**: era, classe (una o due), terreno, caselle, costo, resistenza, Lampo **o**
Rendita (mai tutti e due), Scavo, **produzione** (0-1, al proprietario, a ogni attivazione
di chiunque), **azione** (una voce, al proprietario, a ogni attivazione di chiunque). Le
case della riserva: niente azione, sono case.

**Potenziamento**: era, classe, costo (1 risorsa nelle ere 1-3, 2 nelle ere 4-5), una
voce sola: +1 res, +1 PV subito (Arte), +2 Scavo, oppure un'azione in più all'edificio.

## Come si misura

```bash
S=/percorso/di/godot
# l'era 1 da sola, 3 giocatori, con il rapporto: una riga J per partita
$S --headless res://scenes/audit_partita.tscn -- --players 3 --games 300 --seed 700000 \
  --giro tutte --dati data/proposte/cards-v3-era1.json --rapporto 1 --fino_era 1 > e1.csv 2> e1.err
```

La tabella da guardare, a giocatore e per strategia: prodotto (`cum_e1_*`), speso
(prodotto meno `resta_e1_*`), **morto** (`resta_e1_*`), PV dell'era per canale, edifici
costruiti, crollati all'evento, Personaggi scelti e in quale giro del draft. `--fino_era 1`
ferma la partita a era chiusa (evento compreso) e non conta i punti di fine partita:
Scavo, Continuità e Finali si misurano con la coppia di ere 1-2.
