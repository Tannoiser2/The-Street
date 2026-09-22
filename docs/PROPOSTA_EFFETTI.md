# M4 — Proposta di schema chiuso per gli effetti delle carte

Il brief chiede di **proporre uno schema chiuso di tipi di effetto prima di
implementarli**. Questo è quello.

> **Lo schema è cresciuto in tre punti nel blocco personaggi, e va detto.**
> La proposta diceva: «se servisse un undicesimo nome di `rule_override`, è il
> segnale che lo schema va rivisto con te — non allungato di nascosto». È
> successo. Le tre estensioni:
> 1. `rule_override` passa da 10 a **11 nomi**: `free_upgrade_of_class`, per il
>    Vescovo («il prossimo potenziamento su un tuo edificio Religione costa 0»).
>    È il fratello di `free_restore_of_class`, che già c'era.
> 2. `vp_per` guadagna `value_from: "scavo"`, perché l'Archeologo assegna PV
>    pari allo *Scavo della carta*, non a una costante. Ho preferito questo a un
>    dodicesimo override: è generale e riusabile.
> 3. Gli effetti guadagnano `condition`, un gate con lo stesso vocabolario che
>    useranno Monumenti ed Eredità («se hai già 3+ edifici Sotterrati, +1 PV»).
>    Riuso, non proliferazione.
>
> **Il blocco EDIFICI ha richiesto altre estensioni**, sempre dichiarate:
> predicati di selettore `is_self`, `is_top`, `below_self`; campo `to`
> (`self` | `target_owner`, per il malus del Grattacielo agli avversari); campo
> `per` su `vp_per` (`building` | `distinct_class` | `level` | `upgrade` |
> `recruited_character`); `value_from` ammette anche `level`. Più il campo
> `terrain_adjacent` sugli edifici, che **chiude la domanda aperta 1** (Mulino)
> con un campo invece che con un caso speciale.
>
> **Stato: dati strutturati per EVENTI, PERSONAGGI ed EDIFICI. Il motore
> applica: i modificatori di resistenza degli eventi, le aure di Quartiere e di
> colonna degli edifici, i «Subito:» dei personaggi, il **punteggio finale degli
> edifici** (voce 7 del conteggio), due override e il requisito di terreno
> adiacente. `Effects.pending()` elenca i 17 tipi ancora inerti.** Lo schema qui descritto è in
> `data/cards.schema.json`, tutti e 24 gli eventi hanno il campo `effects`, e
> `Effects` li applica. Gli altri blocchi (personaggi, edifici, potenziamenti,
> Monumenti, Eredità) sono ancora solo proposta: le cinque decisioni in fondo
> restano aperte.

Base: la lettura di tutti i 165 `effect_text` e `condition_text`.

---

## 1. Prima di tutto: `effect_text` contiene tre cose diverse

Sui 60 edifici:

| categoria | quante | esempio |
|---|---:|---|
| ribadiscono un campo già strutturato | 15 | «Produce 1 pietra» → campo `production` · «Richiede livello 1+» → `level_required` |
| **puro testo di colore** | 3 | Menhir: «Piccolo ma quasi indistruttibile» · Circolo di pietre: «Lo Stonehenge della strada» |
| meccanica vera da strutturare | 31 | Museo: «+2 PV per ogni edificio Sotterrato sotto di sé» |
| vuoti | 11 | — |

**Conseguenza sul metodo**: un campo `effects` non va riempito per tutte le carte.
Va riempito per le 31, lasciato vuoto per le altre, e le 15 che ribadiscono un
campo **non vanno duplicate** — altrimenti si creano due fonti per lo stesso
numero, contro il principio 3.

Il testo di colore va conservato ma distinto: propongo di rinominare quei tre in
`flavour_text`, così è chiaro a colpo d'occhio che non c'è nulla da implementare.

---

## 2. Lo schema proposto

Ogni carta può avere un campo facoltativo `effects`, un array. Ogni voce:

```json
{
  "hook":  "on_event",
  "op":    "resistance",
  "target": { "terrain": ["bosco", "collina"] },
  "value": -1
}
```

### 2.1 `hook` — quando si applica (chiuso, 6 voci)

I cinque del brief, più uno che serve e non era in elenco:

| hook | quando |
|---|---|
| `on_acquire` | **non nel brief** — al momento in cui prendi la carta. Serve ai 15 «Subito:» dei personaggi |
| `on_build` | quando costruisci |
| `on_activate` | quando attivi la colonna |
| `on_event` | alla risoluzione dell'evento di fine era |
| `on_era_end` | alla chiusura dell'era, dopo l'evento |
| `on_final_scoring` | nel conteggio finale |

