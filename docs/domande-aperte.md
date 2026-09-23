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

14. ~~**Potenziamenti Struttura**~~ — **RISOLTA in M4**: i due pezzi che
    mancavano sono implementati. `po_cannoniere` dà ora +2 su edificio Militare
    e +1 altrove; `po_merlatura` dichiara `counts_as_class`, che resta però fra
    gli inerti (la classe aggiunta tocca continuità ed eventi, e va fatta con
    cura). E le due famiglie che non facevano nulla ora funzionano: tutti e 9 i
    potenziamenti Arte assegnano PV, condizionali compresi (Idolo e Reliquia
    valgono di più su edificio Religione), e degli «altro» funzionano Scavo,
    ibridi e PV secchi.
    Resta inerte solo `po_stalli_mercantili` (l'affitto +1), più i tre «quando
    abiti qui» che aspettano il hook di attivazione. Qui sotto il testo
    originale, per riferimento.

    **Potenziamenti Struttura — spiegato meglio** (era scritto male).

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

    **RISOLTA dal designer:** *"Usa i dati (infatti le sagome sono già a due
    slot) l'errore è sulle carte quindi per il momento usa il PDF così com'è e
    lo correggerò appena posso"*.
    Quindi: `data/cards.json` resta la fonte, **nessun dato modificato**, e il
    PDF si usa com'è per la sola grafica. Le sagome fustellate confermano la
    v1.5 in modo indipendente: Villaggio palizzato e Tumulo funerario sono
    sagome da due caselle, come dice il campo `width`.

    **Conseguenza da non dimenticare in M5:** le facce delle carte estratte dal
    PDF portano 44 valori di Scavo obsoleti. Non vanno mostrate come faccia
    della carta in gioco — quella va disegnata dai dati. Servono come
    riferimento grafico, non come contenuto.

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

23. **Corrispondenza sagoma → carta: non derivabile.** Le 60 sagome (più le 60
    grigie del lato inattivo) sono l'arte pulita giusta per il tabellone, senza
    testo né numeri. Ma il loro ordine di impaginazione non segue né le ere né
    l'ordine delle carte: sono impaccate per forma, per risparmiare cartoncino.
    Il Teatro dell'era 2 sta in dodicesima posizione, in mezzo all'era 1.

    Ho provato ad accoppiarle automaticamente alle carte per somiglianza
    d'immagine, ed è fallito: 10 biiezioni su 60, margine sul secondo candidato
    sotto lo 0,02. Le sagome sono fustellate con sfondo vuoto e proporzioni
    molto diverse dalla banda d'arte della carta.

    Sono quindi estratte con numerazione stabile in ordine di lettura, più un
    provino a contatto numerato. Serve la corrispondenza numero → id: o la dai
    tu, o la ricavo a vista e la fai validare. È lavoro da farsi una volta sola,
    ma un errore qui metterebbe l'edificio sbagliato sul tabellone in silenzio.

24. **«I tuoi edifici in questa colonna» comprende la carta stessa?** — Castrum
    e Biblioteca usano la stessa formula, ma tirano in direzioni opposte.
    Lettura adottata: **sì, comprende se stessa.** È uno dei tuoi edifici in
    quella colonna, e il testo non lo esclude. Conseguenze:
    - il Castrum si dà +1 resistenza da solo, oltre che agli altri;
    - la Biblioteca conta anche la propria classe (Cultura) fra quelle distinte.

    Chi deve escludersi lo dice esplicitamente: il Monumento ai caduti parla di
    «ogni **altro** tuo edificio Militare», ed è modellato con `is_self: false`.
    «Adiacente» resta invece sempre escludente, perché un edificio non è
    adiacente a se stesso.
    Se per il Castrum intendevi solo gli altri, è una riga nei dati.

25. **Due miei errori di modellazione, corretti** — non sono domande, ma vale la
    pena che restino a verbale perché erano dello stesso tipo.
    Avevo usato `cap` (tetto sui *punti*) dove il testo dice «fino a N edifici»,
    che è un limite sul *numero di bersagli*, cioè `times`. Riguardava il Parco
    archeologico («fino a 2 tuoi edifici») e il Soprintendente («fino a 3 tuoi
    edifici Sotterrati»). Con `cap` il Parco archeologico avrebbe reso al
    massimo 2 PV invece dello Scavo di due edifici, che può valere 12.
    I casi con `cap` corretto restano Urbanista e Veterano, che dicono «max +4»
    riferito ai punti.

26. ~~**Personaggi dell'era 5 e punteggio finale**~~ — **RISOLTA:**
    `PlayerState.final_characters` raccoglie i personaggi alla chiusura dell'era
    5, prima dell'azzeramento, e il conteggio finale li legge. Archeologo,
    Soprintendente, Urbanista e Veterano ora contano davvero.
    Qui sotto il testo originale.

    **Personaggi dell'era 5 e punteggio finale: un problema di tempi.** Quattro
    personaggi dell'era 5 hanno abilità «Finale:» — Archeologo, Soprintendente,
    Urbanista, Veterano — ma `EraRules.end_era` azzera `specialized_characters`
    alla chiusura dell'era 5, **prima** che `Scoring.final_scoring` giri. Al
    momento del conteggio quei personaggi non esistono più.
    Non l'ho corretto perché tocca il blocco personaggi e va deciso dove vivono:
    il regolamento dice che i personaggi dell'era Moderna «si scartano», ma
    parla della sepoltura (niente scheletro), non delle loro abilità finali.
    Serve un elenco che sopravviva alla fine dell'era, tipo
    `PlayerState.final_characters`. Da fare col prossimo blocco.

27. ~~**Capotribù e Ingegnere militare: approssimazione dichiarata**~~ —
    **RISOLTA per il Capotribù.** Il legame lavoratore→edificio abitato esiste
    ora (`Building.protected_by` e `PlayerState.character_targets`), e il
    Capotribù dà il suo +1 al solo edificio che il suo lavoratore abita, non a
    tutti i propri edifici protetti. Stessa cosa per Legionario e Cavaliere, che
    non erano implementati affatto.
    **Resta aperto l'Ingegnere militare**: «uno a tua scelta +2» è una scelta
    del giocatore, e con un bot casuale cade sul primo Militare incontrato. Il
    totale è corretto, la distribuzione no. Si chiude quando l'interfaccia
    potrà chiedere la scelta (M5).
    Qui sotto il testo originale.

    **Capotribù e Ingegnere militare: approssimazione dichiarata.** Due
    personaggi parlano di un edificio *scelto*, e il motore non ha ancora quel
    livello di dettaglio.
    - Capotribù: «l'edificio protetto da **questo lavoratore** ha +1 res». Non
      tracciamo quale edificio protegga un dato lavoratore, quindi l'effetto è
      modellato su *tutti* i propri edifici protetti. Con un solo lavoratore che
      protegge, coincide; con due o più è più generoso del dovuto.
    - Ingegnere militare: «i tuoi edifici Militari hanno +1 res; **uno a tua
      scelta** +2». Il secondo effetto è modellato con `times: 1`, quindi cade
      sul primo Militare incontrato invece che su uno scelto. Il totale è
      corretto, la distribuzione no — e conta, perché decide quale edificio
      sopravvive.

    Entrambi si risolvono tracciando il legame lavoratore→edificio protetto, che
    serve anche a Legionario e Cavaliere. Da fare insieme.

28. **Il mio registro degli inerti mentiva, ed è stato riparato.** La chiave era
    la coppia `hook:op`, non il tipo di carta. Risultato: lo Sciamano risultava
    applicato perché `on_event:resistance` lo era per eventi ed edifici, mentre
    nessun codice scorreva i personaggi come sorgente — **non ha mai dato un
    punto di resistenza**, e il test che avrebbe dovuto accorgersene diceva che
    andava tutto bene.
    Ora la chiave è `tipo:hook:op`. Il numero onesto degli inerti è passato da
    12 a 25 nel momento della riparazione, ed è sceso a 16 implementando questo
    blocco. Vale la pena ricordarlo quando quel numero sembra buono.

