# Le carte della v2 da stampare

> Generato da `tools/stampa_carte_v2.py` da `data/cards-v2.json`. Qui c'è solo quello che va
> scritto sulle carte.

Come si leggono le colonne:

- **Costo** si legge Costruzione / Denaro / Idee.
- **Forma** si legge colonne × binari: 1×2 è una colonna per due binari, 2×2 sono quattro caselle.
- **Produzione:** risorse che l'edificio dà al proprietario ogni volta che si attiva la sua colonna.
- **Rendita:** PV al proprietario a fine di ogni era, se l'edificio è in piedi.
- **Lampo:** PV una volta sola, quando lo costruisci.
- **Testo:** gli effetti permanenti e quelli "A fine partita".

## Prima era

### Edifici

| nome | classi | luogo | forma | costo C/D/I | produzione | resistenza | Scavo | Rendita | Lampo | testo | copie |
|---|---|---|---|--:|---|--:|--:|--:|--:|---|---|
| **Approdo** | Commercio | Fiume | 1×1 | 1 / 0 / 0 | 1 Costruzione | 1 | 2 | — | — | — | 1 |
| **Capanne** | Civico | Pianura | 1×1 | 1 / 0 / 0 | 1 Costruzione | 1 | 2 | — | 1 | — | 1 |
| **Capanne di fango** | Civico | Qualsiasi | 1×1 | 1 / 0 / 0 | — | 2 | 1 | — | 1 | — | 2 (RIS) |
| **Case di pietra** | Civico | Qualsiasi | 1×1 | 2 / 0 / 0 | — | 2 | 1 | — | 2 | — | 2 (RIS) |
| **Cava** | Commercio | Pianura | 1×1 | 1 / 0 / 0 | 2 Costruzione | 1 | 2 | — | — | — | 1 (Esaur. 4) |
| **Circolo di pietre** | Religione | Qualsiasi | 1×2 | 2 / 0 / 1 | — | 4 | 5 | 1 | — | — | 1 |
| **Dolmen** | Religione | Collina | 1×1 | 1 / 0 / 1 | — | 3 | 3 | 1 | — | — | 1 |
| **Focolare comune** | Civico | Pianura | 1×1 | 1 / 0 / 0 | — | 1 | 2 | — | 1 | Quando lo attivi: +1 Costruzione. | 1 |
| **Grotte dipinte** | Cultura | Collina | 1×1 | 0 / 0 / 1 | — | 2 | 6 | — | — | — | 1 |
| **Menhir** | Religione | Bosco | 1×1 | 1 / 0 / 1 | — | 4 | 3 | 1 | — | — | 1 |
| **Palafitte** | Civico | Fiume | 1×1 | 1 / 0 / 0 | 1 Costruzione | 2 | 2 | — | 1 | — | 1 |
| **Ripari** | Civico | Qualsiasi | 1×1 | 1 / 0 / 0 | — | 1 | 2 | — | 1 | — | 2 (RIS) |
| **Trappole da pesca** | Ingegneria | Fiume | 1×1 | 1 / 0 / 0 | 1 Costruzione | 1 | 0 | — | — | — | 1 |
| **Tumulo funerario** | Religione / Cultura | Collina | 2×1 | 1 / 0 / 1 | — | 3 | 5 | — | 1 | — | 1 |
| **Villaggio palizzato** | Militare | Pianura | 1×2 | 1 / 0 / 0 | — | 2 | 3 | — | 2 | Negli eventi, i tuoi edifici adiacenti hanno +1 Resistenza. | 1 |

### Potenziamenti

| nome | famiglia | classe | costo | testo |
|---|---|---|---|---|
| **Argine** | Struttura | Ingegneria | 1 Costruzione | L'edificio ha +1 Resistenza. |
| **Focolare** | Altro | Civico | 1 Denaro | Quando attivi l'edificio: +1 Idea. |
| **Fondamenta in pietra** | Struttura | Ingegneria | 1 Costruzione | L'edificio ha +1 Resistenza. |
| **Granaio comune** | Altro | Civico | 1 Denaro | Quando attivi l'edificio: +1 Costruzione. |
| **Idolo** | Arte | Religione | 1 Idea | Subito: +1 PV. |
| **Ossario** | Altro | Religione | 1 Denaro | L'edificio ha +2 Scavo. |
| **Palizzata** | Struttura | Militare | 1 Costruzione | L'edificio ha +1 Resistenza. |
| **Pittura rupestre** | Arte | Cultura | 1 Idea | Subito: +1 PV. L'edificio ha +2 Scavo. |
| **Recinto per il bestiame** | Altro | Commercio | 1 Denaro | Quando attivi l'edificio: +1 Denaro. |
| **Totem** | Arte | Religione | 1 Idea | Subito: +1 PV. |

