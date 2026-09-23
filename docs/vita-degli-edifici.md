# La vita degli edifici

Misurata su **10 000 partite** a 3 giocatori, rigiocate dal motore vero (`scripts/tools/audit_partita.gd`, modalità `--vita`). In tutto 301 156 edifici costruiti.

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
| era 1 | 12 | 7.5 | 2.36 | 2.86 | 14% | 27% | 53% | 6.8 |
| era 2 | 12 | 5.9 | 2.05 | 2.48 | 4% | 20% | 59% | 6.4 |
| era 3 | 12 | 6.1 | 1.41 | 1.94 | 18% | 9% | 74% | 5.5 |
| era 4 | 12 | 6.1 | 1.24 | 1.58 | 42% | 18% | 61% | 6.0 |
| era 5 | 12 | 4.4 | 1.00 | 1.00 | 0% | 100% | 0% | 11.5 |

In media una partita mette in tavola **30.1 edifici**; di questi **31%** è ancora in piedi alla fine, **52%** finisce sotterrato e **16%** non supera l'era in cui è nato.

## Cosa salta all'occhio

**1. La Rendita è il canale che paga la durata, ed è quasi tutto.** Le 15 carte con Rendita stampata fruttano in media **8.9 PV** contro i **5.9** delle altre, e restano in piedi 2.83 ere contro 1.63. Non è una sorpresa — la Rendita si incassa a ogni censimento — ma dice che il valore di una carta lo decide quasi tutto un numero solo.

**2. La resistenza fa esattamente il suo mestiere.** Sulle ere 1-4, per ogni punto di resistenza:

| resistenza | carte | ere in piedi | cade nella sua era | PV medi |
|---|--:|--:|--:|--:|
| 1 | 7 | 1.60 | 43% | 3.3 |
| 2 | 17 | 1.74 | 36% | 4.2 |
| 3 | 14 | 2.47 | 8% | 6.3 |
| 4 | 8 | 3.00 | 3% | 9.9 |
| 5 | 2 | 2.43 | 2% | 10.0 |

Fra resistenza 1 e resistenza 4 la vita raddoppia e i punti quasi triplicano. Il salto vero è **fra 2 e 3**: è lì che un edificio smette di essere materiale da riempimento.

**3. Le carte da una pietra dell'era 1 non sono edifici: sono Scavo da seminare.** Approdo, Capanne, Cava, Focolare comune, Grotte dipinte, Palafitte, Trappole da pesca vivono 2.0 ere, finiscono sotto nel **67%** dei casi e 37 punti su cento di quello che fruttano sono Scavo. Funzionano — ma solo se chi le gioca sa che le sta seminando, non costruendo.

**4. Un edificio dell'era 5 non può morire.** Gli eventi sono solo nelle ere 1-4: chi costruisce nell'era Moderna non vedrà mai un censimento né un evento. Si vede nei numeri: vetustà **0.00**, Rendita **0.00**, Scavo **0.00**, e il **100%** ancora in piedi. Le carte dell'era 5 pagano solo Lampo e Verticalità, e vanno lette con un metro diverso dalle altre: il loro valore è tutto nell'istante in cui le metti.

**5. I colossali prendono la cima di tre colonne.** Un edificio da tre caselle conta come strato in tutte le colonne che tocca — quindi incassa il premio della cima **tre volte**:

| larghezza | carte | costruiti | PV medi | di cui Verticalità |
|---|--:|--:|--:|--:|
| 1 casella | 41 | 198 403 | 5.5 | 1.6 |
| 2 caselle | 16 | 81 889 | 9.3 | 4.1 |
| 3 caselle | 3 | 20 864 | 12.6 | 5.9 |

Il caso limite è la **Stazione** (era 5, tre caselle, 2P+4O): **26.0 PV medi**, di cui 22.0 di sola Verticalità — contro i 17.8 della seconda della lista, Università. Arriva in tavola una volta ogni 3 partite, quindi non rompe la media, ma quando arriva decide la colonna. Vale la pena chiedersi se il premio della cima debba contare una volta per edificio invece che una volta per colonna.

## Gli estremi

### Le dodici vite più brevi

Ordinate per **vita sfruttata**, non per ere secche: se no in testa finirebbero le carte dell'era 5, che vivono una sola era perché la partita finisce, non perché crollano.

