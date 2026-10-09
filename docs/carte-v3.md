# Le carte della v3, tutte in un documento

> Generato da `tools/carte_v3.py` da `data/proposte/cards-v3-era1.json`, che è quello che gioca il
> motore e che `tools/genera_cards_v3.py` scrive. Per ogni carta c'è tutto quello che serve per
> rifarla: numeri e testo. Se una carta cambia, si cambia il generatore, si rigenera il JSON e si
> rigenera questo documento. I PDF in `materiali/` servono solo per la grafica.

Le regole della v3 che le carte presuppongono (registri 153-179, `docs/proposte/v3-metro.md`):
tre risorse, Costruzione (C), Denaro (D), Idee (I), che **muoiono a fine era** (ere 1-4); i
**Personaggi sono i lavoratori**: a inizio era il draft a passaggio (mano di 4, se ne tiene una, le
altre passano al vicino), poi ognuno piazza i suoi 4 Personaggi, uno per turno, su una colonna;
chi attiva incassa la tessera, poi la **produzione e l'azione del Personaggio**, poi **usa UN edificio**
in piedi della colonna, suo o altrui, che resta bruciato fino a fine giro; dopo compra: un edificio,
un potenziamento, o tutti e due. Catena dei costi: i terreni producono zero, spianare costa
1 per casella e solo edifici di ere passate; il ⊕ apre un acquisto in più con lo sconto; lo
sconto senza condizione vale su quel che si compra nel turno. Costanti: `workers_base` 4, `personaggi_per_era` 16, `market_size` 6, `rails` 5, `spianare_costo` 1, `terrapieno_cost_pietra` 1, `azione_edificio` scelta.

## I 74 edifici (60 nel mazzo, 14 case della riserva)

Ogni edificio è la sua carta distesa sulla casella (colonna x binario). Costo in C/D/I; "caselle"
quante ne occupa; Lampo **o** Rendita, mai tutti e due (il Lampo vale il costo in Costruzione per
le carte del mazzo delle ere 3-5); lo Scavo è quello stampato; "dove" dice se va a terra o solo
sopra; l'azione la usa chi attiva la colonna ("Usa:"), i finali si contano a fine partita. Le case
della riserva (**RIS**) sono sempre disponibili in 2 copie, senza azione; la piccola si paga in
Costruzione o Denaro (◈).

Domanda del mazzo per era (C / D / I): era 1: 14 / 5 / 5 · era 2: 19 / 7 / 6 · era 3: 20 / 10 / 8 · era 4: 23 / 10 / 8 · era 5: 23 / 7 / 4.

### Era 1

| edificio | classi | terreno | caselle | costo | res | Lampo | Rendita | Scavo | dove | azione e finali |
|---|---|---|---|---|--:|--:|--:|--:|---|---|
| Approdo | Commercio | Fiume | 1 | 1 C 1 I ◈ | 1 | 0 | 0 | 2 | a terra o sopra | Usa: +1 Denaro. |
| Capanne | Civico | Pianura | 1 | 1 C 1 I | 1 | 1 | 0 | 2 | a terra o sopra | Usa: puoi comprare ancora un potenziamento o una casa, e paghi 1 in meno. |
| Cava | Commercio | Pianura | 1 | 1 C 1 I ◈ | 1 | 0 | 0 | 2 | a terra o sopra | Usa: puoi comprare ancora un potenziamento o una casa, e paghi 1 in meno. |
| Circolo di pietre | Religione | qualsiasi | 1 col. x 2 bin. | 2 C 1 D 1 I | 4 | 0 | 2 | 5 | a terra o sopra | Usa: +1 PV se hai 2+ edifici Religione in piedi. |
| Dolmen | Religione | Collina | 1 | 1 C 1 D | 3 | 0 | 1 | 3 | a terra o sopra | Usa: +1 resistenza fino a fine era a un tuo edificio adiacente. |
| Focolare comune | Civico | Pianura | 1 | 1 C | 1 | 1 | 0 | 2 | a terra o sopra | Usa: +1 Costruzione. |
| Grotte dipinte | Cultura | Collina | 1 | 1 C 1 D | 2 | 0 | 0 | 6 | a terra o sopra | Usa: +1 Idea. |
| Menhir | Religione | Bosco | 1 | 1 C 1 D | 4 | 0 | 1 | 3 | a terra o sopra | Usa: +1 Idea. |
| Palafitte | Civico | Fiume | 1 | 1 C 1 I | 2 | 1 | 0 | 2 | a terra o sopra | Usa: +1 Denaro. |
| Trappole da pesca | Ingegneria | Fiume | 1 | 1 C ◈ | 1 | 0 | 0 | 0 | a terra o sopra | Usa: -1 a quel che compri in questo turno. |
| Tumulo funerario | Religione, Cultura | Collina | 2 col. x 1 bin. | 1 C 1 D | 3 | 1 | 0 | 5 | a terra o sopra | Usa: +1 Scavo permanente a un tuo edificio adiacente. |
| Villaggio palizzato | Militare | Pianura | 1 col. x 2 bin. | 2 C | 2 | 2 | 0 | 3 | a terra o sopra | Usa: +1 resistenza fino a fine era ai tuoi edifici adiacenti. |
| Capanne di fango **RIS** | Civico | qualsiasi | 1 | 1 C | 2 | 1 | 0 | 1 | a terra o sopra | — |
| Case di pietra **RIS** | Civico | qualsiasi | 1 | 2 C | 2 | 2 | 0 | 1 | a terra o sopra | — |
| Ripari **RIS** | Civico | qualsiasi | 1 | 1 C ◈ | 1 | 1 | 0 | 2 | a terra o sopra | — |

### Era 2

