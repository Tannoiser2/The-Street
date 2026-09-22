# res://scripts/view/board_layout_3d.gd
# Geometria della plancia in 3D. PURA: nessun Node, nessuna mesh, solo
# posizioni. Serve a piazzare le sagome E a capire dove il giocatore ha
# cliccato, cosi' le due cose non possono divergere.
#
# TUTTE LE MISURE SONO IN MILLIMETRI, prese dal cartone vero: cosi' i numeri
# del designer entrano qui verbatim invece di passare da una conversione a
# occhio. `U` le porta alle unita' di Godot.
#
# Misurate da materiali/Carte.pdf (solo geometria, non dati di gioco):
#   tessera colonna  63 x 271 mm  ->  5 binari da 54,2 mm
#   sagome           61 / 121 / 181 mm di larghezza = 1, 2, 3 slot
#   altezze          mediane 66 / 62 / 74 mm per 1 / 2 / 3 slot
# Dal designer: basetta profonda 15 mm, cartone della sagoma spesso 4 mm.
#
# Gli assi vengono dal tavolo vero:
#   X  le colonne, una tessera a fianco all'altra
#   Z  i 5 binari in profondita'. ERA 1 DAVANTI, era 5 in fondo, cielo dietro.
#   Y  le quote. Un edificio sopraelevato non appartiene a nessun binario:
#      poggia su quelli sotto, che gli fanno da basetta.
class_name BoardLayout3D
extends RefCounted

const U := 0.01                  # 1 unita' Godot = 100 mm

const RAILS := 5
const TESSERA_W := 63.0          # larghezza di una tessera colonna
const TESSERA_D := 271.0         # profondita' della tessera intera
const TESSERA_Y := 2.0           # spessore della tessera stesa sul tavolo
# I BINARI STANNO NELLA FASCIA DEL DISEGNO, non su tutta la tessera. Sotto
# l'illustrazione la tessera porta le icone di produzione, la regola e la
# fascia "Prosperita' Urbana": una sagoma piazzata li' le coprirebbe, ed e'
# roba che si deve leggere per tutta la partita.
# La fascia e' misurata sull'immagine stampata, riga per riga: il cielo
# comincia a 30 mm dal bordo alto e la cornice d'oro sotto il disegno cade a
# 160. Centotrenta millimetri per cinque binari.
const BANDA_SU := 30.0
const BANDA_GIU := 160.0
const SLOT_D := (BANDA_GIU - BANDA_SU) / float(RAILS)   # 26 mm per binario
const SAGOMA_MODULO := 60.3      # 1/2/3 slot -> 60,3 / 120,6 / 180,9 mm
const SAGOMA_SPESSORE := 4.0     # cartone vero, misurato
# A schermo 4 mm non si vedono: una sagoma disegnata cosi' sembra un adesivo.
# Il DISEGNO la ingrossa, i conti no - il raggio del clic e la geometria usano
# sempre la misura vera. E' una scelta di leggibilita', scritta qui perche'
# non sembri una misura sbagliata.
const SAGOMA_SPESSORE_VISTA := 9.0
const BASETTA_D := 15.0          # il piede che tiene in piedi la sagoma
const BASETTA_Y := 10.0
# Le sagome sono contigue sul binario, ma la basetta ne occupa 15 mm sui 54:
# il resto dello slot resta scoperto, ed e' quello che lascia vedere le file
# dietro senza bisogno di allontanare i binari.
# Il passo fra le quote e' lo spessore di cio' che sta sotto, e sotto c'e'
# solo la BASETTA: chi crolla in rovina perde la sagoma e resta il piede, che
# fa da fondamenta a chi ci costruisce sopra. Un edificio non si trova mai
# sopra una sagoma in piedi - le basi diventano tutte rovina nel momento in
# cui ci si costruisce - quindi non c'e' niente da scavalcare.
const LEVEL_H := BASETTA_Y
# Il cielo e' un pannello in piedi ATTACCATO al bordo alto delle tessere e
# largo esattamente quanto loro: e' il fondale della strada, non una parete
# della stanza. Prima stava 90 mm piu' indietro e sbordava di due tessere per
# lato, e si vedeva che era un'altra cosa.
# L'altezza non e' scelta: viene dal rapporto dell'immagine di sfondo, cosi'
# il panorama non si deforma. Il valore qui e' quello di materiali/Sfondo.png
# (1672x941); la vista passa il rapporto vero della texture che ha caricato.
const CIELO_RAPPORTO := 1672.0 / 941.0
const SFONDO_PATH := "res://assets/sfondo.png"

