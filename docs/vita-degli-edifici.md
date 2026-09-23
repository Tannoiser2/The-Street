# La vita degli edifici

Misurata su **10 002 partite** a 3 giocatori, rigiocate dal motore vero (`scripts/tools/audit_partita.gd`, modalità `--vita`). In tutto 350 158 edifici costruiti.

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
| era 1 | 12 | 9.0 | 2.13 | 2.39 | 32% | 19% | 80% | 7.0 |
| era 2 | 12 | 7.5 | 1.96 | 2.27 | 12% | 16% | 83% | 7.3 |
| era 3 | 12 | 9.1 | 1.43 | 1.70 | 46% | 13% | 79% | 6.5 |
| era 4 | 12 | 5.9 | 1.24 | 1.34 | 66% | 15% | 59% | 9.3 |
| era 5 | 12 | 3.5 | 1.00 | 1.00 | 0% | 100% | 0% | 15.8 |

In media una partita mette in tavola **35.0 edifici**; di questi **24%** è ancora in piedi alla fine, **69%** finisce sotterrato e **34%** non supera l'era in cui è nato.

## Cosa salta all'occhio

**1. La Rendita è il canale che paga la durata, ed è quasi tutto.** Le 15 carte con Rendita stampata fruttano in media **10.3 PV** contro i **7.0** delle altre, e restano in piedi 2.61 ere contro 1.45. Non è una sorpresa — la Rendita si incassa a ogni censimento — ma dice che il valore di una carta lo decide quasi tutto un numero solo.

**2. La resistenza fa esattamente il suo mestiere.** Sulle ere 1-4, per ogni punto di resistenza:

| resistenza | carte | ere in piedi | cade nella sua era | PV medi |
|---|--:|--:|--:|--:|
| 1 | 7 | 1.41 | 62% | 4.1 |
| 2 | 17 | 1.42 | 65% | 5.5 |
| 3 | 14 | 2.25 | 21% | 7.6 |
| 4 | 8 | 2.72 | 14% | 10.4 |
| 5 | 2 | 2.33 | 5% | 12.8 |

Fra resistenza 1 e resistenza 4 la vita raddoppia e i punti quasi triplicano. Il salto vero è **fra 2 e 3**: è lì che un edificio smette di essere materiale da riempimento.

**3. Le carte da una pietra dell'era 1 non sono edifici: sono Scavo da seminare.** Approdo, Capanne, Cava, Focolare comune, Grotte dipinte, Palafitte, Trappole da pesca vivono 1.7 ere, finiscono sotto nel **97%** dei casi e 45 punti su cento di quello che fruttano sono Scavo. Funzionano — ma solo se chi le gioca sa che le sta seminando, non costruendo.

**4. Un edificio dell'era 5 non può morire.** Gli eventi sono solo nelle ere 1-4: chi costruisce nell'era Moderna non vedrà mai un censimento né un evento. Si vede nei numeri: vetustà **0.00**, Rendita **0.00**, Scavo **0.00**, e il **100%** ancora in piedi. Le carte dell'era 5 pagano solo Lampo e Verticalità, e vanno lette con un metro diverso dalle altre: il loro valore è tutto nell'istante in cui le metti.

**5. I colossali prendono la cima di tre colonne.** Un edificio da tre caselle conta come strato in tutte le colonne che tocca — quindi incassa il premio della cima **tre volte**:

| larghezza | carte | costruiti | PV medi | di cui Verticalità |
|---|--:|--:|--:|--:|
| 1 casella | 41 | 243 355 | 6.6 | 2.5 |
| 2 caselle | 16 | 84 361 | 11.6 | 6.4 |
| 3 caselle | 3 | 22 442 | 12.7 | 6.0 |

Il caso limite è la **Stazione** (era 5, tre caselle, 2P+4O): **37.4 PV medi**, di cui 33.4 di sola Verticalità — contro i 25.4 della seconda della lista, Università. Arriva in tavola una volta ogni 6 partite, quindi non rompe la media, ma quando arriva decide la colonna. Vale la pena chiedersi se il premio della cima debba contare una volta per edificio invece che una volta per colonna.

## Gli estremi

### Le dodici vite più brevi

Ordinate per **vita sfruttata**, non per ere secche: se no in testa finirebbero le carte dell'era 5, che vivono una sola era perché la partita finisce, non perché crollano.

