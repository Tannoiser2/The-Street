# La vita degli edifici

Misurata su **10 000 partite** a 3 giocatori, rigiocate dal motore vero (`scripts/tools/audit_partita.gd`, modalità `--vita`). In tutto 287 047 edifici costruiti.

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
| era 1 | 12 | 6.8 | 2.12 | 2.56 | 19% | 20% | 66% | 6.3 |
| era 2 | 12 | 5.5 | 1.94 | 2.34 | 6% | 15% | 70% | 6.3 |
| era 3 | 12 | 6.4 | 1.41 | 1.96 | 18% | 11% | 72% | 5.6 |
| era 4 | 12 | 5.9 | 1.24 | 1.59 | 41% | 21% | 58% | 6.5 |
| era 5 | 12 | 4.1 | 1.00 | 1.00 | 0% | 100% | 0% | 11.8 |

In media una partita mette in tavola **28.7 edifici**; di questi **29%** è ancora in piedi alla fine, **57%** finisce sotterrato e **18%** non supera l'era in cui è nato.

## Cosa salta all'occhio

**1. La Rendita è il canale che paga la durata, ed è quasi tutto.** Le 15 carte con Rendita stampata fruttano in media **8.6 PV** contro i **6.1** delle altre, e restano in piedi 2.60 ere contro 1.62. Non è una sorpresa — la Rendita si incassa a ogni censimento — ma dice che il valore di una carta lo decide quasi tutto un numero solo.

**2. La resistenza fa esattamente il suo mestiere.** Sulle ere 1-4, per ogni punto di resistenza:

| resistenza | carte | ere in piedi | cade nella sua era | PV medi |
|---|--:|--:|--:|--:|
| 1 | 7 | 1.63 | 41% | 3.5 |
| 2 | 17 | 1.74 | 34% | 4.4 |
| 3 | 14 | 2.34 | 9% | 6.5 |
| 4 | 8 | 2.65 | 12% | 9.0 |
| 5 | 2 | 2.31 | 4% | 9.9 |

Fra resistenza 1 e resistenza 4 la vita raddoppia e i punti quasi triplicano. Il salto vero è **fra 2 e 3**: è lì che un edificio smette di essere materiale da riempimento.

**3. Le carte da una pietra dell'era 1 non sono edifici: sono Scavo da seminare.** Approdo, Capanne, Cava, Focolare comune, Grotte dipinte, Palafitte, Trappole da pesca vivono 1.9 ere, finiscono sotto nel **76%** dei casi e 37 punti su cento di quello che fruttano sono Scavo. Funzionano — ma solo se chi le gioca sa che le sta seminando, non costruendo.

**4. Un edificio dell'era 5 non può morire.** Gli eventi sono solo nelle ere 1-4: chi costruisce nell'era Moderna non vedrà mai un censimento né un evento. Si vede nei numeri: vetustà **0.00**, Rendita **0.00**, Scavo **0.00**, e il **100%** ancora in piedi. Le carte dell'era 5 pagano solo Lampo e Verticalità, e vanno lette con un metro diverso dalle altre: il loro valore è tutto nell'istante in cui le metti.

**5. I colossali prendono la cima di tre colonne.** Un edificio da tre caselle conta come strato in tutte le colonne che tocca — quindi incassa il premio della cima **tre volte**:

| larghezza | carte | costruiti | PV medi | di cui Verticalità |
|---|--:|--:|--:|--:|
| 1 casella | 41 | 194 867 | 5.6 | 1.8 |
| 2 caselle | 16 | 74 189 | 9.4 | 4.6 |
| 3 caselle | 3 | 17 991 | 12.1 | 6.2 |

Il caso limite è la **Stazione** (era 5, tre caselle, 2P+4O): **26.7 PV medi**, di cui 22.7 di sola Verticalità — contro i 18.5 della seconda della lista, Università. Arriva in tavola una volta ogni 4 partite, quindi non rompe la media, ma quando arriva decide la colonna. Vale la pena chiedersi se il premio della cima debba contare una volta per edificio invece che una volta per colonna.

## Gli estremi

### Le dodici vite più brevi

Ordinate per **vita sfruttata**, non per ere secche: se no in testa finirebbero le carte dell'era 5, che vivono una sola era perché la partita finisce, non perché crollano.

