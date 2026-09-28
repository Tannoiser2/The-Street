# I potenziamenti raddoppiati: 25 carte nuove

Richiesta del designer (registro 123): raddoppiare i potenziamenti come le tessere, con altri
25 potenziamenti diversi. Il mazzo di ogni era passa da cinque a dieci carte.

Le regole di costruzione sono quelle dei primi 25:

- **Costo:** 1 nelle ere 1-3 e 2 nelle ere 4-5.
- **Risorsa:** quella della famiglia. Arte si paga in Idee, Struttura in Costruzione, il resto in Denaro.
- **Forza:** pari a quella dei potenziamenti della stessa era. Molti sono varianti con una classe diversa ("+1 extra su edificio Civico") o un'altra risorsa quando si abita l'edificio.
- **Effetti:** usano solo operazioni che il motore conosce già. L'unica aggiunta è che "quando abiti" ora può dare anche Idee (Focolare, Terme, Stamperia).

I dati stanno in `tools/genera_cards_v2.py` (`POTENZIAMENTI_NUOVI`), il file v2 si rigenera da lì.

| era | potenziamento | famiglia | classe | costo | testo |
|--:|---|---|---|---|---|
| 1 | Totem | arte | religione | 1 Idee | Arte: +1 PV (+1 extra su edificio Civico). |
| 1 | Argine | struttura | ingegneria | 1 Costruzione | Struttura: +1 res. |
| 1 | Focolare | altro | civico | 1 Denaro | Quando abiti questo edificio, +1 Idea. |
| 1 | Recinto per il bestiame | altro | commercio | 1 Denaro | Quando abiti questo edificio, +1 Denaro. |
| 1 | Ossario | altro | religione | 1 Denaro | Scavo dell'edificio +2. |
| 2 | Mosaico | arte | cultura | 1 Idee | Arte: +2 PV su edificio Cultura, altrimenti +1. |
| 2 | Terme private | altro | civico | 1 Denaro | Quando abiti questo edificio, +1 Idea. |
| 2 | Mura di cinta | struttura | militare | 1 Costruzione | Struttura: +1 res (+1 extra su edificio Militare). |
| 2 | Mulino ad acqua | altro | ingegneria | 1 Denaro | Solo su slot fiume: quando abiti qui, +1 Costruzione. |
| 2 | Lapide funeraria | altro | religione | 1 Denaro | Finale: +2 Scavo a ogni edificio Sotterrato sotto questo edificio. |
| 3 | Vetrata | arte | religione | 1 Idee | Arte: +1 PV. Scavo dell'edificio +2. |
| 3 | Arco rampante | struttura | ingegneria | 1 Costruzione | Struttura: +1 res. L'edificio conta anche come Religione. |
| 3 | Portico | altro | commercio | 1 Denaro | Quando abiti questo edificio, +1 Denaro (+1 extra su edificio Commercio). |
| 3 | Torre di guardia | struttura | militare | 1 Costruzione | Struttura: +1 res (+1 extra su edificio Militare). |
| 3 | Stemma di famiglia | arte | civico | 1 Idee | Arte: +2 PV su edificio Civico, altrimenti +1. |
| 4 | Pala d'altare | arte | religione | 2 Idee | Arte: +2 PV (+1 extra su edificio Religione). |
| 4 | Loggia | altro | civico | 2 Denaro | +1 PV. L'affitto incassato da questo edificio è +1. |
| 4 | Bastione a stella | struttura | militare | 2 Costruzione | Struttura: +2 res. |
| 4 | Fontana monumentale | arte | civico | 2 Idee | Arte: +2 PV. Scavo dell'edificio +2. |
| 4 | Stamperia | altro | cultura | 2 Denaro | Quando abiti questo edificio, +2 Idee. |
| 5 | Murale | arte | cultura | 2 Idee | Arte: +2 PV (+1 extra su edificio Cultura). |
| 5 | Pannelli solari | altro | ingegneria | 2 Denaro | Quando abiti questo edificio, +2 Costruzione. |
| 5 | Cemento armato | struttura | ingegneria | 2 Costruzione | Struttura: +2 res. |
| 5 | Terrazza panoramica | altro | civico | 2 Denaro | +2 PV su edificio Civico, altrimenti +1. |
| 5 | Archivio storico | altro | cultura | 2 Denaro | Scavo dell'edificio +3. |

## Da stampare

Le 25 carte vanno stampate con lo stesso formato dei primi 25 potenziamenti v2, che a loro volta
mancano ancora nei materiali. Servono nome, era, famiglia, classe, costo e testo come nella tabella.
