# Proposta: una nuova meccanica di gioco

> Trascritta dal file del designer `Nuova_Meccanica.rtf` (24 settembre 2026), con la numerazione
> originale. Il punto 1 è l'introduzione. Sotto la trascrizione: cosa cambia rispetto alla v1.5,
> le domande da chiudere prima di simulare e cosa tocca nel codice. **Niente di questo è ancora
> implementato**: il gioco in `data/cards.json` è la v1.5 con le regole adottate finora.

## La proposta, come l'ha scritta il designer

1. Fatto salvo quello che abbiamo fatto finora, vorrei cambiare radicalmente il meccanismo di
   gioco facendo i seguenti punti:
2. Passare a una versione unificata delle sagome e carte: sulle tessere e sui binari ci va una
   sagoma (alta 15 mm, larga 20 e lunga 1, 2 o 3 slot) con tutte le indicazioni dell'edificio,
   note, produzione, costo ecc. (cioè tutto quello che ora sta sulla carta). Diciamo che diventa
   una carta/sagoma che dà sia le informazioni sia occupa il posto fisico sulle carte.
3. Quando diventa rovina, si ruota e la parte che stava sotto nascosta indica ora lateralmente
   il valore di Scavo, e fa da base per le costruzioni successive.
4. Restano i terrapieni per riempire gli slot vuoti.
5. Passare a tre risorse: Costruzione (pietre), Denaro (oro), Idee (nuova).
6. Le tessere territorio vengono mescolate ed estratte casualmente, indicano la produzione e il
   tipo di quel luogo (Fiume 1 Costruzione, Bosco 1 Idea, Pianura 1 Denaro ecc.) + un effetto di
   gioco one-shot per era che si attiva quando lo dice la tessera. Poi si gira e non vale più per
   quell'era.
7. La Costruzione è progressiva: di più nell'età della pietra, per diminuire dopo; l'oro poco
   all'inizio per aumentare nei tempi moderni; le Idee in aumento costante (o logaritmico?) tra
   le ere.
8. All'inizio dell'era ogni giocatore a turno sceglie un Personaggio tra quelli disponibili, che
   dà un vantaggio per quell'era. Poi ogni turno un giocatore può fare una delle seguenti cose:
   - mettere un suo lavoratore su una colonna e attivare tutte le azioni degli edifici su quella
     colonna;
   - mettere un lavoratore su un edificio tra quelli disponibili e costruirlo; il lavoratore viene
     messo sull'edificio (che avrà +2 alla resistenza) e può attivare l'azione solo di
     quell'edificio;
   - mettere un lavoratore su un potenziamento tra quelli disponibili e mettere il potenziamento
     su un edificio compatibile; il lavoratore va sul potenziamento e diventerà uno scheletro che
     POTREBBE dare punti alla fine del gioco (un artista o un architetto o un pittore verrà forse
     ricordato);
   - ristrutturare un edificio: mettere il lavoratore su un edificio in rovina, pagare il costo di
     ristrutturazione e riportarlo dal lato attivo;
   - passare e incassare risorse (da definire).
9. Restano gli eventi che rendono rovine gli edifici: se non resistono si girano sottosopra per
   rivelare la parte in rovina con il loro valore di Scavo (come indicare di chi era l'edificio e
   prendere a fine partita il valore di Scavo?).
10. Resta il sotterramento. Quando si costruisce si può avere uno sconto di risorsa Costruzione
    pari alla metà del valore di resistenza della rovina.
11. Togliamo il rudere (quattro stati di un edificio erano troppi e ridondanti). Ora abbiamo:
    attivo, disattivo (rovina) e sotterrato (attiva il valore di Scavo a fine gioco).

## Cosa cambia rispetto alla v1.5, punto per punto

