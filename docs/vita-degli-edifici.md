# La vita degli edifici

Misurata su **10 000 partite** a 3 giocatori, rigiocate dal motore vero (`scripts/tools/audit_partita.gd`, modalità `--vita`). In tutto 373 802 edifici costruiti.

> **Avvertenza, e non è piccola.** A giocare sono i bot casuali (`RandomBot`): scelgono
> una colonna a caso e provano le azioni in ordine casuale. Nessuno protegge quello che
> ha costruito, nessuno punta a una colonna, nessuno tiene da parte l'oro per il
> restauro. Quindi questi numeri dicono **cosa fa il gioco quando nessuno lo guida**:
> sono la linea di base della carta, non il suo rendimento in mano a un giocatore.
> Le stesse tabelle rifatte quando ci saranno le cinque strategie vere diranno quanto
> pesa la testa di chi gioca.

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
| era 1 | 12 | 8.4 | 2.10 | 2.51 | 35% | 17% | 67% | 5.0 |
| era 2 | 12 | 8.3 | 1.97 | 2.46 | 24% | 23% | 59% | 5.0 |
| era 3 | 12 | 8.2 | 1.48 | 1.83 | 44% | 23% | 57% | 4.5 |
| era 4 | 12 | 7.1 | 1.13 | 1.28 | 72% | 21% | 53% | 5.8 |
| era 5 | 12 | 5.4 | 1.00 | 1.00 | 2% | 98% | 2% | 5.9 |

In media una partita mette in tavola **37.4 edifici**; di questi **32%** è ancora in piedi alla fine, **51%** finisce sotterrato e **37%** non supera l'era in cui è nato.

## Cosa salta all'occhio

**1. La Rendita è il canale che paga la durata, ed è quasi tutto.** Le 15 carte con Rendita stampata fruttano in media **9.0 PV** contro i **4.1** delle altre, e restano in piedi 2.59 ere contro 1.72. Non è una sorpresa — la Rendita si incassa a ogni censimento — ma dice che il valore di una carta lo decide quasi tutto un numero solo.

**2. La resistenza fa esattamente il suo mestiere.** Sulle ere 1-4, per ogni punto di resistenza:

| resistenza | carte | ere in piedi | cade nella sua era | PV medi |
|---|--:|--:|--:|--:|
| 1 | 7 | 1.57 | 60% | 2.8 |
| 2 | 17 | 1.71 | 56% | 4.0 |
| 3 | 14 | 2.43 | 28% | 5.8 |
| 4 | 8 | 2.77 | 19% | 7.9 |
| 5 | 2 | 2.28 | 16% | 13.4 |

Fra resistenza 1 e resistenza 4 la vita raddoppia e i punti quasi triplicano. Il salto vero è **fra 2 e 3**: è lì che un edificio smette di essere materiale da riempimento.

**3. Le carte da 1 pietra dell'era 1 non sono edifici: sono Scavo da seminare.** Approdo, Trappole da pesca, Cava, Capanne, Focolare comune vivono un'era e mezza, finiscono sotto nell'**80%** dei casi e i loro punti sono per metà Scavo. Funzionano — ma solo se chi le gioca sa che le sta seminando, non costruendo.

**4. Un edificio dell'era 5 non può morire.** Gli eventi sono solo nelle ere 1-4: chi costruisce nell'era Moderna non vedrà mai un censimento né un evento. Si vede nei numeri: vetustà **0.00**, Rendita **0.00**, Scavo **0.00**, e il **98%** ancora in piedi. Le carte dell'era 5 pagano solo Lampo e Verticalità, e vanno lette con un metro diverso dalle altre: il loro valore è tutto nell'istante in cui le metti.

**5. I colossali prendono la cima di tre colonne.** Un edificio da tre caselle conta come strato in tutte le colonne che tocca — quindi incassa il premio della cima **tre volte**:

| larghezza | carte | costruiti | PV medi | di cui Verticalità |
|---|--:|--:|--:|--:|
| XX | 41 | 295 385 | 4.3 | 0.9 |
| XX | 16 | 71 010 | 7.9 | 3.7 |
| XX | 3 | 7 407 | 12.2 | 5.7 |

Il caso limite è la **Stazione** (era 5, tre caselle, 2P+4O): **28.6 PV medi**, di cui 24.6 di sola Verticalità — più del doppio della seconda carta della lista. Arriva in tavola una volta ogni dieci partite, quindi non rompe la media, ma quando arriva decide la colonna. Vale la pena chiedersi se il premio della cima debba contare una volta per edificio invece che una volta per colonna.

## Gli estremi

### Le dodici vite più brevi

Ordinate per **vita sfruttata**, non per ere secche: se no in testa finirebbero le carte dell'era 5, che vivono una sola era perché la partita finisce, non perché crollano.