| carta | costo | res | rend | scavo | per partita | ere intatto | ere in piedi | vita sfruttata | subito | a fine partita | sepolto | vetustà | PV | PV/costo | (L/R/V/S/Sk) |
|---|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|---|
| Approdo | 1P | 1 | 0 | 2 | 0.39 | 1.00 | 1.34 | 27% | 66% | 0% | 99% | 0.00 | **3.7** | 3.7 | 0.0/0.0/1.4/2.1/0.2 |
| Capanne | 1P | 1 | 0 | 2 | 1.09 | 1.05 | 1.45 | 29% | 59% | 0% | 98% | 0.05 | **4.5** | 4.5 | 1.0/0.0/1.4/1.9/0.2 |
| Cava | 1P | 1 | 0 | 2 | 1.19 | 1.06 | 1.47 | 29% | 57% | 0% | 98% | 0.06 | **3.6** | 3.6 | 0.0/0.0/1.4/1.9/0.4 |
| Trappole da pesca | 1P | 1 | 0 | 0 | 0.02 | 1.00 | 1.47 | 29% | 53% | 0% | 97% | 0.00 | **1.9** | 1.9 | 0.0/0.0/1.4/0.3/0.3 |
| Focolare comune | 1P | 1 | 0 | 2 | 0.15 | 1.07 | 1.65 | 33% | 39% | 0% | 99% | 0.06 | **4.5** | 4.5 | 1.0/0.0/1.3/2.1/0.1 |
| Conceria | 1P | 1 | 0 | 0 | 0.09 | 1.00 | 1.02 | 34% | 98% | 0% | 95% | 0.00 | **2.5** | 2.5 | 1.0/0.0/1.5/0.0/0.0 |
| Palafitte | 1P | 2 | 0 | 2 | 1.13 | 1.48 | 1.84 | 37% | 39% | 2% | 97% | 0.41 | **4.7** | 4.7 | 1.0/0.0/1.4/1.6/0.6 |
| Ospedale dei pellegrini | 2P+1O | 2 | 0 | 2 | 0.56 | 1.02 | 1.17 | 39% | 83% | 0% | 92% | 0.02 | **5.4** | 1.3 | 2.0/0.0/1.5/1.8/0.1 |
| Tumulo funerario | 2P | 3 | 0 | 5 | 0.61 | 1.96 | 1.96 | 39% | 4% | 0% | 100% | 0.96 | **5.1** | 2.5 | 1.0/0.0/3.0/0.0/1.1 |
| Villaggio palizzato | 2P | 2 | 0 | 2 | 0.12 | 1.72 | 2.00 | 40% | 0% | 0% | 100% | 0.72 | **5.9** | 3.0 | 1.0/0.0/3.0/0.7/1.2 |
| Cappella | 1P+1O | 2 | 0 | 3 | 1.10 | 1.03 | 1.21 | 40% | 80% | 1% | 91% | 0.03 | **6.3** | 2.1 | 2.0/0.0/1.5/2.7/0.1 |
| Borgo | 2P | 2 | 0 | 2 | 1.21 | 1.03 | 1.23 | 41% | 79% | 1% | 89% | 0.03 | **5.4** | 2.7 | 2.0/0.0/1.6/1.7/0.1 |

### Le dodici che arrivano in fondo

Ordinate per vita sfruttata.

| carta | costo | res | rend | scavo | per partita | ere intatto | ere in piedi | vita sfruttata | subito | a fine partita | sepolto | vetustà | PV | PV/costo | (L/R/V/S/Sk) |
|---|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|---|
| Fondazione d'arte | 1P+2O | 2 | 0 | 0 | 0.36 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **11.0** | 2.2 | 3.0/0.0/8.0/0.0/0.0 |
| Condominio | 1P+1O | 2 | 0 | 0 | 0.79 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **11.1** | 3.7 | 2.0/0.0/9.1/0.0/0.0 |
| Caffè letterario | 0P+2O | 1 | 0 | 0 | 0.08 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **10.0** | 2.5 | 2.0/0.0/8.0/0.0/0.0 |
| Officina | 1P+1O | 2 | 0 | 0 | 0.79 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **10.9** | 3.6 | 2.0/0.0/8.9/0.0/0.0 |
| Monumento ai caduti | 1P+2O | 3 | 0 | 0 | 0.14 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **10.4** | 2.1 | 2.0/0.0/8.4/0.0/0.0 |
| Museo | 1P+3O | 3 | 0 | 0 | 0.10 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **13.1** | 1.9 | 4.0/0.0/9.1/0.0/0.0 |
| Grattacielo | 2P+4O | 3 | 0 | 0 | 0.00 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **14.4** | 1.4 | 4.0/0.0/10.4/0.0/0.0 |
| Biblioteca | 1P+3O | 3 | 0 | 0 | 0.13 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **10.8** | 1.5 | 4.0/0.0/6.8/0.0/0.0 |
| Ponte in acciaio | 1P+3O | 4 | 0 | 0 | 0.24 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **22.8** | 3.3 | 4.0/0.0/18.8/0.0/0.0 |
| Stazione | 2P+4O | 4 | 0 | 0 | 0.17 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **37.4** | 3.7 | 4.0/0.0/33.4/0.0/0.0 |
| Parco archeologico | 1P+2O | 2 | 0 | 0 | 0.41 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **23.3** | 4.7 | 2.0/0.0/21.3/0.0/0.0 |
| Università | 2P+3O | 3 | 0 | 0 | 0.32 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **25.4** | 3.2 | 4.0/0.0/21.4/0.0/0.0 |

### Le dodici che rendono di più

Ordinate per PV medi fruttati al proprietario.

