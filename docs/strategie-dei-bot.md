# Le strategie dei bot

## Perché cinque

Le cinque strategie del simulatore di riferimento — **Rendita, Lampo, Scavo, Verticale,
Bilanciata** — non sono cinque modi di giocare. Sono **quattro canali di punteggio più un
controllo**: ognuna tira verso una voce del conteggio, e la Bilanciata non tira da nessuna
parte, così si sa se specializzarsi conviene.

Il conteggio però di voci ne ha dieci. Su 300 partite a tre giocatori, ecco quanto pesa
ciascuna sul punteggio finale, e se qualcuno la insegue:

| canale | quota dei punti | c'è una strategia che lo insegue |
|---|--:|---|
| Verticalità | 33,8% | sì |
| Rendita | 21,3% | sì |
| Lampo | 13,3% | sì |
| Scavo | 11,9% | sì |
| **Continuità** | **8,9%** | **no** |
| Scheletri | 3,5% | no |
| Eredità | 2,3% | no |
| Monumenti | 2,0% | no |
| Effetti finali | 1,9% | no |
| Cultura | 1,2% | no |

Le cinque coprono i quattro canali grossi e lasciano scoperto il quinto: la **Continuità
pesa quanto lo Scavo** e nessuno la gioca. Poi ci sono Monumenti ed Eredità, che insieme
fanno il 4,3% ma sono l'unico canale con un *obiettivo dichiarato* da inseguire.

## Le due candidate, e cosa dicono i numeri

Ne ho scritte due fuori canone per vedere se reggono:

- **Continuità** — allunga le catene di classe in colonna. Vale la differenza fra quello
  che la colonna paga adesso e quello che pagherebbe dopo, non un premio a forfait.
- **Obiettivi** — costruisce *per finta*, poi chiede alle regole (`Conditions.met`) se la
  condizione del Monumento aperto o della propria Eredità è soddisfatta. Non ricopia i
  requisiti delle carte: li interroga, così quando i dati cambiano la strategia si adegua.

600 partite a tre giocatori, tutte e sette a rotazione di posto (ognuna ha giocato ~257
volte; l'attesa è 33,3%):

| strategia | vittorie | PV medi | il canale che insegue |
|---|--:|--:|---|
| Bilanciata | 39,1% ±6,0 | 86,2 | *nessuno: è il controllo* |
| Rendita | 38,3% ±6,0 | 86,7 | rendita 25,4 |
| Lampo | 33,9% ±5,8 | 87,6 | lampo 15,7 |
| Scavo | 32,6% ±5,7 | 83,8 | scavo 10,3 |
| **Obiettivi** | 31,6% ±5,7 | 82,8 | monumenti 2,5 |
| **Continuità** | 29,2% ±5,6 | 82,3 | continuità 8,8 |
| Verticale | 28,7% ±5,5 | 82,9 | verticalità 36,8 |

**Cinque bastano.** Le due candidate stanno in piedi — nessuna delle due è un disastro — ma
non aprono una linea nuova: finiscono in fondo, con la Verticale. I canali che lasciavano
scoperti sono troppo piccoli per costruirci un piano: inseguire i Monumenti sposta la voce
Monumenti da 2,0 a 2,5 punti, cioè mezzo punto su ottantadue.

## Tre cose che il torneo dice del gioco, non dei bot

**1. Chi non insegue niente vince di più.** La Bilanciata è prima, e tutte e sei le
specializzate stanno sotto o pari. Non è un difetto: vuol dire che nessun canale paga
abbastanza da giustificare di rinunciare agli altri — che è esattamente quello che si chiede
a un gioco a punteggio multiplo. Ma vuol dire anche che la specializzazione, in questo
impianto, **costa**.

**2. La Verticalità è il canale più grosso e la strategia Verticale è l'ultima.** Tutti
prendono 26-37 punti di Verticalità, anche chi non la cerca: è una conseguenza del
costruire, non un piano. Chi la insegue arriva a 36,8 invece di 32,4 — quattro punti in più
— e per averli rinuncia a 9 punti di Rendita (12,1 contro 21,4). Il distacco fra primo e
ultimo lo fa la Verticalità *come sottoprodotto*, non come obiettivo.

**3. Lo Scavo non è un canale che si possa inseguire.** La strategia Scavo prende 10,3 punti
di Scavo — meno della strategia Lampo, che ne prende 11,4 senza cercarlo. È nelle regole:
lo Scavo lo incassa chi viene **sotterrato**, e a sotterrare è l'avversario. Si può
seminare (costruire carte con Scavo alto e lasciarle cadere) ma non raccogliere: la mano
sull'ultimo passo ce l'ha qualcun altro. Se lo Scavo deve essere una strada vera, serve un
modo per sotterrarsi da soli — o il valore va spostato su qualcosa che dipenda da chi
costruisce.

## Come sono fatti i bot

`StrategyBot` valuta **tutte** le mosse legali e pagabili — la lista gliela dà
`AvailableActions`, nato per l'interfaccia, che dice già «cosa posso fare e quanto costa» —
con una funzione comune, e ci somma la preferenza della sua strategia. La preferenza tira in
due sensi: premia la carta che fa al caso suo e scoraggia quella che non ne fa. Col solo
premio il valutatore comune vinceva sempre, e le cinque giocavano la stessa partita.

Due scelte che cambiano l'attendibilità dei numeri:

**La sopravvivenza non è una scommessa.** La forza dell'evento è fissa per era (2, 3, 4, 5;
nell'era 5 non c'è evento), quindi «quante ere resta in piedi questo edificio» si *calcola*:
sopravvive all'era *e* se la resistenza efficace è almeno *e+1*. Un giocatore vero fa lo
stesso conto guardando la carta. Il simulatore di riferimento usava una probabilità perché
non aveva sotto le regole vere; qui ci sono.

**Niente pesi fissi.** `reference/README.md` avverte che due numeri fissi (oro 1,2 contro
pietra 0,8) avevano falsato per round interi la misura della dominanza del fiume, e che
«nessun peso fisso rappresenta bene un giocatore umano». Quindi una risorsa vale quanto la
**chiede il mercato di adesso**, diviso quanta se ne ha già in mano. E un personaggio non
vale un numero medio per tutti: le abilità sono dati strutturati e si leggono una per una —
lo Sciamano che dà +1 resistenza agli edifici Religione vale qualcosa solo se di edifici
Religione ne hai.

Cosa i bot **non** fanno: non guardano cosa stanno per fare gli altri, non bluffano, non
tengono da parte risorse per un piano a due turni, non contrastano il vicino che sta per
reclamare un Monumento. Dove il bot casuale fa 66 punti questi ne fanno 120, ma non sono
campioni: i numeri che producono sono una base solida, non un verdetto.

## Rifare i conti

```
godot --headless res://scenes/audit_partita.tscn -- --players 3 --games 600 --candidate > strat.csv
python3 tools/confronta_strategie.py strat.csv
```

Senza `--candidate` giocano solo le cinque del canone; con `--caso` torna in campo il bot
casuale, che resta il metro di paragone.
