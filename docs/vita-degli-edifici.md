# La vita degli edifici

Misurata su **10 000 partite** a 3 giocatori, rigiocate dal motore vero (`scripts/tools/audit_partita.gd`, modalità `--vita`). In tutto 286 755 edifici costruiti.

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
| era 1 | 12 | 6.8 | 2.11 | 2.37 | 32% | 17% | 68% | 5.9 |
| era 2 | 12 | 5.5 | 1.94 | 2.25 | 12% | 14% | 69% | 6.2 |
| era 3 | 12 | 6.4 | 1.41 | 1.66 | 46% | 9% | 72% | 5.5 |
| era 4 | 12 | 5.9 | 1.24 | 1.35 | 65% | 12% | 57% | 6.6 |
| era 5 | 12 | 4.1 | 1.00 | 1.00 | 0% | 100% | 0% | 12.1 |

In media una partita mette in tavola **28.7 edifici**; di questi **25%** è ancora in piedi alla fine, **57%** finisce sotterrato e **34%** non supera l'era in cui è nato.

## Cosa salta all'occhio

**1. La Rendita è il canale che paga la durata, ed è quasi tutto.** Le 15 carte con Rendita stampata fruttano in media **8.5 PV** contro i **6.1** delle altre, e restano in piedi 2.53 ere contro 1.38. Non è una sorpresa — la Rendita si incassa a ogni censimento — ma dice che il valore di una carta lo decide quasi tutto un numero solo.

**2. La resistenza fa esattamente il suo mestiere.** Sulle ere 1-4, per ogni punto di resistenza:

| resistenza | carte | ere in piedi | cade nella sua era | PV medi |
|---|--:|--:|--:|--:|
| 1 | 7 | 1.37 | 65% | 3.3 |
| 2 | 17 | 1.40 | 66% | 4.3 |
| 3 | 14 | 2.14 | 24% | 6.4 |
| 4 | 8 | 2.60 | 13% | 8.9 |
| 5 | 2 | 2.30 | 5% | 9.9 |

Fra resistenza 1 e resistenza 4 la vita raddoppia e i punti quasi triplicano. Il salto vero è **fra 2 e 3**: è lì che un edificio smette di essere materiale da riempimento.

**3. Le carte da una pietra dell'era 1 non sono edifici: sono Scavo da seminare.** Approdo, Capanne, Cava, Focolare comune, Grotte dipinte, Palafitte, Trappole da pesca vivono 1.6 ere, finiscono sotto nel **78%** dei casi e 43 punti su cento di quello che fruttano sono Scavo. Funzionano — ma solo se chi le gioca sa che le sta seminando, non costruendo.

**4. Un edificio dell'era 5 non può morire.** Gli eventi sono solo nelle ere 1-4: chi costruisce nell'era Moderna non vedrà mai un censimento né un evento. Si vede nei numeri: vetustà **0.00**, Rendita **0.00**, Scavo **0.00**, e il **100%** ancora in piedi. Le carte dell'era 5 pagano solo Lampo e Verticalità, e vanno lette con un metro diverso dalle altre: il loro valore è tutto nell'istante in cui le metti.

**5. I colossali prendono la cima di tre colonne.** Un edificio da tre caselle conta come strato in tutte le colonne che tocca — quindi incassa il premio della cima **tre volte**:

| larghezza | carte | costruiti | PV medi | di cui Verticalità |
|---|--:|--:|--:|--:|
| 1 casella | 41 | 194 563 | 5.5 | 1.7 |
| 2 caselle | 16 | 74 118 | 9.4 | 4.6 |
| 3 caselle | 3 | 18 074 | 12.0 | 5.9 |

Il caso limite è la **Stazione** (era 5, tre caselle, 2P+4O): **27.2 PV medi**, di cui 23.2 di sola Verticalità — contro i 18.9 della seconda della lista, Università. Arriva in tavola una volta ogni 4 partite, quindi non rompe la media, ma quando arriva decide la colonna. Vale la pena chiedersi se il premio della cima debba contare una volta per edificio invece che una volta per colonna.

## Gli estremi

### Le dodici vite più brevi

Ordinate per **vita sfruttata**, non per ere secche: se no in testa finirebbero le carte dell'era 5, che vivono una sola era perché la partita finisce, non perché crollano.

