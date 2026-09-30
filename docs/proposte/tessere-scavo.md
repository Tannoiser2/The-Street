# Le tessere scavo: un mazzetto di rovine per giocatore

Proposta del designer del 29 settembre (registro 130): quando un edificio va in rovina si toglie
la carta e al suo posto si mettono, coperte, delle tessere scavo, che si rivelano a fine partita.
Il valore va al proprietario dell'edificio; per sapere di chi è la rovina, **ogni giocatore ha
un mazzetto di tessere del suo colore**. Oggi è solo nella variante
`data/proposte/cards-v2-tessere_scavo.json` (`python3 tools/genera_cards_v2.py --variante
tessere_scavo`), misurata nella ventiseiesima misura (`docs/la-terza-risorsa.md`).

## Il mazzetto

Venti tessere per giocatore, nel suo colore, valore da 0 a 3 (media 1,4):

| valore | semplici | con lo scheletro | con il potenziamento | totale |
|--:|--:|--:|--:|--:|
| 0 | 3 | 1 | 1 | 5 |
| 1 | 4 | 1 | 1 | 6 |
| 2 | 3 | 1 | 1 | 5 |
| 3 | 4 | – | – | 4 |

## Le regole

1. **In rovina.** Quando un tuo edificio va in rovina, togli la carta, pesca dal tuo mazzetto
   una tessera per ogni casella che occupava (un 2x2 come il Colosseo ne pesca 4) e mettile
   coperte su quelle caselle. Se il mazzetto è finito, le caselle restano vuote e valgono 0.
   Uno spianato non lascia tessere; un edificio ancora in piedi nemmeno.
2. **Si costruisce sopra come prima.** Le tessere restano sotto e non si guardano.
3. **Lo scavo dell'era moderna.** Quando si costruisce un edificio dell'era 5 sopra delle rovine
   (livello 1 o più), tutte le tessere sotto di lui, a qualunque profondità, si girano a faccia
   in su. Sono "scoperte", chiunque abbia costruito.
4. **A fine partita** ogni giocatore incassa le tessere del suo colore:
   - quelle **scoperte** valgono il loro numero **per intero**;
   - quelle ancora **coperte** si girano e valgono **la metà** (per difetto, per edificio);
   - lo **scheletro** di una tessera scoperta vale quanto il tuo miglior Personaggio delle ere
     1–4 non ancora usato da un altro scheletro: 6 meno la sua era (era 1 = 5 PV);
   - il **potenziamento** di una tessera scoperta vale il costo del miglior potenziamento non
     ancora usato fra quelli che erano montati sulle tue rovine.
5. **Lo Scavo stampato** sulle carte resta: è il premio di chi costruisce sopra (Scavo × livello,
   metà nell'era 5). Non dà più punti al proprietario a fine partita: quelli li danno le tessere.

## Da decidere

- Se il premio a chi costruisce sopra debba contare le tessere (coperte, quindi ignote) invece
  dello Scavo stampato.
- Se le icone valgano anche sulle tessere coperte.
- Quante tessere nel mazzetto: nella misura un giocatore ne pesca in media meno di 4 (al
  massimo 12, a ogni tavolo); venti sono troppe, ne bastano 12 con le stesse proporzioni.
