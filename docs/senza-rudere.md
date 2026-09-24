# Senza rudere: la prima misura della nuova meccanica

> La proposta del designer (`proposte/nuova-meccanica.md`, punto 11) toglie lo stato di rudere:
> restano attivo, rovina e sotterrato. Qui quel punto è misurato **da solo**, sul motore di oggi,
> prima di toccare qualsiasi altra cosa: è la D15 dell'audit. Manopola `senza_rudere` in
> `data/cards.json`, spenta; accesa con `--senza_rudere 1`. Le partite con la manopola spenta
> sono identiche al lotto di riferimento della v1.5, riga per riga.

**Il rudere si può togliere in due modi, e vanno in direzioni opposte.** Oggi chi fallisce
l'evento di 1 o 2 diventa rudere e chi fallisce di 3 crolla (`rovina_gap` 3). Senza lo stato
intermedio, il fallimento piccolo deve finire da una parte o dall'altra:

- **soglia 3, "senza rudere"**: chi fallisce di 1 o 2 **resta intatto** (senza Vetustà: non ha
  superato l'evento, l'ha scampato); chi fallisce di 3 crolla come oggi;
- **soglia 1, "ogni fallimento fa rovina"**: la lettura letterale del punto 9 della proposta
  ("se non resistono si girano sottosopra"). È `--gap 1`, senza bisogno della manopola.

## Il metodo

Tre lotti, **stessi semi**, stessi bot (StrategyBot versione 2, sei strategie a rotazione),
3 giocatori: 2 000 partite in modalità `--vita` (semi da 200000) e 750 di torneo (semi da 700000)
per variante. Il primo lotto è il gioco di oggi. Le tabelle della vita le stampa
`tools/confronta_vita.py`, quelle del torneo `tools/confronta_strategie.py`. Su 750 partite una
percentuale di vittoria ha ±5 punti di errore: sotto, è rumore.

```bash
godot --headless res://scenes/audit_partita.tscn -- --players 3 --vita 2000 --seed 200000 > con.csv
godot --headless res://scenes/audit_partita.tscn -- --players 3 --vita 2000 --seed 200000 --senza_rudere 1 > senza.csv
godot --headless res://scenes/audit_partita.tscn -- --players 3 --vita 2000 --seed 200000 --gap 1 > gap1.csv
python3 tools/confronta_vita.py con.csv senza.csv gap1.csv
```

## La vita degli edifici

| misura | oggi (rudere, rovina a −3) | senza rudere, rovina a −3 | ogni fallimento fa rovina |
|---|--:|--:|--:|
| costruiti per partita | 29,52 | 30,63 (+1,11) | 29,75 (+0,23) |
| **in piedi a fine partita** | **9,26** | **11,23 (+1,97)** | **7,08 (−2,18)** |
| intatti a fine partita | 8,57 | 11,23 (+2,66) | 7,08 (−1,50) |
| **cade nell'era in cui nasce** | **17 %** | **17 %** | **48 %** |
| ere intatto | 1,68 | 2,16 (+0,47) | 1,68 |
| ere in piedi | 2,07 | 2,16 (+0,08) | 1,68 (−0,40) |
| caduti (non più intatti) | 76 % | 63 % | 76 % |
| finiti in rovina | 69 % | 63 % | 76 % |
| **sepolti** | **51 %** | **50 %** | **51 %** |
| **Scavo per edificio sepolto** | **1,35** | **0,42 (−0,93)** | **1,46** |
| cubetti Vetustà per partita | 16,2 | 20,7 (+4,5) | 19,0 (+2,8) |
| PV delle carte per partita | 205,4 | 209,2 (+3,8) | 204,4 (−1,0) |
| di cui Rendita | 66,4 | **81,9 (+15,4)** | 65,8 (−0,6) |
| Lampo | 35,8 | 40,2 (+4,4) | 35,9 |
| Verticalità | 74,4 | 73,4 (−1,0) | 74,7 (+0,3) |
| Scavo | 20,5 | **6,5 (−14,0)** | 22,1 (+1,7) |
| Scheletri | 8,3 | 7,3 (−1,0) | 5,9 (−2,4) |

## Il torneo

Punti per giocatore, canale per canale, e vittorie per strategia.

| canale | oggi | senza rudere | ogni fallimento fa rovina |
|---|--:|--:|--:|
| Verticalità | 25,1 | 24,5 | 24,8 |
| Rendita | 22,1 | **27,2** | 21,9 |
| Lampo | 12,0 | 13,4 | 11,9 |
| Continuità | 8,9 | 9,7 | 9,2 |
| Scavo | 6,8 | **2,1** | 7,3 |
| Scheletri | 2,8 | 2,4 | 2,0 |
| PV medi | 85,7 | 88,9 | 85,2 |

