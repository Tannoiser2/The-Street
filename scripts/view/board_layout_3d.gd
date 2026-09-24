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
# Il DISEGNO ingrossa appena il cartone, i conti no: il raggio del clic e la
# geometria usano sempre la misura vera. E' una scelta di leggibilita',
# scritta qui perche' non sembri una misura sbagliata.
# Stava a 9 finche' la sagoma era una pila di quattro copie del disegno e lo
# spessore andava esagerato per farsi vedere. Adesso il cartone e' estruso per
# davvero, col taglio scuro lungo il bordo, e 9 mm sembravano un bordino
# disegnato attorno alla figura: bastano 5.
const SAGOMA_SPESSORE_VISTA := 5.0
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
# Quanta parte dell'immagine si mostra, dal basso. A pannello intero il
# fondale saliva quasi quanto e' profonda la strada - un muro dietro il
# tabellone - e la meta' alta era cielo vuoto. Si mostra la meta' bassa,
# cioe' l'orizzonte e la terra: il pannello cala della meta' e il panorama
# NON si schiaccia, perche' quel che resta tiene le sue proporzioni.
# E' un numero solo: per farlo piu' alto o piu' basso si cambia qui.
const CIELO_QUOTA := 0.5
const SFONDO_PATH := "res://assets/sfondo.png"

static func col_x(col: int) -> float:
	return col * TESSERA_W

# L'ERA 1 STA IN FONDO, le ere recenti davanti, dalla parte della telecamera.
# La telecamera guarda verso le z calanti, quindi l'era 1 ha la z minore.
#
# Prima era il contrario, ed era una scelta che si ritorceva contro il
# disegno: SI COSTRUISCE IN ALTO SULLE ROVINE DELLE PRIME ERE, perche' sono
# quelle che hanno avuto il tempo di crollare. Le pile alte crescevano quindi
# sul binario piu' vicino a chi guarda e facevano da muro a tutto quello che
# veniva costruito dopo, che stava dietro ed era anche piu' basso: della
# citta' recente si vedevano i tetti.
# Cosi' invece la citta' sale verso il fondo - le torri stanno dietro - e le
# costruzioni nuove, basse, restano in prima fila dove si vedono.
# La X non si tocca: la telecamera resta da questo lato, e la colonna 0 resta
# a sinistra come la legge chi gioca.
static func rail_z(era: int) -> float:
	return BANDA_SU + (era - 1) * SLOT_D

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
	return Vector3(x, level_y(b.level), z_sagoma(gs, b))

# Dove sta, in profondita', il piede di un edificio.
# A terra e' il davanti del suo binario. SOPRA, invece, poggia su quello che
# lo regge: la z viene dalle basi sotto. Prima ogni sopraelevato finiva in
# mezzo alla fascia del disegno mentre le sue fondamenta restavano al loro
# binario - per l'era 1 sono 57 mm piu' avanti - e a schermo l'edificio
# galleggiava in aria a fianco della pila che avrebbe dovuto reggerlo.
static func z_sagoma(gs: GameState, b: Building, giri := 0) -> float:
	if b.level == 0:
		# sul davanti dello slot, cioe' dal lato della telecamera
		return rail_z(b.binario_effettivo()) + SLOT_D - BASETTA_D / 2.0
	# LE BASI SONO QUELLE DI QUANDO LO SI E' COSTRUITO, non quelle che si
	# trovano adesso nelle sue colonne. A quota zero una colonna porta fino
	# a cinque edifici, uno per binario d'era: chiedendolo alla colonna, un
	# edificio costruito dopo in un altro binario entrava nella media e
	# spostava la sagoma sopra, che a schermo scivolava verso il fondo.
	# Una sagoma costruita non si muove piu'.
	if not b.basi.is_empty(): return _z_di_uid(gs, b.basi, giri)
	# Senza basi segnate - i fissaggi dei test, o una pila tutta terrapieno -
	# si ripiega sulla colonna, che e' il conto di prima.
	return z_basi(gs, b.col_from, b.col_to, b.level, giri)

# LA BASE PIU' ALTA, e fra quelle alla stessa quota la piu' avanti.
# Le basi di un edificio non stanno per forza tutte alla stessa quota: uno
# largo puo' poggiare su una pila da una parte e su una rovina a terra
# dall'altra, e il dislivello lo riempie il terrapieno. Il piede vero e'
# quello ALTO - e' li' che il cartone appoggia - mentre quello basso e' sotto
# la terra riportata. Seguendo il piu' avanti e basta, un edificio che avesse
# davanti la base bassa se ne andava a stare sopra di lei e perdeva il
# contatto con la base alta, che restava un binario piu' in la'.
static func _z_di_uid(gs: GameState, uid: Array, giri: int) -> float:
	var avanti := -INF
	var alto := -1
	if giri < RAILS:
		for s in gs.grid.buildings:
			if not s.uid in uid: continue
			var z := z_sagoma(gs, s, giri + 1)
			if s.level > alto or (s.level == alto and z > avanti):
				alto = s.level
				avanti = z
	return avanti if avanti > -INF else (BANDA_SU + BANDA_GIU) / 2.0

# La z di cio' che regge una pila alla quota `livello` fra due colonne: la
# base PIU' AVANTI, dalla parte di chi guarda.
#
# Prima era la media delle basi trovate, per mettere in mezzo un edificio
# largo che poggia su due basi di ere diverse. Ma i binari distano 26 mm e
# una basetta ne e' profonda 15: a due ere di distanza la media non tocca
# nessuno dei due piedi, e l'edificio resta sospeso fra loro. Appoggiandolo
# a quello davanti sta sempre su un piede vero, che e' quello che farebbe
# il cartone.
# Se sotto non c'e' niente - tutto terrapieno - si torna al centro della
# fascia: e' l'unico caso in cui non c'e' una base da seguire.
static func z_basi(gs: GameState, col_from: int, col_to: int, livello: int,
		giri := 0) -> float:
	var avanti := -INF
	if giri < RAILS:
		for s in gs.grid.buildings:
			if s.level != livello - 1: continue
			if s.col_to <= col_from or s.col_from >= col_to: continue
			avanti = maxf(avanti, z_sagoma(gs, s, giri + 1))
	return avanti if avanti > -INF else (BANDA_SU + BANDA_GIU) / 2.0