| carta | costo | res | rend | scavo | per partita | ere intatto | ere in piedi | vita sfruttata | subito | a fine partita | sepolto | vetustà | PV | PV/costo | (L/R/V/S/Sk) |
|---|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|---|
| Capanne | 1P | 1 | 0 | 2 | 0.82 | 1.05 | 1.69 | 34% | 37% | 0% | 80% | 0.05 | **4.0** | 4.0 | 1.0/0.0/1.3/1.5/0.2 |
| Cava | 1P | 1 | 0 | 2 | 0.90 | 1.07 | 1.79 | 36% | 27% | 0% | 78% | 0.07 | **3.1** | 3.1 | 0.0/0.0/1.3/1.4/0.4 |
| Trappole da pesca | 1P | 1 | 0 | 0 | 0.01 | 1.00 | 1.80 | 36% | 20% | 0% | 80% | 0.00 | **1.8** | 1.8 | 0.0/0.0/1.3/0.2/0.2 |
| Approdo | 1P | 1 | 0 | 2 | 0.30 | 1.00 | 1.82 | 36% | 19% | 0% | 70% | 0.00 | **2.9** | 2.9 | 0.0/0.0/1.3/1.5/0.1 |
| Focolare comune | 1P | 1 | 0 | 2 | 0.11 | 1.04 | 1.89 | 38% | 17% | 0% | 79% | 0.05 | **3.9** | 3.9 | 1.0/0.0/1.2/1.6/0.0 |
| Tumulo funerario | 2P | 3 | 0 | 5 | 0.46 | 1.97 | 1.97 | 39% | 4% | 0% | 100% | 0.96 | **4.4** | 2.2 | 1.0/0.0/2.4/0.0/1.0 |
| Villaggio palizzato | 2P | 2 | 0 | 2 | 0.09 | 1.68 | 2.00 | 40% | 0% | 0% | 100% | 0.68 | **5.7** | 2.9 | 1.0/0.0/2.4/0.9/1.4 |
| Conceria | 1P | 1 | 0 | 0 | 0.05 | 1.00 | 1.24 | 41% | 77% | 1% | 81% | 0.00 | **2.3** | 2.3 | 1.0/0.0/1.1/0.0/0.2 |
| Palafitte | 1P | 2 | 0 | 2 | 0.84 | 1.48 | 2.20 | 44% | 7% | 3% | 72% | 0.40 | **3.8** | 3.8 | 1.0/0.0/1.3/1.0/0.4 |
| Sacello | 1P | 2 | 0 | 3 | 0.48 | 1.16 | 1.94 | 48% | 14% | 2% | 77% | 0.14 | **4.3** | 4.3 | 1.0/0.0/1.1/2.0/0.2 |
| Grotte dipinte | 1P | 2 | 0 | 6 | 0.38 | 2.04 | 2.45 | 49% | 11% | 8% | 73% | 0.79 | **2.3** | 2.3 | 0.0/0.0/1.3/0.8/0.1 |
| Emporio | 2P | 2 | 0 | 2 | 0.07 | 1.30 | 2.00 | 50% | 0% | 0% | 91% | 0.31 | **4.1** | 2.1 | 1.0/0.0/1.3/1.3/0.6 |

### Le dodici che arrivano in fondo

Ordinate per vita sfruttata.

| carta | costo | res | rend | scavo | per partita | ere intatto | ere in piedi | vita sfruttata | subito | a fine partita | sepolto | vetustà | PV | PV/costo | (L/R/V/S/Sk) |
|---|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|---|
| Fortezza bastionata | 3P+2O | 5 | 3 | 2 | 0.60 | 1.85 | 2.00 | 100% | 0% | 21% | 66% | 0.85 | **9.6** | 1.4 | 0.0/4.2/4.7/0.2/0.5 |
| Fondazione d'arte | 1P+2O | 2 | 0 | 0 | 0.48 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **7.8** | 1.6 | 3.0/0.0/4.8/0.0/0.0 |
| Condominio | 1P+1O | 2 | 0 | 0 | 0.69 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **7.5** | 2.5 | 2.0/0.0/5.5/0.0/0.0 |
| Caffè letterario | 0P+2O | 1 | 0 | 0 | 0.11 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **6.6** | 1.6 | 2.0/0.0/4.6/0.0/0.0 |
| Officina | 1P+1O | 2 | 0 | 0 | 0.68 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **7.4** | 2.5 | 2.0/0.0/5.4/0.0/0.0 |
| Monumento ai caduti | 1P+2O | 3 | 0 | 0 | 0.18 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **7.3** | 1.5 | 2.0/0.0/5.3/0.0/0.0 |
| Museo | 1P+3O | 3 | 0 | 0 | 0.19 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **10.2** | 1.5 | 4.0/0.0/6.2/0.0/0.0 |
| Grattacielo | 2P+4O | 3 | 0 | 0 | 0.01 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **10.2** | 1.0 | 4.0/0.0/6.2/0.0/0.0 |
| Biblioteca | 1P+3O | 3 | 0 | 0 | 0.27 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **8.3** | 1.2 | 4.0/0.0/4.3/0.0/0.0 |
| Ponte in acciaio | 1P+3O | 4 | 0 | 0 | 0.40 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **15.8** | 2.3 | 4.0/0.0/11.8/0.0/0.0 |
| Stazione | 2P+4O | 4 | 0 | 0 | 0.27 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **26.7** | 2.7 | 4.0/0.0/22.7/0.0/0.0 |
| Parco archeologico | 1P+2O | 2 | 0 | 0 | 0.44 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **16.3** | 3.3 | 2.0/0.0/14.3/0.0/0.0 |

### Le dodici che rendono di più

Ordinate per PV medi fruttati al proprietario.