29. **`production_delta` resta inerte, e il motivo è un'ambiguità.** Due carte
    lo usano e nessuna delle due dice *quale* risorsa aumenta.
    - Ponte: «Quartiere: **+1 produzione** agli edifici adiacenti». Un edificio
      adiacente che produce 1 pietra passa a 2 pietra, o guadagna anche 1 oro?
      L'avevo modellato come `+1 pietra e +1 oro`, che è quasi certamente
      sbagliato: raddoppierebbe il valore su un edificio che produce entrambe.
    - Industriale: «le tue prime 2 **produzioni di oro** danno +1». Qui la
      risorsa è detta, ma «produzione di oro» va definito: è ogni edificio che
      paga oro, o ogni attivazione in cui incassi oro?

    Lettura provvisoria: **nessuna**, l'op resta dichiarata e non applicata,
    perché qualunque scelta cambierebbe l'economia in modo misurabile e
    preferisco chiedertelo. La più probabile per il Ponte è «+1 della risorsa
    che già produce», che però non è esprimibile senza un terzo valore nello
    schema (tipo `same_as_base`).

30. **La protezione non era mai entrata in gioco.** Il regolamento la mette al
    centro del turno — «un edificio abitato resiste, uno abbandonato no» — ma
    `RandomBot` chiamava `place_worker(col)` senza mai passare un edificio da
    abitare. Misurato prima della correzione: **0 edifici protetti su 830**, in
    30 partite.

    Conseguenze, tutte silenziose: il predicato `protected` non ha mai
    discriminato nulla, i tre eventi «Edifici non protetti: −1 res extra»
    colpivano sempre tutti, e Legionario, Cavaliere e Capotribù non avevano nulla
    a cui attaccarsi. Nessun test se n'era accorto, perché tutti verificavano il
    comportamento *dato* un edificio protetto, mai che ce ne fosse uno.

    Ora il bot abita un proprio edificio in piedi quando c'è, e a metà partita si
    contano ~20 edifici protetti con protezione totale 42 su 30 partite — il
    surplus oltre il +2 viene dai personaggi. I PV medi salgono da 54,2/44,8/45,2
    a 58,2/49,3/47,1: più edifici sopravvivono agli eventi.

31. **L'Impronta e lo scheletro sono lo stesso gesto fisico.** Il regolamento
    descrive entrambi come «infilare la carta sotto un edificio», e per entrambi
    pone un limite di uno per edificio, ma li enuncia separatamente.

    Lettura adottata: **due cose distinte**, ciascuna col proprio limite. Un
    edificio può quindi portare un'Impronta *e* uno scheletro.
    Conseguenza che ho invece escluso: la carta dell'Incisore o del Retore è già
    sotto un edificio dal momento in cui la giochi, quindi **non viene sepolta
    una seconda volta** a fine era. Senza questa esclusione avrebbe pagato due
    volte — lo Scavo permanente *e* i punti scheletro.

    Se invece l'intenzione era che l'Impronta occupi lo slot dello scheletro (un
    edificio o porta un'Impronta o ospita un personaggio, non entrambi), è un
    controllo in più in `EraRules.bury_characters`.

32. **Il bersaglio dell'Impronta è una scelta, non l'edificio abitato.** «Infila
    questa carta sotto **un tuo edificio**»: il comando `recruit` accetta quindi
    un bersaglio esplicito, come `build` accetta la colonna. Il bot casuale
    prende il primo proprio edificio libero, che è un segnaposto: la scelta vera
    la farà l'interfaccia.

33. **Catacombe: «3 edifici sotterrati nella stessa colonna», di chi?** — il
    testo del Monumento non dice «propri», a differenza dei Fori Imperiali che
    dicono «4 **propri** edifici Sotterrati».
    Lettura adottata: **letterale**, contano i sotterrati di chiunque. Basta
    quindi che una colonna ne accumuli tre, e lo reclama il primo giocatore in
    ordine di turno nel momento in cui accade — anche senza averne sotterrato
    nessuno lui.
    Se l'intenzione era «3 tuoi», è una riga nei dati.

34. **A parità, chi reclama un Monumento?** Due giocatori possono soddisfare la
    condizione nello stesso istante (per esempio dopo un evento che sotterra
    edifici di entrambi). Adottato: **l'ordine di turno dell'era corrente**.
    Il regolamento non lo dice, perché al tavolo la simultaneità non capita
    quasi mai: qui invece la valutazione è puntuale e va decisa.

35. **I Colossali: larghezza 2 o 3? Le tre fonti non concordano.**

    | fonte | dice |
    |---|---|
    | campo `width` in `cards.json` | **3** per tutti e tre |
    | regolamento, sezione «Colossali» | «occupano **tre** caselle» |
    | testo delle carte | «**2** slot adiacenti» |

    Due fonti su tre dicono 3, e il badge stampato sulle carte dice «3 slot»:
    quindi il testo effetto contraddice **la carta stessa**, non solo il JSON.
    Probabile residuo di una versione precedente, coerente con il fatto che il
    PDF è a una calibrazione più vecchia (punto 20).

    Lettura adottata: **width 3**, nessun dato modificato. Di conseguenza non ho
    implementato la regola variabile dell'Acquedotto — «3 pagando +1 pietra; in
    2 giocatori il terzo slot è vietato» — perché presuppone che la base sia 2.
    Se invece quella regola è viva, servono due campi nuovi (larghezza minima e
    massima, più il costo del terzo slot) e un vincolo sul numero di giocatori.
    A 2 giocatori la strada ha 5 colonne: un edificio da 3 ne occupa il 60%,
    che è forse proprio il motivo per cui la vecchia regola lo vietava.

36. **`colossal` non richiede codice, e questo è un risultato.** La sezione
    «Colossali» del regolamento elenca cinque proprietà: si attivano da ciascuna
    colonna che toccano, contano come strato in tutte, crollando diventano rovina
    ovunque, valgono il proprio Scavo una volta sola, e solo a proiezione
    interamente coperta.

    **Tutte e cinque derivano già dal modello generico**, cioè dal fatto che un
    edificio largo è *un* oggetto che copre più colonne. Le ho verificate una per
    una con dei test invece di scrivere codice che non serviva.

    Per non dire il falso, `colossal` non è fra gli override «applicati» ma in
    una terza categoria, `DESCRIPTIVE_OVERRIDES`: marcarlo applicato farebbe
    credere che una riga lo legga.

37. **`counts_as_class`: la classe acquisita è un campo a sé, non un bersaglio.**
    La Merlatura (`po_merlatura`) dice «Struttura: +1 res. L'edificio conta anche
    come Militare». Modellare la classe aggiunta dentro `target` sarebbe stato un
    abuso: `target` è un **selettore**, dice *quali* edifici l'effetto tocca, non
    *cosa* acquisiscono. Ho quindi aggiunto al formato un campo distinto,
    `adds_class`, e il bersaglio resta il selettore normale (`is_self`).

    La classe acquisita conta in quattro posti, e li ho verificati tutti e
    quattro: gli eventi che colpiscono una classe, la continuità, il
    reclutamento di un personaggio che richiede una classe, e il bonus di
    continuità in costruzione.

    Un dettaglio che poteva diventare un bug silenzioso: `Building.data` è la
    **carta condivisa** fra tutte le copie di quell'edificio, quindi
    `classes()` restituisce una *copia* dell'array quando ci sono classi
    acquisite. Se mutasse l'array della carta, un secondo edificio della stessa
    carta erediterebbe la Merlatura di un altro giocatore. C'è un test apposta.

    Conseguenza sull'esportazione: `export_states.gd` esporta ora `b.classes()`
    e non più `b.data["classes"]`, perché l'oracolo ricalcola la continuità dalle
    classi esportate e deve vedere la stessa realtà del motore. Il canale
    continuità resta esatto (1920 contro 1920 su 180 partite) e nelle partite
    reali l'effetto scatta davvero: 25 volte in 100 partite a 3 giocatori.

38. **Otto effetti inerti chiusi, tutti su decisione del designer.** Erano i
    punti che il regolamento non decideva. Qui la risposta adottata e la sua
    conseguenza nel codice.

    | carta | domanda | risposta |
    |---|---|---|
    | Stalli mercantili | «affitto» = Rendita (PV) o produzione (risorse)? | **Rendita**, quindi PV, e ricorre a ogni censimento |
    | Ponte | +1 di cosa, e a chi? | +1 di **cio' che l'edificio gia' produce**, anche agli edifici altrui |
    | Industriale | cos'e' «una produzione di oro»? | **ogni fonte**: il fiume e un edificio che produce oro sono due |
    | Anni della fame | cos'e' «l'ultimo round»? | **l'ultimo lavoratore di ciascuno**; salta la sola produzione base |
    | Eruzione | cos'e' «perdere un edificio»? | il **crollo in rovina**, non il rudere; si pesca coperto e si piazza subito |
    | Mercante | quando e come si scambia? | **1:1, nel proprio turno**, due volte per era, direzioni libere |
    | Vescovo | «il prossimo» si brucia? | **no**: aspetta il primo Religione |
    | Mecenate | conferma della lettura letterale | +1 PV **per carta Arte**, non per effetto |

    Tre conseguenze meritano di essere scritte, perche' non si vedono dai dati.

    **La Vetusta' accompagna la Rendita, non e' una voce a se'.** Il censimento
    paga solo gli edifici che rendono qualcosa: un edificio a Rendita 0 non
    paga nulla, nemmeno la Vetusta' accumulata. Gli Stalli mercantili possono
    percio' far parlare un edificio che prima taceva, e non gli aggiungono 1
    punto ma 1 + Vetusta'.

    **L'ordine fra il Ponte e l'Industriale e' fissato.** Il Ponte alza la
    produzione *prima* che si conti se quella produzione e' «di oro» per
    l'Industriale. Non cambia nulla oggi, perche' il Ponte da' +1 solo di cio'
    che l'edificio gia' produce e non puo' creare oro dal nulla, ma se un
    giorno un effetto potesse crearlo, l'ordine deciderebbe.

    **L'oro della Prosperita' non e' una produzione.** L'Industriale non lo
    alza: il Centro Urbano paga un premio, non una produzione di colonna. Se la
    lettura giusta fosse l'opposta, basta estendere `production_bonus` al ramo
    della Prosperita' in `EraRules.activate`.

    Chiusi anche questi, **non resta nessun effetto inerte**: vedi punto 39.

39. **Artista di corte: la carta che il designer ha riscritto.** Il testo
    stampato dice «il primo potenziamento che piazzi su un edificio altrui e'
    gratis e incassi 1 oro dal proprietario»: un incasso una tantum. La
    decisione del designer ne fa un'altra carta, e questa e' quella viva:

    - il potenziamento su un edificio **altrui** e' gratis, e **non conta nel
      limite di capienza** dell'edificio (uno per era);
    - chi piazza la carta prende **+1 cultura una tantum**, cioe' +1 PV subito;
    - e incassa **1 oro a ogni attivazione di quell'edificio, per tutta la
      partita**.

    Il testo della carta va quindi riscritto: oggi contraddice la regola.

    **Perche' l'incasso sta sull'edificio e non sul personaggio.** I
    personaggi durano un'era (`specialized_characters` si svuota a ogni
    `reset_for_era`), mentre questo incasso dura la partita. Se l'avessi
    cercato fra gli effetti attivi del giocatore, avrebbe smesso di pagare
    alla fine dell'era in cui si recluta l'Artista. Sta percio' su
    `Building.patrons`, che dice quanto oro quell'edificio paga a chi non ne
    e' proprietario. C'e' un test che svuota i personaggi, avanza l'era e
    verifica che l'incasso continui.

    **Due conseguenze.** Il potenziamento lo piazzi tu ma l'edificio e' suo:
    i PV della carta vanno a te, mentre un bonus di Struttura (il cubetto
    nero) resta attaccato all'edificio, e quindi **rinforza l'avversario**.
    Conviene percio' firmare con una carta Arte, non con una Struttura. E
    l'incasso del firmatario **non e' una produzione**: e' un taglio
    dell'artista, quindi l'Industriale non lo alza, come non alza l'oro della
    Prosperita'.

    **L'unica cosa rimasta ferma dal testo originale** e' che il regolamento
    vieta di potenziare un edificio altrui («infilate la carta sotto un
    *vostro* edificio»): questa carta e' l'unica eccezione a quel divieto in
    tutto il gioco.

