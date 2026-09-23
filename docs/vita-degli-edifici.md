# La vita degli edifici

Misurata su **10 002 partite** a 3 giocatori, rigiocate dal motore vero (`scripts/tools/audit_partita.gd`, modalità `--vita`). In tutto 350 670 edifici costruiti.

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
| era 1 | 12 | 9.0 | 2.13 | 2.39 | 32% | 19% | 80% | 6.5 |
| era 2 | 12 | 7.5 | 1.96 | 2.28 | 12% | 16% | 83% | 6.7 |
| era 3 | 12 | 9.0 | 1.44 | 1.71 | 46% | 14% | 79% | 6.0 |
| era 4 | 12 | 6.0 | 1.22 | 1.33 | 67% | 15% | 60% | 7.6 |
| era 5 | 12 | 3.6 | 1.00 | 1.00 | 0% | 100% | 0% | 11.7 |

In media una partita mette in tavola **35.1 edifici**; di questi **25%** è ancora in piedi alla fine, **69%** finisce sotterrato e **34%** non supera l'era in cui è nato.

## Cosa salta all'occhio

**1. La Rendita è il canale che paga la durata, ed è quasi tutto.** Le 15 carte con Rendita stampata fruttano in media **9.4 PV** contro i **5.9** delle altre, e restano in piedi 2.64 ere contro 1.44. Non è una sorpresa — la Rendita si incassa a ogni censimento — ma dice che il valore di una carta lo decide quasi tutto un numero solo.

**2. La resistenza fa esattamente il suo mestiere.** Sulle ere 1-4, per ogni punto di resistenza:

| resistenza | carte | ere in piedi | cade nella sua era | PV medi |
|---|--:|--:|--:|--:|
| 1 | 7 | 1.40 | 62% | 3.6 |
| 2 | 17 | 1.42 | 64% | 4.9 |
| 3 | 14 | 2.25 | 21% | 7.0 |
| 4 | 8 | 2.74 | 14% | 9.6 |
| 5 | 2 | 2.35 | 5% | 11.1 |

Fra resistenza 1 e resistenza 4 la vita raddoppia e i punti quasi triplicano. Il salto vero è **fra 2 e 3**: è lì che un edificio smette di essere materiale da riempimento.

**3. Le carte da una pietra dell'era 1 non sono edifici: sono Scavo da seminare.** Approdo, Capanne, Cava, Focolare comune, Grotte dipinte, Palafitte, Trappole da pesca vivono 1.6 ere, finiscono sotto nel **98%** dei casi e 50 punti su cento di quello che fruttano sono Scavo. Funzionano — ma solo se chi le gioca sa che le sta seminando, non costruendo.

**4. Un edificio dell'era 5 non può morire.** Gli eventi sono solo nelle ere 1-4: chi costruisce nell'era Moderna non vedrà mai un censimento né un evento. Si vede nei numeri: vetustà **0.00**, Rendita **0.00**, Scavo **0.00**, e il **100%** ancora in piedi. Le carte dell'era 5 pagano solo Lampo e Verticalità, e vanno lette con un metro diverso dalle altre: il loro valore è tutto nell'istante in cui le metti.

**5. I colossali prendono la cima di tre colonne.** Un edificio da tre caselle conta come strato in tutte le colonne che tocca — quindi incassa il premio della cima **tre volte**:

| larghezza | carte | costruiti | PV medi | di cui Verticalità |
|---|--:|--:|--:|--:|
| 1 casella | 41 | 245 815 | 5.9 | 1.7 |
| 2 caselle | 16 | 82 499 | 9.9 | 4.5 |
| 3 caselle | 3 | 22 356 | 11.2 | 4.4 |

Il caso limite è la **Stazione** (era 5, tre caselle, 2P+4O): **27.0 PV medi**, di cui 23.0 di sola Verticalità — contro i 18.7 della seconda della lista, Università. Arriva in tavola una volta ogni 5 partite, quindi non rompe la media, ma quando arriva decide la colonna. Vale la pena chiedersi se il premio della cima debba contare una volta per edificio invece che una volta per colonna.

## Gli estremi

### Le dodici vite più brevi

Ordinate per **vita sfruttata**, non per ere secche: se no in testa finirebbero le carte dell'era 5, che vivono una sola era perché la partita finisce, non perché crollano.

