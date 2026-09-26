# Le carte della v2, tutte in un documento

> Generato da `tools/carte_v2.py` da `data/cards-v2.json` (i numeri che gioca il motore) e
> `data/cards.json` (i testi di oggi). Per ogni carta c'è tutto quello che serve per rifarla:
> numeri, testo, e dove la v2 cambia il testo, **il testo nuovo in grassetto** con il motivo.
> È l'unico documento delle carte: se una carta cambia, si cambia qui e nel JSON, e il
> documento si rigenera. I PDF in `materiali/` servono solo per la grafica.

Le regole della v2 che i testi presuppongono (registro 87-94): tre risorse, Costruzione (C),
Denaro (D), Idee (I); tre stati, attivo, rovina, sotterrato, niente rudere; niente Verticalità,
premio di scavo S×L a chi costruisce sopra, dimezzato nell'era 5; quattro lavoratori che
attivano la colonna e poi agiscono; il Personaggio preso a inizio era nel draft, gratis, e non
seppellito; niente Vetustà;
le tessere pescate a caso, che producono per era; tetto 3 per risorsa e 5 in tutto alla
dispersione. Costanti: `workers_base` 4, `resource_cap` 5, `resource_cap_per_resource` 3, `protection_bonus` 2, `rovina_gap` 2, `market_size` 6, `side_rows` 3, `terrapieno_cost_pietra` 1.

Sigle del motivo di un cambio:

| sigla | perché |
|---|---|
| **3R** | tre risorse: il costo o l'effetto nomina pietra/oro dove ora ci sono Costruzione, Denaro e Idee |
| **RUD** | nomina il rudere, il restauro del rudere, la spoliazione o la Vetustà come oggi |
| **LAV** | presuppone il lavoratore sulla colonna: "abiti qui", "questo lavoratore" |
| **DRA** | presuppone il reclutamento come azione (classe nella colonna, 1 oro) invece del draft |
| **TES** | presuppone le tessere di oggi (abilità permanente, mix fisso) |
| **CUL** | dice "cultura" per i punti: con le Idee come risorsa la parola va cambiata (proposta: "PV") |

## I 74 edifici

Ogni edificio è una sagoma unica (punto 2 della proposta): costo, produzione, resistenza,
Rendita, Lampo e Scavo stanno sulla sagoma, che ruotata mostra il lato rovina con lo Scavo.
Costo e produzione in C/D/I. "Slot" è la larghezza; "liv." il livello minimo a cui va
costruito; "esaur." quante attivazioni produce prima di esaurirsi (la Cava). Classi e terreno
richiesto sono quelli di oggi.

### Le case della riserva (registro 116)

Le 14 case (tre per era: la piccola, la grande e quella con lo Scavo; due nell'era Moderna, dove lo Scavo non vale) non stanno nel mazzo dell'era:
sono **sempre disponibili**, tutte scoperte accanto al mercato, in 2 copie ciascuna, e si
comprano come dal mercato; a fine era le copie avanzate si scartano con le file. Non producono
e non rendono: danno Lampo (la piccola 1, la grande 2, 3 nelle ere 4-5) o Scavo (Ripari, Tuguri,
Casupole, Case popolari: 2). Classe civico, nessun terreno richiesto. Nelle tabelle
portano la sigla **RIS**.

### Da dove vengono i costi

Dalle regole di `tools/proponi_costi_v2.py` (registro 90), che scrive `data/proposte/costi-tre-risorse.json`:

- Costruzione = la pietra di oggi, Denaro = l'oro di oggi; le Idee **sostituiscono**, il totale di ogni carta resta uguale.
- Cultura paga in Idee: 1 al posto di 1 Costruzione nelle ere 1-2, al posto di 1 Denaro nelle ere 3-5; una seconda al posto di un secondo Denaro nelle ere 4-5.
- Religione paga 1 Idea al posto di 1 Costruzione nelle ere 1-2 e al posto di 1 Denaro nelle ere 3-5.
- Ingegneria paga 1 Idea al posto di 1 Denaro dall'era 2 in poi.
- Militare, Commercio e Civico non pagano Idee, salvo la regola dell'esplosione.
- Una carta a doppia classe segue la classe che chiede Idee, una volta sola; se la risorsa da sostituire manca, si sostituisce Costruzione.
- Chi oggi produce Cultura produce Idee.
- Nelle ere 4-5 ogni carta paga almeno un'Idea (l'esplosione delle Idee: "15 e 18"); l'era 3 è il periodo oscuro, le Idee calano.

Domanda per era (C / D / I): era 1: 17 / 0 / 5 · era 2: 29 / 0 / 6 · era 3: 25 / 5 / 4 · era 4: 19 / 8 / 18 · era 5: 14 / 13 / 20.

### Era 1