| carta | costo | res | rend | scavo | per partita | ere intatto | ere in piedi | vita sfruttata | subito | a fine partita | sepolto | vetustà | PV | PV/costo | (L/R/V/S/Sk) |
|---|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|---|
| Capanne | 1P | 1 | 0 | 2 | 0.96 | 1.06 | 1.66 | 33% | 38% | 0% | 72% | 0.05 | **3.8** | 3.8 | 1.0/0.0/1.2/1.3/0.3 |
| Cava | 1P | 1 | 0 | 2 | 1.00 | 1.06 | 1.74 | 35% | 29% | 0% | 70% | 0.06 | **2.8** | 2.8 | 0.0/0.0/1.2/1.3/0.4 |
| Approdo | 1P | 1 | 0 | 2 | 0.30 | 1.00 | 1.83 | 37% | 18% | 0% | 61% | 0.00 | **2.7** | 2.7 | 0.0/0.0/1.2/1.4/0.1 |
| Trappole da pesca | 1P | 1 | 0 | 0 | 0.01 | 1.00 | 1.85 | 37% | 17% | 0% | 0% | 0.00 | **1.0** | 1.0 | 0.0/0.0/1.0/0.0/0.0 |
| Villaggio palizzato | 2P | 2 | 0 | 2 | 0.17 | 1.72 | 2.05 | 41% | 0% | 1% | 97% | 0.71 | **5.4** | 2.7 | 1.0/0.0/2.6/0.8/1.1 |
| Focolare comune | 1P | 1 | 0 | 2 | 0.02 | 1.23 | 2.06 | 41% | 10% | 1% | 45% | 0.23 | **3.0** | 3.0 | 1.0/0.0/1.1/0.9/0.0 |
| Conceria | 1P | 1 | 0 | 0 | 0.04 | 1.00 | 1.26 | 42% | 74% | 0% | 91% | 0.00 | **2.3** | 2.3 | 1.0/0.0/1.0/0.1/0.1 |
| Palafitte | 1P | 2 | 0 | 2 | 0.94 | 1.47 | 2.18 | 44% | 7% | 2% | 71% | 0.42 | **3.6** | 3.6 | 1.0/0.0/1.3/1.0/0.3 |
| Sacello | 1P | 2 | 0 | 3 | 0.46 | 1.17 | 1.97 | 49% | 12% | 2% | 69% | 0.15 | **3.9** | 3.9 | 1.0/0.0/1.0/1.8/0.1 |
| Emporio | 2P | 2 | 0 | 2 | 0.04 | 1.27 | 2.00 | 50% | 1% | 0% | 98% | 0.27 | **4.2** | 2.1 | 1.0/0.0/1.3/1.5/0.4 |
| Torre di vedetta | 2P | 3 | 0 | 2 | 0.00 | 1.66 | 2.03 | 51% | 0% | 0% | 100% | 0.66 | **3.2** | 1.6 | 1.0/0.0/1.2/0.7/0.2 |
| Giardino all'italiana | 0P+2O | 1 | 0 | 0 | 0.46 | 1.00 | 1.02 | 51% | 98% | 1% | 43% | 0.00 | **3.9** | 1.0 | 3.0/0.0/0.9/0.0/0.0 |

### Le dodici che arrivano in fondo

Ordinate per vita sfruttata.

| carta | costo | res | rend | scavo | per partita | ere intatto | ere in piedi | vita sfruttata | subito | a fine partita | sepolto | vetustà | PV | PV/costo | (L/R/V/S/Sk) |
|---|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|---|
| Fortezza bastionata | 3P+2O | 5 | 3 | 2 | 0.63 | 1.84 | 2.00 | 100% | 0% | 15% | 74% | 0.84 | **8.5** | 1.2 | 0.0/4.0/3.7/0.3/0.5 |
| Fondazione d'arte | 1P+2O | 2 | 0 | 0 | 0.52 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **7.5** | 1.5 | 3.0/0.0/4.5/0.0/0.0 |
| Condominio | 1P+1O | 2 | 0 | 0 | 0.70 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **7.1** | 2.4 | 2.0/0.0/5.1/0.0/0.0 |
| Caffè letterario | 0P+2O | 1 | 0 | 0 | 0.11 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **6.2** | 1.6 | 2.0/0.0/4.2/0.0/0.0 |
| Officina | 1P+1O | 2 | 0 | 0 | 0.68 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **7.0** | 2.3 | 2.0/0.0/5.0/0.0/0.0 |
| Monumento ai caduti | 1P+2O | 3 | 0 | 0 | 0.18 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **7.4** | 1.5 | 2.0/0.0/5.4/0.0/0.0 |
| Museo | 1P+3O | 3 | 0 | 0 | 0.23 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **9.8** | 1.4 | 4.0/0.0/5.8/0.0/0.0 |
| Grattacielo | 2P+4O | 3 | 0 | 0 | 0.01 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **10.3** | 1.0 | 4.0/0.0/6.3/0.0/0.0 |
| Biblioteca | 1P+3O | 3 | 0 | 0 | 0.32 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **8.0** | 1.1 | 4.0/0.0/4.0/0.0/0.0 |
| Ponte in acciaio | 1P+3O | 4 | 0 | 0 | 0.42 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **14.8** | 2.1 | 4.0/0.0/10.8/0.0/0.0 |
| Stazione | 2P+4O | 4 | 0 | 0 | 0.31 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **26.0** | 2.6 | 4.0/0.0/22.0/0.0/0.0 |
| Parco archeologico | 1P+2O | 2 | 0 | 0 | 0.48 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **15.7** | 3.1 | 2.0/0.0/13.7/0.0/0.0 |

### Le dodici che rendono di più

Ordinate per PV medi fruttati al proprietario.