| carta | costo | res | rend | scavo | per partita | ere intatto | ere in piedi | vita sfruttata | subito | a fine partita | sepolto | vetustà | PV | PV/costo | (L/R/V/S/Sk) |
|---|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|---|
| Approdo | 1P | 1 | 0 | 2 | 0.39 | 1.00 | 1.32 | 26% | 68% | 0% | 99% | 0.00 | **3.2** | 3.2 | 0.0/0.0/1.0/2.1/0.1 |
| Capanne | 1P | 1 | 0 | 2 | 1.10 | 1.06 | 1.46 | 29% | 58% | 0% | 99% | 0.05 | **4.1** | 4.1 | 1.0/0.0/1.0/1.9/0.3 |
| Cava | 1P | 1 | 0 | 2 | 1.19 | 1.06 | 1.46 | 29% | 57% | 0% | 99% | 0.06 | **3.1** | 3.1 | 0.0/0.0/1.0/1.8/0.4 |
| Trappole da pesca | 1P | 1 | 0 | 0 | 0.01 | 1.00 | 1.54 | 31% | 46% | 0% | 99% | 0.00 | **1.5** | 1.5 | 0.0/0.0/1.0/0.1/0.4 |
| Focolare comune | 1P | 1 | 0 | 2 | 0.15 | 1.04 | 1.65 | 33% | 39% | 0% | 99% | 0.04 | **4.2** | 4.2 | 1.0/0.0/1.0/2.0/0.1 |
| Conceria | 1P | 1 | 0 | 0 | 0.11 | 1.01 | 1.04 | 35% | 96% | 0% | 95% | 0.01 | **2.0** | 2.0 | 1.0/0.0/1.0/0.0/0.0 |
| Palafitte | 1P | 2 | 0 | 2 | 1.12 | 1.46 | 1.83 | 37% | 38% | 2% | 97% | 0.40 | **4.2** | 4.2 | 1.0/0.0/1.0/1.6/0.6 |
| Tumulo funerario | 2P | 3 | 0 | 5 | 0.61 | 1.97 | 1.97 | 39% | 4% | 0% | 100% | 0.96 | **4.1** | 2.1 | 1.0/0.0/2.1/0.0/1.1 |
| Ospedale dei pellegrini | 2P+1O | 2 | 0 | 2 | 0.57 | 1.01 | 1.19 | 40% | 82% | 0% | 91% | 0.01 | **5.0** | 1.2 | 2.0/0.0/1.1/1.8/0.1 |
| Villaggio palizzato | 2P | 2 | 0 | 2 | 0.12 | 1.67 | 2.00 | 40% | 1% | 0% | 100% | 0.67 | **5.5** | 2.8 | 1.0/0.0/2.1/0.8/1.6 |
| Cappella | 1P+1O | 2 | 0 | 3 | 1.10 | 1.03 | 1.21 | 40% | 80% | 1% | 92% | 0.03 | **5.9** | 2.0 | 2.0/0.0/1.1/2.7/0.1 |
| Borgo | 2P | 2 | 0 | 2 | 1.21 | 1.03 | 1.24 | 41% | 78% | 1% | 90% | 0.03 | **5.0** | 2.5 | 2.0/0.0/1.1/1.8/0.1 |

### Le dodici che arrivano in fondo

Ordinate per vita sfruttata.

| carta | costo | res | rend | scavo | per partita | ere intatto | ere in piedi | vita sfruttata | subito | a fine partita | sepolto | vetustà | PV | PV/costo | (L/R/V/S/Sk) |
|---|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|---|
| Fondazione d'arte | 1P+2O | 2 | 0 | 0 | 0.37 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **8.5** | 1.7 | 3.0/0.0/5.5/0.0/0.0 |
| Condominio | 1P+1O | 2 | 0 | 0 | 0.79 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **8.1** | 2.7 | 2.0/0.0/6.1/0.0/0.0 |
| Caffè letterario | 0P+2O | 1 | 0 | 0 | 0.08 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **7.2** | 1.8 | 2.0/0.0/5.2/0.0/0.0 |
| Officina | 1P+1O | 2 | 0 | 0 | 0.79 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **8.0** | 2.7 | 2.0/0.0/6.0/0.0/0.0 |
| Monumento ai caduti | 1P+2O | 3 | 0 | 0 | 0.13 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **7.7** | 1.5 | 2.0/0.0/5.7/0.0/0.0 |
| Museo | 1P+3O | 3 | 0 | 0 | 0.11 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **10.2** | 1.5 | 4.0/0.0/6.2/0.0/0.0 |
| Grattacielo | 2P+4O | 3 | 0 | 0 | 0.00 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **10.4** | 1.0 | 4.0/0.0/6.4/0.0/0.0 |
| Biblioteca | 1P+3O | 3 | 0 | 0 | 0.15 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **8.8** | 1.3 | 4.0/0.0/4.8/0.0/0.0 |
| Ponte in acciaio | 1P+3O | 4 | 0 | 0 | 0.26 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **16.7** | 2.4 | 4.0/0.0/12.7/0.0/0.0 |
| Stazione | 2P+4O | 4 | 0 | 0 | 0.18 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **27.0** | 2.7 | 4.0/0.0/23.0/0.0/0.0 |
| Parco archeologico | 1P+2O | 2 | 0 | 0 | 0.41 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **16.6** | 3.3 | 2.0/0.0/14.6/0.0/0.0 |
| Università | 2P+3O | 3 | 0 | 0 | 0.35 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **18.7** | 2.3 | 4.0/0.0/14.7/0.0/0.0 |

### Le dodici che rendono di più

Ordinate per PV medi fruttati al proprietario.

