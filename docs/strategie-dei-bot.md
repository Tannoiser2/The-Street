> **Nota (registri 92 e 98).** Questo documento misura le strategie sulla v1.5. Per la v2 le spinte
> sono una tabella a parte nel bot (`SPINTE_V2`), tarata misurando (`la-terza-risorsa.md`, nona
> misura); `--spinta chiave=valore,...` la sovrascrive lotto per lotto. Per la v2 a tre risorse il
> canone e' diverso (Rendita, Lampo, Scavo, Continuita', Bilanciata, Obiettivi) ed e' misurato in
> `la-terza-risorsa.md`, terza misura.

# Le strategie dei bot

## Rimisurato col bot versione 2 e le regole di oggi

> Il resto del documento racconta il torneo su cui sono state scelte le cinque strategie, col
> bot e le regole di allora. Da allora sono cambiate tre regole — binari liberi, rovina solo
> fallendo di 3, Centro Urbano a 3 edifici — e il bot valuta le mosse dopo l'attivazione. Stesso
> torneo, **600 partite a tre giocatori, tutte e sette le strategie a rotazione**, rigiocato
> oggi:

| strategia | vittorie | PV medi | il canale che insegue | allora |
|---|--:|--:|---|--:|
| **Rendita** | **41,0%** ±6,0 | 93,0 | rendita 30,2 | 38,3% |
| **Obiettivi** | **39,5%** ±6,0 | 90,8 | monumenti 3,1 | 31,6% |
| Bilanciata | 35,7% ±5,8 | 87,7 | *nessuno: è il controllo* | 39,1% |
| Verticale | 32,2% ±5,7 | 85,3 | verticalità 29,9 | 28,7% |
| Continuità | 30,4% ±5,6 | 85,3 | continuità 12,6 | 29,2% |
| Lampo | 28,4% ±5,5 | 85,4 | lampo 21,6 | 33,9% |
| Scavo | 26,4% ±5,4 | 85,1 | scavo 7,5 | 32,6% |

**La prima conclusione non regge più.** "Chi non insegue niente vince di più" era vero allora:
la Bilanciata era prima. Oggi è terza, e prima è la Rendita.

**Merito del bot o delle regole? L'ho misurato.** Stesso torneo, stesse regole di oggi, ma col
**bot della versione 1** — rimesso in campo con `--bot 1`, e verificato identico a quello di
allora su 250 partite, riga per riga. Tre colonne: il torneo di allora, le regole nuove col bot
vecchio, le regole nuove col bot nuovo.

| strategia | allora | regole nuove, bot v1 | regole nuove, bot v2 | effetto delle regole | effetto del bot |
|---|--:|--:|--:|--:|--:|
| Rendita | 38,3% | 37,9% | **41,0%** | −0,4 | **+3,1** |
| Obiettivi | 31,6% | 34,8% | **39,5%** | **+3,2** | **+4,7** |
| Bilanciata | 39,1% | 36,4% | 35,7% | −2,7 | −0,7 |
| Verticale | 28,7% | 31,4% | 32,2% | +2,7 | +0,8 |
| Continuità | 29,2% | 33,5% | 30,4% | +4,3 | −3,1 |
| Lampo | 33,9% | **26,5%** | 28,4% | **−7,4** | +1,9 |
| Scavo | 32,6% | 32,9% | **26,4%** | +0,3 | **−6,5** |

L'errore standard di una percentuale di vittoria, su circa 257 partite per strategia, è di
**2,9 punti**, e quello di una differenza fra due tornei di circa 4: le singole voci qui sotto
sono indicazioni, non prove. Le direzioni però sono leggibili.

- **La Rendita in testa è merito del bot, non delle regole.** Con le regole nuove e il bot
  vecchio vince quanto prima (37,9% contro 38,3%). Qui avevo scritto il contrario — che le regole
  nuove, lasciando più edifici in piedi, avessero fatto della Rendita il canale vincente — ed era
  sbagliato: le regole hanno alzato i punti di Rendita — 25,4 → 29,7 per chi la insegue, ma anche
  12,1 → 14,7 per la Verticale, che la trascura — senza cambiare chi vince. È il bot che, contando cosa incassa
  attivando la colonna, gioca la Rendita meglio.