static func col_x(col: int) -> float:
	return col * TESSERA_W

# L'era 1 sta DAVANTI, cioe' dalla parte della telecamera, che guarda verso
# le z calanti. Con la telecamera dall'altro lato lo schermo specchierebbe la
# X e la colonna 0 finirebbe a destra: chi legge "colonna 2" guarderebbe dalla
# parte sbagliata.
static func rail_z(era: int) -> float:
	return BANDA_SU + (RAILS - era) * SLOT_D

# La tessera intera, che e' piu' lunga della fascia dei binari.
static func tessera_box(col: int) -> AABB:
	return AABB(Vector3(col_x(col), 0.0, 0.0),
		Vector3(TESSERA_W, TESSERA_Y, TESSERA_D))

static func span_w(n_col: int) -> float:
	return n_col * SAGOMA_MODULO

static func board_w(gs: GameState) -> float:
	return gs.grid.n_cols * TESSERA_W

static func board_d() -> float:
	return TESSERA_D

static func level_y(level: int) -> float:
	return TESSERA_Y + level * LEVEL_H

# Il centro dello slot (colonna, binario) sul piano del tavolo.
static func slot_center(col: int, era: int) -> Vector3:
	return Vector3(col_x(col) + TESSERA_W / 2.0, TESSERA_Y, rail_z(era) + SLOT_D / 2.0)

# Dove poggia la sagoma. La basetta sta sul DAVANTI dello slot: i 39 mm dietro
# restano scoperti, ed e' cosi' che si vedono le file in fondo.
static func standee_base(gs: GameState, b: Building) -> Vector3:
	var x := col_x(b.col_from) + b.width() * TESSERA_W / 2.0
	var z: float
	if b.level == 0:
		# sul davanti dello slot, cioe' dal lato della telecamera
		z = rail_z(b.era_built) + SLOT_D - BASETTA_D / 2.0
	else:
		# Senza binario: al centro della FASCIA, sopra il baricentro di cio'
		# che la sorregge - non al centro della tessera, che scenderebbe sul
		# testo.
		z = (BANDA_SU + BANDA_GIU) / 2.0
	return Vector3(x, level_y(b.level), z)

# La basetta: ogni sagoma ne ha una. 15 mm di profondita' per 4 mm di cartone.
static func basetta_box(gs: GameState, b: Building) -> AABB:
	var c := standee_base(gs, b)
	return AABB(Vector3(c.x - span_w(b.width()) / 2.0, c.y, c.z - BASETTA_D / 2.0),
		Vector3(span_w(b.width()), BASETTA_Y, BASETTA_D))

static func tile_box(col: int, era: int) -> AABB:
	return AABB(Vector3(col_x(col), 0.0, rail_z(era)), Vector3(TESSERA_W, TESSERA_Y, SLOT_D))

# Le misure della sagoma vera, da data/sagome.json. Se mancano - il file non
# c'e', o l'edificio non e' mappato - si ripiega sulla mediana misurata per
# quella larghezza: un numero preso dal cartone, non inventato.
const ALTEZZA_MEDIANA: Array[float] = [66.0, 66.0, 62.0, 74.0]

static func standee_size(b: Building) -> Vector2:
	var s: Dictionary = CardDB.sagome.get(str(b.data["id"]), {})
	if s.has("mm"):
		var mm: Array = s["mm"]
		return Vector2(float(mm[0]), float(mm[1]))
	var n: int = clampi(b.width(), 1, ALTEZZA_MEDIANA.size() - 1)
	return Vector2(span_w(b.width()), ALTEZZA_MEDIANA[n])

# Il file dell'illustrazione, nello stato giusto: a colori finche' l'edificio
# e' intatto, in grigio quando e' spento. Stringa vuota se non c'e' mappatura.
# Chi e' CROLLATO IN ROVINA non ha piu' una sagoma in piedi: resta la
# basetta, che fa da fondamenta a chi ci costruisce sopra. Il RUDERE invece e'
# "in piedi ma spento" e la sagoma ce l'ha ancora, in grigio.
static func ha_sagoma(b: Building) -> bool:
	return b.state != Enums.BuildingState.ROVINA

static func sagoma_path(b: Building) -> String:
	var s: Dictionary = CardDB.sagome.get(str(b.data["id"]), {})
	if not s.has("n"): return ""
	var variante := "colore" if b.state == Enums.BuildingState.INTATTO else "grigio"
	return "res://assets/sagome/%s/%02d.png" % [variante, int(s["n"])]

