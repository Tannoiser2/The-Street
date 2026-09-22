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
var turn_pos: int = 0
var current_event: Dictionary = {}
var market: Array = []             # id edifici visibili
var building_decks: Dictionary = {}# era -> Array di id
var char_row: Array = []
var upg_row: Array = []
var monuments_open: Array = []
var next_uid: int = 1
var log: Array = []                # traccia testuale degli eventi (utile per i test)

func current_player() -> PlayerState:
	return players[turn_order[turn_pos]]

func log_line(s: String) -> void:
	log.append("[E%d] %s" % [era, s])

func new_uid() -> int:
	next_uid += 1
	return next_uid - 1
