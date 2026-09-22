# La Strada delle Ere — versione digitale (Godot 4)

Pacchetto di partenza per l'implementazione digitale del gioco da tavolo, ruleset v1.5.

**Inizia da `docs/BRIEF_CLAUDE_CODE.md`.**

- `data/` — database delle carte (fonte unica) e schema di validazione
- `godot/` — progetto Godot con lo scheletro del nucleo di regole
- `reference/` — regolamento e simulatore Python usato come oracolo
- `docs/` — brief di sviluppo e registro delle domande aperte

Per validare i dati:
```
pip install jsonschema
python -c "import json,jsonschema; jsonschema.validate(json.load(open('data/cards.json')), json.load(open('data/cards.schema.json'))); print('ok')"
```
