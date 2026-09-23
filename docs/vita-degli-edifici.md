# La vita degli edifici

Misurata su **10 000 partite** a 3 giocatori, rigiocate dal motore vero (`scripts/tools/audit_partita.gd`, modalità `--vita`). In tutto 298 315 edifici costruiti.

> **Chi ha giocato.** I bot seguono le sei strategie (`StrategyBot`): Rendita, Lampo, Scavo, Verticale, Bilanciata, Obiettivi.
> Valutano tutte le mosse legali e pagabili e scelgono la
> migliore secondo la loro inclinazione; la strategia ruota di posto a ogni partita, così
> nessuna gioca sempre dalla stessa sedia. Non sono campioni — non bluffano, non
> guardano cosa stanno per fare gli altri — ma **giocano**: dove il bot casuale fa 66
> punti, questi ne fanno 120.

## Come leggere le colonne

| colonna | cosa misura |
|---|---|
| **per partita** | quante copie di quella carta finiscono in tavola in una partita |
| **ere intatto** | quante ere resta INTATTO, contando quella in cui è stato costruito. 1,0 = diventa rudere alla fine dell'era stessa in cui è nato |
| **ere in piedi** | quante ere resta in piedi, cioè finché non crolla in rovina o finisce sotterrato |
| **subito** | quota che cade o viene sepolto nell'era stessa in cui è stato costruito |
| **a fine partita** | quota ancora in piedi all'ultimo conteggio |
| **sepolto** | quota che finisce sotto un altro edificio (e quindi paga lo Scavo) |
| **vetustà** | cubetti bianchi accumulati, letti a fine partita |
| **vita sfruttata** | ere in piedi su quelle che poteva vivere: una carta dell'era 4 al massimo ne vive 2, una dell'era 5 una sola. È l'unica misura confrontabile fra ere diverse |
| **PV** | punti che quella carta ha fruttato, in media, in tutta la partita |
| **PV/costo** | gli stessi punti divisi per il costo in pietra equivalente (1 oro = 2 pietra) |

I PV sono attribuiti **alla carta, non al giocatore**: un edificio restaurato e rubato
porta con sé anche i punti che aveva fatto fare al padrone di prima. I canali contati
sono i cinque che si possono attribuire a un edificio senza inventare nulla:

- **Lampo** — il punto alla costruzione;
- **Rendita** — incassata a ogni censimento finché l'edificio è intatto, più la Vetustà;
- **Verticalità** — metà del premio della colonna a chi ha la cima, l'altra metà divisa
  per numero di edifici: è la regola stessa a dividerla per carta, quindi la quota di un
  edificio è un numero vero;
- **Scavo** — il valore stampato, se finisce sotterrato;
- **Scheletri** — il personaggio sepolto sotto, se l'edificio è sotterrato.

Restano fuori **Continuità** (è della colonna, non di una carta), **Monumenti**,
**Eredità** e la **Cultura** (vanno al giocatore). Il conto dei cinque canali torna
esatto col tabellone: c'è un test che lo verifica su partite intere
(`test_actions`, «il libro mastro degli edifici torna col tabellone»).

## Il quadro d'insieme

| era | carte | costruiti/partita | ere intatto | ere in piedi | subito | a fine partita | sepolto | PV medi |
|---|--:|--:|--:|--:|--:|--:|--:|--:|
| era 1 | 12 | 7.5 | 2.36 | 2.87 | 13% | 28% | 52% | 6.9 |
| era 2 | 12 | 5.8 | 2.06 | 2.48 | 4% | 19% | 59% | 6.5 |
| era 3 | 12 | 5.9 | 1.41 | 1.94 | 19% | 9% | 74% | 5.5 |
| era 4 | 12 | 6.1 | 1.24 | 1.57 | 43% | 17% | 61% | 5.9 |
| era 5 | 12 | 4.5 | 1.00 | 1.00 | 0% | 100% | 0% | 11.2 |

In media una partita mette in tavola **29.8 edifici**; di questi **31%** è ancora in piedi alla fine, **52%** finisce sotterrato e **16%** non supera l'era in cui è nato.

## Cosa salta all'occhio

**1. La Rendita è il canale che paga la durata, ed è quasi tutto.** Le 15 carte con Rendita stampata fruttano in media **9.0 PV** contro i **5.9** delle altre, e restano in piedi 2.85 ere contro 1.62. Non è una sorpresa — la Rendita si incassa a ogni censimento — ma dice che il valore di una carta lo decide quasi tutto un numero solo.

**2. La resistenza fa esattamente il suo mestiere.** Sulle ere 1-4, per ogni punto di resistenza:

| resistenza | carte | ere in piedi | cade nella sua era | PV medi |
|---|--:|--:|--:|--:|
| 1 | 7 | 1.62 | 41% | 3.3 |
| 2 | 17 | 1.74 | 36% | 4.2 |
| 3 | 14 | 2.49 | 8% | 6.4 |
| 4 | 8 | 3.03 | 3% | 10.1 |
| 5 | 2 | 2.41 | 2% | 9.9 |

Fra resistenza 1 e resistenza 4 la vita raddoppia e i punti quasi triplicano. Il salto vero è **fra 2 e 3**: è lì che un edificio smette di essere materiale da riempimento.

**3. Le carte da una pietra dell'era 1 non sono edifici: sono Scavo da seminare.** Approdo, Capanne, Cava, Focolare comune, Grotte dipinte, Palafitte, Trappole da pesca vivono 2.0 ere, finiscono sotto nel **66%** dei casi e 36 punti su cento di quello che fruttano sono Scavo. Funzionano — ma solo se chi le gioca sa che le sta seminando, non costruendo.

