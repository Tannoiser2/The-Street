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
# Personaggi reclutati in quest'era, uno per lavoratore specializzato.
# Il regolamento non limita i reclutamenti a uno per era, e la sepoltura dice
# "uno solo per edificio": quindi possono essercene piu' d'uno.
var specialized_characters: Array[String] = []
# Colonne dove hai gia' un lavoratore: "al massimo un vostro lavoratore per colonna".
var worker_cols: Array[int] = []
# "Il primo terrapieno di ogni giocatore in quest'era costa 0" (ev_bonifiche).
var terrapieno_free_used: bool = false
# Personaggi reclutati in tutta la partita: non si azzera a fine era.
# Serve all'Universita' ("+1 PV per ogni tuo personaggio reclutato").
var recruited_total: int = 0
# Personaggi che devono arrivare al conteggio finale. I loro "Finale:" si
# pagano dopo che l'era e' chiusa, quindi non possono stare in
# specialized_characters, che l'era azzera. Vedi domande-aperte punto 26.
var final_characters: Array[String] = []
# Quanto ha gia' reso un effetto in quest'era, per carta. Serve ai tetti
# ("max 2") e ai conteggi ("le tue prime 2 produzioni").
var effect_used: Dictionary = {}
# personaggio -> uid dell'edificio protetto dal lavoratore che lo ha reclutato.
# Serve al Legionario e al Cavaliere ("se l'edificio protetto sopravvive").
var character_targets: Dictionary = {}
# Contatori storici per Monumenti ed Eredita': pietra spesa in terrapieni,
# ruderi restaurati, potenziamenti piazzati. Non si azzerano a fine era,
# perche' non sono ricavabili dalla plancia finale.
var counters: Dictionary = {}

# Una copia su cui provare: vedi Building.duplica.
func duplica() -> PlayerState:
	var p := PlayerState.new(index)
	p.name = name
	p.pietra = pietra
	p.oro = oro
	p.workers = workers
	p.workers_used = workers_used
	p.has_dynasty = has_dynasty
	p.buildings_built = buildings_built
	p.vp = vp
	p.vp_breakdown = vp_breakdown.duplicate(true)
	p.legacy_id = legacy_id
	p.monuments_claimed = monuments_claimed.duplicate()
	p.specialized_characters = specialized_characters.duplicate()
	p.worker_cols = worker_cols.duplicate()
	p.terrapieno_free_used = terrapieno_free_used
	p.recruited_total = recruited_total
	p.final_characters = final_characters.duplicate()
	p.effect_used = effect_used.duplicate(true)
	p.character_targets = character_targets.duplicate(true)
	p.counters = counters.duplicate(true)
	return p

func bump(nome: String, quanto: int = 1) -> void:
	counters[nome] = int(counters.get(nome, 0)) + quanto

func reset_for_era() -> void:
	workers_used = 0
	specialized_characters.clear()
	worker_cols.clear()
	terrapieno_free_used = false
	effect_used.clear()
	character_targets.clear()

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