- **A perdere con le regole nuove è il Lampo** (−7,4, quasi due errori standard): con edifici
  che durano di più, i punti subito valgono meno di quelli che si accumulano. E la Bilanciata,
  che scende di 2,7.
- **Obiettivi sale per tutte e due le ragioni**: +3,2 dalle regole — più edifici in piedi da
  contare per Monumenti ed Eredità — e +4,7 dal bot, che valuta le condizioni sullo stato vero
  dopo l'attivazione. In tutto quasi otto punti, e con tutti e due i bot sta sopra la media.
- **Scavo affonda per colpa del bot migliore** (−6,5): con le regole nuove e il bot vecchio era
  nella media. Quando gli altri giocano meglio, inseguire un canale che non si può raccogliere
  costa di più.

**La seconda conclusione regge**, anche se la Verticale non è più ultima: la Rendita prende
**29,1 punti di Verticalità senza cercarla**, contro i 29,9 di chi la insegue. La Verticalità
resta un sottoprodotto del costruire, non un piano.

**La terza regge ancora di più.** La strategia Scavo prende **7,5 punti di Scavo — meno della
Lampo (9,4), che non lo cerca**. Lo Scavo lo incassa chi viene sotterrato, e a sotterrare è
l'avversario: non si può inseguire.

## Il canone adesso è di sei

**Obiettivi è entrata come sesta, senza togliere Scavo.** Obiettivi sta sopra la media con tutti
e due i bot, ed è la sola delle candidate che lo fa; Scavo resta perché è proprio misurando chi lo
insegue che si vede che lo Scavo, così com'è, non ripaga — togliendolo il difetto sparirebbe dalle
misure senza sparire dal gioco. Le prime cinque restano quelle del simulatore di riferimento, in
quell'ordine, così il confronto con lui resta possibile; la Continuità resta candidata
(`--candidate`).

Cambiare il canone cambia i bot di tutte le batterie future, quindi l'ho misurato: **10 000
partite con sei strategie contro le 10 000 con cinque**, stessi semi, stesse regole, stesso bot
(il confronto completo è in [`vita-degli-edifici.md`](vita-degli-edifici.md)).

| | 5 strategie | 6 strategie | Δ |
|---|--:|--:|--:|
| edifici costruiti per partita | 30,12 | 29,83 | −0,28 |
| in piedi a fine partita | 31% | 31% | = |
| sepolti | 52% | 52% | = |
| PV per partita (tre giocatori) | 211 | 209 | −2 |
| di cui Rendita | 65,8 | 66,2 | +0,4 |
| di cui Verticalità | 77,9 | 76,4 | −1,5 |

**Il tavolo non cambia faccia.** Un sesto dei posti passa a una strategia che costruisce per
soddisfare condizioni invece che per un canale di carta, e si vede solo come un filo di
Verticalità in meno (−1,5 punti a partita). Le misure pubblicate prima, fatte con cinque
strategie, restano confrontabili con quelle nuove entro un punto percentuale; l'intestazione di
ogni batteria ora dice quante strategie c'erano (`strategie=6`), e `impagina_vita.py` lo nomina
quando due lotti differiscono.

Il segno di Obiettivi non si vede in poche partite contro il bot a caso — un Monumento lo
prendono tutti prima o poi — ma fra bot sì: è prima per Monumenti (3,1 punti a partita) ed
Eredità (2,7). Il test fissa la preferenza stessa: su un Monumento che scatta con un edificio
largo, la carta larga vale i punti del Monumento, la stretta niente, e a Monumento già
soddisfatto non vale più niente.

---

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

> *Era la conclusione di allora, e col bot della versione 2 non regge più: Obiettivi vince
> sopra la media con tutti e due i bot ed è entrata nel canone come sesta (vedi in cima).*

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

Senza `--candidate` giocano solo le sei del canone; con `--candidate` entra anche la
Continuità, e con `--caso` torna in campo il bot casuale, che resta il metro di paragone.
L'intestazione di ogni batteria dice quante strategie c'erano al tavolo (`strategie=6`): un
lotto giocato con cinque e uno con sei non sono lo stesso esperimento.