**4. Un edificio dell'era 5 non può morire.** Gli eventi sono solo nelle ere 1-4: chi costruisce nell'era Moderna non vedrà mai un censimento né un evento. Si vede nei numeri: vetustà **0.00**, Rendita **0.00**, Scavo **0.00**, e il **100%** ancora in piedi. Le carte dell'era 5 pagano solo Lampo e Verticalità, e vanno lette con un metro diverso dalle altre: il loro valore è tutto nell'istante in cui le metti.

**5. I colossali prendono la cima di tre colonne.** Un edificio da tre caselle conta come strato in tutte le colonne che tocca — quindi incassa il premio della cima **tre volte**:

| larghezza | carte | costruiti | PV medi | di cui Verticalità |
|---|--:|--:|--:|--:|
| 1 casella | 41 | 197 298 | 5.5 | 1.6 |
| 2 caselle | 16 | 80 313 | 9.4 | 4.1 |
| 3 caselle | 3 | 20 704 | 12.5 | 5.9 |

Il caso limite è la **Stazione** (era 5, tre caselle, 2P+4O): **25.7 PV medi**, di cui 21.7 di sola Verticalità — contro i 17.6 della seconda della lista, Università. Arriva in tavola una volta ogni 3 partite, quindi non rompe la media, ma quando arriva decide la colonna. Vale la pena chiedersi se il premio della cima debba contare una volta per edificio invece che una volta per colonna.

## Gli estremi

### Le dodici vite più brevi

Ordinate per **vita sfruttata**, non per ere secche: se no in testa finirebbero le carte dell'era 5, che vivono una sola era perché la partita finisce, non perché crollano.

| carta | costo | res | rend | scavo | per partita | ere intatto | ere in piedi | vita sfruttata | subito | a fine partita | sepolto | vetustà | PV | PV/costo | (L/R/V/S/Sk) |
|---|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|---|
| Capanne | 1P | 1 | 0 | 2 | 0.96 | 1.06 | 1.68 | 34% | 37% | 0% | 71% | 0.06 | **3.9** | 3.9 | 1.0/0.0/1.2/1.3/0.3 |
| Cava | 1P | 1 | 0 | 2 | 1.00 | 1.05 | 1.76 | 35% | 28% | 0% | 70% | 0.05 | **2.9** | 2.9 | 0.0/0.0/1.2/1.3/0.4 |
| Trappole da pesca | 1P | 1 | 0 | 0 | 0.02 | 1.00 | 1.80 | 36% | 20% | 0% | 0% | 0.00 | **1.0** | 1.0 | 0.0/0.0/1.0/0.0/0.0 |
| Approdo | 1P | 1 | 0 | 2 | 0.38 | 1.00 | 1.84 | 37% | 17% | 0% | 55% | 0.00 | **2.5** | 2.5 | 0.0/0.0/1.2/1.2/0.1 |
| Villaggio palizzato | 2P | 2 | 0 | 2 | 0.16 | 1.75 | 2.09 | 42% | 2% | 2% | 93% | 0.70 | **5.2** | 2.6 | 1.0/0.0/2.5/0.7/1.0 |
| Focolare comune | 1P | 1 | 0 | 2 | 0.02 | 1.25 | 2.10 | 42% | 12% | 2% | 55% | 0.19 | **3.2** | 3.2 | 1.0/0.0/1.1/1.1/0.0 |
| Conceria | 1P | 1 | 0 | 0 | 0.06 | 1.00 | 1.27 | 42% | 73% | 0% | 87% | 0.00 | **2.3** | 2.3 | 1.0/0.0/1.0/0.1/0.2 |
| Palafitte | 1P | 2 | 0 | 2 | 0.95 | 1.47 | 2.20 | 44% | 7% | 2% | 70% | 0.42 | **3.6** | 3.6 | 1.0/0.0/1.3/1.0/0.3 |
| Sacello | 1P | 2 | 0 | 3 | 0.43 | 1.16 | 1.96 | 49% | 12% | 1% | 69% | 0.15 | **4.0** | 4.0 | 1.0/0.0/1.0/1.9/0.1 |
| Torre di vedetta | 2P | 3 | 0 | 2 | 0.00 | 1.84 | 2.00 | 50% | 4% | 0% | 100% | 0.84 | **2.8** | 1.4 | 1.0/0.0/1.4/0.5/0.0 |
| Emporio | 2P | 2 | 0 | 2 | 0.04 | 1.25 | 2.01 | 50% | 0% | 0% | 93% | 0.25 | **4.1** | 2.0 | 1.0/0.0/1.2/1.5/0.4 |
| Giardino all'italiana | 0P+2O | 1 | 0 | 0 | 0.46 | 1.00 | 1.03 | 51% | 97% | 1% | 42% | 0.00 | **3.9** | 1.0 | 3.0/0.0/0.9/0.0/0.0 |

### Le dodici che arrivano in fondo

Ordinate per vita sfruttata.