# ---- il cartone vero al posto dei rettangoli colorati ----------------
# Quale tessera stampata va su una colonna. Il motore conosce quattro terreni,
# il cartone ne stampa undici varianti nominate: si sceglie la k-esima fra
# quelle del terreno giusto, dove k conta quante colonne dello stesso terreno
# vengono prima. Deterministico, quindi due colonne di pianura vicine non
# portano lo stesso disegno.
#
# Se le tessere di un terreno finiscono si ricomincia da capo: succede col
# FIUME a quattro giocatori, che ne chiede tre e sul cartone ce ne sono due.
# Non e' una scelta, e' il difetto di stampa del punto 72 delle domande
# aperte che si vede a schermo.
static func tessera_id(gs: GameState, col: int) -> String:
	if col < 0 or col >= gs.grid.n_cols: return ""
	var terr := Enums.terrain_to_string(gs.grid.terrains[col])
	var quali: Array = CardDB.tessere_per_terreno.get(terr, [])
	if quali.is_empty(): return ""
	var k := 0
	for c in col:
		if gs.grid.terrains[c] == gs.grid.terrains[col]: k += 1
	return str(quali[k % quali.size()])

static func tessera_path(gs: GameState, col: int) -> String:
	var id := tessera_id(gs, col)
	return "" if id == "" else "res://assets/carte/tessere/%s.png" % id

# Le carte delle file laterali. Gli edifici escono dal PDF in JPEG, gli altri
# gruppi in PNG col fondo tolto: l'estensione non e' uniforme e non si puo'
# indovinare, quindi sta qui in un posto solo.
const CARTELLE_CARTE := {
	"mercato": ["edifici", "jpeg"],
	"personaggio": ["personaggi", "png"],
	"potenziamento": ["potenziamenti", "png"],
	"monumento": ["monumenti", "png"],
	"eredita": ["eredita", "png"],
	"eredita_coperta": ["dorsi", "png"],
	"dinastia": ["dorsi", "png"],
}

static func carta_path(tipo: String, id: String) -> String:
	if not CARTELLE_CARTE.has(tipo): return ""
	var d: Array = CARTELLE_CARTE[tipo]
	return "res://assets/carte/%s/%s.%s" % [d[0], id, d[1]]

static func sky_rect(gs: GameState, rapporto := CIELO_RAPPORTO) -> AABB:
	var largo := board_w(gs)
	return AABB(Vector3(0.0, 0.0, 0.0),
		Vector3(largo, largo / maxf(rapporto, 0.05), 0.0))

# L'inquadratura e' DERIVATA, non aggiustata a occhio: inclinazione fissa e
# distanza calcolata perche' la strada riempia il fotogramma. Cosi' vale per
# 5, 7 o 9 colonne senza ritoccare nulla.
#
# L'inclinazione e' un compromesso fra due cose che tirano in direzioni
# opposte:
#   - piu' alta: le sagome dietro si vedono meglio, perche' quella davanti le
#     copre meno;
#   - piu' bassa: si vedono meglio di faccia sia le sagome sia LE TESSERE,
#     perche' guardate dall'alto si schiacciano col coseno.
# Resta 45, e il secondo corno vince per una ragione precisa: a 62 gradi i 271
# mm di profondita' della tessera si leggono come 127 invece che come 192, e a
# schermo la tessera sembra alta la meta'. Non e' cambiata di un millimetro -
# e' l'angolo - ma chi guarda vede una tessera distorta, e ha ragione lui.
# Il prezzo lo paga l'occlusione: con le sagome raccolte in 26 mm, di quella
# dietro ne resta visibile il 39%. Chi vuole guardare in fondo alza lo
# sguardo, perche' la telecamera ora si muove.
const FOV := 40.0
const INCLINAZIONE := 45.0      # gradi sopra l'orizzonte
const RIEMPIMENTO := 0.80       # quanta larghezza del fotogramma occupa la strada
const ASPETTO := 1520.0 / 900.0

# Il punto che la telecamera guarda: il centro della strada, un po' sopra il
# piano del tavolo perche' le sagome stanno in piedi.
# Quanto e' alta la citta': serve all'inquadratura, che deve arretrare man
# mano che le torri salgono invece di tagliarle.
static func altezza_scena(gs: GameState) -> float:
	var m := 0
	for b in gs.grid.buildings:
		m = maxi(m, b.level)
	return level_y(m) + ALTEZZA_MEDIANA[0] + BASETTA_Y

static func camera_target(gs: GameState) -> Vector3:
	var t := table_aabb_piatto(gs)
	return Vector3(t.position.x + t.size.x / 2.0, altezza_scena(gs) * 0.38,
		t.position.z + t.size.z * 0.55)