| carta | costo | res | rend | scavo | per partita | ere intatto | ere in piedi | vita sfruttata | subito | a fine partita | sepolto | vetustà | PV | PV/costo | (L/R/V/S/Sk) |
|---|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|---|
| Approdo | 1P | 1 | 0 | 2 | 0.58 | 1.13 | 1.50 | 30% | 63% | 0% | 81% | 0.17 | **2.5** | 2.5 | 0.0/0.0/0.7/1.5/0.3 |
| Trappole da pesca | 1P | 1 | 0 | 0 | 0.58 | 1.13 | 1.67 | 33% | 52% | 1% | 81% | 0.17 | **1.4** | 1.4 | 0.0/0.0/0.7/0.3/0.5 |
| Cava | 1P | 1 | 0 | 2 | 0.82 | 1.21 | 1.72 | 34% | 48% | 0% | 79% | 0.17 | **2.6** | 2.6 | 0.0/0.0/0.6/1.5/0.5 |
| Capanne | 1P | 1 | 0 | 2 | 0.83 | 1.25 | 1.75 | 35% | 51% | 1% | 78% | 0.27 | **3.5** | 3.5 | 1.0/0.0/0.6/1.4/0.4 |
| Focolare comune | 1P | 1 | 0 | 2 | 0.83 | 1.29 | 1.89 | 38% | 43% | 2% | 78% | 0.30 | **3.6** | 3.6 | 1.0/0.0/0.7/1.4/0.5 |
| Conceria | 1P | 1 | 0 | 0 | 0.63 | 1.06 | 1.17 | 39% | 85% | 2% | 77% | 0.05 | **2.0** | 2.0 | 1.0/0.0/0.8/0.1/0.1 |
| Palafitte | 1P | 2 | 0 | 2 | 0.57 | 1.66 | 2.18 | 44% | 39% | 5% | 77% | 0.60 | **3.6** | 3.6 | 1.0/0.0/0.7/1.2/0.7 |
| Sacello | 1P | 2 | 0 | 3 | 0.84 | 1.42 | 1.94 | 48% | 41% | 9% | 70% | 0.40 | **3.8** | 3.8 | 1.0/0.0/0.7/1.7/0.3 |
| Mercato | 2P | 2 | 0 | 2 | 0.64 | 1.18 | 1.46 | 49% | 64% | 7% | 73% | 0.17 | **3.4** | 1.7 | 1.0/0.0/0.9/1.4/0.1 |
| Cappella | 1P+1O | 2 | 0 | 3 | 0.79 | 1.17 | 1.47 | 49% | 63% | 9% | 67% | 0.18 | **4.8** | 1.6 | 2.0/0.0/0.8/1.9/0.1 |
| Emporio | 2P | 2 | 0 | 2 | 0.69 | 1.22 | 1.97 | 49% | 27% | 5% | 76% | 0.24 | **3.5** | 1.7 | 1.0/0.0/0.7/1.4/0.4 |
| Borgo | 2P | 2 | 0 | 2 | 0.83 | 1.19 | 1.49 | 50% | 63% | 10% | 69% | 0.19 | **4.2** | 2.1 | 2.0/0.0/0.8/1.3/0.1 |

### Le dodici che arrivano in fondo

Ordinate per vita sfruttata.

| carta | costo | res | rend | scavo | per partita | ere intatto | ere in piedi | vita sfruttata | subito | a fine partita | sepolto | vetustà | PV | PV/costo | (L/R/V/S/Sk) |
|---|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|---|
| Fondazione d'arte | 1P+2O | 2 | 0 | 0 | 0.55 | 1.00 | 1.00 | 100% | 2% | 98% | 2% | 0.00 | **4.4** | 0.9 | 3.0/0.0/1.4/0.0/0.0 |
| Condominio | 1P+1O | 2 | 0 | 0 | 0.86 | 1.00 | 1.00 | 100% | 2% | 98% | 2% | 0.00 | **3.3** | 1.1 | 2.0/0.0/1.3/0.0/0.0 |
| Caffè letterario | 0P+2O | 1 | 0 | 0 | 0.55 | 1.00 | 1.00 | 100% | 2% | 98% | 2% | 0.00 | **3.3** | 0.8 | 2.0/0.0/1.3/0.0/0.0 |
| Officina | 1P+1O | 2 | 0 | 0 | 0.86 | 1.00 | 1.00 | 100% | 3% | 97% | 3% | 0.00 | **3.3** | 1.1 | 2.0/0.0/1.3/0.0/0.0 |
| Monumento ai caduti | 1P+2O | 3 | 0 | 0 | 0.55 | 1.00 | 1.00 | 100% | 2% | 98% | 2% | 0.00 | **3.4** | 0.7 | 2.0/0.0/1.4/0.0/0.0 |
| Museo | 1P+3O | 3 | 0 | 0 | 0.36 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **9.2** | 1.3 | 4.0/0.0/5.2/0.0/0.0 |
| Grattacielo | 2P+4O | 3 | 0 | 0 | 0.17 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **11.3** | 1.1 | 4.0/0.0/7.3/0.0/0.0 |
| Biblioteca | 1P+3O | 3 | 0 | 0 | 0.38 | 1.00 | 1.00 | 100% | 3% | 97% | 3% | 0.00 | **5.4** | 0.8 | 4.0/0.0/1.4/0.0/0.0 |
| Ponte in acciaio | 1P+3O | 4 | 0 | 0 | 0.26 | 1.00 | 1.00 | 100% | 4% | 96% | 3% | 0.00 | **8.0** | 1.1 | 4.0/0.0/4.0/0.0/0.0 |
| Stazione | 2P+4O | 4 | 0 | 0 | 0.10 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **28.6** | 2.9 | 4.0/0.0/24.6/0.0/0.0 |
| Parco archeologico | 1P+2O | 2 | 0 | 0 | 0.51 | 1.00 | 1.00 | 100% | 4% | 96% | 3% | 0.00 | **5.6** | 1.1 | 2.0/0.0/3.6/0.0/0.0 |
| Università | 2P+3O | 3 | 0 | 0 | 0.26 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **18.0** | 2.3 | 4.0/0.0/14.0/0.0/0.0 |