| carta | costo | res | rend | scavo | per partita | ere intatto | ere in piedi | vita sfruttata | subito | a fine partita | sepolto | vetustà | PV | PV/costo | (L/R/V/S/Sk) |
|---|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|---|
| Fortezza bastionata | 3P+2O | 5 | 3 | 2 | 0.64 | 1.85 | 2.00 | 100% | 0% | 16% | 74% | 0.85 | **8.4** | 1.2 | 0.0/4.0/3.6/0.2/0.5 |
| Fondazione d'arte | 1P+2O | 2 | 0 | 0 | 0.52 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **7.4** | 1.5 | 3.0/0.0/4.4/0.0/0.0 |
| Condominio | 1P+1O | 2 | 0 | 0 | 0.71 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **7.0** | 2.3 | 2.0/0.0/5.0/0.0/0.0 |
| Caffè letterario | 0P+2O | 1 | 0 | 0 | 0.12 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **5.9** | 1.5 | 2.0/0.0/3.9/0.0/0.0 |
| Officina | 1P+1O | 2 | 0 | 0 | 0.70 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **6.8** | 2.3 | 2.0/0.0/4.8/0.0/0.0 |
| Monumento ai caduti | 1P+2O | 3 | 0 | 0 | 0.21 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **6.7** | 1.3 | 2.0/0.0/4.7/0.0/0.0 |
| Museo | 1P+3O | 3 | 0 | 0 | 0.21 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **9.6** | 1.4 | 4.0/0.0/5.6/0.0/0.0 |
| Grattacielo | 2P+4O | 3 | 0 | 0 | 0.01 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **10.2** | 1.0 | 4.0/0.0/6.2/0.0/0.0 |
| Biblioteca | 1P+3O | 3 | 0 | 0 | 0.32 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **8.0** | 1.1 | 4.0/0.0/4.0/0.0/0.0 |
| Ponte in acciaio | 1P+3O | 4 | 0 | 0 | 0.43 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **14.5** | 2.1 | 4.0/0.0/10.5/0.0/0.0 |
| Stazione | 2P+4O | 4 | 0 | 0 | 0.31 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **25.7** | 2.6 | 4.0/0.0/21.7/0.0/0.0 |
| Parco archeologico | 1P+2O | 2 | 0 | 0 | 0.47 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **15.5** | 3.1 | 2.0/0.0/13.5/0.0/0.0 |

### Le dodici che rendono di più

Ordinate per PV medi fruttati al proprietario.

| carta | costo | res | rend | scavo | per partita | ere intatto | ere in piedi | vita sfruttata | subito | a fine partita | sepolto | vetustà | PV | PV/costo | (L/R/V/S/Sk) |
|---|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|---|
| Stazione | 2P+4O | 4 | 0 | 0 | 0.31 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **25.7** | 2.6 | 4.0/0.0/21.7/0.0/0.0 |
| Università | 2P+3O | 3 | 0 | 0 | 0.50 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **17.6** | 2.2 | 4.0/0.0/13.6/0.0/0.0 |
| Parco archeologico | 1P+2O | 2 | 0 | 0 | 0.47 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **15.5** | 3.1 | 2.0/0.0/13.5/0.0/0.0 |
| Ponte in acciaio | 1P+3O | 4 | 0 | 0 | 0.43 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **14.5** | 2.1 | 4.0/0.0/10.5/0.0/0.0 |
| Circolo di pietre | 3P | 4 | 1 | 5 | 1.00 | 3.79 | 3.99 | 80% | 3% | 64% | 32% | 1.89 | **13.2** | 4.4 | 0.0/10.7/2.1/0.0/0.5 |
| Menhir | 2P | 4 | 1 | 3 | 1.00 | 3.73 | 4.07 | 81% | 5% | 62% | 32% | 1.82 | **12.0** | 6.0 | 0.0/10.3/1.1/0.1/0.6 |
| Dolmen | 2P | 3 | 1 | 3 | 1.00 | 3.69 | 4.16 | 83% | 6% | 64% | 23% | 1.66 | **11.4** | 5.7 | 0.0/10.0/1.0/0.0/0.4 |
| Anfiteatro | 5P | 5 | 2 | 6 | 0.91 | 2.68 | 2.70 | 68% | 3% | 27% | 55% | 1.64 | **11.0** | 2.2 | 0.0/7.4/3.2/0.0/0.5 |
| Grattacielo | 2P+4O | 3 | 0 | 0 | 0.01 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **10.2** | 1.0 | 4.0/0.0/6.2/0.0/0.0 |
| Museo | 1P+3O | 3 | 0 | 0 | 0.21 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **9.6** | 1.4 | 4.0/0.0/5.6/0.0/0.0 |
| Acquedotto | 3P | 4 | 1 | 3 | 0.84 | 2.75 | 2.87 | 72% | 8% | 38% | 40% | 1.62 | **9.3** | 3.1 | 0.0/6.0/2.9/0.0/0.3 |
| Duomo | 3P+3O | 4 | 4 | 5 | 0.56 | 1.79 | 2.00 | 100% | 0% | 14% | 77% | 0.79 | **9.0** | 1.0 | 0.0/4.6/3.0/0.8/0.6 |

### Le dodici che rendono di più per quello che costano

Ordinate per PV diviso il costo in pietra equivalente.