40. **Un bersaglio scelto dal giocatore, approssimato in attesa della M5.**
    Il potenziamento gratuito dell'Eruzione va «piazzato subito», ma su *quale*
    edificio lo decide il giocatore. Finche' non c'e' interfaccia va sul primo
    edificio intatto con capienza libera, in ordine di uid. E' la seconda
    approssimazione di questo tipo, dopo l'Ingegnere militare (punto 27): sono
    entrambe scelte, non regole, e vanno riaperte in M5.

## Emerse durante la Milestone 5 (interfaccia)

41. **La plancia si puo' guardare, e questo cambia come si verifica.** Godot in
    modalita' `--headless` usa un driver di disegno finto e **non produce
    immagini**: per mesi l'unico modo di controllare l'interfaccia sarebbe
    stato affermare che i nodi esistono. Con un display virtuale (`xvfb-run`)
    piu' la modalita' Movie Maker di Godot si ottiene invece un PNG di una
    partita vera. Lo script e' `tools/scatta.sh`.

    Due conseguenze. La prima: ogni scelta grafica si verifica guardandola, non
    immaginandola — i primi tre difetti (il tratteggio dei sotterrati che
    copriva il nome, la riga dei cubetti illeggibile sul fondo scuro, la fascia
    laterale che non diceva a che quota fosse) li ho visti cosi', non
    ragionandoci. La seconda: si puo' mostrare al designer com'e' venuta una
    regola senza fargli compilare niente.

42. **La geometria e' un modulo puro, e si prova headless.** `BoardLayout` non
    e' un `Node` e non disegna: calcola soltanto dei riquadri. Serve due volte
    - a disegnare e, quando ci sara' l'input, a capire dove il giocatore ha
    cliccato - cosi' le due cose non possono divergere. E resta provabile in
    CI: `scenes/test_view.tscn` verifica fra l'altro che, in una partita
    giocata fino in fondo, **nessun riquadro esca dalla plancia** e **nessuna
    coppia di riquadri alla stessa quota si sovrapponga**, che e' l'invariante
    di regola «un edificio sta tutto a un solo livello» vista dallo schermo.

43. ~~**Due viste, perche' un edificio sopraelevato non sta su nessun
    binario.**~~ **RISOLTA dal designer: si fa in 3D.** Tessere colonna stese
    sul tavolo una a fianco all'altra, pannello verticale dietro a fare da
    cielo, sagome in piedi sugli slot. Gli assi vengono dal tavolo vero:
    **X** le colonne, **Z** i cinque binari con l'**era 1 davanti** e la 5 in
    fondo, **Y** le quote. Il problema sparisce da solo: l'altezza smette di
    essere un numero scritto e diventa altezza, e le due viste tornano una.

    La vista 2D resta, ma come **strumento di diagnosi**: per capire cosa c'e'
    sotto a una plancia piena di sepolti e' piu' chiara di qualunque 3D, ed e'
    gia' scritta e provata.

44. ~~**Cosa mostrare di un edificio sotterrato.**~~ **RISOLTA, e avevo posto
    male la domanda.** Chiedevo se nascondere i sepolti per fedelta' al tavolo.
    La risposta del designer ribalta la premessa: **i sepolti sono la basetta
    su cui poggiano le nuove costruzioni**, quindi non stanno sotto un
    coperchio - stanno sotto, in vista, e bastano dei binari distanziati per
    vederli. Non serve nessuna vista a raggi X.

    Nel 3D i binari hanno percio' uno stacco deliberato (`GAP_Z`), ed e'
    l'unica costante di quel modulo che esiste per una ragione di regola e non
    di estetica: c'e' un test che verifica che sia maggiore di zero. Le sagome
    sepolte restano in vista, solo smorzate, perche' non producono piu' nulla
    ma il loro Scavo conta ancora a fine partita.

45. **La faccia della carta va disegnata dai dati.** Le immagini estratte dal
    PDF (`assets/carte`) portano numeri della calibrazione precedente alla v1.5
    (punti 20 e 23), quindi non si possono mostrare come sono: direbbero al
    giocatore valori falsi. Per ora la vista disegna nome, resistenza,
    Vetusta', numero di potenziamenti e i segni di lavoratore e personaggio
    sepolto. **Domanda**: quando il PDF sara' aggiornato, si usa l'illustrazione
    come sfondo con i numeri ridisegnati sopra, oppure la carta a schermo resta
    interamente disegnata?

46. **I colori dei giocatori sono provvisori.** Rosso, blu, verde e giallo,
    scelti per distinguersi su fondo scuro. Se il gioco fisico ha colori
    ufficiali, vanno quelli.

47. **Le due scelte del giocatore ancora decise dal bot.** Ora che la M5 e'
    partita diventano lavoro vero, non piu' approssimazioni: il bersaglio del
    potenziamento gratuito dell'Eruzione (punto 40) e l'Ingegnere militare
    (punto 27). Entrambe aspettano l'input del giocatore, che e' il prossimo
    pezzo dell'interfaccia.