| carta | costo | res | rend | scavo | per partita | ere intatto | ere in piedi | vita sfruttata | subito | a fine partita | sepolto | vetustà | PV | PV/costo | (L/R/V/S/Sk) |
|---|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|---|
| Approdo | 1P | 1 | 0 | 2 | 0.30 | 1.00 | 1.31 | 26% | 69% | 0% | 74% | 0.00 | **2.7** | 2.7 | 0.0/0.0/1.0/1.6/0.1 |
| Capanne | 1P | 1 | 0 | 2 | 0.82 | 1.05 | 1.46 | 29% | 58% | 0% | 82% | 0.06 | **3.7** | 3.7 | 1.0/0.0/1.0/1.5/0.2 |
| Cava | 1P | 1 | 0 | 2 | 0.90 | 1.07 | 1.47 | 29% | 57% | 0% | 80% | 0.07 | **2.7** | 2.7 | 0.0/0.0/1.0/1.5/0.3 |
| Trappole da pesca | 1P | 1 | 0 | 0 | 0.01 | 1.00 | 1.48 | 30% | 52% | 0% | 79% | 0.00 | **1.4** | 1.4 | 0.0/0.0/1.0/0.2/0.2 |
| Focolare comune | 1P | 1 | 0 | 2 | 0.11 | 1.04 | 1.61 | 32% | 42% | 0% | 81% | 0.04 | **3.8** | 3.8 | 1.0/0.0/1.0/1.7/0.1 |
| Conceria | 1P | 1 | 0 | 0 | 0.06 | 1.00 | 1.03 | 34% | 97% | 0% | 81% | 0.00 | **2.1** | 2.1 | 1.0/0.0/1.0/0.0/0.0 |
| Palafitte | 1P | 2 | 0 | 2 | 0.84 | 1.48 | 1.85 | 37% | 38% | 1% | 74% | 0.43 | **3.4** | 3.4 | 1.0/0.0/1.0/1.1/0.3 |
| Tumulo funerario | 2P | 3 | 0 | 5 | 0.46 | 1.97 | 1.97 | 39% | 4% | 0% | 100% | 0.97 | **4.1** | 2.0 | 1.0/0.0/2.0/0.0/1.0 |
| Ospedale dei pellegrini | 2P+1O | 2 | 0 | 2 | 0.41 | 1.01 | 1.18 | 39% | 82% | 0% | 71% | 0.01 | **4.5** | 1.1 | 2.0/0.0/1.0/1.4/0.1 |
| Borgo | 2P | 2 | 0 | 2 | 0.84 | 1.02 | 1.20 | 40% | 81% | 1% | 77% | 0.02 | **4.7** | 2.3 | 2.0/0.0/1.0/1.5/0.1 |
| Villaggio palizzato | 2P | 2 | 0 | 2 | 0.09 | 1.68 | 2.00 | 40% | 0% | 0% | 100% | 0.68 | **5.3** | 2.7 | 1.0/0.0/2.0/0.8/1.4 |
| Cappella | 1P+1O | 2 | 0 | 3 | 0.86 | 1.02 | 1.20 | 40% | 80% | 0% | 77% | 0.02 | **5.4** | 1.8 | 2.0/0.0/1.0/2.3/0.1 |

### Le dodici che arrivano in fondo

Ordinate per vita sfruttata.

| carta | costo | res | rend | scavo | per partita | ere intatto | ere in piedi | vita sfruttata | subito | a fine partita | sepolto | vetustà | PV | PV/costo | (L/R/V/S/Sk) |
|---|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|---|
| Fondazione d'arte | 1P+2O | 2 | 0 | 0 | 0.46 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **8.1** | 1.6 | 3.0/0.0/5.1/0.0/0.0 |
| Condominio | 1P+1O | 2 | 0 | 0 | 0.68 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **7.8** | 2.6 | 2.0/0.0/5.8/0.0/0.0 |
| Caffè letterario | 0P+2O | 1 | 0 | 0 | 0.10 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **6.6** | 1.7 | 2.0/0.0/4.6/0.0/0.0 |
| Officina | 1P+1O | 2 | 0 | 0 | 0.68 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **7.6** | 2.5 | 2.0/0.0/5.6/0.0/0.0 |
| Monumento ai caduti | 1P+2O | 3 | 0 | 0 | 0.18 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **7.8** | 1.6 | 2.0/0.0/5.8/0.0/0.0 |
| Museo | 1P+3O | 3 | 0 | 0 | 0.18 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **10.5** | 1.5 | 4.0/0.0/6.5/0.0/0.0 |
| Grattacielo | 2P+4O | 3 | 0 | 0 | 0.01 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **10.5** | 1.0 | 4.0/0.0/6.5/0.0/0.0 |
| Biblioteca | 1P+3O | 3 | 0 | 0 | 0.26 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **8.7** | 1.2 | 4.0/0.0/4.7/0.0/0.0 |
| Ponte in acciaio | 1P+3O | 4 | 0 | 0 | 0.38 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **16.2** | 2.3 | 4.0/0.0/12.2/0.0/0.0 |
| Stazione | 2P+4O | 4 | 0 | 0 | 0.26 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **27.2** | 2.7 | 4.0/0.0/23.2/0.0/0.0 |
| Parco archeologico | 1P+2O | 2 | 0 | 0 | 0.43 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **16.6** | 3.3 | 2.0/0.0/14.6/0.0/0.0 |
| Università | 2P+3O | 3 | 0 | 0 | 0.43 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **18.9** | 2.4 | 4.0/0.0/14.9/0.0/0.0 |

### Le dodici che rendono di più

Ordinate per PV medi fruttati al proprietario.

