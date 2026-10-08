# Passaggio alla sessione nuova: lo stato della v2 e l'idea della v3

Stato al **1 ottobre 2026**. Questo documento si legge **dopo** `docs/passaggio-di-consegne.md`,
che resta valido per il modo di lavorare con il designer, i vincoli e gli strumenti. Qui c'è
quello che è cambiato da allora e la nuova direzione che il designer vuole prendere.

## Le regole di sempre, in breve

- Si risponde **sempre in italiano**, anche nei riepiloghi lunghi: due volte la risposta è
  scappata in inglese e il designer se n'è accorto subito.
- Le regole sono del designer: si misura, si propone con una raccomandazione, si chiede. Le PR si
  aprono **in bozza** e si mergiano solo quando lui scrive "mergia" (merge commit, con lo SHA
  atteso). Dopo il merge si controlla che la build di GitHub Pages (`pages.yml`) sia andata: il
  designer gioca la pagina web, spesso su iPad.
- `data/cards.json` (v1.5) non cambia comportamento: `tools/verifica_riferimento.sh` deve dire
  "TORNEO: identico" e "VITA: identica" prima di ogni push che tocca motore o bot.
- `data/cards-v2.json` e `data/proposte/*.json` si generano con `tools/genera_cards_v2.py`
  (poi `tools/carte_v2.py` e `tools/stampa_carte_v2.py`); mai a mano.
- I PDF in `materiali/` servono solo per la grafica, mai per i dati.
- Le regole non cambiano col numero di giocatori.
- Ogni decisione va nel registro `docs/domande-aperte.md`; ogni misura in
  `docs/la-terza-risorsa.md`, con i numeri e i comandi per rifarla.

## L'ambiente (cose imparate a fatica)

- **Godot 4.7** non è installato: si scarica come fa `pages.yml`
  (`Godot_v4.7-stable_linux.x86_64.zip` dalle release di godotengine). I test: le scene
  `test_actions`, `test_effects`, `test_schema_validator`, `test_view`
  (`godot --headless res://scenes/<scena>.tscn`). Dopo un `class_name` nuovo:
  `godot --headless --editor --quit`. La grafica (`assets/`) non è versionata: si estrae con
  `python3 tools/estrai_grafica.py` (serve pymupdf); senza, alcuni test della vista falliscono.
- **Un errore di parsing GDScript fa restare appesa la scena headless senza messaggio**: sempre
  con `timeout`, e si cerca `SCRIPT ERROR` / `Parse Error` nell'output. Le variabili prese da
  Array/Dictionary vanno tipizzate (`var x: int = ...`), e non si scrive `for ...: if ...:` su una
  riga.
- **Il container si riavvia spesso** (ogni 30-60 minuti in questa sessione) e uccide i processi
  lanciati. Le misure lunghe si lanciano con `setsid nohup ... &` e si riprendono con
  `--da N --games G`: attenzione, `--da N` parte dalla partita N e ne gioca **G** (non fino a G).
  Le partite fatte sono le righe `J ` nello stderr.
- Non usare `pkill -f` o `pgrep -f` con un testo che compare nel proprio comando: uccide la
  shell, anche col trucco `[G]odot` se il comando contiene altrove il testo cercato (il nome di
  una scena in un heredoc). Si uccide per PID, cercato in un comando a parte.
- Le misure: `audit_partita.tscn -- --games N --seed 700000 --players N --giro tutte
  --dati <file> --rapporto 1`; ogni partita è una riga `J {json}` nello stderr con canali di PV,
  contatori (`cnt`) e lo stato finale degli edifici.

## Cosa è su main con la PR #73 (4 ottobre 2026): la v3 di prova

Tutto acceso dalla costante `turno_v3` del file `data/proposte/cards-v3-era1.json` (generato da
`tools/genera_cards_v3.py`, mai a mano); la v1.5 e la v2 non cambiano. In breve (registri 153-175,
misure 31-48): draft a passaggio (mano di 4, se ne tiene una), i Personaggi sono i lavoratori e
hanno produzione e azione, ogni edificio ha un'azione, le risorse muoiono a fine era (ere 1-4),
catena di costi (terreni a zero, spianare caro, non si spiana la stessa era), potenziamento insieme
alla costruzione, acquisto extra ⊕ solo da carta e con lo sconto dentro, sconti senza condizione su
dieci carte, le cinque carte grandi "a terra oppure sopra", il Lampo del mazzo pari al costo, e la
regola "stile Caylus": chi attiva una colonna usa UN edificio fra quelli in piedi, suo o altrui, e
lo brucia fino a fine giro. Il bot (`SPINTE_V3`, sette strategie con la Ritrovamenti) sceglie
Personaggio, colonna ed edificio sulla copia della partita. Le misure: `--fino_era N`, le
fotografie di fine era con le entrate per fonte, `tools/misura_era.py --era N`.