| edificio | classi | terreno | slot | costo C/D/I | res | Rendita | Lampo | Scavo | produce | liv. | esaur. | testo | motivo | nota |
|---|---|---|--:|--:|--:|--:|--:|--:|---|--:|--:|---|---|---|
| Approdo | commercio | Fiume | 1 | 1/0/0 | 1 | 0 | 0 | 2 | 1 C | 0 | — | — |  |  |
| Capanne | civico | Pianura | 1 | 1/0/0 | 1 | 0 | 1 | 2 | 1 C | 0 | — | — |  |  |
| Capanne di fango | civico | qualsiasi | 1 | 1/0/0 | 1 | 0 | 1 | 1 | — | 0 | — | — | RIS x2 | nuova: in riserva, sempre disponibile; niente lato di oggi |
| Case di pietra | civico | qualsiasi | 1 | 2/0/0 | 2 | 0 | 2 | 1 | — | 0 | — | — | RIS x2 | nuova: in riserva, sempre disponibile; niente lato di oggi |
| Cava | commercio | Pianura | 1 | 1/0/0 | 1 | 0 | 0 | 2 | 2 C | 0 | 4 | — |  |  |
| Circolo di pietre | religione | qualsiasi | 2 | 2/0/1 | 4 | 1 | 0 | 5 | — | 0 | — | Lo Stonehenge della strada. |  |  |
| Dolmen | religione | Collina | 1 | 1/0/1 | 3 | 1 | 0 | 3 | — | 0 | — | — |  |  |
| Focolare comune | civico | Pianura | 1 | 1/0/0 | 1 | 0 | 1 | 2 | — | 0 | — | **Quartiere: +1 Costruzione quando lo attivi.** | LAV 3R | oggi: "Quartiere: +1 pietra quando abiti qui" — "quando abiti qui": il lavoratore sta sulla colonna, quindi "quando attivi la colonna" |
| Grotte dipinte | cultura | Collina | 1 | 0/0/1 | 2 | 0 | 0 | 6 | — | 0 | — | — |  |  |
| Menhir | religione | Bosco | 1 | 1/0/1 | 4 | 1 | 0 | 3 | — | 0 | — | Piccolo ma quasi indistruttibile. |  |  |
| Palafitte | civico | Fiume | 1 | 1/0/0 | 2 | 0 | 1 | 2 | 1 C | 0 | — | — |  |  |
| Ripari | civico | qualsiasi | 1 | 1/0/0 | 1 | 0 | 0 | 2 | — | 0 | — | — | RIS x2 | nuova: in riserva, sempre disponibile; niente lato di oggi |
| Trappole da pesca | ingegneria | Fiume | 1 | 1/0/0 | 1 | 0 | 0 | 0 | 1 C | 0 | — | — |  |  |
| Tumulo funerario | religione, cultura | Collina | 2 | 1/0/1 | 3 | 0 | 1 | 5 | — | 0 | — | — |  |  |
| Villaggio palizzato | militare | Pianura | 2 | 2/0/0 | 2 | 0 | 1 | 2 | — | 0 | — | Quartiere: +1 res ai tuoi edifici adiacenti. |  |  |

### Era 2

| edificio | classi | terreno | slot | costo C/D/I | res | Rendita | Lampo | Scavo | produce | liv. | esaur. | testo | motivo | nota |
|---|---|---|--:|--:|--:|--:|--:|--:|---|--:|--:|---|---|---|
| Acquedotto | ingegneria | Fiume | 3 | 2/0/1 | 4 | 1 | 0 | 3 | — | 0 | — | **Colossale: 2 slot adiacenti (3 pagando +1 Costruzione; in 2 giocatori il terzo slot è vietato), almeno uno con fiume. Eco: +2 PV (lampo) se ancora in piedi nel Moderno.** | 3R | oggi: "Colossale: 2 slot adiacenti (3 pagando +1 pietra; in 2 giocatori il terzo slot è vietato), almeno uno con fiume. Eco: +2 PV (lampo) se ancora in piedi nel Moderno" |
| Anfiteatro | cultura | qualsiasi | 3 | 4/0/1 | 5 | 2 | 0 | 6 | 1 D | 0 | — | Colossale: occupa 2 slot adiacenti, si attiva da entrambe le colonne e conta come strato in entrambe. Produce 1 oro a ogni attivazione — il Colosseo vende i biglietti. |  |  |
| Case a schiera | civico | qualsiasi | 1 | 1/0/0 | 2 | 0 | 1 | 1 | — | 0 | — | — | RIS x2 | nuova: in riserva, sempre disponibile; niente lato di oggi |
| Castrum | militare | Pianura | 2 | 3/0/0 | 4 | 0 | 1 | 3 | — | 0 | — | +1 res ai tuoi edifici in questa colonna. |  |  |
| Domus | civico | qualsiasi | 1 | 2/0/0 | 3 | 0 | 2 | 1 | — | 0 | — | — | RIS x2 | nuova: in riserva, sempre disponibile; niente lato di oggi |
| Emporio | commercio | Fiume | 1 | 2/0/0 | 2 | 0 | 2 | 2 | 1 D | 0 | — | — |  | Lampo 1 → 2 (registro 100) |
| Foro | commercio, civico | Pianura | 2 | 3/0/0 | 3 | 1 | 0 | 5 | 1 D | 0 | — | — |  |  |
| Insulae | civico | Pianura | 1 | 2/0/0 | 2 | 0 | 2 | 2 | 1 C | 0 | — | — |  | Lampo 1 → 2 (registro 100) |
| Ponte | ingegneria | Fiume | 2 | 2/0/1 | 3 | 1 | 0 | 3 | — | 0 | — | Quartiere: +1 produzione agli edifici adiacenti. |  |  |
| Sacello | religione | Collina | 1 | 0/0/1 | 2 | 0 | 1 | 3 | — | 0 | — | — |  |  |
| Teatro | cultura | qualsiasi | 1 | 1/0/1 | 3 | 0 | 2 | 5 | — | 0 | — | — |  |  |
| Tempio | religione | Collina | 1 | 2/0/1 | 3 | 1 | 0 | 3 | — | 0 | — | — |  |  |
| Terme | civico | qualsiasi | 1 | 2/0/0 | 2 | 0 | 2 | 3 | — | 0 | — | — |  |  |
| Torre di vedetta | militare | Collina | 1 | 2/0/0 | 3 | 0 | 1 | 2 | — | 0 | — | Quartiere: +1 res ai tuoi edifici adiacenti. |  |  |
| Tuguri | civico | qualsiasi | 1 | 1/0/0 | 2 | 0 | 0 | 2 | — | 0 | — | — | RIS x2 | nuova: in riserva, sempre disponibile; niente lato di oggi |

### Era 3

