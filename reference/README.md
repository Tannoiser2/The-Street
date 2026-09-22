# Materiale di riferimento

## `regolamento-completo.html`
Il regolamento v1.5 nella forma leggibile. **È la specifica.** In caso di dubbio fra codice e regolamento, vince il regolamento; se il regolamento è ambiguo, va chiarito col designer prima di scegliere un'interpretazione.

## `simulatore_riferimento.py`
Il motore Python usato per circa 80.000 partite simulate durante il bilanciamento. È un'implementazione **completa e funzionante** del modello a griglia: binari e colonne, quattro stati, sopraelevazione, terrapieno, spolia, cap verticale per era, eventi, censimento, dispersione, Prosperità urbana, scheletri, punteggio.

**Va usato come oracolo, non come codice da copiare.** È cresciuto per aggiunta di flag sperimentali durante quindici round di audit, e ne porta i segni: molte varianti attivabili da riga di comando, nomi di variabili ereditati da versioni precedenti del gioco, parti morte.

### Come usarlo come oracolo
L'obiettivo è che la stessa partita, con lo stesso seme e le stesse mosse, produca lo stesso punteggio in Python e in Godot. Quando divergono, uno dei due ha un bug: quasi sempre è utile a scoprire casi limite della regola che nessuno aveva scritto.

### Limiti noti — importanti
1. **Il peso delle risorse nell'euristica di piazzamento** era sbilanciato (oro 1,2 contro pietra 0,8) e ha falsato per molti round la misura della dominanza del fiume. Nella versione allegata è parametrico (`W_P`, `W_O`). Nessun peso fisso rappresenta bene un giocatore umano.
2. **Il reclutamento** è modellato con una formula approssimativa del valore del personaggio, non con le 25 abilità reali. Le misure che dipendono dal reclutamento non sono affidabili.
3. **La Dinastia** non è implementata con il costo a scalare della v1.4.1.
4. **Gli effetti delle singole carte** (edifici, personaggi, potenziamenti, eventi gravi) sono gestiti solo nei pattern più comuni. Gli altri sono ignorati.
5. **Monumenti ed Eredità** non sono verificati carta per carta.

In sintesi: il simulatore misura bene ciò che dipende dalla **struttura** (geometria, crolli, altezze, economia di base) e male ciò che dipende dalle **scelte** e dagli **effetti specifici**. Le stesse avvertenze valgono per i bot che ne deriveranno in Godot.

## File legacy
`cards_simulatore_legacy.json`, `listino117.json`, `costiA.json` servono solo a far girare il simulatore. **Non sono la fonte dei dati**: quella è `data/cards.json`.
