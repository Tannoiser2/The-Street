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

# Quanto si aspetta fra un turno di bot e l'altro. Prima i bot giocavano
# tutti i loro turni in un colpo solo fra un clic e l'altro: sul tabellone
# comparivano tre edifici insieme e non si capiva chi avesse fatto cosa.
# "subito" e' quel comportamento di prima, tenuto perche' serve a sbrigare
# una partita intera; "passo" non aspetta il tempo ma il giocatore, che
# avanza un turno per volta - il modo per studiare davvero cosa fanno.
const VELOCITA: Array[Dictionary] = [
	{"nome": "passo", "pausa": -1.0},
	{"nome": "lenta", "pausa": 1.4},
	{"nome": "normale", "pausa": 0.6},
	{"nome": "veloce", "pausa": 0.2},
	{"nome": "subito", "pausa": 0.0},
]
const VELOCITA_NORMALE := 2

# IL REGOLAMENTO (registro 86 e 102): lo stesso progetto gioca la v1.5 e la
# v2, e a decidere e' il file dati che si carica. La v2 e' quella che si
# sta disegnando, quindi e' la scelta di partenza; la v1.5 resta a portata
# di clic, con le regole congelate. Se il file v2 non c'e' resta la v1.5.
const REGOLAMENTI: Array[Dictionary] = [
	{"nome": "v1.5", "dati": "res://data/cards.json"},
	{"nome": "v2", "dati": "res://data/cards-v2.json"},
]

var giocatori := 3
var bot := 2
var seme := 7
var velocita := VELOCITA_NORMALE
# Il regolamento con cui si apre la schermata: la v2 nel gioco; i test della
# vista, che descrivono la v1.5, lo mettono a 0 prima di cominciare.
static var predefinito := 1
var regolamento := predefinito

# Ogni scelta passa di qui, cosi' non esiste uno stato che il gioco non sappia
# cominciare: i giocatori restano fra 2 e 4 e i bot fra 0 e quanti sono.
func sistema() -> void:
	giocatori = clampi(giocatori, MIN_GIOCATORI, MAX_GIOCATORI)
	bot = clampi(bot, 0, giocatori)
	velocita = clampi(velocita, 0, VELOCITA.size() - 1)
	regolamento = clampi(regolamento, 0, REGOLAMENTI.size() - 1)
	if not FileAccess.file_exists(percorso_dati()): regolamento = 0

func percorso_dati() -> String:
	return str(REGOLAMENTI[regolamento]["dati"])

func nome_regolamento() -> String:
	return str(REGOLAMENTI[regolamento]["nome"])

func con_regolamento(i: int) -> void:
	regolamento = i
	sistema()

# LA STRATEGIA DEL BOT che siede al posto `i`, ricavata dal seme: la stessa
# partita rigiocata ha gli stessi avversari, con le stesse teste. Prima i bot
# tiravano a caso, e "guardare i bot giocare" voleva dire guardare rumore.
# Il canone lo dice il file dati caricato (registro 92): con la v2 la
# Verticale non c'e' e c'e' la Continuita'.
func strategia(i: int) -> String:
	var canone := StrategyBot.canone()
	return canone[(i + seme) % canone.size()]

func nome_strategia(i: int) -> String:
	return strategia(i).capitalize()

func con_giocatori(n: int) -> void:
	giocatori = n
	sistema()

func con_bot(n: int) -> void:
	bot = n
	sistema()

func con_velocita(i: int) -> void:
	velocita = i
	sistema()

# Gira alla velocita' dopo, e dall'ultima torna alla prima: serve al tasto
# in partita, che di posto per cinque nomi non ne ha.
func velocita_dopo() -> void:
	con_velocita((velocita + 1) % VELOCITA.size())

# Secondi fra un turno di bot e l'altro. Negativo vuol dire "a mano", zero
# "tutti in un colpo": due casi che non sono un'attesa, e chi chiama deve
# chiederli per nome invece di confrontare numeri.
func pausa_bot() -> float:
	return float(VELOCITA[velocita]["pausa"])

func nome_velocita() -> String:
	return str(VELOCITA[velocita]["nome"])

func bot_a_mano() -> bool:
	return pausa_bot() < 0.0

func bot_subito() -> bool:
	return is_zero_approx(pausa_bot())

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
	var come := ""
	if bot > 0: come = " · bot %s" % nome_velocita()
	return "%s · %d giocatori · %s%s · seme %d" % [nome_regolamento(), giocatori, chi, come, seme]