| carta | costo | res | rend | scavo | per partita | ere intatto | ere in piedi | vita sfruttata | subito | a fine partita | sepolto | vetustà | PV | PV/costo | (L/R/V/S/Sk) |
|---|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|---|
| Stazione | 2P+4O | 4 | 0 | 0 | 0.18 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **27.0** | 2.7 | 4.0/0.0/23.0/0.0/0.0 |
| Università | 2P+3O | 3 | 0 | 0 | 0.35 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **18.7** | 2.3 | 4.0/0.0/14.7/0.0/0.0 |
| Ponte in acciaio | 1P+3O | 4 | 0 | 0 | 0.26 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **16.7** | 2.4 | 4.0/0.0/12.7/0.0/0.0 |
| Parco archeologico | 1P+2O | 2 | 0 | 0 | 0.41 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **16.6** | 3.3 | 2.0/0.0/14.6/0.0/0.0 |
| Duomo | 3P+3O | 4 | 4 | 5 | 0.45 | 1.76 | 1.92 | 96% | 8% | 34% | 46% | 0.76 | **13.1** | 1.5 | 0.0/5.4/6.7/0.7/0.3 |
| Fortezza bastionata | 3P+2O | 5 | 3 | 2 | 0.66 | 1.84 | 1.96 | 98% | 4% | 40% | 39% | 0.84 | **12.6** | 1.8 | 0.0/4.9/7.3/0.1/0.3 |
| Menhir | 2P | 4 | 1 | 3 | 1.27 | 3.56 | 3.75 | 75% | 14% | 55% | 44% | 1.89 | **11.6** | 5.8 | 0.0/9.9/0.8/0.3/0.6 |
| Dolmen | 2P | 3 | 1 | 3 | 1.26 | 3.41 | 3.65 | 73% | 14% | 48% | 51% | 1.68 | **10.8** | 5.4 | 0.0/8.8/0.8/0.5/0.7 |
| Castello | 2P+1O | 4 | 3 | 3 | 0.99 | 2.29 | 2.36 | 79% | 2% | 24% | 64% | 1.29 | **10.7** | 2.7 | 0.0/6.8/3.2/0.2/0.6 |
| Grattacielo | 2P+4O | 3 | 0 | 0 | 0.00 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **10.4** | 1.0 | 4.0/0.0/6.4/0.0/0.0 |
| Anfiteatro | 5P | 5 | 2 | 6 | 1.14 | 2.55 | 2.57 | 64% | 6% | 23% | 74% | 1.53 | **10.3** | 2.1 | 0.0/6.7/2.9/0.0/0.7 |
| Museo | 1P+3O | 3 | 0 | 0 | 0.11 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **10.2** | 1.5 | 4.0/0.0/6.2/0.0/0.0 |

### Le dodici che rendono di più per quello che costano

Ordinate per PV diviso il costo in pietra equivalente.

| carta | costo | res | rend | scavo | per partita | ere intatto | ere in piedi | vita sfruttata | subito | a fine partita | sepolto | vetustà | PV | PV/costo | (L/R/V/S/Sk) |
|---|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|---|
| Menhir | 2P | 4 | 1 | 3 | 1.27 | 3.56 | 3.75 | 75% | 14% | 55% | 44% | 1.89 | **11.6** | 5.8 | 0.0/9.9/0.8/0.3/0.6 |
| Dolmen | 2P | 3 | 1 | 3 | 1.26 | 3.41 | 3.65 | 73% | 14% | 48% | 51% | 1.68 | **10.8** | 5.4 | 0.0/8.8/0.8/0.5/0.7 |
| Sacello | 1P | 2 | 0 | 3 | 0.66 | 1.16 | 1.66 | 42% | 39% | 1% | 98% | 0.15 | **4.7** | 4.7 | 1.0/0.0/0.9/2.6/0.2 |
| Palafitte | 1P | 2 | 0 | 2 | 1.12 | 1.46 | 1.83 | 37% | 38% | 2% | 97% | 0.40 | **4.2** | 4.2 | 1.0/0.0/1.0/1.6/0.6 |
| Capanne | 1P | 1 | 0 | 2 | 1.10 | 1.06 | 1.46 | 29% | 58% | 0% | 99% | 0.05 | **4.1** | 4.1 | 1.0/0.0/1.0/1.9/0.3 |
| Grotte dipinte | 1P | 2 | 0 | 6 | 0.50 | 2.02 | 2.35 | 47% | 11% | 5% | 94% | 0.84 | **3.8** | 3.8 | 0.0/0.0/1.0/2.5/0.4 |
| Parco archeologico | 1P+2O | 2 | 0 | 0 | 0.41 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **16.6** | 3.3 | 2.0/0.0/14.6/0.0/0.0 |
| Approdo | 1P | 1 | 0 | 2 | 0.39 | 1.00 | 1.32 | 26% | 68% | 0% | 99% | 0.00 | **3.2** | 3.2 | 0.0/0.0/1.0/2.1/0.1 |
| Cava | 1P | 1 | 0 | 2 | 1.19 | 1.06 | 1.46 | 29% | 57% | 0% | 99% | 0.06 | **3.1** | 3.1 | 0.0/0.0/1.0/1.8/0.4 |
| Acquedotto | 3P | 4 | 1 | 3 | 0.91 | 2.68 | 2.75 | 69% | 14% | 39% | 58% | 1.61 | **9.3** | 3.1 | 0.0/6.0/2.7/0.0/0.5 |
| Terme | 2P | 2 | 0 | 3 | 0.74 | 1.34 | 1.87 | 47% | 20% | 2% | 98% | 0.32 | **5.6** | 2.8 | 2.0/0.0/1.0/2.2/0.4 |
| Condominio | 1P+1O | 2 | 0 | 0 | 0.79 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **8.1** | 2.7 | 2.0/0.0/6.1/0.0/0.0 |

### Le dodici che rendono di meno

Solo carte che arrivano in tavola almeno una volta ogni cinque partite: una carta rara ha medie ballerine.

