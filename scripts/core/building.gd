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
var bonus_res: int = 0        # cubetti neri: collina, continuità, potenziamenti Struttura
var bonus_scavo: int = 0      # Impronte e potenziamenti che alzano lo Scavo
var vetusta: int = 0          # cubetti bianchi: +1 per evento superato
var protection: int = 0       # +2 per lavoratore piazzato; si azzera a fine era
var upgrades: Array = []      # id dei potenziamenti infilati sotto
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

func classes() -> Array:
	return data["classes"]

func shares_class_with(other_data: Dictionary) -> bool:
	for c in data["classes"]:
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