| carta | costo | res | rend | scavo | per partita | ere intatto | ere in piedi | vita sfruttata | subito | a fine partita | sepolto | vetustà | PV | PV/costo | (L/R/V/S/Sk) |
|---|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|---|
| Stazione | 2P+4O | 4 | 0 | 0 | 0.27 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **26.7** | 2.7 | 4.0/0.0/22.7/0.0/0.0 |
| Università | 2P+3O | 3 | 0 | 0 | 0.44 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **18.5** | 2.3 | 4.0/0.0/14.5/0.0/0.0 |
| Parco archeologico | 1P+2O | 2 | 0 | 0 | 0.44 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **16.3** | 3.3 | 2.0/0.0/14.3/0.0/0.0 |
| Ponte in acciaio | 1P+3O | 4 | 0 | 0 | 0.40 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **15.8** | 2.3 | 4.0/0.0/11.8/0.0/0.0 |
| Menhir | 2P | 4 | 1 | 3 | 0.95 | 3.52 | 3.80 | 76% | 15% | 57% | 38% | 1.72 | **11.3** | 5.7 | 0.0/9.6/1.2/0.0/0.4 |
| Duomo | 3P+3O | 4 | 4 | 5 | 0.52 | 1.79 | 1.99 | 100% | 1% | 17% | 71% | 0.79 | **10.3** | 1.1 | 0.0/4.7/4.2/0.8/0.6 |
| Dolmen | 2P | 3 | 1 | 3 | 0.95 | 3.39 | 3.72 | 74% | 14% | 53% | 39% | 1.48 | **10.3** | 5.1 | 0.0/8.7/1.2/0.0/0.4 |
| Grattacielo | 2P+4O | 3 | 0 | 0 | 0.01 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **10.2** | 1.0 | 4.0/0.0/6.2/0.0/0.0 |
| Museo | 1P+3O | 3 | 0 | 0 | 0.19 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **10.2** | 1.5 | 4.0/0.0/6.2/0.0/0.0 |
| Anfiteatro | 5P | 5 | 2 | 6 | 0.85 | 2.50 | 2.52 | 63% | 6% | 21% | 60% | 1.46 | **10.2** | 2.0 | 0.0/6.3/3.3/0.0/0.5 |
| Fortezza bastionata | 3P+2O | 5 | 3 | 2 | 0.60 | 1.85 | 2.00 | 100% | 0% | 21% | 66% | 0.85 | **9.6** | 1.4 | 0.0/4.2/4.7/0.2/0.5 |
| Acquedotto | 3P | 4 | 1 | 3 | 0.68 | 2.53 | 2.62 | 65% | 14% | 32% | 50% | 1.43 | **8.9** | 3.0 | 0.0/5.1/3.2/0.0/0.5 |

### Le dodici che rendono di più per quello che costano

Ordinate per PV diviso il costo in pietra equivalente.

| carta | costo | res | rend | scavo | per partita | ere intatto | ere in piedi | vita sfruttata | subito | a fine partita | sepolto | vetustà | PV | PV/costo | (L/R/V/S/Sk) |
|---|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|---|
| Menhir | 2P | 4 | 1 | 3 | 0.95 | 3.52 | 3.80 | 76% | 15% | 57% | 38% | 1.72 | **11.3** | 5.7 | 0.0/9.6/1.2/0.0/0.4 |
| Dolmen | 2P | 3 | 1 | 3 | 0.95 | 3.39 | 3.72 | 74% | 14% | 53% | 39% | 1.48 | **10.3** | 5.1 | 0.0/8.7/1.2/0.0/0.4 |
| Sacello | 1P | 2 | 0 | 3 | 0.48 | 1.16 | 1.94 | 48% | 14% | 2% | 77% | 0.14 | **4.3** | 4.3 | 1.0/0.0/1.1/2.0/0.2 |
| Capanne | 1P | 1 | 0 | 2 | 0.82 | 1.05 | 1.69 | 34% | 37% | 0% | 80% | 0.05 | **4.0** | 4.0 | 1.0/0.0/1.3/1.5/0.2 |
| Palafitte | 1P | 2 | 0 | 2 | 0.84 | 1.48 | 2.20 | 44% | 7% | 3% | 72% | 0.40 | **3.8** | 3.8 | 1.0/0.0/1.3/1.0/0.4 |
| Parco archeologico | 1P+2O | 2 | 0 | 0 | 0.44 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **16.3** | 3.3 | 2.0/0.0/14.3/0.0/0.0 |
| Cava | 1P | 1 | 0 | 2 | 0.90 | 1.07 | 1.79 | 36% | 27% | 0% | 78% | 0.07 | **3.1** | 3.1 | 0.0/0.0/1.3/1.4/0.4 |
| Acquedotto | 3P | 4 | 1 | 3 | 0.68 | 2.53 | 2.62 | 65% | 14% | 32% | 50% | 1.43 | **8.9** | 3.0 | 0.0/5.1/3.2/0.0/0.5 |
| Approdo | 1P | 1 | 0 | 2 | 0.30 | 1.00 | 1.82 | 36% | 19% | 0% | 70% | 0.00 | **2.9** | 2.9 | 0.0/0.0/1.3/1.5/0.1 |
| Circolo di pietre | 3P | 4 | 1 | 5 | 0.97 | 2.57 | 2.67 | 53% | 30% | 27% | 69% | 1.18 | **8.5** | 2.8 | 0.0/5.4/2.5/0.0/0.6 |
| Stazione | 2P+4O | 4 | 0 | 0 | 0.27 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **26.7** | 2.7 | 4.0/0.0/22.7/0.0/0.0 |
| Terme | 2P | 2 | 0 | 3 | 0.55 | 1.40 | 2.09 | 52% | 1% | 3% | 77% | 0.37 | **5.0** | 2.5 | 2.0/0.0/1.1/1.4/0.5 |

### Le dodici che rendono di meno

Solo carte che arrivano in tavola almeno una volta ogni cinque partite: una carta rara ha medie ballerine.