### Le dodici che rendono di più

Ordinate per PV medi fruttati al proprietario.

| carta | costo | res | rend | scavo | per partita | ere intatto | ere in piedi | vita sfruttata | subito | a fine partita | sepolto | vetustà | PV | PV/costo | (L/R/V/S/Sk) |
|---|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|---|
| Stazione | 2P+4O | 4 | 0 | 0 | 0.10 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **28.6** | 2.9 | 4.0/0.0/24.6/0.0/0.0 |
| Università | 2P+3O | 3 | 0 | 0 | 0.26 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **18.0** | 2.3 | 4.0/0.0/14.0/0.0/0.0 |
| Fortezza bastionata | 3P+2O | 5 | 3 | 2 | 0.33 | 1.84 | 1.96 | 98% | 4% | 73% | 10% | 0.84 | **16.3** | 2.3 | 0.0/6.2/10.1/0.0/0.0 |
| Duomo | 3P+3O | 4 | 4 | 5 | 0.29 | 1.35 | 1.69 | 85% | 31% | 44% | 18% | 0.35 | **14.6** | 1.6 | 0.0/3.5/10.4/0.7/0.0 |
| Castello | 2P+1O | 4 | 3 | 3 | 0.41 | 2.26 | 2.46 | 82% | 5% | 39% | 37% | 1.26 | **13.5** | 3.4 | 0.0/7.4/5.6/0.2/0.2 |
| Menhir | 2P | 4 | 1 | 3 | 0.76 | 3.56 | 3.82 | 76% | 15% | 50% | 42% | 2.08 | **11.5** | 5.8 | 0.0/9.9/0.6/0.5/0.5 |
| Grattacielo | 2P+4O | 3 | 0 | 0 | 0.17 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **11.3** | 1.1 | 4.0/0.0/7.3/0.0/0.0 |
| Anfiteatro | 5P | 5 | 2 | 6 | 0.34 | 2.57 | 2.58 | 64% | 28% | 34% | 47% | 1.56 | **10.6** | 2.1 | 0.0/7.7/2.6/0.0/0.3 |
| Piazza monumentale | 2P+2O | 3 | 2 | 3 | 0.36 | 1.21 | 1.42 | 71% | 58% | 27% | 20% | 0.21 | **10.5** | 1.7 | 0.0/1.3/8.6/0.5/0.0 |
| Circolo di pietre | 3P | 4 | 1 | 5 | 0.58 | 3.06 | 3.15 | 63% | 26% | 39% | 50% | 1.72 | **9.9** | 3.3 | 0.0/8.0/1.4/0.1/0.3 |
| Dolmen | 2P | 3 | 1 | 3 | 0.86 | 3.07 | 3.44 | 69% | 17% | 33% | 55% | 1.61 | **9.4** | 4.7 | 0.0/7.2/0.6/0.8/0.7 |
| Museo | 1P+3O | 3 | 0 | 0 | 0.36 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **9.2** | 1.3 | 4.0/0.0/5.2/0.0/0.0 |

### Le dodici che rendono di più per quello che costano

Ordinate per PV diviso il costo in pietra equivalente.