| punto | oggi (v1.5 + regole adottate) | con la proposta |
|---|---|---|
| 2 | carta nel mercato **e** sagoma sul tabellone, due oggetti | un oggetto solo, la sagoma porta tutti i dati |
| 3 | la rovina resta la stessa sagoma, disegnata spenta | la sagoma si ruota e mostra lo Scavo |
| 5 | due risorse, pietra e oro, tetto 5 (`resource_cap`) | tre: Costruzione, Denaro, Idee |
| 6 | 4 terreni a mix fisso per numero di giocatori; ogni tessera ha un'abilità **permanente** di colonna | tessere mescolate, ognuna con produzione e un effetto **una volta per era** |
| 7 | la produzione viene dagli edifici | una curva per era e per risorsa, da definire |
| 8 | fasi PIAZZA → ATTIVA → AZIONE: si piazza il lavoratore su una colonna, la si attiva, poi **un'azione** (costruire, potenziare, restaurare, reclutare, Dinastia) | cinque azioni alternative, e il lavoratore **va dove agisce**: colonna, edificio, potenziamento, rovina |
| 8 | i Personaggi si reclutano come azione, pagando oro | draft a inizio era, uno a testa |
| 8 | +2 di resistenza dalla protezione (`protection_bonus`) | +2 al lavoratore messo sull'edificio appena costruito |
| 8 | gli scheletri sono i personaggi sepolti a fine era, valgono 6 meno l'era | lo scheletro è il lavoratore sul potenziamento, e "potrebbe" dare punti |
| 8 | il restauro riporta un **rudere** intatto | la ristrutturazione riporta attiva una **rovina** |
| 9 | fallire di 1 → rudere, di 3 → rovina (`rovina_gap`) | chi non resiste diventa rovina, un passo solo |
| 10 | costruire sopra una rovina sconta 1 pietra (`rubble_discount_pietra`) | sconta metà della resistenza della rovina |
| 11 | tre stati (intatto, rudere, rovina) più il sotterrato come **posizione** | tre stati: attivo, rovina, sotterrato |

Il punto 1 dice "fatto salvo quello che abbiamo fatto finora". Restano quindi, salvo decisione
contraria: binari liberi, Verticalità 2/5/9/14, Continuità, Centro Urbano a 3 edifici e 2
proprietari che paga una volta per era, Vetustà, Monumenti, Eredità, Lampo e Rendita, le cinque ere
con gli eventi di forza 2-3-4-5.

## Domande da chiudere prima di simulare

Una simulazione vale quanto le regole che gioca: queste sono le lacune che oggi costringerebbero il
motore a **inventare**. Vanno chieste al designer, non decise.

**La sagoma (punti 2-3)**
1. Cosa resta nel mercato al posto delle carte? Le sagome stesse, in fila? Quante per volta
   (`market_size` 6)?
2. Il lato rovina mostra lo Scavo: **di chi è la rovina** (lo chiede il punto 9)? Base colorata
   del giocatore, un segnalino, un cubetto?
3. Le misure: 15 mm di altezza e 20 di larghezza stanno nello slot da 26 mm del binario? E una
   sagoma ruotata (rovina) quanto è alta, cioè quanto alza chi ci costruisce sopra?

**Le risorse (punti 5-7)**
4. I costi dei 60 edifici vanno riscritti in tre risorse: chi li scrive, e con che criterio?
   Cosa si compra con le Idee, e cosa con il Denaro oltre agli edifici?
5. La curva del punto 7 riguarda la produzione dei terreni, degli edifici o di tutti e due? Serve
   una tabella era × risorsa; "logaritmico" per le Idee va tradotto in numeri.
6. Resta un tetto alle risorse (oggi 5)? Uno per risorsa o uno in tutto?

**Le tessere (punto 6)**
7. Quante tessere, di quanti tipi, con che effetti una volta per era? "Quando lo dice la tessera":
   è l'effetto a dire quando scatta (all'attivazione, alla costruzione, a fine era...)?