| carta | costo | res | rend | scavo | per partita | ere intatto | ere in piedi | vita sfruttata | subito | a fine partita | sepolto | vetustà | PV | PV/costo | (L/R/V/S/Sk) |
|---|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|---|
| Grotte dipinte | 1P | 2 | 0 | 6 | 0.38 | 2.04 | 2.45 | 49% | 11% | 8% | 73% | 0.79 | **2.3** | 2.3 | 0.0/0.0/1.3/0.8/0.1 |
| Approdo | 1P | 1 | 0 | 2 | 0.30 | 1.00 | 1.82 | 36% | 19% | 0% | 70% | 0.00 | **2.9** | 2.9 | 0.0/0.0/1.3/1.5/0.1 |
| Cava | 1P | 1 | 0 | 2 | 0.90 | 1.07 | 1.79 | 36% | 27% | 0% | 78% | 0.07 | **3.1** | 3.1 | 0.0/0.0/1.3/1.4/0.4 |
| Mulino | 2P | 2 | 0 | 2 | 0.35 | 1.06 | 1.92 | 64% | 18% | 9% | 59% | 0.06 | **3.4** | 1.7 | 1.0/0.0/1.0/1.1/0.3 |
| Insulae | 2P | 2 | 0 | 2 | 0.54 | 1.33 | 2.08 | 52% | 1% | 3% | 76% | 0.30 | **3.7** | 1.9 | 1.0/0.0/1.1/1.1/0.5 |
| Banco | 1P+1O | 2 | 0 | 0 | 0.54 | 1.00 | 1.31 | 66% | 69% | 12% | 60% | 0.00 | **3.7** | 1.2 | 2.0/0.0/1.6/0.0/0.1 |
| Palafitte | 1P | 2 | 0 | 2 | 0.84 | 1.48 | 2.20 | 44% | 7% | 3% | 72% | 0.40 | **3.8** | 3.8 | 1.0/0.0/1.3/1.0/0.4 |
| Mercato | 2P | 2 | 0 | 2 | 0.43 | 1.02 | 1.69 | 56% | 33% | 1% | 73% | 0.02 | **3.8** | 1.9 | 1.0/0.0/1.0/1.5/0.3 |
| Capanne | 1P | 1 | 0 | 2 | 0.82 | 1.05 | 1.69 | 34% | 37% | 0% | 80% | 0.05 | **4.0** | 4.0 | 1.0/0.0/1.3/1.5/0.2 |
| Giardino all'italiana | 0P+2O | 1 | 0 | 0 | 0.43 | 1.00 | 1.02 | 51% | 98% | 1% | 46% | 0.00 | **4.2** | 1.1 | 3.0/0.0/1.2/0.0/0.0 |
| Sacello | 1P | 2 | 0 | 3 | 0.48 | 1.16 | 1.94 | 48% | 14% | 2% | 77% | 0.14 | **4.3** | 4.3 | 1.0/0.0/1.1/2.0/0.2 |
| Tumulo funerario | 2P | 3 | 0 | 5 | 0.46 | 1.97 | 1.97 | 39% | 4% | 0% | 100% | 0.96 | **4.4** | 2.2 | 1.0/0.0/2.4/0.0/1.0 |

### Le dodici più sepolte

Ordinate per quota di copie finite sotto un altro edificio.

| carta | costo | res | rend | scavo | per partita | ere intatto | ere in piedi | vita sfruttata | subito | a fine partita | sepolto | vetustà | PV | PV/costo | (L/R/V/S/Sk) |
|---|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|---|
| Villaggio palizzato | 2P | 2 | 0 | 2 | 0.09 | 1.68 | 2.00 | 40% | 0% | 0% | 100% | 0.68 | **5.7** | 2.9 | 1.0/0.0/2.4/0.9/1.4 |
| Tumulo funerario | 2P | 3 | 0 | 5 | 0.46 | 1.97 | 1.97 | 39% | 4% | 0% | 100% | 0.96 | **4.4** | 2.2 | 1.0/0.0/2.4/0.0/1.0 |
| Castrum | 3P | 4 | 0 | 3 | 0.04 | 2.08 | 2.08 | 52% | 2% | 5% | 95% | 1.08 | **4.1** | 1.4 | 1.0/0.0/2.2/0.0/0.9 |
| Arsenale | 3P+1O | 3 | 0 | 2 | 0.27 | 1.68 | 1.99 | 66% | 4% | 2% | 92% | 0.68 | **5.5** | 1.1 | 2.0/0.0/2.1/0.6/0.8 |
| Emporio | 2P | 2 | 0 | 2 | 0.07 | 1.30 | 2.00 | 50% | 0% | 0% | 91% | 0.31 | **4.1** | 2.1 | 1.0/0.0/1.3/1.3/0.6 |
| Castello | 2P+1O | 4 | 3 | 3 | 0.75 | 2.08 | 2.16 | 72% | 0% | 7% | 89% | 1.08 | **8.3** | 2.1 | 0.0/4.9/2.3/0.2/0.9 |
| Torre di vedetta | 2P | 3 | 0 | 2 | 0.01 | 1.75 | 2.14 | 54% | 0% | 7% | 89% | 0.73 | **3.1** | 1.5 | 1.0/0.0/1.2/0.7/0.2 |
| Conceria | 1P | 1 | 0 | 0 | 0.05 | 1.00 | 1.24 | 41% | 77% | 1% | 81% | 0.00 | **2.3** | 2.3 | 1.0/0.0/1.1/0.0/0.2 |
| Trappole da pesca | 1P | 1 | 0 | 0 | 0.01 | 1.00 | 1.80 | 36% | 20% | 0% | 80% | 0.00 | **1.8** | 1.8 | 0.0/0.0/1.3/0.2/0.2 |
| Capanne | 1P | 1 | 0 | 2 | 0.82 | 1.05 | 1.69 | 34% | 37% | 0% | 80% | 0.05 | **4.0** | 4.0 | 1.0/0.0/1.3/1.5/0.2 |
| Focolare comune | 1P | 1 | 0 | 2 | 0.11 | 1.04 | 1.89 | 38% | 17% | 0% | 79% | 0.05 | **3.9** | 3.9 | 1.0/0.0/1.2/1.6/0.0 |
| Teatro | 2P | 3 | 0 | 5 | 0.74 | 1.90 | 2.29 | 57% | 2% | 12% | 79% | 0.78 | **4.5** | 2.2 | 2.0/0.0/1.2/0.9/0.4 |