| carta | costo | res | rend | scavo | per partita | ere intatto | ere in piedi | vita sfruttata | subito | a fine partita | sepolto | vetustà | PV | PV/costo | (L/R/V/S/Sk) |
|---|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|---|
| Stazione | 2P+4O | 4 | 0 | 0 | 0.26 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **27.2** | 2.7 | 4.0/0.0/23.2/0.0/0.0 |
| Università | 2P+3O | 3 | 0 | 0 | 0.43 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **18.9** | 2.4 | 4.0/0.0/14.9/0.0/0.0 |
| Parco archeologico | 1P+2O | 2 | 0 | 0 | 0.43 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **16.6** | 3.3 | 2.0/0.0/14.6/0.0/0.0 |
| Ponte in acciaio | 1P+3O | 4 | 0 | 0 | 0.38 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **16.2** | 2.3 | 4.0/0.0/12.2/0.0/0.0 |
| Menhir | 2P | 4 | 1 | 3 | 0.95 | 3.50 | 3.70 | 74% | 15% | 51% | 39% | 1.86 | **11.0** | 5.5 | 0.0/9.5/1.0/0.0/0.5 |
| Duomo | 3P+3O | 4 | 4 | 5 | 0.53 | 1.79 | 1.93 | 96% | 7% | 17% | 71% | 0.79 | **10.5** | 1.2 | 0.0/4.7/4.4/0.8/0.6 |
| Museo | 1P+3O | 3 | 0 | 0 | 0.18 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **10.5** | 1.5 | 4.0/0.0/6.5/0.0/0.0 |
| Grattacielo | 2P+4O | 3 | 0 | 0 | 0.01 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **10.5** | 1.0 | 4.0/0.0/6.5/0.0/0.0 |
| Anfiteatro | 5P | 5 | 2 | 6 | 0.86 | 2.53 | 2.54 | 64% | 5% | 22% | 60% | 1.50 | **10.0** | 2.0 | 0.0/6.5/3.0/0.0/0.5 |
| Fortezza bastionata | 3P+2O | 5 | 3 | 2 | 0.60 | 1.85 | 1.96 | 98% | 4% | 22% | 64% | 0.85 | **9.9** | 1.4 | 0.0/4.2/5.0/0.2/0.5 |
| Dolmen | 2P | 3 | 1 | 3 | 0.95 | 3.36 | 3.59 | 72% | 14% | 44% | 40% | 1.68 | **9.8** | 4.9 | 0.0/8.5/0.9/0.0/0.4 |
| Acquedotto | 3P | 4 | 1 | 3 | 0.69 | 2.57 | 2.65 | 66% | 13% | 33% | 48% | 1.49 | **8.7** | 2.9 | 0.0/5.3/2.9/0.0/0.5 |

### Le dodici che rendono di più per quello che costano

Ordinate per PV diviso il costo in pietra equivalente.

| carta | costo | res | rend | scavo | per partita | ere intatto | ere in piedi | vita sfruttata | subito | a fine partita | sepolto | vetustà | PV | PV/costo | (L/R/V/S/Sk) |
|---|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|---|
| Menhir | 2P | 4 | 1 | 3 | 0.95 | 3.50 | 3.70 | 74% | 15% | 51% | 39% | 1.86 | **11.0** | 5.5 | 0.0/9.5/1.0/0.0/0.5 |
| Dolmen | 2P | 3 | 1 | 3 | 0.95 | 3.36 | 3.59 | 72% | 14% | 44% | 40% | 1.68 | **9.8** | 4.9 | 0.0/8.5/0.9/0.0/0.4 |
| Sacello | 1P | 2 | 0 | 3 | 0.49 | 1.15 | 1.65 | 41% | 39% | 1% | 77% | 0.14 | **4.2** | 4.2 | 1.0/0.0/1.0/2.0/0.2 |
| Capanne | 1P | 1 | 0 | 2 | 0.82 | 1.05 | 1.46 | 29% | 58% | 0% | 82% | 0.06 | **3.7** | 3.7 | 1.0/0.0/1.0/1.5/0.2 |
| Palafitte | 1P | 2 | 0 | 2 | 0.84 | 1.48 | 1.85 | 37% | 38% | 1% | 74% | 0.43 | **3.4** | 3.4 | 1.0/0.0/1.0/1.1/0.3 |
| Parco archeologico | 1P+2O | 2 | 0 | 0 | 0.43 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **16.6** | 3.3 | 2.0/0.0/14.6/0.0/0.0 |
| Acquedotto | 3P | 4 | 1 | 3 | 0.69 | 2.57 | 2.65 | 66% | 13% | 33% | 48% | 1.49 | **8.7** | 2.9 | 0.0/5.3/2.9/0.0/0.5 |
| Cava | 1P | 1 | 0 | 2 | 0.90 | 1.07 | 1.47 | 29% | 57% | 0% | 80% | 0.07 | **2.7** | 2.7 | 0.0/0.0/1.0/1.5/0.3 |
| Stazione | 2P+4O | 4 | 0 | 0 | 0.26 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **27.2** | 2.7 | 4.0/0.0/23.2/0.0/0.0 |
| Approdo | 1P | 1 | 0 | 2 | 0.30 | 1.00 | 1.31 | 26% | 69% | 0% | 74% | 0.00 | **2.7** | 2.7 | 0.0/0.0/1.0/1.6/0.1 |
| Condominio | 1P+1O | 2 | 0 | 0 | 0.68 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **7.8** | 2.6 | 2.0/0.0/5.8/0.0/0.0 |
| Circolo di pietre | 3P | 4 | 1 | 5 | 0.97 | 2.53 | 2.60 | 52% | 30% | 24% | 70% | 1.23 | **7.8** | 2.6 | 0.0/5.3/2.0/0.0/0.6 |

### Le dodici che rendono di meno

Solo carte che arrivano in tavola almeno una volta ogni cinque partite: una carta rara ha medie ballerine.