| carta | costo | res | rend | scavo | per partita | ere intatto | ere in piedi | vita sfruttata | subito | a fine partita | sepolto | vetustà | PV | PV/costo | (L/R/V/S/Sk) |
|---|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|---|
| Mura | 2P | 4 | 0 | 2 | 0.40 | 2.30 | 2.57 | 86% | 5% | 55% | 42% | 1.20 | **2.9** | 1.5 | 1.0/0.0/1.6/0.2/0.1 |
| Cava | 1P | 1 | 0 | 2 | 1.19 | 1.06 | 1.46 | 29% | 57% | 0% | 99% | 0.06 | **3.1** | 3.1 | 0.0/0.0/1.0/1.8/0.4 |
| Approdo | 1P | 1 | 0 | 2 | 0.39 | 1.00 | 1.32 | 26% | 68% | 0% | 99% | 0.00 | **3.2** | 3.2 | 0.0/0.0/1.0/2.1/0.1 |
| Grotte dipinte | 1P | 2 | 0 | 6 | 0.50 | 2.02 | 2.35 | 47% | 11% | 5% | 94% | 0.84 | **3.8** | 3.8 | 0.0/0.0/1.0/2.5/0.4 |
| Mulino | 2P | 2 | 0 | 2 | 0.80 | 1.07 | 1.36 | 45% | 68% | 3% | 90% | 0.07 | **3.9** | 1.9 | 1.0/0.0/1.0/1.8/0.1 |
| Insulae | 2P | 2 | 0 | 2 | 0.76 | 1.32 | 1.85 | 46% | 22% | 2% | 97% | 0.29 | **4.0** | 2.0 | 1.0/0.0/1.0/1.5/0.4 |
| Mercato | 2P | 2 | 0 | 2 | 0.67 | 1.03 | 1.24 | 41% | 77% | 1% | 95% | 0.03 | **4.0** | 2.0 | 1.0/0.0/1.0/1.9/0.1 |
| Capanne | 1P | 1 | 0 | 2 | 1.10 | 1.06 | 1.46 | 29% | 58% | 0% | 99% | 0.05 | **4.1** | 4.1 | 1.0/0.0/1.0/1.9/0.3 |
| Tumulo funerario | 2P | 3 | 0 | 5 | 0.61 | 1.97 | 1.97 | 39% | 4% | 0% | 100% | 0.96 | **4.1** | 2.1 | 1.0/0.0/2.1/0.0/1.1 |
| Palafitte | 1P | 2 | 0 | 2 | 1.12 | 1.46 | 1.83 | 37% | 38% | 2% | 97% | 0.40 | **4.2** | 4.2 | 1.0/0.0/1.0/1.6/0.6 |
| Banco | 1P+1O | 2 | 0 | 0 | 0.80 | 1.00 | 1.01 | 51% | 99% | 1% | 66% | 0.00 | **4.4** | 1.5 | 2.0/0.0/2.4/0.0/0.0 |
| Sacello | 1P | 2 | 0 | 3 | 0.66 | 1.16 | 1.66 | 42% | 39% | 1% | 98% | 0.15 | **4.7** | 4.7 | 1.0/0.0/0.9/2.6/0.2 |

### Le dodici più sepolte

Ordinate per quota di copie finite sotto un altro edificio.

| carta | costo | res | rend | scavo | per partita | ere intatto | ere in piedi | vita sfruttata | subito | a fine partita | sepolto | vetustà | PV | PV/costo | (L/R/V/S/Sk) |
|---|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|---|
| Villaggio palizzato | 2P | 2 | 0 | 2 | 0.12 | 1.67 | 2.00 | 40% | 1% | 0% | 100% | 0.67 | **5.5** | 2.8 | 1.0/0.0/2.1/0.8/1.6 |
| Emporio | 2P | 2 | 0 | 2 | 0.09 | 1.12 | 1.79 | 45% | 21% | 0% | 100% | 0.12 | **4.4** | 2.2 | 1.0/0.0/1.0/1.8/0.6 |
| Tumulo funerario | 2P | 3 | 0 | 5 | 0.61 | 1.97 | 1.97 | 39% | 4% | 0% | 100% | 0.96 | **4.1** | 2.1 | 1.0/0.0/2.1/0.0/1.1 |
| Approdo | 1P | 1 | 0 | 2 | 0.39 | 1.00 | 1.32 | 26% | 68% | 0% | 99% | 0.00 | **3.2** | 3.2 | 0.0/0.0/1.0/2.1/0.1 |
| Focolare comune | 1P | 1 | 0 | 2 | 0.15 | 1.04 | 1.65 | 33% | 39% | 0% | 99% | 0.04 | **4.2** | 4.2 | 1.0/0.0/1.0/2.0/0.1 |
| Trappole da pesca | 1P | 1 | 0 | 0 | 0.01 | 1.00 | 1.54 | 31% | 46% | 0% | 99% | 0.00 | **1.5** | 1.5 | 0.0/0.0/1.0/0.1/0.4 |
| Cava | 1P | 1 | 0 | 2 | 1.19 | 1.06 | 1.46 | 29% | 57% | 0% | 99% | 0.06 | **3.1** | 3.1 | 0.0/0.0/1.0/1.8/0.4 |
| Capanne | 1P | 1 | 0 | 2 | 1.10 | 1.06 | 1.46 | 29% | 58% | 0% | 99% | 0.05 | **4.1** | 4.1 | 1.0/0.0/1.0/1.9/0.3 |
| Sacello | 1P | 2 | 0 | 3 | 0.66 | 1.16 | 1.66 | 42% | 39% | 1% | 98% | 0.15 | **4.7** | 4.7 | 1.0/0.0/0.9/2.6/0.2 |
| Terme | 2P | 2 | 0 | 3 | 0.74 | 1.34 | 1.87 | 47% | 20% | 2% | 98% | 0.32 | **5.6** | 2.8 | 2.0/0.0/1.0/2.2/0.4 |
| Insulae | 2P | 2 | 0 | 2 | 0.76 | 1.32 | 1.85 | 46% | 22% | 2% | 97% | 0.29 | **4.0** | 2.0 | 1.0/0.0/1.0/1.5/0.4 |
| Palafitte | 1P | 2 | 0 | 2 | 1.12 | 1.46 | 1.83 | 37% | 38% | 2% | 97% | 0.40 | **4.2** | 4.2 | 1.0/0.0/1.0/1.6/0.6 |