# IL TERRAPIENO: la terra riportata sotto una colonna dell'impronta che non
# arriva da sola alla quota del piede. E' un blocco che parte da cio' che c'e'
# sotto in quella colonna - il piano del tavolo se non c'e' niente - e arriva
# esatto sotto il piede, largo la fetta di basetta di quella colonna.
#
# I casi sono due e sul tavolo si riempiono allo stesso modo:
#  - la colonna NUDA, il terrapieno che il regolamento fa pagare 1 pietra;
#  - la colonna la cui base sta PIU' IN BASSO del piede. Questa non si paga
#    - "per colonna priva di base, una volta sola, qualunque sia la quota da
#    raggiungere" - perche' l'edificio prende il livello della base piu' alta
#    piu' uno, e le altre restano indietro. Ma la terra ci va lo stesso: e'
#    il caso dell'edificio largo appoggiato a una pila alta da un lato e a una
#    rovina a terra dall'altro, che restava con mezza sagoma sul vuoto.
static func terrapieno_box(gs: GameState, b: Building, col: int) -> AABB:
	var base := basetta_box(gs, b)
	var fetta := base.size.x / float(b.width())
	var da := level_y(quota_sotto(gs, b, col) + 1)
	return AABB(
		Vector3(base.position.x + (col - b.col_from) * fetta, da, base.position.z),
		Vector3(fetta, maxf(base.position.y - da, 0.0), base.size.z))

static func terrapieni(gs: GameState, b: Building) -> Array[AABB]:
	var out: Array[AABB] = []
	if b.level == 0: return out
	for col in range(b.col_from, b.col_to):
		var box := terrapieno_box(gs, b, col)
		if box.size.y > 0.0: out.append(box)
	return out

# Il livello di cio' che regge questa colonna, -1 se sotto non c'e' niente.
# Si guardano le basi fissate alla costruzione - come per la z, quello che
# regge non cambia piu' - e solo quando l'edificio non le ha (i fissaggi dei
# test) si ripiega sulla colonna di adesso.
static func quota_sotto(gs: GameState, b: Building, col: int) -> int:
	var mia := basetta_box(gs, b)
	var q := -1
	for s in gs.grid.buildings:
		if s == b or not s.covers(col) or s.level >= b.level: continue
		# SOLO QUELLO CHE STA ALLA STESSA PROFONDITA'. Un edificio del binario
		# accanto e' DI FIANCO, non sotto: riempire fino a lui lascerebbe il
		# vuoto sotto la terra.
		# E' il caso del Parco archeologico che poggia su due basi a quote e
		# profondita' diverse - una al livello 2 sul binario dell'era 2, una
		# al livello 1 su quello dell'era 3: alla profondita' in cui viene
		# disegnato, sotto di lui c'e' il livello 0, e la terra deve partire
		# da li'.
		var r := basetta_box(gs, s)
		if r.end.z <= mia.position.z + 0.01 or r.position.z >= mia.end.z - 0.01:
			continue
		q = maxi(q, s.level)
	return q

# ---- lo sgretolamento ------------------------------------------------
# Quando un edificio crolla in rovina la sua sagoma sparisce dal tabellone, e
# prima spariva e basta: un fotogramma prima c'era, quello dopo no. Chi stava
# guardando altrove non si accorgeva di niente - ed e' la cosa piu' importante
# che succede a fine era.
#
# Adesso si abbatte in avanti come farebbe il cartone: il piede resta dov'e' e
# il resto cade verso chi guarda, accelerando; mentre cade si spegne, e un
# pugno di macerie rotola giu' dalla basetta. Sono numeri puri, quindi si
# provano headless come tutto il resto: la vista ci mette solo le mesh.
const CROLLO_DURATA := 1.1
const CROLLO_MACERIE := 7
const CROLLO_MACERIA_LATO := 6.0
const GRAVITA := 2600.0          # mm/s^2, scelta perche' le macerie cadano
                                 # nel tempo del crollo e non dopo

# A che punto e' la caduta. `t` va da 0 a 1.
static func crollo(t: float) -> Dictionary:
	var q := clampf(t, 0.0, 1.0)
	# La caduta accelera come accelera una cosa che cade: al quadrato, non
	# lineare, e arriva a terra prima della fine - l'ultimo pezzo di tempo
	# serve a spegnersi da sdraiata.
	var angolo := (PI / 2.0) * minf(1.0, q * q / 0.64)
	# Si spegne sul finire: se cominciasse subito cadrebbe gia' invisibile.
	var opacita := clampf((1.0 - q) / 0.3, 0.0, 1.0)
	return {"angolo": angolo, "opacita": opacita, "finito": q >= 1.0}

# Il mucchietto di macerie che si stacca. Tutto ricavato dall'uid: la stessa
# rovina fa sempre lo stesso mucchio, e una partita rigiocata col suo seme si
# vede uguale.
static func macerie(uid: int, larghezza: float, quante := CROLLO_MACERIE) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	for i in quante:
		var h := _rumore(uid * 31 + i * 7)
		var h2 := _rumore(uid * 17 + i * 13 + 5)
		var h3 := _rumore(uid * 11 + i * 29 + 3)
		out.append({
			# da dove parte, lungo il fronte della sagoma
			"x": (h - 0.5) * larghezza * 0.8,
			"y": 6.0 + h2 * larghezza * 0.25,
			# come schizza via: un po' di lato e un po' verso chi guarda
			"vx": (h2 - 0.5) * 70.0,
			"vy": 60.0 + h3 * 120.0,
			"vz": 20.0 + h * 60.0,
			"lato": CROLLO_MACERIA_LATO * (0.6 + h3 * 0.8),
		})
	return out