48. **Il plinto non e' la basetta, ed e' un errore che ho fatto davvero.** La
    prima versione 3D disegnava sotto ogni sopraelevazione una lastra grigia
    larga quanto l'edificio e profonda quanto **tutta** la strada. A schermo
    era un ripiano che nascondeva ogni cosa dietro di se': esattamente il
    contrario di quello che il designer aveva chiesto. La basetta vera sono
    gli edifici sottostanti; il plinto e' solo un dado, profondo uno slot.
    C'e' un test che lo impedisce di tornare.

49. **Una quota non puo' essere piu' bassa di una sagoma.** Secondo errore
    della stessa sessione: col passo fra le quote a 0,55 e sagome alte fino a
    0,93 i livelli si compenetravano. Non e' una questione di gusto ma di
    coerenza fisica - sul tavolo una sagoma poggia sopra l'altra - quindi c'e'
    un test che misura **tutti e 60** gli edifici e confronta la piu' alta col
    passo, invece di fidarsi di quello che ho guardato io.

50. **L'illustrazione delle sagome e' utilizzabile, quella delle carte no.**
    Distinzione che non avevo fatto: il problema dei numeri della calibrazione
    vecchia (punti 20 e 23) riguarda le **carte**, che stampano valori. Le
    **sagome** sono ritagli illustrati senza numeri, quindi si possono usare
    come sono - appena si sapra' quale sagoma appartiene a quale edificio, che
    e' la mappatura ancora non derivabile del punto 23. Finche' manca, le
    sagome a schermo sono rettangoli colorati col nome sopra.

51. **Cosa manca alla plancia 3D.** Per ora ci sono tessere, cielo, sagome,
    plinti, luce e telecamera. Mancano: le file laterali e le plance dei
    giocatori (oggi solo nella vista 2D), il PNG del cielo al posto del colore
    pieno, l'illustrazione sulle sagome, e soprattutto **l'input**: il clic
    sulla colonna e sulla carta, con l'anteprima del costo che il brief chiede
    esplicitamente. `BoardLayout3D` e' gia' scritto per servirlo - da' le
    posizioni, quindi un raggio dalla telecamera bastera' - ma il raccordo non
    c'e' ancora.

52. **Le misure vere vengono dal PDF, e una smentisce quello che avevo
    scritto.** Invece di scegliere delle proporzioni a occhio ho misurato la
    geometria di `materiali/Carte.pdf` - solo geometria, non dati di gioco:

    | pezzo | misura |
    |---|---|
    | tessera colonna | **63 x 271 mm**, cioe' 5 binari da **54,2 mm** |
    | sagome | **61 / 121 / 181 mm** di larghezza, cioe' 1, 2 e 3 slot |
    | altezze delle sagome | mediane **66 / 62 / 74 mm** per 1 / 2 / 3 slot |

    La larghezza delle sagome si quantizza sul modulo da 60,3 mm: e' la prova
    che il campo `width` dei dati e il cartone dicono la stessa cosa.

    **La smentita**: al punto 44 avevo scritto che i binari sono distanziati e
    che e' quello a lasciar vedere i sepolti. Falso. La tessera e' **una sola
    striscia con cinque binari contigui**; a lasciar vedere le file dietro e'
    la **basetta**, che dei 54 mm dello slot ne occupa 15 (numero del
    designer), lasciandone 39 scoperti. Il codice ora lo dice, e un test lo
    verifica.

    Tutte le costanti della plancia 3D sono percio' in **millimetri**: i
    numeri del designer entrano verbatim, senza passare da una mia conversione.

53. **La telecamera si calcola, non si aggiusta a occhio.** Due cose sono
    derivate dalla geometria e non scelte:

    - l'**inclinazione** ha un minimo. Con binari contigui da 54,2 mm e sagome
      alte fino a 74, sotto circa 54 gradi le file dietro spariscono dietro
      quelle davanti. Sta a 62, e un test confronta l'inclinazione col minimo
      calcolato invece che con una soglia a naso;
    - la **distanza** si trova proiettando gli **otto spigoli** della scena e
      avvicinandosi finche' entrano tutti. Una stima lineare non basta: la
      fila davanti e' piu' vicina e la prospettiva la ingrandisce, ed e'
      esattamente l'errore che avevo fatto - la plancia usciva dal fotogramma
      in basso. Ora il riempimento vale 0,80 esatto a 5, 7 e 9 colonne, e la
      telecamera arretra da sola quando le torri salgono.

54. **L'input: il clic e l'anteprima del costo.** `BoardLayout3D.slot_at_ray`
    porta un raggio della telecamera allo slot: pura, quindi provata headless
    su **tutti** gli slot e non su un campione. `AvailableActions` elenca cosa
    si puo' fare adesso col preventivo gia' fatto e, quando l'azione e'
    illegale, **il motivo in italiano** - il brief chiede l'anteprima del
    costo, e un "non puoi" senza spiegazione e' la cosa che rende
    un'interfaccia incomprensibile.

    Il test che conta non e' che la lista esista ma che **mantenga la
    promessa**: si gioca una partita intera scegliendo solo fra le azioni
    dichiarate eseguibili, e ogni rifiuto del comando e' un fallimento. Oggi
    passa su 40 azioni di quattro tipi. Un'interfaccia che offre e poi rifiuta
    e' peggio di una che non offre nulla.

    `AvailableActions` sta in `rules/` e non in `view/` perche' non e' una
    cosa di grafica: servira' ai bot della M6, che oggi tentano le azioni a
    caso per scoprire quali passano.

55. **Cosa manca ancora all'interfaccia.** In ordine di importanza: la scelta
    del bersaglio dove il regolamento la richiede (l'Impronta, il
    potenziamento dell'Eruzione, l'Ingegnere militare - punti 27 e 47: oggi
    `AvailableActions` offre il primo bersaglio legale); le file laterali e le
    plance degli avversari nella vista 3D, che per ora vivono solo nella 2D;
    il PNG del cielo al posto del colore pieno; e l'illustrazione sulle
    sagome, che aspetta la mappatura del punto 23.

56. **Le colonne erano specchiate, e l'ho scoperto solo guardando.** Con l'era
    1 davanti, la telecamera guardava verso le z crescenti; in quella
    configurazione l'asse X appare invertito sullo schermo, quindi la
    **colonna 0 finiva a destra**. Nessun test lo prendeva - la geometria era
    coerente con se stessa e il clic funzionava - ma chi legge «colonna 2»
    avrebbe guardato dalla parte sbagliata.

    Risolto girando i binari (`rail_z(era) = (RAILS - era) * SLOT_D`) invece
    che la X: la telecamera sta ora dal lato delle z maggiori, l'era 1 resta
    davanti e la colonna 0 torna a sinistra. **Verificato confrontando i
    terreni**: la partita stampa «fiume, bosco, pianura, collina, fiume,
    pianura, collina» da colonna 0 e l'immagine li mostra in quell'ordine da
    sinistra.

    Un test che affermava una direzione e' stato riscritto per verificare la
    non-sovrapposizione **senza dipendere dal verso dell'asse**: cosi' resta
    vero se un giorno si gira di nuovo il tavolo.

57. **Le file e le plance stanno sul tavolo, non in sovrimpressione.** Sono
    carte: si vedono, si indicano e si cliccano come tutto il resto, con lo
    stesso raggio che serve agli slot. Il mercato corre lungo il fianco
    sinistro della strada, personaggi, potenziamenti e monumenti lungo il
    destro, le plance dei giocatori davanti, dal lato di chi guarda.

    Ai lati e non davanti per una ragione di fotogramma: il tavolo e' piu'
    largo che alto, quindi allargarlo di una carta per lato costa molto meno
    che allungarlo di tre file. Le due colonne sono centrate sulla strada, e
    l'inquadratura ora fa entrare **tutto il tavolo**, non la sola strada.

    Sulla plancia di ciascun giocatore ci sono PV, risorse, lavoratori usati,
    Dinastia, personaggi dell'era, edifici in piedi e personaggi sepolti: le
    «carte possedute» che chiede il brief. Manca ancora il dettaglio dei
    cubetti di Vetusta' e resistenza carta per carta, che oggi si legge sulla
    sagoma.

58. **Cosa resta dell'interfaccia.** La scelta del bersaglio dove il
    regolamento la richiede (punto 55), il PNG del cielo al posto del colore
    pieno, l'illustrazione sulle sagome (che aspetta la mappatura del punto
    23), e il dettaglio dei cubetti sulla plancia del giocatore.

