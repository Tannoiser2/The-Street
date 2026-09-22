# Domande aperte per il designer

Registro delle ambiguità incontrate durante l'implementazione. Formato: regola, dubbio, lettura provvisoria adottata.

## Già note al momento del passaggio

1. ~~**Mulino**~~ — **RISOLTA in M4:** aggiunto il campo `terrain_adjacent` alla
   carta e allo schema, come suggeriva la domanda stessa. `BuildRules.terrain_ok`
   lo legge; nessun caso speciale nel codice (principio 3). Il requisito è ora
   verificato da tre test: pianura con fiume accanto è legale, senza fiume no, e
   un fiume a due colonne di distanza non basta.
2. **Verticalità con arrotondamenti** — la metà "proporzionale" del premio produce frazioni. Lettura provvisoria: arrotondare per ciascun proprietario; il totale può quindi differire di ±1 dal premio.
3. **Scavo condiviso** — chi sotterra un edificio altrui prende +1 PV. Serve tracciare in `Building` chi ha costruito la sopraelevazione.
4. **Effetti delle carte** — tutti ancora in `effect_text`. Vedi Milestone 4.

## Emerse durante la Milestone 1

5. ~~**Doppia copia di `cards.json`**~~ — **RISOLTA**. Il designer ha confermato
   che il master è `data/cards.json` e ha lasciato la scelta del metodo.
   Adottata la seconda delle due opzioni pulite proposte: `project.godot` è stato
   spostato nella radice del repository, quindi `res://data/cards.json` *è* il
   master. La copia in `godot/data/` è stata eliminata e non esiste più nulla da
   sincronizzare. Scartato lo script di copia pre-build: avrebbe lasciato due
   file e un passaggio che si può dimenticare.
   `validate_data.tscn` ora fallisce se una copia di `cards.json` ricompare
   fuori da `res://data/`.

6. ~~**Verticalità, denominatore della metà proporzionale**~~ — **RISOLTA in M3**,
   e l'implementazione era già corretta. Due conferme indipendenti:
   il regolamento dice "l'altra metà si ripartisce fra tutti i proprietari in
   proporzione agli edifici che vi hanno, **sotterrati compresi**"; e il
   simulatore, in modo C, costruisce `cnt` scorrendo binari e pila **senza alcun
   filtro di stato** (`simulatore_riferimento.py`, righe 533-545).
   Nessuna modifica necessaria.

7. **Conteggio delle carte: il brief dice 181, il JSON ne ha 165** — scarto di 16.
   Somma effettiva: 60 edifici + 26 personaggi + 25 potenziamenti + 24 eventi
   + 14 monumenti + 16 eredita = 165 (169 contando i 4 terreni).
   I dati pero' sono internamente coerenti: 5 personaggi per era x 5 ere + 1
   Dinastia = 26, e i 25 reclutabili coincidono con le "25 abilita reali" citate
   in `reference/README.md`. Anche lo schema fissa min=max su tutte le collezioni
   e i conteggi tornano.
   Lettura provvisoria: il numero 181 nel brief e' verosimilmente vecchio, i dati
   sono completi. Nessuna modifica fatta.
   Da notare: `characters` e' l'unica collezione **senza** `minItems`/`maxItems`
   nello schema, quindi e' anche l'unica in cui mancherebbero carte senza che la
   validazione se ne accorga. Se 26 e' il numero giusto, conviene fissarlo.

## Emerse durante la Milestone 2

Le azioni sono implementate con la lettura piu' letterale del regolamento, come
chiede il brief. Dove due passaggi si possono leggere diversamente, la scelta e'
segnata qui invece di essere data per buona.

8. ~~**Reclutamento: "in piedi" o "intatto"?**~~ — **RISOLTA dal designer:**
   *"reclutamento su edifici intatti (Il vescovo va in una chiesa attiva, non in
   una abbandonata)"*. Confermata l'implementazione: `ActionRules.quote_recruit`
   guarda solo gli intatti della colonna.

