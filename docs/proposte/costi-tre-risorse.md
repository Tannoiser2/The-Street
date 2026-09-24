# I 60 edifici in tre risorse: una proposta

> Generata da `tools/proponi_costi_v2.py` dai dati della v1.5: le regole stanno nello script,
> una frase ciascuna, e la tabella ne discende. **È una proposta**: il designer cambia una
> regola o una riga, si rilancia, e i totali si rifanno da soli. Il file per il motore è
> `data/proposte/costi-tre-risorse.json` (stesso contenuto, per il futuro `cards-v2.json`).

## Le regole

1. **Costruzione = la pietra di oggi, Denaro = l'oro di oggi.** La curva del punto 7 della
   proposta nei costi c'è già: pietra 18 / 31 / 23 / 19 / 14 per era, oro 0 / 0 / 7 / 22 / 30.
2. **Le Idee sostituiscono, non si aggiungono.** Il costo totale di ogni carta resta uguale,
   così il ritmo del gioco resta confrontabile con oggi e la prima misura isola solo la
   terza risorsa. Alzare i costi è una scelta a parte, da fare dopo.
3. **Cultura paga in Idee**: 1 al posto di 1 Costruzione nelle ere 1-2, al posto di 1 Denaro
   nelle ere 3-5; una seconda al posto di un secondo Denaro nelle ere 4-5.
4. **Religione paga 1 Idea** al posto di 1 Costruzione nelle ere 1-2 (il sacro è la prima
   idea) e al posto di 1 Denaro nelle ere 3-5.
5. **Ingegneria paga 1 Idea** al posto di 1 Denaro dall'era 2 in poi; nell'era 1 resta
   Costruzione: le trappole sono braccia, l'acquedotto è un'idea.
6. **Militare, Commercio e Civico non pagano Idee.**
7. Una carta a doppia classe segue la classe che chiede Idee, una volta sola; se la risorsa
   da sostituire manca (niente Denaro), si sostituisce Costruzione.
