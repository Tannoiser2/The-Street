# Domande aperte per il designer

Registro delle ambiguità incontrate durante l'implementazione. Formato: regola, dubbio, lettura provvisoria adottata.

## Già note al momento del passaggio

1. **Mulino** — il requisito "pianura adiacente a fiume" è solo nel testo effetto, non nel campo `terrain`. Va gestito come caso speciale o va aggiunto un campo `terrain_adjacent`?
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

6. **Verticalità, denominatore della metà proporzionale** — `Scoring._verticality`
   divide la seconda metà del premio contando *tutti* gli edifici della colonna
   (`in_column`), quindi anche i sotterrati e le rovine, non solo quelli in piedi.
   Cambia sensibilmente il punteggio. Lettura provvisoria: lasciato com'è,
   nessuna modifica in M1. Va confermato prima dell'allineamento all'oracolo (M3).

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

8. **Reclutamento: "in piedi" o "intatto"?** — la regola del reclutamento dice
   "richiede che la classe del personaggio sia presente fra gli edifici **in
   piedi** della colonna", ma la sezione sugli stati elenca "la sua classe conta
   per il reclutamento" fra le proprieta' dell'**intatto**, e definisce il rudere
   "in piedi ma spento".
   Lettura adottata: **solo gli intatti**. E' la piu' restrittiva e coerente con
   l'enumerazione degli stati. Se invece valgono anche i ruderi, cambia una riga
   in `ActionRules.quote_recruit`.

9. **Potenziamento su un rudere** — "Infilate la carta sotto un vostro edificio
   in piedi di quella colonna". Alla lettera "in piedi" include il rudere, che il
   regolamento definisce tale. Lettura adottata: **letterale, il rudere si puo'
   potenziare**. Ha un senso meccanico (un rudere affronta ancora gli eventi, e
   un potenziamento Struttura gli darebbe resistenza), ma e' il rovescio della
   scelta fatta al punto 8: vale la pena decidere i due casi insieme.

10. **Capienza dei potenziamenti** — "La capienza base e' di un potenziamento per
    edificio, salvo le carte che ne dichiarano di piu'". Nessuna carta in
    `cards.json` dichiara oggi una capienza diversa e non esiste un campo per
    farlo. Adottato 1 fisso (`ActionRules.UPGRADE_CAPACITY`). Se qualche carta
    deve poterne portare due, serve un campo nel JSON, non un caso speciale nel
    codice.

11. **Bosco: "il restauro costa 1 in meno" — 1 di cosa?** — il terreno non dice
    se lo sconto sia in pietra o in oro. Adottata la **pietra** (e' la risorsa in
    cui si esprime il costo di quasi tutti gli edifici, e non puo' scendere sotto
    zero). Da confermare.

12. **Piu' reclutamenti nella stessa era** — il regolamento non limita il
    reclutamento a uno per era, e la sepoltura dice "uno solo per edificio", il
    che presuppone che i personaggi possano essere piu' d'uno. Adottato:
    **un personaggio per lavoratore specializzato**, quindi fino a 3 (4 con
    Dinastia) per era. `PlayerState.specialized_character` e' diventato
    `specialized_characters: Array[String]`.

13. **Sepoltura sotto un rudere** — "infilatelo sotto la carta di un vostro
    edificio ancora in piedi". Adottato `is_standing()`, quindi anche un rudere
    puo' ospitare uno scheletro. Stessa famiglia di dubbi dei punti 8 e 9.

14. **Potenziamenti Struttura: +1 fisso** — tutte e sei le carte Struttura dicono
    "+1 res", quindi il cubetto nero e' implementato come +1 uniforme. Restano a
    M4 i due casi condizionali gia' presenti nel testo: `po_cannoniere`
    ("+2 su edificio Militare") e `po_merlatura` ("l'edificio conta anche come
    Militare"). Anche gli effetti delle carte Arte e "altro" sono M4: in M2 la
    carta viene attaccata all'edificio ma non produce ancora punti.

15. **Un lavoratore per colonna** — la regola ("Potete avere al massimo un vostro
    lavoratore per colonna") non era implementata nello scheletro. Aggiunta in M2
    perche' e' un vincolo di legalita' del piazzamento, da cui dipendono tutte le
    azioni. Segnalata qui perche' non era fra i TODO dichiarati.
