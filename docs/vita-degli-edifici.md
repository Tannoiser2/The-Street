# La vita degli edifici

Misurata su **10 000 partite** a 3 giocatori, rigiocate dal motore vero (`scripts/tools/audit_partita.gd`, modalità `--vita`). In tutto 293 344 edifici costruiti.

> **Chi ha giocato.** I bot seguono le cinque strategie (`StrategyBot`): Rendita, Lampo,
> Scavo, Verticale, Bilanciata. Valutano tutte le mosse legali e pagabili e scelgono la
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
| era 1 | 12 | 7.8 | 2.35 | 2.88 | 13% | 27% | 47% | 6.4 |
| era 2 | 12 | 5.9 | 2.03 | 2.47 | 5% | 20% | 60% | 6.3 |
| era 3 | 12 | 6.1 | 1.40 | 1.95 | 19% | 11% | 73% | 5.5 |
| era 4 | 12 | 5.7 | 1.24 | 1.58 | 42% | 20% | 58% | 6.3 |
| era 5 | 12 | 3.8 | 1.00 | 1.00 | 0% | 100% | 0% | 11.6 |

In media una partita mette in tavola **29.3 edifici**; di questi **30%** è ancora in piedi alla fine, **51%** finisce sotterrato e **16%** non supera l'era in cui è nato.

## Cosa salta all'occhio

**1. La Rendita è il canale che paga la durata, ed è quasi tutto.** Le 15 carte con Rendita stampata fruttano in media **9.0 PV** contro i **5.7** delle altre, e restano in piedi 2.85 ere contro 1.69. Non è una sorpresa — la Rendita si incassa a ogni censimento — ma dice che il valore di una carta lo decide quasi tutto un numero solo.

**2. La resistenza fa esattamente il suo mestiere.** Sulle ere 1-4, per ogni punto di resistenza:

| resistenza | carte | ere in piedi | cade nella sua era | PV medi |
|---|--:|--:|--:|--:|
| 1 | 7 | 1.67 | 38% | 3.0 |
| 2 | 17 | 1.77 | 34% | 4.2 |
| 3 | 14 | 2.50 | 9% | 6.2 |
| 4 | 8 | 3.07 | 3% | 10.1 |
| 5 | 2 | 2.40 | 3% | 10.0 |

Fra resistenza 1 e resistenza 4 la vita raddoppia e i punti quasi triplicano. Il salto vero è **fra 2 e 3**: è lì che un edificio smette di essere materiale da riempimento.

**3. Le carte da una pietra dell'era 1 non sono edifici: sono Scavo da seminare.** Approdo, Capanne, Cava, Focolare comune, Grotte dipinte, Palafitte, Trappole da pesca vivono 2.0 ere, finiscono sotto nel **58%** dei casi e 34 punti su cento di quello che fruttano sono Scavo. Funzionano — ma solo se chi le gioca sa che le sta seminando, non costruendo.

**4. Un edificio dell'era 5 non può morire.** Gli eventi sono solo nelle ere 1-4: chi costruisce nell'era Moderna non vedrà mai un censimento né un evento. Si vede nei numeri: vetustà **0.00**, Rendita **0.00**, Scavo **0.00**, e il **100%** ancora in piedi. Le carte dell'era 5 pagano solo Lampo e Verticalità, e vanno lette con un metro diverso dalle altre: il loro valore è tutto nell'istante in cui le metti.

**5. I colossali prendono la cima di tre colonne.** Un edificio da tre caselle conta come strato in tutte le colonne che tocca — quindi incassa il premio della cima **tre volte**:

| larghezza | carte | costruiti | PV medi | di cui Verticalità |
|---|--:|--:|--:|--:|
| 1 casella | 41 | 195 227 | 5.4 | 1.6 |
| 2 caselle | 16 | 77 757 | 9.2 | 4.1 |
| 3 caselle | 3 | 20 360 | 12.0 | 5.4 |

Il caso limite è la **Stazione** (era 5, tre caselle, 2P+4O): **25.5 PV medi**, di cui 21.5 di sola Verticalità — contro i 17.6 della seconda della lista, Università. Arriva in tavola una volta ogni 4 partite, quindi non rompe la media, ma quando arriva decide la colonna. Vale la pena chiedersi se il premio della cima debba contare una volta per edificio invece che una volta per colonna.

## Gli estremi

### Le dodici vite più brevi

Ordinate per **vita sfruttata**, non per ere secche: se no in testa finirebbero le carte dell'era 5, che vivono una sola era perché la partita finisce, non perché crollano.