| edificio | classi | terreno | slot | costo C/D/I | res | Rendita | Lampo | Scavo | produce | liv. | esaur. | testo | motivo | nota |
|---|---|---|--:|--:|--:|--:|--:|--:|---|--:|--:|---|---|---|
| Abbazia | religione, commercio | Bosco | 2 | 2/1/1 | 3 | 2 | 0 | 5 | — | 0 | — | — |  | Rendita 3 → 2 (registro 97: le carte care) |
| Arsenale | militare | Fiume | 2 | 3/1/0 | 3 | 0 | 2 | 2 | — | 0 | — | Quartiere: i tuoi edifici Militari adiacenti +1 res. |  |  |
| Borgo | civico | Pianura | 1 | 2/0/0 | 2 | 0 | 3 | 2 | 1 D | 0 | — | — |  | Lampo 2 → 3 (registro 100) |
| Cappella | religione | qualsiasi | 1 | 1/0/1 | 2 | 0 | 2 | 3 | — | 0 | — | — |  |  |
| Casa torre | civico | qualsiasi | 1 | 1/1/0 | 3 | 0 | 2 | 1 | — | 0 | — | — | RIS x2 | nuova: in riserva, sempre disponibile; niente lato di oggi |
| Case di legno | civico | qualsiasi | 1 | 1/0/0 | 2 | 0 | 1 | 1 | — | 0 | — | — | RIS x2 | nuova: in riserva, sempre disponibile; niente lato di oggi |
| Castello | militare | Collina | 2 | 2/1/0 | 4 | 2 | 0 | 3 | — | 1 | — | — |  | Rendita 3 → 2 (registro 97) |
| Casupole | civico | qualsiasi | 1 | 1/0/0 | 2 | 0 | 0 | 2 | — | 0 | — | — | RIS x2 | nuova: in riserva, sempre disponibile; niente lato di oggi |
| Chiesa | religione, cultura | qualsiasi | 1 | 2/0/1 | 3 | 2 | 0 | 3 | — | 0 | — | — |  |  |
| Conceria | commercio | Fiume | 1 | 1/0/0 | 1 | 0 | 1 | 0 | 1 D | 0 | — | — |  |  |
| Mercato | commercio | Fiume | 1 | 2/0/0 | 2 | 0 | 1 | 2 | 1 C + 1 D | 0 | — | — |  |  |
| Mulino | ingegneria, commercio | Pianura | 1 | 1/0/1 | 2 | 0 | 1 | 2 | 2 D | 0 | — | — |  |  |
| Mura | militare | qualsiasi | 1 | 2/0/0 | 4 | 0 | 1 | 2 | — | 0 | — | Quartiere: +1 res agli edifici adiacenti (anche altrui). |  |  |
| Ospedale dei pellegrini | civico | qualsiasi | 1 | 2/1/0 | 2 | 0 | 2 | 2 | — | 0 | — | **Quando lo attivi, +1 Denaro.** | LAV 3R | oggi: "Quando abiti qui, +1 oro" |
| Torre civica | civico | qualsiasi | 1 | 2/0/0 | 3 | 0 | 3 | 2 | — | 0 | — | — |  | Lampo 2 → 3 (registro 100) |

### Era 4

| edificio | classi | terreno | slot | costo C/D/I | res | Rendita | Lampo | Scavo | produce | liv. | esaur. | testo | motivo | nota |
|---|---|---|--:|--:|--:|--:|--:|--:|---|--:|--:|---|---|---|
| Accademia | cultura | qualsiasi | 1 | 1/0/2 | 2 | 0 | 2 | 3 | — | 0 | — | — |  |  |
| Banco | commercio | qualsiasi | 1 | 1/0/1 | 2 | 0 | 3 | 0 | 1 D | 0 | — | — |  | Lampo 2 → 3 (registro 100) |
| Bottega d'artista | cultura | qualsiasi | 1 | 1/0/1 | 2 | 0 | 2 | 2 | — | 0 | — | **I tuoi potenziamenti costano 1 in meno, nella loro risorsa.** | 3R | oggi: "I tuoi potenziamenti costano 1 oro in meno" — i potenziamenti pagano per famiglia: Arte in Idee, Struttura in Costruzione, il resto in Denaro |
| Casa borghese | civico | qualsiasi | 1 | 0/0/1 | 2 | 0 | 2 | 1 | — | 0 | — | — | RIS x2 | nuova: in riserva, sempre disponibile; niente lato di oggi |
| Case popolari | civico | qualsiasi | 1 | 0/0/1 | 2 | 0 | 0 | 2 | — | 0 | — | — | RIS x2 | nuova: in riserva, sempre disponibile; niente lato di oggi |
| Duomo | religione, cultura | qualsiasi | 2 | 3/1/2 | 4 | 2 | 0 | 5 | — | 2 | — | — |  | Rendita 4 → 2 (registro 97) |
| Fortezza bastionata | militare, ingegneria | Collina | 2 | 3/1/1 | 5 | 2 | 0 | 2 | — | 1 | — | — |  | Rendita 3 → 2 (registro 97) |
| Giardino all'italiana | cultura | Collina | 1 | 0/0/2 | 1 | 0 | 3 | 0 | — | 0 | — | Effimero per eccellenza: PV subito, difficilmente sopravvivrà. |  |  |
| Loggia | civico | qualsiasi | 1 | 1/0/1 | 2 | 0 | 3 | 2 | — | 0 | — | — |  | Lampo 2 → 3 (registro 100) |
| Osservatorio | ingegneria | Collina | 1 | 1/1/1 | 2 | 0 | 2 | 2 | — | 0 | — | Eco: +2 PV (lampo) se ancora in piedi a fine partita. |  |  |
| Palazzetto | civico | qualsiasi | 1 | 0/1/1 | 3 | 0 | 3 | 1 | — | 0 | — | — | RIS x2 | nuova: in riserva, sempre disponibile; niente lato di oggi |
| Palazzo signorile | civico | Pianura | 1 | 2/1/1 | 3 | 0 | 3 | 3 | 1 I | 0 | — | — | 3R | produce 1 Idea al posto di 1 cultura (già nel file v2) |
| Piazza monumentale | civico | Pianura | 2 | 2/1/1 | 3 | 2 | 0 | 3 | — | 1 | — | A fine partita: +1 PV per tuo edificio in cima adiacente. Richiede livello 1+. |  |  |
| Ponte monumentale | ingegneria | Fiume | 2 | 2/1/1 | 4 | 2 | 0 | 3 | — | 0 | — | — |  | Rendita 3 → 2 (registro 97) |
| Villa | civico | Collina | 1 | 2/1/1 | 3 | 0 | 4 | 3 | — | 0 | — | — |  |  |