| carta | costo | res | rend | scavo | per partita | ere intatto | ere in piedi | vita sfruttata | subito | a fine partita | sepolto | vetustà | PV | PV/costo | (L/R/V/S/Sk) |
|---|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|---|
| Stazione | 2P+4O | 4 | 0 | 0 | 0.17 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **37.4** | 3.7 | 4.0/0.0/33.4/0.0/0.0 |
| Università | 2P+3O | 3 | 0 | 0 | 0.32 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **25.4** | 3.2 | 4.0/0.0/21.4/0.0/0.0 |
| Parco archeologico | 1P+2O | 2 | 0 | 0 | 0.41 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **23.3** | 4.7 | 2.0/0.0/21.3/0.0/0.0 |
| Ponte in acciaio | 1P+3O | 4 | 0 | 0 | 0.24 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **22.8** | 3.3 | 4.0/0.0/18.8/0.0/0.0 |
| Fortezza bastionata | 3P+2O | 5 | 3 | 2 | 0.66 | 1.85 | 1.96 | 98% | 4% | 39% | 39% | 0.85 | **15.8** | 2.3 | 0.0/4.9/10.6/0.1/0.2 |
| Duomo | 3P+3O | 4 | 4 | 5 | 0.43 | 1.76 | 1.91 | 95% | 9% | 32% | 47% | 0.76 | **15.7** | 1.7 | 0.0/5.3/9.5/0.6/0.3 |
| Grattacielo | 2P+4O | 3 | 0 | 0 | 0.00 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **14.4** | 1.4 | 4.0/0.0/10.4/0.0/0.0 |
| Piazza monumentale | 2P+2O | 3 | 2 | 3 | 0.26 | 1.50 | 1.71 | 85% | 29% | 29% | 45% | 0.50 | **13.8** | 2.3 | 0.0/2.2/10.6/0.8/0.2 |
| Museo | 1P+3O | 3 | 0 | 0 | 0.10 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **13.1** | 1.9 | 4.0/0.0/9.1/0.0/0.0 |
| Menhir | 2P | 4 | 1 | 3 | 1.27 | 3.53 | 3.71 | 74% | 15% | 54% | 45% | 1.89 | **11.8** | 5.9 | 0.0/9.8/1.1/0.3/0.6 |
| Ponte monumentale | 2P+2O | 4 | 3 | 3 | 0.46 | 1.74 | 1.96 | 98% | 4% | 53% | 30% | 0.74 | **11.5** | 1.9 | 0.0/4.8/6.2/0.3/0.2 |
| Castello | 2P+1O | 4 | 3 | 3 | 0.97 | 2.24 | 2.31 | 77% | 2% | 23% | 66% | 1.25 | **11.4** | 2.9 | 0.0/6.5/4.2/0.2/0.6 |

### Le dodici che rendono di più per quello che costano

Ordinate per PV diviso il costo in pietra equivalente.

| carta | costo | res | rend | scavo | per partita | ere intatto | ere in piedi | vita sfruttata | subito | a fine partita | sepolto | vetustà | PV | PV/costo | (L/R/V/S/Sk) |
|---|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|---|
| Menhir | 2P | 4 | 1 | 3 | 1.27 | 3.53 | 3.71 | 74% | 15% | 54% | 45% | 1.89 | **11.8** | 5.9 | 0.0/9.8/1.1/0.3/0.6 |
| Dolmen | 2P | 3 | 1 | 3 | 1.26 | 3.41 | 3.65 | 73% | 14% | 49% | 50% | 1.66 | **11.0** | 5.5 | 0.0/8.9/1.1/0.4/0.6 |
| Sacello | 1P | 2 | 0 | 3 | 0.65 | 1.16 | 1.65 | 41% | 39% | 1% | 98% | 0.15 | **5.1** | 5.1 | 1.0/0.0/1.3/2.6/0.2 |
| Palafitte | 1P | 2 | 0 | 2 | 1.13 | 1.48 | 1.84 | 37% | 39% | 2% | 97% | 0.41 | **4.7** | 4.7 | 1.0/0.0/1.4/1.6/0.6 |
| Parco archeologico | 1P+2O | 2 | 0 | 0 | 0.41 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **23.3** | 4.7 | 2.0/0.0/21.3/0.0/0.0 |
| Capanne | 1P | 1 | 0 | 2 | 1.09 | 1.05 | 1.45 | 29% | 59% | 0% | 98% | 0.05 | **4.5** | 4.5 | 1.0/0.0/1.4/1.9/0.2 |
| Grotte dipinte | 1P | 2 | 0 | 6 | 0.50 | 2.05 | 2.36 | 47% | 10% | 5% | 93% | 0.87 | **4.3** | 4.3 | 0.0/0.0/1.4/2.5/0.4 |
| Approdo | 1P | 1 | 0 | 2 | 0.39 | 1.00 | 1.34 | 27% | 66% | 0% | 99% | 0.00 | **3.7** | 3.7 | 0.0/0.0/1.4/2.1/0.2 |
| Condominio | 1P+1O | 2 | 0 | 0 | 0.79 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **11.1** | 3.7 | 2.0/0.0/9.1/0.0/0.0 |
| Officina | 1P+1O | 2 | 0 | 0 | 0.79 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **10.9** | 3.6 | 2.0/0.0/8.9/0.0/0.0 |
| Cava | 1P | 1 | 0 | 2 | 1.19 | 1.06 | 1.47 | 29% | 57% | 0% | 98% | 0.06 | **3.6** | 3.6 | 0.0/0.0/1.4/1.9/0.4 |
| Acquedotto | 3P | 4 | 1 | 3 | 0.93 | 2.66 | 2.74 | 68% | 13% | 40% | 58% | 1.59 | **10.2** | 3.4 | 0.0/6.0/3.7/0.0/0.5 |

### Le dodici che rendono di meno

Solo carte che arrivano in tavola almeno una volta ogni cinque partite: una carta rara ha medie ballerine.

