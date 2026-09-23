#!/usr/bin/env python3
"""Impagina in Markdown il racconto di una partita.

    godot --headless res://scenes/audit_partita.tscn -- \
        --players 2 --seed 4008 --perche > p.txt
    python3 tools/impagina_partita.py p.txt docs/partita-4008.md

Il testo del tool e' gia' il racconto: qui si mette in forma leggibile - un
capitolo per era, il turno in grassetto, il ragionamento del bot rientrato -
senza riscriverlo. Quel che il documento dice lo dice il motore: se domani i
bot cambiano idea, cambia il documento, non questo script.
"""
import re, sys

fuori = []
def w(s=""): fuori.append(s)

righe = [l.rstrip("\n") for l in open(sys.argv[1], encoding="utf-8")]
righe = [l for l in righe if not l.startswith("Godot Engine")]

testa, corpo = [], []
for l in righe:
    (corpo if corpo or l.startswith("--- ERA") else testa).append(l)

# --- intestazione: chi gioca, con cosa, su che strada ---------------
seme = players = None
strategie, eredita = [], []
for l in testa:
    m = re.match(r"=== Seme (\d+) · (\d+) giocatori", l)
    if m: seme, players = m.group(1), m.group(2)
    m = re.match(r"\s+giocatore (\d+) gioca (\w+)", l)
    if m: strategie.append((m.group(1), m.group(2)))
    m = re.match(r"\s+giocatore (\d+) · eredita' segreta: (.+)", l)
    if m: eredita.append((m.group(1), m.group(2)))
terreni = next((l.split(": ", 1)[1] for l in testa if l.startswith("Terreni:")), "")
monumenti = next((l.split(": ", 1)[1] for l in testa if l.startswith("Monumenti")), "")

w(f"# La partita col seme {seme}, turno per turno")
w()
w(f"Due bot, {players} giocatori, rigiocata dal motore vero "
  "(`scripts/tools/audit_partita.gd --perche`). Ogni mossa porta con sé **la "
  "classifica che il bot si è fatto in testa**: la colonna che ha scelto e "
  "quanto valeva, la mossa che ha fatto e da quali voci era fatto il suo "
  "punteggio, e le mosse che ha scartato. Non è una ricostruzione a posteriori "
  "— i numeri escono dal valutatore mentre decide.")
w()
w("| | chi | strategia | eredità segreta |")
w("|---|---|---|---|")
for (i, st), (_, er) in zip(strategie, eredita):
    w(f"| g{i} | giocatore {i} | **{st}** | {er} |")
w()
w(f"**La strada**: {terreni} (colonne da 0 a {len(terreni.split()) - 1}). "
  f"**Monumenti aperti**: {monumenti}")
w()
w("> **Come si legge il ragionamento.** Il bot sceglie prima *dove* mandare il "
  "lavoratore — la colonna vale per quel che il terreno produce, per gli "
  "edifici suoi che ci sono già, per l'edificio che il lavoratore salverebbe "
  "dall'evento e per la migliore mossa che quella colonna gli aprirebbe — e "
  "poi, fra le mosse che quella colonna gli apre davvero, prende quella che "
  "vale di più. I due numeri possono non combaciare: la colonna si sceglie con "
  "le risorse che si hanno, e *dopo* il bot converte la pietra in oro se gli "
  "serve, quindi la mossa può valere più di quanto la colonna prometteva.")
w()

# --- corpo: un capitolo per era -------------------------------------
# Il tool stampa il ragionamento PRIMA della riga del turno - il bot spiega
# mentre decide, e il riassunto arriva a mossa fatta - mentre a leggerlo si
# vuole prima sapere cosa e' successo e poi perche'. Qui si tiene da parte il
# ragionamento e lo si posa sotto il suo turno.
perche = []
def scarica_turno(titolo, cosa):
    w(f"**{titolo}** — {cosa}")
    w()
    for r in perche:
        w(r)
    if perche: w()
    perche.clear()

for l in corpo:
    m = re.match(r"--- ERA (\d+) · evento: (.+?) · ordine (.+) ---", l)
    if m:
        w()
        w(f"## Era {m.group(1)} — evento: *{m.group(2)}*")
        w()
        w(f"Ordine di turno: {m.group(3)}.")
        w()
        continue
    if re.match(r"\s+g\d+:", l):
        w(f"*In cassa a inizio era:* {l.strip()}")
        w()
        continue
    m = re.match(r"E(\d+) t(\d+) · g(\d+) · (.+)", l)
    if m:
        scarica_turno(f"Turno {int(m.group(2))} · g{m.group(3)}", m.group(4))
        continue
    if l.startswith("    · "):
        perche.append("- " + l.strip()[2:])
        continue
    # IL REGISTRO PRIMA: le sue righe cominciano con otto spazi e un punto, e
    # otto spazi cominciano anche per sei - controllando prima il rientro
    # corto, le righe di registro finivano in mezzo ai ragionamenti.
    if l.lstrip().startswith(". ["):
        w(f"  > {l.strip()[2:]}")
        continue
    if l.startswith("      "):
        perche.append("  - " + l.strip())
        continue
    if l.startswith("=== FINE PARTITA"):
        w()
        w("## Come è finita")
        w()
        w("```")
        w(l.replace("=== ", "").replace(" ===", ""))
        continue
    if l.startswith("---") or l.strip() == "":
        continue
    w(l)
w("```")

open(sys.argv[2], "w", encoding="utf-8").write("\n".join(fuori) + "\n")
print("scritto", sys.argv[2], "-", len(fuori), "righe")