| carta | costo | res | rend | scavo | per partita | ere intatto | ere in piedi | vita sfruttata | subito | a fine partita | sepolto | vetustà | PV | PV/costo | (L/R/V/S/Sk) |
|---|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|---|
| Stazione | 2P+4O | 4 | 0 | 0 | 0.31 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **26.0** | 2.6 | 4.0/0.0/22.0/0.0/0.0 |
| Università | 2P+3O | 3 | 0 | 0 | 0.50 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **17.8** | 2.2 | 4.0/0.0/13.8/0.0/0.0 |
| Parco archeologico | 1P+2O | 2 | 0 | 0 | 0.48 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **15.7** | 3.1 | 2.0/0.0/13.7/0.0/0.0 |
| Ponte in acciaio | 1P+3O | 4 | 0 | 0 | 0.42 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **14.8** | 2.1 | 4.0/0.0/10.8/0.0/0.0 |
| Circolo di pietre | 3P | 4 | 1 | 5 | 1.00 | 3.72 | 3.93 | 79% | 3% | 63% | 33% | 1.84 | **12.9** | 4.3 | 0.0/10.4/2.1/0.0/0.4 |
| Menhir | 2P | 4 | 1 | 3 | 1.00 | 3.69 | 4.03 | 81% | 6% | 61% | 34% | 1.80 | **11.8** | 5.9 | 0.0/10.1/1.1/0.1/0.5 |
| Anfiteatro | 5P | 5 | 2 | 6 | 0.93 | 2.69 | 2.72 | 68% | 3% | 29% | 54% | 1.65 | **11.1** | 2.2 | 0.0/7.5/3.1/0.0/0.5 |
| Dolmen | 2P | 3 | 1 | 3 | 1.00 | 3.62 | 4.10 | 82% | 8% | 63% | 24% | 1.61 | **11.1** | 5.5 | 0.0/9.7/1.0/0.0/0.3 |
| Grattacielo | 2P+4O | 3 | 0 | 0 | 0.01 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **10.3** | 1.0 | 4.0/0.0/6.3/0.0/0.0 |
| Museo | 1P+3O | 3 | 0 | 0 | 0.23 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **9.8** | 1.4 | 4.0/0.0/5.8/0.0/0.0 |
| Acquedotto | 3P | 4 | 1 | 3 | 0.85 | 2.74 | 2.86 | 72% | 8% | 39% | 39% | 1.60 | **9.3** | 3.1 | 0.0/5.9/3.0/0.0/0.3 |
| Duomo | 3P+3O | 4 | 4 | 5 | 0.57 | 1.79 | 2.00 | 100% | 0% | 14% | 77% | 0.79 | **9.1** | 1.0 | 0.0/4.6/3.1/0.9/0.5 |

### Le dodici che rendono di più per quello che costano

Ordinate per PV diviso il costo in pietra equivalente.

| carta | costo | res | rend | scavo | per partita | ere intatto | ere in piedi | vita sfruttata | subito | a fine partita | sepolto | vetustà | PV | PV/costo | (L/R/V/S/Sk) |
|---|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|---|
| Menhir | 2P | 4 | 1 | 3 | 1.00 | 3.69 | 4.03 | 81% | 6% | 61% | 34% | 1.80 | **11.8** | 5.9 | 0.0/10.1/1.1/0.1/0.5 |
| Dolmen | 2P | 3 | 1 | 3 | 1.00 | 3.62 | 4.10 | 82% | 8% | 63% | 24% | 1.61 | **11.1** | 5.5 | 0.0/9.7/1.0/0.0/0.3 |
| Circolo di pietre | 3P | 4 | 1 | 5 | 1.00 | 3.72 | 3.93 | 79% | 3% | 63% | 33% | 1.84 | **12.9** | 4.3 | 0.0/10.4/2.1/0.0/0.4 |
| Sacello | 1P | 2 | 0 | 3 | 0.46 | 1.17 | 1.97 | 49% | 12% | 2% | 69% | 0.15 | **3.9** | 3.9 | 1.0/0.0/1.0/1.8/0.1 |
| Capanne | 1P | 1 | 0 | 2 | 0.96 | 1.06 | 1.66 | 33% | 38% | 0% | 72% | 0.05 | **3.8** | 3.8 | 1.0/0.0/1.2/1.3/0.3 |
| Palafitte | 1P | 2 | 0 | 2 | 0.94 | 1.47 | 2.18 | 44% | 7% | 2% | 71% | 0.42 | **3.6** | 3.6 | 1.0/0.0/1.3/1.0/0.3 |
| Parco archeologico | 1P+2O | 2 | 0 | 0 | 0.48 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **15.7** | 3.1 | 2.0/0.0/13.7/0.0/0.0 |
| Acquedotto | 3P | 4 | 1 | 3 | 0.85 | 2.74 | 2.86 | 72% | 8% | 39% | 39% | 1.60 | **9.3** | 3.1 | 0.0/5.9/3.0/0.0/0.3 |
| Cava | 1P | 1 | 0 | 2 | 1.00 | 1.06 | 1.74 | 35% | 29% | 0% | 70% | 0.06 | **2.8** | 2.8 | 0.0/0.0/1.2/1.3/0.4 |
| Approdo | 1P | 1 | 0 | 2 | 0.30 | 1.00 | 1.83 | 37% | 18% | 0% | 61% | 0.00 | **2.7** | 2.7 | 0.0/0.0/1.2/1.4/0.1 |
| Stazione | 2P+4O | 4 | 0 | 0 | 0.31 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **26.0** | 2.6 | 4.0/0.0/22.0/0.0/0.0 |
| Borgo | 2P | 2 | 0 | 2 | 0.80 | 1.01 | 1.70 | 57% | 32% | 2% | 78% | 0.02 | **4.8** | 2.4 | 2.0/0.0/1.0/1.6/0.3 |

### Le dodici che rendono di meno

Solo carte che arrivano in tavola almeno una volta ogni cinque partite: una carta rara ha medie ballerine.