| carta | costo | res | rend | scavo | per partita | ere intatto | ere in piedi | vita sfruttata | subito | a fine partita | sepolto | vetustà | PV | PV/costo | (L/R/V/S/Sk) |
|---|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|---|
| Mura | 2P | 4 | 0 | 2 | 0.40 | 2.30 | 2.58 | 86% | 5% | 56% | 41% | 1.20 | **3.5** | 1.8 | 1.0/0.0/2.2/0.2/0.1 |
| Cava | 1P | 1 | 0 | 2 | 1.19 | 1.06 | 1.47 | 29% | 57% | 0% | 98% | 0.06 | **3.6** | 3.6 | 0.0/0.0/1.4/1.9/0.4 |
| Approdo | 1P | 1 | 0 | 2 | 0.39 | 1.00 | 1.34 | 27% | 66% | 0% | 99% | 0.00 | **3.7** | 3.7 | 0.0/0.0/1.4/2.1/0.2 |
| Mulino | 2P | 2 | 0 | 2 | 0.80 | 1.07 | 1.37 | 46% | 66% | 3% | 89% | 0.07 | **4.2** | 2.1 | 1.0/0.0/1.4/1.7/0.1 |
| Grotte dipinte | 1P | 2 | 0 | 6 | 0.50 | 2.05 | 2.36 | 47% | 10% | 5% | 93% | 0.87 | **4.3** | 4.3 | 0.0/0.0/1.4/2.5/0.4 |
| Insulae | 2P | 2 | 0 | 2 | 0.73 | 1.29 | 1.85 | 46% | 23% | 2% | 97% | 0.27 | **4.4** | 2.2 | 1.0/0.0/1.4/1.6/0.4 |
| Capanne | 1P | 1 | 0 | 2 | 1.09 | 1.05 | 1.45 | 29% | 59% | 0% | 98% | 0.05 | **4.5** | 4.5 | 1.0/0.0/1.4/1.9/0.2 |
| Mercato | 2P | 2 | 0 | 2 | 0.67 | 1.03 | 1.26 | 42% | 76% | 1% | 95% | 0.03 | **4.5** | 2.2 | 1.0/0.0/1.5/1.9/0.1 |
| Palafitte | 1P | 2 | 0 | 2 | 1.13 | 1.48 | 1.84 | 37% | 39% | 2% | 97% | 0.41 | **4.7** | 4.7 | 1.0/0.0/1.4/1.6/0.6 |
| Tumulo funerario | 2P | 3 | 0 | 5 | 0.61 | 1.96 | 1.96 | 39% | 4% | 0% | 100% | 0.96 | **5.1** | 2.5 | 1.0/0.0/3.0/0.0/1.1 |
| Sacello | 1P | 2 | 0 | 3 | 0.65 | 1.16 | 1.65 | 41% | 39% | 1% | 98% | 0.15 | **5.1** | 5.1 | 1.0/0.0/1.3/2.6/0.2 |
| Teatro | 2P | 3 | 0 | 5 | 1.00 | 1.94 | 2.27 | 57% | 2% | 11% | 88% | 0.83 | **5.3** | 2.6 | 2.0/0.0/1.4/1.5/0.4 |

### Le dodici più sepolte

Ordinate per quota di copie finite sotto un altro edificio.

| carta | costo | res | rend | scavo | per partita | ere intatto | ere in piedi | vita sfruttata | subito | a fine partita | sepolto | vetustà | PV | PV/costo | (L/R/V/S/Sk) |
|---|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|---|
| Villaggio palizzato | 2P | 2 | 0 | 2 | 0.12 | 1.72 | 2.00 | 40% | 0% | 0% | 100% | 0.72 | **5.9** | 3.0 | 1.0/0.0/3.0/0.7/1.2 |
| Emporio | 2P | 2 | 0 | 2 | 0.08 | 1.11 | 1.78 | 45% | 22% | 0% | 100% | 0.11 | **5.1** | 2.5 | 1.0/0.0/1.6/1.8/0.6 |
| Tumulo funerario | 2P | 3 | 0 | 5 | 0.61 | 1.96 | 1.96 | 39% | 4% | 0% | 100% | 0.96 | **5.1** | 2.5 | 1.0/0.0/3.0/0.0/1.1 |
| Focolare comune | 1P | 1 | 0 | 2 | 0.15 | 1.07 | 1.65 | 33% | 39% | 0% | 99% | 0.06 | **4.5** | 4.5 | 1.0/0.0/1.3/2.1/0.1 |
| Approdo | 1P | 1 | 0 | 2 | 0.39 | 1.00 | 1.34 | 27% | 66% | 0% | 99% | 0.00 | **3.7** | 3.7 | 0.0/0.0/1.4/2.1/0.2 |
| Capanne | 1P | 1 | 0 | 2 | 1.09 | 1.05 | 1.45 | 29% | 59% | 0% | 98% | 0.05 | **4.5** | 4.5 | 1.0/0.0/1.4/1.9/0.2 |
| Cava | 1P | 1 | 0 | 2 | 1.19 | 1.06 | 1.47 | 29% | 57% | 0% | 98% | 0.06 | **3.6** | 3.6 | 0.0/0.0/1.4/1.9/0.4 |
| Sacello | 1P | 2 | 0 | 3 | 0.65 | 1.16 | 1.65 | 41% | 39% | 1% | 98% | 0.15 | **5.1** | 5.1 | 1.0/0.0/1.3/2.6/0.2 |
| Insulae | 2P | 2 | 0 | 2 | 0.73 | 1.29 | 1.85 | 46% | 23% | 2% | 97% | 0.27 | **4.4** | 2.2 | 1.0/0.0/1.4/1.6/0.4 |
| Terme | 2P | 2 | 0 | 3 | 0.74 | 1.33 | 1.87 | 47% | 21% | 2% | 97% | 0.30 | **6.1** | 3.0 | 2.0/0.0/1.4/2.2/0.4 |
| Trappole da pesca | 1P | 1 | 0 | 0 | 0.02 | 1.00 | 1.47 | 29% | 53% | 0% | 97% | 0.00 | **1.9** | 1.9 | 0.0/0.0/1.4/0.3/0.3 |
| Palafitte | 1P | 2 | 0 | 2 | 1.13 | 1.48 | 1.84 | 37% | 39% | 2% | 97% | 0.41 | **4.7** | 4.7 | 1.0/0.0/1.4/1.6/0.6 |

