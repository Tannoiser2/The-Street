# Passaggio di consegne

Per chi riprende il lavoro in una sessione nuova. Stato al 24 settembre 2026, main a `d56bb94`
più la PR #24 aperta. Il compito che aspetta è l'**audit della nuova meccanica** proposta dal
designer: [`proposte/nuova-meccanica.md`](proposte/nuova-meccanica.md).

## Con chi si lavora

Il designer di **La Strada delle Ere** (ruleset v1.5), che scrive in **italiano**: si risponde in
italiano. Le regole sono sue: si misura, si propone e si chiede; le decisioni di gioco non si
prendono al suo posto. Quando una domanda ha più risposte ragionevoli, si offrono le opzioni con
una raccomandazione.

Il suo modo di lavorare, visto finora:
- chiede misure su tante partite ("rifai le 10000 partite") e poi decide in una parola ("accendi
  la 2 e mergia");
- **"mergia"** vuol dire: segna pronta la PR, fai il merge, dammi il link. Senza quella parola le
  PR restano in bozza;
- vuole sapere **perché** un numero è quello che è: il merito del bot o delle regole, quale
  meccanismo, quale carta.

## I vincoli che non si toccano

1. **"I PDF in `materiali/` servono solo per la grafica: non leggere mai i dati da lì."** (parole
   sue). I dati del gioco stanno **solo** in `data/cards.json`.
2. I commenti nel codice sono in italiano e spiegano il **perché**, spesso con la storia dell'errore
   che hanno evitato. Si scrive nello stesso stile.
3. Il registro delle decisioni è `docs/domande-aperte.md` (86 punti): ogni scelta di regola o
   difetto dei materiali ha un punto numerato, con i numeri che l'hanno motivata.

## Lo stato del gioco

Godot 4.7, progetto nella radice del repo (`res://` = repo). Le regole in vigore, oltre al
regolamento v1.5 (`reference/regolamento-completo.html`), sono quelle adottate strada facendo, tutte
come costanti in `data/cards.json` → `constants`:

| regola | valore | dove è motivata |
|---|---|---|
| binari liberi: si riempie dal binario più lontano | `binari_liberi: true` | domande-aperte 84 |
| si crolla in rovina solo fallendo di 3 | `rovina_gap: 3` | quanto-punisce-il-gioco |
| Verticalità | `2/5/9/14` | quanto-paga-salire |
| Centro Urbano: 3 edifici, 2 proprietari, 1 oro a testa, **una volta per era** | `prosperity` | domande-aperte 84, 86 |
| Colosseo e Silvicoltore contano intatti e ruderi, non le rovine | dati delle carte | domande-aperte 81 |
| le rovine non portano cubetti | vista | domande-aperte 81 |

**I bot.** `StrategyBot` versione 2 (valuta le mosse sullo stato **dopo** l'attivazione, su una
copia della partita: `GameState.duplica()`). `--bot 1` rimette il bot vecchio, verificato identico.
Sei strategie a rotazione di posto: Rendita, Lampo, Scavo, Verticale, Bilanciata, Obiettivi
(Continuità candidata). `PlanningBot` pianifica l'era intera con una ricerca a fascio (+2 PV,
36% di vittorie contro 33% atteso): è in `docs/il-bot-che-pianifica.md`.

**I test.** `test_actions` 152, `test_effects` 478, `test_view` 415: tutti verdi.

**I documenti di misura** (in `docs/`): `vita-degli-edifici.md` (10 000 partite, generato da
`tools/impagina_vita.py`), `strategie-dei-bot.md`, `quanto-punisce-il-gioco.md`,
`quanto-paga-salire.md`, `il-bot-che-pianifica.md`, `partita-4008.md` (una partita spiegata mossa
per mossa).

## Il metodo di misura

- **Stessi semi, un cambiamento alla volta.** Ogni confronto è fra due lotti con gli stessi semi
  (`--seed`) che differiscono in una cosa sola. Una manopola nuova si verifica **spenta**: le
  partite devono essere identiche a quelle di main, riga per riga (confrontando i primi 19 campi del
  CSV, perché le colonne nuove si aggiungono in fondo).
- **Le intestazioni dicono tutto.** Ogni batteria `--vita` scrive
  `# partite=… bot=… verticalita=… prosperita=… rovina=… binari=… versione_bot=… strategie=… centro=…`,
  e `impagina_vita.py --confronta` nomina **tutte** le differenze fra due lotti. Una regola nuova
  va aggiunta lì, se no due lotti diversi sembrano uguali.
- **Separare il bot dalle regole.** Un cambiamento del bot sposta le percentuali quanto una regola:
  con `--bot 1` si rigiocano le regole nuove col bot vecchio. È così che si è scoperto che la
  Rendita in testa era merito del bot e non delle regole.