## Cosa era su main prima (fino alla PR #69)

Registri 140-147, in breve:
- 140 menu e riepilogo ingranditi (lente); 141 posto del giocatore in due colonne;
- 142 via la Prosperità Urbana; cubetti neri solo per la resistenza senza gettone;
- 143 il Lampo è un flusso di tutti (Lampo 2 nell'era 4 non aiutava la strategia Lampo);
- 144-145 riepilogo con i giocatori in colonna, i PV divisi per fonte, PV in gioco e PV di fine
  partita separati; blocchi della v2 a 9 mm;
- 146 tasti "Attiva e incassa", "Annulla la scelta", "Fine turno"; la cronaca del turno sotto la
  barra (`scripts/view/cronaca.gd`);
- 147 lo spianato con le tessere (poi superato dal 151, vedi sotto).

## Cosa è aperto

Le PR #70 e #71 (evento finale, gilde dell'era 5, regole semplici dello scavo, varianti
`scavo_due`, `tessere_doppie`, `spianare_caro`, `strada_corta`, contatori per era) sono state
mergiate il 1° ottobre: sono la base da cui la v3 è partita. Con la PR #73 (4 ottobre) la v3 di
prova è su main; quel che resta è nei "Prossimi passi" dello stato qui sotto.

I numeri chiave della v2 prima della v3 (3 giocatori, regole semplici + evento finale + gilde):
Scavo 7 PV a testa (bonus 2,6 + riscoperta 4,7), Lampo 16,5, Rendita 13,5, Continuità 17,9;
si spianano 21 edifici propri a partita, si riscoprono solo ~5 rovine.

## La produzione oggi (la base per la v3)

Risorse prodotte a giocatore per era, regole di main, 3 giocatori (fra parentesi quelle ancora
in mano a fine era, prima della dispersione):

| era | Costruzione | Denaro | Idee |
|---|---|---|---|
| 1 | 5,6 (3,9) | 2,0 (2,1) | 1,7 (0,5) |
| 2 | 8,1 (6,1) | 2,6 (4,3) | 2,7 (1,0) |
| 3 | 4,2 (2,2) | 3,5 (3,8) | 2,7 (3,1) |
| 4 | 2,9 (2,5) | 5,3 (5,7) | 4,5 (2,6) |
| 5 | 2,5 (2,3) | 6,7 (6,5) | 4,4 (3,7) |

Fonti in tutta la partita: terreno 9,8 / 6,7 / 6,2; tessera dell'era 5,6 / 4,6 / 8,9; edifici
5,7 / 6,5 / 0,2; Personaggi 1,7 / 2,4 / 0,4. A fine partita si buttano ~12 risorse a testa.

## La v3: l'idea del designer (1 ottobre 2026, parole sue)

> Troppe risorse vanno sprecate e riconvertirle in idee non è la soluzione. Le risorse nascono e
> muoiono nell'era, non si portano appresso tra le ere. Quindi bisogna renderle fruibili durante
> l'era. Quando si scelgono i personaggi si fa un draft delle carte: ogni giocatore prende 4
> personaggi, ne prende uno e quelli rimasti li passa al giocatore alla sua destra, e si ripete
> finché tutti hanno scelto tre personaggi, più quello che rimane alla fine. Questi saranno i
> personaggi dell'era (quindi dovrebbero essere almeno 16 per era, totale 16×5). Questi hanno
> produzione e azione speciale quando verranno utilizzati come lavoratori durante l'era (non ci
> sono più lavoratori non specializzati). Ogni edificio fa anche produzione e azione speciale.
> Quindi quando un personaggio viene messo su una colonna, attiva gli edifici per ogni giocatore
> + produzione ed effetto della colonna + produzione ed effetto del personaggio. Questo dovrebbe
> portare a una sorta di micromondo che comprende produzione, PV ecc. solo per quell'era. I
> personaggi poi hanno la possibilità di essere ripescati come scheletri.