| carta | costo | res | rend | scavo | per partita | ere intatto | ere in piedi | vita sfruttata | subito | a fine partita | sepolto | vetustà | PV | PV/costo | (L/R/V/S/Sk) |
|---|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|---|
| Grotte dipinte | 1P | 2 | 0 | 6 | 0.38 | 2.04 | 2.33 | 47% | 11% | 4% | 73% | 0.91 | **2.0** | 2.0 | 0.0/0.0/1.0/0.8/0.2 |
| Approdo | 1P | 1 | 0 | 2 | 0.30 | 1.00 | 1.31 | 26% | 69% | 0% | 74% | 0.00 | **2.7** | 2.7 | 0.0/0.0/1.0/1.6/0.1 |
| Cava | 1P | 1 | 0 | 2 | 0.90 | 1.07 | 1.47 | 29% | 57% | 0% | 80% | 0.07 | **2.7** | 2.7 | 0.0/0.0/1.0/1.5/0.3 |
| Mulino | 2P | 2 | 0 | 2 | 0.36 | 1.06 | 1.34 | 45% | 69% | 3% | 59% | 0.06 | **3.3** | 1.7 | 1.0/0.0/1.0/1.2/0.1 |
| Palafitte | 1P | 2 | 0 | 2 | 0.84 | 1.48 | 1.85 | 37% | 38% | 1% | 74% | 0.43 | **3.4** | 3.4 | 1.0/0.0/1.0/1.1/0.3 |
| Insulae | 2P | 2 | 0 | 2 | 0.55 | 1.29 | 1.83 | 46% | 23% | 2% | 75% | 0.28 | **3.6** | 1.8 | 1.0/0.0/1.0/1.1/0.4 |
| Mercato | 2P | 2 | 0 | 2 | 0.43 | 1.03 | 1.24 | 41% | 77% | 1% | 73% | 0.03 | **3.7** | 1.8 | 1.0/0.0/1.0/1.5/0.2 |
| Capanne | 1P | 1 | 0 | 2 | 0.82 | 1.05 | 1.46 | 29% | 58% | 0% | 82% | 0.06 | **3.7** | 3.7 | 1.0/0.0/1.0/1.5/0.2 |
| Banco | 1P+1O | 2 | 0 | 0 | 0.55 | 1.00 | 1.01 | 51% | 99% | 0% | 58% | 0.00 | **3.8** | 1.3 | 2.0/0.0/1.8/0.0/0.0 |
| Tumulo funerario | 2P | 3 | 0 | 5 | 0.46 | 1.97 | 1.97 | 39% | 4% | 0% | 100% | 0.97 | **4.1** | 2.0 | 1.0/0.0/2.0/0.0/1.0 |
| Sacello | 1P | 2 | 0 | 3 | 0.49 | 1.15 | 1.65 | 41% | 39% | 1% | 77% | 0.14 | **4.2** | 4.2 | 1.0/0.0/1.0/2.0/0.2 |
| Teatro | 2P | 3 | 0 | 5 | 0.74 | 1.91 | 2.23 | 56% | 2% | 9% | 78% | 0.82 | **4.4** | 2.2 | 2.0/0.0/1.0/0.9/0.4 |

### Le dodici più sepolte

Ordinate per quota di copie finite sotto un altro edificio.

| carta | costo | res | rend | scavo | per partita | ere intatto | ere in piedi | vita sfruttata | subito | a fine partita | sepolto | vetustà | PV | PV/costo | (L/R/V/S/Sk) |
|---|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|---|
| Villaggio palizzato | 2P | 2 | 0 | 2 | 0.09 | 1.68 | 2.00 | 40% | 0% | 0% | 100% | 0.68 | **5.3** | 2.7 | 1.0/0.0/2.0/0.8/1.4 |
| Tumulo funerario | 2P | 3 | 0 | 5 | 0.46 | 1.97 | 1.97 | 39% | 4% | 0% | 100% | 0.97 | **4.1** | 2.0 | 1.0/0.0/2.0/0.0/1.0 |
| Castrum | 3P | 4 | 0 | 3 | 0.04 | 2.09 | 2.09 | 52% | 1% | 5% | 94% | 1.09 | **4.0** | 1.3 | 1.0/0.0/2.0/0.0/1.0 |
| Emporio | 2P | 2 | 0 | 2 | 0.06 | 1.10 | 1.80 | 45% | 21% | 0% | 93% | 0.11 | **4.4** | 2.2 | 1.0/0.0/1.0/1.8/0.6 |
| Torre di vedetta | 2P | 3 | 0 | 2 | 0.01 | 1.75 | 2.07 | 52% | 1% | 2% | 92% | 0.76 | **2.9** | 1.4 | 1.0/0.0/1.0/0.6/0.3 |
| Arsenale | 3P+1O | 3 | 0 | 2 | 0.27 | 1.68 | 1.90 | 63% | 12% | 2% | 91% | 0.68 | **5.5** | 1.1 | 2.0/0.0/2.1/0.6/0.8 |
| Castello | 2P+1O | 4 | 3 | 3 | 0.75 | 2.09 | 2.14 | 71% | 2% | 8% | 88% | 1.09 | **8.4** | 2.1 | 0.0/4.9/2.4/0.2/0.9 |
| Capanne | 1P | 1 | 0 | 2 | 0.82 | 1.05 | 1.46 | 29% | 58% | 0% | 82% | 0.06 | **3.7** | 3.7 | 1.0/0.0/1.0/1.5/0.2 |
| Conceria | 1P | 1 | 0 | 0 | 0.06 | 1.00 | 1.03 | 34% | 97% | 0% | 81% | 0.00 | **2.1** | 2.1 | 1.0/0.0/1.0/0.0/0.0 |
| Focolare comune | 1P | 1 | 0 | 2 | 0.11 | 1.04 | 1.61 | 32% | 42% | 0% | 81% | 0.04 | **3.8** | 3.8 | 1.0/0.0/1.0/1.7/0.1 |
| Cava | 1P | 1 | 0 | 2 | 0.90 | 1.07 | 1.47 | 29% | 57% | 0% | 80% | 0.07 | **2.7** | 2.7 | 0.0/0.0/1.0/1.5/0.3 |
| Trappole da pesca | 1P | 1 | 0 | 0 | 0.01 | 1.00 | 1.48 | 30% | 52% | 0% | 79% | 0.00 | **1.4** | 1.4 | 0.0/0.0/1.0/0.2/0.2 |