# Come table_aabb ma senza chiamare camera_*: serve alla mira, e senza questa
# separazione le due funzioni si chiamerebbero a vicenda senza fine.
static func table_aabb_piatto(gs: GameState) -> AABB:
	var tutto := AABB(Vector3.ZERO, Vector3(board_w(gs), 0.0, board_d()))
	for c in side_cards(gs): tutto = tutto.merge(c["aabb"])
	for p in player_boards(gs): tutto = tutto.merge(p["aabb"])
	return tutto

# L'ingombro di tutta la scena: la strada piu' le torri.
static func scene_aabb(gs: GameState) -> AABB:
	return AABB(Vector3.ZERO, Vector3(board_w(gs), altezza_scena(gs), board_d()))

# Quanto della scena esce dal fotogramma, da una certa posizione: 1.0 vuol
# dire che tocca esattamente il bordo. Si guardano gli OTTO SPIGOLI, perche'
# in prospettiva la fila davanti e' piu' vicina e si ingrandisce - una stima
# lineare la taglierebbe, ed e' proprio l'errore che avevo fatto.
static func _ingombro(cam: Vector3, mira: Vector3, scatola: AABB) -> float:
	var avanti := (mira - cam).normalized()
	var destra := avanti.cross(Vector3.UP).normalized()
	var su := destra.cross(avanti).normalized()
	var tan_v := tan(deg_to_rad(FOV) / 2.0)
	var tan_o := tan_v * ASPETTO
	var peggio := 0.0
	for i in 8:
		var ang := scatola.position + Vector3(
			scatola.size.x * float(i & 1),
			scatola.size.y * float((i >> 1) & 1),
			scatola.size.z * float((i >> 2) & 1))
		var v := ang - cam
		var z := v.dot(avanti)
		if z <= 1.0: return 99.0          # spigolo dietro la telecamera
		peggio = maxf(peggio, absf(v.dot(destra)) / (z * tan_o))
		peggio = maxf(peggio, absf(v.dot(su)) / (z * tan_v))
	return peggio

# La distanza si trova per avvicinamento: poche passate bastano, e il
# risultato e' esatto per 5, 7 o 9 colonne e per qualsiasi altezza.
static func camera_position(gs: GameState) -> Vector3:
	var p := deg_to_rad(INCLINAZIONE)
	var dir := Vector3(0.0, sin(p), cos(p))
	var mira := camera_target(gs)
	var scatola := table_aabb(gs)
	var d := board_w(gs) + board_d() + altezza_scena(gs)
	for i in 8:
		var fattore := _ingombro(mira + dir * d, mira, scatola)
		if fattore > 90.0:
			d *= 2.0
			continue
		d = maxf(d * fattore / RIEMPIMENTO, 1.0)
	return mira + dir * d

# Quanta parte del fotogramma occupa la scena dalla posizione calcolata:
# 1.0 e' il bordo esatto. Sopra 1.0 si taglia qualcosa, molto sotto si spreca
# il fotogramma. Il test ci si appoggia, cosi' l'inquadratura non si giudica
# a occhio.
static func riempimento(gs: GameState) -> float:
	return _ingombro(camera_position(gs), camera_target(gs), table_aabb(gs))

# Quanta parte di una sagoma resta visibile dietro quella della fila davanti,
# da 0 a 1. E' la meta' del compromesso dell'inclinazione; l'altra meta' e'
# lo scorcio, che vale semplicemente cos(inclinazione).
static func quota_visibile(altezza := 66.0) -> float:
	var nascosto: float = maxf(0.0, altezza - SLOT_D * tan(deg_to_rad(INCLINAZIONE)))
	return (altezza - nascosto) / altezza

static func scorcio() -> float:
	return cos(deg_to_rad(INCLINAZIONE))

# L'angolo di sguardo, in gradi sopra l'orizzonte.
static func camera_pitch_deg(gs: GameState) -> float:
	var c := camera_position(gs)
	var t := camera_target(gs)
	var oriz := Vector2(t.x - c.x, t.z - c.z).length()
	return rad_to_deg(atan2(c.y - t.y, oriz))

# ---- i cubetti sulla basetta ----------------------------------------
# Il regolamento li descrive gia': "segnatela con i cubetti BIANCHI" per la
# Vetusta', "resistenza permanente, segnata con un cubetto NERO" per i
# potenziamenti Struttura. Stanno sulla basetta, davanti alla sagoma, dove si
# leggono senza girare il tabellone.
# E i potenziamenti si vedono per la linguetta: "infilate la carta sotto,
# lasciandone sporgere la linguetta".
const CUBETTO := 9.0       # come un cubetto da gioco vero
const CUBETTO_GAP := 2.0
const LINGUETTA_W := 14.0
const LINGUETTA_D := 9.0