## Tutte le carte, era per era

### Era 1

| carta | costo | res | rend | scavo | per partita | ere intatto | ere in piedi | vita sfruttata | subito | a fine partita | sepolto | vetustà | PV | PV/costo | (L/R/V/S/Sk) |
|---|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|---|
| Menhir | 2P | 4 | 1 | 3 | 1.27 | 3.56 | 3.75 | 75% | 14% | 55% | 44% | 1.89 | **11.6** | 5.8 | 0.0/9.9/0.8/0.3/0.6 |
| Dolmen | 2P | 3 | 1 | 3 | 1.26 | 3.41 | 3.65 | 73% | 14% | 48% | 51% | 1.68 | **10.8** | 5.4 | 0.0/8.8/0.8/0.5/0.7 |
| Circolo di pietre | 3P | 4 | 1 | 5 | 1.30 | 2.56 | 2.63 | 53% | 31% | 26% | 72% | 1.26 | **8.1** | 2.7 | 0.0/5.5/1.8/0.1/0.6 |
| Grotte dipinte | 1P | 2 | 0 | 6 | 0.50 | 2.02 | 2.35 | 47% | 11% | 5% | 94% | 0.84 | **3.8** | 3.8 | 0.0/0.0/1.0/2.5/0.4 |
| Villaggio palizzato | 2P | 2 | 0 | 2 | 0.12 | 1.67 | 2.00 | 40% | 1% | 0% | 100% | 0.67 | **5.5** | 2.8 | 1.0/0.0/2.1/0.8/1.6 |
| Tumulo funerario | 2P | 3 | 0 | 5 | 0.61 | 1.97 | 1.97 | 39% | 4% | 0% | 100% | 0.96 | **4.1** | 2.1 | 1.0/0.0/2.1/0.0/1.1 |
| Palafitte | 1P | 2 | 0 | 2 | 1.12 | 1.46 | 1.83 | 37% | 38% | 2% | 97% | 0.40 | **4.2** | 4.2 | 1.0/0.0/1.0/1.6/0.6 |
| Focolare comune | 1P | 1 | 0 | 2 | 0.15 | 1.04 | 1.65 | 33% | 39% | 0% | 99% | 0.04 | **4.2** | 4.2 | 1.0/0.0/1.0/2.0/0.1 |
| Trappole da pesca | 1P | 1 | 0 | 0 | 0.01 | 1.00 | 1.54 | 31% | 46% | 0% | 99% | 0.00 | **1.5** | 1.5 | 0.0/0.0/1.0/0.1/0.4 |
| Cava | 1P | 1 | 0 | 2 | 1.19 | 1.06 | 1.46 | 29% | 57% | 0% | 99% | 0.06 | **3.1** | 3.1 | 0.0/0.0/1.0/1.8/0.4 |
| Capanne | 1P | 1 | 0 | 2 | 1.10 | 1.06 | 1.46 | 29% | 58% | 0% | 99% | 0.05 | **4.1** | 4.1 | 1.0/0.0/1.0/1.9/0.3 |
| Approdo | 1P | 1 | 0 | 2 | 0.39 | 1.00 | 1.32 | 26% | 68% | 0% | 99% | 0.00 | **3.2** | 3.2 | 0.0/0.0/1.0/2.1/0.1 |

### Era 2