| carta | costo | res | rend | scavo | per partita | ere intatto | ere in piedi | vita sfruttata | subito | a fine partita | sepolto | vetustà | PV | PV/costo | (L/R/V/S/Sk) |
|---|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|---|
| Menhir | 2P | 4 | 1 | 3 | 0.76 | 3.56 | 3.82 | 76% | 15% | 50% | 42% | 2.08 | **11.5** | 5.8 | 0.0/9.9/0.6/0.5/0.5 |
| Dolmen | 2P | 3 | 1 | 3 | 0.86 | 3.07 | 3.44 | 69% | 17% | 33% | 55% | 1.61 | **9.4** | 4.7 | 0.0/7.2/0.6/0.8/0.7 |
| Grotte dipinte | 1P | 2 | 0 | 6 | 0.87 | 2.57 | 3.06 | 61% | 17% | 17% | 65% | 1.26 | **4.3** | 4.3 | 0.0/0.1/0.6/2.7/0.9 |
| Sacello | 1P | 2 | 0 | 3 | 0.84 | 1.42 | 1.94 | 48% | 41% | 9% | 70% | 0.40 | **3.8** | 3.8 | 1.0/0.0/0.7/1.7/0.3 |
| Palafitte | 1P | 2 | 0 | 2 | 0.57 | 1.66 | 2.18 | 44% | 39% | 5% | 77% | 0.60 | **3.6** | 3.6 | 1.0/0.0/0.7/1.2/0.7 |
| Focolare comune | 1P | 1 | 0 | 2 | 0.83 | 1.29 | 1.89 | 38% | 43% | 2% | 78% | 0.30 | **3.6** | 3.6 | 1.0/0.0/0.7/1.4/0.5 |
| Capanne | 1P | 1 | 0 | 2 | 0.83 | 1.25 | 1.75 | 35% | 51% | 1% | 78% | 0.27 | **3.5** | 3.5 | 1.0/0.0/0.6/1.4/0.4 |
| Castello | 2P+1O | 4 | 3 | 3 | 0.41 | 2.26 | 2.46 | 82% | 5% | 39% | 37% | 1.26 | **13.5** | 3.4 | 0.0/7.4/5.6/0.2/0.2 |
| Circolo di pietre | 3P | 4 | 1 | 5 | 0.58 | 3.06 | 3.15 | 63% | 26% | 39% | 50% | 1.72 | **9.9** | 3.3 | 0.0/8.0/1.4/0.1/0.3 |
| Acquedotto | 3P | 4 | 1 | 3 | 0.30 | 2.40 | 2.46 | 61% | 37% | 35% | 48% | 1.38 | **8.2** | 2.7 | 0.0/5.4/2.6/0.0/0.2 |
| Cava | 1P | 1 | 0 | 2 | 0.82 | 1.21 | 1.72 | 34% | 48% | 0% | 79% | 0.17 | **2.6** | 2.6 | 0.0/0.0/0.6/1.5/0.5 |
| Teatro | 2P | 3 | 0 | 5 | 0.96 | 2.30 | 2.84 | 71% | 11% | 29% | 54% | 1.17 | **5.1** | 2.5 | 2.0/0.1/0.7/1.8/0.4 |

### Le dodici che rendono di meno

Solo carte che arrivano in tavola almeno una volta ogni cinque partite: una carta rara ha medie ballerine.

| carta | costo | res | rend | scavo | per partita | ere intatto | ere in piedi | vita sfruttata | subito | a fine partita | sepolto | vetustà | PV | PV/costo | (L/R/V/S/Sk) |
|---|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|---|
| Trappole da pesca | 1P | 1 | 0 | 0 | 0.58 | 1.13 | 1.67 | 33% | 52% | 1% | 81% | 0.17 | **1.4** | 1.4 | 0.0/0.0/0.7/0.3/0.5 |
| Conceria | 1P | 1 | 0 | 0 | 0.63 | 1.06 | 1.17 | 39% | 85% | 2% | 77% | 0.05 | **2.0** | 2.0 | 1.0/0.0/0.8/0.1/0.1 |
| Mura | 2P | 4 | 0 | 2 | 0.89 | 2.31 | 2.67 | 89% | 7% | 67% | 26% | 1.22 | **2.3** | 1.2 | 1.0/0.1/0.8/0.3/0.1 |
| Approdo | 1P | 1 | 0 | 2 | 0.58 | 1.13 | 1.50 | 30% | 63% | 0% | 81% | 0.17 | **2.5** | 2.5 | 0.0/0.0/0.7/1.5/0.3 |
| Cava | 1P | 1 | 0 | 2 | 0.82 | 1.21 | 1.72 | 34% | 48% | 0% | 79% | 0.17 | **2.6** | 2.6 | 0.0/0.0/0.6/1.5/0.5 |
| Torre di vedetta | 2P | 3 | 0 | 2 | 0.84 | 2.32 | 2.90 | 72% | 12% | 36% | 52% | 1.23 | **2.9** | 1.4 | 1.0/0.1/0.7/0.6/0.4 |
| Banco | 1P+1O | 2 | 0 | 0 | 0.89 | 1.05 | 1.15 | 57% | 85% | 11% | 63% | 0.05 | **3.0** | 1.0 | 2.0/0.0/0.9/0.0/0.0 |
| Condominio | 1P+1O | 2 | 0 | 0 | 0.86 | 1.00 | 1.00 | 100% | 2% | 98% | 2% | 0.00 | **3.3** | 1.1 | 2.0/0.0/1.3/0.0/0.0 |
| Castrum | 3P | 4 | 0 | 3 | 0.58 | 2.91 | 2.94 | 74% | 22% | 51% | 40% | 1.87 | **3.3** | 1.1 | 1.0/0.3/1.7/0.0/0.2 |
| Mulino | 2P | 2 | 0 | 2 | 0.66 | 1.24 | 1.60 | 53% | 53% | 11% | 71% | 0.24 | **3.3** | 1.7 | 1.0/0.0/0.8/1.3/0.2 |
| Officina | 1P+1O | 2 | 0 | 0 | 0.86 | 1.00 | 1.00 | 100% | 3% | 97% | 3% | 0.00 | **3.3** | 1.1 | 2.0/0.0/1.3/0.0/0.0 |
| Caffè letterario | 0P+2O | 1 | 0 | 0 | 0.55 | 1.00 | 1.00 | 100% | 2% | 98% | 2% | 0.00 | **3.3** | 0.8 | 2.0/0.0/1.3/0.0/0.0 |