# Dove sta una maceria dopo `t` secondi: tiro parabolico, e quando tocca il
# piano ci resta.
static func maceria_pos(m: Dictionary, t: float) -> Vector3:
	var y := float(m["y"]) + float(m["vy"]) * t - 0.5 * GRAVITA * t * t
	var q := clampf(t, 0.0, CROLLO_DURATA)
	if y < 0.0:
		# atterrata: si ferma dov'e' caduta invece di sprofondare
		var caduta := (float(m["vy"]) + sqrt(float(m["vy"]) * float(m["vy"])
			+ 2.0 * GRAVITA * float(m["y"]))) / GRAVITA
		q = minf(q, caduta)
		y = 0.0
	return Vector3(float(m["x"]) + float(m["vx"]) * q, y, float(m["vz"]) * q)

# Un numero fra 0 e 1 ricavato da un intero. Non serve che sia un buon
# generatore: serve che sia SEMPRE LO STESSO per lo stesso uid.
static func _rumore(n: int) -> float:
	var x := (n * 1103515245 + 12345) & 0x7fffffff
	x = (x >> 7) ^ (x * 2654435761)
	return float(absi(x) % 10000) / 10000.0

# ---- il banner dello Scavo -------------------------------------------
# IL VALORE DI SCAVO STA SCRITTO SULLA BASETTA, davanti e dietro. Prima lo
# sapeva solo chi apriva il riquadro col mouse, eppure e' il numero che decide
# se valga la pena sotterrare un edificio invece di restaurarlo.
#
# L'immagine e' UNA SOLA: dieci strisce sovrapposte, una per valore, dallo 0
# al 9. La striscia e' lunga quanto un edificio da tre slot; per quelli piu'
# corti si taglia da SINISTRA, dove ci sono solo macerie, e resta la parte
# destra col numero. Non si ritaglia in dieci file: si sposta la finestra
# sulla texture, cosi' aggiungere un valore domani vuol dire cambiare
# l'immagine e basta.
#
# L'atlante lo prepara `tools/estrai_grafica.py`, che dall'originale del
# designer ritrova le strisce una per una e le rimette in righe tutte uguali:
# l'immagine e' disegnata, non impaginata, e le strisce non sono alte uguali.
const SCAVO_PATH := "res://assets/scavo.png"
const SCAVO_RIGHE := 10          # le strisce dell'atlante: da 0 a 9
const SCAVO_SLOT_MAX := 3        # la striscia copre un edificio da tre slot

# Che fetta di texture mostrare per questo edificio. Il valore e' quello
# EFFETTIVO - `scavo_value` tiene conto delle Impronte e dello spianamento,
# che porta lo Scavo a 0 - quindi il banner dice sempre la verita' di adesso.
static func scavo_uv(b: Building) -> Dictionary:
	var valore := clampi(b.scavo_value(), 0, SCAVO_RIGHE - 1)
	var frazione := span_w(b.width()) / span_w(SCAVO_SLOT_MAX)
	return {
		"valore": valore,
		"fuori_scala": b.scavo_value() > SCAVO_RIGHE - 1,
		"scala": Vector2(frazione, 1.0 / float(SCAVO_RIGHE)),
		"offset": Vector2(1.0 - frazione, float(valore) / float(SCAVO_RIGHE)),
	}

# LA TERRA DEL TERRAPIENO ha un disegno suo: una sezione di terreno, senza
# macerie e senza numero, perche' li' non c'e' niente da contare.
const TERRAPIENO_PATH := "res://assets/terrapieno.png"
const TERRAPIENO_RAPPORTO := 2000.0 / 173.0

# La finestra da ritagliare per un blocco. Non si prende tutta l'immagine per
# poi schiacciarla nel riquadro: si prende una finestra che ha LE STESSE
# PROPORZIONI del blocco, cosi' i sassi restano tondi invece di diventare
# ellissi. Un blocco piu' lungo di quanto sia lunga l'immagine non lascia
# scelta: li' si prende tutto.
#
# `variante` sposta la finestra di lato - basta la colonna - cosi' due
# terrapieni vicini non mostrano lo stesso identico sasso.
static func terra_uv(box: AABB, variante := 0) -> Dictionary:
	if box.size.y <= 0.0: return {"scala": Vector2.ONE, "offset": Vector2.ZERO}
	var voluto := box.size.x / box.size.y
	var frazione := clampf(voluto / TERRAPIENO_RAPPORTO, 0.05, 1.0)
	var resto := 1.0 - frazione
	var dove := fposmod(0.37 * float(variante) + 0.5, 1.0)
	return {
		"scala": Vector2(frazione, 1.0),
		"offset": Vector2(resto * dove, 0.0),
	}

# Le due facce della basetta su cui va il banner: quella davanti, dal lato di
# chi guarda, e quella dietro. Restituisce centro e dimensioni del rettangolo.
static func facce_basetta(gs: GameState, b: Building) -> Array[Dictionary]:
	var r := basetta_box(gs, b)
	var centro := Vector2(r.position.x + r.size.x / 2.0, r.position.y + r.size.y / 2.0)
	return [
		{"davanti": true, "pos": Vector3(centro.x, centro.y, r.end.z),
			"dim": Vector2(r.size.x, r.size.y)},
		{"davanti": false, "pos": Vector3(centro.x, centro.y, r.position.z),
			"dim": Vector2(r.size.x, r.size.y)},
	]

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
# Chi ha ancora una sagoma in piedi. Due casi la perdono, e resta il piede:
#
# - CHI E' CROLLATO IN ROVINA: non e' piu' un edificio, e' il basamento di
#   chi ci costruira' sopra.
# - CHI E' SEPOLTO: sta sotto gli strati, quindi in piedi non puo' esserci.
#   Non e' un caso raro: a quota zero una colonna porta fino a cinque
#   edifici, uno per binario d'era, e chi costruisce sopra ne spiana uno
#   solo - quello in cima. Gli altri restano INTATTI e finiscono sepolti:
#   su otto partite a tre sono 76 su 225, e le loro sagome attraversavano
#   la pila da parte a parte, inglobate negli strati.
static func ha_sagoma(b: Building) -> bool:
	return b.state != Enums.BuildingState.ROVINA and not b.is_buried

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