### Era 5

| edificio | classi | terreno | slot | costo C/D/I | res | Rendita | Lampo | Scavo | produce | liv. | esaur. | testo | motivo | nota |
|---|---|---|--:|--:|--:|--:|--:|--:|---|--:|--:|---|---|---|
| Biblioteca | cultura | qualsiasi | 1 | 1/1/2 | 3 | 0 | 4 | 0 | — | 0 | — | +1 PV per classe diversa fra i tuoi edifici in questa colonna, Sotterrati inclusi. |  |  |
| Caffè letterario | cultura | qualsiasi | 1 | 0/0/2 | 1 | 0 | 2 | 0 | — | 0 | — | Quartiere: +1 PV se adiacente a un edificio Cultura. |  |  |
| Condominio | civico | qualsiasi | 1 | 1/0/1 | 2 | 0 | 3 | 0 | — | 0 | — | Economico: costruire il presente sopra il passato non è mai stato così facile. |  | resta: si costruisce sopra le rovine con lo sconto di metà resistenza (punto 10); Lampo 2 → 3 (registro 100) |
| Condominio popolare | civico | qualsiasi | 1 | 0/1/1 | 4 | 0 | 3 | 1 | — | 0 | — | — | RIS x2 | nuova: in riserva, sempre disponibile; niente lato di oggi |
| Fondazione d'arte | cultura | qualsiasi | 1 | 1/0/2 | 2 | 0 | 3 | 0 | — | 0 | — | I tuoi potenziamenti valgono +1 PV. |  |  |
| Grattacielo | commercio | Pianura | 1 | 2/3/1 | 3 | 0 | 4 | 0 | — | 2 | — | Svettante: +1 PV per livello a cui è costruito. Quartiere: −1 PV agli edifici in cima adiacenti altrui, valutato a fine partita. Richiede livello 2+. |  |  |
| Monumento ai caduti | militare, religione | qualsiasi | 1 | 1/1/1 | 3 | 0 | 2 | 0 | — | 0 | — | Sacrario: +1 PV per ogni altro tuo edificio Militare, in piedi o Sotterrato. |  |  |
| Museo | cultura | qualsiasi | 1 | 1/1/2 | 3 | 0 | 4 | 0 | — | 1 | — | +2 PV per ogni edificio Sotterrato sotto di sé. Richiede livello 1+. |  |  |
| Officina | ingegneria | qualsiasi | 1 | 1/0/1 | 2 | 0 | 3 | 0 | 2 D | 0 | — | — |  | Lampo 2 → 3 (registro 100) |
| Palazzina | civico | qualsiasi | 1 | 0/0/1 | 3 | 0 | 2 | 1 | — | 0 | — | — | RIS x2 | nuova: in riserva, sempre disponibile; niente lato di oggi |
| Parco archeologico | cultura | qualsiasi | 2 | 1/0/2 | 2 | 0 | 2 | 0 | — | 0 | — | Finale: fino a 2 tuoi edifici non Sotterrati nelle colonne adiacenti valgono il loro Scavo come se lo fossero. |  |  |
| Ponte in acciaio | ingegneria | Fiume | 2 | 1/2/1 | 4 | 0 | 4 | 0 | — | 0 | — | — |  |  |
| Stazione | commercio, ingegneria | Pianura | 3 | 2/3/1 | 4 | 0 | 4 | 0 | 2 D | 1 | — | Colossale: 2 slot adiacenti, si attiva da entrambe le colonne. Produce 2 oro. Richiede livello 1+. |  |  |
| Università | cultura, civico | qualsiasi | 2 | 2/1/2 | 3 | 0 | 4 | 0 | — | 1 | — | **+1 PV per ogni tuo Personaggio preso nel draft. Richiede livello 1+.** | DRA | oggi: "+1 PV per ogni tuo personaggio reclutato. Richiede livello 1+" |

## Le tessere terreno

Si pescano a caso (punto 6); il mix garantisce il bosco: 2 giocatori 2 pianura, 1 fiume, 1 collina, 1 bosco; 3 giocatori 2 pianura, 2 fiume, 1 collina, 2 bosco; 4 giocatori 3 pianura, 2 fiume, 2 collina, 2 bosco.
Ogni tessera produce per tipo, con una curva per era, a chi la attiva, e ha un effetto che
scatta **una volta per era** alla prima occasione, poi la tessera si gira (registro 100).

