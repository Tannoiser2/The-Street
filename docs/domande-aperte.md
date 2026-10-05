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

    Risolto il 27 settembre: il designer ha rifatto la pagina 29 e
    ricaricato `materiali/Carte.pdf` (e `Sfondo.png`); le altre 53 pagine
    sono identiche immagine per immagine. Le posizioni 10,
    11 e 12 portano Eruzione, Persecuzioni e Guerra civile; la mappatura
    (`data/carte_pdf.json`) non ha piu' `null` fra gli eventi e
    `tools/estrai_grafica.py` estrae 24 eventi su 24.

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

    Chiuso dal designer: "la tessera fiume raddoppia la prima e fine". La
    terza colonna di fiume a quattro usa il disegno della prima, com'e'
    gia' a schermo; niente da correggere.

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

    Chiuso dal designer: da ignorare. La fascia dei binari resta quella
    misurata sull'illustrazione.

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

    **E ATTENZIONE AL NUMERO DI PARTENZA: non vale piu'.** Il Centro Urbano
    pagava 1,61 volte a partita quando chiedeva tre edifici e si crollava
    fallendo di 2. Con la soglia a 2 E la rovina a -3 - piu' edifici intatti
    sopravvivono, quindi piu' colonne raggiungono la soglia - adesso paga
    **8,73 volte a partita e distribuisce 17,75 oro, in tutte le partite**,
    misurato su 400. Da rarita' che quando capita fa piacere e' diventata una
    rendita costante: e' un effetto combinato delle due decisioni, non di una
    sola, e va guardato al tavolo prima di considerarlo a posto.

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


84. **I binari liberi: piu' terreno, e salire torna una scelta.** Proposta del
    designer: i binari non sono piu' vincolati all'era, si riempie DAL FONDO e
    un edificio di un'era puo' finire sul binario di un'altra se il suo e'
    pieno. Il motivo, misurato: sulle 10 000 partite ogni era tranne la quinta
    chiede piu' caselle di quante il suo binario ne abbia - l'era 2 ne chiede
    9,6 su 7 - quindi oggi salire non e' una strategia, e' uno sfratto. Coi
    binari liberi il terreno passa da 7 caselle per era a 35 per partita,
    contro le 39,7 che servono.

    Provato dietro la manopola `binari_liberi` (spenta nei dati), 5 000 partite
    per parte a parita' di semi:

    | | per era | liberi |
    |---|--:|--:|
    | edifici costruiti per partita | 28,70 | **30,50** |
    | in piedi a fine partita | 8,26 | **9,29** |
    | sepolti | 57% | 52% |
    | sopraelevati (per giocatore) | 5,51 | 5,33 |
    | quota massima raggiunta | 4,02 | 3,95 |
    | PV per partita | 200 | **212** |
    | di cui Rendita | 54,0 | **64,0** |
    | di cui Verticalita' | 79,7 | 79,6 |
    | di cui Scavo | 21,0 | 21,4 |

    **La citta' NON si appiattisce**, ed e' il risultato che non mi aspettavo:
    i sopraelevati restano 5,3 per giocatore contro 5,5, la quota massima non
    si muove e i punti della Verticalita' sono identici. Salire continua a
    convenire - lo pagano la tabella, le spolia e la continuita' - e i binari
    liberi aggiungono terreno senza togliere la stratificazione. Quello che
    cresce e' la Rendita (+10 PV): piu' edifici restano in piedi e pagano il
    censimento.

    **Il prezzo sta altrove, ed e' la Prosperita'.** Con i binari liberi una
    colonna porta fino a cinque edifici a terra di proprietari diversi: il
    Centro Urbano passa da 8,73 a **14,84 pagamenti a partita** e da 17,75 a
    **31,51 oro**. Trentuno monete distribuite sono tante, e vanno a chi ha
    gia' costruito di piu'. Se i binari liberi entrano, la soglia della
    Prosperita' va rivista - probabilmente rimessa a 3 - e rimisurata.

    **ADOTTATI**, insieme alla Prosperita' rimessa a 3 edifici. Misurato dopo,
    5 000 partite a parita' di semi, contro il mondo di stamattina:

    | | per era, soglia 2 | liberi, soglia 3 |
    |---|--:|--:|
    | edifici costruiti per partita | 28,70 | **29,30** |
    | in piedi a fine partita | 8,26 | **8,92** |
    | intatti a fine partita | 7,61 | **8,23** |
    | sepolti | 57% | **51%** |
    | PV per partita | 200 | 201 |
    | di cui Rendita | 54,0 | **65,2** |
    | di cui Verticalita' | 79,7 | **73,7** |

    Il punteggio totale non si muove (200 -> 201) ma cambia da dove viene: undici
    punti in piu' dalla Rendita, sei in meno dalla Verticalita'. E' esattamente
    quello che ci si aspetta quando salire smette di essere obbligatorio e piu'
    edifici restano in piedi a pagare il censimento.

    **La Prosperita' pero' resta frequente: 7,56 pagamenti a partita e 17,03
    oro, nel 98% delle partite** (400 partite). La soglia a 3 taglia l'eccesso
    dei binari liberi - erano 14,84 - ma non riporta il Centro Urbano alla
    rarita' di partenza (1,61), perche' il motivo vero non e' la soglia: e' che
    da quando si crolla solo fallendo di 3 sopravvivono piu' intatti, e piu'
    colonne raggiungono comunque il minimo. Se la rarita' e' una cosa a cui
    tieni, la manopola giusta adesso e' `gold_per_owner` o il richiedere
    proprietari diversi in numero maggiore, non altri edifici. Va visto al
    tavolo.

85. **Il canone delle strategie: sei, con Obiettivi.** Deciso dal designer: il
    torneo rifatto col bot della versione 2 mette Obiettivi sopra la media con
    tutti e due i bot (34,8% col bot v1, 39,5% col v2, attesa 33,3%), e resta
    l'unica candidata a farlo. **Entra come sesta**, Scavo resta: e' misurando
    chi lo insegue che si vede che lo Scavo non si puo' raccogliere.

    Misurato l'effetto sulle batterie, 10 000 partite per parte a parita' di
    semi e di regole: **edifici costruiti 30,12 -> 29,83, PV per partita
    211 -> 209**, in piedi e sepolti identici. Le misure fatte con cinque
    strategie restano confrontabili entro un punto percentuale. Da qui in poi
    l'intestazione di ogni batteria dice `strategie=6`.


86. **Il Centro Urbano piu' raro: tre proprietari, o una volta per era.**
    Seguito del punto 84. `gold_per_owner` vale gia' 1 e l'oro e' intero:
    abbassarlo vuol dire 0, cioe' togliere la Prosperita'. Le due vie
    provate, dietro manopole che non cambiano nulla finche' sono spente
    (verificato: 120 partite identiche a main):

    - **tre proprietari diversi** (`min_owners` 2 -> 3, solo dato:
      `--proprietari 3`);
    - **una volta per era** (`once_per_era`, nuova e spenta nei dati:
      `--una_per_era`): la prima attivazione di un Centro in un'era paga, le
      altre nella stessa colonna no fino all'era dopo.

    3 000 partite a 3 giocatori per configurazione, stessi semi, sei
    strategie (800 a 4 giocatori fra parentesi):

    | | oggi | 3 proprietari | una per era |
    |---|--:|--:|--:|
    | pagamenti a partita | 7,30 (8,63) | **2,25** (3,37) | 5,09 (5,87) |
    | oro distribuito a partita | 16,7 (20,6) | **6,8** (10,2) | 11,4 (13,7) |
    | partite in cui scatta | 95% (96%) | **57%** (71%) | 95% (96%) |
    | oro al vincitore | 6,4 | 2,3 | 4,4 |
    | edifici costruiti a partita | 29,9 | 28,9 | 29,6 |
    | PV a partita (tutti i canali) | 261 | 248 | 257 |
    | di cui Verticalita' | 76,7 | 71,0 | 75,1 |
    | distacco fra primo e secondo | 18,3 | 19,4 | 19,2 |

    **Tre proprietari riporta la Prosperita' vicino alla rarita' di
    partenza** (1,61 pagamenti a partita): 2,25, e in quattro partite su
    dieci non scatta mai. Costa 14 PV a partita al tavolo, quasi tutti dal
    costruire meno (un edificio in meno a partita, Verticalita' -5,7): l'oro
    del Centro finiva in muri. **Ma a due giocatori la Prosperita'
    sparisce**: tre proprietari diversi non ci sono. Se si sceglie questa
    via, la regola va scritta come "tutti i giocatori, massimo tre" o
    simile, e a due resta a 2.

    **Una per era taglia un terzo** (7,30 -> 5,09) e lascia la Prosperita'
    in quasi tutte le partite: toglie la colonna-bancomat attivata tre
    volte di fila, non il Centro. Costa 4 PV a partita.

    **Nessuna delle due sposta chi vince.** Le vittorie per strategia
    restano dentro l'errore standard (1,2 punti a 3 giocatori): la Rendita
    fa 37,6 / 39,0 / 38,9%, Obiettivi 37,1 / 36,5 / 35,7%. Il distacco fra
    primo e secondo cresce di un punto con meno Prosperita': e' l'unico
    premio che paga anche gli avversari, e un po' livellava.

    **ADOTTATA LA SECONDA**: `once_per_era` e' accesa nei dati. Il mondo di
    oggi rigioca esattamente le 3 000 partite misurate con `--una_per_era`
    (verificato sulle prime 300); `--una_per_era 0` rimette il Centro a ogni
    attivazione. L'intestazione delle batterie dice `centro=una_per_era`, e
    le misure pubblicate prima (vita degli edifici, strategie) sono fatte col
    Centro a ogni attivazione: la differenza e' quella della tabella qui
    sopra, 0,4 edifici e 4 PV a partita.

    **Resta una domanda da tavolo:** al tavolo vero bisogna ricordarsi quali
    Centri hanno gia' pagato in quest'era. Serve un segno fisico - girare il
    cartellino della Prosperita' dopo il pagamento, e rigirarli tutti a fine
    era - e il regolamento va aggiornato di conseguenza. A schermo il
    cartellino fa gia' cosi': dopo il pagamento resta sulla tessera ma
    scuro, e a fine era si riaccende.

87. **Senza rudere: la prima misura della nuova meccanica.** Il punto 11 della
    proposta (`proposte/nuova-meccanica.md`) toglie lo stato di rudere. Misurato
    da solo sul motore di oggi, manopola `senza_rudere` spenta nei dati
    (`--senza_rudere 1`), 2 000 partite `--vita` e 750 di torneo per variante a
    parita' di semi: `docs/senza-rudere.md`.

    Le due letture vanno in direzioni opposte. **Rovina solo a -3** (chi fallisce
    di 1-2 resta intatto): +2 edifici in piedi a fine partita, Rendita +15 per
    partita, ma lo Scavo cade da 20,5 a 6,5 con i sepolti fermi al 50%: senza
    ruderi si sale solo spianando i propri edifici vivi, che valgono Scavo 0
    (`was_razed`). Il rudere e' la porta dell'archeologia. **Ogni fallimento fa
    rovina** (`--gap 1`, la lettura letterale del punto 9): canali e vittorie
    fermi, ma gli edifici che cadono nell'era in cui nascono passano dal 17% al
    48%.

    **Deciso dal designer:** gli stati sono attivo, rovina e sotterrato, e lo
    Scavo non si azzera mai; con il dubbio "non si spinge troppo a sotterrare
    i propri?". Misurato (manopola `spianare_conserva_scavo`, spenta;
    `--scavo_spianato 1`; il torneo conta basi proprie, altrui e spianati):
    **il dubbio era fondato.** Con lo Scavo conservato gli edifici spianati
    dal proprietario passano dal 25% di oggi al 44% (69% nell'era 2), le
    basi altrui da 2,0 a 1,1 per giocatore, lo Scavo da 20 a 52 punti a
    partita e il punteggio totale sale di 50: spianare il proprio da' insieme
    lo sconto della Spolia, il livello e lo Scavo pieno. La soglia (3, 2 o 1)
    non cambia questo esito, decide solo le morti premature (18/32/48%).

    La variante detta subito dopo dal designer - "gli edifici vivi spianati
    mettono lo Scavo a zero, diventano terrapieni", cioe' la Spolia di oggi -
    con la soglia 2 e' la piu' vicina al gioco attuale: in piedi 9,1 contro
    9,3, punteggio +5, vittorie ferme; costa lo Scavo (20,5 -> 13,9) e il 32%
    di edifici che cadono nell'era in cui nascono (oggi 17%). Terrapieno o
    rovina non cambia i numeri, solo chi conta gli strati (Archeologo,
    Demolitore, Soprintendente, la meta' della Verticalita' fra i
    proprietari): decisione da regolamento.

    **Terza misura, "perche' costruire sopra gli altri".** Due leve provate
    sulla base senza rudere a soglia 2: lo Scavo a chi scava
    (`scavo_a_chi_scava`; il motore ora registra chi ha sepolto chi) e lo
    sconto macerie solo sulle rovine altrui (`sconto_macerie_solo_altrui`).
    Nessuna delle due porta a costruire sugli altri: basi altrui 1,6-1,8 per
    giocatore contro le 2,0 di oggi. Lo Scavo a chi scava smette di far
    seppellire se stessi (basi proprie 4,6 -> 3,5) ma si costruisce meno
    sopra: colonne mezzo livello piu' basse, Verticalita' -4 per giocatore,
    Rendita che vince il 53%. Lo sconto di una pietra non muove nulla. Il
    kingmaker e' piccolo: togliendo a tutti lo Scavo dell'era 5 il vincitore
    cambia nel 2% delle partite. **Il motivo e' strutturale:** costruire
    nella colonna altrui divide la Verticalita' (meta' alla cima, meta' a
    tutti gli strati), nella propria e' tutta propria. Da provare: il premio
    della colonna che non si divide con chi sta sotto. Tutto in
    `docs/senza-rudere.md`.

88. **Il punto per il disturbo non e' mai esistito nel motore.** Il regolamento
    dice "+1 per ogni edificio altrui che avete sotterrato" (voce Scavo del
    conteggio finale). Ne' il motore (`Scoring._scavo` aveva un TODO) ne'
    l'oracolo Python lo contavano: le 80 000 partite del bilanciamento e tutte
    le misure di questo registro sono senza. Ora il motore sa chi ha sepolto
    chi e la costante `disturbo_vp` lo paga; sta a **0** perche' il gioco
    congelato e' senza, e il lotto di riferimento lo prova. Decisione del
    designer: accenderlo a 1 come da regolamento (e rigenerare il
    riferimento, dichiarandolo) o togliere la frase dal regolamento.