| carta | costo | res | rend | scavo | per partita | ere intatto | ere in piedi | vita sfruttata | subito | a fine partita | sepolto | vetustà | PV | PV/costo | (L/R/V/S/Sk) |
|---|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|---|
| Menhir | 2P | 4 | 1 | 3 | 1.00 | 3.73 | 4.07 | 81% | 5% | 62% | 32% | 1.82 | **12.0** | 6.0 | 0.0/10.3/1.1/0.1/0.6 |
| Dolmen | 2P | 3 | 1 | 3 | 1.00 | 3.69 | 4.16 | 83% | 6% | 64% | 23% | 1.66 | **11.4** | 5.7 | 0.0/10.0/1.0/0.0/0.4 |
| Circolo di pietre | 3P | 4 | 1 | 5 | 1.00 | 3.79 | 3.99 | 80% | 3% | 64% | 32% | 1.89 | **13.2** | 4.4 | 0.0/10.7/2.1/0.0/0.5 |
| Sacello | 1P | 2 | 0 | 3 | 0.43 | 1.16 | 1.96 | 49% | 12% | 1% | 69% | 0.15 | **4.0** | 4.0 | 1.0/0.0/1.0/1.9/0.1 |
| Capanne | 1P | 1 | 0 | 2 | 0.96 | 1.06 | 1.68 | 34% | 37% | 0% | 71% | 0.06 | **3.9** | 3.9 | 1.0/0.0/1.2/1.3/0.3 |
| Palafitte | 1P | 2 | 0 | 2 | 0.95 | 1.47 | 2.20 | 44% | 7% | 2% | 70% | 0.42 | **3.6** | 3.6 | 1.0/0.0/1.3/1.0/0.3 |
| Parco archeologico | 1P+2O | 2 | 0 | 0 | 0.47 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **15.5** | 3.1 | 2.0/0.0/13.5/0.0/0.0 |
| Acquedotto | 3P | 4 | 1 | 3 | 0.84 | 2.75 | 2.87 | 72% | 8% | 38% | 40% | 1.62 | **9.3** | 3.1 | 0.0/6.0/2.9/0.0/0.3 |
| Cava | 1P | 1 | 0 | 2 | 1.00 | 1.05 | 1.76 | 35% | 28% | 0% | 70% | 0.05 | **2.9** | 2.9 | 0.0/0.0/1.2/1.3/0.4 |
| Stazione | 2P+4O | 4 | 0 | 0 | 0.31 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **25.7** | 2.6 | 4.0/0.0/21.7/0.0/0.0 |
| Approdo | 1P | 1 | 0 | 2 | 0.38 | 1.00 | 1.84 | 37% | 17% | 0% | 55% | 0.00 | **2.5** | 2.5 | 0.0/0.0/1.2/1.2/0.1 |
| Borgo | 2P | 2 | 0 | 2 | 0.78 | 1.01 | 1.70 | 57% | 32% | 2% | 78% | 0.01 | **4.9** | 2.5 | 2.0/0.0/1.0/1.6/0.4 |

### Le dodici che rendono di meno

Solo carte che arrivano in tavola almeno una volta ogni cinque partite: una carta rara ha medie ballerine.

| carta | costo | res | rend | scavo | per partita | ere intatto | ere in piedi | vita sfruttata | subito | a fine partita | sepolto | vetustà | PV | PV/costo | (L/R/V/S/Sk) |
|---|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|---|
| Grotte dipinte | 1P | 2 | 0 | 6 | 0.38 | 2.17 | 2.81 | 56% | 11% | 12% | 47% | 0.81 | **1.9** | 1.9 | 0.0/0.0/1.1/0.6/0.1 |
| Approdo | 1P | 1 | 0 | 2 | 0.38 | 1.00 | 1.84 | 37% | 17% | 0% | 55% | 0.00 | **2.5** | 2.5 | 0.0/0.0/1.2/1.2/0.1 |
| Cava | 1P | 1 | 0 | 2 | 1.00 | 1.05 | 1.76 | 35% | 28% | 0% | 70% | 0.05 | **2.9** | 2.9 | 0.0/0.0/1.2/1.3/0.4 |
| Banco | 1P+1O | 2 | 0 | 0 | 0.57 | 1.00 | 1.25 | 63% | 75% | 8% | 60% | 0.00 | **3.3** | 1.1 | 2.0/0.0/1.2/0.0/0.1 |
| Insulae | 2P | 2 | 0 | 2 | 0.52 | 1.32 | 2.08 | 52% | 1% | 2% | 69% | 0.31 | **3.5** | 1.8 | 1.0/0.0/1.1/1.0/0.4 |
| Mulino | 2P | 2 | 0 | 2 | 0.32 | 1.06 | 1.88 | 63% | 18% | 6% | 63% | 0.05 | **3.5** | 1.8 | 1.0/0.0/1.0/1.2/0.3 |
| Palafitte | 1P | 2 | 0 | 2 | 0.95 | 1.47 | 2.20 | 44% | 7% | 2% | 70% | 0.42 | **3.6** | 3.6 | 1.0/0.0/1.3/1.0/0.3 |
| Giardino all'italiana | 0P+2O | 1 | 0 | 0 | 0.46 | 1.00 | 1.03 | 51% | 97% | 1% | 42% | 0.00 | **3.9** | 1.0 | 3.0/0.0/0.9/0.0/0.0 |
| Capanne | 1P | 1 | 0 | 2 | 0.96 | 1.06 | 1.68 | 34% | 37% | 0% | 71% | 0.06 | **3.9** | 3.9 | 1.0/0.0/1.2/1.3/0.3 |
| Tumulo funerario | 2P | 3 | 0 | 5 | 0.64 | 2.39 | 2.69 | 54% | 5% | 17% | 64% | 1.04 | **3.9** | 2.0 | 1.0/0.0/2.2/0.0/0.7 |
| Mercato | 2P | 2 | 0 | 2 | 0.38 | 1.04 | 1.70 | 57% | 32% | 2% | 79% | 0.04 | **3.9** | 2.0 | 1.0/0.0/1.0/1.6/0.3 |
| Sacello | 1P | 2 | 0 | 3 | 0.43 | 1.16 | 1.96 | 49% | 12% | 1% | 69% | 0.15 | **4.0** | 4.0 | 1.0/0.0/1.0/1.9/0.1 |

### Le dodici più sepolte

Ordinate per quota di copie finite sotto un altro edificio.