## Tutte le carte, era per era

### Era 1

| carta | costo | res | rend | scavo | per partita | ere intatto | ere in piedi | vita sfruttata | subito | a fine partita | sepolto | vetustà | PV | PV/costo | (L/R/V/S/Sk) |
|---|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|---|
| Menhir | 2P | 4 | 1 | 3 | 0.95 | 3.50 | 3.70 | 74% | 15% | 51% | 39% | 1.86 | **11.0** | 5.5 | 0.0/9.5/1.0/0.0/0.5 |
| Dolmen | 2P | 3 | 1 | 3 | 0.95 | 3.36 | 3.59 | 72% | 14% | 44% | 40% | 1.68 | **9.8** | 4.9 | 0.0/8.5/0.9/0.0/0.4 |
| Circolo di pietre | 3P | 4 | 1 | 5 | 0.97 | 2.53 | 2.60 | 52% | 30% | 24% | 70% | 1.23 | **7.8** | 2.6 | 0.0/5.3/2.0/0.0/0.6 |
| Grotte dipinte | 1P | 2 | 0 | 6 | 0.38 | 2.04 | 2.33 | 47% | 11% | 4% | 73% | 0.91 | **2.0** | 2.0 | 0.0/0.0/1.0/0.8/0.2 |
| Villaggio palizzato | 2P | 2 | 0 | 2 | 0.09 | 1.68 | 2.00 | 40% | 0% | 0% | 100% | 0.68 | **5.3** | 2.7 | 1.0/0.0/2.0/0.8/1.4 |
| Tumulo funerario | 2P | 3 | 0 | 5 | 0.46 | 1.97 | 1.97 | 39% | 4% | 0% | 100% | 0.97 | **4.1** | 2.0 | 1.0/0.0/2.0/0.0/1.0 |
| Palafitte | 1P | 2 | 0 | 2 | 0.84 | 1.48 | 1.85 | 37% | 38% | 1% | 74% | 0.43 | **3.4** | 3.4 | 1.0/0.0/1.0/1.1/0.3 |
| Focolare comune | 1P | 1 | 0 | 2 | 0.11 | 1.04 | 1.61 | 32% | 42% | 0% | 81% | 0.04 | **3.8** | 3.8 | 1.0/0.0/1.0/1.7/0.1 |
| Trappole da pesca | 1P | 1 | 0 | 0 | 0.01 | 1.00 | 1.48 | 30% | 52% | 0% | 79% | 0.00 | **1.4** | 1.4 | 0.0/0.0/1.0/0.2/0.2 |
| Cava | 1P | 1 | 0 | 2 | 0.90 | 1.07 | 1.47 | 29% | 57% | 0% | 80% | 0.07 | **2.7** | 2.7 | 0.0/0.0/1.0/1.5/0.3 |
| Capanne | 1P | 1 | 0 | 2 | 0.82 | 1.05 | 1.46 | 29% | 58% | 0% | 82% | 0.06 | **3.7** | 3.7 | 1.0/0.0/1.0/1.5/0.2 |
| Approdo | 1P | 1 | 0 | 2 | 0.30 | 1.00 | 1.31 | 26% | 69% | 0% | 74% | 0.00 | **2.7** | 2.7 | 0.0/0.0/1.0/1.6/0.1 |

### Era 2