| tessera | era 1 | era 2 | era 3 | era 4 | era 5 | regola (nel file v2) | oggi |
|---|---|---|---|---|---|---|---|
| Pianura | 1 C | 1 C + 1 D | 1 D | 2 D | 2 D | Denaro, poco all'inizio e molto dopo. Una volta per era: un edificio da 2 o 3 caselle costa 1 Costruzione in meno. | −1 pietra permanente agli edifici da 2 o 3 caselle |
| Fiume | 2 C | 2 C | 1 C | 1 C | 1 C | Costruzione, tanta all'inizio e poco dopo. Una volta per era: +1 Denaro a chi la attiva. Requisito 'fiume' stretto. | "unico terreno che produce oro" (1 pietra 1 oro) |
| Collina | 2 C | 2 C | 1 C | 1 C | 1 C | Costruzione come il fiume. Una volta per era: il primo edificio costruito qui ha +1 resistenza per l'era. | +1 res permanente a ogni edificio costruito qui |
| Bosco | 1 I | 2 I | 2 I | 3 I | 3 I | Idee, in aumento con le ere. Una volta per era: una ristrutturazione costa 1 Costruzione in meno. | Vetustà massima +4 (la Vetustà non c'è più) e restauro −1 pietra |

## I 26 Personaggi

Si prendono nel **draft** a inizio era (registro 93): in ordine di turno, uno a testa fra i
cinque dell'era, gratis e senza lavoratore; gli avanzi si scartano a fine era. Niente classe
richiesta nella colonna, niente costo: la classe resta stampata come informazione. A fine era
il Personaggio si scarta: **non si seppellisce** (registro 95); lo scheletro lo lascia il
lavoratore del potenziamento.

| era | Personaggio | classe | quando | testo | motivo | nota |
|--:|---|---|---|---|---|---|
| 1 | Capotribù | civico | misto | **Subito: +2 Costruzione. Per l'era: il primo edificio che costruisci ha +1 res.** | LAV 3R | oggi: "Subito: +2 pietra. Per l'era: l'edificio protetto da questo lavoratore ha +1 res" — è così nel motore: senza lavoratore che abita, il protettore si lega al primo edificio costruito nell'era |
| 1 | Sciamano | religione | era | Per l'era: i tuoi edifici Religione hanno +1 res. |  |  |
| 1 | Mercante di ossidiana | commercio | misto | **Subito: +1 Denaro. Per l'era: fino a 2 scambi alla pari fra due risorse qualsiasi.** | 3R | oggi: "Subito: +1 oro. Per l'era: fino a 2 scambi pietra↔oro alla pari" |
| 1 | Incisore | cultura | subito | **Impronta: infila questa carta sotto il primo edificio che costruisci in quest'era; Scavo +3 permanente. Max 1 impronta per edificio.** | DRA | oggi: "Subito — Impronta: infila questa carta sotto un tuo edificio; Scavo +3 permanente. Max 1 impronta per edificio" — a inizio era 1 nessuno ha edifici: nel draft la carta si offre solo a chi ha un edificio, quindi va riscritta |
| 1 | Costruttore di zattere | ingegneria | misto | **Subito: +1 Costruzione. Per l'era: −1 Costruzione alle costruzioni su slot con fiume.** | 3R | oggi: "Subito: +1 pietra. Per l'era: −1 pietra alle costruzioni su slot con fiume" |
| 2 | Architetto | ingegneria | misto | **Subito: +1 Costruzione. Per l'era: −1 Costruzione agli edifici da 2 o 3 caselle.** | 3R | oggi: "Subito: +1 pietra. Per l'era: −1 pietra agli edifici da 2 o 3 caselle" |
| 2 | Legionario | militare | era | **Per l'era: il primo edificio che costruisci ha +1 res; se sopravvive all'evento, +1 PV.** | LAV CUL | oggi: "Per l'era: la sua protezione vale +3 invece di +2; se l'edificio protetto sopravvive all'evento, +1 cultura" — oggi "la sua protezione vale +3 invece di +2": il +2 del lavoratore sulla colonna resta, questo è il +1 in più |
| 2 | Sacerdotessa | religione | misto | **Subito: +1 Denaro. Per l'era: il primo edificio Religione che costruisci ti rimborsa 1 Idea.** | 3R | oggi: "Subito: +1 oro. Per l'era: il primo edificio Religione che costruisci ti rimborsa 1 oro" — Religione paga Idee: il rimborso va nella risorsa che paga |
| 2 | Console | civico | misto | **Subito: +1 Denaro. Per l'era: quando attivi una colonna con un tuo strato Civico, +1 Denaro (max 2).** | 3R | oggi: "Subito: +1 oro. Per l'era: quando attivi una colonna con un tuo strato Civico, +1 oro (max 2)" |
| 2 | Retore | cultura | subito | **Impronta: infila questa carta sotto il primo edificio Cultura che costruisci in quest'era; Scavo +5 permanente. Max 1 impronta per edificio.** | DRA | oggi: "Subito — Impronta: infila questa carta sotto un tuo edificio Cultura; Scavo +5 permanente. Max 1 impronta per edificio" — come l'Incisore |
| 3 | Mastro costruttore | ingegneria | misto | **Subito: +1 Costruzione. Per l'era: la tua prima costruzione ha +1 res permanente.** | 3R | oggi: "Subito: +1 pietra. Per l'era: puoi costruire in qualsiasi slot; la tua prima costruzione successiva ha +1 res permanente" — "puoi costruire in qualsiasi slot" non serve più: i binari sono liberi |
| 3 | Vescovo | religione | misto | Subito: il prossimo potenziamento su un tuo edificio Religione in quest'era costa 0. Per l'era: capienza dei tuoi Religione +1. |  | resta: vale nella risorsa del potenziamento |
| 3 | Cavaliere | militare | era | **Per l'era: il primo edificio che costruisci ha +2 res; se sopravvive all'evento, +1 PV.** | LAV CUL | oggi: "Per l'era: la sua protezione vale +4 invece di +2; se l'edificio protetto sopravvive, +1 cultura" |
| 3 | Mercante | commercio | misto | **Subito: +1 Denaro. Per l'era: quando un avversario attiva una colonna con tuoi strati visibili, +1 Denaro (max 2).** | 3R | oggi: "Subito: +1 oro. Per l'era: quando un avversario attiva una colonna con tuoi strati visibili, +1 oro (max 2)" |
| 3 | Cronista | civico | misto | **Subito: se la colonna contiene edifici di 3+ ere diverse, +1 PV. Per l'era: quando attivi una colonna che contiene edifici di 3+ ere diverse (in qualsiasi condizione), +1 PV (max 2 ulteriori).** | CUL | oggi: "Subito: se la colonna contiene edifici di 3+ ere diverse, +1 cultura. Per l'era: quando attivi una colonna che contiene edifici di 3+ ere diverse (in qualsiasi condizione), +1 cultura (max 2 ulteriori)" |
| 4 | Mecenate | cultura | misto | **Subito: +1 PV. Per l'era: i potenziamenti Arte che acquisti valgono +1 PV.** | CUL | oggi: "Subito: +1 cultura. Per l'era: i potenziamenti Arte che acquisti valgono +1 PV" |
| 4 | Banchiere | commercio | subito | **Subito: +3 Denaro.** | 3R | oggi: "Subito: +3 oro" |
| 4 | Ingegnere militare | militare | era | Per l'era: i tuoi edifici Militari hanno +1 res; uno a tua scelta +2. |  |  |
| 4 | Cardinale | religione | misto | **Subito: +1 Denaro. Per l'era: −1 Idea agli edifici Religione (minimo 0).** | 3R | oggi: "Subito: +1 oro. Per l'era: −1 oro agli edifici Religione (minimo 0)" — Religione paga Idee |
| 4 | Artista di corte | cultura | misto | **Subito: +1 PV. Per l'era: il primo potenziamento che piazzi su un edificio altrui è gratis e incassi 1 Denaro dal proprietario.** | 3R CUL | oggi: "Subito: +1 cultura. Per l'era: il primo potenziamento che piazzi su un edificio altrui è gratis e incassi 1 oro dal proprietario" |
| 5 | Archeologo | cultura | finale | Finale: scegli una tua Rovina non Sotterrata: vale il suo Scavo. Se hai già 3+ edifici Sotterrati, +1 PV. |  |  |
| 5 | Urbanista | civico | finale | Finale: +1 PV per ogni tuo strato in catene da 4+ ere (max +4). |  |  |
| 5 | Industriale | commercio | misto | **Subito: +2 Denaro. Per l'era: le tue prime 2 produzioni di Denaro danno +1.** | 3R | oggi: "Subito: +2 oro. Per l'era: le tue prime 2 produzioni di oro danno +1" |
| 5 | Soprintendente | ingegneria | finale | Finale: fino a 3 tuoi edifici Sotterrati hanno Scavo +2. |  |  |
| 5 | Veterano | militare | finale | Finale: +1 PV per ogni tuo edificio Militare in piedi (max +4). |  |  |
| — | Dinastia | civico | permanente | **Sempre disponibile, fuori dal draft, al posto dell'azione. Costo in Idee: era 1 = 4 · era 2 = 3 · era 3 = 3 · era 4 = 3. Nessuna abilità: aggiunge un quinto lavoratore, permanente e attivo da subito. Massimo una a testa.** | 3R | oggi: "Sempre disponibile fuori dalle file, nessuna classe richiesta. Costo a scalare secondo l'era: era 1 = 4 pietra · era 2 = 2 pietra + 1 oro · era 3 = 1 pietra + 2 oro · era 4 = 3 oro. Nessuna abilità: aggiunge un quarto lavoratore, permanente e attivo da subito. Massimo una a testa" — con quattro lavoratori di base (registro 94) è il quinto |

## I 25 potenziamenti

Si paga nella risorsa della famiglia (registro 91): Arte in Idee, Struttura in Costruzione, il
resto in Denaro; importi di oggi (1 nelle ere 1-3, 2 nelle ere 4-5). Il lavoratore che lo
piazza resta sotto l'edificio come scheletro (punto 8, registri 95-96): uno per edificio, non
nell'era Moderna, vale 6 meno l'era comunque finisca l'edificio. Sulla sagoma serve il posto.

| era | potenziamento | famiglia | costo C/D/I | testo | motivo | nota |
|--:|---|---|--:|---|---|---|
| 1 | Pittura rupestre | arte | 0/0/1 | Arte: +1 PV. Scavo dell'edificio +2. |  |  |
| 1 | Palizzata | struttura | 1/0/0 | Struttura: +1 res. |  |  |
| 1 | Idolo | arte | 0/0/1 | Arte: +1 PV (+1 extra su edificio Religione). |  |  |
| 1 | Granaio comune | altro | 0/1/0 | **Quando attivi questo edificio, +1 Costruzione.** | LAV 3R | oggi: "Quando abiti questo edificio, +1 pietra" |
| 1 | Fondamenta in pietra | struttura | 1/0/0 | Struttura: +1 res. |  |  |
| 2 | Statua | arte | 0/0/1 | Arte: +2 PV. |  |  |
| 2 | Altare | arte | 0/0/1 | Arte: +1 PV. Scavo +2. |  |  |
| 2 | Bastioni | struttura | 1/0/0 | Struttura: +1 res. |  |  |
| 2 | Banchina | altro | 0/1/0 | **Solo su slot fiume: quando attivi questo edificio, +1 Denaro.** | LAV 3R | oggi: "Solo su slot fiume: quando abiti qui, +1 oro" |
| 2 | Iscrizione | altro | 0/1/0 | Scavo dell'edificio +2. |  |  |
| 3 | Contrafforte | struttura | 1/0/0 | Struttura: +1 res. |  |  |
| 3 | Campanile | altro | 0/1/0 | Ibrido: +1 PV e +1 res. |  |  |
| 3 | Merlatura | struttura | 1/0/0 | Struttura: +1 res. L'edificio conta anche come Militare. |  |  |
| 3 | Stalli mercantili | altro | 0/1/0 | L'affitto incassato da questo edificio è +1. |  |  |
| 3 | Reliquia | arte | 0/0/1 | Arte: +2 PV su edificio Religione, altrimenti +1. |  |  |
| 4 | Opera d'arte | arte | 0/0/2 | Arte: +3 PV. |  |  |
| 4 | Affreschi | arte | 0/0/2 | Arte: +2 PV. |  |  |
| 4 | Cupola | altro | 0/2/0 | Ibrido: +2 PV e +1 res. |  |  |
| 4 | Giardino pensile | arte | 0/0/2 | Arte: +2 PV. |  |  |
| 4 | Cannoniere | struttura | 2/0/0 | Struttura: +1 res (+2 su edificio Militare). |  |  |
| 5 | Installazione | arte | 0/0/2 | Arte: +3 PV. |  |  |
| 5 | Targa storica | altro | 0/2/0 | Finale: +2 Scavo a ogni edificio Sotterrato sotto questo edificio. |  |  |
| 5 | Ascensore panoramico | altro | 0/2/0 | +2 PV. |  |  |
| 5 | Boutique | altro | 0/2/0 | **Quando attivi questo edificio, +2 Denaro.** | LAV 3R | oggi: "Quando abiti questo edificio, +2 oro" |
| 5 | Memoriale | altro | 0/2/0 | +2 PV. |  |  |

## I 24 eventi

Uno per era nelle ere 1-4, forza 2/3/4/5; chi non regge cade in rovina con un passo solo
(`rovina_gap` 2: fallire di meno resta attivo, senza Vetustà).

| era | evento | forza | testo | motivo | nota |
|--:|---|--:|---|---|---|
| 1 | Diluvio | 2 | Forza 2. Edifici su colonne fiume: −1 res. |  |  |
| 1 | Età degli spiriti | 2 | Forza 2. Religione +1 res · Commercio −1 res. |  |  |
| 1 | Migrazione | 2 | Forza 2. Edifici non protetti: −1 res extra. | LAV | "non protetti" resta: protegge il lavoratore messo sopra un proprio edificio in piedi, come oggi |
| 1 | Inverno lungo | 2 | **Forza 2. Edifici su bosco e collina: −1 res. Tutti i giocatori perdono 1 Costruzione.** | 3R | oggi: "Forza 2. Edifici su bosco e collina: −1 res. Tutti i giocatori perdono 1 pietra" |
| 1 | Faide tribali | 2 | Forza 2. Militare +1 res · Civico −2 res. |  |  |
| 1 | Carestia primitiva | 2 | Forza 2. Edifici a livello 0 non protetti che producono risorse: −2 res. | LAV | come Migrazione |
| 2 | Terremoto | 3 | Forza 3. Edifici da 2 o 3 caselle: −1 res. |  |  |
| 2 | Pax imperiale | 3 | Forza 3. Ingegneria +1 res · Militare −1 res. |  |  |
| 2 | Invasione | 3 | Forza 3. Edifici non protetti: −1 res extra. | LAV | come Migrazione |
| 2 | Eruzione | 3 | Forza 3. Edifici su collina: −2 res. Chi perde un edificio pesca un potenziamento gratis (massimo uno per giocatore). |  |  |
| 2 | Persecuzioni | 3 | Forza 3. Religione −2 res · Civico +1 res. |  |  |
| 2 | Guerra civile | 3 | Forza 3. Nelle colonne con edifici di 2+ giocatori: tutti −1 res. |  |  |
| 3 | Incursioni fluviali | 4 | Forza 4. Edifici su colonne fiume: −1 res. |  |  |
| 3 | Guerra | 4 | Forza 4. Militare +1 res · Civico −1 res. |  |  |
| 3 | Peste | 4 | Forza 4. Colonne con 3+ edifici in piedi: tutti −1 res. |  |  |
| 3 | Grande incendio | 4 | Forza 4. Edifici a livello 0 o 1: −1 res; a livello 2+: −2 res. |  |  |
| 3 | Scisma | 4 | Forza 4. Religione −2 res · Cultura −1 res · Commercio +1 res. |  |  |
| 3 | Anni della fame | 4 | Forza 4. Nessuna produzione durante l’ultimo round dell’era. |  | resta: i round ci sono ancora (quattro lavoratori, quattro giri) |
| 4 | Alluvione | 5 | Forza 5. Edifici su colonne fiume: −1 res. |  |  |
| 4 | Controriforma | 5 | Forza 5. Religione +1 res · Cultura −1 res. |  |  |
| 4 | Rivoluzione industriale | 5 | Forza 5. Edifici con Scavo 2+: −1 res. |  |  |
| 4 | Bonifiche | 5 | Forza 5. Edifici su pianura: −2 res. Il primo terrapieno di ogni giocatore in quest’era costa 0. |  |  |
| 4 | Secolarizzazioni | 5 | **Forza 5. Religione −2 res · durante l'era, ristrutturare una propria rovina Religione non costa risorse (richiede comunque l'azione).** | RUD | oggi: "Forza 5. Religione −2 res · durante l’era, restaurare un rudere Religione non costa risorse (richiede comunque l’azione) e vale sui ruderi già presenti" |
| 4 | Speculazione edilizia | 5 | **Forza 5. Ogni edificio con 2+ potenziamenti: −1 res.** | RUD | oggi: "Forza 5. Ogni edificio con Vetustà 2+: −1 res" — registro 99: senza Vetustà non colpiva nessuno, ora colpisce chi ha costruito sopra il costruito (nel file v2) |

