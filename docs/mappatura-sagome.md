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

## Le tre larghezze, e come si sono chiuse

Contate: **41 sagome da 1 slot, 16 da 2, 3 da 3**. I dati dicevano **44, 13,
3**: tre edifici erano da 1 nel JSON e da 2 sul cartone.

Avevo proposto Ponte monumentale, Ponte in acciaio e **Mercato**. Il designer
ha risposto una cosa più semplice e più forte: **i ponti sono tutti da 2
slot**, compreso il Ponte dell'era 2.

Quella risposta chiude il conto in modo esatto. Portando a 2 i tre ponti, gli
edifici larghi 2 diventano **16**, cioè esattamente quante sono le sagome da 2
slot: ogni edificio largo trova la sua sagoma larga, e non avanza niente. Il
Mercato resta percio' da 1 slot, e la mia terza ipotesi era sbagliata.

| edificio | sagoma | `width` prima | ora |
|---|---|---|---|
| Ponte | 24 | 1 | **2** |
| Ponte monumentale | 48 | 1 | **2** |
| Ponte in acciaio | 57 | 1 | **2** |

**Conseguenza misurata**, non stimata: su 100 partite a 3 giocatori i ponti si
costruiscono meno, perché un edificio largo 2 trova meno posto — il Ponte da 56
a 36 volte, il Ponte monumentale da 34 a 28, il Ponte in acciaio da 9 a 7. Il
requisito «fiume» però chiede *almeno una* colonna di fiume nell'ingombro, non
tutte, quindi allargarsi non li rende irraggiungibili.

Il confronto con l'oracolo resta entro il limite documentato e i quattro
canali esatti restano esatti.

## Due disegni serviti a due carte ciascuno

- la sagoma **26** (Cappella) e la **33** (Ospedale dei pellegrini) sono lo
  stesso identico disegno: una chiesa romanica con campanile;
- la **29** (Mulino) e la **35** (Mercato) pure: un mulino ad acqua con ruota.

Verificato confrontando gli hash dei 60 file, non a occhio: le coppie identiche
sono esattamente queste due, e le illustrazioni distinte sono **58 per 60
carte**. Da decidere se è voluto o se due carte aspettano ancora il proprio
disegno.

**Una terza carta ha un disegno che non la raffigura.** La sagoma 24, che per
aritmetica appartiene al **Ponte**, mostra un foro romano con portici, colonna
onoraria e tempio — nessun ponte. Non è un duplicato (gli hash lo escludono):
è una seconda illustrazione di foro, diversa da quella del Foro vero (15). Le
due sono intercambiabili per quel che si vede, quindi quale delle due appartiene
al Foro e quale al Ponte lo decide il designer; il gioco non cambia.

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