| carta | costo | res | rend | scavo | per partita | ere intatto | ere in piedi | vita sfruttata | subito | a fine partita | sepolto | vetustà | PV | PV/costo | (L/R/V/S/Sk) |
|---|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|---|
| Acquedotto | 3P | 4 | 1 | 3 | 0.69 | 2.57 | 2.65 | 66% | 13% | 33% | 48% | 1.49 | **8.7** | 2.9 | 0.0/5.3/2.9/0.0/0.5 |
| Anfiteatro | 5P | 5 | 2 | 6 | 0.86 | 2.53 | 2.54 | 64% | 5% | 22% | 60% | 1.50 | **10.0** | 2.0 | 0.0/6.5/3.0/0.0/0.5 |
| Ponte | 3P | 3 | 1 | 3 | 0.25 | 2.17 | 2.49 | 62% | 4% | 19% | 66% | 1.09 | **6.5** | 2.2 | 0.0/3.5/2.0/0.4/0.7 |
| Foro | 3P | 3 | 1 | 5 | 0.74 | 2.12 | 2.40 | 60% | 5% | 17% | 69% | 1.08 | **6.5** | 2.2 | 0.0/3.3/2.0/0.3/0.9 |
| Tempio | 3P | 3 | 1 | 3 | 0.56 | 1.93 | 2.38 | 60% | 5% | 15% | 72% | 0.88 | **5.0** | 1.7 | 0.0/2.7/0.9/0.8/0.5 |
| Teatro | 2P | 3 | 0 | 5 | 0.74 | 1.91 | 2.23 | 56% | 2% | 9% | 78% | 0.82 | **4.4** | 2.2 | 2.0/0.0/1.0/0.9/0.4 |
| Castrum | 3P | 4 | 0 | 3 | 0.04 | 2.09 | 2.09 | 52% | 1% | 5% | 94% | 1.09 | **4.0** | 1.3 | 1.0/0.0/2.0/0.0/1.0 |
| Torre di vedetta | 2P | 3 | 0 | 2 | 0.01 | 1.75 | 2.07 | 52% | 1% | 2% | 92% | 0.76 | **2.9** | 1.4 | 1.0/0.0/1.0/0.6/0.3 |
| Terme | 2P | 2 | 0 | 3 | 0.54 | 1.33 | 1.85 | 46% | 21% | 2% | 77% | 0.31 | **5.0** | 2.5 | 2.0/0.0/1.0/1.6/0.4 |
| Insulae | 2P | 2 | 0 | 2 | 0.55 | 1.29 | 1.83 | 46% | 23% | 2% | 75% | 0.28 | **3.6** | 1.8 | 1.0/0.0/1.0/1.1/0.4 |
| Emporio | 2P | 2 | 0 | 2 | 0.06 | 1.10 | 1.80 | 45% | 21% | 0% | 93% | 0.11 | **4.4** | 2.2 | 1.0/0.0/1.0/1.8/0.6 |
| Sacello | 1P | 2 | 0 | 3 | 0.49 | 1.15 | 1.65 | 41% | 39% | 1% | 77% | 0.14 | **4.2** | 4.2 | 1.0/0.0/1.0/2.0/0.2 |

### Era 3

| carta | costo | res | rend | scavo | per partita | ere intatto | ere in piedi | vita sfruttata | subito | a fine partita | sepolto | vetustà | PV | PV/costo | (L/R/V/S/Sk) |
|---|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|---|
| Mura | 2P | 4 | 0 | 2 | 0.14 | 2.14 | 2.35 | 78% | 5% | 33% | 64% | 1.07 | **2.8** | 1.4 | 1.0/0.0/1.3/0.2/0.2 |
| Abbazia | 2P+2O | 3 | 3 | 5 | 0.74 | 1.90 | 2.26 | 75% | 10% | 32% | 45% | 0.90 | **8.4** | 1.4 | 0.0/5.4/2.1/0.5/0.4 |
| Castello | 2P+1O | 4 | 3 | 3 | 0.75 | 2.09 | 2.14 | 71% | 2% | 8% | 88% | 1.09 | **8.4** | 2.1 | 0.0/4.9/2.4/0.2/0.9 |
| Chiesa | 2P+1O | 3 | 2 | 3 | 0.75 | 1.67 | 1.95 | 65% | 28% | 18% | 67% | 0.65 | **5.3** | 1.3 | 0.0/2.7/1.0/1.1/0.4 |
| Arsenale | 3P+1O | 3 | 0 | 2 | 0.27 | 1.68 | 1.90 | 63% | 12% | 2% | 91% | 0.68 | **5.5** | 1.1 | 2.0/0.0/2.1/0.6/0.8 |
| Torre civica | 2P | 3 | 0 | 2 | 0.77 | 1.24 | 1.78 | 59% | 31% | 7% | 75% | 0.24 | **4.6** | 2.3 | 2.0/0.0/1.1/1.2/0.3 |
| Mulino | 2P | 2 | 0 | 2 | 0.36 | 1.06 | 1.34 | 45% | 69% | 3% | 59% | 0.06 | **3.3** | 1.7 | 1.0/0.0/1.0/1.2/0.1 |
| Mercato | 2P | 2 | 0 | 2 | 0.43 | 1.03 | 1.24 | 41% | 77% | 1% | 73% | 0.03 | **3.7** | 1.8 | 1.0/0.0/1.0/1.5/0.2 |
| Cappella | 1P+1O | 2 | 0 | 3 | 0.86 | 1.02 | 1.20 | 40% | 80% | 0% | 77% | 0.02 | **5.4** | 1.8 | 2.0/0.0/1.0/2.3/0.1 |
| Borgo | 2P | 2 | 0 | 2 | 0.84 | 1.02 | 1.20 | 40% | 81% | 1% | 77% | 0.02 | **4.7** | 2.3 | 2.0/0.0/1.0/1.5/0.1 |
| Ospedale dei pellegrini | 2P+1O | 2 | 0 | 2 | 0.41 | 1.01 | 1.18 | 39% | 82% | 0% | 71% | 0.01 | **4.5** | 1.1 | 2.0/0.0/1.0/1.4/0.1 |
| Conceria | 1P | 1 | 0 | 0 | 0.06 | 1.00 | 1.03 | 34% | 97% | 0% | 81% | 0.00 | **2.1** | 2.1 | 1.0/0.0/1.0/0.0/0.0 |

### Era 4