### 2.2 `target` — selettore (chiuso, congiunzione di predicati)

Tutti facoltativi; presenti insieme valgono in AND.

| predicato | valori | da quale carta nasce |
|---|---|---|
| `owner` | `self` · `any` · `others` | Mura («anche altrui») |
| `class` | le 6 classi | «Militare +1 res» |
| `terrain` | i 4 terreni | «Edifici su bosco e collina: −1 res» |
| `level` | `{min,max}` | «a livello 0 o 1: −1; a livello 2+: −2» |
| `width` | `{min}` | «Edifici da 2 o 3 caselle: −1 res» |
| `state` | `intatto` · `rudere` · `rovina` | Archeologo: «una tua Rovina non Sotterrata» |
| `buried` | booleano | Museo, Biblioteca, Fori Imperiali |
| `protected` | booleano | «Edifici non protetti: −1 res extra» |
| `vetusta` | `{min}` | «Ogni edificio con Vetustà 2+: −1 res» |
| `scavo` | `{min}` | «Edifici con Scavo 2+: −1 res» |
| `produces` | booleano | «che producono risorse: −2 res» |
| `era` | `{min,max}` | Pantheon: «un edificio dell'era 1 o 2» |
| `column` | `{min_owners, min_standing, min_eras}` | «colonne con edifici di 2+ giocatori» · «3+ edifici in piedi» · Cronista |
| `adjacent_to_self` | booleano | tutti gli 8 «Quartiere» |
| `same_column_as_self` | booleano | Castrum, Biblioteca |

### 2.3 `op` — che cosa fa (chiuso, 10 voci)

| op | campi | copre |
|---|---|---|
| `resistance` | `value` | 19 eventi su 24, Sciamano, Castrum, i Quartiere di resistenza |
| `resource` | `pietra`, `oro` | i «Subito: +N pietra/oro», «tutti perdono 1 pietra» |
| `vp` | `value` | i «+1 cultura», Eco, i PV secchi |
| `vp_per` | `value`, `target`, `cap` | tutto il punteggio finale: Museo, Biblioteca, Veterano, Urbanista, Monumento ai caduti, Università |
| `cost_delta` | `pietra`, `oro`, `what` (`building`/`upgrade`), `target` | Costruttore di zattere, Architetto, Cardinale, Bottega d'artista |
| `production_delta` | `pietra`, `oro` | Ponte, Industriale |
| `protection_delta` | `value` | Legionario (+3), Cavaliere (+4) |
| `scavo_delta` | `value` | le 2 Impronte, Soprintendente, po_iscrizione |
| `upgrade_slots_delta` | `value` | Vescovo |
| `rule_override` | `name` (enum chiuso, sotto) | i 10 casi irriducibili |

### 2.4 Modificatori comuni

| campo | significato |
|---|---|
| `cap` | tetto totale: «max 2», «max +4» |
| `times` | solo le prime N occorrenze: «le tue prime 2 produzioni di oro» |
| `duration` | `once` · `era` · `permanent` |

### 2.5 `rule_override` — l'elenco è chiuso, ed è questo

Uno schema con una via di fuga aperta non è chiuso. Questi sono **tutti** i casi
che non si riducono a un numero, elencati uno per uno:

| nome | carta |
|---|---|
| `ignore_terrain_requirement` | Mastro costruttore |
| `first_terrapieno_free` | Bonifiche |
| `free_restore_of_class` | Secolarizzazioni |
| `no_production_last_round` | Anni della fame |
| `free_upgrade_on_loss` | Eruzione |
| `resource_exchange` | Mercante di ossidiana |
| `counts_as_class` | Tumulo funerario, po_merlatura |
| `colossal` | Acquedotto, Anfiteatro, Stazione |
| `scavo_only_if_buried` | Grotte dipinte |
| `upgrade_on_others_building` | Artista di corte |

Se durante l'implementazione servisse un undicesimo nome, è il segnale che lo
schema va rivisto con te — non allungato di nascosto.

---

## 3. Monumenti ed Eredità: schema separato

Non sono effetti, sono **condizioni**. Vocabolario proposto per `condition`:

| op | copre |
|---|---|
| `count_matching` (selettore + `min`) | «4+ tuoi edifici Sotterrati», «3+ Militari in piedi» |
| `same_column_count` (selettore + `min`) | «3 edifici Religione nella stessa colonna» |
| `distinct_columns` (`min`) | «edifici in 5+ colonne diverse» |
| `consecutive_columns` (`min`, `top_only`) | «3 colonne consecutive» · «in cima a 4 colonne consecutive» |
| `all_of` (`terrain` / `era`) | «tutti e quattro i terreni» · «tutte e cinque le ere» |
| `counter` (`name` + `min`) | «hai spianato 3+», «hai restaurato 2+», «3 pietra in terrapieno», «sopravvive a 3 eventi» |

