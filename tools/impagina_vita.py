#!/usr/bin/env python3
# Impagina in Markdown le righe CSV di `audit_partita --vita`.
#
#   godot --headless res://scenes/audit_partita.tscn -- --players 3 --vita 2500 --seed 100000 > vita_0.csv
#   ...uno per seme, poi:
#   python3 tools/impagina_vita.py "vita_*.csv" docs/vita-degli-edifici.md
#
# I file si sommano: le partite si possono spezzare su piu' processi.
import sys, glob, statistics as st

NUM = ["n","ere_intatto","ere_piedi","n_rudere","n_rovina","n_sepolto","n_subito",
       "n_in_piedi_fine","n_intatto_fine","vetusta","potenziamenti","vp",
       "vp_lampo","vp_rendita","vp_verticalita","vp_scavo","vp_scheletri"]

def leggi(pattern):
    """Somma i CSV che corrispondono al pattern: le partite si possono
    spezzare su piu' processi, e i file si sommano riga per riga."""
    # Prima che esistessero le strategie l'unico bot era quello a caso, e
    # prima che la tabella finisse nell'intestazione c'era quella ripida: un
    # CSV senza quei campi viene da li'.
    carte, partite, giocatori, bot, vert, prosp, rov, bin, ver = ({}, 0, None, "caso",
                                                                 "2/6/12/20", 3, 2, "per_era", 1)
    strat = None
    for f in sorted(glob.glob(pattern)):
        righe = [l.rstrip("\n") for l in open(f) if l.strip()]
        meta = [l for l in righe if l.startswith("# partite=")][0]
        partite += int(meta.split("partite=")[1].split()[0])
        giocatori = int(meta.split("giocatori=")[1].split()[0])
        if "bot=" in meta: bot = meta.split("bot=")[1].split()[0]
        if "verticalita=" in meta: vert = meta.split("verticalita=")[1].split()[0]
        # La soglia del Centro Urbano e' arrivata dopo: un CSV che non la
        # dichiara viene da quando erano tre edifici.
        if "prosperita=" in meta: prosp = int(meta.split("prosperita=")[1].split()[0])
        # Anche la soglia della rovina e' arrivata dopo: un CSV che non la
        # dichiara viene da quando si crollava fallendo di 2.
        if "rovina=" in meta: rov = int(meta.split("rovina=")[1].split()[0])
        # E i binari: un CSV che non lo dice viene da quando ogni era aveva
        # il suo.
        if "binari=" in meta: bin = meta.split("binari=")[1].split()[0]
        # La versione del bot: un CSV che non la dice viene dal bot che
        # sceglieva la colonna prima dell'attivazione (versione 1).
        if "versione_bot=" in meta: ver = int(meta.split("versione_bot=")[1].split()[0])
        # Quante strategie al tavolo: un CSV che non lo dice viene da quando
        # il canone ne aveva cinque (o dal bot a caso, che non ne ha).
        if "strategie=" in meta: strat = int(meta.split("strategie=")[1].split()[0])
        i = righe.index([l for l in righe if l.startswith("id;")][0])
        hdr = righe[i].split(";")
        for l in righe[i+1:]:
            v = dict(zip(hdr, l.split(";")))
            c = carte.get(v["id"])
            if c is None:
                # Prima volta che si vede questa carta: si prende la riga.
                # ATTENZIONE: qui c'era `setdefault` seguito da una somma, e la
                # riga del PRIMO file finiva contata due volte - una nel
                # costruire il totale e una nel sommarci sopra, perche' il dizionario
                # appena creato non e' mai lo stesso oggetto della riga letta.
                # Con quattro spezzoni tutte le medie "per partita" uscivano
                # gonfiate del 25%.
                carte[v["id"]] = {k: (int(v[k]) if k in NUM else v[k]) for k in v}
            else:
                for k in NUM: c[k] += int(v[k])
    if strat is None: strat = 5 if bot == "strategie" else 0
    return carte, partite, giocatori, bot, vert, prosp, rov, bin, ver, strat