| edificio | classi | terreno | caselle | costo | res | Lampo | Rendita | Scavo | dove | azione e finali |
|---|---|---|---|---|--:|--:|--:|--:|---|---|
| Acquedotto | Ingegneria | Fiume | 3 col. x 1 bin. | 2 C 1 D 1 I ◈ | 4 | 0 | 2 | 3 | a terra o sopra | Usa: +1 Idea. |
| Anfiteatro | Cultura | qualsiasi | 2 col. x 2 bin. | 3 C 1 D 1 I | 5 | 0 | 2 | 6 | a terra o sopra | Usa: +1 PV. |
| Castrum | Militare | Pianura | 1 col. x 2 bin. | 2 C | 4 | 2 | 0 | 3 | a terra o sopra | Usa: +1 resistenza fino a fine era ai tuoi edifici in questa colonna. |
| Emporio | Commercio | Fiume | 1 | 1 C 1 I ◈ | 2 | 2 | 0 | 2 | a terra o sopra | Usa: +1 Denaro. |
| Foro | Commercio, Civico | Pianura | 1 col. x 2 bin. | 2 C 1 D 1 I | 3 | 0 | 2 | 5 | a terra o sopra | Usa: +1 Denaro per ogni altro giocatore con un edificio in questa colonna (max 2). |
| Insulae | Civico | Pianura | 1 | 1 C 1 I | 2 | 2 | 0 | 2 | a terra o sopra | Usa: -1 a quel che compri in questo turno. |
| Ponte | Ingegneria | Fiume | 2 col. x 1 bin. | 2 C 1 D ◈ | 3 | 0 | 1 | 3 | a terra o sopra | Usa: +1 Costruzione. |
| Sacello | Religione | Collina | 1 | 1 C 1 D | 2 | 1 | 0 | 3 | a terra o sopra | Usa: +1 resistenza fino a fine era a un tuo edificio adiacente. |
| Teatro | Cultura | qualsiasi | 1 | 1 C 1 D | 3 | 2 | 0 | 5 | a terra o sopra | Usa: +1 PV. |
| Tempio | Religione | Collina | 1 | 1 C 1 D | 3 | 0 | 1 | 3 | a terra o sopra | Usa: +1 PV se hai 2+ edifici Religione in piedi. |
| Terme | Civico | qualsiasi | 1 | 1 C 1 I | 2 | 2 | 0 | 3 | a terra o sopra | Usa: -1 a quel che compri in questo turno. |
| Torre di vedetta | Militare | Collina | 1 | 2 C | 3 | 2 | 0 | 2 | a terra o sopra | Usa: +1 resistenza fino a fine era ai tuoi edifici adiacenti. |
| Case a schiera **RIS** | Civico | qualsiasi | 1 | 1 C | 3 | 1 | 0 | 1 | a terra o sopra | — |
| Domus **RIS** | Civico | qualsiasi | 1 | 2 C | 3 | 2 | 0 | 1 | a terra o sopra | — |
| Tuguri **RIS** | Civico | qualsiasi | 1 | 1 C ◈ | 2 | 1 | 0 | 2 | a terra o sopra | — |

### Era 3

| edificio | classi | terreno | caselle | costo | res | Lampo | Rendita | Scavo | dove | azione e finali |
|---|---|---|---|---|--:|--:|--:|--:|---|---|
| Abbazia | Religione, Commercio | Bosco | 1 col. x 2 bin. | 2 C 1 D 1 I | 3 | 0 | 2 | 5 | a terra o sopra | Usa: +1 Idea. |
| Arsenale | Militare | Fiume | 1 col. x 2 bin. | 3 C | 3 | 3 | 0 | 2 | a terra o sopra | Usa: +1 resistenza fino a fine era ai tuoi edifici adiacenti. |
| Borgo | Civico | Pianura | 1 | 1 C 1 D 1 I | 3 | 2 | 0 | 2 | a terra o sopra | Usa: +1 PV se hai un altro Civico in piedi in questa colonna. |
| Cappella | Religione | qualsiasi | 1 | 1 C 1 D 1 I | 3 | 2 | 0 | 3 | a terra o sopra | Usa: +1 resistenza fino a fine era a un tuo edificio adiacente. |
| Castello | Militare | Collina | 2 col. x 2 bin. | 3 C 1 D | 4 | 0 | 2 | 3 | a terra o sopra | Usa: +1 resistenza fino a fine era ai tuoi edifici in questa colonna. |
| Chiesa | Religione, Cultura | qualsiasi | 1 | 2 C 1 D | 3 | 0 | 1 | 3 | a terra o sopra | Usa: +1 PV se hai 2+ edifici Religione in piedi. |
| Conceria | Commercio | Fiume | 1 | 1 C 1 D 1 I ◈ | 2 | 1 | 0 | 0 | a terra o sopra | Usa: +1 Denaro. |
| Mercato | Commercio | Fiume | 1 | 1 C 1 D 1 I ◈ | 3 | 1 | 0 | 2 | a terra o sopra | Usa: -1 a quel che compri in questo turno. |
| Mulino | Ingegneria, Commercio | Pianura | 1 | 1 C 1 D 1 I | 3 | 1 | 0 | 2 | a terra o sopra | Usa: -1 a quel che compri in questo turno. |
| Mura | Militare | qualsiasi | 1 | 2 C 1 D | 4 | 2 | 0 | 2 | a terra o sopra | Usa: +1 resistenza fino a fine era ai tuoi edifici adiacenti. |
| Ospedale dei pellegrini | Civico | qualsiasi | 1 | 2 C 1 I | 3 | 2 | 0 | 2 | a terra o sopra | Usa: +1 resistenza fino a fine era a un tuo edificio adiacente. |
| Torre civica | Civico | qualsiasi | 1 | 1 C 1 D 1 I | 3 | 2 | 0 | 2 | a terra o sopra | Usa: +1 PV se hai un altro Civico in piedi in questa colonna. |
| Casa torre **RIS** | Civico | qualsiasi | 1 | 2 C | 3 | 2 | 0 | 1 | a terra o sopra | — |
| Case di legno **RIS** | Civico | qualsiasi | 1 | 1 C | 2 | 1 | 0 | 1 | a terra o sopra | — |
| Casupole **RIS** | Civico | qualsiasi | 1 | 1 C ◈ | 2 | 1 | 0 | 2 | a terra o sopra | — |