| carta | costo | res | rend | scavo | per partita | ere intatto | ere in piedi | vita sfruttata | subito | a fine partita | sepolto | vetustà | PV | PV/costo | (L/R/V/S/Sk) |
|---|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|---|
| Capanne | 1P | 1 | 0 | 2 | 0.97 | 1.10 | 1.76 | 35% | 33% | 0% | 57% | 0.09 | **3.3** | 3.3 | 1.0/0.0/1.1/1.0/0.2 |
| Trappole da pesca | 1P | 1 | 0 | 0 | 0.02 | 1.00 | 1.80 | 36% | 21% | 0% | 0% | 0.00 | **1.0** | 1.0 | 0.0/0.0/1.0/0.0/0.0 |
| Cava | 1P | 1 | 0 | 2 | 1.00 | 1.09 | 1.81 | 36% | 26% | 0% | 60% | 0.09 | **2.5** | 2.5 | 0.0/0.0/1.1/1.0/0.3 |
| Approdo | 1P | 1 | 0 | 2 | 0.40 | 1.00 | 1.83 | 37% | 17% | 0% | 51% | 0.00 | **2.4** | 2.4 | 0.0/0.0/1.2/1.1/0.1 |
| Conceria | 1P | 1 | 0 | 0 | 0.06 | 1.00 | 1.22 | 41% | 78% | 0% | 87% | 0.00 | **2.2** | 2.2 | 1.0/0.0/1.0/0.1/0.1 |
| Focolare comune | 1P | 1 | 0 | 2 | 0.04 | 1.30 | 2.17 | 43% | 10% | 2% | 29% | 0.24 | **2.6** | 2.6 | 1.0/0.0/1.0/0.6/0.0 |
| Villaggio palizzato | 2P | 2 | 0 | 2 | 0.14 | 1.80 | 2.19 | 44% | 0% | 3% | 89% | 0.73 | **5.2** | 2.6 | 1.0/0.0/2.5/0.7/0.9 |
| Palafitte | 1P | 2 | 0 | 2 | 0.96 | 1.48 | 2.21 | 44% | 6% | 2% | 66% | 0.43 | **3.5** | 3.5 | 1.0/0.0/1.3/1.0/0.3 |
| Sacello | 1P | 2 | 0 | 3 | 0.46 | 1.15 | 1.94 | 48% | 13% | 2% | 70% | 0.14 | **3.9** | 3.9 | 1.0/0.0/1.0/1.9/0.1 |
| Emporio | 2P | 2 | 0 | 2 | 0.05 | 1.37 | 1.99 | 50% | 1% | 0% | 99% | 0.38 | **4.1** | 2.0 | 1.0/0.0/1.3/1.3/0.5 |
| Torre di vedetta | 2P | 3 | 0 | 2 | 0.00 | 1.65 | 2.02 | 51% | 0% | 0% | 100% | 0.65 | **3.5** | 1.7 | 1.0/0.0/1.4/0.8/0.4 |
| Giardino all'italiana | 0P+2O | 1 | 0 | 0 | 0.43 | 1.00 | 1.02 | 51% | 98% | 1% | 46% | 0.00 | **4.0** | 1.0 | 3.0/0.0/1.0/0.0/0.0 |

### Le dodici che arrivano in fondo

Ordinate per vita sfruttata.

| carta | costo | res | rend | scavo | per partita | ere intatto | ere in piedi | vita sfruttata | subito | a fine partita | sepolto | vetustà | PV | PV/costo | (L/R/V/S/Sk) |
|---|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|---|
| Fortezza bastionata | 3P+2O | 5 | 3 | 2 | 0.58 | 1.86 | 2.00 | 100% | 0% | 23% | 63% | 0.86 | **9.3** | 1.3 | 0.0/4.3/4.4/0.2/0.4 |
| Fondazione d'arte | 1P+2O | 2 | 0 | 0 | 0.42 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **7.6** | 1.5 | 3.0/0.0/4.6/0.0/0.0 |
| Condominio | 1P+1O | 2 | 0 | 0 | 0.64 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **7.4** | 2.5 | 2.0/0.0/5.4/0.0/0.0 |
| Caffè letterario | 0P+2O | 1 | 0 | 0 | 0.09 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **6.5** | 1.6 | 2.0/0.0/4.5/0.0/0.0 |
| Officina | 1P+1O | 2 | 0 | 0 | 0.62 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **7.2** | 2.4 | 2.0/0.0/5.2/0.0/0.0 |
| Monumento ai caduti | 1P+2O | 3 | 0 | 0 | 0.15 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **7.3** | 1.5 | 2.0/0.0/5.3/0.0/0.0 |
| Museo | 1P+3O | 3 | 0 | 0 | 0.19 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **9.6** | 1.4 | 4.0/0.0/5.6/0.0/0.0 |
| Grattacielo | 2P+4O | 3 | 0 | 0 | 0.01 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **9.6** | 1.0 | 4.0/0.0/5.6/0.0/0.0 |
| Biblioteca | 1P+3O | 3 | 0 | 0 | 0.27 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **8.2** | 1.2 | 4.0/0.0/4.2/0.0/0.0 |
| Ponte in acciaio | 1P+3O | 4 | 0 | 0 | 0.36 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **15.6** | 2.2 | 4.0/0.0/11.6/0.0/0.0 |
| Stazione | 2P+4O | 4 | 0 | 0 | 0.26 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **25.5** | 2.6 | 4.0/0.0/21.5/0.0/0.0 |
| Parco archeologico | 1P+2O | 2 | 0 | 0 | 0.42 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **15.6** | 3.1 | 2.0/0.0/13.6/0.0/0.0 |

### Le dodici che rendono di più

Ordinate per PV medi fruttati al proprietario.

