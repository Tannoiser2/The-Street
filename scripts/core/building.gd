# res://scripts/core/building.gd
# Istanza di un edificio in gioco. I dati statici stanno in `data` (dal CardDB).
class_name Building
extends RefCounted

var uid: int
var data: Dictionary          # riga di cards.json (buildings)
var owner: int
var era_built: int            # era in cui è stato costruito
# IL BINARIO SU CUI POGGIA, quando sta a terra. Finche' ogni era ha il suo
# binario i due numeri coincidono e questo resta 0: si deduce dall'era, com'e'
# sempre stato. Serve per provare i "binari liberi", dove un edificio di
# un'era puo' finire sul binario di un'altra e l'era non basta piu' a dire
# dove sta. Un sopraelevato non ha binario: la sua profondita' viene dalle
# basi su cui poggia.
var binario: int = 0
var col_from: int             # prima colonna occupata (inclusa)
var col_to: int               # ultima colonna occupata (esclusa)
var level: int = 0            # 0 = nel binario; >0 = sopraelevato
var state: int = Enums.BuildingState.INTATTO
var is_buried: bool = false   # condizione di posizione: qualcosa è stato costruito sopra
var was_razed: bool = false   # spianato dal proprietario da intatto -> Scavo 0
# Su chi poggia: gli uid degli edifici che gli fanno da base. Si fissano
# quando lo si costruisce e non cambiano piu', perche' la sagoma non deve
# muoversi quando qualcun altro costruisce li' vicino.
var basi: Array[int] = []
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
# Quanto ha reso, canale per canale. Il nucleo i punti li divide gia' per
# canale quando li segna al giocatore (PlayerState.vp_breakdown); qui li
# divide anche per CARTA, perche' "quanto vale questo edificio in una
# partita vera" e' una domanda da designer a cui lo stato sapeva rispondere
# solo a meta'. Non cambia niente di quello che succede: e' un libro mastro.
var vp_reso: Dictionary = {}      # canale -> punti fruttati al proprietario

func rende(canale: String, quanti: int) -> void:
	if quanti == 0: return
	vp_reso[canale] = int(vp_reso.get(canale, 0)) + quanti

func vp_totali() -> int:
	var t := 0
	for c in vp_reso: t += int(vp_reso[c])
	return t

# Su che binario sta, a terra: quello scelto costruendo, o quello della sua
# era per tutto il resto del gioco e per le partite salvate prima.
func binario_effettivo() -> int:
	return binario if binario > 0 else era_built

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