| carta | costo | res | rend | scavo | per partita | ere intatto | ere in piedi | vita sfruttata | subito | a fine partita | sepolto | vetustà | PV | PV/costo | (L/R/V/S/Sk) |
|---|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|---|
| Torre di vedetta | 2P | 3 | 0 | 2 | 0.00 | 1.84 | 2.00 | 50% | 4% | 0% | 100% | 0.84 | **2.8** | 1.4 | 1.0/0.0/1.4/0.5/0.0 |
| Arsenale | 3P+1O | 3 | 0 | 2 | 0.25 | 1.65 | 1.98 | 66% | 4% | 1% | 95% | 0.65 | **5.5** | 1.1 | 2.0/0.0/2.1/0.7/0.7 |
| Emporio | 2P | 2 | 0 | 2 | 0.04 | 1.25 | 2.01 | 50% | 0% | 0% | 93% | 0.25 | **4.1** | 2.0 | 1.0/0.0/1.2/1.5/0.4 |
| Villaggio palizzato | 2P | 2 | 0 | 2 | 0.16 | 1.75 | 2.09 | 42% | 2% | 2% | 93% | 0.70 | **5.2** | 2.6 | 1.0/0.0/2.5/0.7/1.0 |
| Castello | 2P+1O | 4 | 3 | 3 | 0.76 | 2.07 | 2.15 | 72% | 0% | 6% | 92% | 1.07 | **7.8** | 2.0 | 0.0/4.8/2.1/0.2/0.8 |
| Castrum | 3P | 4 | 0 | 3 | 0.04 | 2.13 | 2.14 | 54% | 2% | 8% | 91% | 1.13 | **4.1** | 1.4 | 1.0/0.0/2.3/0.0/0.8 |
| Conceria | 1P | 1 | 0 | 0 | 0.06 | 1.00 | 1.27 | 42% | 73% | 0% | 87% | 0.00 | **2.3** | 2.3 | 1.0/0.0/1.0/0.1/0.2 |
| Mercato | 2P | 2 | 0 | 2 | 0.38 | 1.04 | 1.70 | 57% | 32% | 2% | 79% | 0.04 | **3.9** | 2.0 | 1.0/0.0/1.0/1.6/0.3 |
| Borgo | 2P | 2 | 0 | 2 | 0.78 | 1.01 | 1.70 | 57% | 32% | 2% | 78% | 0.01 | **4.9** | 2.5 | 2.0/0.0/1.0/1.6/0.4 |
| Torre civica | 2P | 3 | 0 | 2 | 0.67 | 1.20 | 2.02 | 67% | 7% | 8% | 78% | 0.20 | **4.7** | 2.3 | 2.0/0.0/1.0/1.3/0.4 |
| Duomo | 3P+3O | 4 | 4 | 5 | 0.56 | 1.79 | 2.00 | 100% | 0% | 14% | 77% | 0.79 | **9.0** | 1.0 | 0.0/4.6/3.0/0.8/0.6 |
| Piazza monumentale | 2P+2O | 3 | 2 | 3 | 0.19 | 1.57 | 1.94 | 97% | 6% | 12% | 77% | 0.57 | **7.2** | 1.2 | 0.0/2.0/3.8/1.1/0.4 |

## Tutte le carte, era per era

### Era 1

| carta | costo | res | rend | scavo | per partita | ere intatto | ere in piedi | vita sfruttata | subito | a fine partita | sepolto | vetustà | PV | PV/costo | (L/R/V/S/Sk) |
|---|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|---|
| Dolmen | 2P | 3 | 1 | 3 | 1.00 | 3.69 | 4.16 | 83% | 6% | 64% | 23% | 1.66 | **11.4** | 5.7 | 0.0/10.0/1.0/0.0/0.4 |
| Menhir | 2P | 4 | 1 | 3 | 1.00 | 3.73 | 4.07 | 81% | 5% | 62% | 32% | 1.82 | **12.0** | 6.0 | 0.0/10.3/1.1/0.1/0.6 |
| Circolo di pietre | 3P | 4 | 1 | 5 | 1.00 | 3.79 | 3.99 | 80% | 3% | 64% | 32% | 1.89 | **13.2** | 4.4 | 0.0/10.7/2.1/0.0/0.5 |
| Grotte dipinte | 1P | 2 | 0 | 6 | 0.38 | 2.17 | 2.81 | 56% | 11% | 12% | 47% | 0.81 | **1.9** | 1.9 | 0.0/0.0/1.1/0.6/0.1 |
| Tumulo funerario | 2P | 3 | 0 | 5 | 0.64 | 2.39 | 2.69 | 54% | 5% | 17% | 64% | 1.04 | **3.9** | 2.0 | 1.0/0.0/2.2/0.0/0.7 |
| Palafitte | 1P | 2 | 0 | 2 | 0.95 | 1.47 | 2.20 | 44% | 7% | 2% | 70% | 0.42 | **3.6** | 3.6 | 1.0/0.0/1.3/1.0/0.3 |
| Focolare comune | 1P | 1 | 0 | 2 | 0.02 | 1.25 | 2.10 | 42% | 12% | 2% | 55% | 0.19 | **3.2** | 3.2 | 1.0/0.0/1.1/1.1/0.0 |
| Villaggio palizzato | 2P | 2 | 0 | 2 | 0.16 | 1.75 | 2.09 | 42% | 2% | 2% | 93% | 0.70 | **5.2** | 2.6 | 1.0/0.0/2.5/0.7/1.0 |
| Approdo | 1P | 1 | 0 | 2 | 0.38 | 1.00 | 1.84 | 37% | 17% | 0% | 55% | 0.00 | **2.5** | 2.5 | 0.0/0.0/1.2/1.2/0.1 |
| Trappole da pesca | 1P | 1 | 0 | 0 | 0.02 | 1.00 | 1.80 | 36% | 20% | 0% | 0% | 0.00 | **1.0** | 1.0 | 0.0/0.0/1.0/0.0/0.0 |
| Cava | 1P | 1 | 0 | 2 | 1.00 | 1.05 | 1.76 | 35% | 28% | 0% | 70% | 0.05 | **2.9** | 2.9 | 0.0/0.0/1.2/1.3/0.4 |
| Capanne | 1P | 1 | 0 | 2 | 0.96 | 1.06 | 1.68 | 34% | 37% | 0% | 71% | 0.06 | **3.9** | 3.9 | 1.0/0.0/1.2/1.3/0.3 |

### Era 2

