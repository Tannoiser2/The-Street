# Le carte da rifare per la v2

> L'elenco di tutto quello che, stampato oggi, dice una cosa che nella v2 non è più vera. Le
> regole della v2 sono quelle decise nel registro (punti 87-93) e nel file `data/cards-v2.json`:
> tre risorse (Costruzione, Denaro, Idee), niente rudere (attivo, rovina, sotterrato), niente
> Verticalità (premio di scavo S×L a chi costruisce sopra, dimezzato nell'era 5), il turno a
> cinque azioni con il lavoratore che va dove agisce, il draft dei Personaggi a inizio era, le
> tessere pescate a caso con produzione per era. **Non è una decisione sui testi**: per ogni
> carta c'è il motivo per cui va rifatta e una proposta, e decide il designer.

Sigle del motivo:

| sigla | perché cambia |
|---|---|
| **3R** | tre risorse: il costo o l'effetto nomina pietra/oro dove ora ci sono Costruzione, Denaro e Idee |
| **RUD** | nomina il rudere, il restauro del rudere, la spoliazione o la Vetustà come oggi |
| **LAV** | presuppone il lavoratore sulla colonna: "protetto", "abiti qui", "questo lavoratore" |
| **DRA** | presuppone il reclutamento come azione (classe nella colonna, 1 oro) invece del draft |
| **TES** | presuppone le tessere di oggi (abilità permanente, mix fisso) |
| **SAG** | la carta diventa una sagoma unica (punto 2 della proposta): cambia l'oggetto, non il testo |
| **CUL** | dice "cultura" per i punti: con le Idee come risorsa la parola va cambiata (proposta: "PV") |

## 1. I 60 edifici

**Tutte e 60** cambiano oggetto (SAG: una sagoma sola con costo, produzione, resistenza,
Rendita, Lampo e Scavo, ruotabile sul lato rovina con lo Scavo in vista) e **costo** (3R: la
tabella in tre risorse è `proposte/costi-tre-risorse.md`, già nel file v2). La produzione
"cultura" diventa Idee (Palazzo signorile). Oltre a questo, cambia il **testo** di:

| carta (era) | oggi | motivo | proposta |
|---|---|---|---|
| Focolare comune (1) | Quartiere: +1 pietra quando abiti qui | LAV, 3R | +1 Costruzione quando lo attivi (con il lavoratore sulla colonna o quando lo costruisci) |
| Acquedotto (2) | Colossale … 3 slot pagando +1 pietra | 3R | +1 Costruzione |
| Ospedale dei pellegrini (3) | Quando abiti qui, +1 oro | LAV, 3R | +1 Denaro quando lo attivi |
| Bottega d'artista (4) | I tuoi potenziamenti costano 1 oro in meno | 3R | costano 1 in meno, nella loro risorsa (Arte in Idee, Struttura in Costruzione, il resto in Denaro) |
| Palazzo signorile (4) | produce 1 cultura | 3R | produce 1 Idea (già nel file v2) |
| Università (5) | +1 PV per ogni tuo personaggio reclutato | DRA | per ogni Personaggio preso nel draft |
| Monumento ai caduti, Museo, Biblioteca, Parco archeologico (5) | "Sotterrato" | — | il termine resta: sotterrato è uno dei tre stati |
| Condominio (5) | "costruire il presente sopra il passato…" | — | resta: si costruisce sopra le rovine, con lo sconto di metà resistenza (punto 10) |

Gli altri 50 hanno solo numeri o testi che restano validi (Quartiere +1 res, Eco, Colossale,
Svettante, Sacrario).

## 2. Le 4 tessere terreno

**Tutte** (TES): nella v2 le tessere si pescano, producono per tipo con una curva per era e hanno
un effetto una volta per era (punto 6). Le abilità permanenti di oggi spariscono o diventano
l'effetto una tantum:

| tessera | oggi | proposta (curva già nel file v2) |
|---|---|---|
| Pianura | 2 pietra; edifici da 2-3 caselle −1 pietra | Denaro 0/1/1/2/2 (+1 Costruzione nelle ere 1-2); una volta per era: −1 Costruzione a un edificio da 2-3 caselle |
| Fiume | 1 pietra 1 oro; "unico terreno che produce oro" | Costruzione 2/2/1/1/1; una volta per era: +1 Denaro all'attivazione |
| Collina | 2 pietra; +1 res permanente a chi costruisce qui | Costruzione 2/2/1/1/1; una volta per era: +1 res a un edificio qui per l'evento |
| Bosco | 2 pietra; Vetustà max +4, restauro −1 pietra | Idee 1/2/2/3/3; una volta per era: −1 Costruzione a una ristrutturazione |

Quante copie di ogni tipo stampare lo decide il mix (`terrain_mix_by_players` nel file v2: il bosco
è garantito, due a tre giocatori).

## 3. I 26 Personaggi

**Tutti** (DRA): niente costo in oro, niente classe richiesta nella colonna; si prendono a inizio
era, uno a testa in ordine di turno, fra i cinque dell'era. La classe stampata resta come
informazione. Cambia il testo di:

| carta (era) | oggi | motivo | proposta |
|---|---|---|---|
| Capotribù (1) | l'edificio protetto da questo lavoratore ha +1 res | LAV | il primo edificio che costruisci in quest'era ha +1 res (è così nel motore v2) |
| Legionario (2), Cavaliere (3) | la sua protezione vale +3/+4 invece di +2; se l'edificio protetto sopravvive, +1 cultura | LAV, CUL | il primo edificio che costruisci in quest'era ha +3/+4 invece di +2; se sopravvive all'evento, +1 PV |
| Incisore (1), Retore (2) | Impronta: infila questa carta sotto un tuo edificio | DRA | a inizio era 1 nessuno ha edifici: "infila questa carta sotto il primo edificio che costruisci in quest'era" (Scavo +3/+5) |
| Mercante di ossidiana (1) | fino a 2 scambi pietra↔oro alla pari | 3R | 2 scambi alla pari fra due risorse qualsiasi |
| Costruttore di zattere (1), Architetto (2), Mastro costruttore (3) | −1 pietra … | 3R | −1 Costruzione |
| Mastro costruttore (3) | puoi costruire in qualsiasi slot | — | nella v2 si costruisce già ovunque (D9): resta solo "+1 res permanente alla tua prima costruzione" |
| Sacerdotessa (2), Console (2), Mercante (3), Banchiere (4), Cardinale (4), Artista di corte (4), Industriale (5) | +1 oro, −1 oro, +3 oro, "produzioni di oro" | 3R | Denaro; per Cardinale e Sacerdotessa dire in quale risorsa vale lo sconto o il rimborso (Religione paga soprattutto Costruzione e Idee) |
| Vescovo (3) | il prossimo potenziamento su un Religione costa 0 | 3R | resta, ma vale nella risorsa del potenziamento |
| Cronista (3), Mecenate (4) | +1 cultura | CUL | +1 PV |
| Mecenate (4) | i potenziamenti Arte che acquisti valgono +1 PV | — | resta (l'Arte si paga in Idee) |
| Archeologo (5) | scegli una tua Rovina non Sotterrata | — | resta: la rovina è uno stato della v2 |
| Dinastia | 4 pietra · 2 pietra + 1 oro · 1 pietra + 2 oro · 3 oro | 3R | 4/3/3/3 Idee (registro 91), sempre un'azione, al posto del turno (D8) |

Da decidere a parte: gli scheletri. Oggi i Personaggi presi si seppelliscono a fine era sotto un
edificio in piedi e valgono 6 meno l'era se quell'edificio finisce sotterrato; nella v2 il
motore fa ancora così, e in più il lavoratore sul potenziamento "potrebbe" dare punti (D12).

## 4. I 25 potenziamenti

**Tutti**: il costo cambia risorsa per famiglia (3R: Arte in Idee, Struttura in Costruzione, il
resto in Denaro, importi di oggi, registro 91) e ognuno ospita un lavoratore che ci resta come
scheletro (SAG: serve il posto sulla sagoma). Cambia il testo di:

| carta (era) | oggi | motivo | proposta |
|---|---|---|---|
| Granaio comune (1) | Quando abiti questo edificio, +1 pietra | LAV, 3R | +1 Costruzione quando attivi l'edificio |
| Banchina (2) | Solo su slot fiume: quando abiti qui, +1 oro | LAV, 3R | +1 Denaro quando attivi l'edificio |
| Boutique (5) | Quando abiti questo edificio, +2 oro | LAV, 3R | +2 Denaro quando attivi l'edificio |
| Stalli mercantili (3) | l'affitto incassato è +1 | — | resta (è la Rendita) |
| Targa storica (5) | +2 Scavo a ogni Sotterrato sotto | — | resta |

## 5. I 24 eventi

| carta (era) | oggi | motivo | proposta |
|---|---|---|---|
| Migrazione (1), Invasione (2), Carestia primitiva (1) | edifici non protetti: −1/−2 res | LAV | resta, ma "protetto" ora vuol dire "con il lavoratore di chi l'ha costruito in quest'era": colpiscono quasi tutto, da misurare (D11) |
| Inverno lungo (1) | tutti perdono 1 pietra | 3R | 1 Costruzione |
| Secolarizzazioni (4) | restaurare un rudere Religione non costa risorse | RUD | ristrutturare una propria rovina Religione non costa risorse |
| Speculazione edilizia (4) | ogni edificio con Vetustà 2+: −1 res | RUD | la Vetustà resta anche senza rudere (cresce a chi regge l'evento); se il designer la toglie, la carta va sostituita |
| Anni della fame (3) | nessuna produzione durante l'ultimo round dell'era | — | resta: i round ci sono ancora (tre lavoratori, tre giri) |
| Eruzione (2), Bonifiche (4) | potenziamento gratis; primo terrapieno a 0 | — | restano (terrapieni e potenziamenti ci sono) |

Gli altri 15 dicono solo classi, terreni e resistenze: restano.

## 6. I 14 Monumenti

| carta | oggi | motivo | proposta |
|---|---|---|---|
| Colosseo | primo il cui edificio sopravvive esposto a 3 eventi (Vetustà 3, in piedi o rudere) | RUD | "in piedi" = attivo; resta se la Vetustà resta |
| Pantheon | edificio dell'era 1-2 ancora in piedi (intatto o rudere) nel Moderno | RUD | ancora attivo |
| Cloaca Massima | 3 pietra spese in terrapieni | 3R | 3 Costruzione |
| Acropoli | primo a costruire a livello 4 | — | resta (i livelli restano, la Verticalità no) |

Gli altri 10 restano (Fori Imperiali e Catacombe usano "sotterrato", che resta).

## 7. Le 16 Eredità

| carta | oggi | motivo | proposta |
|---|---|---|---|
| Il Guardiano | un tuo edificio in piedi (intatto o rudere) costruito nell'era 1-2 | RUD | ancora attivo |
| Il Silvicoltore | un tuo edificio su bosco con Vetustà 3+ | RUD, TES | resta se la Vetustà resta; il bosco produce Idee, non protegge più |
| Il Restauratore | hai restaurato 2+ ruderi | RUD | hai ristrutturato 2+ tue rovine |
| Il Verticalista | costruito a livello 4+ | — | resta: il nome ricorda un canale che non c'è più, ma la condizione vale |
| Il Demolitore | spianato 3+ tuoi edifici intatti | — | resta: lo spianato è il terrapieno della v2 (registro 87) |

## 8. Il regolamento

- **"+1 per ogni edificio altrui sotterrato"** (il disturbo): mai contato né dal motore né
  dall'oracolo, `disturbo_vp` è 0 finché il designer non decide (registro 88).
- **La Vetustà** senza rudere: il motore la fa crescere a chi regge l'evento; la domanda 18 della
  proposta è aperta. Sei carte la nominano (Colosseo, Silvicoltore, Speculazione edilizia, il
  bosco, due costanti).
- **"Cultura"**: oggi è un canale di punti (Cronista, Legionario, Cavaliere, Mecenate, Artista di
  corte) e il nome della classe; con le Idee come risorsa conviene dire "PV" per i punti e tenere
  "Cultura" solo per la classe.
- **"Protetto"**: nella v2 protegge solo il lavoratore di chi costruisce, sull'edificio nuovo. I
  tre eventi "non protetti" e i tre protettori vanno riletti con questo significato.
- **Reclutare** sparisce dalle azioni; **la Dinastia** resta un acquisto al posto del turno.

## Come rifare l'elenco

I testi vengono da `data/cards.json` (`effect_text`, `rule`, `condition_text`); le regole della v2
da `data/cards-v2.json` e dal registro. Chi cambia una regola aggiorna la riga qui.