## Seconda era

### Edifici

| nome | classi | luogo | forma | costo C/D/I | produzione | resistenza | Scavo | Rendita | Lampo | testo | copie |
|---|---|---|---|--:|---|--:|--:|--:|--:|---|---|
| **Acquedotto** | Ingegneria | Fiume | 3×1 | 2 / 0 / 1 | — | 4 | 3 | 1 | — | A fine partita, se è in piedi: +2 PV. | 1 |
| **Anfiteatro** | Cultura | Qualsiasi | 2×2 | 4 / 0 / 1 | 1 Denaro | 5 | 6 | 2 | — | Solo sopra: mai a terra. Sopra di lui si costruisce solo quando è in rovina. | 1 |
| **Case a schiera** | Civico | Qualsiasi | 1×1 | 1 / 0 / 0 | — | 3 | 1 | — | 1 | — | 2 (RIS) |
| **Castrum** | Militare | Pianura | 1×2 | 2 / 0 / 0 | — | 4 | 3 | — | 2 | Negli eventi, i tuoi edifici nelle sue colonne hanno +1 Resistenza. | 1 |
| **Domus** | Civico | Qualsiasi | 1×1 | 2 / 0 / 0 | — | 3 | 1 | — | 2 | — | 2 (RIS) |
| **Emporio** | Commercio | Fiume | 1×1 | 2 / 0 / 0 | 1 Denaro | 2 | 2 | — | 2 | — | 1 |
| **Foro** | Commercio / Civico | Pianura | 1×2 | 3 / 0 / 0 | 1 Denaro | 3 | 5 | 1 | — | — | 1 |
| **Insulae** | Civico | Pianura | 1×1 | 2 / 0 / 0 | 1 Costruzione | 2 | 2 | — | 2 | — | 1 |
| **Ponte** | Ingegneria | Fiume | 2×1 | 2 / 0 / 1 | — | 3 | 3 | 1 | — | Gli edifici adiacenti producono 1 in più di ogni risorsa che già producono. | 1 |
| **Sacello** | Religione | Collina | 1×1 | 0 / 0 / 1 | — | 2 | 3 | — | 1 | — | 1 |
| **Teatro** | Cultura | Qualsiasi | 1×1 | 1 / 0 / 1 | — | 3 | 5 | — | 2 | — | 1 |
| **Tempio** | Religione | Collina | 1×1 | 2 / 0 / 1 | — | 3 | 3 | 1 | — | — | 1 |
| **Terme** | Civico | Qualsiasi | 1×1 | 2 / 0 / 0 | — | 2 | 3 | — | 2 | — | 1 |
| **Torre di vedetta** | Militare | Collina | 1×1 | 1 / 0 / 0 | — | 3 | 2 | — | 2 | Negli eventi, i tuoi edifici adiacenti hanno +1 Resistenza. | 1 |
| **Tuguri** | Civico | Qualsiasi | 1×1 | 1 / 0 / 0 | — | 2 | 2 | — | 1 | — | 2 (RIS) |

### Potenziamenti

| nome | famiglia | classe | costo | testo |
|---|---|---|---|---|
| **Altare** | Arte | Religione | 1 Idea | Subito: +1 PV. L'edificio ha +2 Scavo. |
| **Banchina** | Altro | Commercio | 1 Denaro | Quando attivi l'edificio, se tocca il Fiume: +1 Denaro. |
| **Bastioni** | Struttura | Militare | 1 Costruzione | L'edificio ha +1 Resistenza. |
| **Iscrizione** | Altro | Cultura | 1 Denaro | L'edificio ha +2 Scavo. |
| **Lapide funeraria** | Altro | Religione | 1 Denaro | A fine partita: +2 Scavo a ogni edificio sotterrato sotto l'edificio. |
| **Mosaico** | Arte | Cultura | 1 Idea | Subito: +1 PV. |
| **Mulino ad acqua** | Altro | Ingegneria | 1 Denaro | Quando attivi l'edificio, se tocca il Fiume: +1 Costruzione. |
| **Mura di cinta** | Struttura | Militare | 1 Costruzione | L'edificio ha +1 Resistenza. |
| **Statua** | Arte | Cultura | 1 Idea | Subito: +2 PV. |
| **Terme private** | Altro | Civico | 1 Denaro | Quando attivi l'edificio: +1 Idea. |