### Era 4

| edificio | classi | terreno | caselle | costo | res | Lampo | Rendita | Scavo | dove | azione e finali |
|---|---|---|---|---|--:|--:|--:|--:|---|---|
| Accademia | Cultura | qualsiasi | 1 | 2 C 1 D | 2 | 2 | 0 | 3 | a terra o sopra | Usa: +1 Scavo permanente a un tuo edificio in questa colonna. |
| Banco | Commercio | qualsiasi | 1 | 1 C 1 D 1 I ◈ | 2 | 1 | 0 | 0 | a terra o sopra | Usa: -1 a quel che compri in questo turno. |
| Bottega d'artista | Cultura | qualsiasi | 1 | 1 C 1 D 1 I | 2 | 1 | 0 | 2 | a terra o sopra | Usa: -1 a quel che compri in questo turno. |
| Duomo | Religione, Cultura | qualsiasi | 1 col. x 2 bin. | 3 C 2 D | 4 | 0 | 2 | 5 | solo sopra, liv. 2 | Usa: +1 PV se hai 2+ edifici Religione in piedi. |
| Fortezza bastionata | Militare, Ingegneria | Collina | 2 col. x 2 bin. | 3 C 1 D | 5 | 0 | 2 | 2 | a terra o sopra | Usa: +1 resistenza fino a fine era ai tuoi edifici in questa colonna. |
| Giardino all'italiana | Cultura | Collina | 1 | 1 C 1 D 1 I | 1 | 1 | 0 | 0 | a terra o sopra | Usa: +1 PV. |
| Loggia | Civico | qualsiasi | 1 | 1 C 1 D 1 I | 2 | 1 | 0 | 2 | a terra o sopra | Usa: -1 a quel che compri in questo turno. |
| Osservatorio | Ingegneria | Collina | 1 | 2 C 1 D ◈ | 2 | 2 | 0 | 2 | a terra o sopra | Usa: +1 Idea. A fine partita, se e' in piedi: +2 PV. |
| Palazzo signorile | Civico | Pianura | 1 | 2 C 1 I | 3 | 2 | 0 | 3 | a terra o sopra | Usa: +1 PV se hai un altro Civico in piedi in questa colonna. |
| Piazza monumentale | Civico | Pianura | 1 col. x 2 bin. | 2 C 2 I | 3 | 0 | 2 | 3 | solo sopra, liv. 1 | Usa: +1 Denaro per ogni altro giocatore con un edificio qui (max 2). A fine partita: +1 PV per ogni tuo edificio in piedi nelle sue colonne. |
| Ponte monumentale | Ingegneria | Fiume | 2 col. x 1 bin. | 3 C 1 D ◈ | 4 | 0 | 2 | 3 | a terra o sopra | Usa: +1 Costruzione. |
| Villa | Civico | Collina | 1 | 2 C 1 I | 3 | 2 | 0 | 3 | a terra o sopra | Usa: +1 PV. |
| Casa borghese **RIS** | Civico | qualsiasi | 1 | 2 C | 2 | 1 | 0 | 1 | a terra o sopra | — |
| Case popolari **RIS** | Civico | qualsiasi | 1 | 1 C ◈ | 2 | 1 | 0 | 2 | a terra o sopra | — |
| Palazzetto **RIS** | Civico | qualsiasi | 1 | 3 C | 3 | 1 | 0 | 1 | a terra o sopra | — |

### Era 5

| edificio | classi | terreno | caselle | costo | res | Lampo | Rendita | Scavo | dove | azione e finali |
|---|---|---|---|---|--:|--:|--:|--:|---|---|
| Biblioteca | Cultura | qualsiasi | 1 | 2 C 1 D | 3 | 2 | 0 | 0 | a terra o sopra | Usa: +1 PV. A fine partita: +1 PV per ogni classe diversa fra i tuoi edifici. |
| Caffè letterario | Cultura | qualsiasi | 1 | 1 C 1 D | 2 | 1 | 0 | 0 | a terra o sopra | Usa: -1 a quel che compri in questo turno. A fine partita: +1 PV se e' adiacente a un edificio Cultura. |
| Condominio | Civico | qualsiasi | 1 | 1 C 1 I | 3 | 1 | 0 | 0 | a terra o sopra | Usa: +1 PV se hai un altro Civico in piedi in questa colonna. A fine partita: +1 PV per ogni tuo Civico in piedi (max 4). |
| Fondazione d'arte | Cultura | qualsiasi | 1 | 1 C 1 D | 3 | 1 | 0 | 0 | a terra o sopra | Usa: +1 PV. A fine partita: +1 PV per ogni tuo potenziamento. |
| Grattacielo | Commercio | qualsiasi | 1 col. x 3 bin. | 2 C 1 I ◈ | 3 | 2 | 0 | 0 | a terra o sopra | Usa: +1 Denaro per ogni altro giocatore con un edificio qui (max 2). A fine partita: +1 PV per ogni livello a cui e' costruito; ogni edificio altrui in cima a una colonna adiacente toglie 1 PV al suo proprietario. |
| Monumento ai caduti | Militare, Religione | qualsiasi | 1 | 2 C 1 D | 3 | 2 | 0 | 0 | a terra o sopra | Usa: +1 resistenza fino a fine era ai tuoi edifici adiacenti. A fine partita: +1 PV per ogni altro tuo Militare. |
| Museo | Cultura | qualsiasi | 1 | 2 C 1 D | 3 | 2 | 0 | 0 | solo sopra, liv. 1 | Usa: +1 Scavo permanente a un tuo edificio in questa colonna. A fine partita: +2 PV per ogni tua rovina riscoperta (max 6). |
| Officina | Ingegneria | qualsiasi | 1 | 2 C ◈ | 3 | 2 | 0 | 0 | a terra o sopra | Usa: -1 a quel che compri in questo turno. A fine partita: +1 PV per ogni altro tuo Ingegneria (max 4). |
| Parco archeologico | Cultura | qualsiasi | 1 col. x 2 bin. | 2 C 1 D | 3 | 2 | 0 | 0 | a terra o sopra | Usa: +1 Scavo permanente a un tuo edificio adiacente. A fine partita: fino a 2 tuoi edifici non sotterrati nelle colonne adiacenti valgono il loro Scavo come se fossero sotterrati. |
| Ponte in acciaio | Ingegneria | Fiume | 2 col. x 1 bin. | 3 C ◈ | 4 | 3 | 0 | 0 | a terra o sopra | Usa: +1 Costruzione. A fine partita: +2 PV per ogni tua rovina riportata alla luce nelle sue colonne. |
| Stazione | Commercio, Ingegneria | qualsiasi | 3 col. x 1 bin. | 3 C 1 I | 4 | 3 | 0 | 0 | a terra o sopra | Usa: +1 Costruzione. A fine partita: +1 PV per ogni edificio in piedi nelle sue colonne (max 5). |
| Università | Cultura, Civico | qualsiasi | 1 col. x 2 bin. | 2 C 1 D 1 I | 3 | 2 | 0 | 0 | solo sopra, liv. 1 | Usa: +1 PV. Solo sopra, al livello 1 o piu'. A fine partita: +1 PV per ogni tuo Personaggio con Scavo 5 o piu' (max 5). |
| Condominio popolare **RIS** | Civico | qualsiasi | 1 | 3 C | 4 | 1 | 0 | 1 | a terra o sopra | — |
| Palazzina **RIS** | Civico | qualsiasi | 1 | 1 C ◈ | 3 | 1 | 0 | 1 | a terra o sopra | — |