## Tutte le carte, era per era

### Era 1

| carta | costo | res | rend | scavo | per partita | ere intatto | ere in piedi | vita sfruttata | subito | a fine partita | sepolto | vetustà | PV | PV/costo | (L/R/V/S/Sk) |
|---|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|---|
| Menhir | 2P | 4 | 1 | 3 | 1.27 | 3.53 | 3.71 | 74% | 15% | 54% | 45% | 1.89 | **11.8** | 5.9 | 0.0/9.8/1.1/0.3/0.6 |
| Dolmen | 2P | 3 | 1 | 3 | 1.26 | 3.41 | 3.65 | 73% | 14% | 49% | 50% | 1.66 | **11.0** | 5.5 | 0.0/8.9/1.1/0.4/0.6 |
| Circolo di pietre | 3P | 4 | 1 | 5 | 1.30 | 2.58 | 2.65 | 53% | 30% | 27% | 72% | 1.26 | **8.8** | 2.9 | 0.0/5.6/2.5/0.1/0.6 |
| Grotte dipinte | 1P | 2 | 0 | 6 | 0.50 | 2.05 | 2.36 | 47% | 10% | 5% | 93% | 0.87 | **4.3** | 4.3 | 0.0/0.0/1.4/2.5/0.4 |
| Villaggio palizzato | 2P | 2 | 0 | 2 | 0.12 | 1.72 | 2.00 | 40% | 0% | 0% | 100% | 0.72 | **5.9** | 3.0 | 1.0/0.0/3.0/0.7/1.2 |
| Tumulo funerario | 2P | 3 | 0 | 5 | 0.61 | 1.96 | 1.96 | 39% | 4% | 0% | 100% | 0.96 | **5.1** | 2.5 | 1.0/0.0/3.0/0.0/1.1 |
| Palafitte | 1P | 2 | 0 | 2 | 1.13 | 1.48 | 1.84 | 37% | 39% | 2% | 97% | 0.41 | **4.7** | 4.7 | 1.0/0.0/1.4/1.6/0.6 |
| Focolare comune | 1P | 1 | 0 | 2 | 0.15 | 1.07 | 1.65 | 33% | 39% | 0% | 99% | 0.06 | **4.5** | 4.5 | 1.0/0.0/1.3/2.1/0.1 |
| Trappole da pesca | 1P | 1 | 0 | 0 | 0.02 | 1.00 | 1.47 | 29% | 53% | 0% | 97% | 0.00 | **1.9** | 1.9 | 0.0/0.0/1.4/0.3/0.3 |
| Cava | 1P | 1 | 0 | 2 | 1.19 | 1.06 | 1.47 | 29% | 57% | 0% | 98% | 0.06 | **3.6** | 3.6 | 0.0/0.0/1.4/1.9/0.4 |
| Capanne | 1P | 1 | 0 | 2 | 1.09 | 1.05 | 1.45 | 29% | 59% | 0% | 98% | 0.05 | **4.5** | 4.5 | 1.0/0.0/1.4/1.9/0.2 |
| Approdo | 1P | 1 | 0 | 2 | 0.39 | 1.00 | 1.34 | 27% | 66% | 0% | 99% | 0.00 | **3.7** | 3.7 | 0.0/0.0/1.4/2.1/0.2 |

### Era 2

