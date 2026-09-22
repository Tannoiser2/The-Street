# Mappatura sagoma → edificio

La corrispondenza fra le sagome del PDF e gli edifici non è scritta da nessuna
parte e non è derivabile dall'ordine: il PDF impagina i pezzi per ingombro, non
per era. L'ho ricavata **riconoscendo le illustrazioni una per una**.

Il risultato sta in `data/sagome.json`: numero della sagoma in ordine di
estrazione (`tools/estrai_grafica.py`), per id dell'edificio.

**54 su 60 assegnate**, di cui 50 senza dubbi e 4 da confermare. Sotto: cosa
resta aperto, e tre cose che il confronto ha fatto emergere.

## Tre scoperte, prima delle carte aperte

### 1. Il cartone e i dati non concordano su tre larghezze

Le sagome si quantizzano su un modulo di 60,3 mm: 61 / 121 / 181 mm sono 1, 2 e
3 slot. Contate: **41 da 1 slot, 16 da 2, 3 da 3**. I dati dicono invece **44,
13, 3**. Tre edifici che il JSON dà da 1 slot sul cartone ne occupano 2.

Due li ho riconosciuti, e sono entrambi ponti:

| edificio | sagoma | `width` nei dati | sul cartone |
|---|---|---|---|
| Ponte monumentale | 48 | 1 | **2** |
| Ponte in acciaio | 57 | 1 | **2** |

Il terzo è fra le sagome ancora aperte. Che i ponti siano larghi due slot ha un
senso evidente — un ponte scavalca — e fa sospettare che anche il **Ponte**
dell'era 2 sia da 2, il che chiuderebbe il conto. Va deciso dal designer: è la
stessa famiglia di problema del punto 35 delle domande aperte, dove il testo
dell'Acquedotto dice 2 slot mentre dati, regolamento e badge dicono 3.

### 2. Due illustrazioni sono duplicate

- la sagoma **26** e la **33** sono lo stesso identico disegno (una chiesa
  romanica con campanile);
- la **29** e la **35** pure (un mulino ad acqua con ruota e ponticello).

Quindi il PDF contiene **58 illustrazioni distinte, non 60**: due edifici non
hanno una sagoma propria.

### 3. Il Ponte dell'era 2 non ha una sagoma

Fra le sagome non assegnate non c'è nessun ponte. Sommato al punto precedente,
il conto torna: mancano due disegni, e uno dei due è il Ponte.

## Le sei ancora aperte

| sagoma | cosa raffigura | candidati |
|---|---|---|
| 15 e 24 | due fori romani quasi identici: portico, colonna onoraria, tempio | **Foro** è uno dei due; l'altro non lo so |
| 26 e 33 | la stessa chiesa romanica | **Cappella**, e l'altra copia è di un edificio senza disegno proprio |
| 29 e 35 | lo stesso mulino | **Mulino**, stessa situazione |
| 49 e 53 | due edifici museali con vessilli rossi | **Museo** e **Fondazione d'arte**, ordine da stabilire |
| 56 e 59 | due scene archeologiche | **Parco archeologico** è una delle due |
| — | nessuna immagine plausibile | **Mercato**, **Ospedale dei pellegrini**, **Università**, **Ponte** |

In `data/sagome.json` ho messo la lettura più probabile per Foro (15),
Cappella (26), Mulino (29) e Parco archeologico (56). Sono quattro voci da
confermare con un'occhiata, non quattro certezze.

## Come rifare il lavoro

```bash
python3 tools/estrai_grafica.py        # estrae le sagome numerate in assets/
```

I fogli numerati per il confronto si rigenerano dal PDF; il numero stampato è
l'indice di estrazione, cioè la chiave di `data/sagome.json`.