static func sky_rect(gs: GameState, rapporto := CIELO_RAPPORTO,
		quota := CIELO_QUOTA) -> AABB:
	var largo := board_w(gs)
	return AABB(Vector3(0.0, 0.0, 0.0),
		Vector3(largo, largo / maxf(rapporto, 0.05) * clampf(quota, 0.05, 1.0), 0.0))

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
# UNA ROVINA NON PORTA CUBETTI. Nessuna regola glieli toglie - il crollo
# azzera i potenziamenti, e la Vetusta' si azzera solo col restauro, che vale
# sui ruderi - ma su una rovina non contano piu' niente: gli eventi guardano
# solo chi e' in piedi, il restauro non la riguarda, le spolia si pagano solo
# spianando un intatto, e da quando il Colosseo e Il Silvicoltore chiedono un
# edificio "sopravvissuto" (intatto o rudere) nemmeno la Vetusta' le serve
# piu'. Sul tabellone restava una fila di cubetti che non diceva piu' niente
# a nessuno: 1851 rovine su 6167 in 300 partite.
static func cubetti(gs: GameState, b: Building) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	if b.state == Enums.BuildingState.ROVINA: return out
	var quanti := b.vetusta + maxi(0, b.bonus_res)
	if quanti <= 0: return out
	var passo := CUBETTO + CUBETTO_GAP
	var base := standee_base(gs, b)
	var larghezza := (quanti * CUBETTO + (quanti - 1) * CUBETTO_GAP)
	# Se sono troppi per la basetta si stringono: meglio affollati che fuori.
	# E il pezzo di basetta dove sta il gettone dello scheletro non e' loro:
	# senza tenerglielo da parte, su un edificio con tanta vetusta i cubetti
	# ci finivano sotto e si vedeva una fila di cubi mezzi dentro un gettone.
	var riservato := (scheletro_size().x + 2.0) if b.buried_character != "" else 0.0
	var disponibile := span_w(b.width()) - 4.0 - riservato
	var scala: float = minf(1.0, disponibile / maxf(larghezza, 0.001))
	var x0 := base.x - riservato / 2.0 - larghezza * scala / 2.0
	var z := base.z + BASETTA_D / 2.0 - CUBETTO / 2.0 - 1.0
	for i in quanti:
		out.append({
			"pos": Vector3(x0 + (i * passo + CUBETTO / 2.0) * scala, base.y + BASETTA_Y, z),
			"lato": CUBETTO * scala,
			"tipo": "vetusta" if i < b.vetusta else "resistenza",
		})
	return out

# ---- il cartellino della Prosperita' Urbana --------------------------
# Un Centro Urbano e' una colonna con almeno tre edifici intatti di almeno due
# proprietari diversi: ogni volta che la si attiva, ognuno di quei proprietari
# incassa un oro. La condizione si fa e si disfa da sola - basta che un
# edificio crolli - e sul tabellone non si vedeva: la scritta "Prosperita'
# Urbana" e' stampata sulla tessera di tutte le colonne, accesa o spenta che
# sia, e per sapere se quella li' pagava bisognava contare gli edifici a mano.
#
# Il cartellino si posa proprio su quella fascia, in fondo alla tessera: la
# scritta stampata c'e' sempre, il cartellino solo quando il Centro e' attivo.
# La fascia e' misurata sull'immagine della tessera - e' l'ultimo riquadro
# scuro prima della cornice - e sta fra il 90% e il 98,5% della sua lunghezza.
const PROSPERITA_PATH := "res://assets/prosperita.png"
const PROSPERITA_FASCIA_SU := 0.898     # in frazioni di TESSERA_D
const PROSPERITA_FASCIA_GIU := 0.985
const PROSPERITA_RAPPORTO := 1387.0 / 518.0
const PROSPERITA_MARGINE := 2.5         # dentro la cornice della tessera

# GIA' PAGATO IN QUEST'ERA. Il Centro Urbano paga una volta per colonna e per
# era (punto 86): al tavolo il cartellino si gira dopo il pagamento e si
# rigirano tutti a fine era. A schermo il rovescio e' lo stesso cartellino
# spento - scuro, come il rudere e' la sagoma in grigio - cosi' si vede ancora
# che la colonna e' un Centro, ma anche che per quest'era ha gia' dato.
# Opaco: mezzo trasparente lasciava passare la scritta stampata sotto, e le
# due scritte sovrapposte non si leggevano piu'.
const PROSPERITA_SPENTA := Color(0.3, 0.3, 0.3, 1.0)

static func prosperita_pagata(gs: GameState, col: int) -> bool:
	return gs.grid.prosperity_paid.has(col)

static func prosperita_colore(gs: GameState, col: int) -> Color:
	return PROSPERITA_SPENTA if prosperita_pagata(gs, col) else Color.WHITE

# Il rettangolo dove si posa, sul piano della tessera.
static func prosperita_box(col: int) -> AABB:
	var t := tessera_box(col)
	var largo := TESSERA_W - 2.0 * PROSPERITA_MARGINE
	var alto := largo / PROSPERITA_RAPPORTO
	var centro_z := TESSERA_D * (PROSPERITA_FASCIA_SU + PROSPERITA_FASCIA_GIU) / 2.0
	return AABB(Vector3(t.position.x + PROSPERITA_MARGINE, t.end.y,
			t.position.z + centro_z - alto / 2.0),
		Vector3(largo, 0.0, alto))

# ---- il gettone dello scheletro --------------------------------------
# "Nelle ere 1-4, a fine era il personaggio non si scarta: infilatelo sotto la
# carta di un vostro edificio ancora in piedi." Quel personaggio sepolto vale
# 6 meno l'era in cui e' stato sepolto - 5, 4, 3, 2 - ed e' l'unica cosa che
# un edificio continua a rendere anche da rovina.
#
# Sul tavolo e' un gettone quadrato posato sulla basetta, uno per era, con
# sopra lo scheletro dell'epoca e il suo valore. Prima era un cubetto color
# ocra: si vedeva che li' sotto c'era qualcuno, non chi ne' quanto valeva.
# I gettoni sono QUATTRO perche' quattro sono le ere che seppelliscono: "i
# personaggi dell'era Moderna si scartano".
#
# L'immagine e' una sola, quattro caselle in fila: si sposta la finestra
# sulla texture invece di ritagliare quattro file, come per il banner dello
# Scavo. L'atlante lo prepara `tools/estrai_grafica.py`.
const SCHELETRO_PATH := "res://assets/scheletri.png"
const SCHELETRI_COLONNE := 4
const SCHELETRO_LATO := 13.0                # quanto e' alto il gettone
const SCHELETRO_RAPPORTO := 487.0 / 450.0   # il gettone e' quasi quadrato
const SCHELETRO_SPESSORE := 1.6             # cartoncino spesso, non un cubo
# Non disteso sulla basetta: APPOGGIATO ALL'INDIETRO contro la sagoma. La
# telecamera guarda il tavolo quasi di taglio, e un gettone steso di piatto
# si vede come una riga di due millimetri - cioe' meno del cubetto che
# sostituisce. In piedi si legge, e sul tavolo vero e' come lo si appoggia
# quando lo si vuole far vedere.
const SCHELETRO_PENDENZA := 0.30            # rad, all'indietro