| carta | costo | res | rend | scavo | per partita | ere intatto | ere in piedi | vita sfruttata | subito | a fine partita | sepolto | vetustà | PV | PV/costo | (L/R/V/S/Sk) |
|---|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|---|
| Grotte dipinte | 1P | 2 | 0 | 6 | 0.45 | 2.17 | 2.82 | 56% | 11% | 12% | 46% | 0.82 | **1.9** | 1.9 | 0.0/0.0/1.1/0.7/0.1 |
| Approdo | 1P | 1 | 0 | 2 | 0.30 | 1.00 | 1.83 | 37% | 18% | 0% | 61% | 0.00 | **2.7** | 2.7 | 0.0/0.0/1.2/1.4/0.1 |
| Cava | 1P | 1 | 0 | 2 | 1.00 | 1.06 | 1.74 | 35% | 29% | 0% | 70% | 0.06 | **2.8** | 2.8 | 0.0/0.0/1.2/1.3/0.4 |
| Banco | 1P+1O | 2 | 0 | 0 | 0.52 | 1.00 | 1.25 | 63% | 75% | 8% | 62% | 0.00 | **3.3** | 1.1 | 2.0/0.0/1.2/0.0/0.1 |
| Mulino | 2P | 2 | 0 | 2 | 0.30 | 1.06 | 1.87 | 62% | 19% | 6% | 63% | 0.05 | **3.5** | 1.8 | 1.0/0.0/1.0/1.2/0.3 |
| Palafitte | 1P | 2 | 0 | 2 | 0.94 | 1.47 | 2.18 | 44% | 7% | 2% | 71% | 0.42 | **3.6** | 3.6 | 1.0/0.0/1.3/1.0/0.3 |
| Insulae | 2P | 2 | 0 | 2 | 0.49 | 1.33 | 2.05 | 51% | 1% | 1% | 76% | 0.32 | **3.6** | 1.8 | 1.0/0.0/1.1/1.1/0.4 |
| Capanne | 1P | 1 | 0 | 2 | 0.96 | 1.06 | 1.66 | 33% | 38% | 0% | 72% | 0.05 | **3.8** | 3.8 | 1.0/0.0/1.2/1.3/0.3 |
| Tumulo funerario | 2P | 3 | 0 | 5 | 0.69 | 2.40 | 2.70 | 54% | 4% | 17% | 65% | 1.05 | **3.9** | 1.9 | 1.0/0.0/2.2/0.0/0.7 |
| Giardino all'italiana | 0P+2O | 1 | 0 | 0 | 0.46 | 1.00 | 1.02 | 51% | 98% | 1% | 43% | 0.00 | **3.9** | 1.0 | 3.0/0.0/0.9/0.0/0.0 |
| Sacello | 1P | 2 | 0 | 3 | 0.46 | 1.17 | 1.97 | 49% | 12% | 2% | 69% | 0.15 | **3.9** | 3.9 | 1.0/0.0/1.0/1.8/0.1 |
| Mercato | 2P | 2 | 0 | 2 | 0.36 | 1.04 | 1.69 | 56% | 33% | 1% | 81% | 0.03 | **4.0** | 2.0 | 1.0/0.0/1.0/1.6/0.4 |

### Le dodici più sepolte

Ordinate per quota di copie finite sotto un altro edificio.

| carta | costo | res | rend | scavo | per partita | ere intatto | ere in piedi | vita sfruttata | subito | a fine partita | sepolto | vetustà | PV | PV/costo | (L/R/V/S/Sk) |
|---|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|---|
| Torre di vedetta | 2P | 3 | 0 | 2 | 0.00 | 1.66 | 2.03 | 51% | 0% | 0% | 100% | 0.66 | **3.2** | 1.6 | 1.0/0.0/1.2/0.7/0.2 |
| Emporio | 2P | 2 | 0 | 2 | 0.04 | 1.27 | 2.00 | 50% | 1% | 0% | 98% | 0.27 | **4.2** | 2.1 | 1.0/0.0/1.3/1.5/0.4 |
| Villaggio palizzato | 2P | 2 | 0 | 2 | 0.17 | 1.72 | 2.05 | 41% | 0% | 1% | 97% | 0.71 | **5.4** | 2.7 | 1.0/0.0/2.6/0.8/1.1 |
| Castrum | 3P | 4 | 0 | 3 | 0.04 | 2.09 | 2.09 | 52% | 2% | 5% | 95% | 1.10 | **4.2** | 1.4 | 1.0/0.0/2.3/0.0/0.9 |
| Arsenale | 3P+1O | 3 | 0 | 2 | 0.26 | 1.61 | 1.96 | 65% | 5% | 1% | 94% | 0.61 | **5.5** | 1.1 | 2.0/0.0/2.1/0.7/0.7 |
| Castello | 2P+1O | 4 | 3 | 3 | 0.76 | 2.05 | 2.13 | 71% | 0% | 6% | 92% | 1.05 | **7.7** | 1.9 | 0.0/4.7/2.1/0.2/0.7 |
| Conceria | 1P | 1 | 0 | 0 | 0.04 | 1.00 | 1.26 | 42% | 74% | 0% | 91% | 0.00 | **2.3** | 2.3 | 1.0/0.0/1.0/0.1/0.1 |
| Mercato | 2P | 2 | 0 | 2 | 0.36 | 1.04 | 1.69 | 56% | 33% | 1% | 81% | 0.03 | **4.0** | 2.0 | 1.0/0.0/1.0/1.6/0.4 |
| Torre civica | 2P | 3 | 0 | 2 | 0.72 | 1.22 | 2.02 | 67% | 7% | 8% | 78% | 0.21 | **4.6** | 2.3 | 2.0/0.0/1.0/1.3/0.3 |
| Borgo | 2P | 2 | 0 | 2 | 0.80 | 1.01 | 1.70 | 57% | 32% | 2% | 78% | 0.02 | **4.8** | 2.4 | 2.0/0.0/1.0/1.6/0.3 |
| Duomo | 3P+3O | 4 | 4 | 5 | 0.57 | 1.79 | 2.00 | 100% | 0% | 14% | 77% | 0.79 | **9.1** | 1.0 | 0.0/4.6/3.1/0.9/0.5 |
| Piazza monumentale | 2P+2O | 3 | 2 | 3 | 0.20 | 1.57 | 1.93 | 96% | 7% | 11% | 77% | 0.57 | **7.1** | 1.2 | 0.0/2.0/3.7/1.1/0.4 |

