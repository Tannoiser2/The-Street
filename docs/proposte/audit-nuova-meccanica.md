# Audit della nuova meccanica: le domande da chiudere prima di simulare

> Seguito di [`nuova-meccanica.md`](nuova-meccanica.md) (la proposta trascritta, per ora nella
> PR #24). Qui ogni lacuna della proposta è messa accanto a **quello che il gioco fa oggi**
> (regolamento v1.5, `data/cards.json`, codice, misure sulle 10 000 partite) e a una **risposta
> consigliata** dove ce n'è una ragionevole. Le decisioni restano del designer: le
> raccomandazioni servono a fargli dire "sì" o "no" in una parola, non a decidere al suo posto.

Le 18 domande della trascrizione sono state verificate una per una contro dati e codice. Tre
cose sono emerse dall'audit e non stavano nella lista: le **tessere estratte a caso contro il
terreno richiesto dagli edifici** (D20), la **curva del punto 7 che nei costi c'è già** (D4) e la
**ristrutturazione che, senza rudere, rende rubabile ogni edificio caduto** (D13).

## L'ordine in cui conviene decidere

1. **Le risorse** (D1-D6): senza costi in tre risorse non si costruisce nemmeno una capanna, e
   tutto il resto si misura in quelle unità.
2. **Il turno** (D7-D14): le cinque azioni cambiano il controller, i bot e le sei strategie.
3. **Stati ed eventi** (D15-D19): la parte più facile da misurare, in parte già oggi.
4. **Le tessere** (D20-D22).
5. **La sagoma** (D23-D25): riguarda solo la vista, si può rimandare.

## A. Le risorse (punti 5 e 7)

**D1. Le Idee sono la Cultura di oggi, resa spendibile?** Oggi la Cultura è un canale di
*punti*, non una risorsa: un solo edificio la produce (Palazzo signorile), sette Personaggi la
danno "subito" e pesa l'**1,2 %** del punteggio. Le carte la chiamano già così in 13 punti.
*Consigliato:* Idee = Cultura trasformata in risorsa (una parola nuova, un concetto già sulle
carte); il canale "Cultura" dei punti sparisce e i suoi effetti diventano `idee: +1`. Se invece le
Idee sono una terza cosa, la Cultura resta punti e va deciso che rapporto hanno.

**D2. Cosa si compra con le Idee, e con il Denaro oltre agli edifici?** Oggi l'oro paga i
potenziamenti (1 nelle ere 1-3, 2 nelle ere 4-5, `upgrade_cost_by_era`), il reclutamento (1) e la
Dinastia (a scalare). Con il draft gratuito dei Personaggi (punto 8) il Denaro perde due dei suoi
tre usi. *Consigliato:* ogni risorsa deve avere **almeno un uso esclusivo**, altrimenti è pietra
di un altro colore. Proposta da confermare: Costruzione → edifici e terrapieni; Denaro → quota
degli edifici tardi e ristrutturazione; Idee → potenziamenti (crescono con le ere, come le Idee) e
Dinastia.

**D3. I 60 costi in tre risorse: chi li scrive e con che criterio.** Oggi 30 edifici costano
solo pietra e 30 pietra e oro; le medie per era sono pietra 1,5 / 2,6 / 1,9 / 1,6 / 1,2 e oro 0 /
0 / 0,6 / 1,8 / 2,5. *Consigliato:* per la **prima misura** una traduzione meccanica, pietra →
Costruzione e oro → Denaro invariati, con le Idee aggiunte come terza componente **agli edifici
delle ere 3-5** (1 nelle ere 3-4, 2 nell'era 5) e a nessun altro. Il designer riscrive poi i
costi a mano in `cards.json` (fonte unica) dopo aver visto le partite: nessuna sua tabella va
convertita da noi.

**D4. La curva del punto 7 riguarda i terreni, gli edifici o tutti e due?** Nei **costi** la
curva c'è già (D3: pietra che scende dopo l'era 2, oro che sale). Nella **produzione** oggi non
c'è: i terreni producono sempre lo stesso (pianura 2 pietra, fiume 1+1, collina 2, bosco 2) e 17
edifici su 60 producono a loro volta, senza andamento per era. *Consigliato:* la curva è quella
delle **tessere** (il punto 6 dice che la produzione sta sulla tessera), come tabella era ×
risorsa in `constants`, e gli edifici tengono la produzione stampata. Una tabella di partenza,
da confermare: Costruzione 2/2/1/1/1, Denaro 0/1/1/2/2, Idee 1/2/2/3/3 ("logaritmico" vuol dire
salire in fretta e poi appiattirsi). Va detto che se **anche** la produzione segue la curva dei
costi, l'effetto raddoppia: nelle ere 4-5 la Costruzione sarà rara e poco richiesta insieme.

**D5. Resta il tetto di 5 risorse?** Oggi è uno solo, totale, applicato a fine era ("la
dispersione dei secoli": `resource_cap` 5). *Consigliato:* tenere **un tetto totale** (una regola,
un numero da girare) e alzarlo a 6, perché con tre risorse mettere da parte per un costo a tre
componenti diventa impossibile a 5. Un tetto per risorsa (5+5+5) toglierebbe alla dispersione il
suo mestiere.

**D6. Con che risorse si parte?** Oggi 2 pietra (e 1 oro al secondo in due giocatori).
*Consigliato:* 2 Costruzione, 0 Denaro, 0 Idee; le Idee arrivano dalle tessere. Da confermare.

## B. Il turno (punto 8)

**D7. Il draft dei Personaggi: sono i 26 di oggi?** Oggi ce ne sono 5 per era più la Dinastia, e
il reclutamento costa 1 oro e **richiede la classe del personaggio fra gli edifici della
colonna**. Con il draft a inizio era non c'è nessuna colonna, quindi il requisito di classe
sparisce. Due famiglie non funzionano più così come sono: le **Impronte** (Incisore, Retore: "infila
questa carta sotto un tuo edificio") e i **protettori** (Capotribù, Legionario, Cavaliere: "la sua
protezione vale +3/+4"), che presuppongono un lavoratore specializzato. *Consigliato:* si
draftano i 5 dell'era in ordine di turno (primo chi ha costruito meno, la regola di oggi), gli
avanzi si scartano; con 2 giocatori ne restano 3, con 4 uno. Le Impronte diventano "a fine era
infila il Personaggio sotto un tuo edificio" (che è già la sepoltura), i protettori diventano
"il primo edificio che costruisci in quest'era ha +1/+2". Il designer dica quali dei 25 tiene.

**D8. La Dinastia (quarto lavoratore) resta?** Le cinque azioni non la nominano. *Consigliato:*
resta, comprabile in qualsiasi turno **al posto** dell'azione, pagata in Idee (D2), perché è
l'unico acquisto che non è né un edificio né un potenziamento.

**D9. Costruire mettendo il lavoratore sull'edificio: in quale colonna?** Oggi si costruisce
nella colonna attivata o in una adiacente. *Consigliato:* in **qualsiasi** colonna legale (i
binari sono liberi), il lavoratore va sull'edificio nuovo. Resta il limite di oggi, un proprio
lavoratore per colonna, contando quelli sugli edifici.

**D10. Cosa attiva il lavoratore sull'edificio.** Oggi attivare una colonna paga la base del
terreno **a chi attiva**, la produzione di ogni edificio in piedi **al suo proprietario** (anche
avversario) e, se la colonna è un Centro Urbano, 1 oro a testa una volta per era. *Consigliato:*
il lavoratore sull'edificio attiva **solo quell'edificio**: né la base del terreno né il Centro
Urbano, che restano il premio dell'azione "colonna". Altrimenti la colonna non la attiva più
nessuno.

**D11. Il +2 di resistenza dura fino a fine era?** Oggi il lavoratore su una colonna protegge
l'edificio su cui sta (+2, `protection_bonus`) fino a fine era, e tre eventi puniscono i "non
protetti". Nella proposta solo chi **costruisce** protegge, e solo l'edificio nuovo.
*Consigliato:* sì, fino a fine era, poi il lavoratore torna. Da misurare subito: oggi il 17 %
degli edifici cade nell'era in cui nasce; con la protezione riservata ai nuovi cadranno di più
i vecchi, e Colosseo, Pantheon e Guardiano (che premiano chi resta in piedi) diventano più rari.

**D12. Lo scheletro sul potenziamento "potrebbe" dare punti: con quale regola?** Oggi lo
scheletro è il Personaggio sepolto a fine era sotto un edificio in piedi, e vale **6 meno l'era**
se quell'edificio finisce sotterrato (3,5 % dei punti). *Consigliato:* stessa regola, cambiando
solo chi è lo scheletro: il lavoratore resta sotto l'edificio potenziato e vale 6 meno l'era se
l'edificio è sotterrato a fine partita. Il codice di conteggio (`Scoring._scheletri`) resta com'è.
Domanda che ne segue: quel lavoratore **torna** a fine era o è perso per sempre? Se è perso, il
potenziamento costa un lavoratore per tutta la partita: con 3 lavoratori è un prezzo enorme.
*Consigliato:* torna a fine era, e sotto l'edificio resta un gettone scheletro.

**D13. La ristrutturazione: costo, risorsa, e di chi diventa l'edificio.** Oggi il restauro
costa metà del costo originale arrotondato per eccesso (bosco: −1), vale solo sui **ruderi**, e
**il rudere di un avversario diventa di chi lo restaura**. Senza rudere, l'unico stato caduto è la
rovina: se la regola del furto resta, **ogni edificio caduto di un avversario è rubabile**, e lo
Scavo (che oggi va al proprietario della rovina sepolta) cambia mano con lui. *Consigliato:*
metà del costo in Costruzione arrotondato per eccesso, e **solo le proprie rovine**; se il
designer vuole tenere il furto, serve il segno di proprietà sulla rovina (D24) e va misurato
quanto Scavo passa di mano.

**D14. "Passare e incassare": quanto, e quando finisce l'era.** Oggi non si passa: l'era finisce
quando tutti hanno piazzato i lavoratori (`workers_used >= workers`), e l'azione è facoltativa.
*Consigliato:* passare **consuma il lavoratore** (va sulla plancia) e incassa una tabella per era
in `constants`, per esempio 1 Costruzione più 1 risorsa a scelta; così l'era finisce come oggi,
quando finiscono i lavoratori, senza una regola nuova "tutti hanno passato".

## C. Stati ed eventi (punti 3, 9, 10, 11)

**D15. La soglia dell'evento con un passo solo.** Oggi "resistenza efficace ≥ forza" salva;
fallire di 1-2 fa rudere, di 3 o più rovina (`rovina_gap` 3), e la misura dice che a gap 2 gli
edifici che cadono nell'era in cui nascono passano dal 17 % al 31 %. Un passo solo si può leggere
in due modi: **fallire di 1 fa rovina** (più severo di qualunque cosa misurata) o **rovina solo
fallendo di 3, altrimenti niente**. *Consigliato:* la seconda, che tiene il tasso di rovine di
oggi (69 % degli edifici) e toglie solo lo stato intermedio. È anche la **prima misura** da fare,
ed è a costo quasi zero: il motore di oggi con una manopola "il rudere non esiste" (chi fallisce
di 1-2 resta intatto) dice già quanti edifici restano in piedi e quanto vale la Rendita senza
rudere, prima di toccare qualsiasi altra cosa.

**D16. Sotterrato come stato: un edificio attivo con sopra qualcosa?** Oggi sotterrato è una
posizione: una rovina (o rudere) coperta interamente vale lo Scavo; costruire sopra un **proprio
intatto** è permesso e lo spiana a rovina prima (`BaseKind.PROPRIO_INTATTO`). *Consigliato:*
resta così, con parole nuove: sotterrato = rovina coperta interamente; spianare un proprio
attivo resta possibile e lo fa rovina. Da confermare che lo spianamento sopravviva.

**D17. Metà della resistenza: arrotondamento e quale resistenza.** Le resistenze stampate vanno
da 1 a 5; oggi lo sconto macerie è fisso a 1 e non supera la pietra dovuta. *Consigliato:*
metà **per difetto** della resistenza **stampata** (una rovina non ha più potenziamenti né
lavoratori: `upgrades.clear()` al crollo), mai oltre la Costruzione dovuta. Dà 0-2 di sconto, e
cresce con le ere insieme al calo della Costruzione: è coerente con il punto 7. La spoliazione
di oggi (depredare un rudere per 1-3 pietra secondo la taglia) sparisce, sostituita da questo.

**D18. Le carte che nominano il rudere.** Sono sei: Secolarizzazioni (evento), Colosseo e
Pantheon (Monumenti), Guardiano, Silvicoltore e Restauratore (Eredità); più la Cava, che
"esaurita diventa rudere", e il registro 81 (Colosseo e Silvicoltore contano intatti e ruderi).
*Consigliato:* "in piedi" diventa "attivo"; Restauratore = "hai ristrutturato 2+ rovine";
Secolarizzazioni = "ristrutturare una rovina Religione non costa"; la Cava esaurita diventa
rovina. Nessuna carta va tolta.

**D19. La Vetustà resta?** È il punto per ogni evento superato (fino a 3, 4 nel bosco), si somma
alla Rendita (insieme il 21 % dei punti) e non dipende dal rudere ma dal restare in piedi.
*Consigliato:* resta identica, sugli edifici attivi. Se il bosco cambia mestiere (D21) il "+4
nel bosco" va tolto o spostato sulla tessera.

## D. Le tessere (punto 6)

**D20. Le tessere a caso e il terreno richiesto dagli edifici.** 37 edifici su 60 richiedono un
terreno (13 pianura, 11 collina, 11 fiume, 2 bosco, uno "fiume adiacente"). Oggi il mix è fisso
per numero di giocatori e li garantisce; con l'estrazione casuale una partita a 5 colonne può non
avere il fiume, e 11 edifici restano incostruibili. *Consigliato:* o il mazzo garantisce **almeno
una tessera per tipo** (si estrae una per tipo, poi il resto a caso), o il requisito di terreno
sparisce dagli edifici. La prima cambia meno carte.

**D21. Quante tessere, di quanti tipi, con quale produzione.** Gli esempi della proposta (fiume
1 Costruzione, bosco 1 Idea, pianura 1 Denaro) **cambiano mestiere** ai terreni: oggi il fiume è
l'unico che produce oro, il bosco è conservazione (Vetustà +4, restauro −1), la collina dà +1
resistenza. *Consigliato:* 4 tipi come oggi, 3 tessere per tipo (12), si estraggono 5/7/9. Serve
dal designer la tabella tipo → produzione, e la conferma che gli 11 edifici "fiume" non devono più
stare vicino all'acqua per ragioni di gioco.

**D22. L'effetto una volta per era: quando scatta e quali sono.** Il motore ha già i ganci che
servono (`on_activate`, `on_build`, `on_event`, `on_era_end`) e i contatori `times` e
`duration: era`: un effetto di tessera è un effetto con `times: 1` che si ricarica a inizio era.
*Consigliato:* le abilità permanenti di oggi (pianura −1 pietra ai larghi, collina +1 res, bosco
restauro −1) diventano gli effetti una volta per era delle stesse tessere, così non si inventa
niente; "quando lo dice la tessera" = il gancio scritto nell'effetto. Serve la lista, una riga per
tessera.

## E. La sagoma (punti 2, 3, 4)

**D23. Il mercato.** Oggi 6 carte visibili (`market_size`) più due file da 3 per Personaggi e
potenziamenti. *Consigliato:* le 6 sagome in fila al posto delle carte, la fila dei potenziamenti
com'è, la fila dei Personaggi sparisce (draft). Per il motore non cambia nulla.

**D24. Di chi è la rovina.** Il motore lo sa sempre (`Building.owner`) e sa anche chi l'ha
sepolta a metà (c'è un TODO per il +1 "disturbo" a chi sotterra un edificio altrui). Al tavolo
serve un segno: *consigliato* la base della sagoma nel colore del giocatore, che oggi è già la
"basetta nuda". Non blocca la simulazione.

**D25. Le misure.** Nel modello 3D lo slot del binario è profondo 26 mm (`SLOT_D`) e il modulo
delle sagome è 60,3 mm per slot: una sagoma larga 20 e lunga 1-3 slot ci sta. Ruotata di 90°
sull'asse lungo, la rovina è alta 20 mm e profonda 15: sta ancora nel binario e alza chi ci
costruisce sopra di 20 mm invece dei 4 del cartone di oggi. Riguarda solo `board_layout_3d`.
Non blocca la simulazione.

## Cosa non cambia, per iscritto

Il punto 1 dice "fatto salvo quello che abbiamo fatto finora". Salvo contrordine restano: binari
liberi, Verticalità 2/5/9/14, Continuità, Centro Urbano (3 edifici, 2 proprietari, una volta per
era), Rendita e Lampo, Monumenti ed Eredità, le cinque ere con gli eventi di forza 2-3-4-5 e i
loro effetti, il terrapieno a 1 Costruzione, il limite di un livello per era per colonna.

## Come prototipare, quando le risposte ci sono

- **Prima misura, oggi stesso, senza risposte**: D15 con una manopola sul motore attuale.
- **Regolamento a interruttore**: `data/cards.json` resta la v1.5, `data/cards-v2.json` porta
  costi, tessere e costanti nuove; un `ruleset` in `constants` sceglie le regole. Le intestazioni
  dei lotti (`# partite=… ruleset=…`) e `impagina_vita.py --confronta` lo nominano, così due
  lotti diversi non sembrano uguali.
- **Un cambiamento alla volta, stessi semi**: tre risorse con il turno vecchio, poi le cinque
  azioni, poi le tessere. Ogni passo ha un termine di paragone.
- I bot vanno riscritti con le azioni: prima `RandomBot` (basta che sia legale), poi le
  strategie; le misure sulla v2 con il solo bot casuale non dicono niente sul bilanciamento.