| carta | costo | res | rend | scavo | per partita | ere intatto | ere in piedi | vita sfruttata | subito | a fine partita | sepolto | vetustà | PV | PV/costo | (L/R/V/S/Sk) |
|---|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|---|
| Stazione | 2P+4O | 4 | 0 | 0 | 0.26 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **25.5** | 2.6 | 4.0/0.0/21.5/0.0/0.0 |
| Università | 2P+3O | 3 | 0 | 0 | 0.43 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **17.6** | 2.2 | 4.0/0.0/13.6/0.0/0.0 |
| Ponte in acciaio | 1P+3O | 4 | 0 | 0 | 0.36 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **15.6** | 2.2 | 4.0/0.0/11.6/0.0/0.0 |
| Parco archeologico | 1P+2O | 2 | 0 | 0 | 0.42 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **15.6** | 3.1 | 2.0/0.0/13.6/0.0/0.0 |
| Menhir | 2P | 4 | 1 | 3 | 1.00 | 3.85 | 4.19 | 84% | 6% | 67% | 27% | 1.88 | **12.4** | 6.2 | 0.0/10.9/1.1/0.0/0.4 |
| Circolo di pietre | 3P | 4 | 1 | 5 | 1.00 | 3.59 | 3.86 | 77% | 3% | 58% | 34% | 1.74 | **12.1** | 4.0 | 0.0/9.7/2.1/0.0/0.3 |
| Dolmen | 2P | 3 | 1 | 3 | 1.00 | 3.57 | 4.02 | 80% | 11% | 62% | 26% | 1.52 | **10.8** | 5.4 | 0.0/9.5/1.0/0.0/0.3 |
| Anfiteatro | 5P | 5 | 2 | 6 | 0.92 | 2.63 | 2.65 | 66% | 4% | 25% | 56% | 1.59 | **10.5** | 2.1 | 0.0/7.0/3.0/0.0/0.5 |
| Duomo | 3P+3O | 4 | 4 | 5 | 0.50 | 1.79 | 1.99 | 100% | 1% | 19% | 70% | 0.79 | **9.7** | 1.1 | 0.0/4.8/3.6/0.8/0.5 |
| Museo | 1P+3O | 3 | 0 | 0 | 0.19 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **9.6** | 1.4 | 4.0/0.0/5.6/0.0/0.0 |
| Grattacielo | 2P+4O | 3 | 0 | 0 | 0.01 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **9.6** | 1.0 | 4.0/0.0/5.6/0.0/0.0 |
| Acquedotto | 3P | 4 | 1 | 3 | 0.85 | 2.79 | 2.92 | 73% | 7% | 42% | 37% | 1.64 | **9.5** | 3.2 | 0.0/6.3/2.9/0.0/0.3 |

### Le dodici che rendono di più per quello che costano

Ordinate per PV diviso il costo in pietra equivalente.

| carta | costo | res | rend | scavo | per partita | ere intatto | ere in piedi | vita sfruttata | subito | a fine partita | sepolto | vetustà | PV | PV/costo | (L/R/V/S/Sk) |
|---|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|---|
| Menhir | 2P | 4 | 1 | 3 | 1.00 | 3.85 | 4.19 | 84% | 6% | 67% | 27% | 1.88 | **12.4** | 6.2 | 0.0/10.9/1.1/0.0/0.4 |
| Dolmen | 2P | 3 | 1 | 3 | 1.00 | 3.57 | 4.02 | 80% | 11% | 62% | 26% | 1.52 | **10.8** | 5.4 | 0.0/9.5/1.0/0.0/0.3 |
| Circolo di pietre | 3P | 4 | 1 | 5 | 1.00 | 3.59 | 3.86 | 77% | 3% | 58% | 34% | 1.74 | **12.1** | 4.0 | 0.0/9.7/2.1/0.0/0.3 |
| Sacello | 1P | 2 | 0 | 3 | 0.46 | 1.15 | 1.94 | 48% | 13% | 2% | 70% | 0.14 | **3.9** | 3.9 | 1.0/0.0/1.0/1.9/0.1 |
| Palafitte | 1P | 2 | 0 | 2 | 0.96 | 1.48 | 2.21 | 44% | 6% | 2% | 66% | 0.43 | **3.5** | 3.5 | 1.0/0.0/1.3/1.0/0.3 |
| Capanne | 1P | 1 | 0 | 2 | 0.97 | 1.10 | 1.76 | 35% | 33% | 0% | 57% | 0.09 | **3.3** | 3.3 | 1.0/0.0/1.1/1.0/0.2 |
| Acquedotto | 3P | 4 | 1 | 3 | 0.85 | 2.79 | 2.92 | 73% | 7% | 42% | 37% | 1.64 | **9.5** | 3.2 | 0.0/6.3/2.9/0.0/0.3 |
| Parco archeologico | 1P+2O | 2 | 0 | 0 | 0.42 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **15.6** | 3.1 | 2.0/0.0/13.6/0.0/0.0 |
| Stazione | 2P+4O | 4 | 0 | 0 | 0.26 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **25.5** | 2.6 | 4.0/0.0/21.5/0.0/0.0 |
| Cava | 1P | 1 | 0 | 2 | 1.00 | 1.09 | 1.81 | 36% | 26% | 0% | 60% | 0.09 | **2.5** | 2.5 | 0.0/0.0/1.1/1.0/0.3 |
| Condominio | 1P+1O | 2 | 0 | 0 | 0.64 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **7.4** | 2.5 | 2.0/0.0/5.4/0.0/0.0 |
| Officina | 1P+1O | 2 | 0 | 0 | 0.62 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **7.2** | 2.4 | 2.0/0.0/5.2/0.0/0.0 |

### Le dodici che rendono di meno

Solo carte che arrivano in tavola almeno una volta ogni cinque partite: una carta rara ha medie ballerine.