9. ~~**Potenziamento su un rudere**~~ — **RISOLTA dal designer:** *"Il
   potenziamento non ha senso farlo su un rudere"*. **Implementazione cambiata**:
   avevo adottato la lettura letterale, per cui "in piedi" includeva il rudere.
   Ora `quote_upgrade` richiede `is_alive()`. Con il punto 8 la coppia e'
   coerente: si investe solo su cio' che e' vivo.

10. ~~**Capienza dei potenziamenti**~~ — **RISOLTA in M4, ed era un mio errore.**
    Avevo scritto che nessuna carta dichiara una capienza diversa: avevo cercato
    un campo, non nel testo. Quattro edifici la dichiarano nel proprio
    `effect_text` — Chiesa, Abbazia, Accademia (2) e Duomo (3) — mentre la M2 ne
    forzava 1 per tutti. Aggiunto il campo `upgrade_slots` alle 4 carte e allo
    schema; `ActionRules` lo legge dalla carta.

11. ~~**Bosco: "il restauro costa 1 in meno" — 1 di cosa?**~~ — **RISOLTA dal
    designer:** *"Pietra"*. Confermata l'implementazione.

12. ~~**Piu' reclutamenti nella stessa era**~~ — **RISOLTA dal designer:**
    *"nessun limite al reclutamento"*. Confermata l'implementazione: un
    personaggio per lavoratore specializzato, quindi fino a 3 per era, 4 con
    Dinastia.

13. ~~**Sepoltura sotto un rudere**~~ — **RISOLTA dal designer:** *"si la
    sepoltura va dove si ha un edificio che ancora e' in piedi"*. Confermata
    l'implementazione (`is_standing()`).
    Da tenere presente: nel vocabolario del regolamento "in piedi" comprende il
    rudere ("Rudere. In piedi ma spento"), quindi **un rudere puo' ospitare uno
    scheletro**. E' l'unico punto in cui "in piedi" resta inclusivo, dopo che i
    punti 8 e 9 hanno ristretto reclutamento e potenziamento ai soli intatti. Se
    l'intenzione era "intatto" anche qui, e' una riga.

14. **Potenziamenti Struttura — spiegato meglio** (era scritto male).

    Il regolamento dice che i potenziamenti **Struttura** danno "resistenza
    permanente, segnata con un cubetto nero". Un cubetto = +1. Le carte Struttura
    sono sei, e cinque dicono esattamente questo:

    | carta | testo | implementato in M2 |
    |---|---|---|
    | `po_palizzata` | Struttura: +1 res. | +1 ✅ |
    | `po_fondamenta_in_pietra` | Struttura: +1 res. | +1 ✅ |
    | `po_bastioni` | Struttura: +1 res. | +1 ✅ |
    | `po_contrafforte` | Struttura: +1 res. | +1 ✅ |
    | `po_merlatura` | Struttura: +1 res. **L'edificio conta anche come Militare.** | +1, ma la seconda frase **no** |
    | `po_cannoniere` | Struttura: +1 res **(+2 su edificio Militare)**. | +1 sempre, anche su un Militare dove dovrebbe essere +2 |

    Quindi: la parte `+1` funziona su tutte e sei. Mancano **due** pezzi, ed
    entrambi sono lavoro della M4 sul blocco potenziamenti:
    - `po_cannoniere` deve dare +2 invece di +1 quando l'edificio e' Militare
      (nello schema: `resistance` con `target: {class: ["militare"]}`);
    - `po_merlatura` deve aggiungere la classe Militare all'edificio
      (`rule_override: counts_as_class`), cosa che ne cambia anche la continuita'
      di classe e la reazione agli eventi che colpiscono i Militari.

    Discorso diverso per le altre due famiglie: **Arte** (9 carte) e **altro**
    (10 carte). In M2 la carta viene attaccata all'edificio e pagata, ma **non
    produce ancora nulla** — "Arte: +1 PV" non assegna punti, "Quando abiti
    questo edificio, +1 pietra" non da' pietra. Sono i loro effetti specifici, e
    sono esattamente cio' che la M4 deve strutturare. Nessun potenziamento non
    Struttura ha oggi un effetto attivo.