89. **Via la Verticalita', il premio di scavo al suo posto.** Proposta del
    designer: togliere la Verticalita' e premiare, con lo Scavo, chi sta
    nelle pile alte. Formulazione misurata: chi costruisce al livello L sopra
    un edificio con Scavo S lo incassa subito (manopola `premio_scavo`,
    "nessuno" nei dati; `--premio per_livello|piu_livello|per_livello_meno_uno`),
    il proprietario tiene lo Scavo stampato a fine partita; base senza rudere
    a soglia 2, Verticalita' a zero. Senza rimpiazzo la citta' si appiattisce
    (-23 punti a giocatore, altezza 3,1, basi altrui 1,0). **S x L** rimette
    in piedi la citta' (altezza 4,1) e porta le basi altrui a 2,0 come oggi,
    con il canale Scavo a 19,6 a giocatore, tre quarti della Verticalita'
    tolta; ma e' neutro fra proprio e altrui, e **il kingmaker e' reale**:
    meta' del premio arriva nell'era 5 e in una partita su sei il vincitore
    cambierebbe senza il bottino dell'ultima era. S + L lo dimezza con un
    canale piu' piccolo; S x (L-1) paga poco e tardi. Da decidere: la scala
    (S x L) e la correzione all'ultima era (premio dimezzato nell'era 5, o
    solo fino all'era 4), entrambe da misurare. La strategia Scavo dei bot
    insegue la regola vecchia: le strategie vanno riscritte per la v2.
    Tutto in `docs/senza-rudere.md`.

90. **I 60 edifici in tre risorse, le tessere e la prima misura della v2.**
    Decisioni del designer: le Idee sono la Cultura resa risorsa e
    **sostituiscono** (il costo totale di ogni carta resta quello di oggi);
    Cultura, Religione e Ingegneria pagano Idee, il Medioevo ne chiede meno
    ("un periodo oscuro"), nelle ere 4-5 ogni carta ne paga almeno una
    ("esplodono"): domanda 5 / 6 / 4 / 15 / 18 per era. Le tessere producono
    per tipo con la curva dell'audit (fiume e collina Costruzione 2/2/1/1/1,
    pianura Denaro 0/1/1/2/2 piu' 1 Costruzione nelle ere 1-2, bosco Idee
    1/2/2/3/3) e il mix garantisce il bosco. Tabella e regole in
    `carte-v2.md` (le regole dei costi, da `tools/proponi_costi_v2.py`),
    file dati `data/cards-v2.json` (da `tools/genera_cards_v2.py`), misura in
    `docs/la-terza-risorsa.md`. Da sola la terza risorsa sposta poco (+2 punti,
    basi altrui da 2,0 a 2,5); con il pacchetto di regole si comporta come con
    le carte vecchie, ma il kingmaker dell'ultima era sale al 22%: la
    correzione all'era 5 del premio di scavo diventa necessaria. Restano il
    tetto delle risorse (D5) e in che risorsa pagare potenziamenti, Dinastia e
    ristrutturazione (D2).

91. **L'ultima era, il tetto a tre, e in che risorsa si pagano le azioni.**
    Decisioni del designer: correggere il premio di scavo nell'ultima era
    (manopola `premio_era5`: intero, dimezzato, niente); "tetto a tre", letto
    come 3 per risorsa alla dispersione con il totale di 5 che resta
    (`resource_cap_per_resource`, 3 nella v2, 0 nella v1.5); i potenziamenti
    pagano secondo cosa sono (Arte in Idee, Struttura in Costruzione, il resto
    in Denaro, importi di oggi); la Dinastia in Idee (4/3/3/3); la
    ristrutturazione in Costruzione e Denaro (la parte in Idee va in Denaro).
    Misurato a parita' di semi (`docs/la-terza-risorsa.md`): le decisioni sui
    dati sono neutre (un punto di differenza, stessa forma della citta'); il
    **premio dimezzato nell'era 5** porta le partite decise dall'ultima era dal
    21% al 12% senza cambiare la citta' (altezza 4,2, basi altrui 2,4), al
    costo di 4,5 punti di Scavo a giocatore; senza premio nell'era 5 la citta'
    smette di salire (altezza 4,0, basi altrui 2,0). Raccomandato: dimezzato.

92. **Il canone delle strategie per la v2.** Con il file v2 caricato il bot
    gioca Rendita, Lampo, Scavo, Continuita', Bilanciata, Obiettivi: la
    Verticale esce (senza Verticalita' non insegue niente), la Continuita'
    entra (senza il premio della colonna e' il quarto canale), la Scavo
    insegue il premio S x L di chi costruisce sopra invece dello Scavo di chi
    viene sepolto. Quale canone vale lo dice `CardDB.ruleset`, non una
    manopola. Misurato sullo stesso lotto v2 con i due canoni
    (`docs/la-terza-risorsa.md`): la citta' non cambia, e con il canone v2
    le sei strategie stanno tutte entro l'errore (27,5-36,8% contro 33,3
    atteso), la Scavo torna nella media, il kingmaker al 10%. E' il lotto di
    partenza per le prossime domande dell'audit.

93. **Il turno a un'azione, il draft dei Personaggi, e quanti lavoratori.**
    Il punto 8 della proposta letto alla lettera (`turno_v2` nel file v2):
    ogni turno UNA cosa, e il lavoratore va dove agisce. Letture adottate
    dove la proposta tace: si costruisce in qualsiasi colonna e il lavoratore
    sta sull'edificio nuovo, con +2 per l'era, e attiva solo quello (D9-D11);
    il lavoratore sul potenziamento resta sotto come scheletro e torna a fine
    era (D12); la ristrutturazione vale solo sulle proprie rovine e costa meta'
    del costo, Costruzione e Denaro (D13); passare consuma il lavoratore e
    incassa 1 Costruzione piu' 1 risorsa a scelta, l'era finisce quando
    finiscono i lavoratori (D14); la Dinastia resta un acquisto al posto del
    turno (D8). Decisione del designer: **i lavoratori restano tre** e il
    Personaggio si prende **in automatico a inizio era, senza lavoratore**
    (`draft_personaggi`: uno a testa in ordine di turno fra i cinque
    dell'era, gratis; Reclutare sparisce; i protettori si legano al primo
    edificio costruito nell'era; le Impronte chiedono l'edificio dopo la
    carta). Misurato (`docs/la-terza-risorsa.md`, quarta misura): con
    un'azione per lavoratore la partita si dimezza (7 edifici e 44 punti a
    giocatore contro 11 e 74), le basi altrui cadono da 2,3 a 0,6 e lo Scavo
    da 17 a 3: l'archeologia si spegne. Con 5 o 6 lavoratori il ritmo torna,
    ma i lavoratori restano tre. Il draft regala scheletri (da 1,8 a 9,4
    punti): la regola degli scheletri va decisa. **Aperto:** il designer ha
    detto che "una cosa sola per lavoratore" non e' la lettura giusta del
    punto 8; la lettura vera (il lavoratore sulla colonna attiva E poi si
    agisce, come oggi? le azioni senza lavoratore?) va scritta e misurata.
    Il bot v2 sconta l'incasso oltre quello che il mercato assorbe: senza,
    passava l'era a incassare (15 punti a giocatore).

94. **Quattro lavoratori che attivano e poi agiscono.** Decisione del
    designer dopo il punto 93: "voglio tre lavoratori come prima che fanno
    una delle cinque azioni" era la lettura giusta della proposta, ma la
    misura ha mostrato che nella v1.5 ogni lavoratore faceva DUE cose
    (attivava e poi agiva) e con una sola la partita si dimezza. Quindi: i
    lavoratori diventano **quattro**, e ogni lavoratore attiva la colonna e
    poi fa un'azione (costruire, potenziare, ristrutturare) li' o accanto,
    come nella v1.5; il Personaggio resta quello del draft (punto 93). Il
    file v2 spegne `turno_v2`, che resta come manopola (`--turno_v2 1`), e
    porta `workers_base` a 4; la ristrutturazione della propria rovina
    dipende da `senza_rudere` e non dal turno; i protettori del draft si
    legano al primo edificio costruito nell'era con tutti e due i turni.
    Misurato (`docs/la-terza-risorsa.md`, quinta misura): la v2 torna una
    partita intera, 13,6 edifici e 97 punti a giocatore, basi altrui 2,2,
    kingmaker 11%; il draft da solo vale 13 punti (Scheletri e Rendita);
    la **Rendita vince il 47%** delle partite e il Lampo il 23%: quattro
    attivazioni pagano piu' censimenti. Aperto: la regola degli scheletri
    per il Personaggio del draft, e la Vetusta' come prima manopola contro
    la Rendita. Un documento solo per le carte: `docs/carte-v2.md`
    (generato da `tools/carte_v2.py`), al posto di `carte-da-rifare.md` e
    `proposte/costi-tre-risorse.md`.

95. **Niente Personaggi sepolti, niente Vetusta', lo scheletro e' il
    lavoratore del potenziamento.** Tre decisioni del designer dopo il
    punto 94: il Personaggio del draft non si seppellisce
    (`personaggi_sepolti` falso nel file v2, vero dove manca); la Vetusta'
    non esiste piu' ("non mi e' mai piaciuta, semplifichiamo": tetto
    `vetusta_max` 0 nel file v2, il motore non cambia; Colosseo, Il
    Silvicoltore e Speculazione edilizia la contavano e non scattano piu',
    proposte in `docs/carte-v2.md`; il bosco perde il +4); gli scheletri ci
    sono e li lascia il lavoratore che piazza un potenziamento
    (`scheletro_potenziamento`, vero nel file v2: resta sotto l'edificio,
    uno per edificio, non nell'era Moderna, 6 meno l'era se l'edificio
    finisce sotterrato; nel turno a un'azione era gia' cosi', D12).
    Manopole `--sepolti` e `--vetusta` per rigiocare con una decisione
    sola. Misurato (`docs/la-terza-risorsa.md`, sesta misura): le
    sepolture del draft erano solo 4,6 punti regalati; la Vetusta' era due
    terzi della Rendita (27,9 -> 10,6) e senza si costruisce piu' sopra
    (altezza 4,66, premio 12,2, kingmaker 15%); lo scheletro del
    potenziamento vale 2,8 punti. La **Rendita vince il 56%** delle
    partite anche senza Vetusta': il motivo e' la protezione, quattro
    lavoratori proteggono quattro edifici per era. Prossima manopola:
    `protection_bonus` o il censimento. Il torneo ora conta le azioni per
    giocatore anche a quattro lavoratori.

96. **La protezione a +1, e quanto valgono gli scheletri.** Due domande
    del designer dopo il punto 95. Misurato sulla base W, stessi semi
    (`docs/la-terza-risorsa.md`, settima misura): la protezione a +1
    (`--protezione 1`) non cambia niente, stessi punti, stessa citta', la
    Rendita vince ancora il 54%: la strategia Rendita costruisce meno
    edifici ma cari e duraturi con la Rendita stampata alta, e con quattro
    lavoratori le risorse per comprarli ci sono sempre. Prossima manopola:
    il valore di Rendita delle carte care, o il censimento. Gli scheletri
    del potenziamento oggi valgono 2,8 punti a giocatore (3%), e pagano
    solo se l'edificio finisce sotterrato: non sono un motivo per
    potenziare. Con lo scheletro che **conta sempre** (`--scheletro sempre`,
    costante `scheletro_conta`, 6 meno l'era comunque finisca l'edificio)
    valgono 9,6 punti (11%), i potenziamenti salgono da 2,8 a 3,4 a
    giocatore, la citta' non cambia e il kingmaker scende al 13%.
    Raccomandato: conta sempre. In attesa della decisione del designer.

97. **La Rendita delle carte care.** Prova chiesta dal designer contro la
    strategia Rendita che vince il 57%: `--rendita_tetto N` taglia la
    Rendita stampata di ogni carta a N (a 2 cinque carte: Abbazia,
    Castello, Fortezza bastionata, Ponte monumentale, Duomo; a 1 otto).
    Misurato sulla base Z, la v2 di oggi con lo scheletro che conta sempre
    (`docs/la-terza-risorsa.md`, ottava misura): a 2 la Rendita vince il
    49%, a 1 il 44%, con il canale Rendita quasi cancellato (5 punti su
    84). Il resto del vantaggio e' lo stile di quella strategia, meno
    edifici e piu' potenziamenti (4,9 contro 2,7-3,8), che con lo scheletro
    che conta sempre valgono 12 punti: con quattro lavoratori costruire
    poco e bene batte costruire tanto. La Scavo e' la strategia debole
    (17-22%): da ritarare il bot, non la regola. Da decidere: la Rendita
    delle cinque carte care a 2 (cinque righe in `carte-v2.md`, forbice
    piu' stretta di 8 punti senza toccare la citta').

98. **Le strategie rifatte per la v2.** Decisione del designer ("rifai le
    strategie"). Le spinte delle strategie sono una tabella nel bot
    (`SPINTE_V1`, `SPINTE_V2`), e `--spinta chiave=valore,...` le sovrascrive
    lotto per lotto: la taratura si fa misurando, tre giri di quattro
    tornei sugli stessi semi (`docs/la-terza-risorsa.md`, nona misura).
    Abbassare la spinta della Rendita la rendeva PIU' forte: il vantaggio
    era nel valutatore comune, che stimava le rendite future come se
    l'edificio restasse scoperto, mentre con quattro lavoratori quasi
    tutto viene protetto (`protezione_attesa`, 2 nella v2). La Scavo
    costruisce a terra le carte con lo Scavo alto invece di passare
    (`scavo_terra` -0,5, `scavo_terra_scavo` 0,5). Risultato: Rendita dal
    57 al 40%, Scavo dal 17 al 32%, le altre fra 27 e 37, citta' e punti
    invariati; il lotto rigiocato con la tabella scritta nel bot esce
    identico a quello della manopola. Il Lampo resta il piu' debole (27%)
    per la natura delle sue carte.

99. **Le tre carte che contavano la Vetusta'.** Decisione del designer
    ("cambia le tre carte"), sulle proposte di `docs/carte-v2.md`, nel solo
    file v2: **Colosseo** premia il primo edificio attivo con resistenza 7
    o piu' (il matcher degli effetti impara l'intervallo `resistance`,
    sulla resistenza efficace); **Il Silvicoltore** vale per un edificio
    attivo su bosco costruito nell'era 1 o 2 (il vecchio del bosco);
    **Speculazione edilizia** toglie 1 res a ogni edificio con 2 o piu'
    potenziamenti (colpisce chi ha costruito sopra il costruito). I dati
    v1.5 non cambiano. Il documento delle carte ora mostra come "oggi" il
    testo della v1.5 e in grassetto quello del file v2 quando differisce.
    La PR #29 (quattro lavoratori, draft, niente Vetusta', scheletro del
    potenziamento, carte care a 2, strategie rifatte) e' su main.