## Tutte le carte, era per era

### Era 1

| carta | costo | res | rend | scavo | per partita | ere intatto | ere in piedi | vita sfruttata | subito | a fine partita | sepolto | vetustà | PV | PV/costo | (L/R/V/S/Sk) |
|---|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|---|
| Dolmen | 2P | 3 | 1 | 3 | 1.00 | 3.62 | 4.10 | 82% | 8% | 63% | 24% | 1.61 | **11.1** | 5.5 | 0.0/9.7/1.0/0.0/0.3 |
| Menhir | 2P | 4 | 1 | 3 | 1.00 | 3.69 | 4.03 | 81% | 6% | 61% | 34% | 1.80 | **11.8** | 5.9 | 0.0/10.1/1.1/0.1/0.5 |
| Circolo di pietre | 3P | 4 | 1 | 5 | 1.00 | 3.72 | 3.93 | 79% | 3% | 63% | 33% | 1.84 | **12.9** | 4.3 | 0.0/10.4/2.1/0.0/0.4 |
| Grotte dipinte | 1P | 2 | 0 | 6 | 0.45 | 2.17 | 2.82 | 56% | 11% | 12% | 46% | 0.82 | **1.9** | 1.9 | 0.0/0.0/1.1/0.7/0.1 |
| Tumulo funerario | 2P | 3 | 0 | 5 | 0.69 | 2.40 | 2.70 | 54% | 4% | 17% | 65% | 1.05 | **3.9** | 1.9 | 1.0/0.0/2.2/0.0/0.7 |
| Palafitte | 1P | 2 | 0 | 2 | 0.94 | 1.47 | 2.18 | 44% | 7% | 2% | 71% | 0.42 | **3.6** | 3.6 | 1.0/0.0/1.3/1.0/0.3 |
| Focolare comune | 1P | 1 | 0 | 2 | 0.02 | 1.23 | 2.06 | 41% | 10% | 1% | 45% | 0.23 | **3.0** | 3.0 | 1.0/0.0/1.1/0.9/0.0 |
| Villaggio palizzato | 2P | 2 | 0 | 2 | 0.17 | 1.72 | 2.05 | 41% | 0% | 1% | 97% | 0.71 | **5.4** | 2.7 | 1.0/0.0/2.6/0.8/1.1 |
| Trappole da pesca | 1P | 1 | 0 | 0 | 0.01 | 1.00 | 1.85 | 37% | 17% | 0% | 0% | 0.00 | **1.0** | 1.0 | 0.0/0.0/1.0/0.0/0.0 |
| Approdo | 1P | 1 | 0 | 2 | 0.30 | 1.00 | 1.83 | 37% | 18% | 0% | 61% | 0.00 | **2.7** | 2.7 | 0.0/0.0/1.2/1.4/0.1 |
| Cava | 1P | 1 | 0 | 2 | 1.00 | 1.06 | 1.74 | 35% | 29% | 0% | 70% | 0.06 | **2.8** | 2.8 | 0.0/0.0/1.2/1.3/0.4 |
| Capanne | 1P | 1 | 0 | 2 | 0.96 | 1.06 | 1.66 | 33% | 38% | 0% | 72% | 0.05 | **3.8** | 3.8 | 1.0/0.0/1.2/1.3/0.3 |

### Era 2

