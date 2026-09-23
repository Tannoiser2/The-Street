# res://scripts/ai/planning_bot.gd
# Il bot che PIANIFICA L'ERA. Usa lo stesso valutatore di StrategyBot - le
# stesse voci, la stessa spinta della strategia - ma invece di prendere la
# mossa migliore adesso cerca la SEQUENZA migliore per i lavoratori che gli
# restano nell'era: costruire una base col primo per salirci col terzo,
# tenersi l'oro per la carta cara invece di spenderlo subito, mettere il
# secondo edificio dove la classe c'e' gia'.
#
# RICERCA A FASCIO. Da ogni stato si provano le colonne migliori e, in
# ciascuna, le mosse migliori; si tengono le LARGHEZZA sequenze che valgono di
# piu' e si va avanti di un lavoratore. Si esegue solo il PRIMO passo della
# sequenza vincente, e al turno dopo si ripianifica da capo: il tavolo sara'
# cambiato, e un piano vecchio e' un piano sbagliato.
#
# Tutto si prova su COPIE della partita (`GameState.duplica`), giocate col
# codice vero: nessuna regola e' riscritta qui dentro.
#
# L'IPOTESI, DETTA CHIARA: pianificando, il bot fa finta che gli avversari
# stiano fermi - dopo ogni sua mossa simulata il turno torna a lui. E'
# ottimista, e lo sa: per questo si esegue un passo solo e si ripianifica.
# Guardare anche le mosse degli altri e' il livello successivo.
class_name PlanningBot
extends RefCounted

const LARGHEZZA := 4      # sequenze tenute a ogni passo
const COLONNE := 2        # colonne esplorate da ogni stato
const MOSSE := 3          # mosse provate in ogni colonna
const PROFONDITA := 3     # lavoratori guardati avanti, al massimo

# Il taccuino, come per StrategyBot: acceso `racconta`, resta scritto il piano.
static var racconta := false
static var taccuino := {}

static func play_turn(ctl: GameController, strategia := "bilanciata") -> void:
	var gs := ctl.gs
	while not gs.pending_choice.is_empty():
		if not ctl.choose(StrategyBot._scelta(gs)): break
	if gs.phase == Enums.Phase.FINE_PARTITA: return
	var p := gs.current_player()
	var piano := pianifica(gs, p.index, strategia)
	if racconta: taccuino = piano.duplicate()
	if piano.is_empty() or (piano["passi"] as Array).is_empty():
		# Niente da pianificare: si gioca come il bot avido.
		StrategyBot.play_turn(ctl, strategia)
		return
	var primo: Dictionary = (piano["passi"] as Array)[0]
	var col := int(primo["col"])
	if not _piazza(ctl, col):
		ctl.pass_action()
		return
	var mossa = primo["mossa"]
	if mossa == null:
		ctl.pass_action()
		return
	if not StrategyBot._esegui(ctl, mossa):
		# Il passo pianificato sulla copia non si fa sul tavolo vero: capita
		# se lo stato non e' identico, e allora si ripiega sulla mossa migliore
		# adesso invece di buttare via il turno.
		var scelta := StrategyBot.migliore(StrategyBot.classifica(gs, p, col, strategia))
		if scelta.is_empty() or not StrategyBot._esegui(ctl, scelta["mossa"]):
			ctl.pass_action()

# Piazza il lavoratore ESATTAMENTE come il bot avido: protegge l'edificio che
# serve, attiva la colonna, e scambia pietra in oro se ha il Mercante ed e' a
# secco. Stesso gesto nella simulazione e sul tavolo, se no si pianifica una
# partita e se ne gioca un'altra.
static func _piazza(c: GameController, col: int) -> bool:
	var g := c.gs
	var p := g.current_player()
	if not c.place_worker(col, StrategyBot._da_proteggere(g, p, col)): return false
	while p.oro < 2 and p.pietra >= 4 and c.exchange(true):
		pass
	return true

# Il piano migliore per i lavoratori che restano: {"valore", "passi": [...]}
# dove ogni passo e' {"col", "mossa" (o null = passa), "valore"}.
static func pianifica(gs: GameState, chi: int, strategia: String) -> Dictionary:
	var p: PlayerState = gs.players[chi]
	var profondita := mini(p.workers - p.workers_used, PROFONDITA)
	if profondita <= 0: return {}
	var era := gs.era
	var frontiera: Array = [{"gs": gs, "valore": 0.0, "passi": []}]
	for _livello in profondita:
		var figli: Array = []
		for nodo in frontiera:
			var g: GameState = nodo["gs"]
			var pg: PlayerState = g.players[chi]
			# Un ramo arrivato in fondo - era finita, o lavoratori finiti -
			# resta com'e' e continua a gareggiare col suo valore.
			if g.era != era or g.phase == Enums.Phase.FINE_PARTITA \
				or pg.workers_used >= pg.workers or g.current_index != chi:
				figli.append(nodo)
				continue
			var colonne := StrategyBot.classifica_colonne(g, pg, strategia)
			colonne.sort_custom(func(a, b): return float(a["valore"]) > float(b["valore"]))
			for e in colonne.slice(0, COLONNE):
				var col := int(e["col"])
				var della_colonna := float(e["produzione"]) + float(e["protezione"])
				var dopo := g.duplica()
				var c := GameController.new()
				c.gs = dopo
				if not _piazza(c, col): continue
				var lista := StrategyBot.classifica(dopo, dopo.players[chi], col, strategia)
				lista.sort_custom(func(a, b): return float(a["valore"]) > float(b["valore"]))
				var provate := 0
				for m in lista:
					if provate >= MOSSE or float(m["valore"]) <= 0.0: break
					var figlio := dopo.duplica()
					var cf := GameController.new()
					cf.gs = figlio
					if not StrategyBot._esegui(cf, m["mossa"]): continue
					provate += 1
					_torna_a_me(figlio, chi, era)
					var passi: Array = (nodo["passi"] as Array).duplicate()
					passi.append({"col": col, "mossa": m["mossa"], "valore": float(m["valore"]),
						"colonna": della_colonna})
					figli.append({"gs": figlio,
						"valore": float(nodo["valore"]) + della_colonna + float(m["valore"]),
						"passi": passi})
				# E il lavoratore piazzato senza fare niente: a volte conviene
				# solo incassare, o tenere le risorse per il passo dopo.
				c.pass_action()
				_torna_a_me(dopo, chi, era)
				var fermi: Array = (nodo["passi"] as Array).duplicate()
				fermi.append({"col": col, "mossa": null, "valore": 0.0, "colonna": della_colonna})
				figli.append({"gs": dopo, "valore": float(nodo["valore"]) + della_colonna,
					"passi": fermi})
		if figli.is_empty(): break
		figli.sort_custom(func(a, b): return float(a["valore"]) > float(b["valore"]))
		frontiera = figli.slice(0, LARGHEZZA)
	if frontiera.is_empty(): return {}
	var meglio: Dictionary = frontiera[0]
	return {"valore": float(meglio["valore"]), "passi": meglio["passi"]}

# L'ipotesi ottimista: dopo la mia mossa simulata il turno torna a me, come
# se gli avversari stessero fermi. Solo sulla copia, e solo finche' l'era e'
# la stessa e ho ancora lavoratori.
static func _torna_a_me(g: GameState, chi: int, era: int) -> void:
	if g.era != era or g.phase == Enums.Phase.FINE_PARTITA: return
	if not g.pending_choice.is_empty(): return
	var pg: PlayerState = g.players[chi]
	if pg.workers_used >= pg.workers: return
	g.current_index = chi
	g.phase = Enums.Phase.PIAZZA