59. **La scelta del bersaglio, e un difetto peggiore di quanto avevo scritto.**
    Dove il regolamento fa scegliere, il motore non deve decidere al posto del
    giocatore. I posti sono tre, e ora sono tutti e tre chiusi.

    **Ingegnere militare** — «i tuoi edifici Militari hanno +1 res; uno a tua
    scelta +2». Al punto 27 avevo scritto che «il totale e' corretto, la
    distribuzione no». **Era ottimista**: il codice ignorava del tutto il
    limite e dava **+2 a tutti** i Militari. Misurato prima di correggere: due
    Militari, entrambi +2. Ora l'effetto porta nei dati un campo nuovo,
    `designated`, e vale sul solo edificio che il giocatore designa prendendo
    la carta. Tre Militari fanno 1+2+1 = 4, non 2+2+2 = 6.

    **Quando si designa**: al reclutamento. Il regolamento non dice quando, e
    il reclutamento e' il momento in cui la carta entra in gioco - lo stesso
    in cui si sceglie dove infilare un'Impronta. Il preventivo rifiuta il
    reclutamento senza bersaglio, e il bersaglio deve soddisfare il selettore
    della carta: un Civico o un Militare altrui non si designano.

    **Impronte e designazioni nell'interfaccia**: `AvailableActions` offre ora
    **una voce per bersaglio** invece di scegliere il primo legale. Sceglierne
    uno al posto del giocatore farebbe tornare il totale ma non la partita.

    **Il potenziamento dell'Eruzione** e' il caso difficile, perche' la scelta
    cade *dentro* la fine dell'era: la carta si infila «subito», cioe' prima
    del censimento, e il censimento puo' dipenderne (gli Stalli mercantili
    alzano la Rendita). Non si poteva rimandare a dopo.

    La fine dell'era e' percio' divisa in pezzi e **puo' sospendersi in
    mezzo**: `GameState.pending_choice` dice cosa il gioco sta aspettando e da
    chi, nessun comando passa finche' e' piena, e `GameController.choose()`
    la risolve e riprende. Se il bersaglio e' uno solo non si disturba
    nessuno; se non ce n'e', la carta si perde.

    `EraRules.end_era` resta intera per chi la chiama direttamente, composta
    dagli stessi pezzi con la scelta automatica: una sola implementazione,
    due composizioni. Il bot sceglie a caso e non «sempre il primo», perche'
    e' una scelta vera.

60. **Un errore di tipo che sembrava un altro errore.** `var scelta :=
    d.get("imprint", false) or ...` non compila - `get` torna Variant - e
    Godot riporta il guasto come «funzione inesistente» su una classe che
    invece esiste: lo script non era stato compilato affatto. Vale la pena
    ricordarlo: davanti a un «Nonexistent function» su una classe propria,
    il sospetto giusto e' un errore di compilazione piu' in alto.

61. **Le illustrazioni sulle sagome, e un compromesso che va scelto coi
    numeri.** Le sagome del PDF hanno il fondo bianco pieno e nessuna
    trasparenza. Toglierlo "per colore" bucherebbe le nuvole, che sono bianche
    anche dentro il disegno: il ritaglio parte percio' **dai bordi** e si
    propaga solo fra pixel contigui. Sta in `tools/estrai_grafica.py`, che ora
    scrive PNG con alfa per entrambe le varianti.

    A colori finche' l'edificio e' intatto, **in grigio quando e' spento**: il
    PDF ha i due stati e sono esattamente rudere e rovina. Col disegno sopra,
    il colore del giocatore non ha piu' dove stare, e va sulla **basetta** -
    che e' poi cio' che sul tavolo vero distingue due copie della stessa
    sagoma.

    **L'inclinazione della telecamera e' diventata un compromesso misurabile.**
    A 62 gradi tutte le file si vedevano intere, ma un cartone in piedi
    guardato da li' si schiaccia al 47% e con l'illustrazione sopra diventa
    illeggibile. Abbassando si legge meglio la sagoma e peggio la fila dietro.
    I due limiti si calcolano:

    | inclinazione | sagoma dietro visibile | scorcio |
    |---|---|---|
    | 62° | 100% | 47% |
    | 50° | 98% | 64% |
    | **45°** | **82%** | **71%** |
    | 40° | 69% | 77% |

    Scelti i 45 gradi, e il test ora regge **entrambi** i limiti invece di una
    soglia sola: almeno il 75% della sagoma dietro, e non meno del 65% di
    scorcio.

62. **Il passo fra le quote non copre il Grattacielo, ed e' giusto cosi'.**
    Con le altezze vere prese dal cartone, la sagoma piu' alta e' il
    Grattacielo: **160 mm** contro un passo di 85. Il test che pretendeva
    "nessuna sagoma piu' alta del passo" affermava una cosa falsa e l'ho
    riscritto: il passo copre la sagoma **tipica** (mediana 66), e la piu'
    alta lo scavalca - che e' quello che fa un grattacielo.

    Che il pezzo piu' alto dei sessanta sia proprio il Grattacielo e' anche
    una conferma indipendente che la mappatura del punto 56 e' giusta: non
    l'ho scelto io, e' venuto fuori misurando.

63. **Le misure delle sagome stanno nei dati, non negli assets.** `assets/` si
    rigenera e non e' versionata, quindi la plancia non puo' dipenderne per
    sapere quanto e' alta una sagoma. Larghezza e altezza in millimetri stanno
    percio' in `data/sagome.json` accanto al numero, e senza le immagini la
    vista ripiega sui rettangoli colorati con le proporzioni giuste. C'e' un
    test che gira con `assets/sagome` rimossa.

64. **Le pagine in grigio sono specchiate, e accoppiavo otto ruderi sbagliati.**
    Il retro del foglio e' impaginato a specchio perche' i due lati combacino
    alla fustellatura. L'estrattore leggeva entrambe le facce per x crescente,
    e nelle righe con piu' pezzi l'ordine usciva invertito: **otto posizioni su
    sessanta** davano al rudere di un edificio il disegno di un altro.

    Difetto silenzioso: la plancia mostrava un'immagine plausibile, solo
    sbagliata. L'ho trovato mentre rispondevo a una domanda del designer sui
    duplicati - i due stati riportavano coppie ripetute diverse, e quella
    differenza non poteva che essere mia.

    Corretto, e lo strumento ora **verifica da se'** che i due stati combacino
    posizione per posizione, stampandolo a ogni estrazione: senza il controllo
    la cosa potrebbe tornare senza che nessuno se ne accorga.

65. **Quali due disegni mancano.** Le coppie ripetute sono le stesse nei due
    stati: la ripetizione e' nel disegno d'origine, non nell'impaginazione. E
    il conto dei pezzi torna (60 sagome, larghezze 41/16/3 come i dati), quindi
    non sono stati aggiunti due edifici in piu': sono due slot legittimi
    riempiti con la copia di un altro disegno.

    Mancano **Ospedale dei pellegrini** (che porta la chiesa della Cappella) e
    **Mercato** (che porta il mulino del Mulino). Terzo caso a parte: il
    **Ponte** un disegno ce l'ha, ma raffigura un foro romano.

66. **I cubetti e le linguette: i segnalini del gioco vero.** Il brief chiede
    «i cubetti di Vetusta' e resistenza» sulla plancia, e il regolamento dice
    gia' di che colore sono: «segnatela con i cubetti **bianchi**» per la
    Vetusta', «resistenza permanente, segnata con un cubetto **nero**» per i
    potenziamenti Struttura. Non c'era niente da inventare.

    Stanno sulla **basetta**, davanti alla sagoma, perche' in 3D il tabellone
    non si puo' girare e vanno letti da dove si guarda. Se sono tanti si
    stringono invece di sbordare dal pezzo: meglio affollati che fuori.

    I potenziamenti si vedono dalla **linguetta**, come dice il regolamento -
    «infilate la carta sotto, lasciandone sporgere la linguetta». La prima
    versione la metteva dietro la sagoma, dove ovviamente non si vedeva: ora
    spunta davanti alla basetta, dal lato di chi guarda. C'e' un test che lo
    verifica, perche' e' un errore facile da rifare.

    Aggiunti anche il segnalino del **lavoratore** che abita l'edificio (nel
    colore di chi l'ha piazzato) e quello del **personaggio sepolto**: due
    cose che cambiano il punteggio e che altrimenti non si vedrebbero.