| carta | costo | res | rend | scavo | per partita | ere intatto | ere in piedi | vita sfruttata | subito | a fine partita | sepolto | vetustà | PV | PV/costo | (L/R/V/S/Sk) |
|---|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|---|
| Grotte dipinte | 1P | 2 | 0 | 6 | 0.47 | 2.19 | 2.78 | 56% | 10% | 12% | 52% | 0.80 | **1.8** | 1.8 | 0.0/0.0/1.2/0.6/0.0 |
| Approdo | 1P | 1 | 0 | 2 | 0.40 | 1.00 | 1.83 | 37% | 17% | 0% | 51% | 0.00 | **2.4** | 2.4 | 0.0/0.0/1.2/1.1/0.1 |
| Cava | 1P | 1 | 0 | 2 | 1.00 | 1.09 | 1.81 | 36% | 26% | 0% | 60% | 0.09 | **2.5** | 2.5 | 0.0/0.0/1.1/1.0/0.3 |
| Mulino | 2P | 2 | 0 | 2 | 0.32 | 1.06 | 1.89 | 63% | 19% | 7% | 62% | 0.06 | **3.3** | 1.7 | 1.0/0.0/0.9/1.2/0.2 |
| Capanne | 1P | 1 | 0 | 2 | 0.97 | 1.10 | 1.76 | 35% | 33% | 0% | 57% | 0.09 | **3.3** | 3.3 | 1.0/0.0/1.1/1.0/0.2 |
| Insulae | 2P | 2 | 0 | 2 | 0.51 | 1.32 | 2.06 | 51% | 2% | 2% | 74% | 0.31 | **3.5** | 1.7 | 1.0/0.0/1.1/1.0/0.4 |
| Palafitte | 1P | 2 | 0 | 2 | 0.96 | 1.48 | 2.21 | 44% | 6% | 2% | 66% | 0.43 | **3.5** | 3.5 | 1.0/0.0/1.3/1.0/0.3 |
| Banco | 1P+1O | 2 | 0 | 0 | 0.51 | 1.00 | 1.30 | 65% | 70% | 11% | 59% | 0.00 | **3.6** | 1.2 | 2.0/0.0/1.5/0.0/0.1 |
| Tumulo funerario | 2P | 3 | 0 | 5 | 0.75 | 2.48 | 2.88 | 58% | 3% | 21% | 57% | 1.05 | **3.8** | 1.9 | 1.0/0.0/2.2/0.0/0.5 |
| Mercato | 2P | 2 | 0 | 2 | 0.40 | 1.03 | 1.70 | 57% | 33% | 2% | 77% | 0.03 | **3.9** | 1.9 | 1.0/0.0/1.0/1.6/0.3 |
| Sacello | 1P | 2 | 0 | 3 | 0.46 | 1.15 | 1.94 | 48% | 13% | 2% | 70% | 0.14 | **3.9** | 3.9 | 1.0/0.0/1.0/1.9/0.1 |
| Giardino all'italiana | 0P+2O | 1 | 0 | 0 | 0.43 | 1.00 | 1.02 | 51% | 98% | 1% | 46% | 0.00 | **4.0** | 1.0 | 3.0/0.0/1.0/0.0/0.0 |

### Le dodici più sepolte

Ordinate per quota di copie finite sotto un altro edificio.

| carta | costo | res | rend | scavo | per partita | ere intatto | ere in piedi | vita sfruttata | subito | a fine partita | sepolto | vetustà | PV | PV/costo | (L/R/V/S/Sk) |
|---|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|---|
| Torre di vedetta | 2P | 3 | 0 | 2 | 0.00 | 1.65 | 2.02 | 51% | 0% | 0% | 100% | 0.65 | **3.5** | 1.7 | 1.0/0.0/1.4/0.8/0.4 |
| Emporio | 2P | 2 | 0 | 2 | 0.05 | 1.37 | 1.99 | 50% | 1% | 0% | 99% | 0.38 | **4.1** | 2.0 | 1.0/0.0/1.3/1.3/0.5 |
| Castrum | 3P | 4 | 0 | 3 | 0.04 | 2.06 | 2.07 | 52% | 2% | 5% | 94% | 1.05 | **3.8** | 1.3 | 1.0/0.0/2.2/0.0/0.6 |
| Arsenale | 3P+1O | 3 | 0 | 2 | 0.23 | 1.62 | 1.99 | 66% | 4% | 2% | 90% | 0.62 | **5.4** | 1.1 | 2.0/0.0/2.1/0.7/0.6 |
| Villaggio palizzato | 2P | 2 | 0 | 2 | 0.14 | 1.80 | 2.19 | 44% | 0% | 3% | 89% | 0.73 | **5.2** | 2.6 | 1.0/0.0/2.5/0.7/0.9 |
| Conceria | 1P | 1 | 0 | 0 | 0.06 | 1.00 | 1.22 | 41% | 78% | 0% | 87% | 0.00 | **2.2** | 2.2 | 1.0/0.0/1.0/0.1/0.1 |
| Castello | 2P+1O | 4 | 3 | 3 | 0.74 | 2.10 | 2.18 | 73% | 0% | 9% | 87% | 1.10 | **8.1** | 2.0 | 0.0/5.1/2.2/0.2/0.7 |
| Cappella | 1P+1O | 2 | 0 | 3 | 0.85 | 1.03 | 1.63 | 54% | 38% | 0% | 79% | 0.03 | **5.4** | 1.8 | 2.0/0.0/0.9/2.3/0.2 |
| Mercato | 2P | 2 | 0 | 2 | 0.40 | 1.03 | 1.70 | 57% | 33% | 2% | 77% | 0.03 | **3.9** | 1.9 | 1.0/0.0/1.0/1.6/0.3 |
| Borgo | 2P | 2 | 0 | 2 | 0.81 | 1.02 | 1.74 | 58% | 31% | 4% | 77% | 0.02 | **4.8** | 2.4 | 2.0/0.0/0.9/1.6/0.3 |
| Torre civica | 2P | 3 | 0 | 2 | 0.73 | 1.24 | 2.08 | 69% | 7% | 12% | 76% | 0.23 | **4.6** | 2.3 | 2.0/0.0/1.0/1.2/0.3 |
| Ospedale dei pellegrini | 2P+1O | 2 | 0 | 2 | 0.38 | 1.01 | 1.66 | 55% | 35% | 0% | 75% | 0.01 | **4.6** | 1.1 | 2.0/0.0/0.9/1.5/0.1 |