# I cubetti di un edificio, in fila sul davanti della basetta.
# Ogni voce: {"pos": Vector3, "tipo": "vetusta"|"resistenza"}.
static func cubetti(gs: GameState, b: Building) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	var quanti := b.vetusta + maxi(0, b.bonus_res)
	if quanti <= 0: return out
	var passo := CUBETTO + CUBETTO_GAP
	var base := standee_base(gs, b)
	var larghezza := (quanti * CUBETTO + (quanti - 1) * CUBETTO_GAP)
	# Se sono troppi per la basetta si stringono: meglio affollati che fuori.
	var disponibile := span_w(b.width()) - 4.0
	var scala: float = minf(1.0, disponibile / maxf(larghezza, 0.001))
	var x0 := base.x - larghezza * scala / 2.0
	var z := base.z + BASETTA_D / 2.0 - CUBETTO / 2.0 - 1.0
	for i in quanti:
		out.append({
			"pos": Vector3(x0 + (i * passo + CUBETTO / 2.0) * scala, base.y + BASETTA_Y, z),
			"lato": CUBETTO * scala,
			"tipo": "vetusta" if i < b.vetusta else "resistenza",
		})
	return out

# Le linguette dei potenziamenti, che sporgono da sotto la sagoma.
static func linguette(gs: GameState, b: Building) -> Array[Vector3]:
	var out: Array[Vector3] = []
	var base := standee_base(gs, b)
	for i in b.upgrades.size():
		var dx := (float(i) - (b.upgrades.size() - 1) / 2.0) * (LINGUETTA_W + 2.0)
		# Davanti alla basetta, non dietro la sagoma: una linguetta che spunta
		# si deve vedere, e da questa parte del tavolo c'e' chi guarda.
		out.append(Vector3(base.x + dx, base.y + 1.0,
			base.z + BASETTA_D / 2.0 + LINGUETTA_D / 2.0 + 1.0))
	return out

# ---- le file e le plance, sul tavolo --------------------------------
# Stanno nella scena e non in una sovrimpressione, perche' sul tavolo vero
# sono carte: si vedono, si indicano e si cliccano come tutto il resto.
# La carta misura 62,6 x 61,8 mm nel PDF: quadrata, in pratica.
const CARTA := 62.5
const CARTA_GAP := 8.0
const BORDO := 26.0          # stacco fra la strada e le file
const PLANCIA_D := 54.0      # profondita' della plancia di un giocatore

# Il mercato corre lungo il fianco SINISTRO della strada; personaggi,
# potenziamenti e monumenti lungo il DESTRO. Cosi' la strada resta libera e
# il tavolo si allarga di una carta per lato invece di allungarsi.
# Centrata sulla strada: una fila lunga sborda davanti e dietro in parti
# uguali invece di allungare il tavolo da un lato solo.
# Le misure vere delle carte, misurate sul PDF (solo geometria, non dati).
# L'orientamento e' quello dell'immagine stampata: monumenti ed eredita' sono
# impaginati DI TRAVERSO - sulla carta vera il titolo si legge girando la
# testa - e sul tavolo si posano per il lungo, che e' l'unico modo di
# leggerli a schermo.
const MISURE_CARTE := {
	"mercato": Vector2(62.6, 61.8),
	"personaggio": Vector2(66.0, 93.2),
	"potenziamento": Vector2(28.0, 68.0),
	"monumento": Vector2(125.6, 25.2),
	"eredita": Vector2(125.7, 45.2),
	"eredita_coperta": Vector2(125.7, 45.2),
	"dinastia": Vector2(95.0, 95.0),
}

static func misura_carta(tipo: String) -> Vector2:
	return MISURE_CARTE.get(tipo, Vector2(CARTA, CARTA))

# Impila le carte in colonna lungo Z, ognuna con la SUA misura: una fila che
# mescola personaggi, potenziamenti e monumenti mette insieme tre formati
# diversi, e forzarli tutti in un quadrato deformava i disegni.
# `x` e' il bordo verso la strada: le carte piu' strette restano allineate a
# quel lato invece di ballare al centro.
static func _colonna_di_carte(x: float, misure: Array) -> Array[AABB]:
	var out: Array[AABB] = []
	if misure.is_empty(): return out
	var totale := 0.0
	for m in misure: totale += m.y
	totale += CARTA_GAP * (misure.size() - 1)
	var z := board_d() / 2.0 - totale / 2.0
	for m in misure:
		out.append(AABB(Vector3(x, 0.0, z), Vector3(m.x, TESSERA_Y, m.y)))
		z += m.y + CARTA_GAP
	return out