| carta | costo | res | rend | scavo | per partita | ere intatto | ere in piedi | vita sfruttata | subito | a fine partita | sepolto | vetustà | PV | PV/costo | (L/R/V/S/Sk) |
|---|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|---|
| Acquedotto | 3P | 4 | 1 | 3 | 0.93 | 2.66 | 2.74 | 68% | 13% | 40% | 58% | 1.59 | **10.2** | 3.4 | 0.0/6.0/3.7/0.0/0.5 |
| Anfiteatro | 5P | 5 | 2 | 6 | 1.14 | 2.53 | 2.55 | 64% | 5% | 23% | 74% | 1.49 | **11.1** | 2.2 | 0.0/6.5/3.9/0.0/0.7 |
| Ponte | 3P | 3 | 1 | 3 | 0.36 | 2.20 | 2.53 | 63% | 3% | 23% | 76% | 1.16 | **7.8** | 2.6 | 0.0/3.8/2.6/0.6/0.7 |
| Tempio | 3P | 3 | 1 | 3 | 0.76 | 1.94 | 2.42 | 60% | 6% | 19% | 79% | 0.90 | **5.7** | 1.9 | 0.0/3.0/1.2/1.0/0.5 |
| Foro | 3P | 3 | 1 | 5 | 0.99 | 2.11 | 2.41 | 60% | 6% | 19% | 81% | 1.08 | **7.9** | 2.6 | 0.0/3.3/2.7/0.8/1.0 |
| Teatro | 2P | 3 | 0 | 5 | 1.00 | 1.94 | 2.27 | 57% | 2% | 11% | 88% | 0.83 | **5.3** | 2.6 | 2.0/0.0/1.4/1.5/0.4 |
| Torre di vedetta | 2P | 3 | 0 | 2 | 0.01 | 1.71 | 2.10 | 53% | 0% | 4% | 96% | 0.73 | **3.4** | 1.7 | 1.0/0.0/1.5/0.7/0.2 |
| Castrum | 3P | 4 | 0 | 3 | 0.08 | 2.08 | 2.08 | 52% | 2% | 5% | 95% | 1.08 | **4.8** | 1.6 | 1.0/0.0/2.9/0.0/0.8 |
| Terme | 2P | 2 | 0 | 3 | 0.74 | 1.33 | 1.87 | 47% | 21% | 2% | 97% | 0.30 | **6.1** | 3.0 | 2.0/0.0/1.4/2.2/0.4 |
| Insulae | 2P | 2 | 0 | 2 | 0.73 | 1.29 | 1.85 | 46% | 23% | 2% | 97% | 0.27 | **4.4** | 2.2 | 1.0/0.0/1.4/1.6/0.4 |
| Emporio | 2P | 2 | 0 | 2 | 0.08 | 1.11 | 1.78 | 45% | 22% | 0% | 100% | 0.11 | **5.1** | 2.5 | 1.0/0.0/1.6/1.8/0.6 |
| Sacello | 1P | 2 | 0 | 3 | 0.65 | 1.16 | 1.65 | 41% | 39% | 1% | 98% | 0.15 | **5.1** | 5.1 | 1.0/0.0/1.3/2.6/0.2 |

### Era 3

| carta | costo | res | rend | scavo | per partita | ere intatto | ere in piedi | vita sfruttata | subito | a fine partita | sepolto | vetustà | PV | PV/costo | (L/R/V/S/Sk) |
|---|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|---|
| Mura | 2P | 4 | 0 | 2 | 0.40 | 2.30 | 2.58 | 86% | 5% | 56% | 41% | 1.20 | **3.5** | 1.8 | 1.0/0.0/2.2/0.2/0.1 |
| Abbazia | 2P+2O | 3 | 3 | 5 | 0.79 | 1.96 | 2.32 | 77% | 10% | 37% | 56% | 0.96 | **10.6** | 1.8 | 0.0/5.8/3.1/1.3/0.3 |
| Castello | 2P+1O | 4 | 3 | 3 | 0.97 | 2.24 | 2.31 | 77% | 2% | 23% | 66% | 1.25 | **11.4** | 2.9 | 0.0/6.5/4.2/0.2/0.6 |
| Chiesa | 2P+1O | 3 | 2 | 3 | 0.94 | 1.69 | 1.98 | 66% | 29% | 25% | 70% | 0.67 | **6.4** | 1.6 | 0.0/3.1/1.6/1.5/0.2 |
| Arsenale | 3P+1O | 3 | 0 | 2 | 0.44 | 1.70 | 1.94 | 65% | 12% | 3% | 84% | 0.70 | **6.8** | 1.4 | 2.0/0.0/3.5/0.6/0.7 |
| Torre civica | 2P | 3 | 0 | 2 | 1.12 | 1.33 | 1.91 | 64% | 28% | 17% | 74% | 0.31 | **5.3** | 2.6 | 2.0/0.0/1.8/1.2/0.3 |
| Mulino | 2P | 2 | 0 | 2 | 0.80 | 1.07 | 1.37 | 46% | 66% | 3% | 89% | 0.07 | **4.2** | 2.1 | 1.0/0.0/1.4/1.7/0.1 |
| Mercato | 2P | 2 | 0 | 2 | 0.67 | 1.03 | 1.26 | 42% | 76% | 1% | 95% | 0.03 | **4.5** | 2.2 | 1.0/0.0/1.5/1.9/0.1 |
| Borgo | 2P | 2 | 0 | 2 | 1.21 | 1.03 | 1.23 | 41% | 79% | 1% | 89% | 0.03 | **5.4** | 2.7 | 2.0/0.0/1.6/1.7/0.1 |
| Cappella | 1P+1O | 2 | 0 | 3 | 1.10 | 1.03 | 1.21 | 40% | 80% | 1% | 91% | 0.03 | **6.3** | 2.1 | 2.0/0.0/1.5/2.7/0.1 |
| Ospedale dei pellegrini | 2P+1O | 2 | 0 | 2 | 0.56 | 1.02 | 1.17 | 39% | 83% | 0% | 92% | 0.02 | **5.4** | 1.3 | 2.0/0.0/1.5/1.8/0.1 |
| Conceria | 1P | 1 | 0 | 0 | 0.09 | 1.00 | 1.02 | 34% | 98% | 0% | 95% | 0.00 | **2.5** | 2.5 | 1.0/0.0/1.5/0.0/0.0 |

### Era 4

