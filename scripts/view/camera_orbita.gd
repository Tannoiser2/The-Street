# res://scripts/view/camera_orbita.gd
# La telecamera che gira attorno al tavolo. PURA come BoardLayout3D: nessun
# Node, nessun input, solo la posizione che ne esce. Cosi' si puo' provare che
# i limiti tengono e che la mira non si perde, senza guardare lo schermo.
#
# Parte esattamente dall'inquadratura calcolata da BoardLayout3D - stessa
# posizione, stessa mira - perche' quella e' gia' scelta coi numeri
# (riempimento 0,80, inclinazione 45 gradi come compromesso fra file occluse e
# sagome schiacciate). Girare il tabellone e' in piu', non al posto di quella:
# il tasto di ripristino ci riporta.
#
# Tutto in MILLIMETRI, come il resto della plancia.
class_name CameraOrbita
extends RefCounted

# Quanto gira il tabellone per pixel di trascinamento. A mezzo grado bastavano
# 180 pixel per un quarto di giro e il tavolo scappava di mano; a 0,3 una
# trascinata larga quanto lo schermo fa poco piu' di mezzo giro.
const GRADI_PER_PIXEL := 0.3

# L'inclinazione non arriva a 0 e non arriva a 90: a zero si guarderebbe il
# tavolo di taglio e la strada sparirebbe in una riga, a novanta si perde ogni
# senso di altezza ed e' proprio quello che il 3D serviva a dare.
const INCLINAZIONE_MIN := 4.0
const INCLINAZIONE_MAX := 87.0

# Lo zoom e' moltiplicativo: ogni scatto di rotella cambia la distanza di un
# fattore fisso, cosi' un passo "pesa" uguale da vicino e da lontano.
const PASSO_ZOOM := 1.12
const ZOOM_MIN := 0.18          # in frazioni della distanza di partenza
const ZOOM_MAX := 2.60

var mira: Vector3               # il punto attorno a cui si gira
var distanza: float             # mm dalla mira
var imbardata: float            # gradi attorno a Y; 0 = l'inquadratura di partenza
var inclinazione: float         # gradi sopra l'orizzonte

var _mira0: Vector3
var _distanza0: float
var _imbardata0: float
var _inclinazione0: float
var _pan_max: AABB              # dove la mira puo' andare a spasso

# L'inquadratura di partenza e' quella calcolata: si ricavano da li' i tre
# numeri dell'orbita, invece di riscriverli, cosi' se BoardLayout3D cambia
# idea la telecamera la segue.
static func da_stato(gs: GameState) -> CameraOrbita:
	var o := CameraOrbita.new()
	var c := BoardLayout3D.camera_position(gs)
	var t := BoardLayout3D.camera_target(gs)
	var v := c - t
	o.mira = t
	o.distanza = v.length()
	o.imbardata = rad_to_deg(atan2(v.x, v.z))
	o.inclinazione = rad_to_deg(atan2(v.y, Vector2(v.x, v.z).length()))
	o._mira0 = o.mira
	o._distanza0 = o.distanza
	o._imbardata0 = o.imbardata
	o._inclinazione0 = o.inclinazione
	# La mira puo' spostarsi di mezza strada in ogni direzione: abbastanza per
	# portare al centro un angolo del tavolo, non abbastanza per perdere di
	# vista il tabellone e non sapere piu' come tornare.
	var tav := BoardLayout3D.table_aabb_piatto(gs)
	o._pan_max = tav.grow(maxf(tav.size.x, tav.size.z) * 0.5)
	return o

func posizione() -> Vector3:
	var p := deg_to_rad(inclinazione)
	var y := deg_to_rad(imbardata)
	return mira + Vector3(sin(y) * cos(p), sin(p), cos(y) * cos(p)) * distanza

# Trascinando, il tabellone segue il mouse: verso destra gira verso destra.
func ruota(dp: Vector2) -> void:
	imbardata = wrapf(imbardata - dp.x * GRADI_PER_PIXEL, -180.0, 180.0)
	inclinazione = clampf(inclinazione - dp.y * GRADI_PER_PIXEL,
		INCLINAZIONE_MIN, INCLINAZIONE_MAX)

# `passi` positivi avvicinano (rotella in su).
func zoom(passi: float) -> void:
	distanza = clampf(distanza * pow(PASSO_ZOOM, -passi),
		_distanza0 * ZOOM_MIN, _distanza0 * ZOOM_MAX)

# Sposta la mira nel piano del tavolo. La scala viene dalla distanza e
# dall'apertura dell'obiettivo: cosi' un pixel di trascinamento sposta il
# tavolo di un pixel, da vicino come da lontano.
func trasla(dp: Vector2, altezza_viewport: float) -> void:
	if altezza_viewport <= 0.0: return
	var per_pixel := 2.0 * distanza * tan(deg_to_rad(BoardLayout3D.FOV) / 2.0) \
		/ altezza_viewport
	var y := deg_to_rad(imbardata)
	var destra := Vector3(cos(y), 0.0, -sin(y))
	var dentro := Vector3(-sin(y), 0.0, -cos(y))
	mira -= destra * dp.x * per_pixel
	mira -= dentro * dp.y * per_pixel / maxf(cos(deg_to_rad(inclinazione)), 0.15)
	mira = Vector3(
		clampf(mira.x, _pan_max.position.x, _pan_max.end.x),
		mira.y,
		clampf(mira.z, _pan_max.position.z, _pan_max.end.z))

func reimposta() -> void:
	mira = _mira0
	distanza = _distanza0
	imbardata = _imbardata0
	inclinazione = _inclinazione0

# Vero quando siamo ancora all'inquadratura calcolata: serve a non sovrascrivere
# una telecamera che il giocatore ha mosso, quando la scena si ridisegna.
func e_iniziale() -> bool:
	return is_equal_approx(distanza, _distanza0) \
		and is_equal_approx(imbardata, _imbardata0) \
		and is_equal_approx(inclinazione, _inclinazione0) \
		and mira.is_equal_approx(_mira0)