## Tutte le carte, era per era

### Era 1

| carta | costo | res | rend | scavo | per partita | ere intatto | ere in piedi | vita sfruttata | subito | a fine partita | sepolto | vetustà | PV | PV/costo | (L/R/V/S/Sk) |
|---|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|---|
| Menhir | 2P | 4 | 1 | 3 | 1.00 | 3.85 | 4.19 | 84% | 6% | 67% | 27% | 1.88 | **12.4** | 6.2 | 0.0/10.9/1.1/0.0/0.4 |
| Dolmen | 2P | 3 | 1 | 3 | 1.00 | 3.57 | 4.02 | 80% | 11% | 62% | 26% | 1.52 | **10.8** | 5.4 | 0.0/9.5/1.0/0.0/0.3 |
| Circolo di pietre | 3P | 4 | 1 | 5 | 1.00 | 3.59 | 3.86 | 77% | 3% | 58% | 34% | 1.74 | **12.1** | 4.0 | 0.0/9.7/2.1/0.0/0.3 |
| Tumulo funerario | 2P | 3 | 0 | 5 | 0.75 | 2.48 | 2.88 | 58% | 3% | 21% | 57% | 1.05 | **3.8** | 1.9 | 1.0/0.0/2.2/0.0/0.5 |
| Grotte dipinte | 1P | 2 | 0 | 6 | 0.47 | 2.19 | 2.78 | 56% | 10% | 12% | 52% | 0.80 | **1.8** | 1.8 | 0.0/0.0/1.2/0.6/0.0 |
| Palafitte | 1P | 2 | 0 | 2 | 0.96 | 1.48 | 2.21 | 44% | 6% | 2% | 66% | 0.43 | **3.5** | 3.5 | 1.0/0.0/1.3/1.0/0.3 |
| Villaggio palizzato | 2P | 2 | 0 | 2 | 0.14 | 1.80 | 2.19 | 44% | 0% | 3% | 89% | 0.73 | **5.2** | 2.6 | 1.0/0.0/2.5/0.7/0.9 |
| Focolare comune | 1P | 1 | 0 | 2 | 0.04 | 1.30 | 2.17 | 43% | 10% | 2% | 29% | 0.24 | **2.6** | 2.6 | 1.0/0.0/1.0/0.6/0.0 |
| Approdo | 1P | 1 | 0 | 2 | 0.40 | 1.00 | 1.83 | 37% | 17% | 0% | 51% | 0.00 | **2.4** | 2.4 | 0.0/0.0/1.2/1.1/0.1 |
| Cava | 1P | 1 | 0 | 2 | 1.00 | 1.09 | 1.81 | 36% | 26% | 0% | 60% | 0.09 | **2.5** | 2.5 | 0.0/0.0/1.1/1.0/0.3 |
| Trappole da pesca | 1P | 1 | 0 | 0 | 0.02 | 1.00 | 1.80 | 36% | 21% | 0% | 0% | 0.00 | **1.0** | 1.0 | 0.0/0.0/1.0/0.0/0.0 |
| Capanne | 1P | 1 | 0 | 2 | 0.97 | 1.10 | 1.76 | 35% | 33% | 0% | 57% | 0.09 | **3.3** | 3.3 | 1.0/0.0/1.1/1.0/0.2 |

### Era 2

