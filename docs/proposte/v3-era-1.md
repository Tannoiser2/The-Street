# La v3: la scheda dell'era 1 (Preistoria)

La prima era scritta con il metro (`docs/proposte/v3-metro.md`), da simulare da sola con
`--fino_era 1` prima di toccare le altre quattro. Stato: **proposta**, da leggere e
correggere carta per carta; ogni riga è una scelta del designer, qui c'è solo la prima
stesura. Le carte di oggi (`data/cards-v2.json`) sono il punto di partenza: dove un valore
non cambia lo si dice.

Perché l'era 1 e non la 2: si simula dalla strada vuota senza inventare uno stato di
partenza; quel che si costruisce qui è quel che crolla e si riscopre dopo (l'evento ha
forza 2 e sei edifici su quindici hanno resistenza 1: sono le prime rovine, il materiale
dello Scavo); la manopola dell'era singola è la più semplice con N = 1. Il limite è noto:
nell'era 1 Scavo e scheletri non si vedono, si misurano con la coppia 1-2.

## Le regole della prova

Le costanti nuove del file dati, tutte spente nella v2 e nella v1.5:

| costante | valore nella prova | nota |
|---|---|---|
| `turno_v3` | vero | il lavoratore è un Personaggio; l'attivazione aggiunge la sua produzione e la sua azione |
| `draft_passaggio` | `{"mano": 4, "direzione": "alternata"}` | era 1, 3, 5 a destra; 2 e 4 a sinistra; a 2 giocatori non cambia nulla |
| `personaggi_per_era` | 16 | mescolati, 4 a testa, gli altri fuori senza guardarli |
| `risorse_muoiono` | vero | a fine era le risorse vanno a 0 al posto della dispersione; si parte da 0 anche nell'era 1 |
| `resource_cap`, `resource_cap_per_resource` | 0 (nessun tetto) | il tetto serviva a limitare gli avanzi, che ora muoiono da soli |
| `dinastia` | spenta | niente quinto lavoratore nella prova |
| `azione_edificio` | `"proprietario"` | l'azione speciale di un edificio scatta per chi lo possiede, a ogni attivazione della colonna, di chiunque |
| `event_force_by_era.1` | 2 | come oggi |
| terreni, `produzione_base` | 0 | il terreno di base non produce: resta la tessera dell'era (registro 157) |
| `spianare_costo` | 1 | spianare caro (registro 152): niente sconto a chi spiana il proprio edificio |
| costi dell'era 1 | +1 della seconda risorsa della classe | Commercio e Civico +1 Denaro, Religione e Cultura +1 Idea, Ingegneria e Militare +1 Costruzione; le case della riserva come sono (registro 157) |
| Ripari | costo 1, ◈ Costruzione o Denaro | la casa che si compra sempre (registro 157) |
| `potenzia_adiacente` | vero | i potenziamenti anche nelle colonne accanto a quella attivata (registri 126, 159) |
| `acquisto_extra` | spento | l'acquisto extra arriva solo dall'azione ⊕ di una carta (due Personaggi, due edifici, una tessera); la variante `extra_sempre` lo dà a ogni turno |

Ordine dell'attivazione: la tessera della colonna (produzione, poi effetto se non ancora
usato); ogni edificio in piedi nella colonna, di chiunque (produzione al proprietario, poi
azione al proprietario); il Personaggio (produzione, poi azione, a chi lo ha piazzato);
infine l'azione del turno, facoltativa.

Il draft: si danno 4 carte a testa; ognuno ne tiene una e passa le altre al vicino; si
ripete finché resta una carta sola, che si tiene. Le 4 carte prese sono i 4 lavoratori
dell'era. A fine era i Personaggi vanno fra gli scheletri possibili, come oggi.

## Le tessere dell'era 1

Restano quelle di oggi, 7 tipi in 2 copie (registro 121):

