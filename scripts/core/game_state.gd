# res://scripts/core/game_state.gd
# Stato completo e serializzabile di una partita. Nessuna logica di regole qui:
# le regole vivono in scripts/rules/. Lo stato è deterministico dato un seme.
class_name GameState
extends RefCounted

var rng := RandomNumberGenerator.new()
var n_players: int
var players: Array = []            # PlayerState
var grid: Grid
var era: int = 1
var phase: int = Enums.Phase.PIAZZA
var turn_order: Array = []         # indici dei giocatori per l'era corrente
var turn_pos: int = 0               # posizione nel giro normale
var current_index: int = -1         # giocatore di turno (puo' non seguire turn_pos: snake)
var current_event: Dictionary = {}
var market: Array = []             # id edifici visibili
# LA RISERVA (registro 116): le case dell'era, sempre disponibili, con le loro
# copie (un id per copia). Non stanno nel mazzo: si comprano come dal mercato
# e a fine era si scartano con le file.
var riserva: Array = []
var building_decks: Dictionary = {}# era -> Array di id
var char_decks: Dictionary = {}    # era -> Array di id
var upg_decks: Dictionary = {}     # era -> Array di id
var char_row: Array = []
var upg_row: Array = []
var dynasties_left: int = 0        # copie di Dinastia ancora acquistabili
# Sequenza esplicita dei turni dell'era, quando non e' un semplice giro
# (serve allo snake dell'Era 1 in due giocatori). Vuota = giro normale.
var turn_sequence: Array[int] = []
var monuments_open: Array = []
# Una scelta che il gioco aspetta dal giocatore prima di proseguire: per ora
# solo il bersaglio del potenziamento omaggio dell'Eruzione, che cade DENTRO
# la fine dell'era. Finche' e' piena, nessun comando passa.
# {"player": int, "kind": String, "prompt": String, "options": Array[int]}
var pending_choice: Dictionary = {}
# IL DRAFT DEI PERSONAGGI (v2, registro 93): a inizio era, in ordine di turno,
# ogni giocatore ne prende uno gratis e senza lavoratore. Chi deve ancora
# scegliere sta qui, in ordine; vuoto = il draft e' finito o non c'e'.
var draft_pending: Array[int] = []
# LE TESSERE USATE NELL'ERA (v2, registro 100): l'effetto di ogni tessera vale
# una volta per era; qui, colonna per colonna, se e' gia' scattato.
var tessere_usate: Array[bool] = []
var next_uid: int = 1
# LA COLONNA ATTIVATA IN QUESTO TURNO e l'edificio che il lavoratore abita.
# Stavano nel controller, e sembravano dettagli del comando; invece decidono
# cosa e' legale - si costruisce solo nella colonna attivata o accanto, si
# potenzia e si restaura solo li' - quindi sono stato della partita. Una copia
# presa a meta' turno che non li portava con se' non sapeva piu' dove si
# poteva costruire, e ogni costruzione simulata falliva in silenzio.
# L'edificio e' tenuto per uid, non per riferimento: un riferimento copiato
# punterebbe all'edificio dell'ORIGINALE, e toccarlo dalla copia sporcherebbe
# la partita vera.
var colonna_attivata: int = -1
var protetto_uid: int = -1
var log: Array = []                # traccia testuale degli eventi (utile per i test)

# UNA COPIA DELLA PARTITA SU CUI PROVARE. Chi vuole sapere "cosa succede se"
# copia, gioca sulla copia col codice vero e guarda com'e' andata: e' l'unico
# modo di simulare senza riscrivere le regole una seconda volta - due ricette
# della stessa regola divergono, e la seconda nessuno la prova.
# Le CARTE non si copiano: `current_event` e il `data` degli edifici sono righe
# di cards.json, condivise da tutti e mai modificate dal gioco.
func duplica() -> GameState:
	var g := GameState.new()
	g.rng = RandomNumberGenerator.new()
	g.rng.seed = rng.seed
	g.rng.state = rng.state
	g.n_players = n_players
	for p in players:
		g.players.append(p.duplica())
	g.grid = grid.duplica()
	g.era = era
	g.phase = phase
	g.turn_order = turn_order.duplicate()
	g.turn_pos = turn_pos
	g.current_index = current_index
	g.current_event = current_event          # carta, condivisa
	g.market = market.duplicate()
	g.riserva = riserva.duplicate()
	g.building_decks = building_decks.duplicate(true)
	g.char_decks = char_decks.duplicate(true)
	g.upg_decks = upg_decks.duplicate(true)
	g.char_row = char_row.duplicate()
	g.upg_row = upg_row.duplicate()
	g.dynasties_left = dynasties_left
	g.turn_sequence = turn_sequence.duplicate()
	g.monuments_open = monuments_open.duplicate()
	g.pending_choice = pending_choice.duplicate(true)
	g.draft_pending = draft_pending.duplicate()
	g.tessere_usate = tessere_usate.duplicate()
	g.next_uid = next_uid
	g.colonna_attivata = colonna_attivata
	g.protetto_uid = protetto_uid
	g.log = log.duplicate()
	return g

func current_player() -> PlayerState:
	return players[current_index]

func log_line(s: String) -> void:
	log.append("[E%d] %s" % [era, s])

func new_uid() -> int:
	next_uid += 1
	return next_uid - 1

# Quello che si puo' costruire adesso: il mercato e la riserva delle case.
# E' l'unica lista che bot, azioni e vista devono guardare.
func in_vendita() -> Array:
	var out := market.duplicate()
	out.append_array(riserva)
	return out