67. **Un cubetto da 5 mm e' invisibile, anche se e' la misura giusta.** Li
    avevo fatti di 5 mm su una plancia larga 44 cm: fisicamente plausibili, a
    schermo due pixel. Portati a 9 mm, che e' poi la misura di un cubetto da
    gioco vero. E' il primo posto in cui ho scelto la leggibilita' contro la
    scala esatta, e vale la pena averlo scritto.

68. **Del PDF estraevo un settimo di quello che contiene.** Il designer ha
    fatto notare che «tutte le carte non sono state importate», ed era vero:
    l'estrattore prendeva le cinque pagine delle facce degli edifici e basta.
    Il PDF contiene anche i **lati rovina**, gli **eventi**, i **personaggi**,
    i **monumenti**, le **eredita'**, la **Dinastia**, le **tessere colonna** e
    i **dorsi**. Ora li prende tutti; la mappa sta in
    `docs/materiali-di-stampa.md`.

    Le mappature le ho ricavate **leggendo i nomi stampati sulle carte**, che
    a differenza delle sagome i nomi ce l'hanno. Tre gruppi seguono ordini
    diversi: gli eventi l'ordine del JSON, i personaggi lo stesso ma con le
    posizioni 4-6 permutate, monumenti ed eredita' un ordine proprio. Nessuna
    regola valeva per tutti, quindi nessuna si poteva indovinare.