15. ~~**Un lavoratore per colonna**~~ — **CONFERMATA dal designer.** La regola
    non era implementata nello scheletro; aggiunta in M2 e ora confermata.

## Emerse durante la Milestone 3 (allineamento all'oracolo)

16. **Il simulatore non può rappresentare i salti di livello** — differenza
    residua documentata, non una divergenza di regola.
    Il simulatore tratta la colonna come una pila contigua: l'altezza è
    `len(stack[c])`, cioè il **numero** di edifici sopraelevati. In v1.5 un
    edificio largo sta tutto a un livello solo, "il più alto delle basi + 1",
    quindi in una delle sue colonne può trovarsi a livello 2 senza che esista
    un livello 1 sotto di lui. La colonna è alta 2, ma di edifici sopraelevati
    ne ha uno.
    Su 180 partite di test questo riguarda 131 colonne e vale 908 PV di scarto
    sul totale. **Godot segue il regolamento** ("Per colonna secondo l'altezza:
    2 / 6 / 12 / 20 per 1 / 2 / 3 / 4+ livelli"); il simulatore non può seguirlo
    perché il suo modello non rappresenta il salto.
    Nessuna azione: è un limite dell'oracolo, come quelli già elencati in
    `reference/README.md`.

17. ~~**Dispersione delle risorse a fine era 5**~~ — **RISOLTA dal designer:**
    *"nessun limite alle risorse, serve per lo spareggio"*.
    **Implementazione cambiata**: `EraRules.end_era` applica la dispersione solo
    nelle ere 1-4. Dopo l'era 5 le risorse residue restano intatte, perché sono
    il secondo criterio di spareggio. Coerente col regolamento, che mette la
    dispersione fra i passi che preparano l'era successiva.

### Due bug trovati dal confronto, già corretti

Non sono domande, ma vale la pena che restino a verbale.

- **Doppio censimento nell'era 5.** `end_era` pagava il censimento in tutte e
  cinque le ere, e `Scoring._census_final` lo ripagava subito dopo. L'era 5 non
  ha evento e il suo censimento *è* il "Censimento finale", voce 1 del conteggio.
  Il canale rendita risultava gonfiato di circa sei volte. Dopo la correzione
  coincide con l'oracolo **esattamente**, su tutte le partite di test.

- **Sotterramento con copertura parziale.** Il codice marcava sotterrata ogni
  base su cui si costruiva, anche quando il nuovo edificio ne copriva solo una
  parte; e non rivalutava mai una base coperta a metà quando strati successivi
  ne completavano la copertura. Il regolamento è esplicito: "Una rovina è
  sotterrata quando l'unione degli strati successivi copre **interamente** la
  sua proiezione, anche se quegli strati appartengono a ere diverse".
  Sbagliava in entrambe le direzioni: su 60 partite, 52 sotterrati su 443 erano
  illegittimi, e molti legittimi non venivano mai riconosciuti. Corretto con
  `Grid.refresh_buried()`, ricalcolato dopo ogni costruzione: i sotterrati
  passano da 443 a 932 e le violazioni a zero.


## Emerse durante la Milestone 4 (effetti, blocco eventi)

18. **"Il primo terrapieno di ogni giocatore in quest'era costa 0"** (ev_bonifiche)
    — non è detto se sia il primo *slot* di terrapieno o la prima *costruzione*
    che ne richiede uno. Una costruzione larga può averne due o tre.
    Lettura adottata: **il primo slot**, quindi una costruzione con due colonne
    nude ne paga comunque una. Da confermare.

19. **Due override dichiarati ma non ancora applicati** — sono nei dati e nello
    schema, e `Effects.NOT_YET_APPLIED` li elenca, con un test che verifica che
    l'elenco sia esatto: non possono essere dimenticati in silenzio.
    - `no_production_last_round` (ev_anni della fame): serve il concetto di
      "ultimo round dell'era", che oggi il motore non ha — l'era finisce quando
      tutti hanno esaurito i lavoratori, senza una nozione esplicita di round.
    - `free_upgrade_on_loss` (ev_eruzione): "chi perde un edificio pesca un
      potenziamento gratis". Richiede di pescare dal mazzo durante la risoluzione
      dell'evento, e di decidere che cosa significhi "perdere" (rudere? rovina?
      entrambi?). Serve la tua risposta prima di implementarlo.


