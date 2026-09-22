# LA STRADA DELLE ERE — Brief di sviluppo per Claude Code

## Leggi prima questo

Stai portando in Godot 4 un gioco da tavolo originale, **La Strada delle Ere** (2–4 giocatori, ruleset **v1.5**). Il design è stato bilanciato su circa 80.000 partite simulate e 15 round di audit indipendenti: **le regole sono stabili, non vanno reinventate**. Il tuo compito è implementarle fedelmente e poi costruirci sopra un'interfaccia.

Ordine di lettura: questo brief → `reference/regolamento-completo.html` (la specifica) → `data/cards.json` (i dati) → gli script in `godot/scripts/`.

Il designer ti passerà anche i PDF dei materiali di stampa: **usali solo per la grafica** (illustrazioni, cornici, colori d'era, impaginazione delle carte). **Non rileggere mai i dati dai PDF**: la fonte unica è `cards.json`.

---

## Principi architetturali (non negoziabili)

1. **Separazione netta fra nucleo e visualizzazione.** Tutto ciò che sta in `scripts/core/` e `scripts/rules/` è GDScript puro: nessun `Node`, nessuna scena, nessun riferimento alla grafica. Deve poter girare headless.
2. **Uno strato di comandi.** Interfaccia e bot modificano lo stato **solo** attraverso `GameController`. Il controller valida con le funzioni pure di `rules/`, applica, ed emette segnali che la visualizzazione ascolta.
3. **Fonte unica dei dati.** Nessun numero di bilanciamento scritto nel codice. Costi, resistenze, forze degli eventi, premi di verticalità, tetto delle risorse: tutto viene da `CardDB.constants` o dalle righe di carta. Se ti serve una costante che non esiste, aggiungila al JSON e allo schema, non al codice.
4. **Determinismo.** Una partita è interamente determinata dal seme e dalla sequenza di comandi. Tutta la casualità passa da `gs.rng`. È ciò che permette i test contro l'oracolo e i replay.
5. **Sviluppo incrementale.** Ogni milestone deve chiudersi con qualcosa che gira.

---

## Struttura

```
data/
  cards.json           fonte unica (181 carte + costanti + terreni)
  cards.schema.json    validazione: esegui prima di ogni build
godot/scripts/
  core/                enums, Building, PlayerState, Grid, GameState  (dati)
  rules/               BuildRules, EraRules, Scoring                  (funzioni pure)
  commands/            GameController                                 (unica porta d'ingresso)
  data/                CardDB (autoload)
  ai/                  RandomBot, headless_runner
reference/
  regolamento-completo.html   la specifica
  simulatore_riferimento.py   oracolo Python (leggi il README prima)
```

---

## Stato dello scheletro

**Già implementato con logica reale**: modello dati, griglia con livelli e cima di colonna, costruzione nel binario e sopra (basi, terrapieno, spolia, sconto macerie, continuità di classe, cap +1 livello per colonna per era, sconto pianura, costo flessibile), attivazione con produzione degli edifici e Prosperità urbana, risoluzione degli eventi a due soglie (rudere/rovina) con Vetustà, censimento, dispersione, e quattro delle sette voci del punteggio finale (censimento, verticalità in modo C, continuità, scavo, scheletri).

**Marcato con `TODO`**: potenziare, restaurare, reclutare, Dinastia, spoliazione, sepoltura dei personaggi a fine era, ordine snake in 2 giocatori, Monumenti ed Eredità, effetti finali, e soprattutto **gli effetti specifici delle carte** (vedi sotto).

**Il codice non è mai stato eseguito in Godot.** È scritto per Godot 4 ma va compilato e corretto: aspettati errori di tipizzazione e piccoli bug. Il primo compito della Milestone 1 è farlo girare.

---

## Milestone

### M1 — Il nucleo gira
Far compilare lo scheletro. Registrare `CardDB` come Autoload. Far girare `headless_runner.gd` con `RandomBot` per 100 partite senza errori né loop infiniti. Scrivere test di validazione del JSON contro lo schema.

**Fatto quando**: 100 partite complete headless, a 2, 3 e 4 giocatori, senza crash.

### M2 — Tutte le azioni
Implementare le azioni mancanti seguendo lo schema di `build()`: `upgrade`, `restore` (con appropriazione del rudere altrui), `recruit` (specializzazione del lavoratore per l'era), `buy_dynasty` (costo a scalare per era da `cost_by_era`), `despoil`. Sepoltura dei personaggi a fine era (ere 1–4, uno per edificio vivo). Snake in 2 giocatori.

**Fatto quando**: ogni azione ha un test unitario che ne verifica legalità e effetto, inclusi i casi di rifiuto.

### M3 — Oracolo
Allineare il nucleo al simulatore Python su una batteria di partite deterministiche. Le divergenze vanno investigate una per una: spesso rivelano una regola ambigua, che va chiarita col designer invece che decisa da te.

**Fatto quando**: su almeno 50 partite di test i punteggi finali coincidono, oppure ogni differenza residua è documentata e giustificata.

### M4 — Effetti delle carte
Gli effetti specifici sono oggi solo testo (`effect_text`). Vanno tradotti in dati strutturati, carta per carta, con un sistema di hook (`on_activate`, `on_build`, `on_event`, `on_final_scoring`, `on_era_end`). Proponi uno **schema chiuso di tipi di effetto** prima di implementarli: è meglio aggiungere al JSON un campo `effects` strutturato che interpretare le stringhe a runtime.

Priorità: i 24 eventi (il pattern "classe ±N" e "terreno −N" copre metà del mazzo), poi i personaggi, poi gli edifici, poi potenziamenti, Monumenti ed Eredità.

### M5 — Interfaccia
Vista dall'alto della griglia 5 binari × colonne, con le sagome in vista laterale per le colonne sopraelevate. Plancia del giocatore con le carte possedute, i cubetti di Vetustà e resistenza, i personaggi sepolti. Mercato, file dei personaggi e dei potenziamenti, evento dell'era visibile. Un'anteprima del costo prima di confermare una costruzione (usa `BuildQuote`: ha già il motivo del rifiuto in italiano).

### M6 — Bot
Portare le cinque strategie del simulatore. **Attenzione ai limiti documentati** in `reference/README.md`: nessun peso fisso fra risorse, e il valore di un personaggio va calcolato dalla sua abilità reale, non stimato.

---

## Invarianti di regola — se il codice le viola, è un bug

- Un edificio **intatto altrui** non può mai trovarsi sotto una nuova costruzione.
- Una colonna non guadagna **più di un livello per era**.
- Un edificio sta **tutto a un solo livello**: il più alto delle basi + 1.
- Almeno una colonna dell'impronta di una sopraelevazione deve avere una **base vera**.
- Un edificio che cambia stato **conserva il proprio ingombro**.
- *Sotterrato* è una **condizione di posizione**, non uno stato: un edificio sotterrato può essere stato intatto (spianato), rudere o rovina.
- Uno spianato vale **Scavo 0**; il suo personaggio sepolto vale comunque.
- Lo Scavo va **al proprietario dell'edificio sepolto**, non a chi ci ha costruito sopra.
- Il **censimento segue l'evento**: si conta solo ciò che è sopravvissuto.
- I personaggi dell'**era 5 non si seppelliscono**.
- Le risorse a fine era non superano **5**.

---

## Convenzioni

GDScript tipizzato ovunque possibile. Nomi di dominio in italiano, coerenti col regolamento (`rudere`, `rovina`, `terrapieno`, `vetusta`), il resto in inglese. Nessuna stringa di interfaccia nel nucleo, tranne i `reason` delle `BuildQuote`, che sono pensati per essere mostrati al giocatore. Commit piccoli, uno per azione o regola.

Quando una regola ti sembra ambigua, **non inventare**: apri una nota in `docs/domande-aperte.md` e prosegui con la lettura più letterale del regolamento. Il designer risponderà.