| carta | costo | res | rend | scavo | per partita | ere intatto | ere in piedi | vita sfruttata | subito | a fine partita | sepolto | vetustà | PV | PV/costo | (L/R/V/S/Sk) |
|---|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|---|
| Ponte monumentale | 2P+2O | 4 | 3 | 3 | 0.51 | 1.73 | 1.96 | 98% | 4% | 54% | 36% | 0.73 | **8.3** | 1.4 | 0.0/4.8/3.0/0.2/0.2 |
| Fortezza bastionata | 3P+2O | 5 | 3 | 2 | 0.60 | 1.85 | 1.96 | 98% | 4% | 22% | 64% | 0.85 | **9.9** | 1.4 | 0.0/4.2/5.0/0.2/0.5 |
| Duomo | 3P+3O | 4 | 4 | 5 | 0.53 | 1.79 | 1.93 | 96% | 7% | 17% | 71% | 0.79 | **10.5** | 1.2 | 0.0/4.7/4.4/0.8/0.6 |
| Piazza monumentale | 2P+2O | 3 | 2 | 3 | 0.21 | 1.55 | 1.74 | 87% | 26% | 13% | 71% | 0.55 | **8.0** | 1.3 | 0.0/2.0/4.7/1.0/0.4 |
| Villa | 2P+2O | 3 | 0 | 3 | 0.75 | 1.02 | 1.34 | 67% | 66% | 16% | 58% | 0.02 | **7.3** | 1.2 | 4.0/0.0/1.6/1.7/0.1 |
| Palazzo signorile | 2P+2O | 3 | 0 | 3 | 0.68 | 1.01 | 1.14 | 57% | 86% | 6% | 62% | 0.01 | **6.4** | 1.1 | 3.0/0.0/1.5/1.9/0.0 |
| Loggia | 1P+1O | 2 | 0 | 2 | 0.66 | 1.00 | 1.02 | 51% | 98% | 1% | 57% | 0.00 | **4.8** | 1.6 | 2.0/0.0/1.6/1.2/0.0 |
| Banco | 1P+1O | 2 | 0 | 0 | 0.55 | 1.00 | 1.01 | 51% | 99% | 0% | 58% | 0.00 | **3.8** | 1.3 | 2.0/0.0/1.8/0.0/0.0 |
| Accademia | 1P+2O | 2 | 0 | 3 | 0.35 | 1.00 | 1.01 | 50% | 99% | 0% | 54% | 0.00 | **5.0** | 1.0 | 2.0/0.0/1.4/1.6/0.0 |
| Bottega d'artista | 1P+1O | 2 | 0 | 2 | 0.66 | 1.00 | 1.01 | 50% | 99% | 0% | 58% | 0.00 | **4.8** | 1.6 | 2.0/0.0/1.6/1.2/0.0 |
| Osservatorio | 1P+2O | 2 | 0 | 2 | 0.05 | 1.00 | 1.00 | 50% | 100% | 0% | 43% | 0.00 | **4.1** | 0.8 | 2.0/0.0/1.2/0.9/0.0 |
| Giardino all'italiana | 0P+2O | 1 | 0 | 0 | 0.39 | 1.00 | 1.00 | 50% | 100% | 0% | 38% | 0.00 | **4.4** | 1.1 | 3.0/0.0/1.4/0.0/0.0 |

### Era 5

| carta | costo | res | rend | scavo | per partita | ere intatto | ere in piedi | vita sfruttata | subito | a fine partita | sepolto | vetustà | PV | PV/costo | (L/R/V/S/Sk) |
|---|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|---|
| Fondazione d'arte | 1P+2O | 2 | 0 | 0 | 0.46 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **8.1** | 1.6 | 3.0/0.0/5.1/0.0/0.0 |
| Condominio | 1P+1O | 2 | 0 | 0 | 0.68 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **7.8** | 2.6 | 2.0/0.0/5.8/0.0/0.0 |
| Caffè letterario | 0P+2O | 1 | 0 | 0 | 0.10 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **6.6** | 1.7 | 2.0/0.0/4.6/0.0/0.0 |
| Officina | 1P+1O | 2 | 0 | 0 | 0.68 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **7.6** | 2.5 | 2.0/0.0/5.6/0.0/0.0 |
| Monumento ai caduti | 1P+2O | 3 | 0 | 0 | 0.18 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **7.8** | 1.6 | 2.0/0.0/5.8/0.0/0.0 |
| Museo | 1P+3O | 3 | 0 | 0 | 0.18 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **10.5** | 1.5 | 4.0/0.0/6.5/0.0/0.0 |
| Grattacielo | 2P+4O | 3 | 0 | 0 | 0.01 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **10.5** | 1.0 | 4.0/0.0/6.5/0.0/0.0 |
| Biblioteca | 1P+3O | 3 | 0 | 0 | 0.26 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **8.7** | 1.2 | 4.0/0.0/4.7/0.0/0.0 |
| Ponte in acciaio | 1P+3O | 4 | 0 | 0 | 0.38 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **16.2** | 2.3 | 4.0/0.0/12.2/0.0/0.0 |
| Stazione | 2P+4O | 4 | 0 | 0 | 0.26 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **27.2** | 2.7 | 4.0/0.0/23.2/0.0/0.0 |
| Parco archeologico | 1P+2O | 2 | 0 | 0 | 0.43 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **16.6** | 3.3 | 2.0/0.0/14.6/0.0/0.0 |
| Università | 2P+3O | 3 | 0 | 0 | 0.43 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **18.9** | 2.4 | 4.0/0.0/14.9/0.0/0.0 |

## Due correlazioni, su chi arriva in tavola almeno 50 volte