## Emerse esaminando materiali/Carte.pdf (preparazione M5)

Il PDF è stato aperto **solo per la grafica**, come prescrive il brief: nessun
dato è stato importato da lì. Ma due confronti fra ciò che è stampato e
`data/cards.json` non tornano, e vanno segnalati.

20. **Il PDF è alla calibrazione precedente alla v1.5.** Verificate tutte e
    cinque le ere (pagine 19, 21, 23, 25, 27), leggendo carta per carta.

    **Scavo — il risultato non lascia margini.** Sono 44 gli edifici su 60 in cui
    `cards_simulatore_legacy.json` e `data/cards.json` danno un valore diverso.
    Su **tutti e 44** il PDF stampa il valore del legacy, e su **nessuno** quello
    della v1.5. Gli altri 16 hanno lo stesso valore nei due file, quindi non
    discriminano (l'intera era 5 ha Scavo 0 ovunque).

    | era | carte che discriminano | il PDF concorda con legacy |
    |---|---:|---:|
    | 1 | 11 | 11 |
    | 2 | 12 | 12 |
    | 3 | 11 | 11 |
    | 4 | 10 | 10 |
    | 5 | 0 | — |

    **Larghezza** — il badge «N slot» coincide su **58 carte su 60**. Le due
    eccezioni sono entrambe nell'era 1: **Villaggio palizzato** e **Tumulo
    funerario** stampano «1 slot», `cards.json` dice `width: 2`. Nelle ere 2–5
    non c'è una sola divergenza.

    Non è un problema di grafica: se queste carte andassero in stampa,
    contraddirebbero le regole che il motore implementa. Da decidere: si
    ristampa il PDF dai dati v1.5, o i dati tornano a quei valori? Le due
    larghezze dell'era 1 vanno decise a parte, perché non seguono lo stesso
    schema dello Scavo — potrebbero essere un cambio voluto della v1.5, o un
    refuso in un file o nell'altro.

21. **Nessun testo estraibile, ma l'ordine È derivabile.** Tutte e 54 le pagine
    hanno zero testo: nomi ed effetti sono curve o raster. Un'illustrazione non
    si può quindi associare a un id leggendo il nome stampato.

    L'ordine di impaginazione però segue una regola esatta, verificata su tutte
    e cinque le pagine: **è l'ordine di `cards.json` con la quinta carta spostata
    in settima posizione**. In simboli, JSON `[1,2,3,4,5,6,7,…]` → PDF
    `[1,2,3,4,6,7,5,8,…]`.

    | era | quinta carta nel JSON | sua posizione nel PDF |
    |---|---|---|
    | 1 | Menhir | 7ª |
    | 2 | Torre di vedetta | 7ª |
    | 3 | Conceria | 7ª |
    | 4 | Banco | 7ª |
    | 5 | Monumento ai caduti | 7ª |

    Cinque conferme su cinque, nessuna eccezione. **Non serve quindi una tabella
    di corrispondenza dal designer**: l'accoppiamento carta↔illustrazione si
    ricava. Resta comunque prudente far verificare il risultato con un provino a
    contatto, visto che un errore qui sarebbe silenzioso.

22. **Le 9 carte colonna hanno nomi propri** (Pianura dei cantieri, Pianura del
    mercato, Collina delle cave, Fiume antico, Bosco sacro…) e un riquadro
    «Prosperità Urbana» in fondo. `data/cards.json` modella 4 terreni generici.
    Se le 9 carte portano effetti distinti, oggi non sono nei dati. Da chiarire.