static func scheletro_size() -> Vector2:
	return Vector2(SCHELETRO_LATO * SCHELETRO_RAPPORTO, SCHELETRO_LATO)

# Dove poggia: a destra sulla basetta, sul davanti, dove non copre la sagoma
# ne' i cubetti della vetusta, che stanno a sinistra.
static func scheletro_piede(gs: GameState, b: Building) -> Vector3:
	var base := standee_base(gs, b)
	var largo := scheletro_size().x
	return Vector3(base.x + span_w(b.width()) / 2.0 - largo / 2.0 - 1.5,
		base.y + BASETTA_Y, base.z + BASETTA_D / 2.0 - 1.5)

# La casella dell'era: la prima e' l'era 1, che vale 5.
static func scheletro_uv(era: int) -> Dictionary:
	var i := clampi(era - 1, 0, SCHELETRI_COLONNE - 1)
	return {"scala": Vector2(1.0 / float(SCHELETRI_COLONNE), 1.0),
		"offset": Vector2(float(i) / float(SCHELETRI_COLONNE), 0.0)}

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

# TUTTE LE CARTE IN PIEDI ALLA STESSA ALTEZZA. Sul foglio di stampa non lo
# sono - la Dinastia e' 95 mm, un edificio 62 - e a schermo la differenza
# diventava enorme: le carte grandi schiacciavano le altre e il tavolo non
# sembrava piu' un mazzo solo. Si porta ognuna alla stessa altezza tenendo
# le sue proporzioni, cosi' i disegni non si deformano e le larghezze
# restano diverse come sul cartone.
#
# Monumenti ed eredita' non entrano nel conto: sono tessere lunghe e basse,
# impaginate di traverso, e tirarle a questa altezza le farebbe larghe mezzo
# metro. Restano quello che sono, cioe' un altro oggetto.
const ALTEZZA_CARTA := 72.0
const CARTE_IN_PIEDI: Array[String] = ["mercato", "personaggio",
	"potenziamento", "dinastia"]

static func misura_carta(tipo: String) -> Vector2:
	var m: Vector2 = MISURE_CARTE.get(tipo, Vector2(CARTA, CARTA))
	if not (tipo in CARTE_IN_PIEDI) or m.y <= 0.0: return m
	return Vector2(m.x * ALTEZZA_CARTA / m.y, ALTEZZA_CARTA)

# Tutte le carte delle file, ognuna col suo riquadro: serve a disegnarle e a
# cliccarle. `kind` dice a quale fila appartiene, `id` quale carta e'.
static func side_cards(gs: GameState, umano := -1) -> Array[Dictionary]:
	var out: Array[Dictionary] = []

	out.append_array(_fila_sinistra(gs))
	out.append_array(_fila_destra(gs))
	out.append_array(player_cards(gs, umano))
	return out

