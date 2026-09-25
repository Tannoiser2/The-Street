# La Strada delle Ere — versione digitale (Godot 4)

Pacchetto di partenza per l'implementazione digitale del gioco da tavolo, ruleset v1.5.

**Inizia da `docs/BRIEF_CLAUDE_CODE.md`.**

Il progetto Godot vive nella **radice del repository**: `res://` coincide con il
repo, quindi `res://data/cards.json` *è* il file master `data/cards.json`. Una
sola copia, nessuno script di sincronizzazione, nessuna possibilità di divergenza.

- `data/` — database delle carte (fonte unica) e schema di validazione
- `scripts/` — nucleo di regole, strato comandi, bot e strumenti
- `scenes/` — scene di avvio (runner headless, test)
- `reference/` — regolamento e simulatore Python usato come oracolo
- `docs/` — brief di sviluppo e registro delle domande aperte
- `materiali/` — PDF di stampa, **solo grafica**: i dati non si leggono mai da qui

`reference/` e `materiali/` contengono un file `.gdignore`: Godot le salta
completamente, così non finiscono né nell'importazione né in un export.

## Comandi

Richiede Godot 4.7 headless. Dalla radice del repository:

```bash
# Importa il progetto: NECESSARIO dopo aver aggiunto o rinominato una classe
# globale (class_name), altrimenti l'identificatore non viene risolto.
godot --headless --import

# Controlla la sintassi di uno script SENZA eseguirlo. Serve perche' un errore
# di parsing fa restare APPESA la scena headless invece di segnalarsi: qui
# invece si legge subito riga ed errore. L'unico falso allarme atteso e'
# "Identifier not found: CardDB", perche' in modo --script gli Autoload non
# esistono.
godot --headless --check-only --script scripts/tools/test_effects.gd

# Valida i dati contro lo schema (esce 1 se qualcosa non torna: usabile in CI)
godot --headless res://scenes/validate_data.tscn

# Verifica che il validatore rifiuti davvero i dati non conformi
godot --headless res://scenes/test_schema_validator.tscn

# Test unitari delle azioni (M2): legalità, effetto e casi di rifiuto
godot --headless res://scenes/test_actions.tscn

# Test del motore degli effetti (M4): i 24 eventi, e la chiusura dello schema
godot --headless res://scenes/test_effects.tscn

# Geometria della plancia (M5): gira headless come gli altri
godot --headless res://scenes/test_view.tscn

# Partite headless con RandomBot
godot --headless res://scenes/headless_runner.tscn -- --games 100 --players 3 --seed 1
```

### Guardare la plancia (M5)

`--headless` usa un driver di disegno finto: **non produce immagini**. Per
vedere davvero l'interfaccia serve un display, vero o virtuale:

```bash
tools/scatta.sh plancia.png -- --players 3 --seed 7 --era 4      # vista 2D
tools/scatta3d.sh strada.png -- --players 3 --seed 7 --era 4    # plancia 3D
```

### Giocare

```bash
godot res://scenes/gioca.tscn
```

Tu sei il giocatore 0, gli altri li gioca il bot. Nella schermata di scelta
si decide il **regolamento**: la v2 (tre risorse, quattro lavoratori, draft
dei Personaggi; carica `data/cards-v2.json`) o la v1.5 congelata
(`data/cards.json`). Con la v2 ogni era comincia dal draft: clicca un
Personaggio della fila e lo prendi, gratis. Poi clicca una colonna per
piazzare un lavoratore e attivarla, e scegli un'azione dall'elenco: ognuna
porta il costo, e quelle non disponibili portano il motivo. Cliccando una
carta delle file la si legge senza chiudere il menu. Nella v2 il lavoratore
che piazza un potenziamento resta sotto l'edificio come scheletro: il
gettone sta sulla basetta e, nel ventaglio del giocatore, in fondo alla
pila sotto la carta dell'edificio; il riquadro del mouse dice quanto vale.

Sul tavolo: la strada al centro, il mercato lungo il fianco sinistro,
personaggi, potenziamenti e monumenti lungo il destro, le plance dei giocatori
davanti. La colonna 0 e' a sinistra e l'era 1 e' la fila piu' vicina.

Le misure della plancia 3D sono in **millimetri**, prese dal cartone vero
(tessera colonna 63 x 271 mm, sagome da 61 / 121 / 181 mm, basetta 15 mm,
cartone 4 mm): i numeri del designer entrano nel codice come sono.

Lo script mette `xvfb-run` da solo se non c'e' un display. Disegna una partita
vera giocata dal RandomBot fino all'era richiesta, cosi' la plancia si guarda
invece di immaginarla. Utile anche per mostrare al designer com'e' venuta una
regola senza fargli compilare nulla.

### Grafica (preparazione M5)

Estrae da `materiali/Carte.pdf` le facce delle carte e le sagome nei due stati.
I file finiscono in `assets/` e **non sono versionati**: si rigenerano.

```bash
pip install pymupdf
python3 tools/estrai_grafica.py
```

Le carte estratte portano numeri obsoleti (il PDF è a una calibrazione
precedente alla v1.5): servono come riferimento grafico, non come contenuto.
La faccia della carta in gioco va disegnata dai dati. Vedi
`docs/domande-aperte.md` punti 20 e 23.

### Confronto con l'oracolo (M3)

Esporta gli stati finali di partite deterministiche e vi riapplica le formule di
punteggio del simulatore Python, per confrontare le regole senza che la
calibrazione dei dati interferisca:

```bash
godot --headless res://scenes/export_states.tscn -- --games 60 --players 3 --seed 1 --out /tmp/stati_3p.json
python3 tools/oracle_check.py /tmp/stati_3p.json
```

Esce 1 se compare uno scarto non spiegato. Le differenze residue attese sono
documentate in `docs/domande-aperte.md` (punti 2 e 16).

Il runner va lanciato **come scena, non con `--script`**: in modalità `--script`
Godot non istanzia gli Autoload, quindi `CardDB` non esisterebbe e il nucleo non
compilerebbe.

In alternativa, per validare i dati fuori da Godot:
```bash
pip install jsonschema
python -c "import json,jsonschema; jsonschema.validate(json.load(open('data/cards.json')), json.load(open('data/cards.schema.json'))); print('ok')"
```