| carta | costo | res | rend | scavo | per partita | ere intatto | ere in piedi | vita sfruttata | subito | a fine partita | sepolto | vetustà | PV | PV/costo | (L/R/V/S/Sk) |
|---|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|---|
| Ponte | 3P | 3 | 1 | 3 | 0.36 | 2.28 | 2.87 | 72% | 1% | 33% | 39% | 1.08 | **6.5** | 2.2 | 0.0/4.1/1.9/0.2/0.3 |
| Acquedotto | 3P | 4 | 1 | 3 | 0.85 | 2.74 | 2.86 | 72% | 8% | 39% | 39% | 1.60 | **9.3** | 3.1 | 0.0/5.9/3.0/0.0/0.3 |
| Anfiteatro | 5P | 5 | 2 | 6 | 0.93 | 2.69 | 2.72 | 68% | 3% | 29% | 54% | 1.65 | **11.1** | 2.2 | 0.0/7.5/3.1/0.0/0.5 |
| Foro | 3P | 3 | 1 | 5 | 0.86 | 2.18 | 2.59 | 65% | 3% | 25% | 59% | 1.04 | **6.5** | 2.2 | 0.0/3.6/2.0/0.3/0.6 |
| Tempio | 3P | 3 | 1 | 3 | 0.65 | 1.91 | 2.52 | 63% | 3% | 19% | 60% | 0.80 | **4.4** | 1.5 | 0.0/2.6/0.9/0.7/0.3 |
| Teatro | 2P | 3 | 0 | 5 | 0.75 | 1.85 | 2.35 | 59% | 2% | 12% | 69% | 0.72 | **4.1** | 2.1 | 2.0/0.0/1.1/0.9/0.2 |
| Castrum | 3P | 4 | 0 | 3 | 0.04 | 2.09 | 2.09 | 52% | 2% | 5% | 95% | 1.10 | **4.2** | 1.4 | 1.0/0.0/2.3/0.0/0.9 |
| Terme | 2P | 2 | 0 | 3 | 0.52 | 1.36 | 2.07 | 52% | 1% | 2% | 68% | 0.34 | **4.6** | 2.3 | 2.0/0.0/1.1/1.3/0.3 |
| Insulae | 2P | 2 | 0 | 2 | 0.49 | 1.33 | 2.05 | 51% | 1% | 1% | 76% | 0.32 | **3.6** | 1.8 | 1.0/0.0/1.1/1.1/0.4 |
| Torre di vedetta | 2P | 3 | 0 | 2 | 0.00 | 1.66 | 2.03 | 51% | 0% | 0% | 100% | 0.66 | **3.2** | 1.6 | 1.0/0.0/1.2/0.7/0.2 |
| Emporio | 2P | 2 | 0 | 2 | 0.04 | 1.27 | 2.00 | 50% | 1% | 0% | 98% | 0.27 | **4.2** | 2.1 | 1.0/0.0/1.3/1.5/0.4 |
| Sacello | 1P | 2 | 0 | 3 | 0.46 | 1.17 | 1.97 | 49% | 12% | 2% | 69% | 0.15 | **3.9** | 3.9 | 1.0/0.0/1.0/1.8/0.1 |

### Era 3

| carta | costo | res | rend | scavo | per partita | ere intatto | ere in piedi | vita sfruttata | subito | a fine partita | sepolto | vetustà | PV | PV/costo | (L/R/V/S/Sk) |
|---|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|---|
| Mura | 2P | 4 | 0 | 2 | 0.09 | 2.05 | 2.35 | 78% | 0% | 28% | 70% | 0.98 | **2.8** | 1.4 | 1.0/0.0/1.2/0.4/0.2 |
| Abbazia | 2P+2O | 3 | 3 | 5 | 0.77 | 1.89 | 2.35 | 78% | 3% | 32% | 49% | 0.87 | **8.1** | 1.3 | 0.0/5.3/1.9/0.7/0.3 |
| Castello | 2P+1O | 4 | 3 | 3 | 0.76 | 2.05 | 2.13 | 71% | 0% | 6% | 92% | 1.05 | **7.7** | 1.9 | 0.0/4.7/2.1/0.2/0.7 |
| Chiesa | 2P+1O | 3 | 2 | 3 | 0.75 | 1.67 | 2.09 | 70% | 17% | 20% | 62% | 0.64 | **5.0** | 1.2 | 0.0/2.8/0.9/1.1/0.3 |
| Torre civica | 2P | 3 | 0 | 2 | 0.72 | 1.22 | 2.02 | 67% | 7% | 8% | 78% | 0.21 | **4.6** | 2.3 | 2.0/0.0/1.0/1.3/0.3 |
| Arsenale | 3P+1O | 3 | 0 | 2 | 0.26 | 1.61 | 1.96 | 65% | 5% | 1% | 94% | 0.61 | **5.5** | 1.1 | 2.0/0.0/2.1/0.7/0.7 |
| Mulino | 2P | 2 | 0 | 2 | 0.30 | 1.06 | 1.87 | 62% | 19% | 6% | 63% | 0.05 | **3.5** | 1.8 | 1.0/0.0/1.0/1.2/0.3 |
| Borgo | 2P | 2 | 0 | 2 | 0.80 | 1.01 | 1.70 | 57% | 32% | 2% | 78% | 0.02 | **4.8** | 2.4 | 2.0/0.0/1.0/1.6/0.3 |
| Mercato | 2P | 2 | 0 | 2 | 0.36 | 1.04 | 1.69 | 56% | 33% | 1% | 81% | 0.03 | **4.0** | 2.0 | 1.0/0.0/1.0/1.6/0.4 |
| Ospedale dei pellegrini | 2P+1O | 2 | 0 | 2 | 0.37 | 1.01 | 1.66 | 55% | 34% | 0% | 73% | 0.01 | **4.5** | 1.1 | 2.0/0.0/0.9/1.5/0.1 |
| Cappella | 1P+1O | 2 | 0 | 3 | 0.85 | 1.03 | 1.64 | 55% | 37% | 1% | 77% | 0.03 | **5.4** | 1.8 | 2.0/0.0/0.9/2.3/0.2 |
| Conceria | 1P | 1 | 0 | 0 | 0.04 | 1.00 | 1.26 | 42% | 74% | 0% | 91% | 0.00 | **2.3** | 2.3 | 1.0/0.0/1.0/0.1/0.1 |

### Era 4