carte, partite, giocatori, bot, vert, prosp, rov, bin, ver, strat = leggi(sys.argv[1])
altro = None
if "--confronta" in sys.argv:
    altro, partite_altro, _, bot_altro, vert_altro, prosp_altro, rov_altro, bin_altro, ver_altro, strat_altro = leggi(
        sys.argv[sys.argv.index("--confronta") + 1])
    # LE COLONNE SI CHIAMANO COME TUTTO CIO' CHE LE DISTINGUE, non come la
    # prima differenza trovata. Due lotti possono differire in piu' di una
    # regola per volta - e' successo coi binari liberi insieme alla soglia
    # della Prosperita' - e allora il titolo ne nominava una sola: un
    # confronto che dichiara male cosa lo separa fa attribuire un effetto
    # alla causa sbagliata, che e' il difetto peggiore di tutti.
    def nomi_bot(b): return "bot a caso" if b == "caso" else "bot con strategia"
    DIFF = []          # (etichetta A, etichetta B, pezzo di titolo)
    if bot != bot_altro:
        DIFF.append((nomi_bot(bot_altro), nomi_bot(bot), "i bot che giocano davvero"))
    if ver != ver_altro:
        nomi_ver = {1: "il bot che sceglie prima di incassare",
                    2: "il bot che valuta dopo l'attivazione"}
        DIFF.append((f"bot v{ver_altro}", f"bot v{ver}",
                     nomi_ver.get(ver, f"il bot versione {ver}")))
    if strat != strat_altro and bot == bot_altro == "strategie":
        DIFF.append((f"{strat_altro} strategie", f"{strat} strategie",
                     f"{strat} strategie al tavolo"))
    if vert != vert_altro:
        DIFF.append((f"Verticalità {vert_altro}", f"Verticalità {vert}",
                     f"la Verticalità {vert}"))
    if rov != rov_altro:
        DIFF.append((f"rovina a −{rov_altro}", f"rovina a −{rov}",
                     f"la rovina solo fallendo di {rov}"))
    if prosp != prosp_altro:
        DIFF.append((f"Centro a {prosp_altro}", f"Centro a {prosp}",
                     f"il Centro Urbano a {prosp} edifici"))
    if bin != bin_altro:
        DIFF.append(("binari per era" if bin_altro == "per_era" else "binari liberi",
                     "binari per era" if bin == "per_era" else "binari liberi",
                     "i binari liberi" if bin == "liberi" else "i binari legati all'era"))
    if not DIFF:
        COL_A, COL_B = "prima", "dopo"
        TITOLO = "Due lotti a parità di regole"
        SOTTO = (f"Le stesse misure su {partite_altro} partite e {partite} altre, "
                 "con le stesse regole: quello che si vede è solo rumore.")
    else:
        COL_A = " · ".join(d[0] for d in DIFF)
        COL_B = " · ".join(d[1] for d in DIFF)
        pezzi = [d[2] for d in DIFF]
        titolo = pezzi[0] if len(pezzi) == 1 else ", ".join(pezzi[:-1]) + " e " + pezzi[-1]
        TITOLO = "Cosa cambia con " + titolo
        # "Stessi bot" si scrive solo se e' vero: quando a cambiare e' proprio
        # il bot, dirlo uguale sarebbe la frase sbagliata nel posto sbagliato.
        uguali = ["stessi semi"]
        if bot == bot_altro and ver == ver_altro and strat == strat_altro:
            uguali.append("stessi bot")
        uguali.append("stesso numero di giocatori")
        SOTTO = (f"Le stesse misure su {partite_altro} partite con **{COL_A}** e "
                 f"{partite} con **{COL_B}**, a parità di tutto il resto: "
                 + ", ".join(uguali) + "."
                 + ("" if len(DIFF) == 1 else
                    " **Le regole cambiate sono più di una**, quindi la colonna Δ è "
                    "l'effetto del pacchetto, non di una sola."))

def r(c, k, d=None):
    d = d or c["n"]
    return c[k] / d if d else 0.0