| carta | costo | res | rend | scavo | per partita | ere intatto | ere in piedi | vita sfruttata | subito | a fine partita | sepolto | vetustà | PV | PV/costo | (L/R/V/S/Sk) |
|---|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|---|
| Fortezza bastionata | 3P+2O | 5 | 3 | 2 | 0.66 | 1.85 | 1.96 | 98% | 4% | 39% | 39% | 0.85 | **15.8** | 2.3 | 0.0/4.9/10.6/0.1/0.2 |
| Ponte monumentale | 2P+2O | 4 | 3 | 3 | 0.46 | 1.74 | 1.96 | 98% | 4% | 53% | 30% | 0.74 | **11.5** | 1.9 | 0.0/4.8/6.2/0.3/0.2 |
| Duomo | 3P+3O | 4 | 4 | 5 | 0.43 | 1.76 | 1.91 | 95% | 9% | 32% | 47% | 0.76 | **15.7** | 1.7 | 0.0/5.3/9.5/0.6/0.3 |
| Piazza monumentale | 2P+2O | 3 | 2 | 3 | 0.26 | 1.50 | 1.71 | 85% | 29% | 29% | 45% | 0.50 | **13.8** | 2.3 | 0.0/2.2/10.6/0.8/0.2 |
| Villa | 2P+2O | 3 | 0 | 3 | 0.64 | 1.03 | 1.34 | 67% | 66% | 18% | 64% | 0.03 | **9.0** | 1.5 | 4.0/0.0/3.1/1.9/0.1 |
| Palazzo signorile | 2P+2O | 3 | 0 | 3 | 0.52 | 1.02 | 1.15 | 57% | 85% | 7% | 70% | 0.02 | **8.2** | 1.4 | 3.0/0.0/3.1/2.1/0.0 |
| Osservatorio | 1P+2O | 2 | 0 | 2 | 0.02 | 1.00 | 1.04 | 52% | 96% | 2% | 76% | 0.00 | **6.4** | 1.3 | 2.0/0.0/2.9/1.6/0.0 |
| Loggia | 1P+1O | 2 | 0 | 2 | 0.83 | 1.00 | 1.02 | 51% | 98% | 1% | 68% | 0.00 | **6.8** | 2.3 | 2.0/0.0/3.5/1.4/0.0 |
| Banco | 1P+1O | 2 | 0 | 0 | 0.81 | 1.00 | 1.02 | 51% | 98% | 1% | 65% | 0.00 | **5.7** | 1.9 | 2.0/0.0/3.7/0.0/0.0 |
| Bottega d'artista | 1P+1O | 2 | 0 | 2 | 0.84 | 1.00 | 1.01 | 50% | 99% | 0% | 68% | 0.00 | **6.8** | 2.3 | 2.0/0.0/3.4/1.4/0.0 |
| Accademia | 1P+2O | 2 | 0 | 3 | 0.24 | 1.00 | 1.01 | 50% | 99% | 0% | 78% | 0.00 | **7.0** | 1.4 | 2.0/0.0/2.7/2.3/0.0 |
| Giardino all'italiana | 0P+2O | 1 | 0 | 0 | 0.21 | 1.00 | 1.00 | 50% | 100% | 0% | 75% | 0.00 | **5.7** | 1.4 | 3.0/0.0/2.7/0.0/0.0 |

### Era 5

| carta | costo | res | rend | scavo | per partita | ere intatto | ere in piedi | vita sfruttata | subito | a fine partita | sepolto | vetustà | PV | PV/costo | (L/R/V/S/Sk) |
|---|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|---|
| Fondazione d'arte | 1P+2O | 2 | 0 | 0 | 0.36 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **11.0** | 2.2 | 3.0/0.0/8.0/0.0/0.0 |
| Condominio | 1P+1O | 2 | 0 | 0 | 0.79 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **11.1** | 3.7 | 2.0/0.0/9.1/0.0/0.0 |
| Caffè letterario | 0P+2O | 1 | 0 | 0 | 0.08 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **10.0** | 2.5 | 2.0/0.0/8.0/0.0/0.0 |
| Officina | 1P+1O | 2 | 0 | 0 | 0.79 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **10.9** | 3.6 | 2.0/0.0/8.9/0.0/0.0 |
| Monumento ai caduti | 1P+2O | 3 | 0 | 0 | 0.14 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **10.4** | 2.1 | 2.0/0.0/8.4/0.0/0.0 |
| Museo | 1P+3O | 3 | 0 | 0 | 0.10 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **13.1** | 1.9 | 4.0/0.0/9.1/0.0/0.0 |
| Grattacielo | 2P+4O | 3 | 0 | 0 | 0.00 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **14.4** | 1.4 | 4.0/0.0/10.4/0.0/0.0 |
| Biblioteca | 1P+3O | 3 | 0 | 0 | 0.13 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **10.8** | 1.5 | 4.0/0.0/6.8/0.0/0.0 |
| Ponte in acciaio | 1P+3O | 4 | 0 | 0 | 0.24 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **22.8** | 3.3 | 4.0/0.0/18.8/0.0/0.0 |
| Stazione | 2P+4O | 4 | 0 | 0 | 0.17 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **37.4** | 3.7 | 4.0/0.0/33.4/0.0/0.0 |
| Parco archeologico | 1P+2O | 2 | 0 | 0 | 0.41 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **23.3** | 4.7 | 2.0/0.0/21.3/0.0/0.0 |
| Università | 2P+3O | 3 | 0 | 0 | 0.32 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **25.4** | 3.2 | 4.0/0.0/21.4/0.0/0.0 |