# Tutte le carte delle file, ognuna col suo riquadro: serve a disegnarle e a
# cliccarle. `kind` dice a quale fila appartiene, `id` quale carta e'.
static func side_cards(gs: GameState, umano := -1) -> Array[Dictionary]:
	var out: Array[Dictionary] = []

	# A SINISTRA il mercato, una colonna sola, appoggiata al proprio bordo
	# destro cosi' le carte guardano la strada.
	var sinistra: Array = []
	for id in gs.market: sinistra.append(["mercato", str(id)])
	var mis_sx: Array = []
	for c in sinistra: mis_sx.append(misura_carta(str(c[0])))
	var largo_sx := 0.0
	for m in mis_sx: largo_sx = maxf(largo_sx, m.x)
	var box_sx := _colonna_di_carte(-(largo_sx + BORDO), mis_sx)
	for i in sinistra.size():
		var b: AABB = box_sx[i]
		b.position.x += largo_sx - b.size.x
		out.append({"kind": str(sinistra[i][0]), "id": str(sinistra[i][1]), "aabb": b})

	out.append_array(_fila_destra(gs))
	out.append_array(player_cards(gs, umano))
	return out

# A DESTRA due file affiancate: i personaggi in colonna e, a fianco di
# ciascuno, il potenziamento della sua riga. Sono tre e tre, e messi cosi' si
# leggono a coppie invece che in un elenco unico lungo il doppio.
# I monumenti stanno appena sotto, in fondo alle due file.
static func _fila_destra(gs: GameState) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	var m_pers := misura_carta("personaggio")
	var m_pot := misura_carta("potenziamento")
	var m_mon := misura_carta("monumento")
	var righe: int = maxi(gs.char_row.size(), gs.upg_row.size())

	var alto_righe := righe * m_pers.y + maxf(0.0, righe - 1) * CARTA_GAP
	var alto_mon := gs.monuments_open.size() * m_mon.y \
		+ maxf(0.0, gs.monuments_open.size() - 1) * CARTA_GAP
	var totale := alto_righe + (CARTA_GAP * 3.0 + alto_mon if alto_mon > 0.0 else 0.0)
	var z := board_d() / 2.0 - totale / 2.0
	var x := board_w(gs) + BORDO

	for i in righe:
		if i < gs.char_row.size():
			out.append({"kind": "personaggio", "id": str(gs.char_row[i]),
				"aabb": AABB(Vector3(x, 0.0, z), Vector3(m_pers.x, TESSERA_Y, m_pers.y))})
		if i < gs.upg_row.size():
			# Il potenziamento e' piu' corto del personaggio: si centra sulla
			# sua riga, cosi' le due file restano allineate a occhio.
			out.append({"kind": "potenziamento", "id": str(gs.upg_row[i]),
				"aabb": AABB(
					Vector3(x + m_pers.x + CARTA_GAP, 0.0, z + (m_pers.y - m_pot.y) / 2.0),
					Vector3(m_pot.x, TESSERA_Y, m_pot.y))})
		z += m_pers.y + CARTA_GAP
	z += CARTA_GAP * 2.0
	for id in gs.monuments_open:
		out.append({"kind": "monumento", "id": str(id),
			"aabb": AABB(Vector3(x, 0.0, z), Vector3(m_mon.x, TESSERA_Y, m_mon.y))})
		z += m_mon.y + CARTA_GAP
	return out

# ---- il posto del giocatore -----------------------------------------
# Non c'e' piu' un rettangolo colorato che finge di essere un tabellone: il
# giocatore possiede delle CARTE, e quelle si vedono. Del suo colore resta una
# bacchetta sottile, e sotto ci si impilano le carte comprate.
const BACCHETTA_D := 7.0
const CARTE_GIOCATORE_GAP := 5.0