vive = [c for c in carte.values() if c["n"] > 0]
mai = [c for c in carte.values() if c["n"] == 0]
for c in vive:
    c["vita"] = r(c, "ere_piedi")
    c["intatto"] = r(c, "ere_intatto")
    c["pv"] = r(c, "vp")
    c["sep"] = 100 * r(c, "n_sepolto")
    c["fine"] = 100 * r(c, "n_in_piedi_fine")
    c["subito"] = 100 * r(c, "n_subito")
    c["vet"] = r(c, "vetusta")
    c["freq"] = c["n"] / partite
    # Un edificio dell'era 4 puo' vivere al massimo 2 ere, uno dell'era 5 una
    # sola: confrontare le ere secche mette in cima alla classifica delle vite
    # brevi le carte che sono semplicemente nate tardi. La quota di vita
    # sfruttata - quanto e' durato su quanto poteva durare - si puo'
    # confrontare fra ere diverse.
    c["possibili"] = 6 - int(c["era"])
    c["quota"] = 100 * c["vita"] / c["possibili"]
    c["equiv"] = int(c["costo_pietra"]) + 2 * int(c["costo_oro"])
    c["resa"] = c["pv"] / max(1, c["equiv"])

O = []
def w(s=""): O.append(s)

w("# La vita degli edifici")
w()
w(f"Misurata su **{partite:_} partite** a {giocatori} giocatori, rigiocate dal motore vero ".replace("_", " ")
  + "(`scripts/tools/audit_partita.gd`, modalità `--vita`). "
  + f"In tutto {sum(c['n'] for c in vive):,} edifici costruiti.".replace(",", " "))
w()
if bot == "caso":
    w("> **Avvertenza, e non è piccola.** A giocare sono i bot casuali (`RandomBot`): scelgono")
    w("> una colonna a caso e provano le azioni in ordine casuale. Nessuno protegge quello che")
    w("> ha costruito, nessuno punta a una colonna, nessuno tiene da parte l'oro per il")
    w("> restauro. Quindi questi numeri dicono **cosa fa il gioco quando nessuno lo guida**:")
    w("> sono la linea di base della carta, non il suo rendimento in mano a un giocatore.")
else:
    elenco = "Rendita, Lampo, Scavo, Verticale, Bilanciata" + (", Obiettivi" if strat >= 6 else "")
    numeri = {5: "cinque", 6: "sei", 7: "sette"}
    w(f"> **Chi ha giocato.** I bot seguono le {numeri.get(strat, strat)} strategie (`StrategyBot`): {elenco}.")
    w("> Valutano tutte le mosse legali e pagabili e scelgono la")
    w("> migliore secondo la loro inclinazione; la strategia ruota di posto a ogni partita, così")
    w("> nessuna gioca sempre dalla stessa sedia. Non sono campioni — non bluffano, non")
    w("> guardano cosa stanno per fare gli altri — ma **giocano**: dove il bot casuale fa 66")
    w("> punti, questi ne fanno 120.")
w()
w("## Come leggere le colonne")
w()
w("| colonna | cosa misura |")
w("|---|---|")
w("| **per partita** | quante copie di quella carta finiscono in tavola in una partita |")
w("| **ere intatto** | quante ere resta INTATTO, contando quella in cui è stato costruito. 1,0 = diventa rudere alla fine dell'era stessa in cui è nato |")
w("| **ere in piedi** | quante ere resta in piedi, cioè finché non crolla in rovina o finisce sotterrato |")
w("| **subito** | quota che cade o viene sepolto nell'era stessa in cui è stato costruito |")
w("| **a fine partita** | quota ancora in piedi all'ultimo conteggio |")
w("| **sepolto** | quota che finisce sotto un altro edificio (e quindi paga lo Scavo) |")
w("| **vetustà** | cubetti bianchi accumulati, letti a fine partita |")
w("| **vita sfruttata** | ere in piedi su quelle che poteva vivere: una carta dell'era 4 al massimo ne vive 2, una dell'era 5 una sola. È l'unica misura confrontabile fra ere diverse |")
w("| **PV** | punti che quella carta ha fruttato, in media, in tutta la partita |")
w("| **PV/costo** | gli stessi punti divisi per il costo in pietra equivalente (1 oro = 2 pietra) |")
w()
w("I PV sono attribuiti **alla carta, non al giocatore**: un edificio restaurato e rubato")
w("porta con sé anche i punti che aveva fatto fare al padrone di prima. I canali contati")
w("sono i cinque che si possono attribuire a un edificio senza inventare nulla:")
w()
w("- **Lampo** — il punto alla costruzione;")
w("- **Rendita** — incassata a ogni censimento finché l'edificio è intatto, più la Vetustà;")
w("- **Verticalità** — metà del premio della colonna a chi ha la cima, l'altra metà divisa")
w("  per numero di edifici: è la regola stessa a dividerla per carta, quindi la quota di un")
w("  edificio è un numero vero;")
w("- **Scavo** — il valore stampato, se finisce sotterrato;")
w("- **Scheletri** — il personaggio sepolto sotto, se l'edificio è sotterrato.")
w()
w("Restano fuori **Continuità** (è della colonna, non di una carta), **Monumenti**,")
w("**Eredità** e la **Cultura** (vanno al giocatore). Il conto dei cinque canali torna")
w("esatto col tabellone: c'è un test che lo verifica su partite intere")
w("(`test_actions`, «il libro mastro degli edifici torna col tabellone»).")
w()

