# res://scripts/view/scelte_inizio.gd
# Come comincia la partita: quanti siedono al tavolo e quanti di loro li gioca
# il bot. Prima erano due numeri scritti dentro gioca.gd - tre giocatori, seme
# 7 - e per provarne altri bisognava ricompilare.
#
# I POSTI SONO IN ORDINE: prima gli umani, poi i bot. Cosi' chi gioca da solo
# contro due bot e' sempre il giocatore 0 e sa dove guardare, e in due umani il
# primo e il secondo sono quelli che il regolamento chiama primo e secondo.
#
# PURA come BoardLayout3D e CameraOrbita: nessun Node, nessun disegno. Serve a
# provare headless che le combinazioni impossibili non passino - zero umani e
# zero bot non e' una partita - senza aprire lo schermo.
class_name ScelteInizio
extends RefCounted

# Il regolamento sta su 2, 3 e 4: il numero di colonne e il mix dei terreni
# sono tabulati solo per quelli (constants.columns_by_players).
const MIN_GIOCATORI := 2
const MAX_GIOCATORI := 4

var giocatori := 3
var bot := 2
var seme := 7

# Ogni scelta passa di qui, cosi' non esiste uno stato che il gioco non sappia
# cominciare: i giocatori restano fra 2 e 4 e i bot fra 0 e quanti sono.
func sistema() -> void:
	giocatori = clampi(giocatori, MIN_GIOCATORI, MAX_GIOCATORI)
	bot = clampi(bot, 0, giocatori)

func con_giocatori(n: int) -> void:
	giocatori = n
	sistema()

func con_bot(n: int) -> void:
	bot = n
	sistema()

func umani() -> int:
	return giocatori - bot

# I primi posti sono degli umani. Con tutti bot non ne resta nessuno, ed e'
# legittimo: la partita si gioca da sola fino in fondo e resta da guardare il
# tavolo finito. E' il modo piu' rapido per vedere dove va a finire un seme.
func e_umano(i: int) -> bool:
	return i >= 0 and i < umani()

func posti_umani() -> Array[int]:
	var out: Array[int] = []
	for i in umani(): out.append(i)
	return out

# Un seme nuovo per una partita diversa. Il seme resta visibile e scelto,
# perche' tutto il resto del progetto dipende da lui: la stessa partita si
# rigioca uguale, e un difetto si racconta col suo numero.
func rimescola(rng := RandomNumberGenerator.new()) -> void:
	rng.randomize()
	seme = rng.randi_range(1, 9999)

func descrizione() -> String:
	var u := umani()
	var chi := ""
	if u == 0: chi = "tutti bot"
	elif bot == 0: chi = "tutti umani"
	elif u == 1: chi = "tu contro %d bot" % bot
	else: chi = "%d umani e %d bot" % [u, bot]
	return "%d giocatori · %s · seme %d" % [giocatori, chi, seme]