| carta | costo | res | rend | scavo | per partita | ere intatto | ere in piedi | vita sfruttata | subito | a fine partita | sepolto | vetustà | PV | PV/costo | (L/R/V/S/Sk) |
|---|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|---|
| Fortezza bastionata | 3P+2O | 5 | 3 | 2 | 0.63 | 1.84 | 2.00 | 100% | 0% | 15% | 74% | 0.84 | **8.5** | 1.2 | 0.0/4.0/3.7/0.3/0.5 |
| Duomo | 3P+3O | 4 | 4 | 5 | 0.57 | 1.79 | 2.00 | 100% | 0% | 14% | 77% | 0.79 | **9.1** | 1.0 | 0.0/4.6/3.1/0.9/0.5 |
| Ponte monumentale | 2P+2O | 4 | 3 | 3 | 0.50 | 1.74 | 1.99 | 99% | 1% | 48% | 43% | 0.74 | **7.3** | 1.2 | 0.0/4.7/2.1/0.2/0.3 |
| Piazza monumentale | 2P+2O | 3 | 2 | 3 | 0.20 | 1.57 | 1.93 | 96% | 7% | 11% | 77% | 0.57 | **7.1** | 1.2 | 0.0/2.0/3.7/1.1/0.4 |
| Villa | 2P+2O | 3 | 0 | 3 | 0.79 | 1.04 | 1.83 | 92% | 17% | 34% | 59% | 0.04 | **6.9** | 1.2 | 4.0/0.0/1.1/1.7/0.2 |
| Palazzo signorile | 2P+2O | 3 | 0 | 3 | 0.70 | 1.01 | 1.78 | 89% | 22% | 29% | 62% | 0.01 | **6.1** | 1.0 | 3.0/0.0/1.1/1.9/0.2 |
| Osservatorio | 1P+2O | 2 | 0 | 2 | 0.06 | 1.00 | 1.29 | 65% | 71% | 14% | 39% | 0.00 | **3.6** | 0.7 | 2.0/0.0/0.8/0.8/0.0 |
| Banco | 1P+1O | 2 | 0 | 0 | 0.52 | 1.00 | 1.25 | 63% | 75% | 8% | 62% | 0.00 | **3.3** | 1.1 | 2.0/0.0/1.2/0.0/0.1 |
| Loggia | 1P+1O | 2 | 0 | 2 | 0.66 | 1.00 | 1.25 | 62% | 75% | 7% | 61% | 0.00 | **4.4** | 1.5 | 2.0/0.0/1.1/1.2/0.1 |
| Accademia | 1P+2O | 2 | 0 | 3 | 0.39 | 1.00 | 1.16 | 58% | 84% | 7% | 55% | 0.00 | **4.7** | 0.9 | 2.0/0.0/1.0/1.7/0.0 |
| Bottega d'artista | 1P+1O | 2 | 0 | 2 | 0.67 | 1.00 | 1.14 | 57% | 86% | 6% | 61% | 0.00 | **4.4** | 1.5 | 2.0/0.0/1.2/1.2/0.0 |
| Giardino all'italiana | 0P+2O | 1 | 0 | 0 | 0.46 | 1.00 | 1.02 | 51% | 98% | 1% | 43% | 0.00 | **3.9** | 1.0 | 3.0/0.0/0.9/0.0/0.0 |

### Era 5

| carta | costo | res | rend | scavo | per partita | ere intatto | ere in piedi | vita sfruttata | subito | a fine partita | sepolto | vetustà | PV | PV/costo | (L/R/V/S/Sk) |
|---|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|---|
| Fondazione d'arte | 1P+2O | 2 | 0 | 0 | 0.52 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **7.5** | 1.5 | 3.0/0.0/4.5/0.0/0.0 |
| Condominio | 1P+1O | 2 | 0 | 0 | 0.70 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **7.1** | 2.4 | 2.0/0.0/5.1/0.0/0.0 |
| Caffè letterario | 0P+2O | 1 | 0 | 0 | 0.11 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **6.2** | 1.6 | 2.0/0.0/4.2/0.0/0.0 |
| Officina | 1P+1O | 2 | 0 | 0 | 0.68 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **7.0** | 2.3 | 2.0/0.0/5.0/0.0/0.0 |
| Monumento ai caduti | 1P+2O | 3 | 0 | 0 | 0.18 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **7.4** | 1.5 | 2.0/0.0/5.4/0.0/0.0 |
| Museo | 1P+3O | 3 | 0 | 0 | 0.23 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **9.8** | 1.4 | 4.0/0.0/5.8/0.0/0.0 |
| Grattacielo | 2P+4O | 3 | 0 | 0 | 0.01 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **10.3** | 1.0 | 4.0/0.0/6.3/0.0/0.0 |
| Biblioteca | 1P+3O | 3 | 0 | 0 | 0.32 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **8.0** | 1.1 | 4.0/0.0/4.0/0.0/0.0 |
| Ponte in acciaio | 1P+3O | 4 | 0 | 0 | 0.42 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **14.8** | 2.1 | 4.0/0.0/10.8/0.0/0.0 |
| Stazione | 2P+4O | 4 | 0 | 0 | 0.31 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **26.0** | 2.6 | 4.0/0.0/22.0/0.0/0.0 |
| Parco archeologico | 1P+2O | 2 | 0 | 0 | 0.48 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **15.7** | 3.1 | 2.0/0.0/13.7/0.0/0.0 |
| Università | 2P+3O | 3 | 0 | 0 | 0.50 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **17.8** | 2.2 | 4.0/0.0/13.8/0.0/0.0 |

## Due correlazioni, su chi arriva in tavola almeno 50 volte