# A SINISTRA il mercato, in DUE FILE DA TRE. In una colonna sola le sei
# carte erano piu' lunghe della strada e la prima finiva fuori dal
# tabellone, sospesa nel nulla; in due file ci stanno tutte dentro.
# Le file sono appoggiate al bordo verso la strada, cosi' le carte la
# guardano invece di ballare al centro.
static func _fila_sinistra(gs: GameState) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	if gs.market.is_empty(): return out
	var m := misura_carta("mercato")
	var per_fila: int = int(ceil(gs.market.size() / 2.0))
	var righe: int = mini(per_fila, gs.market.size())
	var alto := righe * m.y + maxf(0.0, righe - 1) * CARTA_GAP
	var z0 := board_d() / 2.0 - alto / 2.0
	# Il bordo destro del blocco tocca lo stacco dalla strada; la fila con la
	# x piu' grande e' quella vicina alla strada.
	var quante_file: int = 1 if gs.market.size() <= per_fila else 2
	var x0 := -(BORDO + quante_file * m.x + (quante_file - 1) * CARTA_GAP)
	for i in gs.market.size():
		var fila := i / per_fila
		var riga := i % per_fila
		out.append({"kind": "mercato", "id": str(gs.market[i]),
			"aabb": AABB(
				Vector3(x0 + fila * (m.x + CARTA_GAP), 0.0, z0 + riga * (m.y + CARTA_GAP)),
				Vector3(m.x, TESSERA_Y, m.y))})
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

	# La Dinastia sta "sempre disponibile fuori dalle file": in cima, sopra i
	# personaggi, e non si sposta mai. Chi la compra ne prende il pupazzetto.
	var m_din := misura_carta("dinastia")
	var alto_righe := righe * m_pers.y + maxf(0.0, righe - 1) * CARTA_GAP
	var alto_mon := gs.monuments_open.size() * m_mon.y \
		+ maxf(0.0, gs.monuments_open.size() - 1) * CARTA_GAP
	var totale := m_din.y + CARTA_GAP * 3.0 + alto_righe \
		+ (CARTA_GAP * 3.0 + alto_mon if alto_mon > 0.0 else 0.0)
	var z := board_d() / 2.0 - totale / 2.0
	var x := board_w(gs) + BORDO

	out.append({"kind": "dinastia", "id": "dinastia_1",
		"aabb": AABB(Vector3(x, 0.0, z), Vector3(m_din.x, TESSERA_Y, m_din.y))})
	z += m_din.y + CARTA_GAP * 3.0

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
# Le carte degli edifici si accumulano - una decina a testa a fine partita -
# e distese una a fianco all'altra allungherebbero il tavolo di mezzo metro.
# Si impilano a ventaglio come si fa al tavolo vero: ognuna copre la
# precedente lasciandone fuori la fascia del titolo, che e' quanto basta a
# sapere cosa si ha.
const VENTAGLIO_Z := 20.0     # quanto resta scoperto di una carta coperta
# Il mazzetto sta in DUE colonne, e le carte si stringono quel tanto che basta
# a entrarci: una colonna sola lunga il doppio allungava il tavolo davanti al
# giocatore piu' della strada stessa. La stretta e' poca - in quattro e' 0,88,
# in due non serve affatto - e si calcola dal posto disponibile invece di
# essere un numero scelto a occhio.
const MAZZETTO_COLONNE := 2
const VENTAGLIO_Y := 0.25     # ogni carta un filo piu' alta: chi copre sta sopra

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
		# A partita finita si girano tutte, come al tavolo vero: e' il momento
		# in cui si scopre cosa stava inseguendo ciascuno, e senza quello il
		# riepilogo direbbe "eredita': 7 punti" senza dire di quale.
		if player == umano or gs.phase == Enums.Phase.FINE_PARTITA:
			out.append({"kind": "eredita", "id": p.legacy_id})
		else:
			out.append({"kind": "eredita_coperta", "id": "eredita_1"})
	# La Dinastia non sta piu' qui: la carta resta fuori dalle file e quello
	# che il giocatore ha preso e' il PUPAZZETTO, che si vede sulla bacchetta.
	# I PERSONAGGI DI QUEST'ERA stanno subito sotto la bacchetta, perche' sono
	# i lavoratori che ha in gioco adesso; quelli gia' sepolti non si ripetono
	# qui, stanno sotto la carta del loro edificio.
	var sepolti := {}
	for b in gs.grid.buildings:
		if b.owner == player and b.buried_character != "": sepolti[b.buried_character] = true
	var visti := {}
	for c in p.specialized_characters:
		if sepolti.has(str(c)): continue
		visti[str(c)] = true
		out.append({"kind": "personaggio", "id": str(c)})
	for c in p.final_characters:
		if visti.has(str(c)) or sepolti.has(str(c)): continue
		visti[str(c)] = true
		out.append({"kind": "personaggio", "id": str(c)})
	for m in p.monuments_claimed: out.append({"kind": "monumento", "id": str(m)})
	# LE CARTE DEGLI EDIFICI COSTRUITI. "Costruire significa pagare il costo
	# della carta e mettere la sagoma sul tabellone": la carta resta davanti
	# a chi l'ha presa - il regolamento ci fa infilare sotto i personaggi a
	# fine era - e prima spariva nel nulla. Vanno in fondo, a ventaglio,
	# nell'ordine in cui sono state costruite.
	for b in gs.grid.buildings:
		if b.owner != player: continue
		# Ogni carta si porta dietro lo stato dell'edificio: la colonna di
		# sinistra tiene quelle in gioco - accese se intatte, spente in
		# grigio se rudere o rovina - e quella di destra le sotterrate, che
		# sono il mazzetto dello Scavo.
		# LE CARTE INFILATE SOTTO QUESTA. Sono due cose diverse che al tavolo
		# si fanno allo stesso modo: i potenziamenti, che si infilano sotto
		# l'edificio lasciando sporgere la linguetta, e il personaggio che a
		# fine era finisce sepolto li' sotto. Viaggiano con la carta che le
		# copre, se no dei potenziamenti restava solo una linguetta gialla sul
		# tabellone e del personaggio non si capiva ne' chi fosse ne' sotto
		# cosa fosse finito.
		var sotto: Array[Dictionary] = []
		for u in b.upgrades:
			sotto.append({"kind": "potenziamento", "id": str(u)})
		if b.buried_character != "":
			sotto.append({"kind": "personaggio", "id": str(b.buried_character),
				"spenta": true})
		out.append({"kind": "mercato", "id": str(b.data["id"]),
			"ventaglio": true, "sepolta": b.is_buried,
			"spenta": b.state != Enums.BuildingState.INTATTO,
			"sotto": sotto})
	return out

# ---- i pupazzetti ---------------------------------------------------
# I LAVORATORI SI VEDONO. Prima esisteva solo il parallelepipedo sull'edificio
# abitato: chi guardava non sapeva quanti lavoratori avesse ancora in mano un
# giocatore, ne' che quelli sulla strada tornano indietro a fine era. Adesso
# stanno sulla bacchetta del loro colore e da li' vanno sulla colonna che
# attivano - e a fine era, quando `worker_cols` si svuota, tornano da soli.
const MEEPLE_W := 8.0
const MEEPLE_H := 15.0
const MEEPLE_D := 6.0
const MEEPLE_GAP := 3.0

# Quelli ancora in mano: in fila sulla bacchetta, da sinistra.
static func meeple_liberi(gs: GameState, player: int) -> Array[Vector3]:
	var out: Array[Vector3] = []
	var p: PlayerState = gs.players[player]
	var quanti: int = maxi(0, p.workers - p.workers_used)
	if quanti <= 0: return out
	var r := bacchetta_box(gs, player)
	var passo := MEEPLE_W + MEEPLE_GAP
	# Se sono tanti e la bacchetta e' corta si stringono invece di sbordare.
	if passo * float(quanti) > r.size.x:
		passo = r.size.x / float(quanti)
	for i in quanti:
		out.append(Vector3(r.position.x + MEEPLE_W / 2.0 + i * passo,
			r.position.y + r.size.y, r.position.z + r.size.z / 2.0))
	return out