| carta | costo | res | rend | scavo | per partita | ere intatto | ere in piedi | vita sfruttata | subito | a fine partita | sepolto | vetustà | PV | PV/costo | (L/R/V/S/Sk) |
|---|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|---|
| Acquedotto | 3P | 4 | 1 | 3 | 0.84 | 2.75 | 2.87 | 72% | 8% | 38% | 40% | 1.62 | **9.3** | 3.1 | 0.0/6.0/2.9/0.0/0.3 |
| Ponte | 3P | 3 | 1 | 3 | 0.34 | 2.28 | 2.85 | 71% | 1% | 33% | 41% | 1.10 | **6.5** | 2.2 | 0.0/4.1/1.9/0.2/0.2 |
| Anfiteatro | 5P | 5 | 2 | 6 | 0.91 | 2.68 | 2.70 | 68% | 3% | 27% | 55% | 1.64 | **11.0** | 2.2 | 0.0/7.4/3.2/0.0/0.5 |
| Foro | 3P | 3 | 1 | 5 | 0.85 | 2.20 | 2.58 | 64% | 3% | 24% | 60% | 1.08 | **6.5** | 2.2 | 0.0/3.6/2.0/0.3/0.6 |
| Tempio | 3P | 3 | 1 | 3 | 0.65 | 1.91 | 2.52 | 63% | 4% | 19% | 59% | 0.79 | **4.5** | 1.5 | 0.0/2.6/0.9/0.7/0.3 |
| Teatro | 2P | 3 | 0 | 5 | 0.65 | 1.85 | 2.34 | 59% | 1% | 12% | 70% | 0.72 | **4.2** | 2.1 | 2.0/0.0/1.1/0.9/0.2 |
| Castrum | 3P | 4 | 0 | 3 | 0.04 | 2.13 | 2.14 | 54% | 2% | 8% | 91% | 1.13 | **4.1** | 1.4 | 1.0/0.0/2.3/0.0/0.8 |
| Insulae | 2P | 2 | 0 | 2 | 0.52 | 1.32 | 2.08 | 52% | 1% | 2% | 69% | 0.31 | **3.5** | 1.8 | 1.0/0.0/1.1/1.0/0.4 |
| Terme | 2P | 2 | 0 | 3 | 0.48 | 1.38 | 2.08 | 52% | 1% | 2% | 69% | 0.36 | **4.6** | 2.3 | 2.0/0.0/1.1/1.2/0.3 |
| Emporio | 2P | 2 | 0 | 2 | 0.04 | 1.25 | 2.01 | 50% | 0% | 0% | 93% | 0.25 | **4.1** | 2.0 | 1.0/0.0/1.2/1.5/0.4 |
| Torre di vedetta | 2P | 3 | 0 | 2 | 0.00 | 1.84 | 2.00 | 50% | 4% | 0% | 100% | 0.84 | **2.8** | 1.4 | 1.0/0.0/1.4/0.5/0.0 |
| Sacello | 1P | 2 | 0 | 3 | 0.43 | 1.16 | 1.96 | 49% | 12% | 1% | 69% | 0.15 | **4.0** | 4.0 | 1.0/0.0/1.0/1.9/0.1 |

### Era 3

| carta | costo | res | rend | scavo | per partita | ere intatto | ere in piedi | vita sfruttata | subito | a fine partita | sepolto | vetustà | PV | PV/costo | (L/R/V/S/Sk) |
|---|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|---|
| Mura | 2P | 4 | 0 | 2 | 0.09 | 2.09 | 2.36 | 79% | 0% | 26% | 72% | 1.04 | **2.7** | 1.4 | 1.0/0.0/1.2/0.3/0.3 |
| Abbazia | 2P+2O | 3 | 3 | 5 | 0.72 | 1.90 | 2.34 | 78% | 3% | 32% | 49% | 0.88 | **8.1** | 1.3 | 0.0/5.3/1.8/0.7/0.3 |
| Castello | 2P+1O | 4 | 3 | 3 | 0.76 | 2.07 | 2.15 | 72% | 0% | 6% | 92% | 1.07 | **7.8** | 2.0 | 0.0/4.8/2.1/0.2/0.8 |
| Chiesa | 2P+1O | 3 | 2 | 3 | 0.71 | 1.67 | 2.09 | 70% | 17% | 19% | 65% | 0.65 | **5.0** | 1.3 | 0.0/2.8/0.8/1.1/0.3 |
| Torre civica | 2P | 3 | 0 | 2 | 0.67 | 1.20 | 2.02 | 67% | 7% | 8% | 78% | 0.20 | **4.7** | 2.3 | 2.0/0.0/1.0/1.3/0.4 |
| Arsenale | 3P+1O | 3 | 0 | 2 | 0.25 | 1.65 | 1.98 | 66% | 4% | 1% | 95% | 0.65 | **5.5** | 1.1 | 2.0/0.0/2.1/0.7/0.7 |
| Mulino | 2P | 2 | 0 | 2 | 0.32 | 1.06 | 1.88 | 63% | 18% | 6% | 63% | 0.05 | **3.5** | 1.8 | 1.0/0.0/1.0/1.2/0.3 |
| Borgo | 2P | 2 | 0 | 2 | 0.78 | 1.01 | 1.70 | 57% | 32% | 2% | 78% | 0.01 | **4.9** | 2.5 | 2.0/0.0/1.0/1.6/0.4 |
| Mercato | 2P | 2 | 0 | 2 | 0.38 | 1.04 | 1.70 | 57% | 32% | 2% | 79% | 0.04 | **3.9** | 2.0 | 1.0/0.0/1.0/1.6/0.3 |
| Ospedale dei pellegrini | 2P+1O | 2 | 0 | 2 | 0.33 | 1.01 | 1.64 | 55% | 36% | 0% | 76% | 0.01 | **4.6** | 1.1 | 2.0/0.0/0.9/1.5/0.1 |
| Cappella | 1P+1O | 2 | 0 | 3 | 0.83 | 1.03 | 1.64 | 55% | 37% | 1% | 77% | 0.03 | **5.4** | 1.8 | 2.0/0.0/0.9/2.2/0.2 |
| Conceria | 1P | 1 | 0 | 0 | 0.06 | 1.00 | 1.27 | 42% | 73% | 0% | 87% | 0.00 | **2.3** | 2.3 | 1.0/0.0/1.0/0.1/0.2 |