## I 80 Personaggi (16 per era)

Sono i lavoratori. Ogni Personaggio ha una **produzione** (quel che incassi quando lo piazzi) e
un'**azione** (scatta subito dopo, nella colonna attivata). Lo **Scavo** è il valore dello
scheletro: ogni Personaggio ha la sua tessera scavo, con nome e Scavo, che entra nel sacchetto quando
viene reclutato; quando un edificio va in rovina si pescano dal sacchetto tante tessere quante le sue
caselle, coperte; una tessera riportata alla luce nell'era 5 paga il suo Scavo a chi ha reclutato quel
Personaggio, chiunque abbia scavato. Il ⊕ è l'acquisto in più, con lo sconto dentro.

### Era 1

| Personaggio | classe | produce | Scavo | azione |
|---|---|---|--:|---|
| Capotribù | Civico | 1 C | 3 | In questo turno puoi comprare ancora un potenziamento o una casa, e paghi 1 in meno. |
| Anziana del villaggio | Civico | 1 C | 3 | Cambia 1 risorsa in un'altra. |
| Cacciatore | Civico | 1 C | 2 | +1 Lampo all'edificio che costruisci in questo turno. |
| Sciamano | Religione | 1 I | 5 | +1 PV se hai un edificio Religione in piedi in questa colonna. |
| Guardiano del fuoco | Religione | 1 I | 5 | −1 al costo dell'edificio Religione che costruisci in questo turno. |
| Custode delle ossa | Religione | 1 I | 6 | Il potenziamento che compri in questo turno costa 1 in meno. |
| Mercante di ossidiana | Commercio | 1 D | 6 | In questo turno puoi comprare ancora un potenziamento o una casa, e paghi 1 in meno. |
| Barattatore | Commercio | 1 D + 1 I | 5 | Nessuna azione. |
| Portatore di sale | Commercio | 1 D | 4 | +1 Denaro per ogni altro giocatore con un edificio in questa colonna (max 2). |
| Incisore | Cultura | 1 I | 4 | +2 Scavo permanente a un tuo edificio in questa colonna. |
| Cantastorie | Cultura | 1 I | 3 | +1 PV. |
| Pittore delle grotte | Cultura | 1 I | 5 | Il potenziamento Arte che compri in questo turno costa 1 in meno. |
| Costruttore di zattere | Ingegneria | 1 C | 3 | −1 Costruzione se costruisci su fiume in questo turno. |
| Tagliapietre | Ingegneria | 1 C | 2 | −1 Costruzione alla costruzione di questo turno. |
| Guerriero | Militare | 1 C | 2 | +2 resistenza fino a fine era all'edificio su cui sta. |
| Sentinella | Militare | 1 D | 4 | +1 resistenza fino a fine era a ogni tuo edificio in questa colonna. |

### Era 2

| Personaggio | classe | produce | Scavo | azione |
|---|---|---|--:|---|
| Console | Civico | 1 D | 3 | +1 PV se hai un edificio Civico in piedi in questa colonna. |
| Edile | Civico | 1 C | 3 | In questo turno puoi comprare ancora un potenziamento o una casa, e paghi 1 in meno. |
| Tribuno della plebe | Civico | 1 C | 2 | Cambia 1 risorsa in un'altra. |
| Sacerdotessa | Religione | 1 I | 5 | −1 al costo dell'edificio Religione che costruisci in questo turno. |
| Augure | Religione | 1 C | 4 | +1 resistenza fino a fine era a un tuo edificio in questa colonna. |
| Pontefice | Religione | 1 C | 5 | +1 PV se hai 2+ edifici Religione in piedi. |
| Negotiator | Commercio | 1 D | 4 | +1 Denaro per ogni altro giocatore con un edificio in questa colonna (max 2). |
| Armatore | Commercio | 1 C + 1 D | 5 | Nessuna azione. |
| Argentario | Commercio | 1 D | 6 | In questo turno puoi comprare ancora un potenziamento o una casa, e paghi 1 in meno. |
| Retore | Cultura | 1 I | 4 | +2 Scavo permanente a un tuo edificio in questa colonna. |
| Poeta | Cultura | 1 I | 3 | +1 PV. |
| Mosaicista | Cultura | 1 I | 5 | Il potenziamento Arte che compri in questo turno costa 1 in meno. |
| Architetto | Ingegneria | 1 C | 2 | −1 Costruzione alla costruzione di questo turno. |
| Agrimensore | Ingegneria | 1 C | 3 | Prendi anche la produzione della tessera di una colonna accanto. |
| Legionario | Militare | 1 C | 2 | +2 resistenza fino a fine era all'edificio su cui sta. |
| Centurione | Militare | 1 C | 4 | +1 resistenza fino a fine era a ogni tuo edificio in questa colonna. |

