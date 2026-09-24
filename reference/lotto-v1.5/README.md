# Il lotto di riferimento della v1.5

Due batterie di 120 partite a 3 giocatori, giocate dal motore com'era al momento in cui il
gioco è stato congelato (main a `d56bb94`, ramo `congelato/v1.5`, tag `v1.5`), prima di
cominciare la nuova meccanica. Sono la pietra di paragone: **qualunque modifica al motore che
non voglia cambiare la v1.5 deve rigiocarle identiche, riga per riga.**

| file | comando che l'ha generato | righe |
|---|---|---|
| `torneo.csv` | `audit_partita --players 3 --games 120 --seed 700000` | una per giocatore (360) |
| `vita.csv` | `audit_partita --players 3 --vita 120 --seed 100000` | una per carta (60), più l'intestazione delle regole |

Regole in vigore, come le scrive l'intestazione di `vita.csv`: bot a strategie versione 2, sei
strategie, Verticalità 2/5/9/14, Centro Urbano a 3 edifici una volta per era, rovina a −3,
binari liberi.

## Come si usa

```bash
tools/verifica_riferimento.sh                 # `godot` nel PATH
GODOT=/percorso/godot tools/verifica_riferimento.sh
```

Rigioca le due batterie (circa 100 secondi) e dice se sono identiche. Del torneo confronta i
primi 19 campi (fino a `piano`), perché le colonne nuove si aggiungono in fondo; della vita
confronta tutto, intestazione compresa. Se una regola nuova aggiunge una voce all'intestazione
il confronto fallisce apposta: si guarda che sia l'unica differenza, e si rigenera il
riferimento dichiarandolo nel commit.

È lo stesso metodo usato finora per le manopole ("spenta, le partite sono identiche a main"),
reso eseguibile e ancorato a un lotto salvato, così non serve più tenere a mano i CSV di main.

## Quando si rigenera

Solo quando la v1.5 cambia **di proposito** (una regola adottata dal designer). Mai per far
passare un confronto.
