# Mappatura sagoma → edificio

La corrispondenza fra le sagome del PDF e gli edifici non è scritta da nessuna
parte e non è derivabile dall'ordine: il PDF impagina i pezzi per ingombro, non
per era. L'ho ricavata **riconoscendo le illustrazioni una per una** e
chiudendo il resto **per esclusione sulla larghezza**.

Il risultato sta in `data/sagome.json`: numero della sagoma in ordine di
estrazione (`tools/estrai_grafica.py`), per id dell'edificio.

**60 edifici, 60 sagome, ciascuna usata una volta sola.** La mappatura è una
biiezione: non avanza niente e non manca niente. Restano però tre cose da
decidere, e una lettura che non so verificare da solo.

## Come si è chiusa

Le sagome si quantizzano su un modulo di 60,3 mm: 61 / 121 / 181 mm sono 1, 2 e
3 slot. Questo ha fatto da vincolo. Riconosciute a vista 50 illustrazioni, ne
restavano 10 per 10 edifici; e poiché le sagome da 2 slot libere erano due
mentre l'unico edificio `width` 2 rimasto era uno solo, **una delle due doveva
per forza essere un edificio che i dati danno da 1 slot**. È così che è emersa
la terza discrepanza.

## Tre larghezze che il cartone e i dati non dicono uguali

Contate: **41 sagome da 1 slot, 16 da 2, 3 da 3**. I dati dicono **44, 13, 3**.

| edificio | sagoma | `width` nei dati | sul cartone |
|---|---|---|---|
| Ponte monumentale | 48 | 1 | **2** |
| Ponte in acciaio | 57 | 1 | **2** |
| Mercato | 24 | 1 | **2** |

I primi due sono ponti, e che un ponte scavalchi due slot ha un senso evidente.
Il terzo è il Mercato, la cui sagoma raffigura un foro romano con portici,
colonna onoraria e tempio: un mercato largo, non un banco.

**Nessun dato di gioco è stato modificato.** Le larghezze restano come sono
finché il designer non decide: cambiare `width` sposta costi, sepolture e
verticalità, quindi non è una correzione da fare di mia iniziativa.

## Due disegni serviti a due carte ciascuno

- la sagoma **26** (Cappella) e la **33** (Ospedale dei pellegrini) sono lo
  stesso identico disegno: una chiesa romanica con campanile;
- la **29** (Mulino) e la **35** (Ponte) pure: un mulino ad acqua con ruota,
  che però sorge accanto a un ponte ad arco — il che rende l'immagine
  comprensibile anche come Ponte.

Il PDF contiene quindi **58 illustrazioni distinte per 60 carte**. Da decidere
se è voluto o se due carte aspettano ancora il proprio disegno.

## L'unica lettura che non so verificare

Le sagome **49** e **53** sono due edifici museali quasi indistinguibili,
entrambi con vessilli rossi e statue. Ho messo 49 = Fondazione d'arte e
53 = Museo, ma è una scelta, non un riconoscimento: se vanno invertite basta
scambiare due numeri.

## Una correzione a quanto avevo proposto

Nella prima versione avevo proposto 56 = Parco archeologico, e il designer
l'aveva confermata. **Guardando meglio col vincolo dell'esclusione ho corretto:
56 = Università, 59 = Parco archeologico.** Il 56 mostra colonne davanti a un
grande edificio a cupola fra i cipressi — un campus; il 59 mostra un arco di
trionfo e basi di colonne sparse lungo un sentiero — uno scavo. La conferma era
arrivata su una mia lettura sbagliata, quindi la segnalo invece di lasciarla
passare.

## Come rifare il lavoro

```bash
python3 tools/estrai_grafica.py        # estrae le sagome numerate in assets/
```

Il numero stampato è l'indice di estrazione, cioè la chiave di
`data/sagome.json`.