| carta | costo | res | rend | scavo | per partita | ere intatto | ere in piedi | vita sfruttata | subito | a fine partita | sepolto | vetustà | PV | PV/costo | (L/R/V/S/Sk) |
|---|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|---|
| Acquedotto | 3P | 4 | 1 | 3 | 0.85 | 2.79 | 2.92 | 73% | 7% | 42% | 37% | 1.64 | **9.5** | 3.2 | 0.0/6.3/2.9/0.0/0.3 |
| Ponte | 3P | 3 | 1 | 3 | 0.35 | 2.25 | 2.87 | 72% | 2% | 36% | 37% | 1.03 | **6.4** | 2.1 | 0.0/4.1/1.8/0.2/0.2 |
| Anfiteatro | 5P | 5 | 2 | 6 | 0.92 | 2.63 | 2.65 | 66% | 4% | 25% | 56% | 1.59 | **10.5** | 2.1 | 0.0/7.0/3.0/0.0/0.5 |
| Foro | 3P | 3 | 1 | 5 | 0.86 | 2.18 | 2.60 | 65% | 4% | 27% | 57% | 1.02 | **6.4** | 2.1 | 0.0/3.6/1.9/0.3/0.5 |
| Tempio | 3P | 3 | 1 | 3 | 0.60 | 1.90 | 2.48 | 62% | 5% | 19% | 63% | 0.78 | **4.5** | 1.5 | 0.0/2.6/0.9/0.7/0.3 |
| Teatro | 2P | 3 | 0 | 5 | 0.75 | 1.83 | 2.32 | 58% | 4% | 12% | 71% | 0.70 | **4.0** | 2.0 | 2.0/0.0/1.1/0.8/0.1 |
| Castrum | 3P | 4 | 0 | 3 | 0.04 | 2.06 | 2.07 | 52% | 2% | 5% | 94% | 1.05 | **3.8** | 1.3 | 1.0/0.0/2.2/0.0/0.6 |
| Terme | 2P | 2 | 0 | 3 | 0.54 | 1.37 | 2.06 | 51% | 2% | 2% | 72% | 0.35 | **4.6** | 2.3 | 2.0/0.0/1.0/1.3/0.3 |
| Insulae | 2P | 2 | 0 | 2 | 0.51 | 1.32 | 2.06 | 51% | 2% | 2% | 74% | 0.31 | **3.5** | 1.7 | 1.0/0.0/1.1/1.0/0.4 |
| Torre di vedetta | 2P | 3 | 0 | 2 | 0.00 | 1.65 | 2.02 | 51% | 0% | 0% | 100% | 0.65 | **3.5** | 1.7 | 1.0/0.0/1.4/0.8/0.4 |
| Emporio | 2P | 2 | 0 | 2 | 0.05 | 1.37 | 1.99 | 50% | 1% | 0% | 99% | 0.38 | **4.1** | 2.0 | 1.0/0.0/1.3/1.3/0.5 |
| Sacello | 1P | 2 | 0 | 3 | 0.46 | 1.15 | 1.94 | 48% | 13% | 2% | 70% | 0.14 | **3.9** | 3.9 | 1.0/0.0/1.0/1.9/0.1 |

### Era 3

| carta | costo | res | rend | scavo | per partita | ere intatto | ere in piedi | vita sfruttata | subito | a fine partita | sepolto | vetustà | PV | PV/costo | (L/R/V/S/Sk) |
|---|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|---|
| Mura | 2P | 4 | 0 | 2 | 0.12 | 2.13 | 2.46 | 82% | 0% | 38% | 61% | 1.06 | **2.7** | 1.3 | 1.0/0.0/1.3/0.2/0.2 |
| Abbazia | 2P+2O | 3 | 3 | 5 | 0.74 | 1.89 | 2.35 | 78% | 3% | 33% | 47% | 0.87 | **8.0** | 1.3 | 0.0/5.3/1.8/0.6/0.3 |
| Castello | 2P+1O | 4 | 3 | 3 | 0.74 | 2.10 | 2.18 | 73% | 0% | 9% | 87% | 1.10 | **8.1** | 2.0 | 0.0/5.1/2.2/0.2/0.7 |
| Torre civica | 2P | 3 | 0 | 2 | 0.73 | 1.24 | 2.08 | 69% | 7% | 12% | 76% | 0.23 | **4.6** | 2.3 | 2.0/0.0/1.0/1.2/0.3 |
| Chiesa | 2P+1O | 3 | 2 | 3 | 0.74 | 1.64 | 2.07 | 69% | 17% | 19% | 65% | 0.63 | **5.0** | 1.2 | 0.0/2.7/0.9/1.1/0.3 |
| Arsenale | 3P+1O | 3 | 0 | 2 | 0.23 | 1.62 | 1.99 | 66% | 4% | 2% | 90% | 0.62 | **5.4** | 1.1 | 2.0/0.0/2.1/0.7/0.6 |
| Mulino | 2P | 2 | 0 | 2 | 0.32 | 1.06 | 1.89 | 63% | 19% | 7% | 62% | 0.06 | **3.3** | 1.7 | 1.0/0.0/0.9/1.2/0.2 |
| Borgo | 2P | 2 | 0 | 2 | 0.81 | 1.02 | 1.74 | 58% | 31% | 4% | 77% | 0.02 | **4.8** | 2.4 | 2.0/0.0/0.9/1.6/0.3 |
| Mercato | 2P | 2 | 0 | 2 | 0.40 | 1.03 | 1.70 | 57% | 33% | 2% | 77% | 0.03 | **3.9** | 1.9 | 1.0/0.0/1.0/1.6/0.3 |
| Ospedale dei pellegrini | 2P+1O | 2 | 0 | 2 | 0.38 | 1.01 | 1.66 | 55% | 35% | 0% | 75% | 0.01 | **4.6** | 1.1 | 2.0/0.0/0.9/1.5/0.1 |
| Cappella | 1P+1O | 2 | 0 | 3 | 0.85 | 1.03 | 1.63 | 54% | 38% | 0% | 79% | 0.03 | **5.4** | 1.8 | 2.0/0.0/0.9/2.3/0.2 |
| Conceria | 1P | 1 | 0 | 0 | 0.06 | 1.00 | 1.22 | 41% | 78% | 0% | 87% | 0.00 | **2.2** | 2.2 | 1.0/0.0/1.0/0.1/0.1 |

### Era 4