## Terza era

### Edifici

| nome | classi | luogo | forma | costo C/D/I | produzione | resistenza | Scavo | Rendita | Lampo | testo | copie |
|---|---|---|---|--:|---|--:|--:|--:|--:|---|---|
| **Abbazia** | Religione / Commercio | Bosco | 1×2 | 2 / 1 / 1 | — | 3 | 5 | 2 | — | — | 1 |
| **Arsenale** | Militare | Fiume | 1×2 | 3 / 1 / 0 | — | 3 | 2 | — | 2 | Negli eventi, i tuoi edifici Militari adiacenti hanno +1 Resistenza. | 1 |
| **Borgo** | Civico | Pianura | 1×1 | 2 / 0 / 0 | 1 Denaro | 2 | 2 | — | 2 | — | 1 |
| **Cappella** | Religione | Qualsiasi | 1×1 | 1 / 0 / 1 | — | 2 | 3 | — | 2 | — | 1 |
| **Casa torre** | Civico | Qualsiasi | 1×1 | 1 / 1 / 0 | — | 3 | 1 | — | 2 | — | 2 (RIS) |
| **Case di legno** | Civico | Qualsiasi | 1×1 | 0 / 1 / 0 | — | 2 | 1 | — | 1 | — | 2 (RIS) |
| **Castello** | Militare | Collina | 2×2 | 2 / 1 / 0 | — | 4 | 3 | 2 | — | Solo sopra: mai a terra. Sopra di lui si costruisce solo quando è in rovina. | 1 |
| **Casupole** | Civico | Qualsiasi | 1×1 | 1 / 0 / 0 | — | 2 | 2 | — | 1 | — | 2 (RIS) |
| **Chiesa** | Religione / Cultura | Qualsiasi | 1×1 | 2 / 0 / 1 | — | 3 | 3 | 2 | — | — | 1 |
| **Conceria** | Commercio | Fiume | 1×1 | 1 / 0 / 0 | 1 Denaro | 1 | 0 | — | 1 | — | 1 |
| **Mercato** | Commercio | Fiume | 1×1 | 2 / 0 / 0 | 1 Costruzione, 1 Denaro | 2 | 2 | — | 1 | — | 1 |
| **Mulino** | Ingegneria / Commercio | Pianura | 1×1 | 1 / 0 / 1 | 2 Denaro | 2 | 2 | — | 1 | — | 1 |
| **Mura** | Militare | Qualsiasi | 1×1 | 2 / 0 / 0 | — | 4 | 2 | — | 2 | Negli eventi, tutti gli edifici adiacenti, anche altrui, hanno +1 Resistenza. | 1 |
| **Ospedale dei pellegrini** | Civico | Qualsiasi | 1×1 | 2 / 1 / 0 | — | 2 | 2 | — | 2 | Quando lo attivi: +1 Denaro. | 1 |
| **Torre civica** | Civico | Qualsiasi | 1×1 | 2 / 0 / 0 | — | 3 | 2 | — | 2 | — | 1 |

### Potenziamenti

| nome | famiglia | classe | costo | testo |
|---|---|---|---|---|
| **Arco rampante** | Struttura | Ingegneria | 1 Costruzione | L'edificio ha +1 Resistenza e conta anche come Religione. |
| **Campanile** | Altro | Religione | 1 Denaro | Subito: +1 PV. L'edificio ha +1 Resistenza. |
| **Contrafforte** | Struttura | Ingegneria | 1 Costruzione | L'edificio ha +1 Resistenza. |
| **Merlatura** | Struttura | Militare | 1 Costruzione | L'edificio ha +1 Resistenza e conta anche come Militare. |
| **Portico** | Altro | Commercio | 1 Denaro | Quando attivi l'edificio: +1 Denaro. |
| **Reliquia** | Arte | Religione | 1 Idea | Subito: +1 PV. |
| **Stalli mercantili** | Altro | Commercio | 1 Denaro | L'edificio ha +1 Rendita. |
| **Stemma di famiglia** | Arte | Civico | 1 Idea | Subito: +1 PV. |
| **Torre di guardia** | Struttura | Militare | 1 Costruzione | L'edificio ha +1 Resistenza. |
| **Vetrata** | Arte | Religione | 1 Idea | Subito: +1 PV. L'edificio ha +2 Scavo. |

## Quarta era

### Edifici

