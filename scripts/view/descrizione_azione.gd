# res://scripts/view/descrizione_azione.gd
# La frase che la barra di stato mostra quando il mouse sta sopra un posto
# acceso: che mossa sarebbe, e quanto costa.
#
# Serve perche' i riquadri accesi si somigliano tutti. Lo stesso edificio, due
# caselle piu' in la', puo' essere una costruzione a terra da 3 pietra oppure
# lo spianamento di una tua bottega ancora intatta: due mosse diverse, stesso
# riquadro verde. Prima il giocatore la differenza la scopriva CLICCANDO,
# cioe' dopo.
#
# PURA come BoardLayout3D e CameraOrbita: entrano lo stato e una voce, esce
# testo. Nessun Node, nessun disegno, quindi le frasi si provano headless.
class_name DescrizioneAzione
extends RefCounted

# Il tipo della mossa in una parola. Per le costruzioni la parola cambia con
# quello che la mossa fa davvero: costruire su terra libera, salire di un
# livello e spianare un proprio edificio intatto sono tre cose diverse e il
# regolamento le paga in modo diverso.
static func tipo(v: AvailableActions.Voce) -> String:
	match v.tipo:
		"costruisci":
			if not _spianati(v).is_empty(): return "Spianata"
			return "Sopraelevazione" if bool(v.parametri.get("above", false)) \
				else "Costruzione"
		"potenzia": return "Potenziamento"
		"restaura": return "Ristrutturazione" if BoardLayout3D.senza_rudere() else "Restauro"
		"recluta": return "Reclutamento"
		"dinastia": return "Dinastia"
		"passa": return "Passo"
	return v.tipo.capitalize()

# Cosa finisce dove. I nomi vengono dai DATI, non dalla carta stampata.
static func frase(gs: GameState, v: AvailableActions.Voce, player: int) -> String:
	var b := _edificio(gs, int(v.parametri.get("uid", -1)))
	match v.tipo:
		"costruisci":
			var d: Dictionary = CardDB.buildings[str(v.parametri["card_id"])]
			var s := str(d["name"])
			var spianati := _spianati(v)
			if not spianati.is_empty():
				s += " al posto di " + ", ".join(spianati)
			elif int(v.parametri.get("level", 0)) > 0:
				s += " al livello %d" % int(v.parametri["level"])
			s += " · " + _colonne(int(v.parametri.get("col_from", 0)), int(d["width"]))
			var terr := int(v.parametri.get("terrapieni", 0))
			if terr > 0:
				s += " · %d terrapien%s" % [terr, "o" if terr == 1 else "i"]
			return s
		"potenzia":
			var nome := str(CardDB.upgrades[str(v.parametri["upg_id"])]["name"])
			return nome if b == null else "%s su %s" % [nome, b.data["name"]]
		"restaura":
			if b == null: return v.etichetta
			# Restaurare il rudere di un altro te lo fa tuo: e' meta' del
			# motivo per farlo, quindi si dice prima e non dopo.
			return "%s%s" % [b.data["name"],
				"" if b.owner == player else " (di G%d: diventa tuo)" % b.owner]
		"recluta":
			return v.etichetta.trim_prefix("Recluta ")
	return v.etichetta

# Il verbo del tasto: nella v2 non c'e' il rudere, si RISTRUTTURA la propria
# rovina; nella v1.5 si restaura il rudere, anche altrui.
static func verbo_restauro() -> String:
	return "Ristruttura" if BoardLayout3D.senza_rudere() else "Restaura"

# Il conto. Zero non si scrive "0 pietra 0 oro": si scrive che non costa.
static func prezzo(v: AvailableActions.Voce) -> String:
	if v.pietra == 0 and v.oro == 0 and v.idee == 0: return "gratis"
	var parti := PackedStringArray()
	if v.pietra != 0: parti.append("%d pietra" % v.pietra)
	if v.oro != 0: parti.append("%d oro" % v.oro)
	if v.idee != 0: parti.append("%d Idee" % v.idee)
	return " ".join(parti)

# Quanto manca per pagarla, "" se il prezzo c'e'. Legale e pagabile sono due
# cose diverse e il giocatore deve vederle diverse: il posto resta acceso
# perche' la mossa e' permessa, ma il conto non torna.
static func ammanco(v: AvailableActions.Voce, p: PlayerState) -> String:
	var parti := PackedStringArray()
	if v.pietra > p.pietra: parti.append("%d pietra" % (v.pietra - p.pietra))
	if v.oro > p.oro: parti.append("%d oro" % (v.oro - p.oro))
	if v.idee > p.idee: parti.append("%d Idee" % (v.idee - p.idee))
	return "" if parti.is_empty() else "ti manca " + " e ".join(parti)

# La riga intera, meno l'ammanco: quello lo scrive la barra a parte, in rosso.
static func riga(gs: GameState, v: AvailableActions.Voce, player: int) -> String:
	var s := "%s · %s · %s" % [tipo(v), frase(gs, v, player), prezzo(v)]
	# Se il lavoratore non e' ancora sul tabellone, cliccare qui lo mette: e'
	# una conseguenza che non si vede nel riquadro acceso, quindi si scrive.
	if v.parametri.has("attiva"):
		s += " · attiva la colonna %d" % int(v.parametri["attiva"])
	return s

static func _spianati(v: AvailableActions.Voce) -> PackedStringArray:
	var s = v.parametri.get("spiana", PackedStringArray())
	return s if s is PackedStringArray else PackedStringArray(s)

static func _colonne(col_from: int, larghezza: int) -> String:
	if larghezza <= 1: return "colonna %d" % col_from
	return "colonne %d-%d" % [col_from, col_from + larghezza - 1]

static func _edificio(gs: GameState, uid: int) -> Building:
	if uid < 0: return null
	for b in gs.grid.buildings:
		if b.uid == uid: return b
	return null