def tabella(righe, titolo, nota=""):
    w(f"### {titolo}")
    if nota: w(); w(nota)
    w()
    w("| carta | costo | res | rend | scavo | per partita | ere intatto | ere in piedi | vita sfruttata | subito | a fine partita | sepolto | vetustà | PV | PV/costo | (L/R/V/S/Sk) |")
    w("|---|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|---|")
    for c in righe:
        costo = f"{c['costo_pietra']}P" + (f"+{c['costo_oro']}O" if int(c['costo_oro']) else "")
        canali = "/".join(f"{r(c,'vp_'+k):.1f}" for k in ("lampo","rendita","verticalita","scavo","scheletri"))
        w(f"| {c['nome']} | {costo} | {c['resistenza']} | {c['rendita']} | {c['scavo']} | "
          f"{c['freq']:.2f} | {c['intatto']:.2f} | {c['vita']:.2f} | {c['quota']:.0f}% | {c['subito']:.0f}% | "
          f"{c['fine']:.0f}% | {c['sep']:.0f}% | {c['vet']:.2f} | **{c['pv']:.1f}** | {c['resa']:.1f} | {canali} |")
    w()

w("## Il quadro d'insieme")
w()
tot_n = sum(c["n"] for c in vive)
w("| era | carte | costruiti/partita | ere intatto | ere in piedi | subito | a fine partita | sepolto | PV medi |")
w("|---|--:|--:|--:|--:|--:|--:|--:|--:|")
for e in ("1","2","3","4","5"):
    g = [c for c in vive if c["era"] == e]
    if not g: continue
    n = sum(c["n"] for c in g)
    w(f"| era {e} | {len(g)} | {n/partite:.1f} | {sum(c['ere_intatto'] for c in g)/n:.2f} | "
      f"{sum(c['ere_piedi'] for c in g)/n:.2f} | {100*sum(c['n_subito'] for c in g)/n:.0f}% | "
      f"{100*sum(c['n_in_piedi_fine'] for c in g)/n:.0f}% | {100*sum(c['n_sepolto'] for c in g)/n:.0f}% | "
      f"{sum(c['vp'] for c in g)/n:.1f} |")
w()
w(f"In media una partita mette in tavola **{tot_n/partite:.1f} edifici**; "
  f"di questi **{100*sum(c['n_in_piedi_fine'] for c in vive)/tot_n:.0f}%** è ancora in piedi alla fine, "
  f"**{100*sum(c['n_sepolto'] for c in vive)/tot_n:.0f}%** finisce sotterrato e "
  f"**{100*sum(c['n_subito'] for c in vive)/tot_n:.0f}%** non supera l'era in cui è nato.")
w()

w("## Cosa salta all'occhio")
w()

def med(g, k, d="n"):
    n = sum(c[d] for c in g)
    return sum(c[k] for c in g) / n if n else 0.0

w("**1. La Rendita è il canale che paga la durata, ed è quasi tutto.** Le "
  + f"{len([c for c in vive if int(c['rendita'])>0])} carte con Rendita stampata fruttano in media "
  + f"**{med([c for c in vive if int(c['rendita'])>0],'vp'):.1f} PV** contro i "
  + f"**{med([c for c in vive if int(c['rendita'])==0],'vp'):.1f}** delle altre, e restano in piedi "
  + f"{med([c for c in vive if int(c['rendita'])>0],'ere_piedi'):.2f} ere contro "
  + f"{med([c for c in vive if int(c['rendita'])==0],'ere_piedi'):.2f}. Non è una sorpresa — la Rendita si "
  "incassa a ogni censimento — ma dice che il valore di una carta lo decide quasi tutto un "
  "numero solo.")