## I 14 Monumenti

Se ne rivelano tanti quanti i giocatori meno uno; li prende il primo che soddisfa la condizione.

| carta | PV | condizione | motivo | nota |
|---|--:|---|---|---|
| San Clemente | 5 | Primo ad avere 3 edifici Religione nella stessa colonna. |  |  |
| Colosseo | 4 | **Primo ad avere un edificio attivo con resistenza 7 o più.** | RUD | oggi: "Primo il cui edificio sopravvive esposto a 3 eventi" — registro 99: contava la Vetustà 3, ora premia l'edificio che resiste per costruzione (nel file v2) |
| Pantheon | 4 | **Primo ad avere un edificio dell'era 1 o 2 ancora attivo all'inizio dell'era Moderna.** | RUD | oggi: "Primo ad avere un edificio dell’era 1 o 2 ancora in piedi all’inizio dell’era Moderna" |
| Fori Imperiali | 4 | Primo ad avere 4 propri edifici Sotterrati. |  |  |
| Acropoli | 4 | Primo a costruire a livello 4. |  | resta: i livelli restano, la Verticalità no |
| Via Appia | 5 | Primo ad avere propri edifici in cima a 4 colonne consecutive. |  |  |
| Terme di Caracalla | 4 | Primo a costruire un edificio da 3 caselle. |  |  |
| Ponte Milvio | 4 | Primo ad avere 2 edifici su colonne fiume distinte. |  |  |
| Mura Aureliane | 5 | Primo ad avere 3 edifici Militari in piedi contemporaneamente. |  |  |
| Cloaca Massima | 4 | **Primo ad aver speso almeno 3 Costruzione complessive in costi di terrapieno.** | 3R | oggi: "Primo ad aver speso almeno 3 pietra complessive in costi di terrapieno" |
| Domus Aurea | 5 | Primo ad avere un edificio con 3 potenziamenti. |  |  |
| Campidoglio | 4 | Primo ad avere 2 edifici Civici nella stessa colonna. |  |  |
| Isola Tiberina | 4 | Primo a costruire su una colonna fiume a livello 2+. |  |  |
| Catacombe | 5 | Primo ad avere 3 edifici sotterrati nella stessa colonna. |  |  |