### Era 4

| carta | costo | res | rend | scavo | per partita | ere intatto | ere in piedi | vita sfruttata | subito | a fine partita | sepolto | vetustà | PV | PV/costo | (L/R/V/S/Sk) |
|---|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|---|
| Fortezza bastionata | 3P+2O | 5 | 3 | 2 | 0.64 | 1.85 | 2.00 | 100% | 0% | 16% | 74% | 0.85 | **8.4** | 1.2 | 0.0/4.0/3.6/0.2/0.5 |
| Duomo | 3P+3O | 4 | 4 | 5 | 0.56 | 1.79 | 2.00 | 100% | 0% | 14% | 77% | 0.79 | **9.0** | 1.0 | 0.0/4.6/3.0/0.8/0.6 |
| Ponte monumentale | 2P+2O | 4 | 3 | 3 | 0.49 | 1.76 | 1.99 | 99% | 1% | 49% | 43% | 0.76 | **7.4** | 1.2 | 0.0/4.8/2.1/0.2/0.2 |
| Piazza monumentale | 2P+2O | 3 | 2 | 3 | 0.19 | 1.57 | 1.94 | 97% | 6% | 12% | 77% | 0.57 | **7.2** | 1.2 | 0.0/2.0/3.8/1.1/0.4 |
| Villa | 2P+2O | 3 | 0 | 3 | 0.78 | 1.03 | 1.83 | 91% | 17% | 34% | 58% | 0.03 | **6.9** | 1.2 | 4.0/0.0/1.0/1.7/0.2 |
| Palazzo signorile | 2P+2O | 3 | 0 | 3 | 0.69 | 1.01 | 1.76 | 88% | 24% | 28% | 63% | 0.01 | **6.2** | 1.0 | 3.0/0.0/1.1/1.9/0.2 |
| Osservatorio | 1P+2O | 2 | 0 | 2 | 0.07 | 1.00 | 1.35 | 67% | 65% | 17% | 41% | 0.00 | **3.6** | 0.7 | 2.0/0.0/0.7/0.8/0.0 |
| Banco | 1P+1O | 2 | 0 | 0 | 0.57 | 1.00 | 1.25 | 63% | 75% | 8% | 60% | 0.00 | **3.3** | 1.1 | 2.0/0.0/1.2/0.0/0.1 |
| Loggia | 1P+1O | 2 | 0 | 2 | 0.66 | 1.00 | 1.24 | 62% | 76% | 6% | 61% | 0.00 | **4.4** | 1.5 | 2.0/0.0/1.1/1.2/0.1 |
| Accademia | 1P+2O | 2 | 0 | 3 | 0.35 | 1.00 | 1.15 | 57% | 85% | 6% | 56% | 0.00 | **4.7** | 0.9 | 2.0/0.0/1.0/1.7/0.0 |
| Bottega d'artista | 1P+1O | 2 | 0 | 2 | 0.68 | 1.00 | 1.15 | 57% | 85% | 6% | 60% | 0.00 | **4.4** | 1.5 | 2.0/0.0/1.1/1.2/0.0 |
| Giardino all'italiana | 0P+2O | 1 | 0 | 0 | 0.46 | 1.00 | 1.03 | 51% | 97% | 1% | 42% | 0.00 | **3.9** | 1.0 | 3.0/0.0/0.9/0.0/0.0 |

### Era 5

| carta | costo | res | rend | scavo | per partita | ere intatto | ere in piedi | vita sfruttata | subito | a fine partita | sepolto | vetustà | PV | PV/costo | (L/R/V/S/Sk) |
|---|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|---|
| Fondazione d'arte | 1P+2O | 2 | 0 | 0 | 0.52 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **7.4** | 1.5 | 3.0/0.0/4.4/0.0/0.0 |
| Condominio | 1P+1O | 2 | 0 | 0 | 0.71 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **7.0** | 2.3 | 2.0/0.0/5.0/0.0/0.0 |
| Caffè letterario | 0P+2O | 1 | 0 | 0 | 0.12 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **5.9** | 1.5 | 2.0/0.0/3.9/0.0/0.0 |
| Officina | 1P+1O | 2 | 0 | 0 | 0.70 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **6.8** | 2.3 | 2.0/0.0/4.8/0.0/0.0 |
| Monumento ai caduti | 1P+2O | 3 | 0 | 0 | 0.21 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **6.7** | 1.3 | 2.0/0.0/4.7/0.0/0.0 |
| Museo | 1P+3O | 3 | 0 | 0 | 0.21 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **9.6** | 1.4 | 4.0/0.0/5.6/0.0/0.0 |
| Grattacielo | 2P+4O | 3 | 0 | 0 | 0.01 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **10.2** | 1.0 | 4.0/0.0/6.2/0.0/0.0 |
| Biblioteca | 1P+3O | 3 | 0 | 0 | 0.32 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **8.0** | 1.1 | 4.0/0.0/4.0/0.0/0.0 |
| Ponte in acciaio | 1P+3O | 4 | 0 | 0 | 0.43 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **14.5** | 2.1 | 4.0/0.0/10.5/0.0/0.0 |
| Stazione | 2P+4O | 4 | 0 | 0 | 0.31 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **25.7** | 2.6 | 4.0/0.0/21.7/0.0/0.0 |
| Parco archeologico | 1P+2O | 2 | 0 | 0 | 0.47 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **15.5** | 3.1 | 2.0/0.0/13.5/0.0/0.0 |
| Università | 2P+3O | 3 | 0 | 0 | 0.50 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **17.6** | 2.2 | 4.0/0.0/13.6/0.0/0.0 |