## Tutte le carte, era per era

### Era 1

| carta | costo | res | rend | scavo | per partita | ere intatto | ere in piedi | vita sfruttata | subito | a fine partita | sepolto | vetustà | PV | PV/costo | (L/R/V/S/Sk) |
|---|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|---|
| Menhir | 2P | 4 | 1 | 3 | 0.95 | 3.52 | 3.80 | 76% | 15% | 57% | 38% | 1.72 | **11.3** | 5.7 | 0.0/9.6/1.2/0.0/0.4 |
| Dolmen | 2P | 3 | 1 | 3 | 0.95 | 3.39 | 3.72 | 74% | 14% | 53% | 39% | 1.48 | **10.3** | 5.1 | 0.0/8.7/1.2/0.0/0.4 |
| Circolo di pietre | 3P | 4 | 1 | 5 | 0.97 | 2.57 | 2.67 | 53% | 30% | 27% | 69% | 1.18 | **8.5** | 2.8 | 0.0/5.4/2.5/0.0/0.6 |
| Grotte dipinte | 1P | 2 | 0 | 6 | 0.38 | 2.04 | 2.45 | 49% | 11% | 8% | 73% | 0.79 | **2.3** | 2.3 | 0.0/0.0/1.3/0.8/0.1 |
| Palafitte | 1P | 2 | 0 | 2 | 0.84 | 1.48 | 2.20 | 44% | 7% | 3% | 72% | 0.40 | **3.8** | 3.8 | 1.0/0.0/1.3/1.0/0.4 |
| Villaggio palizzato | 2P | 2 | 0 | 2 | 0.09 | 1.68 | 2.00 | 40% | 0% | 0% | 100% | 0.68 | **5.7** | 2.9 | 1.0/0.0/2.4/0.9/1.4 |
| Tumulo funerario | 2P | 3 | 0 | 5 | 0.46 | 1.97 | 1.97 | 39% | 4% | 0% | 100% | 0.96 | **4.4** | 2.2 | 1.0/0.0/2.4/0.0/1.0 |
| Focolare comune | 1P | 1 | 0 | 2 | 0.11 | 1.04 | 1.89 | 38% | 17% | 0% | 79% | 0.05 | **3.9** | 3.9 | 1.0/0.0/1.2/1.6/0.0 |
| Approdo | 1P | 1 | 0 | 2 | 0.30 | 1.00 | 1.82 | 36% | 19% | 0% | 70% | 0.00 | **2.9** | 2.9 | 0.0/0.0/1.3/1.5/0.1 |
| Trappole da pesca | 1P | 1 | 0 | 0 | 0.01 | 1.00 | 1.80 | 36% | 20% | 0% | 80% | 0.00 | **1.8** | 1.8 | 0.0/0.0/1.3/0.2/0.2 |
| Cava | 1P | 1 | 0 | 2 | 0.90 | 1.07 | 1.79 | 36% | 27% | 0% | 78% | 0.07 | **3.1** | 3.1 | 0.0/0.0/1.3/1.4/0.4 |
| Capanne | 1P | 1 | 0 | 2 | 0.82 | 1.05 | 1.69 | 34% | 37% | 0% | 80% | 0.05 | **4.0** | 4.0 | 1.0/0.0/1.3/1.5/0.2 |

### Era 2