| carta | costo | res | rend | scavo | per partita | ere intatto | ere in piedi | vita sfruttata | subito | a fine partita | sepolto | vetustà | PV | PV/costo | (L/R/V/S/Sk) |
|---|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|---|
| Fortezza bastionata | 3P+2O | 5 | 3 | 2 | 0.58 | 1.86 | 2.00 | 100% | 0% | 23% | 63% | 0.86 | **9.3** | 1.3 | 0.0/4.3/4.4/0.2/0.4 |
| Duomo | 3P+3O | 4 | 4 | 5 | 0.50 | 1.79 | 1.99 | 100% | 1% | 19% | 70% | 0.79 | **9.7** | 1.1 | 0.0/4.8/3.6/0.8/0.5 |
| Ponte monumentale | 2P+2O | 4 | 3 | 3 | 0.45 | 1.73 | 1.98 | 99% | 2% | 49% | 41% | 0.73 | **7.8** | 1.3 | 0.0/4.7/2.6/0.3/0.2 |
| Piazza monumentale | 2P+2O | 3 | 2 | 3 | 0.18 | 1.58 | 1.94 | 97% | 6% | 17% | 70% | 0.58 | **7.8** | 1.3 | 0.0/2.2/4.3/1.0/0.3 |
| Villa | 2P+2O | 3 | 0 | 3 | 0.72 | 1.04 | 1.83 | 92% | 17% | 35% | 58% | 0.04 | **7.1** | 1.2 | 4.0/0.0/1.2/1.7/0.2 |
| Palazzo signorile | 2P+2O | 3 | 0 | 3 | 0.64 | 1.02 | 1.77 | 88% | 23% | 27% | 64% | 0.02 | **6.2** | 1.0 | 3.0/0.0/1.2/1.9/0.2 |
| Osservatorio | 1P+2O | 2 | 0 | 2 | 0.06 | 1.00 | 1.33 | 66% | 67% | 19% | 39% | 0.00 | **3.7** | 0.7 | 2.0/0.0/0.9/0.8/0.0 |
| Banco | 1P+1O | 2 | 0 | 0 | 0.51 | 1.00 | 1.30 | 65% | 70% | 11% | 59% | 0.00 | **3.6** | 1.2 | 2.0/0.0/1.5/0.0/0.1 |
| Loggia | 1P+1O | 2 | 0 | 2 | 0.61 | 1.00 | 1.28 | 64% | 72% | 9% | 59% | 0.00 | **4.6** | 1.5 | 2.0/0.0/1.4/1.2/0.1 |
| Bottega d'artista | 1P+1O | 2 | 0 | 2 | 0.63 | 1.00 | 1.17 | 58% | 83% | 7% | 60% | 0.00 | **4.6** | 1.5 | 2.0/0.0/1.3/1.2/0.0 |
| Accademia | 1P+2O | 2 | 0 | 3 | 0.36 | 1.00 | 1.15 | 58% | 85% | 7% | 56% | 0.00 | **4.8** | 1.0 | 2.0/0.0/1.1/1.7/0.0 |
| Giardino all'italiana | 0P+2O | 1 | 0 | 0 | 0.43 | 1.00 | 1.02 | 51% | 98% | 1% | 46% | 0.00 | **4.0** | 1.0 | 3.0/0.0/1.0/0.0/0.0 |

### Era 5

| carta | costo | res | rend | scavo | per partita | ere intatto | ere in piedi | vita sfruttata | subito | a fine partita | sepolto | vetustà | PV | PV/costo | (L/R/V/S/Sk) |
|---|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|---|
| Fondazione d'arte | 1P+2O | 2 | 0 | 0 | 0.42 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **7.6** | 1.5 | 3.0/0.0/4.6/0.0/0.0 |
| Condominio | 1P+1O | 2 | 0 | 0 | 0.64 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **7.4** | 2.5 | 2.0/0.0/5.4/0.0/0.0 |
| Caffè letterario | 0P+2O | 1 | 0 | 0 | 0.09 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **6.5** | 1.6 | 2.0/0.0/4.5/0.0/0.0 |
| Officina | 1P+1O | 2 | 0 | 0 | 0.62 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **7.2** | 2.4 | 2.0/0.0/5.2/0.0/0.0 |
| Monumento ai caduti | 1P+2O | 3 | 0 | 0 | 0.15 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **7.3** | 1.5 | 2.0/0.0/5.3/0.0/0.0 |
| Museo | 1P+3O | 3 | 0 | 0 | 0.19 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **9.6** | 1.4 | 4.0/0.0/5.6/0.0/0.0 |
| Grattacielo | 2P+4O | 3 | 0 | 0 | 0.01 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **9.6** | 1.0 | 4.0/0.0/5.6/0.0/0.0 |
| Biblioteca | 1P+3O | 3 | 0 | 0 | 0.27 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **8.2** | 1.2 | 4.0/0.0/4.2/0.0/0.0 |
| Ponte in acciaio | 1P+3O | 4 | 0 | 0 | 0.36 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **15.6** | 2.2 | 4.0/0.0/11.6/0.0/0.0 |
| Stazione | 2P+4O | 4 | 0 | 0 | 0.26 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **25.5** | 2.6 | 4.0/0.0/21.5/0.0/0.0 |
| Parco archeologico | 1P+2O | 2 | 0 | 0 | 0.42 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **15.6** | 3.1 | 2.0/0.0/13.6/0.0/0.0 |
| Università | 2P+3O | 3 | 0 | 0 | 0.43 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **17.6** | 2.2 | 4.0/0.0/13.6/0.0/0.0 |

## Due correlazioni, su chi arriva in tavola almeno 50 volte

- **resistenza stampata** → ere in piedi: r = +0.37 · → PV: r = +0.55
- **costo in pietra** → ere in piedi: r = +0.56 · → PV: r = +0.22
- **Rendita stampata** → ere in piedi: r = +0.35 · → PV: r = +0.22
- **Scavo stampato** → ere in piedi: r = +0.72 · → PV: r = -0.18

