# Il bot che pianifica l'era

> `scripts/ai/planning_bot.gd`. Torneo giocato con `audit_partita.gd --piano --tutti <strategia>`:
> in ogni partita i tre giocatori seguono **la stessa strategia** e **uno solo pianifica**, a
> rotazione di posto. Così l'effetto del *pianificare* si separa da quello della *strategia*:
> stessi bot, stesse preferenze, uno solo guarda avanti.

## Cosa fa

I bot di tutti i giorni (`StrategyBot`) sono **avidi**: a ogni turno scelgono la mossa che vale di
più adesso. Il pianificatore usa **lo stesso valutatore** — le stesse voci, la stessa spinta della
strategia — ma invece della mossa migliore cerca **la sequenza migliore** per i lavoratori che gli
restano nell'era: costruire una base col primo per salirci col terzo, tenersi l'oro per la carta
cara invece di spenderlo subito, mettere il secondo edificio dove la classe c'è già.

È una **ricerca a fascio**: da ogni stato si provano le 2 colonne migliori e in ciascuna le 3
mosse migliori, si tengono le 4 sequenze che valgono di più e si va avanti di un lavoratore, fino
a 3. Il futuro vale un po' meno del presente (0,8 a passo). Si esegue **solo il primo passo** della
sequenza vincente, e al turno dopo si ripianifica da capo.

Tutto si prova su **copie della partita**, giocate col codice vero: nessuna regola è riscritta nel
pianificatore.

**L'ipotesi, detta chiara:** pianificando il bot fa finta che gli avversari stiano fermi — dopo
ogni sua mossa simulata il turno torna a lui. È ottimista, e lo sa: per questo esegue un passo
solo e ripianifica.

## Il primo torneo: 3% di vittorie

1500 partite, 300 per strategia:

| strategia | pianificatore | avidi | Δ | vince |
|---|--:|--:|--:|--:|
| bilanciata | 47,5 | 85,4 | −37,9 | 3% |
| lampo | 52,9 | 90,3 | −37,5 | 2% |
| rendita | 44,1 | 82,0 | −37,9 | 3% |
| scavo | 54,8 | 94,2 | −39,5 | 4% |
| verticale | 46,1 | 82,6 | −36,5 | 5% |
| **tutte** | **49,1** | **86,9** | **−37,9** | **4%** (atteso 33%) |

Un pianificatore che usa lo stesso valutatore dell'avido, più la previsione, **non può essere
peggiore dell'avido per costruzione**: la mossa avida è sempre fra quelle che esplora. Un risultato
così non è un risultato, è un difetto — e i numeri lo indicavano: costruiva **5,45 edifici contro
10,05**, e il **64% dei suoi turni cominciava stando fermo**.

**La causa** non era nel pianificatore. La colonna attivata nel turno — quella che decide dove si
può costruire, potenziare, restaurare — stava nel `GameController`, non nello stato della partita.
Una copia presa a metà turno non se la portava dietro, e su un controller nuovo **ogni costruzione
simulata falliva in silenzio**. Il pianificatore poteva simulare solo reclutamenti e Dinastia, e ne
concludeva che stare fermi fosse la mossa migliore. Spostata nello stato (`gs.colonna_attivata`),
il bot avido gioca **identico, partita per partita**, e il pianificatore sta fermo l'1% dei turni.

Con l'occasione, due correzioni che restano giuste comunque: si sta fermi **solo se non c'è niente
da fare**, come fa l'avido — nel mondo immobile della simulazione rimandare a un passo sempre più
ricco sembra sempre meglio, e ripianificando si rimanda ancora — e il futuro vale **0,8** del
presente, perché intanto gli avversari prendono le carte e le caselle.

## Il torneo vero

1000 partite, 200 per strategia, stessi semi del primo:

| strategia | pianificatore | avidi | Δ | vince |
|---|--:|--:|--:|--:|
| bilanciata | 87,4 | 85,1 | +2,3 | 36% |
| lampo | 89,3 | 88,3 | +1,0 | 36% |
| rendita | 81,7 | 78,6 | +3,1 | 34% |
| scavo | 94,0 | 92,8 | +1,2 | 38% |
| verticale | 84,0 | 81,4 | +2,7 | 36% |
| **tutte** | **87,3** | **85,3** | **+2,1** | **36%** (atteso 33%) |

**Pianificare aiuta, ma poco.** La differenza appaiata è **+2,05 PV a partita**, con un errore
standard di 0,78: 2,6 errori standard da zero, quindi reale. Le vittorie — 36% contro il 33,3% di
un giocatore qualsiasi — sono a 1,8 errori standard: suggestive, non una prova. Quello che la
rende credibile è che il segno è **positivo in tutte e cinque le strategie**.

## Cosa vuol dire per il gioco

Il confronto che conta è con l'altro miglioramento del bot, fatto poco prima: far valutare le mosse
**sullo stato dopo l'attivazione** — cioè contare cosa si incassa piazzando il lavoratore — valeva
**+3,5 PV a giocatore**, da solo, senza nessuna previsione. **Leggere bene il turno vale più che
pianificare l'era.**

Ci sono ragioni che stanno nel regolamento:

- **l'era è corta**: tre lavoratori, quattro con la Dinastia. Non c'è molto spazio per combinazioni
  lunghe;
- **il mercato si muove**: la carta per cui ci si prepara al primo lavoratore, al terzo può averla
  presa un altro. Il piano ottimista non lo vede, e per questo il suo vantaggio si assottiglia;
- **le mosse migliori sono già quasi sempre anche le più immediate**: una costruzione che rende,
  la base su cui salire — l'avido le trova da solo, perché il valutatore conta già le rendite
  future e la Verticalità della colonna.

Per un gioco è una buona notizia: **premia chi legge il tavolo, non chi calcola dieci mosse
avanti.** Un giocatore umano che pianifica bene avrà un vantaggio, ma non schiacciante.

## Cosa usano le misure

Le batterie da migliaia di partite (`docs/vita-degli-edifici.md`, `docs/quanto-paga-salire.md`,
`docs/quanto-punisce-il-gioco.md`, `docs/strategie-dei-bot.md`) usano il **bot avido versione 2**,
quello che valuta dopo l'attivazione. Una partita con **un solo** pianificatore al tavolo dura
già **circa tre volte** (1,5 secondi contro 0,47), per un vantaggio di 2 punti su 85: rifarci sopra diecimila partite sposterebbe i numeri meno del rumore
fra due lotti, al triplo del tempo. Resta a disposizione per i tornei e per le domande in cui la
pianificazione è il punto — i Monumenti, per esempio, che sono obiettivi da inseguire.