w()
w("**2. La resistenza fa esattamente il suo mestiere.** Sulle ere 1-4, per ogni punto di resistenza:")
w()
w("| resistenza | carte | ere in piedi | cade nella sua era | PV medi |")
w("|---|--:|--:|--:|--:|")
for res in sorted({int(c["resistenza"]) for c in vive}):
    g = [c for c in vive if int(c["resistenza"]) == res and c["era"] != "5"]
    if not g: continue
    w(f"| {res} | {len(g)} | {med(g,'ere_piedi'):.2f} | {100*med(g,'n_subito'):.0f}% | {med(g,'vp'):.1f} |")
w()
w("Fra resistenza 1 e resistenza 4 la vita raddoppia e i punti quasi triplicano. Il salto "
  "vero è **fra 2 e 3**: è lì che un edificio smette di essere materiale da riempimento.")
w()
magre = [c for c in vive if c["era"] == "1" and int(c["costo_pietra"]) <= 1 and int(c["costo_oro"]) == 0]
if magre:
    w("**3. Le carte da una pietra dell'era 1 non sono edifici: sono Scavo da seminare.** "
      + ", ".join(sorted(c["nome"] for c in magre))
      + f" vivono {med(magre,'ere_piedi'):.1f} ere, finiscono sotto nel "
      + f"**{100*med(magre,'n_sepolto'):.0f}%** dei casi e "
      + f"{100*med(magre,'vp_scavo')/max(0.01, med(magre,'vp')):.0f} punti su cento di quello che "
      "fruttano sono Scavo. Funzionano — ma solo se chi le gioca sa che le sta seminando, "
      "non costruendo.")
w()
w("**4. Un edificio dell'era 5 non può morire.** Gli eventi sono solo nelle ere 1-4: chi "
  "costruisce nell'era Moderna non vedrà mai un censimento né un evento. Si vede nei numeri: "
  f"vetustà **{med([c for c in vive if c['era']=='5'],'vetusta'):.2f}**, Rendita "
  f"**{med([c for c in vive if c['era']=='5'],'vp_rendita'):.2f}**, Scavo "
  f"**{med([c for c in vive if c['era']=='5'],'vp_scavo'):.2f}**, e il "
  f"**{100*med([c for c in vive if c['era']=='5'],'n_in_piedi_fine'):.0f}%** ancora in piedi. "
  "Le carte dell'era 5 pagano solo Lampo e Verticalità, e vanno lette con un metro diverso "
  "dalle altre: il loro valore è tutto nell'istante in cui le metti.")
w()
w("**5. I colossali prendono la cima di tre colonne.** Un edificio da tre caselle conta come "
  "strato in tutte le colonne che tocca — quindi incassa il premio della cima **tre volte**:")
w()
w("| larghezza | carte | costruiti | PV medi | di cui Verticalità |")
w("|---|--:|--:|--:|--:|")
for larg in ("1", "2", "3"):
    g = [c for c in vive if c["larghezza"] == larg]
    if not g: continue
    nome = "1 casella" if larg == "1" else f"{larg} caselle"
    w(f"| {nome} | {len(g)} | {sum(c['n'] for c in g):,} | "
      .replace(",", " ") + f"{med(g,'vp'):.1f} | {med(g,'vp_verticalita'):.1f} |")
w()
st_ = [c for c in vive if c["nome"] == "Stazione"]
if st_:
    c = st_[0]
    secondo = sorted((x for x in vive if x is not c), key=lambda x: -x["pv"])[0]
    quanto = "una volta ogni %.0f partite" % (1 / c["freq"]) if c["freq"] < 1 else "%.1f volte a partita" % c["freq"]
    w(f"Il caso limite è la **Stazione** (era 5, tre caselle, {c['costo_pietra']}P+{c['costo_oro']}O): "
      f"**{c['pv']:.1f} PV medi**, di cui {r(c,'vp_verticalita'):.1f} di sola Verticalità — "
      f"contro i {secondo['pv']:.1f} della seconda della lista, {secondo['nome']}. Arriva in tavola "
      f"{quanto}, quindi non rompe la media, ma quando arriva decide la colonna. Vale la pena "
      "chiedersi se il premio della cima debba contare una volta per edificio invece che una "
      "volta per colonna.")