### Le dodici più sepolte

Ordinate per quota di copie finite sotto un altro edificio.

| carta | costo | res | rend | scavo | per partita | ere intatto | ere in piedi | vita sfruttata | subito | a fine partita | sepolto | vetustà | PV | PV/costo | (L/R/V/S/Sk) |
|---|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|---|
| Approdo | 1P | 1 | 0 | 2 | 0.58 | 1.13 | 1.50 | 30% | 63% | 0% | 81% | 0.17 | **2.5** | 2.5 | 0.0/0.0/0.7/1.5/0.3 |
| Trappole da pesca | 1P | 1 | 0 | 0 | 0.58 | 1.13 | 1.67 | 33% | 52% | 1% | 81% | 0.17 | **1.4** | 1.4 | 0.0/0.0/0.7/0.3/0.5 |
| Cava | 1P | 1 | 0 | 2 | 0.82 | 1.21 | 1.72 | 34% | 48% | 0% | 79% | 0.17 | **2.6** | 2.6 | 0.0/0.0/0.6/1.5/0.5 |
| Capanne | 1P | 1 | 0 | 2 | 0.83 | 1.25 | 1.75 | 35% | 51% | 1% | 78% | 0.27 | **3.5** | 3.5 | 1.0/0.0/0.6/1.4/0.4 |
| Focolare comune | 1P | 1 | 0 | 2 | 0.83 | 1.29 | 1.89 | 38% | 43% | 2% | 78% | 0.30 | **3.6** | 3.6 | 1.0/0.0/0.7/1.4/0.5 |
| Palafitte | 1P | 2 | 0 | 2 | 0.57 | 1.66 | 2.18 | 44% | 39% | 5% | 77% | 0.60 | **3.6** | 3.6 | 1.0/0.0/0.7/1.2/0.7 |
| Conceria | 1P | 1 | 0 | 0 | 0.63 | 1.06 | 1.17 | 39% | 85% | 2% | 77% | 0.05 | **2.0** | 2.0 | 1.0/0.0/0.8/0.1/0.1 |
| Emporio | 2P | 2 | 0 | 2 | 0.69 | 1.22 | 1.97 | 49% | 27% | 5% | 76% | 0.24 | **3.5** | 1.7 | 1.0/0.0/0.7/1.4/0.4 |
| Mercato | 2P | 2 | 0 | 2 | 0.64 | 1.18 | 1.46 | 49% | 64% | 7% | 73% | 0.17 | **3.4** | 1.7 | 1.0/0.0/0.9/1.4/0.1 |
| Insulae | 2P | 2 | 0 | 2 | 0.87 | 1.50 | 2.08 | 52% | 29% | 8% | 71% | 0.47 | **3.4** | 1.7 | 1.0/0.0/0.8/1.2/0.4 |
| Giardino all'italiana | 0P+2O | 1 | 0 | 0 | 0.57 | 1.01 | 1.05 | 52% | 95% | 3% | 71% | 0.01 | **4.0** | 1.0 | 3.0/0.0/0.9/0.0/0.0 |
| Mulino | 2P | 2 | 0 | 2 | 0.66 | 1.24 | 1.60 | 53% | 53% | 11% | 71% | 0.24 | **3.3** | 1.7 | 1.0/0.0/0.8/1.3/0.2 |

## Tutte le carte, era per era

### Era 1