## Due correlazioni, su chi arriva in tavola almeno 50 volte

- **resistenza stampata** → ere in piedi: r = +0.38 · → PV: r = +0.54
- **costo in pietra** → ere in piedi: r = +0.56 · → PV: r = +0.24
- **Rendita stampata** → ere in piedi: r = +0.35 · → PV: r = +0.20
- **Scavo stampato** → ere in piedi: r = +0.72 · → PV: r = -0.15

---

Rifare il conto: `godot --headless res://scenes/audit_partita.tscn -- --players 3 --vita 2500 --seed 100000` (quattro processi, semi 100000 / 102500 / 105000 / 107500).

## Cosa cambia con 6 strategie al tavolo

Le stesse misure su 10000 partite con **5 strategie** e 10000 con **6 strategie**, a parità di tutto il resto: stessi semi, stesso numero di giocatori. La colonna Δ è la seconda meno la prima.

| misura | 5 strategie | 6 strategie | Δ |
|---|--:|--:|--:|
| edifici costruiti per partita | 30.12 | 29.83 | −0.28 |
| ere intatto (media) | 1.68 | 1.68 | +0.00 |
| ere in piedi (media) | 2.06 | 2.06 | −0.00 |
| cade nella sua era | 16% | 16% | +0% |
| in piedi a fine partita | 31% | 31% | +0% |
| sepolto | 52% | 52% | −0% |
| vetustà media | 0.55 | 0.55 | +0.00 |
| potenziamenti per edificio | 0.04 | 0.05 | +0.01 |
| PV per edificio | 7.0 | 7.0 | +0.0 |
| PV per partita (i tre giocatori insieme) | 211 | 209 | −2 |

| canale (PV per partita, tutti i giocatori) | 5 strategie | 6 strategie | Δ |
|---|--:|--:|--:|
| Lampo | 37.3 | 36.9 | −0.4 |
| Rendita | 65.8 | 66.2 | +0.4 |
| Verticalita | 77.9 | 76.4 | −1.5 |
| Scavo | 21.3 | 20.8 | −0.5 |
| Scheletri | 8.2 | 8.6 | +0.3 |

### Le carte che si cercano di più

Copie costruite per partita, prima e dopo.

| carta | era | costo | 5 strategie | 6 strategie | Δ | PV 5 strategie | PV 6 strategie |
|---|--:|--:|--:|--:|--:|--:|--:|
| Approdo | 1 | 1P | 0.30 | 0.38 | +0.08 | 2.7 | 2.5 |
| Banco | 4 | 1P+1O | 0.52 | 0.57 | +0.05 | 3.3 | 3.3 |
| Insulae | 2 | 2P | 0.49 | 0.52 | +0.03 | 3.6 | 3.5 |
| Monumento ai caduti | 5 | 1P+2O | 0.18 | 0.21 | +0.03 | 7.4 | 6.7 |
| Mulino | 3 | 2P | 0.30 | 0.32 | +0.03 | 3.5 | 3.5 |
| Mercato | 3 | 2P | 0.36 | 0.38 | +0.03 | 4.0 | 3.9 |
| Officina | 5 | 1P+1O | 0.68 | 0.70 | +0.02 | 7.0 | 6.8 |
| Conceria | 3 | 1P | 0.04 | 0.06 | +0.02 | 2.3 | 2.3 |
| Bottega d'artista | 4 | 1P+1O | 0.67 | 0.68 | +0.01 | 4.4 | 4.4 |
| Fortezza bastionata | 4 | 3P+2O | 0.63 | 0.64 | +0.01 | 8.5 | 8.4 |

### E quelle che si cercano di meno

Le stesse carte, dall'altro capo della classifica.

| carta | era | costo | 5 strategie | 6 strategie | Δ | PV 5 strategie | PV 6 strategie |
|---|--:|--:|--:|--:|--:|--:|--:|
| Teatro | 2 | 2P | 0.75 | 0.65 | −0.10 | 4.1 | 4.2 |
| Grotte dipinte | 1 | 1P | 0.45 | 0.38 | −0.07 | 1.9 | 1.9 |
| Tumulo funerario | 1 | 2P | 0.69 | 0.64 | −0.05 | 3.9 | 3.9 |
| Torre civica | 3 | 2P | 0.72 | 0.67 | −0.04 | 4.6 | 4.7 |
| Ospedale dei pellegrini | 3 | 2P+1O | 0.37 | 0.33 | −0.04 | 4.5 | 4.6 |
| Abbazia | 3 | 2P+2O | 0.77 | 0.72 | −0.04 | 8.1 | 8.1 |
| Chiesa | 3 | 2P+1O | 0.75 | 0.71 | −0.04 | 5.0 | 5.0 |
| Accademia | 4 | 1P+2O | 0.39 | 0.35 | −0.04 | 4.7 | 4.7 |
| Terme | 2 | 2P | 0.52 | 0.48 | −0.04 | 4.6 | 4.6 |
| Sacello | 2 | 1P | 0.46 | 0.43 | −0.03 | 3.9 | 4.0 |

### Carte che non arrivano quasi mai in tavola

- **Torre di vedetta** (era 2, 2P) — una ogni 400 partite, contro una ogni 263 prima
- **Grattacielo** (era 5, 2P+4O) — una ogni 128 partite, contro una ogni 112 prima
- **Trappole da pesca** (era 1, 1P) — una ogni 60 partite, contro una ogni 192 prima
- **Focolare comune** (era 1, 1P) — una ogni 53 partite, contro una ogni 58 prima