### Era 3

| Personaggio | classe | produce | Scavo | azione |
|---|---|---|--:|---|
| Cronista | Civico | 1 C | 3 | +1 PV se hai un edificio Civico in piedi in questa colonna. |
| Podesta' | Civico | 1 C | 3 | In questo turno puoi comprare ancora un potenziamento o una casa, e paghi 1 in meno. |
| Borgomastro | Civico | 1 C | 2 | Cambia 1 risorsa in un'altra. |
| Vescovo | Religione | 1 I | 5 | -1 al costo dell'edificio Religione che costruisci in questo turno. |
| Abate | Religione | 1 C | 4 | +1 resistenza fino a fine era a un tuo edificio in questa colonna. |
| Frate predicatore | Religione | 1 C | 5 | +1 PV se hai 2+ edifici Religione in piedi. |
| Mercante | Commercio | 1 D | 4 | +1 Denaro per ogni altro giocatore con un edificio in questa colonna (max 2). |
| Cambiatore | Commercio | 1 C + 1 D | 5 | Nessuna azione. |
| Speziale | Commercio | 1 D | 6 | Il potenziamento che compri in questo turno costa 1 in meno. |
| Miniatore | Cultura | 1 I | 5 | Il potenziamento Arte che compri in questo turno costa 1 in meno. |
| Trovatore | Cultura | 1 C | 3 | +1 PV. |
| Maestro vetraio | Cultura | 1 I | 4 | +2 Scavo permanente a un tuo edificio in questa colonna. |
| Mastro costruttore | Ingegneria | 1 C | 2 | -1 Costruzione alla costruzione di questo turno. |
| Capomastro | Ingegneria | 1 C | 3 | Prendi anche la produzione della tessera di una colonna accanto. |
| Cavaliere | Militare | 1 C | 2 | +2 resistenza fino a fine era all'edificio su cui sta. |
| Balestriere | Militare | 1 C | 4 | +1 resistenza fino a fine era a ogni tuo edificio in questa colonna. |

### Era 4

| Personaggio | classe | produce | Scavo | azione |
|---|---|---|--:|---|
| Gonfaloniere | Civico | 1 C | 3 | +1 PV se hai un edificio Civico in piedi in questa colonna. |
| Provveditore | Civico | 1 C | 3 | In questo turno puoi comprare ancora un potenziamento o una casa, e paghi 1 in meno. |
| Notaio | Civico | 1 C | 2 | Cambia 1 risorsa in un'altra. |
| Cardinale | Religione | 1 I | 5 | -1 al costo dell'edificio Religione che costruisci in questo turno. |
| Priore | Religione | 1 C | 4 | +1 resistenza fino a fine era a un tuo edificio in questa colonna. |
| Predicatore | Religione | 1 C | 5 | +1 PV se hai 2+ edifici Religione in piedi. |
| Banchiere | Commercio | 1 D | 4 | +1 Denaro per ogni altro giocatore con un edificio in questa colonna (max 2). |
| Mercante veneziano | Commercio | 1 C + 1 D | 5 | Nessuna azione. |
| Orafo | Commercio | 1 D | 6 | Il potenziamento che compri in questo turno costa 1 in meno. |
| Mecenate | Cultura | 1 I | 5 | Il potenziamento Arte che compri in questo turno costa 1 in meno. |
| Umanista | Cultura | 1 C | 3 | +1 PV. |
| Artista di corte | Cultura | 1 I | 4 | +2 Scavo permanente a un tuo edificio in questa colonna. |
| Ingegnere idraulico | Ingegneria | 1 C | 2 | -1 Costruzione alla costruzione di questo turno. |
| Cartografo | Ingegneria | 1 C | 3 | Prendi anche la produzione della tessera di una colonna accanto. |
| Ingegnere militare | Militare | 1 C | 2 | +2 resistenza fino a fine era all'edificio su cui sta. |
| Condottiero | Militare | 1 C | 4 | +1 resistenza fino a fine era a ogni tuo edificio in questa colonna. |

### Era 5

| Personaggio | classe | produce | Scavo | azione |
|---|---|---|--:|---|
| Sindaco | Civico | 1 C | 3 | +1 PV se hai un edificio Civico in piedi in questa colonna. |
| Urbanista | Civico | 1 C | 3 | In questo turno puoi comprare ancora un potenziamento o una casa, e paghi 1 in meno. |
| Assessore | Civico | 1 C | 2 | Cambia 1 risorsa in un'altra. |
| Parroco | Religione | 1 I | 5 | -1 al costo dell'edificio Religione che costruisci in questo turno. |
| Sagrestano | Religione | 1 C | 4 | +1 resistenza fino a fine era a un tuo edificio in questa colonna. |
| Missionario | Religione | 1 C | 5 | +1 PV se hai 2+ edifici Religione in piedi. |
| Industriale | Commercio | 1 D | 4 | +1 Denaro per ogni altro giocatore con un edificio in questa colonna (max 2). |
| Imprenditore | Commercio | 1 C + 1 D | 5 | Nessuna azione. |
| Commercialista | Commercio | 1 D | 6 | Il potenziamento che compri in questo turno costa 1 in meno. |
| Archeologo | Cultura | 1 I | 5 | Il potenziamento Arte che compri in questo turno costa 1 in meno. |
| Scrittore | Cultura | 1 C | 3 | +1 PV. |
| Restauratore | Cultura | 1 I | 4 | +2 Scavo permanente a un tuo edificio in questa colonna. |
| Soprintendente | Ingegneria | 1 C | 2 | -1 Costruzione alla costruzione di questo turno. |
| Geometra | Ingegneria | 1 C | 3 | Prendi anche la produzione della tessera di una colonna accanto. |
| Veterano | Militare | 1 C | 2 | +2 resistenza fino a fine era all'edificio su cui sta. |
| Carabiniere | Militare | 1 C | 4 | +1 resistenza fino a fine era a ogni tuo edificio in questa colonna. |