100. **Le tessere una volta per era, via il disturbo, piu' Lampo a otto
    carte.** Tre decisioni del designer. Le tessere (punto 6, D20-D22): la
    produzione per era resta, l'abilita' permanente diventa un effetto
    che scatta una volta per era alla prima occasione, poi la tessera si
    gira (`tessere_una_volta_per_era`, vera nel file v2, `--tessere 0` la
    spegne; `gs.tessere_usate` colonna per colonna): pianura -1
    Costruzione a una carta da 2 o 3 caselle, fiume +1 Denaro a chi la
    attiva, collina +1 resistenza per l'era al primo edificio costruito
    qui, bosco -1 Costruzione a una ristrutturazione; con i dati v1.5 le
    regole restano permanenti. Il "+1 per il disturbo" (punto 88) non
    esiste piu': "cambia poco e aggiunge complessita'", costante e codice
    tolti da tutti e due i file, il lotto di riferimento v1.5 esce
    identico. Il Lampo sale di 1 su otto carte a solo Lampo (Insulae,
    Emporio, Borgo, Torre civica, Loggia, Banco, Condominio, Officina).
    Misurato (`docs/la-terza-risorsa.md`, decima misura): le tessere una
    volta per era non cambiano la partita (stessa citta', stessi punti);
    il Lampo in piu' alza il Lampo di tutti (+2,7 a giocatore) e non la
    strategia Lampo, che resta ultima (23-24%) perche' costruisce edifici
    che cadono: se deve vincere di piu', la strada e' il bot, non le carte.

101. **La strategia Lampo potenzia.** Dopo il punto 100 (il Lampo delle
    carte e' di tutti) il designer ha detto di andare avanti sul bot. Due
    spinte nuove nella tabella delle strategie, solo per la Lampo:
    `lampo_potenzia` (ai potenziamenti, punti sicuri con lo scheletro che
    conta sempre) e `lampo_sopra` (al costruire sopra), misurate con
    `--spinta` in quattro tornei sugli stessi semi
    (`docs/la-terza-risorsa.md`, undicesima misura). Vince
    `lampo_potenzia` 3, `lampo_sopra` resta 0: la Lampo dal 23 al 31%,
    3,6 potenziamenti a partita invece di 2,5, i suoi 31 punti di Lampo
    intatti; tutte e sei le strategie fra il 30 e il 38% (atteso 33,
    errore 5), per la prima volta nessuna fuori; citta' e punti
    invariati. Il lotto rigiocato con la tabella scritta nel bot esce
    identico a quello della manopola. Con i dati v1.5 niente cambia.

102. **La v2 nella schermata di gioco: l'interruttore e il draft.** Il
    designer ("prima l'interruttore e il draft"). Nella schermata di scelta
    c'e' la riga "Regolamento": v1.5 (`data/cards.json`) o v2
    (`data/cards-v2.json`); il gioco parte dalla v2, i test della vista
    dalla v1.5 (`ScelteInizio.predefinito`). `comincia()` carica il file
    dati scelto ogni volta, cosi' si passa da un regolamento all'altro
    senza riavviare; il canone dei bot segue il file. Il draft a schermo:
    la scelta in sospeso di tipo "draft" si risolve cliccando la carta
    nella fila dei Personaggi (le opzioni sono posizioni nella fila), la
    riga di stato lo dice; il bersaglio di un'Impronta si clicca
    sull'edificio come le scelte di sempre. La riga in alto mostra le tre
    risorse e la carta del mercato il costo in C/D/I quando il file e' v2.
    Restano da disegnare: le tessere girate, il quarto lavoratore sulla
    plancia, lo scheletro del potenziamento, la rovina senza rudere.

103. **Le tessere girate a schermo.** Il designer ("vai con le tessere
    girate"). Nella v2 la tessera usata nell'era si abbuia con un velo
    scuro e porta la scritta "girata" sulla fascia in fondo, dove sta il
    cartellino della Prosperita'; a inizio era il motore la rigira e il
    velo sparisce. Nella v1.5 nessuna tessera si abbuia mai (la lista e'
    tutta falsa). Il riquadro che segue il mouse ora descrive anche la
    tessera nuda: colonna, terreno, cosa produce in quest'era, la regola
    stampata, e nella v2 se l'effetto e' ancora da usare o la tessera e'
    girata. Test della vista: il velo compare sulla colonna giusta dopo
    l'attivazione del fiume e il riquadro lo dice.

104. **Il quarto lavoratore a schermo.** Il designer ("vai con il quarto
    lavoratore"). Il disegno dei pupazzetti legge `p.workers`, quindi con il
    file v2 i quattro lavoratori stavano gia' sulla bacchetta (scatto con
    `tools/scatta3d.sh -- --dati data/cards-v2.json`, che ora carica il
    file v2 e gioca col canone v2); il test lo fissa. Quel che mancava era
    il resto: la Dinastia e' il quinto lavoratore e il riquadro lo dice, il
    suo prezzo (e ogni prezzo delle azioni) si scrive anche in Idee, con
    l'ammanco. Nella v1.5 niente cambia.

105. **Lo scheletro del lavoratore a schermo.** Il designer ("vai"). Nella
    v2 il sepolto e' il lavoratore del potenziamento (`Building.LAVORATORE`,
    registri 95-96), non una carta: finiva nel ventaglio del giocatore come
    "personaggio" di nome "lavoratore", cercato in un mazzo dove non c'e'.
    Ora nel ventaglio, sotto la carta dell'edificio e in fondo alla pila
    (sotto il potenziamento), ci va il gettone dello scheletro dell'era, in
    piedi sulla striscia scoperta; sulla basetta stava gia'. Il riquadro del
    mouse lo descrive sia sul gettone sia sull'edificio ("scheletro: il
    lavoratore del potenziamento · era N · vale 6-N"), e nella v1.5 chiama
    il Personaggio sepolto per nome. Nella v1.5 nient'altro cambia. Test
    della vista: il gettone c'e', l'id e' l'era, sta sotto edificio e
    potenziamento, la vista lo disegna, i riquadri lo dicono.

106. **La rovina senza rudere a schermo.** Il designer ("vai"). Nella v2
    non c'e' il rudere e la propria rovina si ristruttura (registri 88 e
    seguenti); al tavolo "la sagoma ruotata mostra il lato rovina". A
    schermo la rovina spariva come nella v1.5, dove e' solo il basamento
    di chi ci costruisce sopra: cosi' nascondeva proprio la cosa che nella
    v2 si puo' fare. Ora, con `senza_rudere`, la sagoma della rovina resta
    in piedi, girata di mezzo giro e scurita (senza il disegno del lato
    rovina si vede il retro del cartone), non si abbatte, e si clicca per
    la sagoma; sepolta sparisce come tutte. I testi seguono: il tasto dice
    "Ristruttura", l'azione "Ristrutturazione", i messaggi parlano di
    rovina, e il riquadro dell'edificio dice "si puo' ristrutturare" sulle
    proprie. Nella v1.5 nulla cambia (la costante e' spenta). Test della
    vista: sagoma in piedi e girata, niente crollo, ingombro del clic,
    testi; nella v1.5 la rovina resta senza sagoma.

107. **Il regolamento della v2, scritto.** Il designer ("fammi il nuovo
    regolamento"). `docs/regolamento-v2.md`: la struttura e il testo del
    regolamento v1.5 dove la v2 non cambia, e le decisioni dei punti 84-106
    dove cambia: tre risorse, tessere pescate con produzione per era ed
    effetto una volta per era, draft dei Personaggi, quattro lavoratori che
    attivano e agiscono, premio di scavo S x L dimezzato nell'era Moderna al
    posto della Verticalita', niente rudere ne' Vetusta', rovina girata che
    si ristruttura (propria, meta' costo in C e D), scheletro del
    potenziamento che conta sempre, Prosperita' una volta per era in Denaro,
    tetto 3 per risorsa e 5 in tutto, Dinastia in Idee. Ogni numero e' quello
    che gioca il motore con `data/cards-v2.json`. In fondo le cose che
    restano da decidere al tavolo (mercato, di chi e' la rovina, misure
    delle sagome). Le varianti non sono misurate con la v2.

108. **La v2 a 2 e a 4 giocatori.** Il designer ("vai con le misure a 2 e 4
    giocatori"): tutte le misure erano a tre. Stessi lotti (750 torneo, 2 000
    vita) a 2, 3 e 4, v2 e v1.5 (`docs/la-terza-risorsa.md`, dodicesima
    misura). La citta' della v2 ha la stessa forma a ogni numero di
    giocatori (altezza 4,4-4,6, un terzo cade nell'era in cui nasce, 6-7
    sopraelevazioni a testa) e le Idee si spendono (90-97%). Due cose da
    decidere. **A due** le strategie si aprono: Continuita' 58% e Obiettivi
    40% fuori dall'errore (50 +- 6), nella v1.5 a due tutte fra 46 e 54;
    Obiettivi ha un Monumento solo (giocatori meno uno) e senza la
    Verticalita' e' la piu' povera, Continuita' costruisce sopra i propri
    nelle cinque colonne. **A quattro** le strategie tengono (25 +- 4, meglio
    della v1.5) ma ognuno passa 5,1 volte a partita: sedici turni per era
    contro dodici sagome dell'era, 49 sagome costruite su 60, e il draft ha
    tolto Reclutare, che nella v1.5 era la valvola; kingmaker 18% (10 a
    due, 13 a tre). Controprova con tre lavoratori: a quattro i passaggi
    cadono a 1,9 ma la partita perde 9 punti e le strategie non si muovono
    (il mercato corto e' confermato; se si interviene, meglio un incasso al
    passaggio o piu' sagome che un lavoratore in meno); a due la forbice si
    chiude (Continuita' 55, Obiettivi 45) al costo di 13 punti. Resta da
    fare la controprova del secondo Monumento rivelato a due (serve una
    costante: oggi "giocatori meno uno" e' nel codice).

109. **L'incasso al passaggio non cambia niente.** Il designer ("vai con
    l'incasso al passaggio a quattro"). Costante `passa_incasso` (spenta dove
    manca, `--passa_incasso 1`): nel turno della v1.5 chi non fa l'azione
    incassa 1 Costruzione piu' 1 risorsa a scelta, e il bot la valuta come
    una mossa. Misurato a 4, 3 e 2 giocatori, stessi semi
    (`docs/la-terza-risorsa.md`, tredicesima misura): a quattro i passaggi
    restano 5 a testa e gli edifici 12,2, perche' il vincolo sono le sagome
    e le risorse in piu' si perdono alla dispersione; a tre e a due
    niente. Non entra nel file v2; la manopola resta.

110. **Il secondo Monumento a due, e piu' sagome a quattro.** Il designer
    ("vai anche con il secondo monumento a due"; per la scarsita' a
    quattro: raddoppiare chiese o villaggi, o aggiungere abitazioni
    generiche che costano poco e rendono poco). Costante
    `monumenti_rivelati_by_players` (`--monumenti N`; assente: giocatori
    meno uno); `min_players` sulle sagome che entrano nel mazzo solo con
    abbastanza giocatori; due file di prova in `data/proposte/` da
    `genera_cards_v2.py --variante doppioni|abitazioni`, dieci sagome in
    piu', solo a quattro. Misurato (tredicesima misura). Il secondo
    Monumento a due non risolve: la partita e' identica, Obiettivi da 40 a
    42% e resta la piu' povera; e' il bot, non i Monumenti. A quattro le
    dieci sagome in piu' danno un edificio in piu' a testa e tolgono un
    passaggio (da 5,1 a 4): la leva e' giusta ma dieci non bastano, ne
    servono circa venti. I doppioni sono meglio delle abitazioni (+6 punti
    contro +2, kingmaker 15%, niente da disegnare; le abitazioni spostano
    Rendita a 36 e Continuita' a 18), ma scelti per classe affossano la
    Lampo (15%). Da decidere: doppioni scelti per Lampo, o quattro per
    era, poi ricontrollare la Lampo. Il file v2 non cambia.

111. **Le case generiche a quattro: solo Lampo, due taglie.** Il designer
    (dopo il punto 110): "copie generiche di edifici che costano poco e
    danno PV Lampo, e altre che costano poco di piu' e danno un po' piu'
    PV; non fanno consumare risorse e danno un rientro annacquato; poi si
    possono raddoppiare edifici non enormi ne' speciali, tipo chiese".
    Due file di prova (`--variante case`, `--variante case_doppioni`):
    venti case (due taglie per era, due copie, senza produzione, Lampo 1 e
    2-3), e le stesse piu' dieci doppioni di chiese; solo a quattro.
    Misurato (`docs/la-terza-risorsa.md`, tredicesima misura): le case
    risolvono il mercato (13,9 edifici a testa, passaggi da 5,1 a 3,5, +5
    punti, citta' uguale, kingmaker 16%) e le chiese in piu' non aggiungono
    niente; ma il Lampo diventa di tutti (+4 a testa) e la strategia Lampo
    affonda al 14% (13 con le chiese), la Rendita sale al 34-36%. Se il
    Lampo si compra con una casa da 1, specializzarsi nel Lampo non e' piu'
    una strategia. Da decidere: case che danno Scavo invece di Lampo, case
    senza niente (puro suolo), o il bot Lampo ritarato a quattro. Il file
    v2 non cambia.

112. **"Prova tutto": case con Scavo, case senza niente, bot Lampo
    ritarato.** Il designer, dopo il punto 111. Misurato a quattro, stessi
    semi (`docs/la-terza-risorsa.md`, tredicesima misura). Le case senza
    niente non si costruiscono (passaggi 5,1 come senza case): inutili. Le
    case con Scavo 2 e 3 sono il compromesso: la Lampo torna al 23% e le
    strategie stanno nell'errore tranne la Scavo al 18%, ma si costruiscono
    meno (13,0 edifici, passaggi 4,5): il mercato corto e' mezzo risolto.
    Ritarare il bot Lampo sulle case con Lampo non serve (lampo 2,5 lo
    porta al 7%, potenzia 5 al 18%): il problema e' il canale che non
    distingue piu' nessuno, non il bot. La variante mista (piccola con
    Lampo 1, grande con Scavo 3) sta in mezzo e non aiuta (Rendita 34,
    Scavo 18). Ogni casa che si compra volentieri regala qualcosa alla
    Rendita, che a quattro lavoratori compra sempre: la domanda vera a
    quattro e' la Rendita, non le case. Le case con Scavo restano il
    compromesso. Il file v2 non cambia.

113. **Le regole non cambiano col numero di giocatori.** Decisione del
    designer dopo il punto 112 ("non voglio che le regole cambino al
    variare dei giocatori"). Niente sagome "da quattro in su" nel file v2,
    niente Monumenti in piu' a due: le manopole (`min_players`,
    `monumenti_rivelati_by_players`, `passa_incasso`) restano nel motore,
    spente, e i file di prova in `data/proposte/` restano come misura. A
    quattro il mercato resta corto (un turno per era a testa senza azione)
    e la Rendita al 30%; a due Continuita' 58% e Obiettivi 40%: sono i
    numeri del gioco a quei tavoli, da riguardare con i bot, non con le
    regole.

114. **Il calendario del torneo, e i bot a due e a quattro.** Il designer
    ("i bot a due e quattro"). Cercando le spinte e' venuto fuori che il
    torneo assegnava le strategie a finestre consecutive della lista: con
    meno posti che strategie ognuna incontrava solo le vicine, sempre le
    stesse, e il 58% della Continuita' e il 40% della Obiettivi a due erano
    accoppiamenti. Il torneo ha ora `--giro tutte` (ogni combinazione di
    strategie lo stesso numero di volte, posti a rotazione); il giro vecchio
    resta dove non si chiede. Rimisurato a 2, 3 e 4
    (`docs/la-terza-risorsa.md`, quattordicesima misura): la partita e'
    identica, la mappa vera e' Scavo debole a due e a tre (38%, 26%),
    Rendita forte (36%) e Lampo debole (18%) a quattro. Le spinte sono
    handicap: spingere di piu' peggiora, la Bilanciata senza spinte e' la
    piu' forte quasi ovunque. Taratura verso il basso: Scavo a meta' spinta
    (in `SPINTE_V2`, vale ovunque), a quattro Lampo con meta' peso al Lampo
    e potenziamenti a 5 (`SPINTE_V2_PER_GIOCATORI`, le regole non cambiano,
    cambia il bot). Rigiocato senza manopole: tutte entro l'errore a tutti
    e tre i tavoli (a 2: 44-54; a 3: 30-37; a 4: 21-28). La v1.5 e la
    partita non cambiano.

115. **Le case per tutti.** Il designer, dopo il punto 113: "volevo introdurre
    gli edifici generici, che per me risolvono: due o tre tipi diversi, con
    costi e resistenza bassi e incasso Lampo di PV, magari uno che da'
    anche Scavo. Nessuna regola diversa per numero di giocatori; magari si
    puo' decidere il numero di carte del mercato in base ai giocatori."
    File di prova `--variante case_tutti`: tre case per era, una copia
    ciascuna, per ogni tavolo (piccola: costa 1, Lampo 1; grande: costa 2,
    Lampo 2-3; del borgo: costa 1, Scavo 2), 75 sagome; manopola
    `--mercato N`. Misurato sul torneo corretto coi bot tarati
    (`docs/la-terza-risorsa.md`, quindicesima misura): reggono a tutti e
    tre i tavoli (strategie nell'errore a 2 e a 3, a 4 la Rendita al 30
    contro 29 di bordo), a tre e quattro danno l'edificio in piu' che
    mancava (13,2 a quattro, passaggi da 5,4 a 4,1), a due tolgono tre
    punti perche' diluiscono il mercato; kingmaker 8/12/13%. Il mercato a 8
    non cambia niente: si lascia a 6. Da decidere: tre per era una copia,
    o due copie della piccola. Il file v2 non cambia finche' non si decide.

116. **Le case nel file v2: in riserva, due copie.** Decisione del designer
    dopo il punto 115 ("confermo, ma farei due copie di ognuna, poi il
    giocatore decide cosa comprare; sono sempre disponibili, non vengono
    pescate"). Le quattordici case (tre per era: piccola, grande e con lo
    Scavo; nell'era Moderna solo le prime due, perche' "lo scavo nell'era 5
    non vale") stanno nel file v2 per tutti i tavoli con `riserva` vero e
    `copie` 2: non entrano nel mazzo
    dell'era, a inizio era si scoprono tutte accanto al mercato
    (`gs.riserva`, una voce per copia), si comprano come dal mercato senza
    rimpiazzo e a fine era le avanzate si scartano. Bot, azioni e vista
    guardano `gs.in_vendita()`, mercato piu' riserva; nella v1.5 la riserva
    e' vuota e il riferimento e' identico. Il documento delle carte le
    porta con la sigla RIS; il regolamento ha la riserva e le case. Misura
    a 2, 3 e 4 sul torneo corretto (sedicesima misura): la riserva si
    compra piu' del mazzo (edifici a testa 13,6 / 15,1 / 13,4 contro 12,8 /
    13,8 / 12,0; passaggi a quattro da 5,4 a 3,9) e a due non toglie piu'
    niente (84 PV contro 83), perche' il mazzo dell'era non e' diluito;
    kingmaker 10 / 14 / 15 %. Due strategie sul bordo: Lampo a tre 39 %
    (bordo 38), Rendita a quattro 33 % (bordo 29). Si tiene cosi'; da
    rimisurare se si ritoccano i bot. La vita delle carte a tre dice
    pero' che le case con lo Scavo non le compra nessuno (98 costruzioni
    su 16 000 copie: alla stessa spesa c'e' la piccola con Lampo 1) e che
    le case grandi delle ere 4-5 (Lampo 3 a costo 2) finiscono quasi ogni
    partita (3989 e 3969 copie su 4000); 3,6 case a testa a tre. Deciso
    al punto 117.

117. **Le case: lo Scavo prende anche il Lampo, la grande non supera 2.**
    Decisione del designer dopo la sedicesima misura ("le case con lo
    Scavo le rafforziamo portando anche i PV, e Lampo 3 lo portiamo a 2").
    La casa con lo Scavo (Ripari, Tuguri, Casupole, Case popolari) ha
    Lampo 1 come la piccola, oltre allo Scavo 2, allo stesso costo; le
    case grandi delle ere 4-5 (Palazzetto, Condominio popolare) scendono
    da Lampo 3 a 2. Nota: a pari costo e resistenza la casa con lo Scavo
    domina la piccola nelle ere 1-4; la piccola resta la scelta solo
    quando le due copie dell'altra sono finite. Misurato (diciassettesima
    misura): il Lampo a testa scende di 1-1,5 punti senza toccare edifici
    e passaggi; la casa con lo Scavo ha sostituito la piccola nelle ere
    1-3 (0 / 87 / 4 copie su 4000), le Case popolari sono la casa piu'
    comprata (3884 su 4000), il Palazzetto scende a 562. Lampo a tre (40 %)
    e Rendita a quattro (32 %) restano sul bordo: e' la presenza delle
    case, non il loro Lampo; da ritarare i bot a tre e quattro. La
    piccola nelle ere 1-3, che non si compra piu', resta: e' la terza e la
    quarta copia della casa da 1 (deciso dal designer).

118. **I bot ritarati con le case.** Chiesto dal designer dopo la
    diciassettesima misura. Con le case della riserva a tre la Lampo
    vinceva il 40% e a quattro la Rendita il 32% e la Scavo il 19%. Stesso
    metodo del punto 114 (le spinte sono handicap): a tre `lampo` 2,0
    (Lampo 40 -> 30); a quattro `rendita_per_era` 1,5 e Scavo a un quarto
    (`scavo_premio` 0,2, `scavo_terra_scavo` 0,1): Rendita 32 -> 28, Scavo
    19 -> 23. Le tabelle stanno in `SPINTE_V2_PER_GIOCATORI` per tavolo; a
    due la base va bene. Tutte le strategie entro l'errore a 2, 3 e 4; la
    partita (PV, edifici, passaggi) non cambia al decimale. La v1.5 non
    cambia (diciottesima misura).

119. **Il riepilogo finale con i nomi del regolamento v2.** Il designer
    ("fai tu e poi mergia"). La tabella di fine partita chiamava le
    colonne con i nomi e l'ordine della v1.5 anche nella v2. Ora i nomi
    seguono il file dei dati caricato (`Riepilogo.voci()`): nella v2 sono
    Lampo, PV prodotti, Censimento, Continuita', Scavo+premio (il premio
    di scavo pagato sul momento e lo Scavo di fine partita stanno nello
    stesso canale del nucleo, quindi una colonna sola col nome che lo
    dice), Scheletri, Monumenti, Eredita', Finali; la Verticalita' non c'e'
    piu'. Trovato per strada: la coda della tabella, che raccoglie i canali
    che non conosce, mostrava anche quelli a zero (il nucleo segna
    `verticalita` con 0 nella v2); ora una colonna compare solo se ha dato
    punti a qualcuno. I nomi stanno in 86 px a corpo 12: il test lo
    controlla. La v1.5 non cambia.

120. **Le carte degli edifici della v2, stampate.** Il designer ha caricato
    i cinque PDF `materiali/Edifici_<Era>_Era_A4.pdf`: 90 carte, cioe' i 60
    edifici e le case della riserva in due copie. Letti a macchina (il
    testo e' vero testo) e confrontati campo per campo con
    `data/cards-v2.json`: 71 edifici su 74 coincidono in tutto. Restano
    indietro tre case, stampate prima del punto 117: **Case popolari**
    Lampo 0 (dati 2), **Palazzetto** e **Condominio popolare** Lampo 3
    (dati 2). E sono stampate due copie di **Case operaie**, la casa con lo
    Scavo dell'era 5 tolta al punto 116. Da correggere nel PDF: le tre case
    a Lampo 2 e via le Case operaie. Intanto le facce si estraggono per id
    (`tools/estrai_grafica.py`, che ripete il confronto a ogni estrazione) e
    la vista v2 le usa per mercato, riserva e ventagli; le Case operaie non
    si estraggono. Vedi `docs/materiali-di-stampa.md`.

121. **Le tessere dell'era.** Decisione del designer, dalla sua dima: il
    terreno ha una produzione di base fissa (Pianura e Collina 1
    Costruzione, Fiume 1 Denaro, Bosco 1 Idea) e ogni era su ogni colonna
    si posa una tessera dell'era, pescata fra le 14 dell'era (7 diverse in
    due copie), non legata al terreno, con da zero a una icona di
    produzione in piu' e un effetto una volta per era. Scatta solo la
    tessera della colonna scelta dal giocatore ("non importa se un
    edificio copre piu' colonne"). Nomi confermati; seconde copie stampate
    a parte. Nel motore: modulo `TessereEra`, costante `tessere_era` nel
    file v2, manopola `--tessere_era`. Le regole vecchie dei terreni si
    spengono. Misurato (diciannovesima misura): piu' punti (+7,8 a testa a
    due, +2,4 a tre, +4,6 a quattro), la Lampo fuori dall'errore a due
    (61 %) e a tre (41 %), la Obiettivi sul bordo basso a tre (28 %);
    quattro tessere non scattano quasi mai (Raccoglitori, Restauratori,
    Giardino all'italiana, Spoglio delle rovine). Aperto: sostituire le
    quattro, e togliere Lampo alle tessere o ritarare il bot.

122. **Le caselle e le forme nuove delle carte.** Decisioni del designer:
    le carte quadrate occupano una colonna per due binari; il Colosseo
    (Anfiteatro) passa da 3 a 2 colonne ed e' 2x2 come Castello e Fortezza
    bastionata; il Grattacielo e' una colonna per tre binari; Acquedotto e
    Stazione restano larghi 3. I binari non sono le ere: si costruisce nel
    binario che si vuole, si parte dal fondo per comodita'. Si attiva ogni
    edificio che tocca la colonna attivata. I 2x2 e il Grattacielo vanno
    solo sopra, con le regole di sempre (almeno una base vera, propri
    attivi spianati, terrapieno sulle caselle vuote), e sopra di loro si
    costruisce solo quando sono in rovina. Nel motore: costante `caselle`
    del file v2, campi `depth` e `solo_su_rovine`. Misurato (ventesima
    misura): piu' Scavo, citta' piu' bassa, la Lampo fuori dall'errore a
    tutti i tavoli (66/48/41 %). Aperto: riportare la Lampo nell'errore.

123. **I potenziamenti raddoppiati.** Richiesta del designer: altri 25
    potenziamenti, cinque per era, cosi' ogni era ha un mazzo di dieci carte
    diverse. Stessa economia dei primi 25 (costo 1 nelle ere 1-3, 2 nelle
    ere 4-5, nella risorsa della famiglia) e forza pari a quelli della
    stessa era. Nel motore l'unica aggiunta e' che "quando abiti" puo' dare
    anche Idee. Elenco in `docs/proposte/potenziamenti-v2.md`, dati in
    `tools/genera_cards_v2.py`. Aperto: stampa delle carte e misura.

124. **I testi delle carte e le icone dei punti.** Il designer: "correggi
    tutti i testi"; il Lampo fa l'effetto una volta e basta, poi ci sono gli
    effetti permanenti e quelli di fine partita. Sulle carte stampate
    Rendita (PV a fine di ogni era) e Lampo (PV subito, una volta) usavano
    la moneta del Denaro, e sembrava un doppio incasso: nel motore non lo
    era. Proposta: corona d'alloro per i punti, con clessidra (Rendita) o
    fulmine (Lampo); la moneta solo per il Denaro. I testi sono riscritti
    tutti in `tools/genera_cards_v2.py` (`TESTI_V2`): tre tempi, niente
    frasi di colore, niente parole della v1.5, niente ripetizioni di cio'
    che dice un'icona. Due correzioni al motore per far dire alla carta il
    vero: la Bottega d'artista sconta nella risorsa del potenziamento
    (com'e' stampata), e il Ponte da' +1 anche alle Idee. Documento unico
    per la stampa: `docs/carte-v2-da-stampare.md`
    (`tools/stampa_carte_v2.py`); prompt per rifare le carte:
    `docs/proposte/prompt-chatgpt-correzioni-carte-v2.md`.

125. **La Lampo troppo forte, e il rapporto delle partite.** Il designer:
    "prova le tre strade e applica quella migliore o la combinazione". Fra
    bot ritarato, Lampo tolto alle tessere dell'era e tetto al Lampo delle
    carte, le tessere e il tetto a 3 non servono; il tetto a 2 insieme al
    bot ritarato riporta la Lampo nell'errore a tutti i tavoli (49/30/25 %,
    ventiduesima misura). Applicato: `LAMPO_TETTO = 2` in
    `tools/genera_cards_v2.py` (16 carte, nel prompt per ChatGPT) e spinta
    Lampo 2,6/2,6/3,2 nel bot. Poi il rapporto completo delle partite
    (`audit_partita --rapporto 1`, `tools/rapporto_partite.py`,
    `tools/rapporto_html.py`): i contatori di entrate e uscite per fonte
    non cambiano il gioco. Quel che il rapporto mostra e resta da decidere:
    i dieci potenziamenti dell'era 1 non si usano mai (per potenziare serve
    attivare la colonna dell'edificio, e nell'era 1 i propri edifici stanno
    sulle colonne gia' attivate); gli edifici dell'era 4 crollano quasi
    tutti all'evento della loro era; col tetto a tre per risorsa si buttano
    10-12 Costruzione e 6-9 Denaro a testa per partita; i Monumenti si
    prendono di rado; tre Eredita' (Condottiero, Antiquario, Restauratore)
    quasi non riescono.

126. **L'era 4, le risorse e le carte morte.** Decisioni del designer dopo il
    rapporto delle partite: rivedere gli eventi dell'era 4 (nell'era 5 far
    crollare non ha senso: resta senza evento), rivedere il tetto delle
    risorse ("il problema piu' serio di bilanciamento") e sistemare le carte
    morte ("le proposte sulle carte vanno bene, procedi"). Applicato nel file
    v2 (`tools/genera_cards_v2.py`, `carte_vive` ed `eventi_e_avanzo`): i
    sei eventi dell'era 4 a forza 3; a fine era ogni 2 risorse oltre il
    tetto diventano 1 Idea (`avanzo_idee`); la fila dei potenziamenti resta
    un'era (`fila_potenziamenti_resta`; `potenzia_adiacente` provato e
    scartato); case piccole, Militari, Museo, Cemento armato, tre tessere
    dell'era e tre Eredita' corretti (anche nel prompt per ChatGPT).
    Misurato (ventitreesima misura): l'era 4 crolla nel 16-17 % invece
    dell'87 %, si buttano 7 Costruzione invece di 11-12, il kingmaker scende
    a 6/6/10 %. Aperto: piccoli scarti fra le strategie (ritaratura dei bot),
    i tre 2x2 che non crollano mai, il Denaro che avanza ancora, cinque carte
    ancora ferme.

127. **I bot ritarati.** Il designer: "ritara i bot". Pesi del bot per
    tavolo (`SPINTE_V2_PER_GIOCATORI`): a due Lampo 2,0 e Obiettivi 0,6, a
    tre Obiettivi 0,7, a quattro Lampo 2,8 e Obiettivi 0,6. Il peso della
    Obiettivi va giu' per indebolirla, al contrario del Lampo. Misurato
    (ventiquattresima misura): scarto massimo fra le strategie 10/10/9 punti,
    tre strategie a un punto dal bordo. Le regole non cambiano.

128. **I potenziamenti stampati.** Il designer ha caricato
    `materiali/Potenziamenti_Completi_A4.pdf`, i 50 potenziamenti a icone.
    `tools/estrai_grafica.py` (`estrai_potenziamenti_v2`) li ritaglia in
    `assets/carte/potenziamenti_v2/` e li confronta coi dati: nomi, costi e
    numeri degli effetti senza condizione coincidono tutti. Da decidere:
    - **Classe diversa** su cinque carte: Cupola (stampata Religione, dati
      Ingegneria), Giardino pensile (Cultura / Civico), Targa storica
      (Cultura / Civico), Ascensore panoramico (Civico / Ingegneria),
      Memoriale (Militare / Religione).
    - **Il bonus di classe non e' stampato** su dodici carte: Idolo, Totem,
      Mosaico, Reliquia, Stemma di famiglia, Terrazza panoramica, Pala
      d'altare, Murale ("+1 PV in piu' se l'edificio e' ..."), Mura di cinta,
      Torre di guardia, Cannoniere ("+1 Resistenza in piu' se Militare"),
      Portico ("+1 Denaro in piu' se Commercio"). O si aggiunge
      un'icona della classe sulla carta, o si tolgono dai dati.
    - **Cemento armato** e' stampato con lo scudo "+2" (la versione di prima):
      nei dati, dal registro 126, e' "Subito: +2 PV".

129. **I potenziamenti di classe.** Il designer, sul confronto del punto
    128: "valgono i dati, togli i bonus di classe, i potenziamenti si possono
    mettere solo su edifici della stessa classe, cemento armato +2". Nel file
    v2: via i dodici bonus "+1 se l'edificio e' ..." (resta la condizione del
    fiume), costante `potenziamento_stessa_classe` (controllata in
    `ActionRules.quote_upgrade`, conta anche la classe acquisita), Cemento
    armato "+2 Resistenza" come stampato. Le cinque classi stampate sbagliate
    (Cupola, Giardino pensile, Targa storica, Ascensore panoramico,
    Memoriale) vanno nel prompt per ChatGPT. Misura: venticinquesima: tutte
    le strategie nell'errore a 2, 3 e 4 (scarto massimo 9 / 9 / 7), un quarto
    di potenziamenti in meno, i potenziamenti "struttura" tornano vivi.
130. **Le tessere scavo.** Il designer: quando un edificio va in rovina si
    toglie la carta e il giocatore pesca una tessera scavo coperta per ogni
    casella che occupava; si rivelano a fine partita quando ci si costruisce
    sopra un edificio dell'era 5; alcune hanno uno scheletro o un
    potenziamento. "Il valore di scavo va a chi era proprietario
    dell'edificio ... ogni giocatore ha un mazzetto rovine del suo colore."
    Nel motore (`TessereScavo`, costante `tessere_scavo`), oggi solo nella
    variante `tessere_scavo`; regole in `docs/proposte/tessere-scavo.md`.
    Ventiseiesima misura: stessi punti dello Scavo stampato, un po' piu'
    dispersi, strategie ferme, il vincitore cambia nelle partite chiuse
    (7 / 12 / 12 %). Da decidere: il mazzetto (20 e' largo, se ne pescano
    meno di 4), il premio di chi costruisce sopra, le icone sulle coperte.
131. **Le carte restituite e i potenziamenti come token.** Il designer: "i
    Potenziamenti diventano Token che vengono posizionati sull'edificio e
    quando questo va in rovina vengono riscattati dal giocatore
    proprietario, inoltre non ci sono piu' le carte Edificio [...] viene
    restituito al proprietario"; poi "(c), restituito al proprietario,
    togli ristrutturare, rovine non contano". Nel motore
    (`TessereScavo.fuori`, `Effects.chiede_mappa`, costante
    `tessere_scavo.carte_restituite`): per le regole di mappa la rovina non
    c'e' piu'; le regole sulle tue rovine leggono la carta restituita; gli
    effetti finali della carta crollata non scattano; niente ristrutturare;
    il token riscattato perde l'effetto sull'edificio. Misura: la
    Continuita' di colonna crollava da 16 a 3 PV (registro 132).
132. **La Continuita' come collezione e i flussi di PV.** Il designer
    sceglie la collezione: per ogni classe contano i tuoi edifici in piedi
    piu' le carte restituite, a soglie (3 → 3 PV, 5 → 5, 7 → 8, 9 → 12). E
    "vorrei che i PV arrivino tutti piu' o meno uguali": Lampo, Rendita,
    Scavo e Continuita' i quattro flussi principali. Il Lampo delle ere 4-5
    scende da 2 a 1, la Rendita 1 sale a 2 (con +1 su tutte la Rendita
    arrivava a 24 PV). Prova a 3 giocatori: Lampo 15, Rendita 20, Scavo
    17, Continuita' 19 (tabella poi abbassata a 3/5/8/12, stimata 16).
133. **Il mazzetto rovine, l'arte ritrovata, un token per casella.** Il
    designer: 12 tessere per giocatore (0: semplice, scheletro, arte; 1: tre
    semplici e uno scheletro; 2: due semplici e un'arte; 3: due semplici);
    "(a)": solo i token arte riscattati valgono, col loro Scavo stampato
    (5 l'era 1 ... 1 l'era 5), e solo se un'icona arte scoperta li
    ritrova; anche i Personaggi hanno uno Scavo stampato per lo scheletro;
    massimo un potenziamento per casella (il Colosseo 4); le carte del
    mercato hanno la misura della mappa. Senza ristrutturare, il
    Restauratore diventa "almeno 2 tue rovine riportate alla luce dall'era
    Moderna" e le Secolarizzazioni tengono solo "Religione −2 res". Sul
    mazzetto: nelle misure un giocatore pesca in media 3,5-3,8 tessere, 9
    o meno nel 99% delle partite, al massimo 12.
134. **Il mazzetto a 16 e lo spianato.** Il designer: "Rifai le tessere
    scavo con 16 tessere": 0 ×4 (due semplici, scheletro, arte), 1 ×5 (tre
    semplici, scheletro, arte), 2 ×4 (tre semplici, scheletro), 3 ×3 (due
    semplici, arte); media 1,375, tre scheletri e tre arte. I Personaggi
    presi restano ai giocatori, quelli non scelti si scartano. Lo spianato:
    "restituisce carta e lascia un terrapieno oppure si mette la tessera
    scavo di chi appartiene. Da valutare": di regola resta senza tessere;
    la variante `spianato_tessere` gli fa lasciare le tessere del
    proprietario (senza premio). Da misurare.
135. **Il mazzetto a 20, gli scheletri per era, piu' arte.** Il designer: 4
    scheletri, uno per era, con una linea che indica lo strato e l'era, cosi'
    si sa quale Personaggio usare; piu' arte, tante quante i token arte che
    un giocatore riscatta; 20 tessere per giocatore piu' la tessera
    terrapiano; alcune con scheletro e arte. Misura (120 partite per
    tavolo): un giocatore riscatta 0,66 / 0,64 / 0,49 token arte a 2 / 3 / 4
    (per lo piu' delle ere 2 e 3, al massimo 3-4), e pesca in media 4
    tessere. Mazzetto: 0 ×5 (due semplici, scheletro era 2, arte,
    scheletro era 1 + arte), 1 ×6 (quattro semplici, scheletro era 3,
    arte), 2 ×5 (quattro semplici, scheletro era 4 + arte), 3 ×4; media 1,4.
    Lo scheletro con l'era vale lo Scavo del Personaggio preso in
    quell'era (`TessereScavo.scavo_personaggio_di_era`).
136. **I bot ritarati per le rovine a tessere.** Con le regole dei registri
    130-135 la Lampo vinceva il 22 / 10 % a tre e quattro e la Rendita il
    20 % a ogni tavolo. La Rendita del bot scartava le carte senza Rendita
    (`rendita_zero`), l'80 % del mazzo: a zero torna in media. Il premio di
    scavo del bot rafforzava la Scavo: a zero a tre e quattro. La Lampo con
    meno peso (1,4 a tre, 1,0 a quattro). Ventisettesima misura. Le regole
    non cambiano: sono pesi del bot.
137. **Via le pedine scheletro.** Il designer, provando il gioco: "ancora ci
    sono le pedine scheletro che non servono piu'". Con gli scheletri sulle
    tessere scavo (registro 135) il lavoratore che potenzia non lascia piu'
    il gettone sotto l'edificio: `scheletro_potenziamento` spento nel file
    v2 (il meccanismo resta, provato nei test). Tolti circa 8-9 PV a
    giocatore di Scheletri; misura in corso. Insieme: la Lampo dei bot a tre
    giocatori pesa 1,2 (31-37 % a ogni strategia su 300 partite), e
    tools/estrai_grafica.py lanciato da riga di comando si fermava prima di
    estrarre le tessere rovina (la funzione stava dopo il `__main__`).
138. **I Personaggi e l'arte, carta per carta.** Il designer: "devi calcolare i
    punti per le carte personaggio e gli effetti per ciascuno... anche i
    potenziamenti arte dovrebbero avere dei PV". Misura senza pedine
    scheletro (750 partite per tavolo), vittorie di chi prende la carta:
    forti Architetto 60/52/42, Archeologo 63/47/39, Costruttore di zattere
    59/47/36, Cavaliere 61/46/34; deboli Console 14/13, Vescovo 14,
    Sacerdotessa 18/14, Cardinale 16, Sciamano 17, Veterano 15 a quattro, i
    due Mercanti 20, Banchiere 19-23, Cronista 22-24, Soprintendente 22-26.
    Approvato: lo Scavo stampato carta per carta (2-6, nessuno all'era 5),
    i testi rotti dalle rovine riscritti (Urbanista per ere diverse in
    piedi, Cronista 2+ ere in piedi, Console +1 PV, Mercante max 3), i
    deboli rinforzati, i forti limati (Architetto il primo edificio grande,
    Archeologo max 4, Cavaliere +3). L'arte vale "Subito" + 2 e l'icona la
    ritrova anche sugli edifici in piedi (valeva 0,3 PV a partita).
139. **La vista dopo la prova del designer.** "Edifici e terrapieni non hanno
    la stessa dimensione": le tessere scavo e il terrapieno dello spianato
    avevano un margine del 6% per lato, ora 0,4 mm. "La scritta Girata e'
    bruttissima": la tessera dell'era usata si capovolge (animazione) e
    mostra la faccia in bianco e nero; la sua produzione in piu' resta
    attiva, si consuma solo l'effetto. "Elimina le carte davanti al
    giocatore": restano i Personaggi scelti, i token riscattati, Eredita' e
    Monumenti, e il mazzetto rovine; le classi per la Continuita' stanno
    nella barra in alto. "Le tessere volano dal mazzetto al posto
    dell'edificio, i potenziamenti davanti al giocatore": fatto.

140. **Menu d'inizio e riepilogo finale leggibili.** Il designer: "Sono
    troppo piccoli e non si legge nulla". Due cose: il progetto ora scala
    tutta l'interfaccia 2D con la finestra (`stretch canvas_items`, aspetto
    `expand`), cosi' su un iPad ad alta densita' non resta tutto in
    miniatura; e i due pannelli passano sotto una "lente" che li ingrandisce
    fino a riempire circa il 90% dello schermo (fattore fra 1 e 2,6), con i
    tasti cliccabili dove si vedono. Il menu e' piu' largo (le descrizioni
    uscivano dal bordo) e nel riepilogo la strategia del bot sta nella riga
    sotto il nome, che altrimenti veniva tagliata.
141. **Il posto del giocatore in due colonne; la Vetusta' sparita dal
    riquadro.** Il designer: "i personaggi impilati uno sopra l'altro
    leggermente sfasati in modo da lasciare leggere il Nome, i potenziamenti
    sotto i personaggi uno sotto l'altro e le milestone acquisite sotto
    l'obiettivo segreto". A sinistra il mazzetto rovine, sotto l'Eredita' e
    sotto ancora i Monumenti; a destra i Personaggi a ventaglio (scoperti
    nome ed era, 20 mm) e sotto i token riscattati. Una terza colonna non ci
    stava: a tre giocatori l'Eredita' restava larga due dita. "Leggo ancora
    la vetusta'": era il riquadro dell'edificio, che la scriveva sempre (a
    zero); nella v2 scrive la resistenza e quanti cubetti neri ha. Domande
    aperte al designer: i cubetti neri (resistenza guadagnata da
    potenziamenti Struttura, Personaggi come Sciamano, Mastro costruttore e
    Ingegnere militare, edifici militari, tessere dell'era) e la Prosperita'
    Urbana, che nel regolamento v2 c'e' ancora.
142. **Via la Prosperita' Urbana; i cubetti neri solo senza gettone.** Il
    designer: "cubetti solo senza token, togli la Prosperita' se il denaro e'
    abbondante e avanza a ogni era". Ventottesima misura: senza il Centro a
    fine era avanzano comunque 3-6 Denaro a testa dall'era 2, a zero raramente,
    e i PV non cambiano; la Prosperita' esce dal file v2 (manopola
    `prosperity.attiva`, la v1.5 non cambia) e dal regolamento, con i suoi
    cartellini. I cubetti neri non ripetono piu' la resistenza dei
    potenziamenti Struttura, che si legge sul gettone: restano per quella
    dei Personaggi, degli edifici militari e delle tessere dell'era.
144. **Il riepilogo girato e diviso per fonte; i blocchi piu' bassi.** Il
    designer: "i blocchi degli edifici sono molto alti", "puoi dividere i
    punteggi finali per capire da dove vengono? e Premi da dove arrivano?",
    "nel riepilogo finale i giocatori in alto, ogni riga i punti per
    categoria, sotto il totale". Il blocco della v2 scende da 15 a 9 mm. I
    PV ora portano anche la loro fonte (`vp_dettaglio`, solo per il
    riepilogo: canali e misure non cambiano, la v1.5 resta identica): il
    Lampo si divide in edifici costruiti e tessere dell'era; i PV prodotti
    in produzione degli edifici, potenziamenti e Personaggi; lo Scavo in
    premi di scavo, tessere scavo, scheletri ritrovati e arte ritrovata; i
    Finali carta per carta. I "premi" sono il premio di scavo: chi costruisce
    sopra un edificio e lo sotterra incassa subito lo Scavo di quello che
    seppellisce, secondo il livello e l'era (come il Lampo, sul momento).
    Il riepilogo ha i giocatori in colonna, le voci in riga con le sottovoci
    sotto, il totale in fondo con l'eredita' segreta e gli edifici in piedi.
143. **Il Lampo e' un flusso di tutti.** Il designer: "misura la Lampo 2
    sulle carte era 4". Ventinovesima misura: il Lampo sale di 3 PV a testa
    per tutti, e la strategia Lampo resta dov'era (24 -> 25% a tre, 13 -> 14%
    a quattro): il bot Lampo prende gia' piu' Lampo degli altri, e perde
    perche' inseguendolo lascia 4-6 PV altrove. Il designer: "accetta il
    Lampo come flusso di tutti". Il file v2 non cambia; la strategia Lampo
    dei bot resta com'e', non si bilancia piu'.
146. **Attivare una colonna e basta; la cronaca del turno.** Il designer:
    "alcune volte sono costretto a passare perche' non ci sono mosse valide
    [...] non posso mettere semplicemente un lavoratore sulla colonna e
    incassare". La regola c'era; mancava il modo, sull'iPad: con una carta
    scelta e nessun posto acceso ogni tocco sulla colonna diceva "li' non ci
    va", e senza Esc restava solo Passa. Ora in basso c'e' una fila "Attiva e
    incassa" (un tasto per colonna libera), il tasto "Annulla la scelta", e
    "Passa" dopo l'attivazione si chiama "Fine turno". "Nella barra di stato
    ci deve essere scritto cosa sto facendo e cosa ho fatto, quali effetti
    degli edifici sono stati attivati e quante risorse ho guadagnato": sotto
    la barra la cronaca (scripts/view/cronaca.gd) racconta ogni mossa, anche
    dei bot: l'azione, gli edifici della colonna che hanno prodotto e per
    chi, le risorse guadagnate da ciascuno, gli effetti e i crolli.
147. **Lo spianato lascia le tessere; il terrapieno solo nei buchi.** Il
    designer, dopo un Acquedotto (tre colonne) spianato da un edificio largo
    una: "i due slot rimasti liberi sono diventati un terrapieno. E' un
    errore clamoroso, dovevano diventare rovine. Il Terrapieno e' solo ed
    esclusivamente quando si crea un buco". L'errore veniva dal registro 134
    (lo spianato senza tessere, "da valutare") e dal 139 (al suo posto il
    terrapieno, per non lasciare sospeso chi sta sopra). Ora lo spianato e'
    una rovina come le altre: la carta torna al proprietario e al suo posto
    vanno le sue tessere coperte, una per casella, senza premio di scavo per
    chi spiana. Misura in corso insieme al premio (registro 145).
149. **L'evento finale.** Il designer: "a cosa serve la resistenza negli
    edifici di era 5? O si mette un evento anche alla fine oppure va
    eliminato. Procedi con evento finale". Nel file v2 l'era Moderna ha un
    evento, *Il giudizio del tempo* (costante `evento_finale`, la v1.5 non
    cambia): forza 4, nessun effetto speciale, rivelato a inizio era e
    risolto prima del conto finale. Quel che crolla non paga il censimento
    finale e diventa rovina con le sue tessere. La forza e' una scelta
    provvisoria (come il Medioevo); i sei eventi moderni veri, se il
    designer li vuole come le altre ere, restano da disegnare. Misura in
    corso.
150. **Le gilde dell'era Moderna.** Il designer: "gli edifici dell'era 5
    dovrebbero funzionare come una specie di gilda di 7 Wonders, che oltre a
    riscoprire le rovine danno PV in base ad alcune condizioni". Otto dei
    quattordici lo facevano gia' (Museo, Biblioteca, Grattacielo, Universita',
    Fondazione d'arte, Caffe' letterario, Monumento ai caduti, Parco
    archeologico). Le quattro senza condizione la prendono: Condominio +1 PV
    per ogni tuo Civico in piedi (max 4); Officina +1 per ogni altro tuo
    Ingegneria, in piedi o sotterrato (max 4); Ponte in acciaio +2 per ogni
    tua rovina riportata alla luce nelle sue colonne (nuovo filtro
    `scavata`); Stazione +1 per ogni edificio in piedi nelle sue colonne, di
    chiunque (max 5). Le due case restano case. Misura insieme all'evento
    finale (registro 149).
151. **Le regole semplici del costruire sopra.** Il designer, davanti alla
    tabella dei casi: "converrebbe sempre costruire su rovina propria [...]
    Troppe regole complesse. Io la semplificherei al massimo". Terreno
    libero: si costruisce. Proprio edificio integro: si spiana, sconto in
    Costruzione, nessuna rovina, al suo posto il terrapieno (supera il
    registro 147). Integro avversario: non si puo'. Rovine proprie o altrui:
    bonus scavo, 1 PV subito per ogni tessera che finisce sotto il nuovo
    edificio (2 da misurare, `--variante scavo_due`), senza livello ne'
    dimezzamento nell'era 5; dove sotto non c'e' niente, terrapieno (0 PV);
    niente piu' sconto macerie. Nell'era 5 un edificio sopra delle rovine
    gira le tessere della pila sotto di se'; a fine partita contano solo le
    tessere girate (numero scritto, scheletri, arte), quelle mai girate
    valgono 0. Scelte del designer: si girano solo le tessere sotto
    l'edificio dell'era 5, e le non girate valgono niente. Misura insieme a
    evento finale e gilde.
153. **La v3: il metro e la scheda dell'era 1.** Il designer (1 ottobre): "Troppe
    risorse vanno sprecate [...] Le risorse nascono e muoiono nell'era"; i
    Personaggi si prendono con un draft a passaggio (4 a testa, se ne tiene uno
    e si passa a destra) e sono gli unici lavoratori, con produzione e azione;
    ogni edificio ha produzione e azione; "si puo' lavorare per ere quasi a
    compartimenti", con lo scopo di "piu' strategie [...] equilibrate fra di
    loro e che nessuna sia palesemente dominante" (Lampo, Rendita, Scavo,
    ritrovamenti, generi). Si parte dall'era 1, non dalla 2: si simula dalla
    strada vuota, e quel che si costruisce li' e' il materiale dello Scavo
    dopo. Due proposte da leggere e correggere: `docs/proposte/v3-metro.md`
    (il cambio in PV, il budget di un'era, il vocabolario di dieci azioni, la
    sagoma delle carte) e `docs/proposte/v3-era-1.md` (16 Personaggi, 15
    edifici con l'azione, le costanti della prova). Il limite noto: nell'era 1
    Scavo e scheletri non si vedono, si misurano con la coppia 1-2.
154. **Le regole della prova (provvisorie, da confermare).** Nel file generato
    `data/proposte/cards-v3-era1.json` (`tools/genera_cards_v3.py`): draft a
    passaggio con direzione **alternata** (ere 1, 3, 5 a destra; 2 e 4 a
    sinistra), **senza Dinastia**, azione degli edifici **al proprietario** a
    ogni attivazione della colonna di chiunque, **nessun tetto** alle risorse
    dentro l'era, si parte da **zero** risorse, le risorse muoiono a fine
    era (nell'era 5 restano: spareggio). Le scelte che un'azione richiede
    (quale risorsa cambiare, quale edificio proteggere) le fanno i bot con
    una regola fissa scritta in `scripts/rules/personaggi_v3.gd`. Dolmen e
    Menhir a Rendita 1 (da misurare contro il 2 di oggi). La v1.5 e la v2
    non cambiano: tutto e' acceso dalla costante `turno_v3`.
155. **La prima misura dell'era 1 della v3 (trentunesima misura).** Trecento
    ere 1 giocate da sole (`--fino_era 1`), 3 giocatori: si producono 14
    risorse a testa (budget del metro 10-12: terreno 4, tessera 3, Personaggi
    4, edifici 1,6, azioni 1,1), se ne spendono 5,4 e ne **muoiono 8,7**
    (budget 1-2); quattro costruzioni e zero potenziamenti a testa. La Lampo
    vince il 73% delle ere giocate da sole (atteso: e' l'unico canale che paga
    nell'era), Lampo 5,6 PV e Rendita 1,2 di censimento, tutte sotto il metro.
    Il Guerriero e' preso quasi sempre per primo (giro 1,11), il Custode delle
    ossa per ultimo (3,77). Il pozzo manca ed e' la prima cosa da decidere:
    potenziamenti nella colonna adiacente (controprova nella misura), meno
    produzione dal tabellone (il terreno di base potrebbe non produrre piu'),
    piu' azioni di cambio e di PV. La controprova con i potenziamenti nella
    colonna adiacente non sposta il morto (8,6): si potenzia al posto di
    costruire, con quattro azioni si spende lo stesso (circa 6 su 14). Il
    bot non sa ancora che le risorse muoiono
    e non potenzia nell'era 1: una parte del morto e' sua. **Da decidere con
    il designer** prima di toccare le carte.
156. **Mancanza, non surplus: le leve del pozzo.** Il designer, letta la prima
    misura: "si puo' ricalibrare tutto, anche gli edifici potrebbero costare
    di piu'"; la catena dei Castelli di Borgogna ("quando si comprano edifici
    ti permette di prenderne o comprarne altri"); "trova modi per spendere piu'
    risorse o far fare piu' azioni o acquisti oltre i 4 consentiti [...] Ci
    deve essere una mancanza di risorse non un surplus" (Dune Imperium). Tre
    leve misurate da sole e insieme (trentunesima misura, "Le leve del
    pozzo"): costi +1, terreno che non produce, l'**acquisto extra** (costante
    `acquisto_extra`: dopo l'azione del turno si compra ancora un
    potenziamento o una casa della riserva, pagando, senza lavoratore). Il
    bot usava l'extra per spianare i propri Dolmen con una casa (Circolo
    spianato nell'81% delle partite): serve lo spianare caro del registro
    152. La **catena** (terreno a zero, acquisto extra, spianare caro) e' la
    prima in cui si spende piu' di quanto muore (7,0 contro 3,1); con i
    **costi misti** (+1 della seconda risorsa della classe) il morto scende a
    2,3 su tutte e tre le risorse e la Lampo al 55%, ma l'era si fa povera
    (2,8 costruzioni a testa). Proposta: la catena come base dell'era 1 e una
    via di mezzo sui costi. **Da decidere con il designer.**
157. **L'acquisto extra solo dalle carte; catena e costi misti nel file base;
    i bot sanno che le risorse muoiono; una casa sempre comprabile.** Il
    designer, letta la misura delle leve: "L'acquisto extra non si fa sempre,
    ci vuole un effetto di una carta o personaggio o edificio o tessera
    terreno; catena si' e costi misti; poi si' i bot devono sapere che le
    risorse si perdono; inoltre i giocatori devono poter comprare sempre
    almeno un edificio, magari le case di fango o qualcosa che costa poco".
    Nel file base dell'era 1: terreno di base a zero (resta la tessera),
    spianare caro, +1 della seconda risorsa della classe sugli edifici del
    mazzo (le case come sono), i Ripari a costo 1 pagabile in Costruzione o
    Denaro. L'acquisto extra e' l'azione ⊕ del vocabolario: la danno il
    Capotribu' e il Mercante di ossidiana (al posto di 🛡 e ⇄), le Capanne
    e la Cava a chi le possiede quando le attiva (al posto di ⇄), e la
    tessera Sentiero dei pastori (al posto di +1 Denaro). Il bot sconta le
    risorse che non potra' spendere nei piazzamenti rimasti (circa 2,5
    l'uno): all'ultimo lavoratore spendere non costa niente e tenere non
    vale niente (`StrategyBot._fattore_morte`). Controprove: `extra_sempre`,
    `senza_extra`, `costi_vecchi`. Le otto varianti del primo giro sono
    state tolte: le rigenera il generatore al commit 2db6223.
158. **La trentaduesima misura: la mancanza c'e', l'era e' di case.** Con il
    file base del registro 157 e il bot che sa che le risorse muoiono: si
    produce 8,7 a testa, si spende 7,2, muore 1,5 (mezza risorsa per tipo,
    dentro il budget). Ma si costruiscono 5 case a partita su 11 edifici
    (Ripari in tutte le partite, Dolmen 0,5, Grotte 0,25, Tumulo 0,1): le
    case costano una risorsa sola, le carte del mazzo due. I potenziamenti
    spariscono (0,03 a testa) e l'acquisto extra si apre 0,74 volte e si usa
    0,25: quando si apre non c'e' piu' niente in mano. Lampo 61%. Proposte
    da misurare una per volta: le case con la seconda risorsa (Ripari a 1 ◈
    come salvataggio) o il Lampo delle case a 1; l'extra con lo sconto (o il
    potenziamento nell'extra gratis); potenziamenti a 0 o in Costruzione
    nell'era 1; il bot che valuta l'azione ⊕ per quel che rende. **Da
    decidere con il designer.**
159. **Il tuning delle risorse e i potenziamenti.** Il designer: "E' questo
    quello che devi fare, un tuning delle risorse, se Idee e Denaro sono poco
    bisogna alzarle, poi i potenziamenti devono essere comprati, anche questo
    e' un difetto da riparare". Perche' prima si comprava tutto: si
    producevano 14 risorse, di cui 8 Costruzione, e le carte costavano 1-2
    Costruzione; con i costi misti le carte del mazzo chiedono Denaro o Idee,
    che si producevano 1,5 e 1,7 a testa, e le case restavano l'unica cosa
    pagabile. Nel file base: le quattro tessere dell'era 1 senza produzione
    danno Denaro (Sentiero, Terra di nessuno) o Idee (Radura, Luogo sacro);
    Guardiano del fuoco 💡, Anziana 🪙, Barattatore 🪙💡 (fra i 16, in unita':
    5 Costruzione, 6 Denaro, 7 Idee; erano 10/4/5);
    `potenzia_adiacente` acceso. Nel bot le Idee contano nella domanda del
    mercato (solo nella v3) e l'azione ⊕ vale 0,4. Trentatreesima misura:
    Denaro 2,6 e Idee 3,0 prodotti, potenziamenti 0,46 a testa, case 3,6 a
    partita, morto 2,2, Lampo al 37% con le strategie fra 19 e 41. Restano:
    l'acquisto extra che si usa un quarto delle volte (sconto o potenziamenti
    piu' economici), il Guerriero sempre primo, le Trappole da pesca mai
    costruite, la Rendita sul bordo basso. Controprova `case_seconda` (le
    case con +1 Denaro tranne i Ripari): un po' meglio su tutto, Rendita al 19.
160. **Il potenziamento insieme alla costruzione.** Il designer: "E se i
    potenziamenti non sono un'azione a parte ma possono essere presi insieme
    agli edifici se il giocatore ha risorse sufficienti? Se non bastano
    rimetterei la produzione base dei terreni". Costante
    `potenziamento_con_costruzione` nel file base: dopo ogni costruzione si
    puo' comprare un potenziamento, pagandolo, senza consumare il lavoratore
    (l'acquisto extra limitato ai potenziamenti, aperto da ogni costruzione;
    con una carta ⊕ si compra anche una casa). Trentaquattresima misura: i
    potenziamenti da 0,46 a 0,71 a testa, morto 2,0, il resto fermo;
    l'occasione si apre 3,6 volte e si usa una su sette, perche' dopo
    l'edificio resta di rado la risorsa giusta. Con il terreno che produce
    (variante `terreno_produce`) si arriva a 1,07 potenziamenti ma si torna
    al surplus: morto 3,9, Lampo 51%, spianati di nuovo. Da misurare la via
    di mezzo: terreno a meta' produzione, o potenziamento scontato di 1
    nell'extra. **Da decidere con il designer.**
161. **I costi rimodulati, le risorse che si tengono, gli sconti, lo spianare
    solo del passato.** Il designer: "dovresti rimodulare i costi tu in modo
    da rendere risorse prodotte e spese nella giusta proporzione, le risorse
    possono essere tenute per poter comprare meglio con il lavoratore
    successivo. Inoltre alcuni effetti potrebbero scontare dei tipi di
    potenziamenti o edifici, possiamo poi mettere la regola che non si
    possono spianare edifici della stessa era, ma solo ere precedenti". Nel
    file base: costante `spiana_solo_ere_precedenti`; il Guardiano del fuoco
    sconta l'edificio Religione del turno e il Custode delle ossa il
    potenziamento del turno (azione `sconto` con `se` "classe:religione" o
    "potenziamento"); i costi dell'era 1 nella tabella `COSTI_E1` del
    generatore con la regola trovata misurando: **l'edificio chiede la
    risorsa che i suoi potenziamenti non chiedono** (Civico e Commercio
    Costruzione e Idea, Religione e Cultura Costruzione e Denaro, Focolare e
    Trappole 1 Costruzione), Radura e Anziana tornano a Costruzione. Nel bot
    `_valore_attesa`: si passa e si tiene se una carta oggi non pagabile ma
    pagabile al prossimo incasso vale di piu' (sconto 0,4, margine 1).
    Trentacinquesima misura, tre giri: prodotto 10,1, speso 7,8, morto 2,3
    (0,7/0,8/0,9), 3,6 costruzioni, 0,77 potenziamenti, 2,2 case a partita,
    zero spianati. Il bot che aspetta passa 0,5 turni a testa e nell'era 1 da
    sola regala vittorie alla Lampo (54%): da rileggere sulla coppia 1-2.
162. **La coppia di ere 1-2.** Il designer: "Vai pure". L'era 2 scritta nello
    schema dell'era 1 (`docs/proposte/v3-era-2.md`): 16 Personaggi (cinque
    della v2 riscritti, undici nuovi), 15 edifici con azione, costi a due
    risorse con la regola del registro 161 e un gradino in piu' solo alle
    carte grandi, Rendita 2 solo dove si paga 4 o piu', Cambiavalute a
    Denaro, Via consolare, Cantiere e Necropoli senza produzione, i Tuguri a
    costo flessibile. I Personaggi della v3 hanno uno **Scavo da scheletro**
    (registro 135), piu' alto per chi il draft lascia per ultimo. Nel
    rapporto le fotografie di fine era (`snap_e<N>_*`, `pv_e<N>*`), e
    `tools/misura_era.py --era N` misura un'era come differenza.
    Trentaseiesima misura, tre giri sull'era 2: prodotto 12,0, speso 8,5,
    morto 3,5 (0,9/1,3/1,4), 3,3 costruzioni, 1,07 potenziamenti, 4,1 rovine
    dell'era 1 coperte a partita; a fine era 2 le sei strategie fra il 27 e
    il 41%. Restano: il morto dell'era 2 sopra il budget (Denaro e Idee),
    Sacello, Torre di vedetta e Anfiteatro quasi mai costruiti, il ⊕ sempre
    ultimo nel draft. **Prossimo passo**: le ere 3-5 nello stesso schema, per
    vedere Scavo, scheletri e riscoperta sulla partita intera.
163. **Le ere 3-5 e la partita intera.** Il designer: "Procedi". Le tre ere
    scritte con uno stampo uguale per i 16 Personaggi (le stesse sedici
    azioni, produzione 9/4/4, i cinque della v2 di ogni era al posto del loro
    ruolo, nomi segnaposto) e gli edifici con la regola dei costi, Rendita 2
    solo dove si paga 4 o piu', le case piu' piccole a 1 flessibile, cinque
    tessere su sette che producono (`docs/proposte/v3-ere-3-5.md`). Non
    servono piu' riempitivi: le cinque ere hanno i loro 16. Trentasettesima
    misura, la prima partita intera della v3: 74,7 PV a testa (v2: 69,5),
    Lampo 17,4, Continuita' 15,8, Rendita 11,7, Scavo 11,6 (v2: 7,7), PV
    prodotti 10,5; vittorie Bilanciata 39, Rendita 38, Obiettivi 37,
    Continuita' 35, Scavo 27, Lampo 23. Le ere 1-2 tengono il metro, le ere
    3-5 producono 13-14,5 e ne lasciano morire 5,6-6,3; le case delle ere 4-5
    (costi in Denaro e Idee) dominano; nell'era 5 il mazzo "solo sopra" non
    si costruisce e quel che sta a terra crolla al Giudizio del tempo.
    **Prossimo passo**: il tuning delle ere 3-5 come per l'era 2, poi
    resistenza dell'era 3 e carte dell'era 5.
164. **Il tuning delle ere 3-5.** Il designer: "Vai". Due giri sulla partita
    intera (trentottesima misura). Il primo (tessere a tre su sette,
    Personaggi 11/3/3, case in Costruzione, +1 resistenza alle carte fragili
    delle ere 3 e 5) non ha mosso il morto: il Denaro veniva per 7 dalle
    azioni degli edifici e per 4,4 dalla produzione della v2 rimasta sulle
    carte, che si sommava all'azione. Il secondo: produzione della v2 a zero
    dall'era 2 in su (l'azione e' la produzione), sette azioni "+1 Denaro"
    cambiate (Terme, Banco ⇄; Borgo, Condominio, Villa ★; Ospedale 🛡;
    Stazione ⚒), le case delle ere 4-5 a 2 e 3 Costruzione. Le ere 3-5
    scendono da 14 prodotte e 6 morte a 11 e 3,5-4,0; la partita intera
    72,7 PV a testa, vittorie fra 30 e 41 tranne la Lampo al 23. Restano: il
    morto delle ere 3-5 sopra il budget (le azioni degli edifici delle ere
    passate), le carte mai costruite (Conceria, Castello, Arsenale,
    Fortezza, Stazione, Grattacielo, Ponte in acciaio), le case piccole a 2
    a partita, la Lampo da ritarare nel bot. **Da decidere con il designer**
    la via per il morto: azioni "risorsa" solo per chi attiva, o costi in
    Denaro e Idee sulle carte delle ere 3-5.
165. **Costi delle ere 3-4, le carte "solo sopra", la Lampo nel bot.** Il
    designer: "Le carte ere 3-4 vanno rimodulate per costare un po' di piu'.
    Le grandi 'solo sopra' che vuol dire? Prima si trovava il modo di
    costruire perche' ora no? Le case piccole le teniamo cosi', per ora vanno
    bene. Ritara bot per strategia lampo." Fatto (trentanovesima misura): le
    carte da due risorse delle ere 3 e 4 ne prendono una terza (Denaro o
    Idee); il morto non si muove (3,4) e la spesa passa dal mazzo alle case
    medie. Le "solo sopra" sono le carte della v2 che non vanno a terra
    (Anfiteatro, Castello, Fortezza 2x2; Grattacielo e Duomo al livello 2;
    Piazza, Museo, Stazione, Universita' al livello 1): nella v2 un 2x2 si
    poggiava spianando due propri edifici dell'era stessa con lo sconto, nella
    v3 spianare costa e non si spiana la stessa era, quindi servono due
    colonne adiacenti con rovine vecchie e capita di rado. **Da decidere**:
    carte rare cosi' come sono, o riscritte a una colonna / "a terra oppure
    sopra". Il bot: tabella `SPINTE_V3` (lampo 0,8, lampo_potenzia 1,5): la
    Lampo vince il 30% con 69 PV (era 23% con 66); la piu' debole ora e' la
    Scavo (25%).
166. **"A terra oppure sopra", e da dove vengono le Idee che muoiono.** Il
    designer: "A terra oppure sopra, vai con la seconda" (la seconda via del
    registro 165: il morto delle ere 2-5). Le cinque carte grandi (Anfiteatro,
    Castello, Fortezza, Grattacielo, Stazione) prendono il campo
    `a_terra_o_sopra`: a terra con le regole di tutti, sopra con quelle della
    v2 (e sopra di loro si costruisce ancora solo quando sono in rovina).
    Duomo, Piazza, Museo e Universita' (una colonna, livello 1-2) restano come
    sono. Per il morto, prima la diagnosi: il rapporto ora distingue le
    entrate per fonte era per era (`snap_e<N>_in_<fonte>_<risorsa>`, e le
    azioni degli edifici in piedi sono `in_edifici_azione_*`, distinte dal
    Personaggio). Sulla trentanovesima misura chi aveva l'Acquedotto (tre
    colonne, in piedi dall'era 2 alla 5, "+1 Idea a ogni attivazione di
    chiunque") incassava 19,8 Idee dalle azioni contro 2,6 di chi non lo
    aveva: una carta da 17 Idee a partita, e il Foro 5,4 Denaro, la Piazza
    monumentale 9 Idee. Senza le azioni degli edifici, Idee e Denaro prodotti
    (7 e 8 a partita) pareggiano quasi quel che se ne spende (6,4 e 8,4): il
    surplus e' tutto li'. Due controprove sugli stessi semi: le azioni degli
    edifici che danno Denaro o Idee scattano solo quando attivi tu
    (`--variante proprio_morte`), oppure tutte quelle che danno risorse
    (`proprio_tutte`). Risultato (quarantesima misura): il morto scende da
    2,7-3,8 a 2,0-2,5 a testa in ogni era e la spesa quasi non cala; le carte
    grandi a terra si costruiscono (Anfiteatro 0,46, Castello 0,12 a
    partita). **Deciso**: la regola semplice, "le azioni degli edifici che
    danno risorse scattano solo a ogni TUA attivazione" (PV, resistenza,
    cambio e scavo restano a ogni attivazione di chiunque), e' il file base;
    `--variante chiunque` rifa' la regola di prima. Vittorie 26-39; la piu'
    debole e' ora la Lampo (26%), da riguardare nel bot.
167. **Il Lampo vale il costo; Fondaco e Periferia in Costruzione.** Il
    designer: "Continua". Restavano il morto delle ere 4-5 (2,5) e la Lampo al
    26%. Nelle ere 4-5 tutte le carte Lampo del mazzo valevano 1 anche a costo
    3, contro il metro ("rende in Lampo il suo costo"): ora il Lampo delle
    carte Lampo del mazzo delle ere 3-5 vale almeno il costo in Costruzione
    (Osservatorio, Villa, Officina, Museo, Biblioteca... 2; Grattacielo, Ponte
    in acciaio, Stazione 3). Le case restano come sono. Il Fondaco (era 4) e la
    Periferia (era 5), uniche tessere a produrre Denaro nella loro era,
    producono Costruzione. Quarantunesima misura: +2 PV a testa per tutti, le
    carte tarde costruite il doppio, il morto delle ere 4-5 da 2,5 a 2,2 e
    2,1, le costruzioni +0,15 a era. La Lampo resta la piu' debole (25%): il
    Lampo lo prendono tutti; si cercano le spinte del bot con `--spinta`.
168. **La Lampo nel bot, e il ⊕ nel rapporto.** Il designer chiede quante
    decisioni prende un giocatore e perche' l'acquisto extra si apre 14 volte
    e si usa 2,7. Risposta: il 14 non e' il ⊕ (che scatta 2,2 volte a
    partita) ma la finestra del potenziamento insieme alla costruzione
    (registro 160), aperta dopo ognuna delle 14,7 costruzioni; il 2,7 sono i
    potenziamenti comprati li', 2,7 dei 3,9 a partita, cioe' quanto spesso
    dopo aver costruito resta qualcosa in mano (ere 1-2 quasi sempre, ere 3-5
    una volta su dieci: il potenziamento costa 2 e manca la Costruzione). Il
    rapporto distingue ora le aperture da carta ⊕ da quelle dopo la
    costruzione (`extra_aperti_carta`, `extra_usati_carta`). La Lampo
    (quarantaduesima misura): `lampo_zero` da -1 a 0 nella tabella
    `SPINTE_V3`; la penalita' sulle carte senza Lampo le faceva scartare le
    carte a Rendita. Dal 25 al 31% con 71 PV, e resta una Lampo. Vittorie fra
    29 e 38.
169. **Gli sconti sugli edifici.** Il designer: "quando si mette un lavoratore
    l'azione e' un acquisto, edificio, potenziamento o entrambi in base alle
    risorse" (e' cosi' nel codice, registro 160); "il ⊕ se serve deve stare su
    piu' Personaggi e/o edifici": il contatore nuovo dice che il ⊕ si apre
    2,1 volte a partita a giocatore e si usa 0,8 (il 39%), la finestra dopo
    la costruzione si apre 12,2 e si usa 2,0 (il 16%): il ⊕ rende il doppio
    della finestra ma resta a meta' per mancanza di risorse, quindi prima di
    moltiplicarlo va reso piu' utile (uno sconto dentro, o i potenziamenti
    delle ere 4-5 meno cari). "Mancano gli sconti, che sono essenziali". Variante
    `sconti_edifici`: sette azioni "+1 risorsa" o cambio diventano sconti
    (Trappole su fiume, Insulae Civico, Mulino e Banco Costruzione, Bottega
    potenziamento, Officina Ingegneria, Caffe' Arte), validi per l'acquisto del
    turno, quindi solo quando attiva il padrone: chiave nuova `chi: proprio`,
    perche' `se` nello sconto e' la condizione. Il Lampo +1 e la tessera che si
    rigira restano sui Personaggi. Quarantatreesima misura: niente si muove
    (sconti usati 1,45 → 1,68 a partita, morto e vittorie uguali), perche' lo
    sconto scatta solo se il padrone attiva quella colonna e compra in quel
    turno. **Il file base non cambia**; la decisione dipende dalla "scelta"
    (registro 170), dove lo sconto va a chi sta per comprare. Misurato anche
    quello (quarantacinquesima): sconti usati 1,57 → 1,92, il resto uguale.
    Per pesare, gli sconti vanno su piu' carte e senza condizione, o dentro
    il ⊕: **da decidere**.
170. **"Stile Caylus": chi attiva usa un edificio della colonna.** Il
    designer: "se quando si attiva una colonna un giocatore possa scegliere
    qualunque edificio, anche quelli non suoi, e brucia quell'effetto per il
    turno? Quanti cambierebbe in meglio o in peggio?" Poi "Vai". Costante
    `azione_edificio` = "scelta" (era gia' prevista, letta solo come
    "proprietario"): dopo tessera e Personaggio chi attiva usa UN edificio
    vivo della colonna con un'azione, di chiunque; l'edificio e' bruciato fino
    alla fine del giro di piazzamenti (`gs.bruciati`, uid -> "era:giro"); con
    uno solo non c'e' domanda, con piu' d'uno e' una `pending_choice` di tipo
    "edificio" (per i bot la risolve `StrategyBot._scelta_edificio`, provando
    ciascuno su una copia con lo stesso conto del piazzamento). Compenso al
    padrone quando lo usa un altro: `azione_edificio_compenso` = "nessuno" |
    "pv" (1 PV, canale `compenso`). Le condizioni "a ogni tua attivazione" e
    "di un avversario" non hanno piu' senso e nelle varianti `scelta` e
    `scelta_pv` cadono: ogni carta dice "Usa:". Il bot non ha pregiudizio sugli
    edifici altrui (`_produzione_colonna`). Contatori `az3_scelta_propri`,
    `az3_scelta_altrui`, `az3_scelta_nessuna`, `compensi`. A ragionamento: una
    decisione vera in piu' a turno, meno morto, interazione diretta, regole
    piu' semplici; contro, il padrone non guadagna dal suo edificio, fuga sulle
    carte forti, la Rendita perde le ★ degli altri, il bot costa il triplo.
    Quarantaquattresima misura: 16 usi a partita a giocatore, due terzi su
    edifici altrui; si spende di piu' e si passa di meno in tutte le ere,
    costruzioni 15,1 e potenziamenti 4,5 (da 14,7 e 3,9); il morto sale di
    0,2-0,5 nelle ere 1-4; PV 74,8 (da 72,7). Vittorie Obiettivi 44, Lampo 33,
    Bilanciata 34, Scavo 31, Rendita 30, Continuita' 28: la forbice da 9 a 16,
    le due che vivevano delle ★ dei propri edifici perdono. Il compenso a 1 PV
    vale 10 PV a testa (14%) e il bot non lo valuta: troppo, se serve va piu'
    piccolo. **Il file base non cambia: decisione del designer sui numeri.**
    In corso `scelta_sconti`.
171. **La "scelta" e' il file base; sconti senza condizione; il ⊕ con lo
    sconto.** Il designer, ai numeri della quarantaquattresima e
    quarantacinquesima: "Ok vai". Tre cose, una alla volta. (1) La regola
    stile Caylus senza compenso al padrone e' il file base
    (`azione_edificio` = "scelta"): ogni carta dice "Usa:", `--variante
    proprietario` rifa' la regola di prima, `compenso_pv` quella con 1 PV al
    padrone. (2) Gli sconti: dieci carte con lo sconto senza condizione, "-1
    a quel che compri in questo turno" (Trappole, Terme, Insulae, Mulino,
    Mercato, Bottega, Loggia, Banco, Officina, Caffe'); lo sconto "" vale
    ora anche per il potenziamento (`_sconto_vale_per_potenziamento`).
    Variante `sconti`. (3) Il ⊕ porta anche lo sconto, "compri una cosa in
    piu' e paghi 1 in meno" (chiave `sconto` nell'azione acquisto): variante
    `sconti_extra`. Quarantaseiesima misura: gli sconti si usano 2,9 volte
    a partita invece di 1,6 e la forbice va da 28-44 a 29-40; il ⊕ con lo
    sconto si usa il 68% delle volte invece del 43%, costruzioni 15,6 invece di
    15,1. **Tutte e due nel file base** (`--variante senza_sconti` rifa' la
    quarantaquattresima). Le scelte vere sono 10 a partita a giocatore. Ora in
    coda Rendita 27 e Scavo 28: ritaratura nel bot (registro 172).
172. **Rendita e Scavo nel bot, sulla regola nuova.** Primo giro
    (quarantasettesima misura): `rendita_per_era` da 0,9 a 1,3 porta la
    Rendita dal 27 al 33% (forbice 27-38). I pesi "v1" della Scavo che avevo
    messo in tabella erano codice morto: con la v3 il bot usa il ramo v2
    (`scavo_premio`, `scavo_terra`, `scavo_terra_scavo`), e il lotto era
    identico alla base; tolti. Secondo giro: `scavo_premio` 0,8 e
    `scavo_terra_scavo` 0,5 insieme alla Rendita a 1,3 danno la forbice piu'
    stretta misurata, 29-37 (Bil 35, Cont 35, Lampo 33, Obi 31, Rend 37,
    Scavo 29): **e' la tabella `SPINTE_V3`**. La Scavo resta ultima perche' lo
    Scavo e' un canale di tutti; il suo margine sono i ritrovamenti, che nei
    bot non ci sono ancora.

173. **La strategia Ritrovamenti nei bot.** Il designer: "Ok procedi e poi
    mergia" (i tre punti aperti: Ritrovamenti, carte grandi rare, la domanda
    per le persone). La Ritrovamenti e' la "scheletri e arte" chiesta fin
    dall'inizio della v3: nel file v3 le tessere scavo valgono solo se
    riportate alla luce nell'era 5 (`riscoperta: solo_scavate`), con lo
    scheletro del Personaggio dell'era e i token Arte, e chi costruisce sopra
    incassa 1 PV per tessera (`premio: sotto`). La strategia (settima del
    canone v3, `STRATEGIE_V3`): al draft lo Scavo stampato del Personaggio
    (`ritro_scheletro` 0,5), le caselle dell'edificio che lasceranno tessere
    (`ritro_caselle` 0,6), nell'era 5 costruire sopra le proprie rovine mai
    scavate (`ritro_riscoperta` 1,2 per tessera), i token Arte (`ritro_arte`
    0,6 per Scavo), l'azione ⚱ come la Scavo. Quarantottesima misura, prima
    taratura: vince il 43% con 79 PV, ma con la Rendita (14,2) delle carte
    larghe piu' che con gli scheletri (Scavo 12,5 contro 11,5): il peso sulle
    caselle la fa giocare da Rendita. Seconda: caselle 0,2, arte 0,4,
    scheletro 0,3: al 33% con 76,8 PV, la Rendita risale da 25 a 32. **E' la
    tabella.** Scheletri e arte valgono 2,4 e 1,6 PV a partita: da soli non
    fanno una strategia, il margine della Ritrovamenti resta la riscoperta.
    La Obiettivi al 42-44 nel torneo a sette: con `obiettivi_peso` 0,8 scende a
    40, forbice 27-40. Tabella chiusa, la v3 va su main (PR #73).
174. **Le tre carte grandi rare.** Fortezza (⚒4, collina 2x2), Grattacielo
    (3 binari) e Stazione (3 colonne di pianura) si costruivano 0,03-0,14
    volte a partita per terreno e forma. Stazione su qualunque terreno,
    Grattacielo a 2 binari, Fortezza ⚒3 🪙1 (quarantottesima misura):
    Grattacielo 0,26, Fortezza 0,11, la Stazione resta a 0,03 per le tre
    colonne. **Nel file base**, `--variante grandi_vecchie` le rifa' come
    nella v2.
175. **La domanda "quale edificio usi?" per le persone.** Non fatta:
    l'interfaccia a schermo non conosce la v3 (il file di prova non e' fra
    quelli offerti), e la scelta e' una `pending_choice` di tipo "edificio"
    con `options` (uid) ed `etichette`, pronta per un pannello come quello
    del draft. Resta nel passaggio.
176. **L'interfaccia a schermo per la v3.** Il designer: "Fai l'interfaccia a
    schermo per la v3". Nella schermata d'inizio il regolamento ha il tasto
    "v3" (il file `data/proposte/cards-v3-era1.json`) ed e' la scelta di
    partenza; il draft a passaggio si fa cliccando la fila, che e' la propria
    mano (l'invito lo dice); prima di piazzare si sceglie il Personaggio da un
    tasto per ciascuno di quelli liberi ("Piazza: ...") o cliccando la sua
    carta davanti a se', e senza scegliere va il primo; la domanda "quale
    edificio usi?" (pending_choice "edificio") si risponde con un tasto per
    edificio, col nome, il padrone e l'azione, oppure cliccando l'edificio sul
    tavolo; con una carta gia' scelta la mossa aspetta la risposta e poi si fa
    col clic sul posto acceso; la finestra dell'acquisto in piu' ha il suo
    invito ("un potenziamento, o una casa"); in alto si leggono sconto, Lampo
    e acquisto in piu' del turno; il riquadro di un edificio mostra "Usa: ..."
    e "gia' usato in questo giro", quello di un proprio Personaggio se e' da
    piazzare o gia' piazzato. Tutto in `scripts/view/gioca.gd` e
    `scelte_inizio.gd`; il tavolo 3D non cambia. Test `test_view`: la v3 a
    schermo dal draft alla scelta dell'edificio.
177. **Il bot giocava il primo turno dell'era di un altro.** Trovato facendo
    l'interfaccia v3 (il test a schermo: l'umano, primo nell'ordine, si
    trovava un Personaggio gia' piazzato). In `StrategyBot.play_turn` il bot
    risolve le scelte in sospeso e poi gioca il turno di `current_player()`:
    se l'ultima presa del draft era sua, il draft finisce li' dentro e il
    turno passa al primo dell'ordine, che il bot giocava con la propria
    strategia, anche se era un altro bot o l'umano. Nella v3, con la quarta
    presa obbligata, capitava in circa due ere su tre. Corretto: dopo un
    draft, se il turno non e' piu' suo il bot si ferma. Nella v1.5 la stessa
    cosa succede con gli omaggi di fine era (il bot che piazza l'ultimo omaggio
    gioca il primo turno dell'era nuova per chi e' primo): li' resta com'e',
    perche' e' il riferimento congelato (TORNEO e VITA cambiavano in 12 e 38
    righe con la correzione larga). Quarantanovesima misura: il file base
    della v3 col bot corretto ha la stessa economia (entro un decimo) e
    vittorie Bil 36, Cont 38, Lampo 27, Obi 42, Rend 29, Ritro 37, Scavo 26:
    spostamenti entro l'errore, le conclusioni delle misure 44-48 restano.
178. **Il Grattacielo a tre binari, il seme nel riepilogo, il terrapieno sul
    Colosseo.** Il designer, giocando la v3 a schermo: un Monumento ai caduti
    sopra un Colosseo intatto, e prima "un terrapieno da solo"; il Grattacielo
    "sono tre slot in verticale, qui sono solo due"; "metti il seme della
    partita come promemoria nel riepilogo". Fatto: il Grattacielo torna a 3
    binari com'e' stampato (il registro 174 lo aveva portato a 2 per farlo
    costruire di piu', 0,17 → 0,26 a partita; Stazione e Fortezza restano
    ritoccate); il riepilogo finale porta in alto a destra "seme N · v3 · N
    giocatori". Il terrapieno sul Colosseo: dal codice una carta non puo'
    poggiare su una casella del Colosseo intatto (2x2, "sopra di lui solo
    quando e' in rovina"), e il terrapieno e' solo il riempimento delle
    caselle vuote di una carta larga; la spiegazione piu' probabile e' una
    carta su un altro binario della stessa colonna, al livello 1, che la
    vista disegna sollevata su tutta la colonna. **Aperto**: si rigioca col
    seme quando il designer lo ha; nel riquadro manca "poggia su ... ·
    binario N".
179. **Il Grattacielo: tre binari, livello 1, qualunque terreno.** Il
    designer, dopo la spiegazione dei tre vincoli (tre binari liberi in una
    colonna nell'era 5, il livello 2 che vuole una pila gia' alta, la sola
    pianura): "prova con tre binari e livello 1 e misura, terreno qualunque".
    Nel file base il Grattacielo resta a tre binari com'e' stampato, va su
    qualunque terreno e chiede il livello 1; `--variante grandi_vecchie` lo
    rimette in pianura al livello 2. Misurato (cinquantesima): 85 Grattacieli
    in 300 partite prima e 85 dopo, economia e vittorie identiche; cambia
    solo il terreno sotto (meno pianura, piu' bosco). Terreno e livello non
    erano il freno: lo sono il costo (3 Costruzione 1 Idea, il piu' caro
    dell'era con la Stazione) e il bot che non pesa il suo finale. Tenere la
    carta libera o tornare alla stampa: decisione del designer.

180. **Lo spianamento parziale: terrapieno sotto, rovina accanto.** Il
    designer, davanti a due Terrapieni soli nel seme 4573 (un Acquedotto di
    tre colonne spianato da una Palazzina di una casella): "se spiani un
    edificio dovresti rendere le caselle dove effettivamente costruisci dei
    terrapieni, perche' stai effettivamente usando il suo materiale e lo
    stai coprendo, mentre le caselle rimaste libere diventano rovine perche'
    NON ci hai costruito sopra. In questo modo si formano nuove rovine che
    possono valere qualcosa. Il vantaggio e' avere uno sconto costruzione e
    poter costruire qualcosa che potenzialmente vale di piu'". Oggi la carta
    spianata va in rovina tutta intera con Scavo 0 e senza tessere, e le
    caselle non coperte restano Terrapieni a vista (315 volte in 300 partite,
    una a partita: 202 carte 1x2, 72 2x1, 41 3x1). Regola nuova: le caselle
    coperte dalla carta nuova sono terrapieno (niente tessere, Scavo 0); le
    caselle non coperte restano rovina del proprietario, con le loro tessere
    e il loro Scavo, come ogni rovina. Da fare e misurare (cinquantunesima).