| tessera | produce | effetto (una volta per era) |
|---|---|---|
| Campi arati | ⚒1 | il primo edificio da 2 o 3 caselle costruito qui costa 1 Costruzione in meno |
| Radura | 💡1 | il primo Civico costruito qui ha +1 Lampo |
| Sentiero dei pastori | 🪙1 | chi attiva per primo ⊕ può comprare ancora un potenziamento o una casa in quel turno (registro 157; era +1 Denaro) |
| Terra di nessuno | 🪙1 | il primo edificio costruito qui ignora il requisito di terreno |
| Recinto di pietre | ⚒1 | il primo edificio costruito qui ha +1 resistenza fino a fine era |
| Luogo sacro | 💡1 | il primo Religione costruito qui costa 1 Idea in meno |
| Raccoglitori | ⚒1 | chi attiva per primo può cambiare 1 Costruzione in 1 Idea |

Le quattro tessere che non producevano niente danno Denaro o Idee dal registro 159: il terreno di
base non produce più, e Denaro e Idee erano troppo pochi per i costi misti.

## I 16 Personaggi

Tre per classe, due per Ingegneria e Militare (16 = 3 × 4 + 2 × 2). Cinque sono quelli di
oggi riscritti nella sagoma nuova (produzione + azione), undici sono nuovi. La produzione
è di 1 risorsa; chi ne produce 2 non ha azione. Le icone sono quelle del vocabolario del
metro.