8. Le abilità permanenti delle tessere di oggi ("Gli edifici Religione qui hanno +1 resistenza")
   spariscono o diventano effetti una volta per era?

**Il turno (punto 8)**
9. Costruire mettendo il lavoratore sull'edificio: **in quale colonna** si costruisce? Serve
   ancora un lavoratore sulla colonna, o si sceglie liberamente?
10. Il +2 di resistenza dura finché il lavoratore sta lì: cioè fino a fine era? E torna a fine era
    come oggi?
11. Lo scheletro "potrebbe" dare punti: con quale regola? Una condizione, un'estrazione, un
    Monumento?
12. Il costo della ristrutturazione: quale, e in quale risorsa?
13. "Passare e incassare": quanto, e la fine dell'era arriva quando tutti hanno passato o quando
    finiscono i lavoratori?
14. I Personaggi del draft: sono i 26 di oggi? Cosa ne è di Reclutare (costa oro) e della Dinastia
    (il quarto lavoratore)?

**Eventi e stati (punti 9-11)**
15. Oggi la soglia è "resistenza efficace ≥ forza": resta così, con un passo solo verso la rovina?
16. Sotterrato diventa uno **stato**: un edificio **attivo** con sopra qualcosa è sotterrato? Oggi
    si può costruire sopra un proprio intatto (`BaseKind.PROPRIO_INTATTO`).
17. Metà della resistenza: arrotondata per difetto o per eccesso? E la rovina conta la resistenza
    stampata o quella efficace?
18. Senza rudere spariscono spoliazione e restauro del rudere altrui, e la Vetustà (cubetti bianchi,
    oggi legata al restare in piedi)? Tutte le carte che nominano il rudere vanno riscritte.

## Cosa tocca nel codice

Circa 14 600 righe di GDScript. La proposta tocca quasi tutto il nucleo; la tabella serve a
stimare, non a pianificare.

| zona | file | cosa cambia |
|---|---|---|
| dati | `data/cards.json`, `data/cards.schema.json`, `scripts/data/card_db.gd`, `scripts/tools/schema_validator.gd` | tre risorse nei costi e nella produzione; tessere con effetti per era; stati senza rudere |
| stato | `scripts/core/enums.gd` (`BuildingState`, `ActionType`, `BaseKind`), `building.gd`, `player_state.gd` (`pietra`/`oro`), `grid.gd` (sotterrato), `game_state.gd` | via RUDERE; SOTTERRATO forse stato; tre risorse; lavoratori su edifici e potenziamenti |
| regole | `build_rules.gd` (costi, sconto rovina), `action_rules.gd` + `available_actions.gd` (le cinque azioni), `era_rules.gd` (attivazione, eventi, fine era, draft), `effects.gd` (effetti che nominano il rudere), `conditions.gd`, `scoring.gd` (Scavo, scheletri) | la parte grossa |
| controller | `scripts/commands/game_controller.gd` | le fasi del turno cambiano (oggi PIAZZA → ATTIVA → AZIONE) |
| bot | `strategy_bot.gd`, `planning_bot.gd`, `random_bot.gd` | valutano tre risorse e cinque azioni; le sei strategie vanno ripensate |
| vista | `board_layout_3d.gd`, `board_view_3d.gd`, `gioca.gd`, `descrizione_azione.gd`, `riepilogo.gd` | sagoma unica, rovina ruotata, lavoratori sugli edifici |
| grafica | `tools/estrai_grafica.py`, `data/sagome.json` | le sagome nuove non esistono ancora nei PDF |
| test | `test_actions` (152), `test_effects` (478), `test_view` (415) | molti presuppongono il rudere e due risorse |

Un suggerimento da discutere, non una decisione: tenere la v1.5 giocabile e misurabile accanto alla
nuova (per esempio con un file dati separato e un interruttore di regolamento), così ogni misura
della v2 ha un termine di paragone, come si è fatto finora con le manopole.
