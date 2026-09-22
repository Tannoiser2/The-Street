# Domande aperte per il designer

Registro delle ambiguità incontrate durante l'implementazione. Formato: regola, dubbio, lettura provvisoria adottata.

## Già note al momento del passaggio

1. **Mulino** — il requisito "pianura adiacente a fiume" è solo nel testo effetto, non nel campo `terrain`. Va gestito come caso speciale o va aggiunto un campo `terrain_adjacent`?
2. **Verticalità con arrotondamenti** — la metà "proporzionale" del premio produce frazioni. Lettura provvisoria: arrotondare per ciascun proprietario; il totale può quindi differire di ±1 dal premio.
3. **Scavo condiviso** — chi sotterra un edificio altrui prende +1 PV. Serve tracciare in `Building` chi ha costruito la sopraelevazione.
4. **Effetti delle carte** — tutti ancora in `effect_text`. Vedi Milestone 4.

## Emerse durante la Milestone 1

5. **Doppia copia di `cards.json`** — il file esiste identico in `data/cards.json`
   (dichiarata fonte unica nel brief) e in `godot/data/cards.json` (quella che
   `CardDB` carica davvero, perché `res://` è la cartella `godot/`). Finché
   restano due file possono divergere in silenzio, contro il principio 3.
   Lettura provvisoria adottata: **nessuna ristrutturazione** — il test
   `validate_data.tscn` confronta le due copie e fallisce se differiscono.
   Da decidere: symlink, copia in fase di build, o spostare il progetto Godot
   alla radice del repo?

6. **Verticalità, denominatore della metà proporzionale** — `Scoring._verticality`
   divide la seconda metà del premio contando *tutti* gli edifici della colonna
   (`in_column`), quindi anche i sotterrati e le rovine, non solo quelli in piedi.
   Cambia sensibilmente il punteggio. Lettura provvisoria: lasciato com'è,
   nessuna modifica in M1. Va confermato prima dell'allineamento all'oracolo (M3).