Fuori dal draft: Dinastia (Sempre disponibile fuori dalle file, nessuna classe richiesta. Costo a scalare in Idee: era 1 = 4 · era 2 = 3 · era 3 = 3 · era 4 = 3. Nessuna abilita': aggiunge un quarto lavoratore, permanente e attivo da subito. Massimo una a testa.).

## I 50 potenziamenti

Si comprano insieme a una costruzione o da soli; il costo è nella risorsa della famiglia (Arte in
Idee, Struttura in Costruzione, il resto in Denaro). Lo **Scavo** del token Arte è quel che vale
se un'icona arte lo ritrova a fine partita. Quando l'edificio va in rovina il token torna al
proprietario.

| era | potenziamento | famiglia | costo | Scavo | testo |
|--:|---|---|---|--:|---|
| 1 | Focolare | Altro | 1 D | — | Quando attivi l'edificio: +1 Idea. |
| 1 | Granaio comune | Altro | 1 D | — | Quando attivi l'edificio: +1 Costruzione. |
| 1 | Ossario | Altro | 1 D | — | L'edificio ha +2 Scavo. |
| 1 | Recinto per il bestiame | Altro | 1 D | — | Quando attivi l'edificio: +1 Denaro. |
| 1 | Idolo | Arte | 1 I | 3 | Subito: +1 PV. |
| 1 | Pittura rupestre | Arte | 1 I | 3 | Subito: +1 PV. L'edificio ha +2 Scavo. |
| 1 | Totem | Arte | 1 I | 3 | Subito: +1 PV. |
| 1 | Argine | Struttura | 1 C | — | L'edificio ha +1 Resistenza. |
| 1 | Fondamenta in pietra | Struttura | 1 C | — | L'edificio ha +1 Resistenza. |
| 1 | Palizzata | Struttura | 1 C | — | L'edificio ha +1 Resistenza. |
| 2 | Banchina | Altro | 1 D | — | Quando attivi l'edificio, se tocca il Fiume: +1 Denaro. |
| 2 | Iscrizione | Altro | 1 D | — | L'edificio ha +2 Scavo. |
| 2 | Lapide funeraria | Altro | 1 D | — | A fine partita: +2 Scavo a ogni edificio sotterrato sotto l'edificio. |
| 2 | Mulino ad acqua | Altro | 1 D | — | Quando attivi l'edificio, se tocca il Fiume: +1 Costruzione. |
| 2 | Terme private | Altro | 1 D | — | Quando attivi l'edificio: +1 Idea. |
| 2 | Altare | Arte | 1 I | 3 | Subito: +1 PV. L'edificio ha +2 Scavo. |
| 2 | Mosaico | Arte | 1 I | 3 | Subito: +1 PV. |
| 2 | Statua | Arte | 1 I | 4 | Subito: +2 PV. |
| 2 | Bastioni | Struttura | 1 C | — | L'edificio ha +1 Resistenza. |
| 2 | Mura di cinta | Struttura | 1 C | — | L'edificio ha +1 Resistenza. |
| 3 | Campanile | Altro | 1 D | — | Subito: +1 PV. L'edificio ha +1 Resistenza. |
| 3 | Portico | Altro | 1 D | — | Quando attivi l'edificio: +1 Denaro. |
| 3 | Stalli mercantili | Altro | 1 D | — | L'edificio ha +1 Rendita. |
| 3 | Reliquia | Arte | 1 I | 3 | Subito: +1 PV. |
| 3 | Stemma di famiglia | Arte | 1 I | 3 | Subito: +1 PV. |
| 3 | Vetrata | Arte | 1 I | 3 | Subito: +1 PV. L'edificio ha +2 Scavo. |
| 3 | Arco rampante | Struttura | 1 C | — | L'edificio ha +1 Resistenza e conta anche come Religione. |
| 3 | Contrafforte | Struttura | 1 C | — | L'edificio ha +1 Resistenza. |
| 3 | Merlatura | Struttura | 1 C | — | L'edificio ha +1 Resistenza e conta anche come Militare. |
| 3 | Torre di guardia | Struttura | 1 C | — | L'edificio ha +1 Resistenza. |
| 4 | Cupola | Altro | 2 D | — | Subito: +2 PV. L'edificio ha +1 Resistenza. |
| 4 | Loggia | Altro | 2 D | — | Subito: +1 PV. L'edificio ha +1 Rendita. |
| 4 | Stamperia | Altro | 2 D | — | Quando attivi l'edificio: +2 Idee. |
| 4 | Affreschi | Arte | 2 I | 4 | Subito: +2 PV. |
| 4 | Fontana monumentale | Arte | 2 I | 4 | Subito: +2 PV. L'edificio ha +2 Scavo. |
| 4 | Giardino pensile | Arte | 2 I | 4 | Subito: +2 PV. |
| 4 | Opera d'arte | Arte | 2 I | 5 | Subito: +3 PV. |
| 4 | Pala d'altare | Arte | 2 I | 4 | Subito: +2 PV. |
| 4 | Bastione a stella | Struttura | 2 C | — | L'edificio ha +2 Resistenza. |
| 4 | Cannoniere | Struttura | 2 C | — | L'edificio ha +1 Resistenza. |
| 5 | Archivio storico | Altro | 2 D | — | L'edificio ha +3 Scavo. |
| 5 | Ascensore panoramico | Altro | 2 D | — | Subito: +2 PV. |
| 5 | Boutique | Altro | 2 D | — | Quando attivi l'edificio: +2 Denaro. |
| 5 | Memoriale | Altro | 2 D | — | Subito: +2 PV. |
| 5 | Pannelli solari | Altro | 2 D | — | Quando attivi l'edificio: +2 Costruzione. |
| 5 | Targa storica | Altro | 2 D | — | A fine partita: +2 Scavo a ogni edificio sotterrato sotto l'edificio. |
| 5 | Terrazza panoramica | Altro | 2 D | — | Subito: +1 PV. |
| 5 | Installazione | Arte | 2 I | 5 | Subito: +3 PV. |
| 5 | Murale | Arte | 2 I | 4 | Subito: +2 PV. |
| 5 | Cemento armato | Struttura | 2 C | — | L'edificio ha +2 Resistenza. |

## Le 35 tessere dell'era (2 copie ciascuna)

I terreni producono zero (la catena dei costi); a ogni era si posa su ogni colonna una tessera che
produce a chi attiva e ha un effetto, una volta per era. Quattro tessere dell'era 1 e quattro per
era dalle 3 in su non producono: hanno l'effetto più forte.

| era | tessera | produce | effetto, una volta per era |
|--:|---|---|---|
| 1 | Campi arati | 1 C | Il primo edificio da 2 o 3 caselle costruito qui costa 1 Costruzione in meno. |
| 1 | Luogo sacro | 1 I | Il primo edificio Religione costruito qui costa 1 Idea in meno. |
| 1 | Raccoglitori | 1 C | Chi attiva per primo può cambiare 1 Costruzione in 1 Idea. |
| 1 | Radura | 1 C | Il primo edificio Civico costruito qui dà +1 Lampo. |
| 1 | Recinto di pietre | 1 C | Il primo edificio costruito qui ha +1 resistenza fino a fine era. |
| 1 | Sentiero dei pastori | 1 D | Chi attiva per primo puo' comprare ancora un potenziamento o una casa in quel turno. |
| 1 | Terra di nessuno | 1 D | Il primo edificio costruito qui ignora il requisito di terreno. |
| 2 | Cambiavalute | 1 D | Chi attiva per primo può cambiare 1 Costruzione in 1 Denaro. |
| 2 | Cantiere | — | Il primo edificio costruito qui sopra un altro edificio costa 1 Costruzione in meno. |
| 2 | Centuriazione | 1 C | Il primo edificio Ingegneria costruito qui costa 1 Costruzione in meno. |
| 2 | Necropoli | — | Il primo edificio costruito qui ha Scavo +1, per sempre. |
| 2 | Restauratori | 1 I | Il primo edificio costruito qui sopra un altro costa 1 Idea in meno. |
| 2 | Statio | 1 C | Il primo edificio Commercio costruito qui dà +1 Denaro a chi lo costruisce. |
| 2 | Via consolare | — | Chi attiva per primo prende anche la produzione di una colonna adiacente a scelta. |
| 3 | Borgo franco | 1 C | Il primo edificio costruito qui sopra una rovina altrui costa 1 Costruzione in meno. |
| 3 | Eremo | — | Il primo edificio Religione o Cultura costruito qui dà +2 Lampo. |
| 3 | Fiera | — | Chi attiva per primo prende +1 Denaro per ogni altro giocatore con un edificio intatto qui. |
| 3 | Mura | 1 C | Il primo edificio Militare costruito qui ha +2 resistenza fino a fine era. |
| 3 | Rocca | — | Il primo edificio costruito qui è protetto all'evento di fine era. |
| 3 | Scuola dei mastri | 1 I | Chi attiva per primo prende +1 Idea per ogni edificio Ingegneria intatto qui. |
| 3 | Spoglio delle rovine | — | Chi seppellisce per primo un edificio qui prende +1 al premio di scavo. |
| 4 | Belvedere | 1 C | Il primo edificio costruito qui al livello 3 o più dà +2 Lampo. |
| 4 | Bottega | — | Chi attiva per primo prende 1 risorsa a scelta. |
| 4 | Cappella di famiglia | — | Il primo scheletro lasciato qui vale +1 punto a fine partita. |
| 4 | Fondaco | 1 C | Il primo edificio Commercio costruito qui produce subito, una volta. |
| 4 | Giardino all'italiana | 1 C | Il primo edificio costruito qui ha +2 resistenza fino a fine era. |
| 4 | Piazza del mercato | — | Chi attiva per primo, se ha meno punti di tutti, prende +2 Denaro. |
| 4 | Villa di campagna | — | Il primo edificio Cultura costruito qui costa 1 Denaro in meno. |
| 5 | Isolato | — | Il primo edificio costruito qui dà +1 Lampo per ogni edificio altrui intatto qui. |
| 5 | Orto botanico | — | Il primo potenziamento messo su un edificio qui costa 1 Idea in meno. |
| 5 | Parco pubblico | — | A fine partita chi ha l'edificio in cima a questa colonna prende +2 punti. |
| 5 | Periferia | 1 C | Il primo edificio Civico costruito qui costa 1 Idea in meno. |
| 5 | Quartiere alto | 1 C | Il primo edificio costruito qui, se diventa il più alto della strada, dà +3 Lampo. |
| 5 | Scuola politecnica | — | Il primo edificio Ingegneria costruito qui costa 1 Denaro in meno. |
| 5 | Zona industriale | 1 C | Chi attiva per primo prende +1 Denaro per ogni edificio Ingegneria o Commercio intatto qui. |

## Gli eventi

| era | evento | forza | testo |
|--:|---|--:|---|
| 1 | Carestia primitiva | 2 | Forza 2. Edifici a livello 0 non protetti che producono risorse: −2 res. |
| 1 | Diluvio | 2 | Forza 2. Edifici su colonne fiume: −1 res. |
| 1 | Età degli spiriti | 3 | Forza 3. Colpisce solo Commercio, Civico. |
| 1 | Faide tribali | 3 | Forza 3. Colpisce solo Civico, Commercio. |
| 1 | Inverno lungo | 2 | Forza 2. Edifici su bosco e collina: −1 res. Tutti i giocatori perdono 1 Costruzione. |
| 1 | Migrazione | 2 | Forza 2. Edifici non protetti: −1 res extra. |
| 2 | Eruzione | 2 | Forza 2. Edifici su collina: −2 res. Chi perde un edificio pesca un potenziamento gratis (massimo uno per giocatore). |
| 2 | Guerra civile | 2 | Forza 2. Nelle colonne con edifici di 2+ giocatori: tutti −1 res. |
| 2 | Invasione | 2 | Forza 2. Edifici non protetti: −1 res extra. |
| 2 | Pax imperiale | 3 | Forza 3. Colpisce solo Militare. |
| 2 | Persecuzioni | 3 | Forza 3. Colpisce solo Religione, Cultura. |
| 2 | Terremoto | 2 | Forza 2. Edifici da 2 o 3 caselle: −1 res. |
| 3 | Anni della fame | 3 | Forza 3. Nessuna produzione durante l’ultimo round dell’era. |
| 3 | Grande incendio | 3 | Forza 3. Edifici a livello 0 o 1: −1 res; a livello 2+: −2 res. |
| 3 | Guerra | 4 | Forza 4. Colpisce solo Civico, Commercio, Ingegneria. |
| 3 | Incursioni fluviali | 3 | Forza 3. Edifici su colonne fiume: −1 res. |
| 3 | Peste | 3 | Forza 3. Colonne con 3+ edifici in piedi: tutti −1 res. |
| 3 | Scisma | 4 | Forza 4. Colpisce solo Religione, Cultura. |
| 4 | Alluvione | 2 | Forza 2. Edifici su colonne fiume: −1 res. |
| 4 | Bonifiche | 2 | Forza 2. Edifici su pianura: −2 res. Il primo terrapieno di ogni giocatore in quest’era costa 0. |
| 4 | Controriforma | 3 | Forza 3. Colpisce solo Cultura, Commercio. |
| 4 | Rivoluzione industriale | 2 | Forza 2. Edifici con Scavo 2+: −1 res. |
| 4 | Secolarizzazioni | 3 | Forza 3. Colpisce solo Religione. |
| 4 | Speculazione edilizia | 2 | Forza 2. Ogni edificio con 2+ potenziamenti: −1 res. |
| 5 | Crisi dello Stato | 3 | Forza 3. Colpisce solo Civico, Militare. |
| 5 | Crisi energetica | 2 | Forza 2. Edifici non protetti che producono risorse: −1 res. |
| 5 | Globalizzazione | 3 | Forza 3. Colpisce solo Cultura, Civico. |
| 5 | Guerra mondiale | 2 | Forza 2. Nelle colonne con edifici di 2+ giocatori: tutti −1 res. Militare −1 res. |
| 5 | Innalzamento dei mari | 2 | Forza 2. Edifici su fiume: −2 res · su pianura: −1 res. |
| 5 | Subsidenza | 2 | Forza 2. Edifici su pianura e fiume: −1 res. |

## I Monumenti

Se ne rivelano tanti quanti i giocatori meno uno; li prende il primo che soddisfa la condizione.

| carta | PV | condizione |
|---|--:|---|
| San Clemente | 5 | Primo ad avere 3 edifici Religione nella stessa colonna. |
| Colosseo | 4 | Primo ad avere un edificio attivo con resistenza 7 o più. |
| Pantheon | 4 | Primo ad avere un edificio dell’era 1 o 2 ancora in piedi all’inizio dell’era Moderna. |
| Fori Imperiali | 4 | Primo ad avere 4 propri edifici Sotterrati. |
| Acropoli | 4 | Primo a costruire a livello 4. |
| Via Appia | 5 | Primo ad avere propri edifici in cima a 4 colonne consecutive. |
| Terme di Caracalla | 4 | Primo a costruire un edificio da 3 caselle. |
| Ponte Milvio | 4 | Primo ad avere 2 edifici su colonne fiume distinte. |
| Mura Aureliane | 5 | Primo ad avere 3 edifici Militari in piedi contemporaneamente. |
| Cloaca Massima | 4 | Primo ad aver speso almeno 3 Costruzione complessive in costi di terrapieno. |
| Domus Aurea | 5 | Primo ad avere un edificio con 3 potenziamenti. |
| Campidoglio | 4 | Primo ad avere 2 edifici Civici nella stessa colonna. |
| Isola Tiberina | 4 | Primo a costruire su una colonna fiume a livello 2+. |
| Catacombe | 5 | Primo ad avere 3 edifici sotterrati nella stessa colonna. |

## Le Eredità

Due a testa, se ne tiene una segreta; si conta a fine partita.

| carta | PV | condizione |
|---|--:|---|
| L’Archeologo | 5 | 4+ tuoi edifici Sotterrati. |
| Il Costruttore di cattedrali | 4 | 3+ tuoi edifici Religione, in qualsiasi stato. |
| Il Verticalista | 4 | hai costruito un edificio a livello 4 o superiore. |
| Il Geografo | 4 | tuoi edifici su tutti e quattro i terreni. |
| Il Colonizzatore | 4 | tuoi edifici in 5+ colonne diverse. |
| Il Mecenate | 4 | 4+ potenziamenti collocati sui tuoi edifici, inclusi quelli poi Sotterrati. |
| Il Condottiero | 4 | 2+ tuoi edifici Militari, in qualsiasi stato. |
| Il Cronista | 5 | tuoi edifici di tutte e cinque le ere. |
| Il Guardiano | 5 | un tuo edificio in piedi costruito nell’era 1 o 2. |
| Il Lastricatore | 4 | tuoi edifici in 3 colonne consecutive. |
| Il Demolitore | 4 | hai spianato 3+ tuoi edifici intatti. |
| Il Massaio | 4 | due tuoi edifici a livello 2 o superiore. |
| L’Idraulico | 4 | 3+ tuoi edifici su colonne fiume. |
| Il Silvicoltore | 5 | un tuo edificio attivo su bosco costruito nell'era 1 o 2. |
| Il Restauratore | 4 | almeno 2 tue rovine riportate alla luce da un edificio dell'era Moderna. |
| L’Antiquario | 5 | un tuo edificio Sotterrato con Scavo 5 o più. |