| carta | costo | res | rend | scavo | per partita | ere intatto | ere in piedi | vita sfruttata | subito | a fine partita | sepolto | vetustà | PV | PV/costo | (L/R/V/S/Sk) |
|---|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|---|
| Acquedotto | 3P | 4 | 1 | 3 | 0.68 | 2.53 | 2.62 | 65% | 14% | 32% | 50% | 1.43 | **8.9** | 3.0 | 0.0/5.1/3.2/0.0/0.5 |
| Ponte | 3P | 3 | 1 | 3 | 0.25 | 2.14 | 2.53 | 63% | 3% | 22% | 67% | 1.02 | **6.6** | 2.2 | 0.0/3.4/2.1/0.4/0.7 |
| Anfiteatro | 5P | 5 | 2 | 6 | 0.85 | 2.50 | 2.52 | 63% | 6% | 21% | 60% | 1.46 | **10.2** | 2.0 | 0.0/6.3/3.3/0.0/0.5 |
| Tempio | 3P | 3 | 1 | 3 | 0.56 | 1.92 | 2.44 | 61% | 4% | 19% | 72% | 0.82 | **5.1** | 1.7 | 0.0/2.7/1.1/0.8/0.5 |
| Foro | 3P | 3 | 1 | 5 | 0.73 | 2.13 | 2.44 | 61% | 5% | 21% | 69% | 1.03 | **6.7** | 2.2 | 0.0/3.3/2.2/0.3/0.8 |
| Teatro | 2P | 3 | 0 | 5 | 0.74 | 1.90 | 2.29 | 57% | 2% | 12% | 79% | 0.78 | **4.5** | 2.2 | 2.0/0.0/1.2/0.9/0.4 |
| Torre di vedetta | 2P | 3 | 0 | 2 | 0.01 | 1.75 | 2.14 | 54% | 0% | 7% | 89% | 0.73 | **3.1** | 1.5 | 1.0/0.0/1.2/0.7/0.2 |
| Terme | 2P | 2 | 0 | 3 | 0.55 | 1.40 | 2.09 | 52% | 1% | 3% | 77% | 0.37 | **5.0** | 2.5 | 2.0/0.0/1.1/1.4/0.5 |
| Castrum | 3P | 4 | 0 | 3 | 0.04 | 2.08 | 2.08 | 52% | 2% | 5% | 95% | 1.08 | **4.1** | 1.4 | 1.0/0.0/2.2/0.0/0.9 |
| Insulae | 2P | 2 | 0 | 2 | 0.54 | 1.33 | 2.08 | 52% | 1% | 3% | 76% | 0.30 | **3.7** | 1.9 | 1.0/0.0/1.1/1.1/0.5 |
| Emporio | 2P | 2 | 0 | 2 | 0.07 | 1.30 | 2.00 | 50% | 0% | 0% | 91% | 0.31 | **4.1** | 2.1 | 1.0/0.0/1.3/1.3/0.6 |
| Sacello | 1P | 2 | 0 | 3 | 0.48 | 1.16 | 1.94 | 48% | 14% | 2% | 77% | 0.14 | **4.3** | 4.3 | 1.0/0.0/1.1/2.0/0.2 |

### Era 3

| carta | costo | res | rend | scavo | per partita | ere intatto | ere in piedi | vita sfruttata | subito | a fine partita | sepolto | vetustà | PV | PV/costo | (L/R/V/S/Sk) |
|---|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|---|
| Mura | 2P | 4 | 0 | 2 | 0.14 | 2.11 | 2.41 | 80% | 0% | 32% | 66% | 1.05 | **2.7** | 1.4 | 1.0/0.0/1.3/0.2/0.2 |
| Abbazia | 2P+2O | 3 | 3 | 5 | 0.74 | 1.89 | 2.37 | 79% | 2% | 36% | 46% | 0.88 | **8.4** | 1.4 | 0.0/5.4/2.0/0.5/0.4 |
| Castello | 2P+1O | 4 | 3 | 3 | 0.75 | 2.08 | 2.16 | 72% | 0% | 7% | 89% | 1.08 | **8.3** | 2.1 | 0.0/4.9/2.3/0.2/0.9 |
| Torre civica | 2P | 3 | 0 | 2 | 0.76 | 1.26 | 2.10 | 70% | 7% | 14% | 75% | 0.26 | **4.6** | 2.3 | 2.0/0.0/1.1/1.1/0.4 |
| Chiesa | 2P+1O | 3 | 2 | 3 | 0.75 | 1.67 | 2.08 | 69% | 17% | 18% | 68% | 0.65 | **5.3** | 1.3 | 0.0/2.8/1.0/1.1/0.4 |
| Arsenale | 3P+1O | 3 | 0 | 2 | 0.27 | 1.68 | 1.99 | 66% | 4% | 2% | 92% | 0.68 | **5.5** | 1.1 | 2.0/0.0/2.1/0.6/0.8 |
| Mulino | 2P | 2 | 0 | 2 | 0.35 | 1.06 | 1.92 | 64% | 18% | 9% | 59% | 0.06 | **3.4** | 1.7 | 1.0/0.0/1.0/1.1/0.3 |
| Borgo | 2P | 2 | 0 | 2 | 0.84 | 1.02 | 1.76 | 59% | 30% | 4% | 76% | 0.03 | **4.9** | 2.4 | 2.0/0.0/1.0/1.5/0.3 |
| Mercato | 2P | 2 | 0 | 2 | 0.43 | 1.02 | 1.69 | 56% | 33% | 1% | 73% | 0.02 | **3.8** | 1.9 | 1.0/0.0/1.0/1.5/0.3 |
| Ospedale dei pellegrini | 2P+1O | 2 | 0 | 2 | 0.41 | 1.01 | 1.68 | 56% | 32% | 0% | 72% | 0.01 | **4.6** | 1.2 | 2.0/0.0/1.0/1.4/0.2 |
| Cappella | 1P+1O | 2 | 0 | 3 | 0.86 | 1.03 | 1.65 | 55% | 36% | 1% | 77% | 0.03 | **5.5** | 1.8 | 2.0/0.0/1.0/2.3/0.3 |
| Conceria | 1P | 1 | 0 | 0 | 0.05 | 1.00 | 1.24 | 41% | 77% | 1% | 81% | 0.00 | **2.3** | 2.3 | 1.0/0.0/1.1/0.0/0.2 |

### Era 4