| carta | costo | res | rend | scavo | per partita | ere intatto | ere in piedi | vita sfruttata | subito | a fine partita | sepolto | vetustà | PV | PV/costo | (L/R/V/S/Sk) |
|---|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|---|
| Menhir | 2P | 4 | 1 | 3 | 0.76 | 3.56 | 3.82 | 76% | 15% | 50% | 42% | 2.08 | **11.5** | 5.8 | 0.0/9.9/0.6/0.5/0.5 |
| Dolmen | 2P | 3 | 1 | 3 | 0.86 | 3.07 | 3.44 | 69% | 17% | 33% | 55% | 1.61 | **9.4** | 4.7 | 0.0/7.2/0.6/0.8/0.7 |
| Circolo di pietre | 3P | 4 | 1 | 5 | 0.58 | 3.06 | 3.15 | 63% | 26% | 39% | 50% | 1.72 | **9.9** | 3.3 | 0.0/8.0/1.4/0.1/0.3 |
| Tumulo funerario | 2P | 3 | 0 | 5 | 0.58 | 2.86 | 3.06 | 61% | 28% | 33% | 51% | 1.49 | **3.4** | 1.7 | 1.0/0.2/1.3/0.4/0.4 |
| Grotte dipinte | 1P | 2 | 0 | 6 | 0.87 | 2.57 | 3.06 | 61% | 17% | 17% | 65% | 1.26 | **4.3** | 4.3 | 0.0/0.1/0.6/2.7/0.9 |
| Villaggio palizzato | 2P | 2 | 0 | 2 | 0.56 | 2.27 | 2.71 | 54% | 30% | 21% | 61% | 1.10 | **3.4** | 1.7 | 1.0/0.1/1.4/0.4/0.5 |
| Palafitte | 1P | 2 | 0 | 2 | 0.57 | 1.66 | 2.18 | 44% | 39% | 5% | 77% | 0.60 | **3.6** | 3.6 | 1.0/0.0/0.7/1.2/0.7 |
| Focolare comune | 1P | 1 | 0 | 2 | 0.83 | 1.29 | 1.89 | 38% | 43% | 2% | 78% | 0.30 | **3.6** | 3.6 | 1.0/0.0/0.7/1.4/0.5 |
| Capanne | 1P | 1 | 0 | 2 | 0.83 | 1.25 | 1.75 | 35% | 51% | 1% | 78% | 0.27 | **3.5** | 3.5 | 1.0/0.0/0.6/1.4/0.4 |
| Cava | 1P | 1 | 0 | 2 | 0.82 | 1.21 | 1.72 | 34% | 48% | 0% | 79% | 0.17 | **2.6** | 2.6 | 0.0/0.0/0.6/1.5/0.5 |
| Trappole da pesca | 1P | 1 | 0 | 0 | 0.58 | 1.13 | 1.67 | 33% | 52% | 1% | 81% | 0.17 | **1.4** | 1.4 | 0.0/0.0/0.7/0.3/0.5 |
| Approdo | 1P | 1 | 0 | 2 | 0.58 | 1.13 | 1.50 | 30% | 63% | 0% | 81% | 0.17 | **2.5** | 2.5 | 0.0/0.0/0.7/1.5/0.3 |

### Era 2

| carta | costo | res | rend | scavo | per partita | ere intatto | ere in piedi | vita sfruttata | subito | a fine partita | sepolto | vetustà | PV | PV/costo | (L/R/V/S/Sk) |
|---|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|---|
| Castrum | 3P | 4 | 0 | 3 | 0.58 | 2.91 | 2.94 | 74% | 22% | 51% | 40% | 1.87 | **3.3** | 1.1 | 1.0/0.3/1.7/0.0/0.2 |
| Torre di vedetta | 2P | 3 | 0 | 2 | 0.84 | 2.32 | 2.90 | 72% | 12% | 36% | 52% | 1.23 | **2.9** | 1.4 | 1.0/0.1/0.7/0.6/0.4 |
| Teatro | 2P | 3 | 0 | 5 | 0.96 | 2.30 | 2.84 | 71% | 11% | 29% | 54% | 1.17 | **5.1** | 2.5 | 2.0/0.1/0.7/1.8/0.4 |
| Ponte | 3P | 3 | 1 | 3 | 0.50 | 2.18 | 2.67 | 67% | 22% | 34% | 49% | 1.18 | **7.1** | 2.4 | 0.0/4.6/1.7/0.5/0.3 |
| Tempio | 3P | 3 | 1 | 3 | 0.84 | 2.11 | 2.66 | 66% | 18% | 27% | 58% | 1.06 | **6.2** | 2.1 | 0.0/3.9/0.7/1.2/0.4 |
| Foro | 3P | 3 | 1 | 5 | 0.59 | 2.18 | 2.65 | 66% | 22% | 31% | 51% | 1.20 | **7.4** | 2.5 | 0.0/4.6/1.7/0.8/0.4 |
| Anfiteatro | 5P | 5 | 2 | 6 | 0.34 | 2.57 | 2.58 | 64% | 28% | 34% | 47% | 1.56 | **10.6** | 2.1 | 0.0/7.7/2.6/0.0/0.3 |
| Acquedotto | 3P | 4 | 1 | 3 | 0.30 | 2.40 | 2.46 | 61% | 37% | 35% | 48% | 1.38 | **8.2** | 2.7 | 0.0/5.4/2.6/0.0/0.2 |
| Terme | 2P | 2 | 0 | 3 | 0.97 | 1.51 | 2.11 | 53% | 29% | 10% | 67% | 0.48 | **4.7** | 2.4 | 2.0/0.0/0.7/1.7/0.3 |
| Insulae | 2P | 2 | 0 | 2 | 0.87 | 1.50 | 2.08 | 52% | 29% | 8% | 71% | 0.47 | **3.4** | 1.7 | 1.0/0.0/0.8/1.2/0.4 |
| Emporio | 2P | 2 | 0 | 2 | 0.69 | 1.22 | 1.97 | 49% | 27% | 5% | 76% | 0.24 | **3.5** | 1.7 | 1.0/0.0/0.7/1.4/0.4 |
| Sacello | 1P | 2 | 0 | 3 | 0.84 | 1.42 | 1.94 | 48% | 41% | 9% | 70% | 0.40 | **3.8** | 3.8 | 1.0/0.0/0.7/1.7/0.3 |

### Era 3