- **Errore standard.** Su ~1 500 partite per strategia una percentuale di vittoria ha ±1,2 punti;
  su ~260, ±2,9. Sotto quelle soglie una differenza è rumore, e il documento lo dice.

`scripts/tools/audit_partita.gd`, lanciato come scena:

```bash
# una partita raccontata turno per turno (--perche spiega ogni mossa del bot)
godot --headless res://scenes/audit_partita.tscn -- --seed 4008 --players 3 --perche
# un torneo: una riga CSV per giocatore
godot --headless res://scenes/audit_partita.tscn -- --players 3 --games 750 --seed 700000 > lotto.csv
python3 tools/confronta_strategie.py lotto.csv
# la vita delle carte (quattro processi da 2500, semi 100000/102500/105000/107500)
godot --headless res://scenes/audit_partita.tscn -- --players 3 --vita 2500 --seed 100000 > vita_0.csv
python3 tools/impagina_vita.py "vita_*.csv" docs/vita-degli-edifici.md [--confronta "vecchi_*.csv"]
```

Manopole per provare regole senza toccare i dati: `--verticalita`, `--prosperita`, `--proprietari`,
`--una_per_era 0|1`, `--gap`, `--rudere`, `--forza`, `--binari`; e per i bot `--bot N`, `--piano`,
`--tutti STRATEGIA`, `--candidate`, `--caso`. A 3 giocatori 10 000 partite richiedono ~25 minuti
su 4 processi.

## Le trappole tecniche

- **Un errore di parsing fa restare appesa una scena headless**, senza messaggio. Lanciare sempre
  con `timeout` e l'output su file, poi cercare `SCRIPT ERROR`. Per esempio
  `var p := gs.players[0]` non compila (tipo non inferibile): serve `var p: PlayerState = …`.
- `godot --headless --check-only --script …` segnala sempre, a torto,
  "Identifier not found: CardDB" (in modalità `--script` gli Autoload non esistono).
- Dopo una nuova `class_name` o un nuovo asset: `godot --headless --import`.
- Un `pgrep -f test_actions` trova anche il comando che lo contiene: usare `pgrep -x godot`.
- Il container può ripartire e uccide i processi in background: i lotti lunghi vanno lanciati con
  `nohup` e un file-segnale a fine lavoro, e ricontrollati.
- Gli screenshot: `tools/scatta3d.sh FILE.png -- --seed 7 --era 3 --turns 2 [--zoom 0.5 --mira 3 --alt 50]`
  (usa xvfb). `scatta3d` stampa i Centri Urbani e quali hanno già pagato.
- In Python non c'è PIL.

## Git e PR

- Si lavora sul ramo indicato dalla sessione; dopo ogni merge si riparte da `origin/main`.
- Ogni PR nasce in **bozza**; il merge solo quando il designer lo chiede.
- I commit finiscono con le righe di attribuzione (`Co-Authored-By` e `Claude-Session`) indicate
  dalla sessione; nessun identificativo di modello in commit, PR o codice.

## Cosa resta aperto

- **PR #24** (il cartellino della Prosperità si spegne dopo il pagamento): in bozza, aspetta il
  "mergia". Contiene anche questo documento e la proposta trascritta.
- **domande-aperte 69, 73, 74**: difetti dei materiali di stampa, in attesa dei PDF corretti dal
  designer.
- **domande-aperte 86**: al tavolo serve un segno fisico per i Centri che hanno già pagato
  nell'era (per esempio girare il cartellino); il regolamento va aggiornato.
- **Il controllo quotidiano dei materiali.** La sessione vecchia aveva una routine che ogni giorno
  confrontava i file in `materiali/` con quelli noti e, se il designer ne ricaricava uno,
  rilanciava `tools/estrai_grafica.py` (che si autoverifica), guardava se i punti 69 e 73 erano
  stati corretti e apriva una PR. I blob noti su main: `Carte.pdf` 5bbec7e,
  `Potenziamenti.pdf` 7e630f1, `Sfondo.png` cce0456, `Scavo.png` ee29441, `Terrapieno.png`
  4fe4f34, `Scheletri.png` 7eef245, `ProsperitaUrbana.png` 8c42bf1
  (`git ls-tree origin/main materiali/`). Se serve ancora, va ricreata nella sessione nuova.

## Da dove partire con l'audit

1. Leggere [`proposte/nuova-meccanica.md`](proposte/nuova-meccanica.md): la proposta trascritta,
   il confronto punto per punto con la v1.5, **18 domande da chiudere** e la mappa del codice.
2. Portare al designer le domande **prima** di scrivere codice: dove la proposta tace, un
   simulatore dovrebbe inventare, e una misura su regole inventate non dice niente del suo gioco.
   Dove una risposta ragionevole c'è, proporla come opzione raccomandata.
3. Solo allora decidere con lui come prototipare. Suggerimento, non decisione: tenere la v1.5
   giocabile accanto alla nuova, così ogni misura della v2 ha un termine di paragone.