### Il parere dato al designer (da riprendere)

Punti di forza:
- **Risorse che muoiono a fine era** chiudono il problema dello spreco alla radice: niente
  dispersione, niente conversione in Idee, niente avanzi nell'era 5. Ogni era diventa un
  problema di economia chiuso, da pianificare.
- **Il draft a passaggio** (alla 7 Wonders) dà interazione vera già prima di giocare: si sceglie
  per sé e si toglie agli altri.
- **I lavoratori sono i Personaggi**: ogni piazzamento è una scelta (quale personaggio, su quale
  colonna), non più "un lavoratore qualunque". Lega i Personaggi agli scheletri delle tessere
  rovina, che già portano l'era.

Cose da decidere o da tenere d'occhio:
1. **Quante carte**: 4 a testa vuol dire 8/12/16 personaggi per era a 2/3/4 giocatori. Per non
   cambiare le regole col numero di giocatori: si mescolano i 16 dell'era e se ne danno 4 a
   testa, gli altri fuori. A 2 giocatori il draft gira poco (2 scelte vere): valutare.
2. **"Tre scelti più quello che rimane"**: con 4 carte in mano si sceglie, si passa, si sceglie,
   si passa, si sceglie, e l'ultima arriva da sola. Va confermato che l'ultima è un lavoratore
   come le altre (4 lavoratori a testa, come oggi). La Dinastia (quinto lavoratore) va ripensata.
3. **Direzione del passaggio**: sempre a destra, o alternata per era come in 7 Wonders.
4. **Il ciclo dell'attivazione** diventa ricco: produzione ed effetto della colonna (tessera
   dell'era), poi di **ogni edificio** in piedi nella colonna (di tutti i giocatori), poi del
   Personaggio. Gli effetti devono essere brevi e iconografici, o il turno si allunga molto.
   Chiarire se l'azione speciale degli edifici scatta per il proprietario o per chi attiva.
5. **Che cosa resta tra un'era e l'altra**: solo PV, edifici sulla mappa, rovine, token
   riscattati e i Personaggi presi (per gli scheletri). Lampo e Rendita restano i flussi in PV.
6. **Lavoro sulle carte**: 80 Personaggi (16 × 5) con produzione + azione; tutti i 74 edifici
   con produzione + azione speciale. È il grosso del lavoro, e va fatto con il generatore (le
   carte di oggi non hanno questi campi).
7. **Lato codice**: il turno cambia (piazzare un Personaggio invece di un lavoratore), il draft
   diventa a passaggio (oggi è "uno a testa in ordine di turno fra tutti quelli dell'era"),
   le risorse si azzerano a fine era (al posto di `disperse`), l'attivazione legge la produzione
   del Personaggio. I bot vanno riadattati. Conviene una costante nuova (es. `turno_v3`) nel
   file dati, come si è fatto per la v2, così la v1.5 e la v2 restano giocabili e misurabili.

Prima mossa proposta per la sessione nuova: scrivere con il designer la scheda di **un'era di
prova** (16 Personaggi con produzione e azione, gli edifici di quell'era con produzione e
azione), simularla e guardare la tabella della produzione per giro, prima di toccare tutte le
cinque ere.


## Stato al 3 ottobre 2026 (ramo `claude/v3-era-1`, PR #73 in bozza)

La v3 e' nel codice, accesa dalla costante `turno_v3` del file dati (`data/proposte/cards-v3-era1.json`,
generato da `tools/genera_cards_v3.py` dalla v2; la v1.5 e la v2 non cambiano, `verifica_riferimento`
identico). Le cinque ere sono scritte (registri 153-163, misure dalla trentunesima alla trentasettesima): le ere
1 e 2 misurate e nel metro, le ere 3-5 in prima stesura da uno stampo, misurate una volta sulla partita
intera e da ritarare. I documenti di lavoro: `docs/proposte/v3-metro.md` (il metro), `v3-era-1.md`,
`v3-era-2.md`, `v3-ere-3-5.md`.