69. **Mancano tre eventi gravi dell'era 2** - **Eruzione, Persecuzioni, Guerra
    civile** - le cui posizioni portano una seconda stampa di tre carte
    dell'era 3.

    (Qui avevo scritto anche che mancavano tutti e 25 i potenziamenti. Era
    sbagliato: stanno in un PDF a parte, `materiali/Potenziamenti.pdf`, che
    allora non avevo. Quello che ne manca davvero e' al punto 71.)

    L'Eruzione e' la carta di cui ho appena implementato il potenziamento
    omaggio con tanto di sospensione della fine dell'era: esiste nelle regole e
    nei dati, ma non ha una carta da mettere in tavola.

    A differenza dei duplicati delle sagome, queste non sono copie byte per
    byte: stessa carta e stesso testo, illustrazione rigenerata. L'ho
    verificato prima confrontando gli hash (che le davano distinte) e poi
    guardandole grandi, perche' il primo confronto mi aveva ingannato.

70. **Il lato rovina dell'era 5 non manca: non serve.** La pagina 28 porta il
    dorso del mazzo invece delle dodici rovine dell'era 5. Sembra una lacuna e
    non lo e': l'era Moderna non ha evento, quindi un edificio dell'era 5 non
    diventa mai rudere - misurato, **0 su 113** in 40 partite - e l'unico modo
    in cui puo' finire in rovina e' essere spianato da chi ci costruisce sopra,
    cioe' restando sepolto e invisibile. Quel lato non lo vedrebbe nessuno.

71. **Nel PDF dei potenziamenti manca una carta per era, e al suo posto c'e'
    una ristampa.** `materiali/Potenziamenti.pdf` ha 25 posizioni per 25 carte,
    ma la prima carta di ogni era e' stampata due volte e un potenziamento non
    c'e':

    | era | posizione ripetuta | manca |
    |---|---|---|
    | 1 | 2 (copia di 1, *Pittura rupestre*) | **Fondamenta in pietra** |
    | 2 | 7 (copia di 6, *Statua*) | **Iscrizione** |
    | 3 | 12 (copia di 11, *Contrafforte*) | **Reliquia** |
    | 4 | 17 (copia di 16, *Opera d'arte*) | **Cannoniere** |
    | 5 | 22 (copia di 21, *Installazione*) | **Memoriale** |

    E' lo stesso difetto degli eventi del punto 69, ma qui le ripetizioni sono
    copie **byte per byte** - la stessa immagine incorporata due volte - non
    illustrazioni rigenerate. La regolarita' (sempre la prima carta del gruppo
    di cinque) fa pensare a un errore di impaginazione, non a cinque
    dimenticanze.

    Nessuna carta stampata e' estranea ai dati, e il testo delle 20 presenti
    coincide voce per voce con `data/cards.json`: qui, a differenza delle carte
    edificio del punto 20, i numeri del PDF **non** sono obsoleti.

    Intanto il gioco gira lo stesso: i potenziamenti li disegna dai dati, la
    grafica manca solo per cinque su venticinque.

72. **Le tessere colonna stampate hanno regole che il motore non ha.** Il
    modello conosce QUATTRO terreni con una regola ciascuno
    (`data/cards.json`, `terrains`); il cartone stampa UNDICI tessere con
    undici regole diverse, ognuna una variante nominata di un terreno.

    La produzione coincide sempre (pianura, collina e bosco 2 pietra; fiume
    1 pietra + 1 oro). La regola no: solo **Pianura dei Cantieri** ripete
    alla lettera la regola del suo terreno ("gli edifici da 2-3 caselle
    costano 1 pietra in meno"). Le altre dieci sono regole nuove - la
    Pianura del Mercato converte 2 pietra in 1 oro, il Fiume Guado fa
    contare come fiume anche le due colonne adiacenti, il Bosco Sacro da'
    +1 resistenza a Religione e Cultura.

    Perfino la regola della **collina** diverge: i dati dicono "ogni
    edificio costruito qui ha +1 resistenza permanente", la Collina del
    Castello stampa "il primo edificio che ciascun giocatore costruisce qui
    in ogni era ottiene +1 resistenza". Non e' la stessa cosa.

    Sono due giochi diversi: quattro terreni uguali fra loro, oppure undici
    tessere che si comportano ognuna a modo suo. Finche' non lo decidi le
    tessere si usano come **grafica** del terreno e le loro regole non
    vengono applicate: il motore resta quello dei dati.

73. **Le tessere FIUME sono una in meno di quante ne servono.** Il mix a
    quattro giocatori (`terrain_mix_by_players`) chiede pianura 3, fiume 3,
    collina 2, bosco 1. Stampate: pianura 4, collina 2, **fiume 2**, bosco 3.

    E la posizione sprecata e' esattamente una: la settima e' una seconda
    stampa di *Collina delle Cave*, copia byte per byte della sesta - lo
    stesso difetto dei potenziamenti e degli eventi. Undici tessere
    distinte su dodici posizioni, e quella che manca e' un fiume.

    (Qui mi ero sbagliato: avevo scritto che il duplicato era voluto,
    "serve avere due volte lo stesso terreno su una strada da 9 colonne".
    Col mix alla mano non regge - di colline ne servono al massimo due e
    due sono gia' stampate - ed era una spiegazione inventata per una cosa
    che non avevo verificato.)

    A schermo si vede: a quattro giocatori la terza colonna di fiume ripete
    il disegno della prima.

74. **Le "caselle disegnate" sulle tessere non le trovo.** Mi hai detto che
    sul PDF ci sono caselle disegnate nella parte alta della tessera, dove
    vanno le sagome. Nella copia che ho in mano - `materiali/Carte.pdf`,
    impronta `06530822fdf30035` - non ci sono: le tessere portano titolo,
    illustrazione, icone di produzione, regola e la fascia "Prosperita'
    Urbana", e basta. Controllate tutte e undici.

    Ho quindi preso come fascia dei binari **l'illustrazione**, misurata sul
    pixel: il cielo comincia a 30 mm dal bordo alto e la cornice d'oro sotto
    il disegno cade a 160. Centotrenta millimetri, cinque binari da 26.

    Se le caselle stanno nel PDF nuovo, quando arriva rimisuro sulle loro
    posizioni invece che sulla cornice: potrebbero non essere centrate sulla
    fascia che ho scelto.

75. **I binari stretti costano lo scorcio.** Con i binari a 54 mm bastavano
    45 gradi di inclinazione per vedere l'82% di una sagoma dietro quella
    davanti e tenere il 71% di scorcio. Portandoli a 26 mm, a 45 gradi ne
    restava visibile il **39%** e la fila davanti copriva anche il testo
    della tessera.

    La telecamera e' salita a **62 gradi**: cosi' la visibilita' torna al 74%
    - dov'era - e il prezzo lo paga lo scorcio, che scende dal 71 al **47%**.
    A 70 gradi le sagome sono quasi coricate e non si riconoscono piu':
    provato, guardato, scartato.

    Le due soglie che il test controllava prima - 75% visibile e 65% di
    scorcio - non stanno piu' insieme: la prima vuole almeno 62 gradi, la
    seconda al massimo 49. Le soglie nuove sono scritte nel test, non
    allentate di nascosto. Se preferisci sagome meno schiacciate si scende
    d'angolo e si accetta che le file dietro si vedano meno; ora comunque la
    telecamera la muovi tu.

76. **Chiuse dal PDF del 22 settembre, e una che resta aperta.**

    Il designer ha ricaricato tutti e due i PDF. Confrontati posizione per
    posizione con le copie precedenti, ecco cosa e' cambiato davvero.

    **Chiusi.** I cinque potenziamenti mancanti (punto 71) ci sono: 25
    posizioni, 25 carte distinte, nell'ordine esatto dei dati. E le tre
    sagome sbagliate sono rifatte: il **Ponte** raffigura un ponte e non piu'
    un foro romano, **Ospedale dei pellegrini** e **Mercato** hanno un
    disegno proprio. Sessanta disegni distinti per sessanta edifici, e le
    larghezze sul cartone combaciano una per una con `width`.

    **Resta aperto il punto 69: i tre eventi gravi dell'era 2.** Le posizioni
    10, 11 e 12 portano ancora una seconda stampa di Grande incendio, Scisma
    e Anni della fame - stessa carta, stesso testo, illustrazione rigenerata
    - invece di **Eruzione, Persecuzioni e Guerra civile**. Ricontrollato a
    vista sul PDF nuovo, perche' li' l'impronta non aiuta: sono ventiquattro
    immagini tutte diverse fra loro, e solo leggendo i titoli si vede che tre
    carte sono stampate due volte.

    L'Eruzione e' la carta di cui il motore implementa il potenziamento
    omaggio con tanto di sospensione della fine dell'era: esiste nelle regole
    e nei dati, ma non ha ancora una carta da mettere in tavola.

    **Restano aperti anche** il punto 73 (manca una tessera FIUME: le tessere
    sono identiche al byte a prima) e il punto 74 (le "caselle disegnate"
    sulle tessere: nel PDF nuovo non ci sono, le tessere non sono state
    toccate).

77. **Il cielo era una parete, ora e' un fondale.** Stava 90 mm dietro il
    bordo delle tessere e sbordava di due tessere per lato: si vedeva che era
    un'altra cosa. Ora e' largo esattamente quanto la fila di tessere e
    attaccato al loro bordo alto, come ha chiesto il designer.

    Il PNG del cielo pero' **non e' arrivato**: nel repository non c'e'
    nessuna immagine. Finche' non c'e', il pannello resta a tinta unita.


78. **"Intatto e sepolto" era uno stato che al tavolo non esiste.** Il
    designer l'ha visto nel riquadro di un edificio - *"come fa il condominio
    a essere intatto e sepolto? E' cosi' per molti edifici, infatti vedo alla
    fine della partita solo tre sagome"* - e aveva ragione.

    `Grid.refresh_buried` sotterrava **qualsiasi** edificio la cui proiezione
    fosse coperta da uno strato piu' alto. Ma a quota zero una colonna porta
    fino a **cinque** edifici, uno per binario d'era: il primo strato
    costruito sopra ne sotterrava cinque invece di uno. Gli altri quattro
    restavano INTATTI e sepolti - smettevano di produrre, regalavano lo Scavo
    al proprietario e sparivano dal tabellone.

    Le due fonti dicono la stessa cosa, e nessuna delle due permette quello
    stato:

    - il regolamento: *"E' sotterrato qualsiasi edificio su cui e' stata
      costruita una sopraelevazione"* e *"**una rovina** e' sotterrata quando
      l'unione degli strati successivi copre interamente la sua proiezione"*.
      Chi fa da base viene prima spianato o schiacciato, quindi quando viene
      sotterrato e' gia' rovina;
    - `reference/simulatore_riferimento.py`, l'oracolo su cui il gioco e'
      stato bilanciato, sotterra **solo la base** (una per colonna, scelta da
      `ground_level`) e la marca `spianata` se era intatta, `sotterrata`
      altrimenti. Nessun altro edificio della colonna viene toccato, e
      `intact` + sepolto non si presenta mai.

    Correzione adottata: si sotterra **solo una rovina**, e solo quando
    l'intera proiezione e' coperta. Il ricalcolo gira anche dopo l'evento di
    fine era, che e' l'unico altro punto in cui uno stato cambia da solo: un
    edificio gia' coperto restava in piedi finche' era intatto, e crollando
    diventa archeologia.

    **Ha conseguenze sui punteggi, e vanno riviste in una partita vera**: su
    otto partite a tre giocatori i sepolti passano da 147 su 225 a 137 su
    243, e le sagome in piedi a fine partita da 33 a 80. Meno Scavo, piu'
    rendita e piu' vetusta': e' il conto che il simulatore faceva gia', ma il
    porting no.

79. **Il banner dello Scavo ha cinque righe, i valori stampati arrivano a 6.**
    L'immagine `materiali/Scavo.png` porta cinque strisce, una per valore, dallo
    **0 al 4**. I valori di Scavo in `data/cards.json` sono invece **0, 2, 3, 5,
    6**: il 4 e l'1 non esistono su nessuna carta, e otto edifici stanno oltre la
    scala —

    | valore | carte |
    |---|---|
    | 5 | Circolo di pietre, Tumulo funerario, Teatro, Foro, Abbazia, Duomo |
    | 6 | Grotte dipinte, Anfiteatro |

    E non e' solo il valore stampato: l'Impronta dell'Incisore alza lo Scavo di
    **+3 permanenti**, quindi anche una carta da 3 puo' arrivare a 6.

    Per ora la vista **appiattisce sul 4** quello che va oltre, il che vuol dire
    un numero SBAGLIATO sul tavolo per quelle otto carte. Il codice non ha
    bisogno di altro che di un'immagine piu' alta: `SCAVO_RIGHE` dice quante
    strisce ci sono e la vista prende la riga per valore, non per posizione.

    **RISOLTA dal designer**: l'immagine adesso porta **dieci strisce, dallo 0
    al 9**. Lo 0-9 copre i valori stampati (0, 2, 3, 5, 6) e anche il caso
    peggiore con l'Impronta (6 + 3 = 9). L'1 e il 4 restano li' senza una
    carta che li usi, e va bene: ci arriva l'Incisore.

    L'immagine del designer e' pero' DISEGNATA, non impaginata: le strisce
    sono separate da righe bianche e alte una diversa dall'altra (fra 79 e
    117 pixel). `tools/estrai_grafica.py` le ritrova una per una e le
    ricompone in righe tutte uguali, alte quanto la MEDIANA: cosi' la vista
    prende la riga del valore N con una divisione, e una striscia piu' alta
    delle altre non stira tutto il disegno. Un test controlla che nessuna
    carta abbia uno Scavo oltre le righe disponibili.

80. **"Sepolto" con il vuoto sopra: gli strati successivi non sono tutta la
    colonna.** Sul tabellone si vedevano basette marcate *sepolto* con sopra
    niente. Il seme 726 ne dava cinque in una partita sola — Dolmen, Menhir,
    Ponte, Mulino, Torre civica — tutte a quota zero, tutte all'aria aperta.

    La regola dice: *"una rovina e' Sotterrata quando l'unione degli strati
    successivi copre interamente la sua proiezione"*. Il codice leggeva
    "strati successivi" come **tutto quello che nella colonna sta a un livello
    piu' alto**. Ma a quota zero una colonna porta fino a **cinque** edifici,
    uno per binario d'era, affiancati in PROFONDITA': chi costruisce sopra ne
    sceglie uno solo come base — `top_of` — e gli altri quattro restano
    scoperti, con niente addosso. Un edificio al livello 1 li seppelliva tutti
    e cinque.

    Correzione adottata: si risale la CATENA di chi poggia su chi (`basi`, che
    l'edificio si fissa alla costruzione), e si e' sepolti solo se quella
    catena copre tutte le proprie colonne. E' anche quello che fa il
    simulatore di riferimento, che sotterra solo la base.

    **Quanto sposta, misurato a parita' di tutto il resto.** Sessanta partite
    a tre giocatori, stessi semi e stessi bot, cambiando SOLO questa regola:

    | | prima | dopo |
    |---|--:|--:|
    | edifici costruiti per partita | 26,9 | 26,9 |
    | turni per partita | 45,3 | 45,3 |
    | **sotterrati** | **68%** | **51%** |
    | PV per giocatore | 73,8 | **69,2** |

    Il tavolo si costruisce **identico** - stessi edifici, stessi turni: la
    sepoltura non cambia quello che si puo' fare, cambia quello che vale.
    Costa **4,6 PV a testa, il 6%**, e quasi tutti dallo Scavo. Un sepolto su
    quattro, prima, era uno di quelli col vuoto sopra.

    Resta da rivedere al tavolo se il 51% di sotterrati sia la quota giusta:
    e' la stessa domanda del punto 78, ma su un numero diverso.

81. **I cubetti restano sulla rovina: quelli bianchi contano ancora, quelli
    neri no.** Il Menhir a fine partita porta ancora tre cubetti bianchi di
    Vetusta' e i suoi cubetti neri di resistenza, pur essendo una rovina.
    Nessuna regola li toglie: il crollo azzera i potenziamenti
    (`resolve_event` fa `upgrades.clear()`) e la Vetusta' si azzera **solo col
    restauro** — che pero' vale sui *ruderi*, non sulle rovine. Una rovina non
    si restaura piu', quindi quei cubetti restano li' per sempre.

    **I neri sono inerti, e si puo' dimostrare.** Su una rovina la resistenza
    non serve piu' a niente: gli eventi guardano solo chi e' in piedi
    (`is_standing`), il restauro non la riguarda, le spolia di chi costruisce
    sopra si pagano solo spianando un INTATTO (una rovina da' lo sconto
    macerie, che non dipende dalla resistenza) e nessuna carta seleziona per
    resistenza. In 300 partite a tre giocatori restano a fine partita 6167
    rovine, 1851 delle quali con cubetti neri addosso che non fanno piu' nulla.

    **I bianchi no: due carte li contano ancora.** Il **Colosseo**
    (`{"owner": "self", "vetusta": {"min": 3}}`) e **Il Silvicoltore**
    (`{"owner": "self", "terrain": ["bosco"], "vetusta": {"min": 3}}`) chiedono
    "un tuo edificio con Vetusta' almeno 3" **senza dire in che stato**,
    mentre le altre carte che vogliono edifici sani lo scrivono
    (`"state": ["intatto"], "buried": false` — Monumenti 3 e 9, Lasciti 7 e 9,
    personaggi 21 e 25). Cosi' come sono scritti i dati, una rovina — e
    perfino una rovina sotterrata — soddisfa il Colosseo.

    Misurato su 300 partite a tre giocatori (900 giocatori): a fine partita ci
    sono 621 edifici con Vetusta' >= 3, di cui **517 intatti, 2 ruderi, 77
    rovine e 25 sepolti**. Il Colosseo e' soddisfatto dal 55,4% dei giocatori,
    e il **7,1%** lo soddisfa SOLO grazie a edifici non intatti: circa un
    giocatore su quattordici prende quel punto per una rovina.

    **Domanda al designer, due cose distinte:**
    1. il Colosseo e Il Silvicoltore devono contare anche le rovine e i
       sepolti, o gli manca il `"state": ["intatto"], "buried": false` che
       hanno le carte sorelle? (regola: cambia il punteggio)
    2. sul tabellone i cubetti di una rovina si continuano a mostrare, si
       spengono o si tolgono? Finche' i bianchi contano per due carte,
       toglierli nasconderebbe un'informazione che serve; i neri invece non
       dicono piu' niente a nessuno. (solo grafica: non cambia il punteggio)

82. **Il Centro Urbano paga 1,6 volte a partita.** La Prosperita' Urbana e' la
    sola cosa sul tabellone che paga anche gli avversari: quando si attiva una
    colonna con almeno tre edifici intatti di almeno due proprietari, ognuno di
    quei proprietari incassa un oro. La scritta e' stampata su tutte le
    tessere, quindi sembra una cosa che succede sempre.

    Misurato su 300 partite a tre giocatori coi bot a strategie:

    | | |
    |---|--:|
    | volte che paga, per partita | **1,61** |
    | oro distribuito in tutto, per partita | 3,51 |
    | partite in cui non paga MAI | **42%** |
    | colonne diverse che pagano, per partita | 0,89 |
    | colonne che sono Centro a fine partita | 8,5% |

    E arriva tardi: nell'era 1 mai, nell'era 2 nel 3% delle partite, poi 24%,
    35% e 13%. Prima dell'era 3 il tabellone non ha abbastanza edifici intatti
    nella stessa colonna, e dall'era 4 in poi quelli che ci sono cominciano a
    crollare.

    Con dei bot, per giunta, che il Centro non lo cercano: nessuna delle cinque
    strategie ha una riga che dica "costruisci dove c'e' gia' roba altrui per
    accendere la Prosperita'", perche' il regolamento non dice che convenga.
    Un tavolo di umani che ci puntasse lo farebbe scattare piu' spesso - ma
    dovrebbe accorgersene, e finora sul tabellone non si vedeva.

    **RISOLTO: il designer ha messo la soglia a 2 edifici.** Rimisurato su
    10 000 partite per parte, stessi semi e stessi bot, cambiando solo quella
    riga di `constants.prosperity`:

    | | Centro a 3 | Centro a 2 |
    |---|--:|--:|
    | edifici costruiti per partita | 26,3 | **28,7** |
    | PV per partita (i tre insieme) | 177 | **198** |
    | in piedi a fine partita | 25% | 25% |
    | sepolti | 54% | 57% |

    Due edifici e mezzo in piu' per partita e ventuno punti: l'oro in piu' non
    resta in tasca, diventa mattoni. A guadagnarci sono le carte care delle
    ultime ere - Palazzo signorile, Villa, Duomo, Ponte in acciaio, che si
    costruiscono una volta e mezzo piu' spesso - e i canali che premiano chi
    costruisce: Verticalita' +11 PV, Lampo +6,5. La Rendita cala di un punto,
    perche' gli edifici nuovi coprono i vecchi. Il dettaglio carta per carta
    sta in `docs/vita-degli-edifici.md`.

    Intanto il cartellino sulla fascia della tessera dice quali colonne sono
    Centro **adesso**: prima bisognava contare gli edifici a mano.


83. **La citta' a fine partita e' fatta di rovine: 7,3 edifici in piedi su
    28,7 costruiti.** Il designer l'ha vista giocando e ha chiesto se le
    soglie che mandano in rovina non siano troppo severe. Misurato: le tre
    manopole (la penalita' del rudere, la soglia della rovina, la forza degli
    eventi) valgono rispettivamente +0,07, +1,0 e +2,0 edifici in piedi a fine
    partita; tutte e tre insieme portano da 7,3 a 10,3, cioe' da un quarto a
    un terzo della citta'. Il conto completo, variante per variante, sta in
    `docs/quanto-punisce-il-gioco.md`.

    Le manopole si girano da riga di comando (`--rudere`, `--gap`, `--forza`)
    e i dati non cambiano: nel commit c'e' solo `rovina_gap`, la soglia che
    prima stava scritta nel codice come `gap == 1` e adesso sta nei dati col
    suo valore di oggi, 2. Non e' un cambio di regola: e' la stessa regola,
    scritta dove si puo' leggere e provare.

    **Quel che la misura dice, e che non ci si aspettava:** in tutte le
    varianti la quota di SEPOLTI resta ferma al 57%. Gli eventi decidono chi
    crolla, non chi sparisce sotto la citta': quello lo decidono i giocatori
    costruendo sopra. Anche rendendo il gioco molto piu' mite, piu' di meta'
    degli edifici finirebbe comunque sotto uno strato. Se la citta' deve
    sembrare piu' viva, la manopola grossa non e' la severita' dell'evento ma
    quanto paga salire (`docs/quanto-paga-salire.md`).

    **RISOLTO: `rovina_gap` a 3.** Fallire l'evento di 1 o di 2 lascia un
    rudere; si crolla in rovina solo fallendo di 3 o piu'. Gli edifici in piedi
    a fine partita passano da 7,3 a 8,3 e la vita media da 1,79 a 1,96 ere, al
    prezzo di 2 punti a partita su 198. Nessuna carta stampata cambia: la forza
    degli eventi resta 2/3/4/5 e le resistenze restano quelle.

    La manopola della forza (`--forza -1`, +2 edifici in piedi) resta li' per
    quando si vorra' riprovare: quella pero' cambia il materiale stampato e va
    decisa prima della stampa.

    Alzando la soglia e' venuto fuori un difetto vecchio: il libro mastro delle
    carte non tornava col tabellone sulla Verticalita', perche' la meta' divisa
    del premio veniva arrotondata carta per carta invece di spezzare la quota
    del giocatore. Adesso si spezza col resto piu' grande e i due conti sono lo
    stesso numero - il test e' passato da "tolleranza un punto per colonna" a
    nessuna tolleranza.