| nome | classi | luogo | forma | costo C/D/I | produzione | resistenza | Scavo | Rendita | Lampo | testo | copie |
|---|---|---|---|--:|---|--:|--:|--:|--:|---|---|
| **Accademia** | Cultura | Qualsiasi | 1×1 | 1 / 0 / 2 | — | 2 | 3 | — | 2 | — | 1 |
| **Banco** | Commercio | Qualsiasi | 1×1 | 1 / 0 / 1 | 1 Denaro | 2 | 0 | — | 2 | — | 1 |
| **Bottega d'artista** | Cultura | Qualsiasi | 1×1 | 1 / 0 / 1 | — | 2 | 2 | — | 2 | I tuoi potenziamenti costano 1 in meno, nella loro risorsa. | 1 |
| **Casa borghese** | Civico | Qualsiasi | 1×1 | 0 / 0 / 1 | — | 2 | 1 | — | 2 | — | 2 (RIS) |
| **Case popolari** | Civico | Qualsiasi | 1×1 | 0 / 0 / 1 | — | 2 | 2 | — | 2 | — | 2 (RIS) |
| **Duomo** | Religione / Cultura | Qualsiasi | 1×2 | 3 / 1 / 2 | — | 4 | 5 | 2 | — | Solo sopra: al livello 2 o più. | 1 |
| **Fortezza bastionata** | Militare / Ingegneria | Collina | 2×2 | 3 / 1 / 1 | — | 5 | 2 | 2 | — | Solo sopra: mai a terra. Sopra di lui si costruisce solo quando è in rovina. | 1 |
| **Giardino all'italiana** | Cultura | Collina | 1×1 | 0 / 0 / 2 | — | 1 | 0 | — | 2 | — | 1 |
| **Loggia** | Civico | Qualsiasi | 1×1 | 1 / 0 / 1 | — | 2 | 2 | — | 2 | — | 1 |
| **Osservatorio** | Ingegneria | Collina | 1×1 | 1 / 1 / 1 | — | 2 | 2 | — | 2 | A fine partita, se è in piedi: +2 PV. | 1 |
| **Palazzetto** | Civico | Qualsiasi | 1×1 | 0 / 1 / 1 | — | 3 | 1 | — | 2 | — | 2 (RIS) |
| **Palazzo signorile** | Civico | Pianura | 1×1 | 2 / 1 / 1 | 1 Idea | 3 | 3 | — | 2 | — | 1 |
| **Piazza monumentale** | Civico | Pianura | 1×2 | 2 / 1 / 1 | — | 3 | 3 | 2 | — | Solo sopra: al livello 1 o più. A fine partita: +1 PV per ogni tuo edificio in cima a una colonna adiacente. | 1 |
| **Ponte monumentale** | Ingegneria | Fiume | 2×1 | 2 / 1 / 1 | — | 4 | 3 | 2 | — | — | 1 |
| **Villa** | Civico | Collina | 1×1 | 2 / 1 / 1 | — | 3 | 3 | — | 2 | — | 1 |

### Potenziamenti

| nome | famiglia | classe | costo | testo |
|---|---|---|---|---|
| **Affreschi** | Arte | Cultura | 2 Idee | Subito: +2 PV. |
| **Bastione a stella** | Struttura | Militare | 2 Costruzione | L'edificio ha +2 Resistenza. |
| **Cannoniere** | Struttura | Militare | 2 Costruzione | L'edificio ha +1 Resistenza. |
| **Cupola** | Altro | Ingegneria | 2 Denaro | Subito: +2 PV. L'edificio ha +1 Resistenza. |
| **Fontana monumentale** | Arte | Civico | 2 Idee | Subito: +2 PV. L'edificio ha +2 Scavo. |
| **Giardino pensile** | Arte | Civico | 2 Idee | Subito: +2 PV. |
| **Loggia** | Altro | Civico | 2 Denaro | Subito: +1 PV. L'edificio ha +1 Rendita. |
| **Opera d'arte** | Arte | Cultura | 2 Idee | Subito: +3 PV. |
| **Pala d'altare** | Arte | Religione | 2 Idee | Subito: +2 PV. |
| **Stamperia** | Altro | Cultura | 2 Denaro | Quando attivi l'edificio: +2 Idee. |

## Quinta era

### Edifici