w()
w("## Gli estremi")
w()
tabella(sorted(vive, key=lambda c: c["quota"])[:12], "Le dodici vite più brevi",
        "Ordinate per **vita sfruttata**, non per ere secche: se no in testa finirebbero le carte dell'era 5, che vivono una sola era perché la partita finisce, non perché crollano.")
tabella(sorted(vive, key=lambda c: -c["quota"])[:12], "Le dodici che arrivano in fondo",
        "Ordinate per vita sfruttata.")
tabella(sorted(vive, key=lambda c: -c["pv"])[:12], "Le dodici che rendono di più",
        "Ordinate per PV medi fruttati al proprietario.")
tabella(sorted([c for c in vive if c["freq"] > 0.2], key=lambda c: -c["resa"])[:12],
        "Le dodici che rendono di più per quello che costano",
        "Ordinate per PV diviso il costo in pietra equivalente.")
tabella(sorted([c for c in vive if c["freq"] > 0.2], key=lambda c: c["pv"])[:12],
        "Le dodici che rendono di meno",
        "Solo carte che arrivano in tavola almeno una volta ogni cinque partite: una carta rara ha medie ballerine.")
tabella(sorted(vive, key=lambda c: -c["sep"])[:12], "Le dodici più sepolte",
        "Ordinate per quota di copie finite sotto un altro edificio.")

w("## Tutte le carte, era per era")
w()
for e in ("1","2","3","4","5"):
    g = sorted([c for c in vive if c["era"] == e], key=lambda c: -c["vita"])
    if g: tabella(g, f"Era {e}")

if mai:
    w("## Carte che non sono mai arrivate in tavola")
    w()
    w("In " + f"{partite:,}".replace(",", " ") + " partite non è mai stata costruita nemmeno una copia di:")
    w()
    for c in sorted(mai, key=lambda c: (c["era"], c["nome"])):
        w(f"- **{c['nome']}** (era {c['era']}, {c['costo_pietra']}P"
          + (f"+{c['costo_oro']}O" if int(c['costo_oro']) else "") + ")")
    w()

# correlazioni
def corr(xs, ys):
    mx, my = st.mean(xs), st.mean(ys)
    num = sum((x-mx)*(y-my) for x, y in zip(xs, ys))
    den = (sum((x-mx)**2 for x in xs) * sum((y-my)**2 for y in ys)) ** 0.5
    return num/den if den else 0.0

grandi = [c for c in vive if c["n"] >= 50]
w("## Due correlazioni, su chi arriva in tavola almeno 50 volte")
w()
for nome, k in (("resistenza stampata", "resistenza"), ("costo in pietra", "costo_pietra"),
                ("Rendita stampata", "rendita"), ("Scavo stampato", "scavo")):
    xs = [int(c[k]) for c in grandi]
    w(f"- **{nome}** → ere in piedi: r = {corr(xs, [c['vita'] for c in grandi]):+.2f} · "
      f"→ PV: r = {corr(xs, [c['pv'] for c in grandi]):+.2f}")
w()
w("---")
w()
w("Rifare il conto: `godot --headless res://scenes/audit_partita.tscn -- "
  f"--players {giocatori} --vita 2500 --seed 100000` (quattro processi, semi 100000 / 102500 / 105000 / 107500).")
w()