| carta | costo | res | rend | scavo | per partita | ere intatto | ere in piedi | vita sfruttata | subito | a fine partita | sepolto | vetustà | PV | PV/costo | (L/R/V/S/Sk) |
|---|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|---|
| Mura | 2P | 4 | 0 | 2 | 0.89 | 2.31 | 2.67 | 89% | 7% | 67% | 26% | 1.22 | **2.3** | 1.2 | 1.0/0.1/0.8/0.3/0.1 |
| Castello | 2P+1O | 4 | 3 | 3 | 0.41 | 2.26 | 2.46 | 82% | 5% | 39% | 37% | 1.26 | **13.5** | 3.4 | 0.0/7.4/5.6/0.2/0.2 |
| Torre civica | 2P | 3 | 0 | 2 | 0.89 | 1.58 | 2.16 | 72% | 24% | 35% | 49% | 0.56 | **3.8** | 1.9 | 2.0/0.1/0.8/0.8/0.2 |
| Arsenale | 3P+1O | 3 | 0 | 2 | 0.45 | 1.69 | 2.10 | 70% | 30% | 36% | 42% | 0.72 | **4.9** | 1.0 | 2.0/0.1/2.2/0.5/0.1 |
| Abbazia | 2P+2O | 3 | 3 | 5 | 0.39 | 1.60 | 2.08 | 69% | 29% | 33% | 42% | 0.63 | **8.0** | 1.3 | 0.0/4.3/2.1/1.5/0.1 |
| Chiesa | 2P+1O | 3 | 2 | 3 | 0.80 | 1.49 | 1.96 | 65% | 33% | 25% | 56% | 0.47 | **4.8** | 1.2 | 0.0/2.4/0.8/1.5/0.2 |
| Mulino | 2P | 2 | 0 | 2 | 0.66 | 1.24 | 1.60 | 53% | 53% | 11% | 71% | 0.24 | **3.3** | 1.7 | 1.0/0.0/0.8/1.3/0.2 |
| Ospedale dei pellegrini | 2P+1O | 2 | 0 | 2 | 0.80 | 1.19 | 1.50 | 50% | 61% | 10% | 66% | 0.19 | **4.2** | 1.0 | 2.0/0.0/0.8/1.3/0.1 |
| Borgo | 2P | 2 | 0 | 2 | 0.83 | 1.19 | 1.49 | 50% | 63% | 10% | 69% | 0.19 | **4.2** | 2.1 | 2.0/0.0/0.8/1.3/0.1 |
| Cappella | 1P+1O | 2 | 0 | 3 | 0.79 | 1.17 | 1.47 | 49% | 63% | 9% | 67% | 0.18 | **4.8** | 1.6 | 2.0/0.0/0.8/1.9/0.1 |
| Mercato | 2P | 2 | 0 | 2 | 0.64 | 1.18 | 1.46 | 49% | 64% | 7% | 73% | 0.17 | **3.4** | 1.7 | 1.0/0.0/0.9/1.4/0.1 |
| Conceria | 1P | 1 | 0 | 0 | 0.63 | 1.06 | 1.17 | 39% | 85% | 2% | 77% | 0.05 | **2.0** | 2.0 | 1.0/0.0/0.8/0.1/0.1 |

### Era 4

| carta | costo | res | rend | scavo | per partita | ere intatto | ere in piedi | vita sfruttata | subito | a fine partita | sepolto | vetustà | PV | PV/costo | (L/R/V/S/Sk) |
|---|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|---|
| Fortezza bastionata | 3P+2O | 5 | 3 | 2 | 0.33 | 1.84 | 1.96 | 98% | 4% | 73% | 10% | 0.84 | **16.3** | 2.3 | 0.0/6.2/10.1/0.0/0.0 |
| Ponte monumentale | 2P+2O | 4 | 3 | 3 | 0.46 | 1.33 | 1.69 | 85% | 31% | 55% | 27% | 0.33 | **6.5** | 1.1 | 0.0/3.1/2.7/0.6/0.0 |
| Duomo | 3P+3O | 4 | 4 | 5 | 0.29 | 1.35 | 1.69 | 85% | 31% | 44% | 18% | 0.35 | **14.6** | 1.6 | 0.0/3.5/10.4/0.7/0.0 |
| Villa | 2P+2O | 3 | 0 | 3 | 0.56 | 1.13 | 1.45 | 72% | 55% | 34% | 49% | 0.13 | **6.4** | 1.1 | 4.0/0.0/1.0/1.4/0.0 |
| Piazza monumentale | 2P+2O | 3 | 2 | 3 | 0.36 | 1.21 | 1.42 | 71% | 58% | 27% | 20% | 0.21 | **10.5** | 1.7 | 0.0/1.3/8.6/0.5/0.0 |
| Palazzo signorile | 2P+2O | 3 | 0 | 3 | 0.61 | 1.12 | 1.33 | 67% | 67% | 26% | 54% | 0.12 | **5.5** | 0.9 | 3.0/0.0/1.0/1.5/0.0 |
| Banco | 1P+1O | 2 | 0 | 0 | 0.89 | 1.05 | 1.15 | 57% | 85% | 11% | 63% | 0.05 | **3.0** | 1.0 | 2.0/0.0/0.9/0.0/0.0 |
| Osservatorio | 1P+2O | 2 | 0 | 2 | 0.55 | 1.05 | 1.13 | 57% | 87% | 11% | 64% | 0.05 | **4.2** | 0.8 | 2.0/0.0/1.0/1.2/0.0 |
| Loggia | 1P+1O | 2 | 0 | 2 | 0.88 | 1.04 | 1.13 | 56% | 87% | 10% | 63% | 0.04 | **4.2** | 1.4 | 2.0/0.0/0.9/1.2/0.0 |
| Bottega d'artista | 1P+1O | 2 | 0 | 2 | 0.89 | 1.03 | 1.11 | 56% | 89% | 9% | 64% | 0.03 | **4.2** | 1.4 | 2.0/0.0/0.9/1.3/0.0 |
| Accademia | 1P+2O | 2 | 0 | 3 | 0.68 | 1.02 | 1.09 | 55% | 91% | 7% | 65% | 0.02 | **4.8** | 1.0 | 2.0/0.0/0.9/1.9/0.0 |
| Giardino all'italiana | 0P+2O | 1 | 0 | 0 | 0.57 | 1.01 | 1.05 | 52% | 95% | 3% | 71% | 0.01 | **4.0** | 1.0 | 3.0/0.0/0.9/0.0/0.0 |