- **resistenza stampata** → ere in piedi: r = +0.38 · → PV: r = +0.54
- **costo in pietra** → ere in piedi: r = +0.57 · → PV: r = +0.23
- **Rendita stampata** → ere in piedi: r = +0.36 · → PV: r = +0.19
- **Scavo stampato** → ere in piedi: r = +0.73 · → PV: r = -0.17

---

Rifare il conto: `godot --headless res://scenes/audit_partita.tscn -- --players 3 --vita 2500 --seed 100000` (quattro processi, semi 100000 / 102500 / 105000 / 107500).

## Cosa cambia con il bot che valuta dopo l'attivazione

Le stesse misure su 10000 partite con **bot v1** e 10000 con **bot v2**, a parità di tutto il resto: stessi semi, stesso numero di giocatori. La colonna Δ è la seconda meno la prima.

| misura | bot v1 | bot v2 | Δ |
|---|--:|--:|--:|
| edifici costruiti per partita | 29.33 | 30.12 | +0.78 |
| ere intatto (media) | 1.70 | 1.68 | −0.02 |
| ere in piedi (media) | 2.11 | 2.06 | −0.04 |
| cade nella sua era | 16% | 16% | +0% |
| in piedi a fine partita | 30% | 31% | +1% |
| sepolto | 51% | 52% | +1% |
| vetustà media | 0.56 | 0.55 | −0.01 |
| potenziamenti per edificio | 0.04 | 0.04 | +0.00 |
| PV per edificio | 6.9 | 7.0 | +0.1 |
| PV per partita (i tre giocatori insieme) | 201 | 211 | +10 |

| canale (PV per partita, tutti i giocatori) | bot v1 | bot v2 | Δ |
|---|--:|--:|--:|
| Lampo | 35.0 | 37.3 | +2.3 |
| Rendita | 65.0 | 65.8 | +0.7 |
| Verticalita | 73.7 | 77.9 | +4.2 |
| Scavo | 20.2 | 21.3 | +1.2 |
| Scheletri | 7.1 | 8.2 | +1.2 |

### Le carte che si cercano di più

Copie costruite per partita, prima e dopo.

| carta | era | costo | bot v1 | bot v2 | Δ | PV bot v1 | PV bot v2 |
|---|--:|--:|--:|--:|--:|--:|--:|
| Fondazione d'arte | 5 | 1P+2O | 0.42 | 0.52 | +0.10 | 7.6 | 7.5 |
| Università | 5 | 2P+3O | 0.43 | 0.50 | +0.07 | 17.6 | 17.8 |
| Duomo | 4 | 3P+3O | 0.50 | 0.57 | +0.07 | 9.7 | 9.1 |
| Villa | 4 | 2P+2O | 0.72 | 0.79 | +0.07 | 7.1 | 6.9 |
| Condominio | 5 | 1P+1O | 0.64 | 0.70 | +0.06 | 7.4 | 7.1 |
| Officina | 5 | 1P+1O | 0.62 | 0.68 | +0.06 | 7.2 | 7.0 |
| Parco archeologico | 5 | 1P+2O | 0.42 | 0.48 | +0.06 | 15.6 | 15.7 |
| Palazzo signorile | 4 | 2P+2O | 0.64 | 0.70 | +0.06 | 6.2 | 6.1 |
| Tempio | 2 | 3P | 0.60 | 0.65 | +0.06 | 4.5 | 4.4 |
| Ponte in acciaio | 5 | 1P+3O | 0.36 | 0.42 | +0.06 | 15.6 | 14.8 |

### E quelle che si cercano di meno

Le stesse carte, dall'altro capo della classifica.

| carta | era | costo | bot v1 | bot v2 | Δ | PV bot v1 | PV bot v2 |
|---|--:|--:|--:|--:|--:|--:|--:|
| Approdo | 1 | 1P | 0.40 | 0.30 | −0.11 | 2.4 | 2.7 |
| Tumulo funerario | 1 | 2P | 0.75 | 0.69 | −0.06 | 3.8 | 3.9 |
| Mercato | 3 | 2P | 0.40 | 0.36 | −0.05 | 3.9 | 4.0 |
| Mura | 3 | 2P | 0.12 | 0.09 | −0.03 | 2.7 | 2.8 |
| Insulae | 2 | 2P | 0.51 | 0.49 | −0.02 | 3.5 | 3.6 |
| Grotte dipinte | 1 | 1P | 0.47 | 0.45 | −0.02 | 1.8 | 1.9 |
| Palafitte | 1 | 1P | 0.96 | 0.94 | −0.02 | 3.5 | 3.6 |
| Mulino | 3 | 2P | 0.32 | 0.30 | −0.02 | 3.3 | 3.5 |
| Focolare comune | 1 | 1P | 0.04 | 0.02 | −0.02 | 2.6 | 3.0 |
| Capanne | 1 | 1P | 0.97 | 0.96 | −0.02 | 3.3 | 3.8 |

### Carte che non arrivano quasi mai in tavola

- **Torre di vedetta** (era 2, 2P) — una ogni 263 partite, contro una ogni 250 prima
- **Trappole da pesca** (era 1, 1P) — una ogni 192 partite, contro una ogni 53 prima
- **Grattacielo** (era 5, 2P+4O) — una ogni 112 partite, contro una ogni 122 prima
- **Focolare comune** (era 1, 1P) — una ogni 58 partite, contro una ogni 26 prima