if altro is not None:
    def somma(c, k): return sum(x[k] for x in c.values())
    na, nb = somma(altro, "n"), somma(carte, "n")
    w(f"## {TITOLO}")
    w()
    w(SOTTO + " La colonna Δ è la seconda meno la prima.")
    w()
    w(f"| misura | {COL_A} | {COL_B} | Δ |")
    w("|---|--:|--:|--:|")
    def riga(nome, va, vb, fmt="{:.2f}"):
        d = vb - va
        w(f"| {nome} | {fmt.format(va)} | {fmt.format(vb)} | {'+' if d >= 0 else '−'}{fmt.format(abs(d))} |")
    riga("edifici costruiti per partita", na/partite_altro, nb/partite)
    riga("ere intatto (media)", somma(altro,"ere_intatto")/na, somma(carte,"ere_intatto")/nb)
    riga("ere in piedi (media)", somma(altro,"ere_piedi")/na, somma(carte,"ere_piedi")/nb)
    riga("cade nella sua era", 100*somma(altro,"n_subito")/na, 100*somma(carte,"n_subito")/nb, "{:.0f}%")
    riga("in piedi a fine partita", 100*somma(altro,"n_in_piedi_fine")/na, 100*somma(carte,"n_in_piedi_fine")/nb, "{:.0f}%")
    riga("sepolto", 100*somma(altro,"n_sepolto")/na, 100*somma(carte,"n_sepolto")/nb, "{:.0f}%")
    riga("vetustà media", somma(altro,"vetusta")/na, somma(carte,"vetusta")/nb)
    riga("potenziamenti per edificio", somma(altro,"potenziamenti")/na, somma(carte,"potenziamenti")/nb)
    riga("PV per edificio", somma(altro,"vp")/na, somma(carte,"vp")/nb, "{:.1f}")
    riga("PV per partita (i tre giocatori insieme)", somma(altro,"vp")/partite_altro, somma(carte,"vp")/partite, "{:.0f}")
    w()
    w(f"| canale (PV per partita, tutti i giocatori) | {COL_A} | {COL_B} | Δ |")
    w("|---|--:|--:|--:|")
    for k in ("vp_lampo","vp_rendita","vp_verticalita","vp_scavo","vp_scheletri"):
        riga(k.replace("vp_","").capitalize(), somma(altro,k)/partite_altro, somma(carte,k)/partite, "{:.1f}")
    w()
    comuni = [i for i in altro if altro[i]["n"] >= 50 and i in carte]
    def dfreq(i): return carte[i]["n"]/partite - altro[i]["n"]/partite_altro
    def tabellina(titolo, lista, nota):
        w(f"### {titolo}")
        w()
        w(nota)
        w()
        w(f"| carta | era | costo | {COL_A} | {COL_B} | Δ | PV {COL_A} | PV {COL_B} |")
        w("|---|--:|--:|--:|--:|--:|--:|--:|")
        for i in lista:
            ca, cb = altro[i], carte[i]
            costo = f"{ca['costo_pietra']}P" + (f"+{ca['costo_oro']}O" if int(ca['costo_oro']) else "")
            d = dfreq(i)
            w(f"| {ca['nome']} | {ca['era']} | {costo} | {ca['n']/partite_altro:.2f} | "
              f"{cb['n']/partite:.2f} | {'+' if d>=0 else '−'}{abs(d):.2f} | "
              f"{ca['vp']/ca['n']:.1f} | {cb['vp']/max(1,cb['n']):.1f} |")
        w()
    tabellina("Le carte che si cercano di più", sorted(comuni, key=dfreq, reverse=True)[:10],
              "Copie costruite per partita, prima e dopo.")
    tabellina("E quelle che si cercano di meno", sorted(comuni, key=dfreq)[:10],
              "Le stesse carte, dall'altro capo della classifica.")
    scartate = [i for i in carte if carte[i]["n"] < partite * 0.02]
    if scartate:
        w("### Carte che non arrivano quasi mai in tavola")
        w()
        for i in sorted(scartate, key=lambda i: carte[i]["n"]):
            c = carte[i]
            costo = f"{c['costo_pietra']}P" + (f"+{c['costo_oro']}O" if int(c['costo_oro']) else "")
            quante = "mai" if c["n"] == 0 else f"una ogni {partite/c['n']:.0f} partite"
            prima = f", contro una ogni {partite_altro/altro[i]['n']:.0f} prima" \
                if i in altro and altro[i]["n"] else ""
            w(f"- **{c['nome']}** (era {c['era']}, {costo}) — {quante}{prima}")
        w()

open(sys.argv[2], "w").write("\n".join(O) + "\n")
print("scritto", sys.argv[2], "-", len(vive), "carte vive,", len(mai), "mai costruite")