# Quelli sulla strada: uno per colonna attivata. Se il lavoratore abita un
# edificio sta sulla sua basetta - e' li' che il regolamento lo vuole, e da li'
# gli da' +2 resistenza; se no sta sul davanti della colonna, dove si vede che
# la colonna e' presa.
static func meeple_in_campo(gs: GameState, player: int) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	var p: PlayerState = gs.players[player]
	for c in p.worker_cols:
		var col := int(c)
		var ospite: Building = null
		for b in gs.grid.buildings:
			if b.protected_by == player and b.covers(col) and b.is_standing():
				ospite = b
				break
		if ospite != null:
			var base := standee_base(gs, ospite)
			out.append({"col": col, "uid": ospite.uid, "pos": Vector3(
				base.x - span_w(ospite.width()) / 2.0 + MEEPLE_W / 2.0 + 2.0,
				base.y + BASETTA_Y,
				base.z + BASETTA_D / 2.0 - MEEPLE_D / 2.0)})
		else:
			out.append({"col": col, "uid": -1, "pos": Vector3(
				col_x(col) + TESSERA_W / 2.0, TESSERA_Y,
				board_d() - MEEPLE_D)})
	return out

# ---- la Dinastia, fuori dalle file ----------------------------------
# "Sempre disponibile fuori dalle file": la carta non si sposta mai. Sta in
# cima alla fila dei personaggi e ci tiene sopra un pupazzetto per giocatore.
# Chi la compra non prende la carta: prende il PUPAZZETTO e lo mette insieme
# agli altri tre che ha gia'.
static func meeple_dinastia(gs: GameState) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	var carta := carta_dinastia(gs)
	if carta.is_empty(): return out
	var r: AABB = carta["aabb"]
	# Solo chi non l'ha ancora presa, e mai piu' copie di quante ne restano.
	var chi: Array[int] = []
	for i in gs.n_players:
		if not gs.players[i].has_dynasty: chi.append(i)
	while chi.size() > gs.dynasties_left: chi.pop_back()
	if chi.is_empty(): return out
	var passo := MEEPLE_W + MEEPLE_GAP
	var largo := passo * float(chi.size()) - MEEPLE_GAP
	var x0 := r.position.x + (r.size.x - largo) / 2.0 + MEEPLE_W / 2.0
	for j in chi.size():
		out.append({"player": chi[j], "pos": Vector3(x0 + j * passo,
			r.position.y + r.size.y, r.position.z + r.size.z / 2.0)})
	return out

static func carta_dinastia(gs: GameState) -> Dictionary:
	for c in _fila_destra(gs):
		if str(c["kind"]) == "dinastia": return c
	return {}

# La bacchetta del colore: una per giocatore, davanti alla strada.
static func player_boards(gs: GameState) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	for i in gs.n_players:
		out.append({"player": i, "aabb": bacchetta_box(gs, i)})
	return out

static func bacchetta_box(gs: GameState, player: int) -> AABB:
	var largo := board_w(gs) / float(gs.n_players)
	var z := board_d() + BORDO      # davanti alla strada, dal lato di chi guarda
	return AABB(Vector3(player * largo + 4.0, 0.0, z),
		Vector3(largo - 8.0, TESSERA_Y, BACCHETTA_D))

# Le carte comprate, stese sotto la bacchetta. NESSUNA COPRE L'ALTRA: si
# riempie una riga finche' ci sta dentro il posto del giocatore, poi si va a
# capo, e la riga nuova comincia sotto la carta piu' profonda di quella prima.
#
# Prima il passo si stringeva da solo per tenerle tutte su una riga sola, e
# con tre carte larghe 125 mm in una fetta da 147 il passo scendeva a 12: un
# mucchio in cui si leggeva solo l'ultima. Meglio che il posto del giocatore
# si allunghi verso di lui - li' il tavolo e' vuoto - che avere carte che non
# si distinguono.
static func player_cards(gs: GameState, umano := -1) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	var largo := board_w(gs) / float(gs.n_players)
	var z0 := board_d() + BORDO + BACCHETTA_D + CARTE_GIOCATORE_GAP
	for i in gs.n_players:
		var carte := carte_giocatore(gs, i, umano)
		if carte.is_empty(): continue
		var spazio := largo - 8.0
		var x0 := i * largo + 4.0
		var x := x0
		var z := z0
		var profonda := 0.0          # la carta piu' profonda della riga in corso
		var ventaglio: Array = []
		for j in carte.size():
			# Le carte degli edifici vanno in fondo, tutte insieme: distese
			# come le altre allungherebbero il tavolo di mezzo metro.
			if bool(carte[j].get("ventaglio", false)):
				ventaglio.append(carte[j])
				continue
			var m := misura_carta(str(carte[j]["kind"]))
			# A capo quando la carta non ci sta piu'. La prima di una riga ci
			# resta comunque, anche se da sola sborda: e' meglio di una riga
			# vuota e di un giro infinito.
			if x > x0 and x + m.x > x0 + spazio:
				x = x0
				z += profonda + CARTE_GIOCATORE_GAP
				profonda = 0.0
			out.append({"kind": str(carte[j]["kind"]), "id": str(carte[j]["id"]),
				"player": i, "ordine": j,
				"aabb": AABB(Vector3(x, 0.0, z), Vector3(m.x, TESSERA_Y, m.y))})
			x += m.x + CARTE_GIOCATORE_GAP
			profonda = maxf(profonda, m.y)
		if not ventaglio.is_empty():
			var z_v := z + (profonda if profonda > 0.0 else 0.0) \
				+ (CARTE_GIOCATORE_GAP if profonda > 0.0 else 0.0)
			out.append_array(_ventaglio(ventaglio, i, x0, spazio, z_v, carte.size()))
	return out