| carta | costo | res | rend | scavo | per partita | ere intatto | ere in piedi | vita sfruttata | subito | a fine partita | sepolto | vetustà | PV | PV/costo | (L/R/V/S/Sk) |
|---|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|---|
| Acquedotto | 3P | 4 | 1 | 3 | 0.91 | 2.68 | 2.75 | 69% | 14% | 39% | 58% | 1.61 | **9.3** | 3.1 | 0.0/6.0/2.7/0.0/0.5 |
| Ponte | 3P | 3 | 1 | 3 | 0.34 | 2.27 | 2.60 | 65% | 3% | 25% | 73% | 1.20 | **7.3** | 2.4 | 0.0/4.1/1.9/0.6/0.7 |
| Anfiteatro | 5P | 5 | 2 | 6 | 1.14 | 2.55 | 2.57 | 64% | 6% | 23% | 74% | 1.53 | **10.3** | 2.1 | 0.0/6.7/2.9/0.0/0.7 |
| Tempio | 3P | 3 | 1 | 3 | 0.77 | 1.96 | 2.46 | 62% | 6% | 20% | 78% | 0.92 | **5.5** | 1.8 | 0.0/3.1/0.9/1.1/0.5 |
| Foro | 3P | 3 | 1 | 5 | 0.99 | 2.13 | 2.43 | 61% | 6% | 19% | 80% | 1.08 | **7.1** | 2.4 | 0.0/3.3/1.9/0.8/1.0 |
| Teatro | 2P | 3 | 0 | 5 | 1.00 | 1.93 | 2.24 | 56% | 2% | 10% | 90% | 0.83 | **4.9** | 2.4 | 2.0/0.0/1.0/1.5/0.4 |
| Torre di vedetta | 2P | 3 | 0 | 2 | 0.01 | 1.79 | 2.14 | 53% | 0% | 6% | 94% | 0.77 | **2.9** | 1.4 | 1.0/0.0/1.1/0.6/0.2 |
| Castrum | 3P | 4 | 0 | 3 | 0.05 | 2.11 | 2.11 | 53% | 1% | 6% | 93% | 1.12 | **3.8** | 1.3 | 1.0/0.0/2.1/0.0/0.7 |
| Terme | 2P | 2 | 0 | 3 | 0.74 | 1.34 | 1.87 | 47% | 20% | 2% | 98% | 0.32 | **5.6** | 2.8 | 2.0/0.0/1.0/2.2/0.4 |
| Insulae | 2P | 2 | 0 | 2 | 0.76 | 1.32 | 1.85 | 46% | 22% | 2% | 97% | 0.29 | **4.0** | 2.0 | 1.0/0.0/1.0/1.5/0.4 |
| Emporio | 2P | 2 | 0 | 2 | 0.09 | 1.12 | 1.79 | 45% | 21% | 0% | 100% | 0.12 | **4.4** | 2.2 | 1.0/0.0/1.0/1.8/0.6 |
| Sacello | 1P | 2 | 0 | 3 | 0.66 | 1.16 | 1.66 | 42% | 39% | 1% | 98% | 0.15 | **4.7** | 4.7 | 1.0/0.0/0.9/2.6/0.2 |

### Era 3

| carta | costo | res | rend | scavo | per partita | ere intatto | ere in piedi | vita sfruttata | subito | a fine partita | sepolto | vetustà | PV | PV/costo | (L/R/V/S/Sk) |
|---|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|---|
| Mura | 2P | 4 | 0 | 2 | 0.40 | 2.30 | 2.57 | 86% | 5% | 55% | 42% | 1.20 | **2.9** | 1.5 | 1.0/0.0/1.6/0.2/0.1 |
| Castello | 2P+1O | 4 | 3 | 3 | 0.99 | 2.29 | 2.36 | 79% | 2% | 24% | 64% | 1.29 | **10.7** | 2.7 | 0.0/6.8/3.2/0.2/0.6 |
| Abbazia | 2P+2O | 3 | 3 | 5 | 0.78 | 1.99 | 2.35 | 78% | 10% | 39% | 54% | 0.99 | **10.0** | 1.7 | 0.0/6.0/2.3/1.3/0.3 |
| Chiesa | 2P+1O | 3 | 2 | 3 | 0.93 | 1.72 | 2.03 | 68% | 27% | 26% | 70% | 0.70 | **6.1** | 1.5 | 0.0/3.2/1.2/1.5/0.3 |
| Arsenale | 3P+1O | 3 | 0 | 2 | 0.33 | 1.69 | 1.92 | 64% | 14% | 4% | 85% | 0.69 | **5.7** | 1.1 | 2.0/0.0/2.5/0.6/0.6 |
| Torre civica | 2P | 3 | 0 | 2 | 1.12 | 1.32 | 1.88 | 63% | 29% | 15% | 76% | 0.30 | **4.8** | 2.4 | 2.0/0.0/1.3/1.3/0.3 |
| Mulino | 2P | 2 | 0 | 2 | 0.80 | 1.07 | 1.36 | 45% | 68% | 3% | 90% | 0.07 | **3.9** | 1.9 | 1.0/0.0/1.0/1.8/0.1 |
| Mercato | 2P | 2 | 0 | 2 | 0.67 | 1.03 | 1.24 | 41% | 77% | 1% | 95% | 0.03 | **4.0** | 2.0 | 1.0/0.0/1.0/1.9/0.1 |
| Borgo | 2P | 2 | 0 | 2 | 1.21 | 1.03 | 1.24 | 41% | 78% | 1% | 90% | 0.03 | **5.0** | 2.5 | 2.0/0.0/1.1/1.8/0.1 |
| Cappella | 1P+1O | 2 | 0 | 3 | 1.10 | 1.03 | 1.21 | 40% | 80% | 1% | 92% | 0.03 | **5.9** | 2.0 | 2.0/0.0/1.1/2.7/0.1 |
| Ospedale dei pellegrini | 2P+1O | 2 | 0 | 2 | 0.57 | 1.01 | 1.19 | 40% | 82% | 0% | 91% | 0.01 | **5.0** | 1.2 | 2.0/0.0/1.1/1.8/0.1 |
| Conceria | 1P | 1 | 0 | 0 | 0.11 | 1.01 | 1.04 | 35% | 96% | 0% | 95% | 0.01 | **2.0** | 2.0 | 1.0/0.0/1.0/0.0/0.0 |

### Era 4