Le regole decise dal designer lungo la strada, tutte nel file base: risorse che muoiono a fine era,
draft a passaggio alternato, Personaggi lavoratori con produzione e azione, azioni degli edifici al
proprietario, terreno di base che non produce, spianare caro e mai nella stessa era, costi con la
regola "l'edificio chiede la risorsa che i suoi potenziamenti non chiedono", una casa sempre
comprabile (Ripari, Tuguri a costo flessibile), potenziamento insieme alla costruzione e nelle
colonne adiacenti, acquisto extra solo dall'azione ⊕ di una carta, sconti per classe e per
potenziamento, bot che sa che le risorse muoiono e che tiene le risorse per comprare meglio.

Come si misura: `--fino_era N` nell'audit, `--rapporto 1`, poi `python3 tools/misura_era.py e.err --era N`
(dall'era 2 l'era e' la differenza fra le fotografie di fine era). 300 partite a 3 giocatori, seme 700000,
`--giro tutte`; ogni lotto fino all'era 2 dura circa 12 minuti su questo container.

Prossimi passi: il morto e' 2,0-2,2 in tutte le ere (registro 167: Lampo pari al costo, Fondaco e
Periferia in Costruzione), il budget del metro (1-2) e' a un passo; le vittorie stanno fra 29
(Scavo) e 38 (Obiettivi) dopo `lampo_zero` a zero nella tabella `SPINTE_V3` (registro 168); la
Scavo e' ora la piu' debole; il ⊕ si apre 2,1 volte a partita a giocatore e si usa 0,8 (39%), la finestra dopo la costruzione
12,2 e 2,0 (16%): da rendere piu' utile prima di metterlo su altre carte (registro 169); gli sconti
sugli edifici (varianti `sconti_edifici`, `scelta_sconti`) non muovono nulla ne' per il padrone ne'
con la "scelta" (quarantatreesima e quarantacinquesima): sette carte condizionate sono poche, servono
su piu' carte e senza condizione, o dentro il ⊕; la "scelta" stile Caylus (registri 170-171) e' il file base dalla quarantaquattresima misura
(`--variante proprietario` rifa' la regola di prima), con gli sconti senza condizione su dieci carte
e il ⊕ con lo sconto (quarantaseiesima, `--variante senza_sconti` li toglie); la tabella `SPINTE_V3`
ritarata (quarantasettesima: Rendita 1,3, Scavo 0,8/0,5; quarantottesima: la Ritrovamenti,
settima strategia del canone v3, al 33%; `obiettivi_peso` 0,8), vittorie fra 26 (Scavo) e 42
(Obiettivi) nel torneo a sette, rimisurate col bot corretto (quarantanovesima, registro 177);
le carte ancora rare
(la Stazione per le tre colonne; Conceria, Arsenale, Ponte in acciaio); il ⊕ ancora ultimo al draft
anche con lo sconto dentro. L'interfaccia a schermo conosce la v3 (registro 176: il tasto "v3" nella
schermata d'inizio, il Personaggio da piazzare, la domanda "quale edificio usi?"); il tavolo 3D non
segna gli edifici gia' usati nel giro, lo dice solo il riquadro. La strategia Ritrovamenti e' nei bot
(registro 173). Le cinque carte grandi vanno "a terra oppure sopra" (`a_terra_o_sopra`). Il Grattacielo
libero (livello 1, terreno qualunque, cinquantesima misura) non si costruisce di piu' (85 su 300 prima e
dopo): il freno e' il costo, non il terreno. Lo spianamento parziale (registro 180, `spianato:
"parziale"`): le caselle coperte dalla carta nuova sono terrapieno, quelle libere restano rovina con la
tessera; `--variante spianato_intero` rifa' lo spianato di prima; cinquantunesima misura: +3,5 PV a testa
tutti nel canale Scavo (11,2 -> 14,7), vittorie 23 (Lampo) - 42 (Continuita'), la Scavo risale a 31.
Il bot pesa i finali delle carte (registro 181, `finali_peso`); l'Universita' conta i Personaggi con
Scavo 5+ (182, valeva +20 fissi); il Grattacielo costa 2 Costruzione 1 Idea (183) e si costruisce
piu' spesso in alto che a terra. La tabella per giocatori della v2 copriva quattro voci di `SPINTE_V3`
(185): le misure 49-54 "da tabella" giocavano `lampo` 1,2, `obiettivi_peso` 1,5, `rendita_zero` 0,
`scavo_premio` 0; ora la tabella scritta e' quella che gioca e porta quei valori col `lampo` a 0,8
(186). La Ritrovamenti (187): Museo max 6 e Universita' max 5 (i due finali senza tetto rendevano 6,9 e 7,4 PV
a costruzione), `ritro_scheletro` 0; l'audit rende il finale carta per carta (`finale` nella riga J).
Gli scheletri sono i Personaggi (188, `scheletri: "personaggi"`, il designer "tienila"): una tessera per
Personaggio nel sacchetto dei reclutati, pescata al crollo, che riportata alla luce paga il suo Scavo a chi
ha quel Personaggio; il padrone della rovina non incassa dalle tessere. Spianare e costruire sopra non
cambiano (57ª); +3 PV a testa nel canale Scavo (16,9); Scavo e Ritrovamenti da ritarare (189). Scavo e
Ritrovamenti ritarate al draft (189: `scavo_scheletro` 0,6, `ritro_scheletro` 0,15). Base attuale (58ª):
vittorie 30-37, 82,4 PV, la forbice piu' stretta misurata. Varianti misurate e lasciate al designer (190):
`tutto_in_vendita` (+3,5 PV, forbice 22-42) ed `evento_coperto` (quasi nulla cambia nel simulatore). Nell'audit `--schermo` rigioca il seme visto a schermo e `--perche` stampa la vetrina. La vista 3D col sacchetto (191): un sacchetto solo in cima alla fila dei Personaggi, e i Personaggi del
giocatore a ventaglio su piu' colonne. Il seme 925 (192): le Trappole da pesca da 1 vivevano cinque ere per
soffio, Argine e Personaggio in colonna (+2). Da li' il soffio non vale per la resistenza stampata 1 (193,
`soffio_resistenza_min` 2, 61ª: nessun resistenza-1 arriva alla fine, Scavo 17,4, la Rendita scende al 27,
forbice 27-37; `--variante soffio_per_tutti`). A fine era i Personaggi si girano col dorso e a fine partita si
rigirano solo quelli riportati alla luce (194; il dorso disegnato va in `assets/carte/dorsi/personaggio_scheletro.png`).
La Vetusta' nella v3 e' a 0 (195): la manopola resta solo per la v1.5. Anche l'era 5 ha sei eventi (196: Subsidenza, Globalizzazione, Crisi energetica, Innalzamento dei mari,
Crisi dello Stato, Guerra mondiale; `--variante giudizio_solo` per il Giudizio del tempo di prima). Il bot legge la
forza dell'evento dalla carta e da `event_force_by_era` invece di `era + 1` (197, vale un punto a testa e rimette la
Rendita al 34). I sei eventi sono a forza 3 come l'era 4 (198, 64ª: 83,6 PV, un edificio dell'era 5 su sette in rovina,
forbice 30-40; a forza 4 ne crollava meta', `--variante eventi5_forza4`). Via il soffio (199, "o dentro o fuori"): `rovina_gap` 1, resistenza sotto la forza = crolla, forze 2, 2, 3, 2, 2
(-1 dove il soffio attutiva, l'era 1 resta a 2 per la resistenza 1); `--variante soffio` rifa' il conto di prima; misura
65 le due alternative pulite, 66 la conferma: 83,3 PV, canali al decimo come la 64ª, vittorie 25-41 (Continuita' 41,
Rendita 25) perche' il bot ora legge forze esatte; da ritarare le spinte, non la regola. IL TEMPO LOGORA (200-202, PR #87, varianti in `data/proposte/`, base intatta): scala 1-10 delle resistenze,
erosione a fine era 2/1/0 (`EraRules.erosione`), eventi lievi 3-3-4-4-5 e gravi +2, eventi di classe con `bersaglio`
(colpiscono solo le classi che nominano), `spolia_divisore` 4, `scavo_tessera_fattore` 0,5. Misure 67-69: con le forze
ripide crollava tre quarti dell'era Moderna; coi bersagli di classe l'era Moderna torna intera e la preistoria resta ai
megaliti (Dolmen 76%, Capanne 0%); con la tessera a meta' lo Scavo torna a 16 e la forbice a 24-38. Decisione del
designer se farne la base; dopo: ristrutturazione che ridà resistenza, bot sulle tessere e sulla Continuita', schema
dati (resistenza max 6 -> 10), carte. L'alternativa prudente (203, misura 70) e' la base (204): i dieci eventi di classe
colpiscono solo le classi che nominano, con +1 di forza e senza malus; 82,8 PV, Scavo 16,8, crolli per era come la 66ª;
`--variante senza_bersagli` per la base di prima.