### Era 5

| carta | costo | res | rend | scavo | per partita | ere intatto | ere in piedi | vita sfruttata | subito | a fine partita | sepolto | vetustà | PV | PV/costo | (L/R/V/S/Sk) |
|---|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|---|
| Fondazione d'arte | 1P+2O | 2 | 0 | 0 | 0.55 | 1.00 | 1.00 | 100% | 2% | 98% | 2% | 0.00 | **4.4** | 0.9 | 3.0/0.0/1.4/0.0/0.0 |
| Condominio | 1P+1O | 2 | 0 | 0 | 0.86 | 1.00 | 1.00 | 100% | 2% | 98% | 2% | 0.00 | **3.3** | 1.1 | 2.0/0.0/1.3/0.0/0.0 |
| Caffè letterario | 0P+2O | 1 | 0 | 0 | 0.55 | 1.00 | 1.00 | 100% | 2% | 98% | 2% | 0.00 | **3.3** | 0.8 | 2.0/0.0/1.3/0.0/0.0 |
| Officina | 1P+1O | 2 | 0 | 0 | 0.86 | 1.00 | 1.00 | 100% | 3% | 97% | 3% | 0.00 | **3.3** | 1.1 | 2.0/0.0/1.3/0.0/0.0 |
| Monumento ai caduti | 1P+2O | 3 | 0 | 0 | 0.55 | 1.00 | 1.00 | 100% | 2% | 98% | 2% | 0.00 | **3.4** | 0.7 | 2.0/0.0/1.4/0.0/0.0 |
| Museo | 1P+3O | 3 | 0 | 0 | 0.36 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **9.2** | 1.3 | 4.0/0.0/5.2/0.0/0.0 |
| Grattacielo | 2P+4O | 3 | 0 | 0 | 0.17 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **11.3** | 1.1 | 4.0/0.0/7.3/0.0/0.0 |
| Biblioteca | 1P+3O | 3 | 0 | 0 | 0.38 | 1.00 | 1.00 | 100% | 3% | 97% | 3% | 0.00 | **5.4** | 0.8 | 4.0/0.0/1.4/0.0/0.0 |
| Ponte in acciaio | 1P+3O | 4 | 0 | 0 | 0.26 | 1.00 | 1.00 | 100% | 4% | 96% | 3% | 0.00 | **8.0** | 1.1 | 4.0/0.0/4.0/0.0/0.0 |
| Stazione | 2P+4O | 4 | 0 | 0 | 0.10 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **28.6** | 2.9 | 4.0/0.0/24.6/0.0/0.0 |
| Parco archeologico | 1P+2O | 2 | 0 | 0 | 0.51 | 1.00 | 1.00 | 100% | 4% | 96% | 3% | 0.00 | **5.6** | 1.1 | 2.0/0.0/3.6/0.0/0.0 |
| Università | 2P+3O | 3 | 0 | 0 | 0.26 | 1.00 | 1.00 | 100% | 0% | 100% | 0% | 0.00 | **18.0** | 2.3 | 4.0/0.0/14.0/0.0/0.0 |

## Due correlazioni, su chi arriva in tavola almeno 50 volte

- **resistenza stampata** → ere in piedi: r = +0.38 · → PV: r = +0.62
- **costo in pietra** → ere in piedi: r = +0.55 · → PV: r = +0.39
- **Rendita stampata** → ere in piedi: r = +0.25 · → PV: r = +0.46
- **Scavo stampato** → ere in piedi: r = +0.70 · → PV: r = +0.06

---

Rifare il conto: `godot --headless res://scenes/audit_partita.tscn -- --players 3 --vita 2500 --seed 100000` (quattro processi, semi 100000 / 102500 / 105000 / 107500).

