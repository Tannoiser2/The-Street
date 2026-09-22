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

# Valida i dati contro lo schema (esce 1 se qualcosa non torna: usabile in CI)
godot --headless res://scenes/validate_data.tscn

# Verifica che il validatore rifiuti davvero i dati non conformi
godot --headless res://scenes/test_schema_validator.tscn

# Partite headless con RandomBot
godot --headless res://scenes/headless_runner.tscn -- --games 100 --players 3 --seed 1
```

Il runner va lanciato **come scena, non con `--script`**: in modalità `--script`
Godot non istanzia gli Autoload, quindi `CardDB` non esisterebbe e il nucleo non
compilerebbe.

In alternativa, per validare i dati fuori da Godot:
```bash
pip install jsonschema
python -c "import json,jsonschema; jsonschema.validate(json.load(open('data/cards.json')), json.load(open('data/cards.schema.json'))); print('ok')"
```