# Il mazzetto delle carte edificio, in DUE COLONNE CHE VOGLIONO DIRE
# QUALCOSA: a sinistra quello che sta ancora sulla strada, a destra quello
# che e' finito sotto - il mazzetto dello Scavo. Dentro ogni colonna le
# carte si impilano a ventaglio, ognuna copre la precedente lasciandone
# fuori la fascia del titolo.
#
# Ogni carta sta un filo piu' in alto della precedente: due carte complanari
# si contenderebbero lo stesso pixel e lo schermo sfarfalla.
#
# Le colonne restano due anche quando una e' vuota, cosi' il posto di una
# carta non balla appena la prima viene sotterrata. Su otto partite a tre il
# massimo misurato e' 8 carte a sinistra e 10 a destra.
static func _ventaglio(carte: Array, player: int, x0: float, spazio: float,
		z0: float, ordine0: int) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	if carte.is_empty(): return out
	var piena := misura_carta(str(carte[0]["kind"]))
	# Quanto puo' essere larga una carta perche' le due colonne ci stiano.
	# Non si ingrandisce mai: al massimo resta com'e'.
	var posto := (spazio - CARTE_GIOCATORE_GAP * (MAZZETTO_COLONNE - 1)) \
		/ float(MAZZETTO_COLONNE)
	var scala: float = minf(1.0, posto / piena.x)
	var m := piena * scala
	var passo := VENTAGLIO_Z * scala
	var righe := [0, 0]
	for j in carte.size():
		var sepolta := bool(carte[j].get("sepolta", false))
		var c: int = 1 if sepolta else 0
		var r: int = int(righe[c])
		var x := x0 + c * (m.x + CARTE_GIOCATORE_GAP)
		# LE CARTE INFILATE SOTTO QUESTA vengono PRIMA nel ventaglio - cosi'
		# quello che sporge e' la loro fascia del titolo, dritta, e si legge
		# che cosa c'e' infilato li' - ma stanno piu' in BASSO, perche' sono
		# sotto. Prendono una riga per una, non spazio in larghezza: prima
		# sporgevano di fianco e per far loro posto le carte dell'edificio si
		# rimpicciolivano tutte.
		var infilate: Array = carte[j].get("sotto", [])
		var quota := float(r + infilate.size() + 1) * VENTAGLIO_Y
		for k in infilate.size():
			var sotto: Dictionary = infilate[k]
			# Ognuna un filo piu' sotto della precedente: sono una pila, non
			# un mazzo complanare.
			var giu := quota - VENTAGLIO_Y * 0.5 * float(infilate.size() - k) \
				/ float(infilate.size())
			out.append({"kind": str(sotto["kind"]), "id": str(sotto["id"]),
				"player": player, "ordine": ordine0 + j, "sotto": true,
				"spenta": bool(sotto.get("spenta", false)),
				"aabb": AABB(Vector3(x, giu, z0 + r * passo),
					Vector3(m.x, TESSERA_Y, m.y))})
			r += 1
		var box := AABB(Vector3(x, quota, z0 + r * passo),
			Vector3(m.x, TESSERA_Y, m.y))
		out.append({"kind": str(carte[j]["kind"]), "id": str(carte[j]["id"]),
			"player": player, "ordine": ordine0 + j,
			"sepolta": sepolta, "spenta": bool(carte[j].get("spenta", false)),
			"aabb": box})
		r += 1
		righe[c] = r
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
	var era := 1 + int(floor((p.z - BANDA_SU) / SLOT_D))
	return {"col": col, "era": clampi(era, 1, RAILS), "punto": p}

# L'ingombro che il raggio incontra: SI CLICCA QUELLO CHE SI VEDE. Chi non ha
# piu' la sagoma in piedi - una rovina, o una base su cui si e' costruito -
# offre la sola basetta, altrimenti il raggio continuerebbe a colpire un
# cartone che a schermo non c'e' piu', e per giunta davanti a chi lo copre.
static func ingombro(gs: GameState, b: Building) -> AABB:
	if not ha_sagoma(b): return basetta_box(gs, b)
	var base := standee_base(gs, b)
	var dim := standee_size(b)
	return AABB(
		Vector3(base.x - dim.x / 2.0, base.y, base.z - SAGOMA_SPESSORE * 2.0),
		Vector3(dim.x, dim.y + BASETTA_Y, SAGOMA_SPESSORE * 4.0))

# L'edificio colpito da un raggio: la sagoma sta IN PIEDI, quindi non basta
# intersecare il piano del tavolo come per gli slot e le carte. Si prova
# l'ingombro di ciascuna, e vince la piu' vicina alla telecamera.
# Restituisce l'uid, o -1.
static func at_ray_building(gs: GameState, origine: Vector3, direzione: Vector3) -> int:
	var migliore := -1
	var piu_vicino := INF
	for b in gs.grid.buildings:
		var t := _colpisce(ingombro(gs, b), origine, direzione)
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
static func box_piazzamento(gs: GameState, col_from: int, larghezza: int,
		livello: int, era: int) -> AABB:
	if livello == 0:
		# A terra si va sul binario dell'era in corso: e' li' che la sagoma
		# andra' a finire.
		return AABB(Vector3(col_x(col_from), level_y(0), rail_z(era)),
			Vector3(larghezza * TESSERA_W, 0.0, SLOT_D))
	# Sopra non c'e' un binario: il riquadro va DOVE FINIRA' LA SAGOMA, cioe'
	# sopra le basi, con lo stesso conto che usa standee_base. Se qui e la
	# sagoma rispondessero due z diverse, il giocatore accenderebbe un posto e
	# l'edificio comparirebbe altrove.
	# Si tira un po' dentro, cosi' quando un binario ci finisce sotto restano
	# due rettangoli distinti e cliccabili invece di uno sopra l'altro.
	var profondo := SLOT_D - 12.0
	var z := z_basi(gs, col_from, col_from + larghezza, livello) - profondo / 2.0
	return AABB(Vector3(col_x(col_from) + 9.0, level_y(livello), z),
		Vector3(larghezza * TESSERA_W - 18.0, 0.0, profondo))

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
	# `umano` va passato: senza, la vista disegnava l'obiettivo del giocatore
	# scoperto e il clic rispondeva con la carta coperta - sulla tua stessa
	# eredita' il riquadro diceva "lo vede solo il suo giocatore".
	# Nel ventaglio le carte si coprono, quindi non basta la prima che si
	# trova: vince QUELLA SOPRA, cioe' la piu' alta. Altrimenti si
	# cliccherebbe una carta e ne risponderebbe un'altra, nascosta sotto.
	var vinta := {}
	var quota := -INF
	for c in side_cards(gs, umano):
		var r: AABB = c["aabb"]
		if p.x >= r.position.x and p.x <= r.position.x + r.size.x \
				and p.z >= r.position.z and p.z <= r.position.z + r.size.z:
			if r.position.y >= quota:
				quota = r.position.y
				vinta = c
	return vinta
