# Passaggio di consegne

Per chi riprende il lavoro in una sessione nuova. Stato al **27 settembre 2026**, main a
`c66b0dc`, nessuna PR aperta. Il lavoro in corso è la **v2 del gioco** ("la terza risorsa"):
regole nel file `data/cards-v2.json`, regolamento in `docs/regolamento-v2.md`, diciotto misure in
`docs/la-terza-risorsa.md`, decisioni nel registro `docs/domande-aperte.md` (118 punti).

## Con chi si lavora

Il designer di **La Strada delle Ere**, che scrive in **italiano**: si risponde in italiano. Le
regole sono sue: si misura, si propone e si chiede; le decisioni di gioco non si prendono al suo
posto. Quando una domanda ha più risposte ragionevoli, si offrono le opzioni con una
raccomandazione, e si va avanti solo con la sua parola.

Il suo modo di lavorare:
- procede **un passo alla volta**: chiede una prova, guarda i numeri, decide in una riga ("resta
  come terza e quarta copia, poi mergia") e passa alla prossima;
- **"mergia"** (o "mergia tutto", "confermo vai pure") vuol dire: togli la bozza, fai il merge,
  dimmi cosa c'è su main. Senza quella parola le PR restano in bozza, anche per ore;
- vuole sapere **perché** un numero è quello che è (il bot o le regole? quale carta?) e ogni
  misura finisce scritta nel documento delle misure e nel registro, con i numeri;
- ogni tanto fa domande di stato ("tutto mergiato?", "cosa manca?"): la risposta è l'elenco delle
  PR aperte e delle domande aperte, non un riassunto del lavoro.

## I vincoli che non si toccano

1. **"I PDF in `materiali/` servono solo per la grafica: non leggere mai i dati da lì."** (parole
   sue). I dati stanno **solo** nei file JSON.
2. **`data/cards.json` è la v1.5 congelata.** Non cambia mai il comportamento: il lotto di
   riferimento in `reference/lotto-v1.5/` deve rigiocarsi identico riga per riga
   (`tools/verifica_riferimento.sh`, da lanciare prima di ogni push che tocca il motore o i bot).
   Ogni regola nuova entra come manopola spenta, o come costante del file v2.
3. **`data/cards-v2.json` è generato** da `tools/genera_cards_v2.py` e non si edita a mano; lo
   stesso per `data/proposte/cards-v2-*.json` (`--variante`) e `docs/carte-v2.md`
   (`tools/carte_v2.py`). Si cambia il generatore, si rigenera tutto, si committa tutto.
4. **Le regole non cambiano col numero di giocatori** (registro 113): niente `min_players` sulle
   carte, niente PV diversi a quattro. Solo la misura del mercato potrebbe dipenderne, e finora
   non ne dipende.
5. I commenti nel codice sono in italiano e spiegano il **perché**, spesso con la storia
   dell'errore che hanno evitato. Si scrive nello stesso stile.
6. **Una modifica alla volta**, misurata sugli stessi semi prima e dopo, scritta nei documenti.

## Lo stato del gioco

Godot 4.7, progetto nella radice del repo (`res://` = repo). Due regolamenti convivono e si
scelgono nella schermata di gioco (`godot res://scenes/gioca.tscn`) o con `--dati` nell'audit:

- **v1.5** (`data/cards.json`, `reference/regolamento-completo.html`): congelata, termine di
  paragone.
- **v2** (`data/cards-v2.json`, `docs/regolamento-v2.md`): tutte le regole sono costanti del file.
  In breve: **tre risorse** (Pietra, Denaro, Idee; tetto 3 per risorsa, 5 in tutto), **quattro
  lavoratori** che attivano e poi agiscono, **draft dei Personaggi** a inizio era, **senza rudere**
  (chi crolla va in rovina, sagoma girata, ristrutturabile), rovina a −2, **Verticalità a zero e
  premio di scavo S×L** a chi costruisce sopra (dimezzato nell'era 5), Continuità 2/5, tessere
  colonna con un effetto **una volta per era**, lo **scheletro** del lavoratore sotto il
  potenziamento, Monumenti rivelati = giocatori − 1, mercato a 6, e le **case della riserva**
  (registro 116–117): quattordici case generiche sempre disponibili in due copie, tre tipi per era
  (piccola Lampo 1, grande Lampo 2, con lo Scavo Lampo 1 e Scavo 2; nell'era Moderna solo le prime
  due), che non stanno nel mazzo dell'era. Le misure 1–18 in `docs/la-terza-risorsa.md` dicono
  perché ogni scelta è quella.

- **v3 di prova** (`data/proposte/cards-v3-era1.json`, generato da `tools/genera_cards_v3.py`;
  `docs/passaggio-v3.md` e `docs/proposte/v3-*.md`): i Personaggi sono i lavoratori, le risorse
  muoiono a fine era, chi attiva una colonna usa un edificio della colonna ("stile Caylus"). Tutto
  acceso dalla costante `turno_v3`; nella schermata di gioco e' il tasto "v3", quello di partenza.
  Registri 153-177, misure 31-49.

**I bot.** `StrategyBot` versione 2, sei strategie (Rendita, Lampo, Scavo, Bilanciata, Obiettivi,
Continuità) sullo stesso valutatore con **spinte** che sono handicap, non aiuti (registro 114).
Le tabelle sono in `scripts/ai/strategy_bot.gd`: `SPINTE_V1` (non si tocca), `SPINTE_V2` e
`SPINTE_V2_PER_GIOCATORI` per tavolo (a 3: `lampo` 2,0; a 4: `lampo` 0,8, `lampo_potenzia` 5,
`rendita_per_era` 1,5, Scavo a un quarto). Con le case tutte le strategie stanno nell'errore a
2, 3 e 4 (diciottesima misura): a 2 Rendita 56 e a 3 Rendita 38 sono sul bordo alto.
`--spinta k=v,...` prova una taratura senza toccare le tabelle.

**I test** (scene headless, sempre con `timeout` e l'output su file): `test_actions` 452 (quattro per
la v3), `test_effects` 503, `test_schema_validator` 13, `test_view` 552. `test_view` ha bisogno della
grafica importata (`python3 tools/estrai_grafica.py` e poi `godot --headless --import`): senza,
due test sul piano della tessera falliscono ("profondo quanto la tessera", "uno per colonna")
e non sono regressioni.

**I documenti.** `la-terza-risorsa.md` (le diciotto misure, con "Come rifare il conto" in fondo),
`domande-aperte.md` (il registro), `regolamento-v2.md`, `carte-v2.md` (la distinta delle carte v2,
generata), `strategie-dei-bot.md`, `materiali-di-stampa.md` e `mappatura-sagome.md` (i PDF e la
loro mappatura), `vita-degli-edifici.md`, `quanto-punisce-il-gioco.md`, `quanto-paga-salire.md`,
`il-bot-che-pianifica.md`, `partita-4008.md`, `proposte/nuova-meccanica.md` (la proposta da cui
è nata la v2) e `proposte/audit-nuova-meccanica.md`.

## Il metodo di misura

- **Stessi semi, un cambiamento alla volta.** Il torneo standard: 750 partite, seme 700000,
  `--giro tutte` (ogni combinazione di strategie lo stesso numero di volte, con rotazione dei
  posti: senza, a due e a quattro le strategie incontravano solo le vicine di lista, registro
  114). La vita delle carte: 2000 partite, seme 200000, a tre. Una manopola nuova si verifica
  **spenta**: `tools/verifica_riferimento.sh` deve dire identico.
- **Errore standard sulla vittoria**: a due ±6 (atteso 50), a tre ±5 (33), a quattro ±4 (25). Una
  strategia "sul bordo" si scrive così; si ritoccano i bot, non le regole, se non c'è un motivo
  di regole.
- **La partita e chi vince sono due cose.** Le spinte dei bot spostano le percentuali di
  vittoria e lasciano PV, edifici, passaggi, altezza e basi altrui identici al decimale: è il
  controllo che una taratura non ha cambiato il gioco.
- **Le intestazioni dicono tutto**: ogni lotto porta `# dati = …`, `# giro = …` e ogni manopola
  accesa (`--spinta` compresa). Una riga di intestazione si stampa **solo se la manopola è
  data**, altrimenti il riferimento della v1.5 cambia e la verifica fallisce.

```bash
S=/percorso/di/godot   # l'eseguibile; in questa macchina stava nella cartella di lavoro
# tornei a 2, 3, 4 sul file v2 (uno per processo, ~15-40 minuti su 4 core)
for p in 2 3 4; do $S --headless res://scenes/audit_partita.tscn -- --players $p --games 750 \
  --seed 700000 --giro tutte --dati data/cards-v2.json > lotto_p$p.csv; done
python3 tools/confronta_torneo.py prima_p4.csv dopo_p4.csv     # PV per canale, azioni, vittorie
python3 tools/confronta_strategie.py lotto_p3.csv               # solo le vittorie, con l'errore
python3 tools/kingmaker.py lotto_p2.csv lotto_p3.csv lotto_p4.csv
# la vita delle carte (una riga per carta: quante volte costruita, quanto ha reso)
$S --headless res://scenes/audit_partita.tscn -- --players 3 --vita 2000 --seed 200000 \
  --dati data/cards-v2.json > vita.csv
python3 tools/confronta_vita.py prima.csv dopo.csv
# una partita raccontata, con il perché di ogni mossa del bot
$S --headless res://scenes/audit_partita.tscn -- --seed 700007 --players 3 --dati data/cards-v2.json --perche
# la v1.5 è ancora identica?
GODOT=$S tools/verifica_riferimento.sh
```

Le manopole dell'audit (tutte in `scripts/tools/audit_partita.gd`): regole `--senza_rudere`,
`--gap`, `--verticalita`, `--premio`, `--premio_era5`, `--tetto`, `--turno_v2`, `--lavoratori`,
`--tessere`, `--sepolti`, `--vetusta`, `--scheletro`, `--protezione`, `--passa_incasso`,
`--monumenti`, `--mercato`, `--rendita_tetto`, `--scavo_scava`, `--scavo_spianato`,
`--sconto_altrui`, `--prosperita`, `--proprietari`, `--una_per_era`, `--binari`, `--rudere`,
`--forza`; bot `--bot`, `--spinta`, `--piano`, `--candidate`, `--caso`, `--tutto`; lotti
`--games`, `--vita`, `--seed`, `--players`, `--giro`, `--dati`, `--perche`, `--muto`. I lotti
lunghi si lanciano con `nohup … ; echo $? > X.done` e si aspettano con un ciclo su `.done`: il
container può ripartire.

## Le trappole tecniche

- **Un errore di parsing fa restare appesa una scena headless**, senza messaggio: sempre `timeout`
  e output su file, poi cercare `SCRIPT ERROR`. `var x := funzione_non_tipizzata()` non compila
  (tipo non inferibile): si scrive il tipo.
- `godot --headless --check-only --script …` segnala sempre, a torto, "Identifier not found:
  CardDB" e "Failed to compile depended scripts": gli Autoload non esistono in `--script`.
- Dopo una nuova `class_name` o un nuovo asset: `godot --headless --import`.
- `tools/verifica_riferimento.sh` usa `godot` nel PATH: se non c'è, `GODOT=/percorso`, altrimenti
  il torneo esce vuoto e sembra "diverso".
- `rm -f $M/*` viene bloccato dal controllo di sicurezza della sessione: `rm -f "${M:?}"/*` o il
  percorso per esteso; meglio ancora una cartella nuova per ogni serie di lotti.
- La grafica estratta (`assets/`) non è versionata: `pip install pymupdf` e
  `python3 tools/estrai_grafica.py`, che si autoverifica (impronte dei PDF, conteggi per gruppo,
  copie byte per byte) e dice da solo se un PDF è cambiato. In Python non c'è PIL.
- Un PDF caricato dal sito di GitHub sopra i 25 MB non entra: `Carte.pdf` pesa 26. Il designer
  può consegnare la pagina rifatta da sola (è successo per la 29) e la si confronta con la
  vecchia posizione per posizione, per impronta delle immagini.
- Gli screenshot: `tools/scatta3d.sh FILE.png -- --seed 7 --era 3 --turns 2` (usa xvfb).

## Git e PR

- Un ramo per modifica, da `origin/main`; dopo ogni merge si riparte da `origin/main`
  (`git checkout -B ramo origin/main`; `main` locale può essere in un worktree e non si tocca).
- Ogni PR nasce in **bozza**; il merge (con commit di merge, non squash) solo quando il designer lo
  chiede. Dopo il merge: togliere l'osservazione della PR e il check-in programmato.
- Se main è avanzata (il designer carica file da solo, per esempio i PDF): `git merge origin/main`
  nel ramo, e nei conflitti del registro si tengono tutte e due le parti, nell'ordine dei punti.
- I commit finiscono con le righe di attribuzione indicate dalla sessione; nessun identificativo
  di modello in commit, PR o codice.

## Cosa resta aperto

- **La v3** e' su main come file di prova (PR #73) e si gioca a schermo dal tasto "v3" della
  schermata d'inizio (registro 176): quel che resta e' in `docs/passaggio-v3.md`, "Prossimi
  passi" (le decisioni del designer sui numeri delle ultime misure; il tavolo 3D non segna gli
  edifici gia' usati nel giro).
- **La grafica della v2.** Le carte degli edifici v2 ci sono (registro 120, cinque PDF per era):
  a schermo la v2 le usa. Da correggere nel PDF tre case col Lampo vecchio e le Case operaie da
  togliere. Mancano ancora le sagome v2, i Personaggi del draft e le tessere con l'effetto: il
  capitolato è `docs/carte-v2.md`.
- Il riepilogo finale a schermo usa i nomi del regolamento v2 dal registro 119 (`Riepilogo.voci()`
  sceglie la tabella dal file dei dati); la colonna "Scavo+premio" tiene insieme il premio di
  scavo pagato sul momento e lo Scavo di fine partita, che il nucleo segna nello stesso canale.
- **Le strategie sul bordo**: Rendita 56 a due e 38 a tre (bordo 56 e 38). Si rimisurano se si
  ritoccano i bot o le case; non è un problema di regole.
- **Registro 86**: al tavolo serve un segno fisico per i Centri Urbani che hanno già pagato
  nell'era; il regolamento v1.5 non lo dice.
- I difetti dei materiali di stampa (69, 73, 74) sono **chiusi** il 27 settembre. I blob noti su
  main: `Carte.pdf` 008a6c4, i cinque `Edifici_<Era>_Era_A4.pdf` (dal 28 settembre: a8f7b79,
  a1efd25, f2fcaf4, cfd6790, c799604), `Potenziamenti.pdf` 7e630f1, `Sfondo.png` 6dbe9a9, `Scavo.png`
  ee29441, `Terrapieno.png` 4fe4f34, `Scheletri.png` 7eef245, `ProsperitaUrbana.png` 8c42bf1
  (`git ls-tree origin/main materiali/`); se uno cambia, `tools/estrai_grafica.py` lo dice.

## Da dove partire

1. Leggere il registro dal punto 107 (il regolamento v2) al 118, e le misure dalla dodicesima
   alla diciottesima in `docs/la-terza-risorsa.md`: sono le decisioni delle ultime due settimane.
2. Rigiocare i tre tornei standard (comandi sopra) e confrontarli con la diciottesima misura:
   devono uscire identici. È il modo più veloce per sapere che l'ambiente è a posto.
3. Chiedere al designer da dove ripartire fra le cose aperte. Non anticipare la grafica della v2
   senza un suo capitolato: le carte e le sagome sono sue.