| strategia | oggi | senza rudere | ogni fallimento fa rovina |
|---|--:|--:|--:|
| Rendita | 41,3 % | **46,1 %** | 42,7 % |
| Bilanciata | 38,7 % | 30,7 % | 36,3 % |
| Obiettivi | 33,6 % | 36,5 % | 36,0 % |
| Verticale | 30,7 % | **23,7 %** | 25,6 % |
| Scavo | 28,5 % | **38,9 %** | 34,4 % |
| Lampo | 27,2 % | 24,0 % | 25,1 % |

La forma del tavolo non cambia: edifici costruiti sopra un altro per giocatore 5,1 / 5,3 / 5,0,
altezza massima 3,9 in tutte e tre. Il Centro Urbano paga di più senza rudere (2,7 attivazioni
pagate per giocatore contro 1,7): con più edifici in piedi ci sono più Centri.

## Cosa salta all'occhio

**1. Senza rudere a soglia 3 l'archeologia sparisce, e non perché si seppellisca di meno.** I
sepolti restano al 50 %, ma lo Scavo per sepolto passa da 1,35 a 0,42 e il canale cade da 20,5
a 6,5 punti a partita. Il meccanismo è nelle regole di oggi: **sopra un edificio vivo non si
costruisce**, salvo il proprio, che si spiana (`was_razed`) e vale Scavo 0. Con il rudere, chi
fallisce di poco diventa una base per chiunque, e la sua sepoltura paga il proprietario. Senza,
chi fallisce di poco resta vivo e blocca la colonna agli altri: per salire si spiana il proprio,
e la memoria sotto la città vale zero. Nelle ere 1 e 2 lo Scavo per sepolto scende a 0,22 e 0,04:
quasi tutto ciò che è sotto è stato spianato dal suo padrone. Il rudere è **la porta
dell'archeologia**, non solo uno stato intermedio.

**2. Gli stessi punti si spostano sulla Rendita.** +2 edifici in piedi a fine partita, +4,5
cubetti di Vetustà, Rendita +15 per partita. Il punteggio totale sale di 4 e le vittorie vanno
alla strategia Rendita (46 %), mentre la Verticale scende sotto un quarto. Curioso: la strategia
Scavo vince di più (39 %) prendendo **meno** Scavo (2,7 punti contro 7,6): i suoi edifici, non
più ruderi, restano in piedi e pagano Rendita. Insegue un canale che non c'è più e vince per
un altro.

**3. Ogni fallimento fa rovina lascia l'equilibrio dov'è e raddoppia le morti premature.** I
canali stanno tutti entro un punto e le vittorie entro l'errore, ma gli edifici che cadono
nell'era in cui nascono passano dal 17 % al **48 %**, e a fine partita ne restano in piedi 7
invece di 9. È la stessa curva di `quanto-punisce-il-gioco.md` (soglia 2: 31 %), un gradino
più in là. Gli Scheletri perdono un quarto: meno edifici in piedi sotto cui seppellire.

## Cosa vuol dire per la proposta

Il punto 11 ("togliamo il rudere") **non è una semplificazione neutra**: la sua lettura
letterale (punto 9, ogni fallimento è rovina) rende il gioco molto più punitivo di quello che il
designer ha già giudicato troppo severo; la lettura morbida (rovina solo a −3) spegne il canale
dello Scavo, cioè metà del tema del gioco. La decisione da prendere è doppia, D15 e D16 insieme:

1. **la soglia** con un passo solo: 1, 2 o 3;
2. **se spianare un proprio edificio attivo conserva lo Scavo.** Oggi no. La proposta dice
   "sotterrato: attiva il valore di Scavo a fine gioco" senza distinguere chi l'ha sepolto: se
   vale anche per il proprio spianato, l'archeologia torna per un'altra porta. È una manopola da
   una riga (`was_razed`), e sarebbe la misura successiva.

Le manopole ci sono già tutte: `--senza_rudere 1 --gap 2` misura la soglia intermedia,
`--senza_rudere 1` con una manopola sullo spianamento misura la seconda domanda.

## Come rifare il conto

I tre lotti sono stati giocati il 24 settembre 2026 sul ramo `claude/niente-rudere` (main a
`d56bb94` più la manopola). Con gli stessi comandi del metodo escono identici, riga per riga.