| carta | costo | res | rend | scavo | per partita | ere intatto | ere in piedi | vita sfruttata | subito | a fine partita | sepolto | vetustà | PV | PV/costo | (L/R/V/S/Sk) |
|---|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|---|
| Ponte monumentale | 2P+2O | 4 | 3 | 3 | 0.43 | 1.75 | 1.97 | 98% | 3% | 58% | 28% | 0.75 | **9.3** | 1.6 | 0.0/5.0/3.9/0.2/0.2 |
| Fortezza bastionata | 3P+2O | 5 | 3 | 2 | 0.66 | 1.84 | 1.96 | 98% | 4% | 40% | 39% | 0.84 | **12.6** | 1.8 | 0.0/4.9/7.3/0.1/0.3 |
| Duomo | 3P+3O | 4 | 4 | 5 | 0.45 | 1.76 | 1.92 | 96% | 8% | 34% | 46% | 0.76 | **13.1** | 1.5 | 0.0/5.4/6.7/0.7/0.3 |
| Piazza monumentale | 2P+2O | 3 | 2 | 3 | 0.18 | 1.48 | 1.69 | 84% | 31% | 27% | 45% | 0.48 | **10.1** | 1.7 | 0.0/2.1/7.0/0.8/0.2 |
| Villa | 2P+2O | 3 | 0 | 3 | 0.67 | 1.03 | 1.34 | 67% | 66% | 19% | 64% | 0.03 | **8.1** | 1.3 | 4.0/0.0/2.1/1.9/0.1 |
| Palazzo signorile | 2P+2O | 3 | 0 | 3 | 0.58 | 1.02 | 1.14 | 57% | 86% | 7% | 72% | 0.02 | **7.2** | 1.2 | 3.0/0.0/2.1/2.1/0.0 |
| Osservatorio | 1P+2O | 2 | 0 | 2 | 0.02 | 1.00 | 1.03 | 52% | 97% | 2% | 80% | 0.00 | **5.2** | 1.0 | 2.0/0.0/1.6/1.6/0.0 |
| Loggia | 1P+1O | 2 | 0 | 2 | 0.82 | 1.00 | 1.03 | 51% | 97% | 1% | 68% | 0.00 | **5.7** | 1.9 | 2.0/0.0/2.3/1.4/0.0 |
| Banco | 1P+1O | 2 | 0 | 0 | 0.80 | 1.00 | 1.01 | 51% | 99% | 1% | 66% | 0.00 | **4.4** | 1.5 | 2.0/0.0/2.4/0.0/0.0 |
| Bottega d'artista | 1P+1O | 2 | 0 | 2 | 0.84 | 1.00 | 1.01 | 51% | 99% | 1% | 68% | 0.00 | **5.7** | 1.9 | 2.0/0.0/2.4/1.4/0.0 |
| Accademia | 1P+2O | 2 | 0 | 3 | 0.26 | 1.00 | 1.01 | 50% | 99% | 0% | 79% | 0.00 | **6.2** | 1.2 | 2.0/0.0/1.8/2.4/0.0 |
| Giardino all'italiana | 0P+2O | 1 | 0 | 0 | 0.24 | 1.00 | 1.00 | 50% | 100% | 0% | 77% | 0.00 | **4.7** | 1.2 | 3.0/0.0/1.7/0.0/0.0 |

### Era 5

| carta | costo | res | rend | scavo | per partita | ere intatto | ere in piedi | vita sfruttata | subito | a fine partita | sepolto | vetustà | PV | PV/costo | (L/R/V/S/Sk) |
|---|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|---|
| Fondazione d'arte | 1P+2O | 2 | 0 | 0 | 0.37 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **8.5** | 1.7 | 3.0/0.0/5.5/0.0/0.0 |
| Condominio | 1P+1O | 2 | 0 | 0 | 0.79 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **8.1** | 2.7 | 2.0/0.0/6.1/0.0/0.0 |
| Caffè letterario | 0P+2O | 1 | 0 | 0 | 0.08 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **7.2** | 1.8 | 2.0/0.0/5.2/0.0/0.0 |
| Officina | 1P+1O | 2 | 0 | 0 | 0.79 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **8.0** | 2.7 | 2.0/0.0/6.0/0.0/0.0 |
| Monumento ai caduti | 1P+2O | 3 | 0 | 0 | 0.13 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **7.7** | 1.5 | 2.0/0.0/5.7/0.0/0.0 |
| Museo | 1P+3O | 3 | 0 | 0 | 0.11 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **10.2** | 1.5 | 4.0/0.0/6.2/0.0/0.0 |
| Grattacielo | 2P+4O | 3 | 0 | 0 | 0.00 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **10.4** | 1.0 | 4.0/0.0/6.4/0.0/0.0 |
| Biblioteca | 1P+3O | 3 | 0 | 0 | 0.15 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **8.8** | 1.3 | 4.0/0.0/4.8/0.0/0.0 |
| Ponte in acciaio | 1P+3O | 4 | 0 | 0 | 0.26 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **16.7** | 2.4 | 4.0/0.0/12.7/0.0/0.0 |
| Stazione | 2P+4O | 4 | 0 | 0 | 0.18 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **27.0** | 2.7 | 4.0/0.0/23.0/0.0/0.0 |
| Parco archeologico | 1P+2O | 2 | 0 | 0 | 0.41 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **16.6** | 3.3 | 2.0/0.0/14.6/0.0/0.0 |
| Università | 2P+3O | 3 | 0 | 0 | 0.35 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **18.7** | 2.3 | 4.0/0.0/14.7/0.0/0.0 |

## Due correlazioni, su chi arriva in tavola almeno 50 volte

- **resistenza stampata** → ere in piedi: r = +0.50 · → PV: r = +0.53
- **costo in pietra** → ere in piedi: r = +0.61 · → PV: r = +0.18
- **Rendita stampata** → ere in piedi: r = +0.45 · → PV: r = +0.32
- **Scavo stampato** → ere in piedi: r = +0.65 · → PV: r = -0.16

