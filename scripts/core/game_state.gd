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
var next_uid: int = 1
var log: Array = []                # traccia testuale degli eventi (utile per i test)

func current_player() -> PlayerState:
	return players[current_index]

func log_line(s: String) -> void:
	log.append("[E%d] %s" % [era, s])

func new_uid() -> int:
	next_uid += 1
	return next_uid - 1