| carta | costo | res | rend | scavo | per partita | ere intatto | ere in piedi | vita sfruttata | subito | a fine partita | sepolto | vetustà | PV | PV/costo | (L/R/V/S/Sk) |
|---|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|---|
| Fortezza bastionata | 3P+2O | 5 | 3 | 2 | 0.60 | 1.85 | 2.00 | 100% | 0% | 21% | 66% | 0.85 | **9.6** | 1.4 | 0.0/4.2/4.7/0.2/0.5 |
| Duomo | 3P+3O | 4 | 4 | 5 | 0.52 | 1.79 | 1.99 | 100% | 1% | 17% | 71% | 0.79 | **10.3** | 1.1 | 0.0/4.7/4.2/0.8/0.6 |
| Ponte monumentale | 2P+2O | 4 | 3 | 3 | 0.51 | 1.73 | 1.99 | 99% | 1% | 55% | 37% | 0.73 | **8.1** | 1.3 | 0.0/4.9/2.8/0.2/0.2 |
| Piazza monumentale | 2P+2O | 3 | 2 | 3 | 0.21 | 1.57 | 1.94 | 97% | 6% | 14% | 72% | 0.57 | **7.8** | 1.3 | 0.0/2.1/4.4/1.0/0.4 |
| Villa | 2P+2O | 3 | 0 | 3 | 0.74 | 1.04 | 1.84 | 92% | 16% | 37% | 56% | 0.04 | **7.2** | 1.2 | 4.0/0.0/1.4/1.6/0.2 |
| Palazzo signorile | 2P+2O | 3 | 0 | 3 | 0.67 | 1.01 | 1.78 | 89% | 22% | 30% | 61% | 0.01 | **6.4** | 1.1 | 3.0/0.0/1.4/1.8/0.2 |
| Osservatorio | 1P+2O | 2 | 0 | 2 | 0.05 | 1.00 | 1.35 | 68% | 65% | 20% | 41% | 0.00 | **4.0** | 0.8 | 2.0/0.0/1.1/0.8/0.0 |
| Banco | 1P+1O | 2 | 0 | 0 | 0.54 | 1.00 | 1.31 | 66% | 69% | 12% | 60% | 0.00 | **3.7** | 1.2 | 2.0/0.0/1.6/0.0/0.1 |
| Loggia | 1P+1O | 2 | 0 | 2 | 0.65 | 1.00 | 1.28 | 64% | 72% | 9% | 58% | 0.00 | **4.7** | 1.6 | 2.0/0.0/1.4/1.2/0.1 |
| Bottega d'artista | 1P+1O | 2 | 0 | 2 | 0.65 | 1.00 | 1.18 | 59% | 82% | 9% | 58% | 0.00 | **4.7** | 1.6 | 2.0/0.0/1.5/1.2/0.0 |
| Accademia | 1P+2O | 2 | 0 | 3 | 0.35 | 1.00 | 1.16 | 58% | 84% | 8% | 53% | 0.00 | **4.8** | 1.0 | 2.0/0.0/1.2/1.6/0.0 |
| Giardino all'italiana | 0P+2O | 1 | 0 | 0 | 0.43 | 1.00 | 1.02 | 51% | 98% | 1% | 46% | 0.00 | **4.2** | 1.1 | 3.0/0.0/1.2/0.0/0.0 |

### Era 5

| carta | costo | res | rend | scavo | per partita | ere intatto | ere in piedi | vita sfruttata | subito | a fine partita | sepolto | vetustà | PV | PV/costo | (L/R/V/S/Sk) |
|---|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|---|
| Fondazione d'arte | 1P+2O | 2 | 0 | 0 | 0.48 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **7.8** | 1.6 | 3.0/0.0/4.8/0.0/0.0 |
| Condominio | 1P+1O | 2 | 0 | 0 | 0.69 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **7.5** | 2.5 | 2.0/0.0/5.5/0.0/0.0 |
| Caffè letterario | 0P+2O | 1 | 0 | 0 | 0.11 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **6.6** | 1.6 | 2.0/0.0/4.6/0.0/0.0 |
| Officina | 1P+1O | 2 | 0 | 0 | 0.68 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **7.4** | 2.5 | 2.0/0.0/5.4/0.0/0.0 |
| Monumento ai caduti | 1P+2O | 3 | 0 | 0 | 0.18 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **7.3** | 1.5 | 2.0/0.0/5.3/0.0/0.0 |
| Museo | 1P+3O | 3 | 0 | 0 | 0.19 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **10.2** | 1.5 | 4.0/0.0/6.2/0.0/0.0 |
| Grattacielo | 2P+4O | 3 | 0 | 0 | 0.01 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **10.2** | 1.0 | 4.0/0.0/6.2/0.0/0.0 |
| Biblioteca | 1P+3O | 3 | 0 | 0 | 0.27 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **8.3** | 1.2 | 4.0/0.0/4.3/0.0/0.0 |
| Ponte in acciaio | 1P+3O | 4 | 0 | 0 | 0.40 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **15.8** | 2.3 | 4.0/0.0/11.8/0.0/0.0 |
| Stazione | 2P+4O | 4 | 0 | 0 | 0.27 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **26.7** | 2.7 | 4.0/0.0/22.7/0.0/0.0 |
| Parco archeologico | 1P+2O | 2 | 0 | 0 | 0.44 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **16.3** | 3.3 | 2.0/0.0/14.3/0.0/0.0 |
| Università | 2P+3O | 3 | 0 | 0 | 0.44 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **18.5** | 2.3 | 4.0/0.0/14.5/0.0/0.0 |

## Due correlazioni, su chi arriva in tavola almeno 50 volte