# Le carte che un giocatore ha davanti. I potenziamenti no: quelli stanno
# infilati sotto l'edificio, ed e' li' che il regolamento li vuole. L'Eredita'
# nemmeno: e' segreta fino alla fine.
static func carte_giocatore(gs: GameState, player: int, umano := -1) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	var p: PlayerState = gs.players[player]
	# L'OBIETTIVO SEGRETO. Ce l'hanno tutti dall'inizio e non si vedeva da
	# nessuna parte: sta davanti al suo giocatore, scoperto per lui e coperto
	# per gli altri - come sul tavolo vero.
	if p.legacy_id != "":
		if player == umano:
			out.append({"kind": "eredita", "id": p.legacy_id})
		else:
			out.append({"kind": "eredita_coperta", "id": "eredita_1"})
	if p.has_dynasty: out.append({"kind": "dinastia", "id": "dinastia_1"})
	for m in p.monuments_claimed: out.append({"kind": "monumento", "id": str(m)})
	var visti := {}
	for c in p.specialized_characters:
		visti[str(c)] = true
		out.append({"kind": "personaggio", "id": str(c)})
	for c in p.final_characters:
		if visti.has(str(c)): continue
		visti[str(c)] = true
		out.append({"kind": "personaggio", "id": str(c)})
	return out

# La bacchetta del colore: una per giocatore, davanti alla strada.
static func player_boards(gs: GameState) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	var largo := board_w(gs) / float(gs.n_players)
	var z := board_d() + BORDO      # davanti alla strada, dal lato di chi guarda
	for i in gs.n_players:
		out.append({"player": i, "aabb": AABB(
			Vector3(i * largo + 4.0, 0.0, z),
			Vector3(largo - 8.0, TESSERA_Y, BACCHETTA_D))})
	return out

# Le carte comprate, stese sotto la bacchetta. Il passo si stringe da solo
# quando le carte sono tante: restano dentro il posto del giocatore e si
# sovrappongono come un mazzo aperto a ventaglio, invece di sbordare addosso
# al vicino.
static func player_cards(gs: GameState, umano := -1) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	var largo := board_w(gs) / float(gs.n_players)
	var z := board_d() + BORDO + BACCHETTA_D + CARTE_GIOCATORE_GAP
	for i in gs.n_players:
		var carte := carte_giocatore(gs, i, umano)
		if carte.is_empty(): continue
		var w_max := 0.0
		for c in carte: w_max = maxf(w_max, misura_carta(str(c["kind"])).x)
		var spazio := largo - 8.0
		var passo := w_max + CARTE_GIOCATORE_GAP
		if carte.size() > 1:
			passo = minf(passo, maxf(12.0, (spazio - w_max) / float(carte.size() - 1)))
		var x0 := i * largo + 4.0
		for j in carte.size():
			var m := misura_carta(str(carte[j]["kind"]))
			out.append({"kind": str(carte[j]["kind"]), "id": str(carte[j]["id"]),
				"player": i, "ordine": j,
				"aabb": AABB(Vector3(x0 + j * passo, 0.0, z),
					Vector3(m.x, TESSERA_Y, m.y))})
	return out

# Tutto il tavolo: strada, file e plance. E' questo che l'inquadratura deve
# far entrare, non la sola strada.
static func table_aabb(gs: GameState) -> AABB:
	var tutto := scene_aabb(gs)
	for c in side_cards(gs): tutto = tutto.merge(c["aabb"])
	for p in player_boards(gs): tutto = tutto.merge(p["aabb"])
	return tutto

# ---- dal clic allo slot --------------------------------------------
# Pura anche questa: prende un raggio (origine e direzione, in millimetri) e
# dice su quale slot cade. Il disegno e il clic leggono la stessa geometria.
# Restituisce {"col": int, "era": int} oppure {} se il raggio manca il tavolo.
static func slot_at_ray(gs: GameState, origine: Vector3, direzione: Vector3) -> Dictionary:
	if absf(direzione.y) < 0.00001: return {}
	var t := (TESSERA_Y - origine.y) / direzione.y
	if t < 0.0: return {}                       # il tavolo e' dietro la telecamera
	var p := origine + direzione * t
	var col := int(floor(p.x / TESSERA_W))
	if col < 0 or col >= gs.grid.n_cols: return {}
	if p.z < 0.0 or p.z >= board_d(): return {}
	# I binari occupano solo la fascia del disegno, ma si clicca tutta la
	# tessera: fuori dalla fascia vale il binario piu' vicino, altrimenti
	# meta' tessera sarebbe morta al clic senza che si capisca perche'.
	var era := RAILS - int(floor((p.z - BANDA_SU) / SLOT_D))
	return {"col": col, "era": clampi(era, 1, RAILS), "punto": p}