---

Rifare il conto: `godot --headless res://scenes/audit_partita.tscn -- --players 3 --vita 2500 --seed 100000` (quattro processi, semi 100000 / 102500 / 105000 / 107500).

## Cosa cambia con il Centro Urbano a 3 edifici e i binari liberi

Le stesse misure su 10000 partite con **Centro a 2 · binari per era** e 10000 con **Centro a 3 · binari liberi**, a parità di tutto il resto: stessi semi, stessi bot, stesso numero di giocatori. **Le regole cambiate sono più di una**, quindi la colonna Δ è l'effetto del pacchetto, non di una sola. La colonna Δ è la seconda meno la prima.

| misura | Centro a 2 · binari per era | Centro a 3 · binari liberi | Δ |
|---|--:|--:|--:|
| edifici costruiti per partita | 28.70 | 29.33 | +0.63 |
| ere intatto (media) | 1.58 | 1.70 | +0.11 |
| ere in piedi (media) | 1.96 | 2.11 | +0.15 |
| cade nella sua era | 18% | 16% | −2% |
| in piedi a fine partita | 29% | 30% | +2% |
| sepolto | 57% | 51% | −6% |
| vetustà media | 0.50 | 0.56 | +0.06 |
| potenziamenti per edificio | 0.05 | 0.04 | −0.01 |
| PV per edificio | 7.0 | 6.9 | −0.1 |
| PV per partita (i tre giocatori insieme) | 200 | 201 | +1 |

| canale (PV per partita, tutti i giocatori) | Centro a 2 · binari per era | Centro a 3 · binari liberi | Δ |
|---|--:|--:|--:|
| Lampo | 36.0 | 35.0 | −0.9 |
| Rendita | 54.0 | 65.0 | +11.1 |
| Verticalita | 79.6 | 73.7 | −5.9 |
| Scavo | 20.9 | 20.2 | −0.8 |
| Scheletri | 9.5 | 7.1 | −2.5 |

### Le carte che si cercano di più

Copie costruite per partita, prima e dopo.

| carta | era | costo | Centro a 2 · binari per era | Centro a 3 · binari liberi | Δ | PV Centro a 2 · binari per era | PV Centro a 3 · binari liberi |
|---|--:|--:|--:|--:|--:|--:|--:|
| Tumulo funerario | 1 | 2P | 0.46 | 0.75 | +0.29 | 4.4 | 3.8 |
| Acquedotto | 2 | 3P | 0.68 | 0.85 | +0.17 | 8.9 | 9.5 |
| Capanne | 1 | 1P | 0.82 | 0.97 | +0.16 | 4.0 | 3.3 |
| Foro | 2 | 3P | 0.73 | 0.86 | +0.12 | 6.7 | 6.4 |
| Palafitte | 1 | 1P | 0.84 | 0.96 | +0.12 | 3.8 | 3.5 |
| Approdo | 1 | 1P | 0.30 | 0.40 | +0.11 | 2.9 | 2.4 |
| Ponte | 2 | 3P | 0.25 | 0.35 | +0.11 | 6.6 | 6.4 |
| Cava | 1 | 1P | 0.90 | 1.00 | +0.10 | 3.1 | 2.5 |
| Grotte dipinte | 1 | 1P | 0.38 | 0.47 | +0.09 | 2.3 | 1.8 |
| Anfiteatro | 2 | 5P | 0.85 | 0.92 | +0.07 | 10.2 | 10.5 |

### E quelle che si cercano di meno

Le stesse carte, dall'altro capo della classifica.

| carta | era | costo | Centro a 2 · binari per era | Centro a 3 · binari liberi | Δ | PV Centro a 2 · binari per era | PV Centro a 3 · binari liberi |
|---|--:|--:|--:|--:|--:|--:|--:|
| Focolare comune | 1 | 1P | 0.11 | 0.04 | −0.08 | 3.9 | 2.6 |
| Fondazione d'arte | 5 | 1P+2O | 0.48 | 0.42 | −0.06 | 7.8 | 7.6 |
| Ponte monumentale | 4 | 2P+2O | 0.51 | 0.45 | −0.06 | 8.1 | 7.8 |
| Officina | 5 | 1P+1O | 0.68 | 0.62 | −0.05 | 7.4 | 7.2 |
| Condominio | 5 | 1P+1O | 0.69 | 0.64 | −0.05 | 7.5 | 7.4 |
| Arsenale | 3 | 3P+1O | 0.27 | 0.23 | −0.04 | 5.5 | 5.4 |
| Loggia | 4 | 1P+1O | 0.65 | 0.61 | −0.04 | 4.7 | 4.6 |
| Monumento ai caduti | 5 | 1P+2O | 0.18 | 0.15 | −0.04 | 7.3 | 7.3 |
| Banco | 4 | 1P+1O | 0.54 | 0.51 | −0.04 | 3.7 | 3.6 |
| Mulino | 3 | 2P | 0.35 | 0.32 | −0.04 | 3.4 | 3.3 |

### Carte che non arrivano quasi mai in tavola

- **Torre di vedetta** (era 2, 2P) — una ogni 250 partite, contro una ogni 110 prima
- **Grattacielo** (era 5, 2P+4O) — una ogni 122 partite, contro una ogni 179 prima
- **Trappole da pesca** (era 1, 1P) — una ogni 53 partite, contro una ogni 81 prima