- **resistenza stampata** → ere in piedi: r = +0.37 · → PV: r = +0.50
- **costo in pietra** → ere in piedi: r = +0.57 · → PV: r = +0.18
- **Rendita stampata** → ere in piedi: r = +0.39 · → PV: r = +0.21
- **Scavo stampato** → ere in piedi: r = +0.71 · → PV: r = -0.21

---

Rifare il conto: `godot --headless res://scenes/audit_partita.tscn -- --players 3 --vita 2500 --seed 100000` (quattro processi, semi 100000 / 102500 / 105000 / 107500).

## Cosa cambia crollando solo fallendo di 3

Le stesse misure su 10000 partite in cui si crollava in rovina fallendo l'evento di **2** e 10000 in cui ci vogliono **3**, a parità di tutto il resto: stessi semi, stessi bot, stesso numero di giocatori. La colonna Δ è la seconda meno la prima.

| misura | rovina fallendo di 2 | rovina fallendo di 3 | Δ |
|---|--:|--:|--:|
| edifici costruiti per partita | 28.68 | 28.70 | +0.03 |
| ere intatto (media) | 1.58 | 1.58 | +0.00 |
| ere in piedi (media) | 1.78 | 1.96 | +0.18 |
| cade nella sua era | 34% | 18% | −15% |
| in piedi a fine partita | 25% | 29% | +4% |
| sepolto | 57% | 57% | −0% |
| vetustà media | 0.52 | 0.50 | −0.02 |
| potenziamenti per edificio | 0.05 | 0.05 | +0.00 |
| PV per edificio | 6.9 | 7.0 | +0.1 |
| PV per partita (i tre giocatori insieme) | 198 | 200 | +2 |

| canale (PV per partita, tutti i giocatori) | rovina fallendo di 2 | rovina fallendo di 3 | Δ |
|---|--:|--:|--:|
| Lampo | 35.7 | 36.0 | +0.3 |
| Rendita | 54.0 | 54.0 | +0.0 |
| Verticalita | 78.1 | 79.6 | +1.5 |
| Scavo | 21.6 | 20.9 | −0.7 |
| Scheletri | 8.5 | 9.5 | +1.0 |

### Le carte che si cercano di più

Copie costruite per partita, prima e dopo.

| carta | era | costo | rovina fallendo di 2 | rovina fallendo di 3 | Δ | PV rovina fallendo di 2 | PV rovina fallendo di 3 |
|---|--:|--:|--:|--:|--:|--:|--:|
| Giardino all'italiana | 4 | 0P+2O | 0.39 | 0.43 | +0.04 | 4.4 | 4.2 |
| Fondazione d'arte | 5 | 1P+2O | 0.46 | 0.48 | +0.02 | 8.1 | 7.8 |
| Ponte in acciaio | 5 | 1P+3O | 0.38 | 0.40 | +0.02 | 16.2 | 15.8 |
| Parco archeologico | 5 | 1P+2O | 0.43 | 0.44 | +0.01 | 16.6 | 16.3 |
| Biblioteca | 5 | 1P+3O | 0.26 | 0.27 | +0.01 | 8.7 | 8.3 |
| Caffè letterario | 5 | 0P+2O | 0.10 | 0.11 | +0.01 | 6.6 | 6.6 |
| Università | 5 | 2P+3O | 0.43 | 0.44 | +0.01 | 18.9 | 18.5 |
| Condominio | 5 | 1P+1O | 0.68 | 0.69 | +0.00 | 7.8 | 7.5 |
| Borgo | 3 | 2P | 0.84 | 0.84 | +0.00 | 4.7 | 4.9 |
| Monumento ai caduti | 5 | 1P+2O | 0.18 | 0.18 | +0.00 | 7.8 | 7.3 |

### E quelle che si cercano di meno

Le stesse carte, dall'altro capo della classifica.

| carta | era | costo | rovina fallendo di 2 | rovina fallendo di 3 | Δ | PV rovina fallendo di 2 | PV rovina fallendo di 3 |
|---|--:|--:|--:|--:|--:|--:|--:|
| Duomo | 4 | 3P+3O | 0.53 | 0.52 | −0.02 | 10.5 | 10.3 |
| Bottega d'artista | 4 | 1P+1O | 0.66 | 0.65 | −0.01 | 4.8 | 4.7 |
| Palazzo signorile | 4 | 2P+2O | 0.68 | 0.67 | −0.01 | 6.4 | 6.4 |
| Acquedotto | 2 | 3P | 0.69 | 0.68 | −0.01 | 8.7 | 8.9 |
| Insulae | 2 | 2P | 0.55 | 0.54 | −0.01 | 3.6 | 3.7 |
| Sacello | 2 | 1P | 0.49 | 0.48 | −0.01 | 4.2 | 4.3 |
| Banco | 4 | 1P+1O | 0.55 | 0.54 | −0.01 | 3.8 | 3.7 |
| Tempio | 2 | 3P | 0.56 | 0.56 | −0.01 | 5.0 | 5.1 |
| Foro | 2 | 3P | 0.74 | 0.73 | −0.01 | 6.5 | 6.7 |
| Ponte | 2 | 3P | 0.25 | 0.25 | −0.00 | 6.5 | 6.6 |

### Carte che non arrivano quasi mai in tavola

- **Grattacielo** (era 5, 2P+4O) — una ogni 179 partite, contro una ogni 189 prima
- **Torre di vedetta** (era 2, 2P) — una ogni 110 partite, contro una ogni 114 prima
- **Trappole da pesca** (era 1, 1P) — una ogni 81 partite, contro una ogni 81 prima