| # | Personaggio | classe | produce | azione (quando lo piazzi) |
|---|---|---|---|---|
| 1 | Capotribù | Civico | ⚒1 | ⊕ in questo turno puoi comprare ancora un potenziamento o una casa (registro 157; era 🛡 +1 res) |
| 2 | Anziana del villaggio | Civico | 🪙1 | ⇄ cambia 1 risorsa in un'altra |
| 3 | Cacciatore | Civico | ⚒1 | ✦ +1 Lampo all'edificio che costruisci in questo turno |
| 4 | Sciamano | Religione | 💡1 | ★ +1 PV se hai un edificio Religione in piedi in questa colonna |
| 5 | Guardiano del fuoco | Religione | 💡1 | 🛡 +1 res fino a fine era a ogni tuo Religione in questa colonna |
| 6 | Custode delle ossa | Religione | 💡1 | ⚱ +1 Scavo permanente a un tuo edificio in questa colonna |
| 7 | Mercante di ossidiana | Commercio | 🪙1 | ⊕ in questo turno puoi comprare ancora un potenziamento o una casa (registro 157; era ⇄ 2 cambi) |
| 8 | Barattatore | Commercio | 🪙1 💡1 | nessuna |
| 9 | Portatore di sale | Commercio | 🪙1 | 👥 +1 Denaro per ogni altro giocatore con un edificio in questa colonna (max 2) |
| 10 | Incisore | Cultura | 💡1 | ⚱ +2 Scavo permanente a un tuo edificio in questa colonna (l'Impronta di oggi, senza carta sotto) |
| 11 | Cantastorie | Cultura | 💡1 | ★ +1 PV |
| 12 | Pittore delle grotte | Cultura | 💡1 | − il potenziamento Arte che compri in questo turno costa 1 in meno |
| 13 | Costruttore di zattere | Ingegneria | ⚒1 | − −1 Costruzione se costruisci su fiume in questo turno |
| 14 | Tagliapietre | Ingegneria | ⚒1 | − −1 Costruzione alla costruzione di questo turno |
| 15 | Guerriero | Militare | ⚒1 | 🛡 +2 res fino a fine era all'edificio su cui sta |
| 16 | Sentinella | Militare | 🪙1 | 🛡 +1 res fino a fine era a ogni tuo edificio in questa colonna |

Conti del metro: ogni Personaggio vale 1 risorsa più un'azione da circa 1 PV, cioè 2 PV
per piazzamento; 4 piazzamenti sono 8 PV di valore a testa per era, uguali per tutti.
La differenza la fa **dove** lo si piazza (una colonna con i propri Religione per il
Guardiano, una colonna affollata per il Portatore di sale) e **chi** si toglie agli altri
nel draft. Il Barattatore è il metro di paragone: 2 risorse e niente da leggere.

Produzione dei 16 messi insieme: ⚒7, 🪙6, 💡6 (il Barattatore conta due volte; registro 159, erano
10/4/5 prima del tuning). A 3 giocatori se ne usano 12.

## I 15 edifici

Dodici nel mazzo, tre case in riserva. Resistenza, Lampo, Rendita e Scavo sono quelli di
oggi salvo dove la nota lo dice; i **costi** in tabella sono quelli della scheda, e il file
base aggiunge a ciascuno (case escluse) **+1 della seconda risorsa della classe** (registro
157: Capanne ⚒1 🪙1, Dolmen ⚒1 💡2, Grotte dipinte 💡2, Villaggio palizzato ⚒2...); la **produzione** resta (quasi tutta a zero) e
l'**azione** è nuova. L'azione scatta per il proprietario a ogni attivazione della
colonna, di chiunque: circa due volte per era.

| edificio | classe | terreno | costo | res | Lampo | Rendita | Scavo | produce | azione | nota |
|---|---|---|---|---|---|---|---|---|---|---|
| Capanne | Civico | pianura | ⚒1 🪙1 | 1 | 1 | — | 2 | ⚒1 | ⊕ a ogni tua attivazione: puoi comprare ancora un potenziamento o una casa | registro 157; era ⇄ |
| Palafitte | Civico | fiume | ⚒1 | 2 | 1 | — | 2 | ⚒1 | 🪙 +1 Denaro | |
| Focolare comune | Civico | pianura | ⚒1 | 1 | 1 | — | 2 | — | ⚒ +1 Costruzione | oggi "quando lo attivi": ora a ogni attivazione |
| Dolmen | Religione | collina | ⚒1 💡1 | 3 | — | **1** | 3 | — | 🛡 +1 res fino a fine era a un tuo edificio adiacente | Rendita da 2 a 1, da misurare contro il 2 di oggi (metro: fino a 4 censimenti; vita media oggi 2,2 ere) |
| Menhir | Religione | bosco | ⚒1 💡1 | 4 | — | **1** | 3 | — | 💡 +1 Idea | Rendita da 2 a 1, come il Dolmen |
| Circolo di pietre | Religione | — | ⚒2 💡1 | 4 | — | 2 | 5 | — | ★ +1 PV se hai 2+ Religione in piedi | resta a 2: costa 3 e vuole la collezione |
| Approdo | Commercio | fiume | ⚒1 | 1 | — | — | 2 | ⚒1 | 🪙 +1 Denaro se chi attiva non sei tu | premia la colonna viva |
| Cava | Commercio | pianura | ⚒1 🪙1 | 1 | — | — | 2 | ⚒2 | ⊕ a ogni tua attivazione: puoi comprare ancora un potenziamento o una casa | registro 157; era ⇄ |
| Grotte dipinte | Cultura | collina | 💡1 | 2 | — | — | 6 | — | 💡 +1 Idea | la carta dello Scavo: cade all'evento e vale 6 se riscoperta |
| Tumulo funerario | Religione, Cultura | collina, 2 caselle | ⚒1 💡1 | 3 | 1 | — | 5 | — | ⚱ +1 Scavo permanente a un tuo edificio adiacente | |
| Trappole da pesca | Ingegneria | fiume | ⚒1 | 1 | — | — | 0 | ⚒1 | ⚒ +1 Costruzione se chi attiva sei tu | |
| Villaggio palizzato | Militare | pianura | ⚒1 | 2 | 2 | — | 3 | — | 🛡 +1 res fino a fine era ai tuoi edifici adiacenti | oggi "negli eventi": ora azione |
| Capanne di fango (casa, 2 copie) | Civico | — | ⚒1 | 2 | 1 | — | 1 | — | nessuna | le case sono case |
| Case di pietra (casa, 2 copie) | Civico | — | ⚒2 | 2 | 2 | — | 1 | — | nessuna | |
| Ripari (casa, 2 copie) | Civico | — | ⚒1 | 1 | 1 | — | 2 | — | nessuna | |

Conti del metro, per strategia:
- **Lampo**: Case di pietra 2 → 2 PV, Villaggio palizzato 1 → 2 PV più la protezione dei
  vicini: con 4 costruzioni da Lampo si fanno 6-8 PV nell'era, più ✦ del Cacciatore e la
  Radura. Sotto il budget di 10-12: se la misura lo conferma, il Lampo delle case sale di 1.
- **Rendita**: Dolmen e Menhir a Rendita 1 valgono 4 PV ciascuno se reggono fino alla fine
  (costano 2), il Circolo 8 (costa 3). Tre edifici Religione nell'era 1 sono 3 PV di
  censimento a fine era 1 e 12 a fine partita, se nessuno crolla: è il budget del metro.
- **Scavo**: Grotte dipinte (res 2, Scavo 6, costo 1) e Tumulo (Scavo 5) sono le carte da
  far crollare apposta, con Custode delle ossa e Incisore sopra. Il valore si vede solo
  dall'era 2 in su.
- **Generi**: tre Religione (Dolmen, Menhir, Circolo) o quattro Civici (Capanne,
  Palafitte, Focolare, una casa) nell'era 1 sono già 3 PV di collezione, e il Circolo e lo
  Sciamano premiano la collezione dentro l'era.

## I 10 potenziamenti

Restano quelli di oggi, costo 1: Pittura rupestre (💡1: +1 PV, +2 Scavo), Idolo e Totem
(💡1: +1 PV), Palizzata, Fondamenta in pietra e Argine (⚒1: +1 res), Granaio comune
(🪙1: +1 Costruzione quando l'edificio si attiva), Focolare (🪙1: +1 Idea), Recinto per il
bestiame (🪙1: +1 Denaro), Ossario (🪙1: +2 Scavo). Sono già nella sagoma del metro (una
voce sola) e sono il pozzo delle Idee e del Denaro dell'era 1: 1 risorsa → 1 PV o 1
resistenza. Da controllare nella misura quanti se ne comprano: oggi nell'era 1 pochi.

## I 6 eventi

Restano quelli di oggi, forza 2: Diluvio (fiume −1), Età degli spiriti (Religione +1,
Commercio −1), Migrazione (non protetti −1), Inverno lungo (bosco e collina −1, tutti
perdono 1 Costruzione: con le risorse che muoiono a fine era la perdita non vale più
niente, da riscrivere), Faide tribali (Militare +1, Civico −2), Carestia primitiva (livello 0
non protetti che producono −2). Con il 🛡 dei Personaggi la protezione torna una scelta
di piazzamento: la misura dirà quanti edifici a resistenza 1 reggono.

## Che cosa si misura

Trecento partite a 3 giocatori, seme 700000, tutte le strategie, fermate a fine era 1:

```bash
S=/percorso/di/godot
$S --headless res://scenes/audit_partita.tscn -- --players 3 --games 300 --seed 700000 \
  --giro tutte --dati data/proposte/cards-v3-era1.json --rapporto 1 --fino_era 1 > e1.csv 2> e1.err
```

La tabella, a giocatore e per strategia:

| | cosa dice |
|---|---|
| prodotto ⚒ 🪙 💡 | `cum_e1_*`: il budget è 10-12 |
| speso | prodotto meno `resta_e1_*` |
| **morto** | `resta_e1_*`: il budget è 1-2; sopra, più ⇄ e ★ nelle carte |
| PV dell'era per canale | Lampo, PV prodotti, Censimento |
| costruiti, potenziati | quante delle 4 azioni si usano |
| crollati all'evento | quanti e quali; quante rovine lascia l'era 1 all'era 2 (oggi 3,1 a partita su 11,7 edifici costruiti nell'era 1) |
| Personaggi | quante volte ciascuno è preso e a quale giro del draft (1°, 2°, 3°, l'ultima) |
| vittorie per strategia | con l'errore a 3 giocatori (±5 su 33) |

Un Personaggio preso sempre al primo giro è troppo forte; uno che arriva sempre per ultimo
è da rifare. È la misura più diretta del draft, e l'unica che non si può fare a mano.

## La prima misura (1 ottobre, trentunesima misura)

Fatta: 300 ere 1 da sole, 3 giocatori (`docs/la-terza-risorsa.md`, trentunesima
misura, registro 155). In breve: prodotto 14,0 a testa, speso 5,4, **morto 8,7**;
4 costruzioni e 0 potenziamenti; Lampo 5,6 PV e Rendita 1,2 di censimento; il
Guerriero sempre primo nel draft, il Custode delle ossa sempre ultimo. Il pozzo
manca: e' il primo punto da decidere. Le tabelle complete le fa
`python3 tools/misura_era.py e1.err`.

Secondo giro, le leve del pozzo (registro 156): la **catena** (terreno di base che non produce,
**acquisto extra** dopo l'azione del turno, spianare caro) spende 7,0 e lascia morire 3,1; con i
**costi misti** (+1 della seconda risorsa della classe) il morto e' 2,3 e la Lampo scende al 55%.
Le varianti sono file generati: `tools/genera_cards_v3.py --variante catena` eccetera.

Terzo giro (registri 157-158), con la catena e i costi misti nel file base, l'extra solo dalle
carte e il bot che sa che le risorse muoiono: prodotto 8,7, speso 7,2, **morto 1,5**. La
mancanza c'e'. Ma si costruiscono 5 case a partita su 11 edifici, i potenziamenti spariscono e
l'acquisto extra si usa un quarto delle volte che si apre: le proposte sono nella trentaduesima
misura.

Quarto giro (registro 159, trentatreesima misura), il tuning delle risorse: Denaro 2,6 e Idee 3,0
prodotti a testa, potenziamenti 0,46, case 3,6 a partita, morto 2,2, Lampo al 37% con le strategie
fra 19 e 41. L'economia dell'era 1 è nel metro o sul suo bordo.

## Che cosa serve nel codice

1. Il generatore `tools/genera_cards_v3.py` (o una variante del v2) che scrive
   `data/proposte/cards-v3-era1.json`: le costanti sopra, i 16 Personaggi con `produzione`
   e `azione`, gli edifici dell'era 1 con `azione`. Le ere 2-5 restano quelle della v2 nel
   file, così la partita non si rompe se la si lascia andare oltre.
2. Il draft a passaggio nel controller (oggi: uno a testa in ordine di turno fra tutti
   quelli dell'era): mani di 4, scelta, passaggio, direzione per era.
3. Il piazzamento: si sceglie quale Personaggio, non solo dove; l'attivazione aggiunge la
   sua produzione e la sua azione dopo gli edifici.
4. L'azione degli edifici nell'attivazione, al proprietario.
5. Fine era: azzeramento al posto di `disperse`; nessun tetto.
6. I bot: valutare la mano del draft e la coppia Personaggio-colonna; una strategia
   Ritrovamenti (scheletri e arte) in più.
7. La manopola `--fino_era N` nell'audit: **fatta** in questo ramo (fermati a era N chiusa;
   l'intestazione si stampa solo se la manopola è data, la v1.5 resta identica).

Stato al 1 ottobre: i punti 1-5 e 7 sono **fatti** in questo ramo (`tools/genera_cards_v3.py`,
`scripts/rules/personaggi_v3.gd`, il controller, `tools/misura_era.py`); del punto 6 c'è la
scelta del Personaggio e della colonna provando ogni coppia su una copia della partita e la
valutazione delle carte al draft, mancano il bot che sa che le risorse muoiono e la strategia
Ritrovamenti. L'interfaccia a schermo non conosce ancora la v3: il file di prova non è fra
quelli che la schermata di gioco offre.