## Le 16 Eredità

Due a testa, se ne tiene una segreta; si conta a fine partita.

| carta | PV | condizione | motivo | nota |
|---|--:|---|---|---|
| L’Archeologo | 5 | 4+ tuoi edifici Sotterrati. |  |  |
| Il Costruttore di cattedrali | 4 | 3+ tuoi edifici Religione, in qualsiasi stato. |  |  |
| Il Verticalista | 4 | hai costruito un edificio a livello 4 o superiore. |  | resta: il nome ricorda un canale che non c'è più, la condizione vale |
| Il Geografo | 4 | tuoi edifici su tutti e quattro i terreni. |  |  |
| Il Colonizzatore | 4 | tuoi edifici in 5+ colonne diverse. |  |  |
| Il Mecenate | 4 | 4+ potenziamenti collocati sui tuoi edifici, inclusi quelli poi Sotterrati. |  |  |
| Il Condottiero | 4 | 3+ tuoi edifici Militari in piedi. |  |  |
| Il Cronista | 5 | tuoi edifici di tutte e cinque le ere. |  |  |
| Il Guardiano | 5 | **un tuo edificio attivo costruito nell'era 1 o 2.** | RUD | oggi: "un tuo edificio in piedi costruito nell’era 1 o 2" |
| Il Lastricatore | 4 | tuoi edifici in 3 colonne consecutive. |  |  |
| Il Demolitore | 4 | hai spianato 3+ tuoi edifici intatti. |  | resta: lo spianato è il terrapieno della v2 (registro 87) |
| Il Massaio | 4 | due tuoi edifici a livello 2 o superiore. |  |  |
| L’Idraulico | 4 | 3+ tuoi edifici su colonne fiume. |  |  |
| Il Silvicoltore | 5 | **un tuo edificio attivo su bosco costruito nell'era 1 o 2.** | RUD TES | oggi: "un tuo edificio su bosco con Vetustà 3+" — registro 99: contava la Vetustà 3, ora è il vecchio del bosco (nel file v2) |
| Il Restauratore | 4 | **hai ristrutturato 2+ tue rovine.** | RUD | oggi: "hai restaurato 2+ ruderi" |
| L’Antiquario | 5 | un tuo edificio Sotterrato con Scavo 6 o più. |  |  |

## Quello che non sta su una carta

- **"+1 per ogni edificio altrui sotterrato"** (il disturbo): tolto dal designer (registro 100), non c'è più né nel regolamento né nel motore.
- **La Vetustà non esiste più** (registro 95): niente cubetti a chi regge l'evento, la Rendita è solo quella stampata. Colosseo, Il Silvicoltore e Speculazione edilizia la contavano e sono stati rifatti (registro 99, nel file v2); il bosco perde il +4.
- **"Cultura"**: oggi è un canale di punti e il nome di una classe; con le Idee come risorsa i punti si chiamano PV e Cultura resta la classe.
- **"Protetto"**: come oggi, il lavoratore messo sopra un proprio edificio in piedi della colonna attivata (+2); i tre protettori del draft si legano al primo edificio costruito nell'era.
- **Reclutare** non è un'azione; **la Dinastia** resta un acquisto al posto dell'azione; **passare** è non fare l'azione dopo l'attivazione.
- **Gli scheletri** (registri 95-96): il Personaggio del draft non si seppellisce; lo scheletro è il lavoratore che piazza un potenziamento, che resta sotto l'edificio (uno per edificio, non nell'era Moderna) e vale 6 meno l'era **comunque finisca l'edificio**.

