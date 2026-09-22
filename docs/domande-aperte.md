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
