# res://scripts/core/player_state.gd
class_name PlayerState
extends RefCounted

var index: int
var name: String = ""
var pietra: int = 0
var oro: int = 0
var workers: int = 3
var workers_used: int = 0
var has_dynasty: bool = false
var buildings_built: int = 0
var vp: int = 0                        # punti già segnati durante la partita
var vp_breakdown: Dictionary = {}      # canale -> punti (per il riepilogo finale)
var legacy_id: String = ""             # Eredità segreta tenuta
var monuments_claimed: Array = []
var specialized_character: String = "" # personaggio attivo per l'era corrente
var specialized_era: int = 0

func _init(i: int) -> void:
	index = i

func can_pay(p: int, o: int) -> bool:
	return pietra >= p and oro >= o

func pay(p: int, o: int) -> void:
	assert(can_pay(p, o), "Pagamento non coperto")
	pietra -= p
	oro -= o

func gain(p: int, o: int) -> void:
	pietra += p
	oro += o

func add_vp(channel: String, amount: int) -> void:
	vp += amount
	vp_breakdown[channel] = vp_breakdown.get(channel, 0) + amount

func total_resources() -> int:
	return pietra + oro