# L'edificio colpito da un raggio: la sagoma sta IN PIEDI, quindi non basta
# intersecare il piano del tavolo come per gli slot e le carte. Si prova
# l'ingombro di ciascuna, e vince la piu' vicina alla telecamera.
# Restituisce l'uid, o -1.
static func at_ray_building(gs: GameState, origine: Vector3, direzione: Vector3) -> int:
	var migliore := -1
	var piu_vicino := INF
	for b in gs.grid.buildings:
		var base := standee_base(gs, b)
		var dim := standee_size(b)
		var box := AABB(
			Vector3(base.x - dim.x / 2.0, base.y, base.z - SAGOMA_SPESSORE * 2.0),
			Vector3(dim.x, dim.y + BASETTA_Y, SAGOMA_SPESSORE * 4.0))
		var t := _colpisce(box, origine, direzione)
		if t >= 0.0 and t < piu_vicino:
			piu_vicino = t
			migliore = b.uid
	return migliore

# Distanza a cui il raggio entra nella scatola, o -1 se la manca.
static func _colpisce(box: AABB, o: Vector3, d: Vector3) -> float:
	var t0 := -INF
	var t1 := INF
	for asse in 3:
		var od: float = d[asse]
		var oo: float = o[asse]
		var lo: float = box.position[asse]
		var hi: float = lo + box.size[asse]
		if absf(od) < 0.000001:
			if oo < lo or oo > hi: return -1.0
			continue
		var a := (lo - oo) / od
		var b := (hi - oo) / od
		t0 = maxf(t0, minf(a, b))
		t1 = minf(t1, maxf(a, b))
	if t1 < maxf(t0, 0.0): return -1.0
	return maxf(t0, 0.0)

# Il riquadro di un piazzamento: dove si accende e dove si clicca, che sono
# la stessa cosa. Alla quota del livello, cosi' "costruire sopra" e' un posto
# in alto sulla pila invece di un tasto da tenere premuto - e "spianare il mio
# edificio" diventa un riquadro sopra quell'edificio, che prima non c'era modo
# di chiedere.
static func box_piazzamento(col_from: int, larghezza: int, livello: int,
		era: int) -> AABB:
	if livello == 0:
		# A terra si va sul binario dell'era in corso: e' li' che la sagoma
		# andra' a finire.
		return AABB(Vector3(col_x(col_from), level_y(0), rail_z(era)),
			Vector3(larghezza * TESSERA_W, 0.0, SLOT_D))
	# Sopra non c'e' un binario: la sagoma poggia al centro della fascia,
	# sopra il baricentro di cio' che la sorregge. Il riquadro si tira un po'
	# dentro, cosi' quando un binario ci finisce sotto - nell'era 3 cadono
	# alla stessa z - restano due rettangoli distinti e cliccabili invece di
	# uno sopra l'altro.
	var z := (BANDA_SU + BANDA_GIU) / 2.0 - SLOT_D / 2.0
	return AABB(Vector3(col_x(col_from) + 9.0, level_y(livello), z + 6.0),
		Vector3(larghezza * TESSERA_W - 18.0, 0.0, SLOT_D - 12.0))

# Quale riquadro colpisce il raggio, fra quelli dati: il piu' vicino, o -1.
# I riquadri sono piatti, quindi si ingrossano un filo in altezza per dare
# al raggio qualcosa da prendere.
static func riquadro_al_raggio(riquadri: Array, origine: Vector3,
		direzione: Vector3) -> int:
	var migliore := -1
	var piu_vicino := INF
	for i in riquadri.size():
		var b: AABB = riquadri[i]
		# Un filo piu' generoso del disegno: un binario e' profondo 26 mm, a
		# schermo una quindicina di pixel, e chiedere il pixel esatto sarebbe
		# scortese. Il margine e' meta' binario, quindi non arriva mai a
		# toccare il riquadro di un'altra riga.
		b = b.grow(6.0)
		b.position.y = riquadri[i].position.y - 3.0
		b.size.y = 6.0
		var t := _colpisce(b, origine, direzione)
		if t >= 0.0 and t < piu_vicino:
			piu_vicino = t
			migliore = i
	return migliore

# La carta di una fila sotto un raggio, se ce n'e' una. Stessa geometria del
# disegno: il giocatore clicca cio' che vede.
static func card_at_ray(gs: GameState, origine: Vector3, direzione: Vector3,
		umano := -1) -> Dictionary:
	if absf(direzione.y) < 0.00001: return {}
	var t := (TESSERA_Y - origine.y) / direzione.y
	if t < 0.0: return {}
	var p := origine + direzione * t
	for c in side_cards(gs):
		var r: AABB = c["aabb"]
		if p.x >= r.position.x and p.x <= r.position.x + r.size.x \
				and p.z >= r.position.z and p.z <= r.position.z + r.size.z:
			return c
	return {}