| nome | classi | luogo | forma | costo C/D/I | produzione | resistenza | Scavo | Rendita | Lampo | testo | copie |
|---|---|---|---|--:|---|--:|--:|--:|--:|---|---|
| **Biblioteca** | Cultura | Qualsiasi | 1×1 | 1 / 1 / 2 | — | 3 | 0 | — | 2 | A fine partita: +1 PV per ogni classe diversa fra i tuoi edifici nelle sue colonne, sotterrati compresi. | 1 |
| **Caffè letterario** | Cultura | Qualsiasi | 1×1 | 0 / 0 / 2 | — | 1 | 0 | — | 2 | A fine partita: +1 PV se è adiacente a un edificio Cultura. | 1 |
| **Condominio** | Civico | Qualsiasi | 1×1 | 1 / 0 / 1 | — | 2 | 0 | — | 2 | — | 1 |
| **Condominio popolare** | Civico | Qualsiasi | 1×1 | 0 / 1 / 1 | — | 4 | 1 | — | 2 | — | 2 (RIS) |
| **Fondazione d'arte** | Cultura | Qualsiasi | 1×1 | 1 / 0 / 2 | — | 2 | 0 | — | 2 | A fine partita: +1 PV per ogni tuo potenziamento. | 1 |
| **Grattacielo** | Commercio | Pianura | 1×3 | 2 / 3 / 1 | — | 3 | 0 | — | 2 | Solo sopra: al livello 2 o più, mai a terra. A fine partita: +1 PV per ogni livello a cui è costruito; ogni edificio altrui in cima a una colonna adiacente toglie 1 PV al suo proprietario. | 1 |
| **Monumento ai caduti** | Militare / Religione | Qualsiasi | 1×1 | 1 / 1 / 1 | — | 3 | 0 | — | 2 | A fine partita: +1 PV per ogni altro tuo edificio Militare, in piedi o sotterrato. | 1 |
| **Museo** | Cultura | Qualsiasi | 1×1 | 1 / 1 / 1 | — | 3 | 0 | — | 2 | Solo sopra: al livello 1 o più. A fine partita: +2 PV per ogni edificio sotterrato sotto di lui. | 1 |
| **Officina** | Ingegneria | Qualsiasi | 1×1 | 1 / 0 / 1 | 2 Denaro | 2 | 0 | — | 2 | — | 1 |
| **Palazzina** | Civico | Qualsiasi | 1×1 | 0 / 0 / 1 | — | 3 | 1 | — | 2 | — | 2 (RIS) |
| **Parco archeologico** | Cultura | Qualsiasi | 1×2 | 1 / 0 / 2 | — | 2 | 0 | — | 2 | A fine partita: fino a 2 tuoi edifici non sotterrati nelle colonne adiacenti valgono il loro Scavo come se fossero sotterrati. | 1 |
| **Ponte in acciaio** | Ingegneria | Fiume | 2×1 | 1 / 2 / 1 | — | 4 | 0 | — | 2 | — | 1 |
| **Stazione** | Commercio / Ingegneria | Pianura | 3×1 | 2 / 3 / 1 | 2 Denaro | 4 | 0 | — | 2 | Solo sopra: al livello 1 o più. | 1 |
| **Università** | Cultura / Civico | Qualsiasi | 1×2 | 2 / 1 / 2 | — | 3 | 0 | — | 2 | Solo sopra: al livello 1 o più. A fine partita: +1 PV per ogni tuo Personaggio. | 1 |

### Potenziamenti

| nome | famiglia | classe | costo | testo |
|---|---|---|---|---|
| **Archivio storico** | Altro | Cultura | 2 Denaro | L'edificio ha +3 Scavo. |
| **Ascensore panoramico** | Altro | Ingegneria | 2 Denaro | Subito: +2 PV. |
| **Boutique** | Altro | Commercio | 2 Denaro | Quando attivi l'edificio: +2 Denaro. |
| **Cemento armato** | Struttura | Ingegneria | 2 Costruzione | L'edificio ha +2 Resistenza. |
| **Installazione** | Arte | Cultura | 2 Idee | Subito: +3 PV. |
| **Memoriale** | Altro | Religione | 2 Denaro | Subito: +2 PV. |
| **Murale** | Arte | Cultura | 2 Idee | Subito: +2 PV. |
| **Pannelli solari** | Altro | Ingegneria | 2 Denaro | Quando attivi l'edificio: +2 Costruzione. |
| **Targa storica** | Altro | Civico | 2 Denaro | A fine partita: +2 Scavo a ogni edificio sotterrato sotto l'edificio. |
| **Terrazza panoramica** | Altro | Civico | 2 Denaro | Subito: +1 PV. |