8. **Chi oggi produce Cultura produce Idee** (D1 dell'audit: Idee = Cultura resa risorsa).
9. **Nelle ere 4-5 ogni carta paga almeno un'Idea**, anche Militare, Commercio e Civico: è
   l'esplosione delle Idee nel Rinascimento e nell'era Moderna.

Con queste regole la domanda di Idee cresce con le ere quasi da sola, perché crescono le carte
Cultura (2 / 2 / 1 / 4 / 6 per era) e l'oro da sostituire (0 / 0 / 7 / 22 / 30). **L'era 3 fa
eccezione**, e il designer l'ha voluta così: il Medioevo è un periodo oscuro, le Idee calano;
esplodono nel Rinascimento e nell'era Moderna, dove con la regola 9 nessuna carta è senza
Idee. Il designer ha scelto questa curva ("15 e 18") rispetto ai 10 / 16 delle sole classi
colte: si spegne in testa allo script, se mai servisse il confronto.

## La tabella

| era | edificio | classi | oggi C/O | **Costruzione** | **Denaro** | **Idee** | produce | nota |
|--:|---|---|--:|--:|--:|--:|---|---|
| 1 | Approdo | commercio | 1/0 | 1 | 0 | 0 | 1 C |  |
| 1 | Capanne | civico | 1/0 | 1 | 0 | 0 | 1 C |  |
| 1 | Cava | commercio | 1/0 | 1 | 0 | 0 | 2 C |  |
| 1 | Circolo di pietre | religione | 3/0 | 2 | 0 | 1 | — | R4 Religione: 1 Idea per 1 Costruzione |
| 1 | Dolmen | religione | 2/0 | 1 | 0 | 1 | — | R4 Religione: 1 Idea per 1 Costruzione |
| 1 | Focolare comune | civico | 1/0 | 1 | 0 | 0 | — |  |
| 1 | Grotte dipinte | cultura | 1/0 | 0 | 0 | 1 | — | R3 Cultura: 1 Idea per 1 Costruzione |
| 1 | Menhir | religione | 2/0 | 1 | 0 | 1 | — | R4 Religione: 1 Idea per 1 Costruzione |
| 1 | Palafitte | civico | 1/0 | 1 | 0 | 0 | 1 C |  |
| 1 | Trappole da pesca | ingegneria | 1/0 | 1 | 0 | 0 | 1 C |  |
| 1 | Tumulo funerario | religione/cultura | 2/0 | 1 | 0 | 1 | — | R3 Cultura: 1 Idea per 1 Costruzione |
| 1 | Villaggio palizzato | militare | 2/0 | 2 | 0 | 0 | — |  |
| 2 | Acquedotto | ingegneria | 3/0 | 2 | 0 | 1 | — | R7: niente Denaro, 1 Idea per 1 Costruzione |
| 2 | Anfiteatro | cultura | 5/0 | 4 | 0 | 1 | 1 D | R3 Cultura: 1 Idea per 1 Costruzione |
| 2 | Castrum | militare | 3/0 | 3 | 0 | 0 | — |  |
| 2 | Emporio | commercio | 2/0 | 2 | 0 | 0 | 1 D |  |
| 2 | Foro | commercio/civico | 3/0 | 3 | 0 | 0 | 1 D |  |
| 2 | Insulae | civico | 2/0 | 2 | 0 | 0 | 1 C |  |
| 2 | Ponte | ingegneria | 3/0 | 2 | 0 | 1 | — | R7: niente Denaro, 1 Idea per 1 Costruzione |
| 2 | Sacello | religione | 1/0 | 0 | 0 | 1 | — | R4 Religione: 1 Idea per 1 Costruzione |
| 2 | Teatro | cultura | 2/0 | 1 | 0 | 1 | — | R3 Cultura: 1 Idea per 1 Costruzione |
| 2 | Tempio | religione | 3/0 | 2 | 0 | 1 | — | R4 Religione: 1 Idea per 1 Costruzione |
| 2 | Terme | civico | 2/0 | 2 | 0 | 0 | — |  |
| 2 | Torre di vedetta | militare | 2/0 | 2 | 0 | 0 | — |  |
| 3 | Abbazia | religione/commercio | 2/2 | 2 | 1 | 1 | — | R4 Religione: 1 Idea per 1 Denaro |
| 3 | Arsenale | militare | 3/1 | 3 | 1 | 0 | — |  |
| 3 | Borgo | civico | 2/0 | 2 | 0 | 0 | 1 D |  |
| 3 | Cappella | religione | 1/1 | 1 | 0 | 1 | — | R4 Religione: 1 Idea per 1 Denaro |
| 3 | Castello | militare | 2/1 | 2 | 1 | 0 | — |  |
| 3 | Chiesa | religione/cultura | 2/1 | 2 | 0 | 1 | — | R3 Cultura: 1 Idea per 1 Denaro |
| 3 | Conceria | commercio | 1/0 | 1 | 0 | 0 | 1 D |  |
| 3 | Mercato | commercio | 2/0 | 2 | 0 | 0 | 1 C 1 D |  |
| 3 | Mulino | ingegneria/commercio | 2/0 | 1 | 0 | 1 | 2 D | R7: niente Denaro, 1 Idea per 1 Costruzione |
| 3 | Mura | militare | 2/0 | 2 | 0 | 0 | — |  |
| 3 | Ospedale dei pellegrini | civico | 2/1 | 2 | 1 | 0 | — |  |
| 3 | Torre civica | civico | 2/0 | 2 | 0 | 0 | — |  |
| 4 | Accademia | cultura | 1/2 | 1 | 0 | 2 | — | R3 Cultura: 1 Idea per 1 Denaro; R3 Cultura, era 4-5: seconda Idea |
| 4 | Banco | commercio | 1/1 | 1 | 0 | 1 | 1 D | R9: era 4-5, almeno 1 Idea |
| 4 | Bottega d'artista | cultura | 1/1 | 1 | 0 | 1 | — | R3 Cultura: 1 Idea per 1 Denaro |
| 4 | Duomo | religione/cultura | 3/3 | 3 | 1 | 2 | — | R3 Cultura: 1 Idea per 1 Denaro; R3 Cultura, era 4-5: seconda Idea |
| 4 | Fortezza bastionata | militare/ingegneria | 3/2 | 3 | 1 | 1 | — | R5 Ingegneria: 1 Idea per 1 Denaro |
| 4 | Giardino all'italiana | cultura | 0/2 | 0 | 0 | 2 | — | R3 Cultura: 1 Idea per 1 Denaro; R3 Cultura, era 4-5: seconda Idea |
| 4 | Loggia | civico | 1/1 | 1 | 0 | 1 | — | R9: era 4-5, almeno 1 Idea |
| 4 | Osservatorio | ingegneria | 1/2 | 1 | 1 | 1 | — | R5 Ingegneria: 1 Idea per 1 Denaro |
| 4 | Palazzo signorile | civico | 2/2 | 2 | 1 | 1 | 1 I | R9: era 4-5, almeno 1 Idea |
| 4 | Piazza monumentale | civico | 2/2 | 2 | 1 | 1 | — | R9: era 4-5, almeno 1 Idea |
| 4 | Ponte monumentale | ingegneria | 2/2 | 2 | 1 | 1 | — | R5 Ingegneria: 1 Idea per 1 Denaro |
| 4 | Villa | civico | 2/2 | 2 | 1 | 1 | — | R9: era 4-5, almeno 1 Idea |
| 5 | Biblioteca | cultura | 1/3 | 1 | 1 | 2 | — | R3 Cultura: 1 Idea per 1 Denaro; R3 Cultura, era 4-5: seconda Idea |
| 5 | Caffè letterario | cultura | 0/2 | 0 | 0 | 2 | — | R3 Cultura: 1 Idea per 1 Denaro; R3 Cultura, era 4-5: seconda Idea |
| 5 | Condominio | civico | 1/1 | 1 | 0 | 1 | — | R9: era 4-5, almeno 1 Idea |
| 5 | Fondazione d'arte | cultura | 1/2 | 1 | 0 | 2 | — | R3 Cultura: 1 Idea per 1 Denaro; R3 Cultura, era 4-5: seconda Idea |
| 5 | Grattacielo | commercio | 2/4 | 2 | 3 | 1 | — | R9: era 4-5, almeno 1 Idea |
| 5 | Monumento ai caduti | militare/religione | 1/2 | 1 | 1 | 1 | — | R4 Religione: 1 Idea per 1 Denaro |
| 5 | Museo | cultura | 1/3 | 1 | 1 | 2 | — | R3 Cultura: 1 Idea per 1 Denaro; R3 Cultura, era 4-5: seconda Idea |
| 5 | Officina | ingegneria | 1/1 | 1 | 0 | 1 | 2 D | R5 Ingegneria: 1 Idea per 1 Denaro |
| 5 | Parco archeologico | cultura | 1/2 | 1 | 0 | 2 | — | R3 Cultura: 1 Idea per 1 Denaro; R3 Cultura, era 4-5: seconda Idea |
| 5 | Ponte in acciaio | ingegneria | 1/3 | 1 | 2 | 1 | — | R5 Ingegneria: 1 Idea per 1 Denaro |
| 5 | Stazione | commercio/ingegneria | 2/4 | 2 | 3 | 1 | 2 D | R5 Ingegneria: 1 Idea per 1 Denaro |
| 5 | Università | cultura/civico | 2/3 | 2 | 1 | 2 | — | R3 Cultura: 1 Idea per 1 Denaro; R3 Cultura, era 4-5: seconda Idea |

## I totali per era

| era | carte | con Idee | Costruzione | Denaro | Idee | totale unità | oggi (pietra + oro) |
|--:|--:|--:|--:|--:|--:|--:|--:|
| 1 | 12 | 5 | 13 | 0 | 5 | 18 | 18 |
| 2 | 12 | 6 | 25 | 0 | 6 | 31 | 31 |
| 3 | 12 | 4 | 22 | 4 | 4 | 30 | 30 |
| 4 | 12 | 12 | 19 | 7 | 15 | 41 | 41 |
| 5 | 12 | 12 | 14 | 12 | 18 | 44 | 44 |

La domanda di Idee per era: 5 / 6 / 4 / 15 / 18 unità sulle 12 carte dell'era. Contro la produzione proposta nell'audit (D4) per una
attivazione di tessera, Idee 1 / 2 / 2 / 3 / 3, con tre giocatori e tre lavoratori l'era
produce circa 9 attivazioni: 9 / 18 / 18 / 27 / 27 Idee, cioè più della domanda in ogni era.
È voluto: le Idee devono restare la risorsa più facile, e comprano anche i potenziamenti e la
Dinastia (D2), che qui non sono contati. Se il designer preferisce le Idee scarse, la curva
della tessera scende a 0 / 1 / 1 / 2 / 2.

## Cosa non decide questa tabella

- **La scala.** I costi restano quelli di oggi: se la v2 deve costare di più o di meno, è una
  seconda passata, dopo aver misurato la terza risorsa da sola.
- **Le tessere.** Cosa produce ogni tipo di terreno (D21) e con quale curva per era (D4).
- **Potenziamenti, Dinastia, ristrutturazione** (D2): in Idee o in Denaro. La proposta
  dell'audit era Idee per potenziamenti e Dinastia, Denaro per la ristrutturazione.
