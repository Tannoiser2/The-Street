# res://scripts/core/building.gd
# Istanza di un edificio in gioco. I dati statici stanno in `data` (dal CardDB).
class_name Building
extends RefCounted

var uid: int
var data: Dictionary          # riga di cards.json (buildings)
var owner: int
var era_built: int            # era in cui è stato costruito (= binario se livello 0)
var col_from: int             # prima colonna occupata (inclusa)
var col_to: int               # ultima colonna occupata (esclusa)
var level: int = 0            # 0 = nel binario; >0 = sopraelevato
var state: int = Enums.BuildingState.INTATTO
var is_buried: bool = false   # condizione di posizione: qualcosa è stato costruito sopra
var was_razed: bool = false   # spianato dal proprietario da intatto -> Scavo 0
# Le colonne in cui, per poggiare qui, e' stata riportata terra: sotto non
# c'era niente e si e' pagato un terrapieno. Serve alla vista per riempire
# il vuoto sotto l'edificio, che altrimenti resta sospeso.
var terrapieno_cols: Array[int] = []
var bonus_res: int = 0        # cubetti neri: collina, continuità, potenziamenti Struttura
var bonus_scavo: int = 0      # Impronte e potenziamenti che alzano lo Scavo
var bonus_rendita: int = 0    # Stalli mercantili: "l'affitto incassato da questo edificio e' +1"
var vetusta: int = 0          # cubetti bianchi: +1 per evento superato
var protection: int = 0       # +2 per lavoratore piazzato; si azzera a fine era
var protected_by: int = -1    # giocatore il cui lavoratore lo abita; -1 = nessuno
var upgrades: Array = []      # id dei potenziamenti infilati sotto
# Artista di corte: chi ha infilato una carta sotto un edificio ALTRUI incassa
# da quell'edificio per il resto della partita. Indice giocatore -> oro per
# attivazione. Sta sull'edificio e non sul personaggio perche' il personaggio
# dura un'era mentre questo incasso dura la partita.
var patrons: Dictionary = {}
var extra_classes: Array[String] = []  # classi acquisite (po_merlatura: "conta anche come Militare")
var imprint: String = ""      # Impronta infilata sotto: "un edificio puo' portarne una sola"
var buried_character: String = ""   # personaggio sepolto qui (meccanica Scheletri)
var buried_character_era: int = 0
var charges: int = 0          # cubetti carica per edifici Esauribili

func width() -> int:
	return col_to - col_from

func covers(col: int) -> bool:
	return col >= col_from and col < col_to

func is_standing() -> bool:
	return not is_buried and state != Enums.BuildingState.ROVINA

func is_alive() -> bool:
	return not is_buried and state == Enums.BuildingState.INTATTO

# Le classi effettive: quelle stampate piu' quelle acquisite. Restituisce una
# copia quando ce ne sono di acquisite, per non esporre l'array della carta -
# che e' condiviso da tutte le istanze di quell'edificio.
func classes() -> Array:
	if extra_classes.is_empty(): return data["classes"]
	var out: Array = (data["classes"] as Array).duplicate()
	for c in extra_classes:
		if not c in out: out.append(c)
	return out

func shares_class_with(other_data: Dictionary) -> bool:
	for c in classes():
		if c in other_data["classes"]: return true
	return false

func effective_resistance() -> int:
	var r: int = int(data["resistance"]) + bonus_res + protection
	if state == Enums.BuildingState.RUDERE:
		r -= int(CardDB.constants["rudere_penalty"])
	return r

func scavo_value() -> int:
	if was_razed: return 0
	return int(data["scavo"]) + bonus_scavo

# La Rendita effettiva: quella stampata piu' i potenziamenti che la alzano.
func rendita_value() -> int:
	return int(data["rendita"]) + bonus_rendita