- **resistenza stampata** → ere in piedi: r = +0.49 · → PV: r = +0.50
- **costo in pietra** → ere in piedi: r = +0.61 · → PV: r = +0.16
- **Rendita stampata** → ere in piedi: r = +0.45 · → PV: r = +0.21
- **Scavo stampato** → ere in piedi: r = +0.67 · → PV: r = -0.24

---

Rifare il conto: `godot --headless res://scenes/audit_partita.tscn -- --players 3 --vita 2500 --seed 100000` (quattro processi, semi 100000 / 102500 / 105000 / 107500).

## Cosa cambia col Centro Urbano a due edifici

Le stesse misure su 10000 partite con la Prosperità Urbana che chiede **3 edifici intatti** nella colonna e 10000 con **2**, a parità di tutto il resto: stessi semi, stessi bot, stesso numero di giocatori. La colonna Δ è la seconda meno la prima.

| misura | Centro a 3 edifici | Centro a 2 edifici | Δ |
|---|--:|--:|--:|
| edifici costruiti per partita | 26.30 | 28.68 | +2.38 |
| ere intatto (media) | 1.64 | 1.58 | −0.06 |
| ere in piedi (media) | 1.87 | 1.78 | −0.09 |
| cade nella sua era | 34% | 34% | −1% |
| in piedi a fine partita | 25% | 25% | +1% |
| sepolto | 54% | 57% | +3% |
| vetustà media | 0.57 | 0.52 | −0.05 |
| potenziamenti per edificio | 0.04 | 0.05 | +0.01 |
| PV per edificio | 6.7 | 6.9 | +0.2 |
| PV per partita (i tre giocatori insieme) | 177 | 198 | +21 |

| canale (PV per partita, tutti i giocatori) | Centro a 3 edifici | Centro a 2 edifici | Δ |
|---|--:|--:|--:|
| Lampo | 29.2 | 35.7 | +6.5 |
| Rendita | 55.0 | 54.0 | −1.0 |
| Verticalita | 66.9 | 78.1 | +11.2 |
| Scavo | 18.5 | 21.6 | +3.1 |
| Scheletri | 7.0 | 8.5 | +1.6 |

### Le carte che si cercano di più

Copie costruite per partita, prima e dopo.

| carta | era | costo | Centro a 3 edifici | Centro a 2 edifici | Δ | PV Centro a 3 edifici | PV Centro a 2 edifici |
|---|--:|--:|--:|--:|--:|--:|--:|
| Palazzo signorile | 4 | 2P+2O | 0.42 | 0.68 | +0.25 | 6.8 | 6.4 |
| Villa | 4 | 2P+2O | 0.51 | 0.75 | +0.24 | 7.7 | 7.3 |
| Giardino all'italiana | 4 | 0P+2O | 0.18 | 0.39 | +0.21 | 5.0 | 4.4 |
| Ponte in acciaio | 5 | 1P+3O | 0.19 | 0.38 | +0.19 | 16.9 | 16.2 |
| Fondazione d'arte | 5 | 1P+2O | 0.27 | 0.46 | +0.19 | 8.6 | 8.1 |
| Duomo | 4 | 3P+3O | 0.34 | 0.53 | +0.19 | 12.9 | 10.5 |
| Ponte monumentale | 4 | 2P+2O | 0.33 | 0.51 | +0.18 | 9.3 | 8.3 |
| Università | 5 | 2P+3O | 0.25 | 0.43 | +0.18 | 18.7 | 18.9 |
| Accademia | 4 | 1P+2O | 0.19 | 0.35 | +0.17 | 5.5 | 5.0 |
| Abbazia | 3 | 2P+2O | 0.58 | 0.74 | +0.16 | 8.9 | 8.4 |

### E quelle che si cercano di meno

Le stesse carte, dall'altro capo della classifica.

| carta | era | costo | Centro a 3 edifici | Centro a 2 edifici | Δ | PV Centro a 3 edifici | PV Centro a 2 edifici |
|---|--:|--:|--:|--:|--:|--:|--:|
| Mulino | 3 | 2P | 0.60 | 0.36 | −0.25 | 2.9 | 3.3 |
| Mura | 3 | 2P | 0.30 | 0.14 | −0.15 | 2.8 | 2.8 |
| Torre civica | 3 | 2P | 0.84 | 0.77 | −0.08 | 4.4 | 4.6 |
| Mercato | 3 | 2P | 0.50 | 0.43 | −0.07 | 3.4 | 3.7 |
| Borgo | 3 | 2P | 0.91 | 0.84 | −0.07 | 4.5 | 4.7 |
| Banco | 4 | 1P+1O | 0.60 | 0.55 | −0.05 | 4.5 | 3.8 |
| Conceria | 3 | 1P | 0.08 | 0.06 | −0.02 | 2.1 | 2.1 |
| Sacello | 2 | 1P | 0.51 | 0.49 | −0.02 | 4.0 | 4.2 |
| Insulae | 2 | 2P | 0.56 | 0.55 | −0.02 | 3.5 | 3.6 |
| Terme | 2 | 2P | 0.56 | 0.54 | −0.01 | 4.9 | 5.0 |

### Carte che non arrivano quasi mai in tavola

- **Grattacielo** (era 5, 2P+4O) — una ogni 189 partite, contro una ogni 417 prima
- **Torre di vedetta** (era 2, 2P) — una ogni 114 partite, contro una ogni 105 prima
- **Trappole da pesca** (era 1, 1P) — una ogni 81 partite, contro una ogni 81 prima