### Il punto che richiede una decisione tua

I 14 Monumenti dicono tutti «**Primo** a…»: sono una corsa, non una condizione di
fine partita. Vanno valutati **durante** la partita, a ogni cambiamento di stato,
e il primo che la soddisfa se li prende.

Inoltre `counter` richiede contatori storici che oggi **non esistono**: edifici
spianati, ruderi restaurati, pietra spesa in terrapieni, eventi superati da
ciascun edificio. Non sono ricavabili dalla plancia finale: vanno accumulati
durante il gioco.

---

## 4. Copertura

| blocco | carte | coperte dallo schema | note |
|---|---:|---:|---|
| Eventi | 24 | 24 | 19 con `resistance` puro, 5 con un `rule_override` in aggiunta |
| Personaggi | 25 | 25 | 15 hanno due effetti (`on_acquire` + era) |
| Potenziamenti | 25 | 25 | i 6 Struttura sono già `+1 res`; restano 2 condizionali |
| Edifici | 60 | 31 | 15 già strutturati, 3 di colore, 11 vuoti |
| Monumenti | 14 | 14 | schema `condition`, più la corsa e i contatori |
| Eredità | 16 | 16 | schema `condition` |

---

## 5. Cosa ho già fatto, perché non era una scelta di design

**Capienza dei potenziamenti.** Quattro edifici la dichiarano nel testo — Chiesa,
Abbazia, Accademia (2) e Duomo (3) — ma non esisteva un campo, e la mia
implementazione della M2 ne forzava 1. Il regolamento dice «salvo le carte che ne
dichiarano di più», quindi era semplicemente un bug.

Aggiunto il campo `upgrade_slots` alle 4 carte e allo schema; `ActionRules` lo
legge dalla carta invece di avere una costante. Correggo anche quanto avevo
scritto al punto 10 di `domande-aperte.md`: avevo cercato un campo e concluso che
nessuna carta dichiarasse una capienza diversa. Avrei dovuto cercare nel testo.

---

## 6. Le decisioni — risposte del designer

1. **Il sesto hook.** *"aggiungi il sesto hook se serve"* → `on_acquire` resta
   nello schema; lo useranno i 15 «Subito:» dei personaggi.
2. **`flavour_text` o `effect_text`?** *"usa quello che sembra meglio"* →
   **nessun campo nuovo.** La distinzione è già interamente portata dalla
   presenza o assenza di `effects`: se una carta non ha `effects`, non c'è nulla
   da implementare. Un secondo campo di testo significherebbe due campi da
   tenere allineati e un ramo di schema in più per tre carte.
3. **Le righe che ribadiscono campi esistenti.** *"se sono doppioni le
   togliamo"* → rimosse 16 righe di `effect_text` sugli edifici, tutte
   verificate come ricavabili dai campi strutturati prima di toccarle
   (`production`, `level_required`, `exhaustible`). Restano 33 edifici con
   `effect_text`.
4. **I Monumenti sono una corsa.** *"si reclamano quando la condizione è
   soddisfatta"* → confermato. Servono la valutazione continua e i contatori
   storici.
5. **L'ordine di lavoro.** *"procedi come hai deciso"* → eventi (fatti) →
   personaggi → edifici → potenziamenti → Monumenti ed Eredità.

## 6bis. Le decisioni originali, per riferimento

1. **Il sesto hook.** `on_acquire` non è nell'elenco del brief ma serve ai 15
   «Subito:». Lo aggiungiamo, o li modelliamo diversamente?
2. **I tre testi di colore** diventano `flavour_text`, o resta tutto in
   `effect_text`?
3. **Le 15 righe che ribadiscono campi esistenti**: le lasciamo come testo per il
   giocatore (e non le implementiamo), o le togliamo per evitare che qualcuno un
   domani le implementi due volte?
4. **I Monumenti sono una corsa.** Confermi che «Primo a…» si assegna nell'istante
   in cui la condizione è soddisfatta, e non a fine partita? Cambia
   l'architettura: servono contatori storici e una valutazione continua.
5. **L'ordine di lavoro.** Il brief dice eventi → personaggi → edifici →
   potenziamenti → Monumenti/Eredità. Confermi, o preferisci che parta dai
   Monumenti perché sono quelli che richiedono l'infrastruttura più invasiva?