## Due correlazioni, su chi arriva in tavola almeno 50 volte

- **resistenza stampata** → ere in piedi: r = +0.50 · → PV: r = +0.46
- **costo in pietra** → ere in piedi: r = +0.61 · → PV: r = +0.09
- **Rendita stampata** → ere in piedi: r = +0.45 · → PV: r = +0.23
- **Scavo stampato** → ere in piedi: r = +0.66 · → PV: r = -0.26

---

Rifare il conto: `godot --headless res://scenes/audit_partita.tscn -- --players 3 --vita 2500 --seed 100000` (quattro processi, semi 100000 / 102500 / 105000 / 107500).

## Cosa cambia quando i bot giocano davvero

Le stesse misure su 10000 partite coi bot **a caso** e 10002 con le **cinque strategie**. La colonna Δ è la seconda meno la prima.

| misura | bot a caso | con strategia | Δ |
|---|--:|--:|--:|
| edifici costruiti per partita | 37.38 | 35.01 | −2.37 |
| ere intatto (media) | 1.59 | 1.65 | +0.05 |
| ere in piedi (media) | 1.90 | 1.87 | −0.03 |
| cade nella sua era | 37% | 34% | −3% |
| in piedi a fine partita | 32% | 24% | −8% |
| sepolto | 51% | 69% | +18% |
| vetustà media | 0.54 | 0.57 | +0.03 |
| potenziamenti per edificio | 0.12 | 0.04 | −0.08 |
| PV per edificio | 5.2 | 8.2 | +3.0 |
| PV per partita (i tre giocatori insieme) | 193 | 287 | +94 |

| canale (PV per partita, tutti i giocatori) | bot a caso | con strategia | Δ |
|---|--:|--:|--:|
| Lampo | 49.4 | 38.5 | −10.9 |
| Rendita | 43.5 | 72.8 | +29.3 |
| Verticalita | 58.4 | 127.4 | +69.0 |
| Scavo | 33.5 | 36.5 | +3.0 |
| Scheletri | 8.5 | 11.6 | +3.1 |

### Le carte che i bot con la testa cercano di più

Copie costruite per partita, prima e dopo.

| carta | era | costo | a caso | con strategia | Δ | PV a caso | PV con strategia |
|---|--:|--:|--:|--:|--:|--:|--:|
| Anfiteatro | 2 | 5P | 0.34 | 1.14 | +0.80 | 10.6 | 11.1 |
| Circolo di pietre | 1 | 3P | 0.58 | 1.30 | +0.72 | 9.9 | 8.8 |
| Acquedotto | 2 | 3P | 0.30 | 0.93 | +0.64 | 8.2 | 10.2 |
| Castello | 3 | 2P+1O | 0.41 | 0.97 | +0.56 | 13.5 | 11.4 |
| Palafitte | 1 | 1P | 0.57 | 1.13 | +0.55 | 3.6 | 4.7 |
| Menhir | 1 | 2P | 0.76 | 1.27 | +0.50 | 11.5 | 11.8 |
| Foro | 2 | 3P | 0.59 | 0.99 | +0.40 | 7.4 | 7.9 |
| Abbazia | 3 | 2P+2O | 0.39 | 0.79 | +0.40 | 8.0 | 10.6 |
| Dolmen | 1 | 2P | 0.86 | 1.26 | +0.39 | 9.4 | 11.0 |
| Borgo | 3 | 2P | 0.83 | 1.21 | +0.38 | 4.2 | 5.4 |

### E quelle che evitano

Le stesse carte, dall'altro capo della classifica.

| carta | era | costo | a caso | con strategia | Δ | PV a caso | PV con strategia |
|---|--:|--:|--:|--:|--:|--:|--:|
| Torre di vedetta | 2 | 2P | 0.84 | 0.01 | −0.83 | 2.9 | 3.4 |
| Focolare comune | 1 | 1P | 0.83 | 0.15 | −0.68 | 3.6 | 4.5 |
| Emporio | 2 | 2P | 0.69 | 0.08 | −0.61 | 3.5 | 5.1 |
| Trappole da pesca | 1 | 1P | 0.58 | 0.02 | −0.56 | 1.4 | 1.9 |
| Conceria | 3 | 1P | 0.63 | 0.09 | −0.54 | 2.0 | 2.5 |
| Osservatorio | 4 | 1P+2O | 0.55 | 0.02 | −0.52 | 4.2 | 6.4 |
| Castrum | 2 | 3P | 0.58 | 0.08 | −0.50 | 3.3 | 4.8 |
| Mura | 3 | 2P | 0.89 | 0.40 | −0.48 | 2.3 | 3.5 |
| Caffè letterario | 5 | 0P+2O | 0.55 | 0.08 | −0.47 | 3.3 | 10.0 |
| Villaggio palizzato | 1 | 2P | 0.56 | 0.12 | −0.44 | 3.4 | 5.9 |

### Carte che un bot con la testa non compra quasi mai

- **Grattacielo** (era 5, 2P+4O) — una ogni 385 partite, contro una ogni 6 coi bot a caso
- **Torre di vedetta** (era 2, 2P) — una ogni 73 partite, contro una ogni 1 coi bot a caso
- **Trappole da pesca** (era 1, 1P) — una ogni 61 partite, contro una ogni 2 coi bot a caso