---

Rifare il conto: `godot --headless res://scenes/audit_partita.tscn -- --players 3 --vita 2500 --seed 100000` (quattro processi, semi 100000 / 102500 / 105000 / 107500).

## Cosa cambia con la Verticalità più piatta

Le stesse misure su 10002 partite con la tabella **2/6/12/20** e 10002 con la **2/5/9/14**, a parità di tutto il resto: stessi bot, stesso numero di giocatori. La colonna Δ è la seconda meno la prima.

| misura | Verticalità 2/6/12/20 | Verticalità 2/5/9/14 | Δ |
|---|--:|--:|--:|
| edifici costruiti per partita | 35.01 | 35.06 | +0.05 |
| ere intatto (media) | 1.65 | 1.65 | +0.00 |
| ere in piedi (media) | 1.87 | 1.87 | +0.00 |
| cade nella sua era | 34% | 34% | +0% |
| in piedi a fine partita | 24% | 25% | +0% |
| sepolto | 69% | 69% | +0% |
| vetustà media | 0.57 | 0.57 | +0.00 |
| potenziamenti per edificio | 0.04 | 0.04 | +0.00 |
| PV per edificio | 8.2 | 7.1 | −1.1 |
| PV per partita (i tre giocatori insieme) | 287 | 250 | −36 |

| canale (PV per partita, tutti i giocatori) | Verticalità 2/6/12/20 | Verticalità 2/5/9/14 | Δ |
|---|--:|--:|--:|
| Lampo | 38.5 | 39.1 | +0.6 |
| Rendita | 72.8 | 73.7 | +0.9 |
| Verticalita | 127.4 | 89.2 | −38.2 |
| Scavo | 36.5 | 36.8 | +0.3 |
| Scheletri | 11.6 | 11.6 | −0.0 |

### Le carte che si cercano di più

Copie costruite per partita, prima e dopo.

| carta | era | costo | Verticalità 2/6/12/20 | Verticalità 2/5/9/14 | Δ | PV Verticalità 2/6/12/20 | PV Verticalità 2/5/9/14 |
|---|--:|--:|--:|--:|--:|--:|--:|
| Palazzo signorile | 4 | 2P+2O | 0.52 | 0.58 | +0.06 | 8.2 | 7.2 |
| Villa | 4 | 2P+2O | 0.64 | 0.67 | +0.03 | 9.0 | 8.1 |
| Insulae | 2 | 2P | 0.73 | 0.76 | +0.03 | 4.4 | 4.0 |
| Giardino all'italiana | 4 | 0P+2O | 0.21 | 0.24 | +0.03 | 5.7 | 4.7 |
| Università | 5 | 2P+3O | 0.32 | 0.35 | +0.02 | 25.4 | 18.7 |
| Ponte in acciaio | 5 | 1P+3O | 0.24 | 0.26 | +0.02 | 22.8 | 16.7 |
| Castello | 3 | 2P+1O | 0.97 | 0.99 | +0.02 | 11.4 | 10.7 |
| Accademia | 4 | 1P+2O | 0.24 | 0.26 | +0.02 | 7.0 | 6.2 |
| Duomo | 4 | 3P+3O | 0.43 | 0.45 | +0.02 | 15.7 | 13.1 |
| Biblioteca | 5 | 1P+3O | 0.13 | 0.15 | +0.02 | 10.8 | 8.8 |

### E quelle che si cercano di meno

Le stesse carte, dall'altro capo della classifica.

| carta | era | costo | Verticalità 2/6/12/20 | Verticalità 2/5/9/14 | Δ | PV Verticalità 2/6/12/20 | PV Verticalità 2/5/9/14 |
|---|--:|--:|--:|--:|--:|--:|--:|
| Arsenale | 3 | 3P+1O | 0.44 | 0.33 | −0.11 | 6.8 | 5.7 |
| Piazza monumentale | 4 | 2P+2O | 0.26 | 0.18 | −0.08 | 13.8 | 10.1 |
| Ponte monumentale | 4 | 2P+2O | 0.46 | 0.43 | −0.03 | 11.5 | 9.3 |
| Castrum | 2 | 3P | 0.08 | 0.05 | −0.02 | 4.8 | 3.8 |
| Ponte | 2 | 3P | 0.36 | 0.34 | −0.02 | 7.8 | 7.3 |
| Acquedotto | 2 | 3P | 0.93 | 0.91 | −0.02 | 10.2 | 9.3 |
| Chiesa | 3 | 2P+1O | 0.94 | 0.93 | −0.01 | 6.4 | 6.1 |
| Fortezza bastionata | 4 | 3P+2O | 0.66 | 0.66 | −0.01 | 15.8 | 12.6 |
| Abbazia | 3 | 2P+2O | 0.79 | 0.78 | −0.01 | 10.6 | 10.0 |
| Mercato | 3 | 2P | 0.67 | 0.67 | −0.01 | 4.5 | 4.0 |

### Carte che non arrivano quasi mai in tavola

- **Grattacielo** (era 5, 2P+4O) — una ogni 417 partite, contro una ogni 385 prima
- **Torre di vedetta** (era 2, 2P) — una ogni 92 partite, contro una ogni 73 prima
- **Trappole da pesca** (era 1, 1P) — una ogni 68 partite, contro una ogni 61 prima

