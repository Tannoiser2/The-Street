# La partita col seme 4008, turno per turno

Due bot, 2 giocatori, rigiocata dal motore vero (`scripts/tools/audit_partita.gd --perche`). Ogni mossa porta con sé **la classifica che il bot si è fatto in testa**: la colonna che ha scelto e quanto valeva, la mossa che ha fatto e da quali voci era fatto il suo punteggio, e le mosse che ha scartato. Non è una ricostruzione a posteriori — i numeri escono dal valutatore mentre decide.

| | chi | strategia | eredità segreta |
|---|---|---|---|
| g0 | giocatore 0 | **rendita** | Il Cronista (5 PV) |
| g1 | giocatore 1 | **lampo** | Il Restauratore (4 PV) |

**La strada**: pia fiu fiu pia col (colonne da 0 a 4). **Monumenti aperti**: Catacombe (5 PV)

> **Come si legge il ragionamento.** Il bot sceglie prima *dove* mandare il lavoratore — la colonna vale per quel che il terreno produce, per gli edifici suoi che ci sono già, per l'edificio che il lavoratore salverebbe dall'evento e per la migliore mossa che quella colonna gli aprirebbe — e poi, fra le mosse che quella colonna gli apre davvero, prende quella che vale di più. I due numeri possono non combaciare: la colonna si sceglie con le risorse che si hanno, e *dopo* il bot converte la pietra in oro se gli serve, quindi la mossa può valere più di quanto la colonna prometteva.


## Era 1 — evento: *Età degli spiriti*

Ordine di turno: [0, 1].

*In cassa a inizio era:* g0: 2 pietra 0 oro, 0 PV | g1: 2 pietra 1 oro, 0 PV

**Turno 1 · g0** — lavoratore in col 4 · COSTRUISCE Dolmen (col 4-4, liv 0)

- **colonna 4** (10.7): terreno collina, produzione e roba mia 0.6, ci si puo' fare una mossa da 10.1
  - (la seconda era la 3 a 6.7)
- **Costruisci Dolmen a terra in col 4** (10.1) perche': rendite future +9.0 · spinta della strategia rendita +3.6 · costo -3.2 · Scavo suo +0.8
  - scartate: Costruisci Capanne a terra in col 4 1.6 · Acquista la Dinastia -0.4 · Costruisci Grotte dipinte a terra in col 4 -1.6

  > [E1] Inizia l'era 1. Evento: Età degli spiriti
**Turno 2 · g1** — lavoratore in col 0 · COSTRUISCE Capanne (col 0-0, liv 0)  [+1 pietra +0 oro]  {+1 lampo}

- **colonna 0** (5.3): terreno pianura, produzione e roba mia 0.6, ci si puo' fare una mossa da 4.7
  - (la seconda era la 3 a 5.3)
- **Costruisci Capanne a terra in col 0** (4.7) perche': produzione +3.2 · costo -1.6 · spinta della strategia lampo +1.6 · lampo subito +1.0 · Scavo suo +0.5
  - scartate: Costruisci Cava a terra in col 0 4.3 · Costruisci Focolare comune a terra in col 0 1.5 · Acquista la Dinastia -0.4

**Turno 3 · g1** — lavoratore in col 1 · COSTRUISCE Palafitte (col 1-1, liv 0)  [+0 pietra +1 oro]  {+1 lampo}

- **colonna 1** (5.2): terreno fiume, produzione e roba mia 0.5, ci si puo' fare una mossa da 4.7
  - (la seconda era la 2 a 5.2)
- **Costruisci Palafitte a terra in col 1** (4.7) perche': produzione +3.2 · costo -1.6 · spinta della strategia lampo +1.6 · lampo subito +1.0 · Scavo suo +0.5
  - scartate: Costruisci Cava a terra in col 1 4.3 · Costruisci Focolare comune a terra in col 1 1.5 · Costruisci Trappole da pesca a terra in col 1 0.6

**Turno 4 · g0** — lavoratore in col 3 · COSTRUISCE Circolo di pietre (col 3-4, liv 0)

- **colonna 3** (11.2): terreno pianura, produzione e roba mia 0.6, ci si puo' fare una mossa da 10.6
  - (la seconda era la 0 a 11.0)
- **Costruisci Circolo di pietre a terra in col 3** (10.6) perche': rendite future +9.0 · spinta della strategia rendita +3.6 · costo -3.2 · Scavo suo +1.2
  - scartate: Costruisci Circolo di pietre spianando Dolmen in col 3 9.6 · Costruisci Circolo di pietre a terra in col 2 9.0 · Costruisci Cava a terra in col 3 3.8

**Turno 5 · g0** — lavoratore in col 2 · COSTRUISCE Cava (col 2-2, liv 0)  [+0 pietra +1 oro]

- **colonna 2** (4.3): terreno fiume, produzione e roba mia 0.5, ci si puo' fare una mossa da 3.8
  - (la seconda era la 0 a 4.2)
- **Costruisci Cava a terra in col 2** (3.8) perche': produzione +6.4 · costo -1.6 · spinta della strategia rendita -1.5 · Scavo suo +0.5
  - scartate: Costruisci Approdo a terra in col 2 0.6 · Costruisci Trappole da pesca a terra in col 2 0.1 · Costruisci Focolare comune a terra in col 2 -1.6

**Turno 6 · g1** — Capanne: intatto -> rudere · seppellisce Mercante di ossidiana sotto Capanne · Cava: intatto -> rudere · RECLUTA Mercante di ossidiana  [-1 pietra +1 oro]

- **colonna 2** (3.3): terreno fiume, produzione e roba mia 0.3, ci si puo' fare una mossa da 3.0
  - (la seconda era la 3 a 1.9)
- **Recluta Mercante di ossidiana (commercio)** (3.0) perche': se lo seppellisco vale 5 +1.5 · la sua abilita' (commercio) +1.4 · un lavoratore in piu' +0.5 · costo -0.4
  - scartate: Costruisci Focolare comune a terra in col 2 1.5 · Costruisci Approdo a terra in col 2 1.1 · Costruisci Trappole da pesca a terra in col 2 0.6

  > [E1] Mercante di ossidiana: +0 pietra +1 oro
  > [E1] Reclutato Mercante di ossidiana
  > [E1] Capanne diventa rudere
  > [E1] Cava diventa rudere
  > [E1] Mercante di ossidiana sepolto sotto Capanne
  > [E2] Inizia l'era 2. Evento: Invasione

## Era 2 — evento: *Invasione*

Ordine di turno: [1, 0].

*In cassa a inizio era:* g0: 4 pietra 1 oro, 4 PV | g1: 2 pietra 3 oro, 2 PV

**Turno 7 · g1** — lavoratore in col 1 · Capanne: rudere -> rovina · Capanne sepolto · Palafitte: intatto -> rovina · Palafitte sepolto · Cava: rudere -> rovina · Cava sepolto · COSTRUISCE Acquedotto (col 0-2, liv 1)  [+1 pietra +1 oro]

  - g0 {+4 rendita}
- **colonna 1** (10.4): terreno fiume, produzione e roba mia 1.3, il lavoratore salva Palafitte dall'evento (1.5), ci si puo' fare una mossa da 7.6
  - (la seconda era la 0 a 8.2)
- **Costruisci Acquedotto spianando Palafitte in col 0** (7.6) perche': rendite future +5.0 · Verticalita' della colonna +3.0 · Scavo dei miei che vanno sotto +2.0 · costo -1.6 · spinta della strategia lampo -1.0 · Scavo suo +0.8 · quel che perdo spianando -0.5
  - scartate: Costruisci Terme spianando Palafitte in col 1 7.3 · Costruisci Teatro spianando Palafitte in col 1 6.3 · Costruisci Foro spianando Palafitte in col 0 6.2

**Turno 8 · g0** — lavoratore in col 0 · COSTRUISCE Anfiteatro (col 0-2, liv 0)  [-2 pietra +0 oro]

- **colonna 0** (18.5): terreno pianura, produzione e roba mia 0.4, ci si puo' fare una mossa da 18.1
  - (la seconda era la 1 a 18.4)
- **Costruisci Anfiteatro a terra in col 0** (18.1) perche': rendite future +17.0 · costo -6.4 · spinta della strategia rendita +5.4 · Scavo suo +1.5 · produzione +0.6
  - scartate: Costruisci Foro a terra in col 0 3.3 · Acquista la Dinastia 1.2 · Costruisci Teatro a terra in col 0 -1.5

**Turno 9 · g1** — lavoratore in col 0 · COSTRUISCE Terme (col 0-0, liv 0)  {+2 lampo}

- **colonna 0** (5.4): terreno pianura, produzione e roba mia 1.2, ci si puo' fare una mossa da 4.2
  - (la seconda era la 2 a 4.3)
- **Costruisci Terme a terra in col 0** (4.2) perche': costo -3.2 · spinta della strategia lampo +3.2 · lampo subito +2.0 · continuita' di classe in colonna +1.5 · Scavo suo +0.8
  - scartate: Costruisci Teatro a terra in col 0 3.2 · Potenzia con Statua 2.1 · Potenzia con Iscrizione 2.1

**Turno 10 · g0** — lavoratore in col 4 · COSTRUISCE Foro (col 3-4, liv 0)

- **colonna 4** (6.8): terreno collina, produzione e roba mia 2.2, ci si puo' fare una mossa da 4.6
  - (la seconda era la 3 a 6.0)
- **Costruisci Foro a terra in col 3** (3.3) perche': costo -3.2 · spinta della strategia rendita +2.7 · rendite future +2.0 · Scavo suo +1.2 · produzione +0.6
  - scartate: Potenzia con Statua 2.1 · Potenzia con Iscrizione 2.1 · Potenzia con Bastioni 2.1

**Turno 11 · g1** — lavoratore in col 2 · COSTRUISCE Teatro (col 2-2, liv 0)  [-1 pietra +1 oro]  {+2 lampo}

- **colonna 2** (4.3): terreno fiume, produzione e roba mia 1.1, ci si puo' fare una mossa da 3.2
  - (la seconda era la 3 a 3.4)
- **Costruisci Teatro a terra in col 2** (3.2) perche': costo -3.2 · spinta della strategia lampo +3.2 · lampo subito +2.0 · Scavo suo +1.2
  - scartate: Potenzia con Statua 2.1 · Potenzia con Iscrizione 2.1 · Potenzia con Bastioni 2.1

**Turno 12 · g0** — Terme: intatto -> rudere · Foro: intatto -> rovina · Teatro: intatto -> rudere · COSTRUISCE Tempio (col 3-3, liv 1)  [-1 pietra +1 oro]  {+9 rendita}

- **colonna 3** (8.6): terreno pianura, produzione e roba mia 2.2, ci si puo' fare una mossa da 6.4
  - (la seconda era la 1 a 4.9)
- **Costruisci Tempio spianando Foro in col 3** (6.4) perche': spinta della strategia rendita +2.7 · Scavo dei miei che vanno sotto +2.5 · quel che perdo spianando -2.5 · rendite future +2.0 · costo -1.6 · continuita' di classe in colonna +1.5 · Verticalita' della colonna +1.0 · Scavo suo +0.8
  - scartate: Costruisci Sacello spianando Foro in col 3 2.8 · Costruisci Castrum spianando Foro in col 3 2.3 · Costruisci Tempio a terra in col 3 2.1

  > [E2] Terme diventa rudere
  > [E2] Teatro diventa rudere
  > [E2] Tempio diventa rudere
  > [E3] Inizia l'era 3. Evento: Scisma

## Era 3 — evento: *Scisma*

Ordine di turno: [1, 0].

*In cassa a inizio era:* g0: 1 pietra 4 oro, 13 PV | g1: 0 pietra 5 oro, 8 PV

**Turno 13 · g1** — lavoratore in col 0 · Acquedotto: intatto -> rovina · COSTRUISCE Torre civica (col 0-0, liv 2)  [+2 pietra +0 oro]  {+2 lampo}

  - g1 {+2 rendita}
- **colonna 0** (9.8): terreno pianura, produzione e roba mia 1.2, ci si puo' fare una mossa da 8.6
  - (la seconda era la 1 a 9.7)
- **Costruisci Torre civica spianando Acquedotto in col 0** (5.0) perche': quel che perdo spianando -5.5 · spinta della strategia lampo +3.2 · lampo subito +2.0 · Verticalita' della colonna +1.8 · Scavo dei miei che vanno sotto +1.5 · continuita' di classe in colonna +1.5 · Scavo suo +0.5
  - scartate: Costruisci Torre civica a terra in col 0 4.3 · Costruisci Cappella a terra in col 0 4.1 · Recluta Mastro costruttore (ingegneria) 3.5

**Turno 14 · g0** — lavoratore in col 4 · Foro sepolto · COSTRUISCE Chiesa (col 4-4, liv 1)  [+1 pietra -1 oro]

- **colonna 4** (10.2): terreno collina, produzione e roba mia 2.2, ci si puo' fare una mossa da 8.0
  - (la seconda era la 1 a 7.1)
- **Costruisci Chiesa sopra in col 4** (8.1) perche': spinta della strategia rendita +3.6 · rendite future +3.0 · costo -1.8 · continuita' di classe in colonna +1.5 · Verticalita' della colonna +1.0 · Scavo suo +0.8
  - scartate: Costruisci Chiesa a terra in col 4 5.7 · Costruisci Cappella sopra in col 4 3.3 · Potenzia con Merlatura 2.1

**Turno 15 · g1** — lavoratore in col 1 · COSTRUISCE Cappella (col 1-1, liv 2)  [+1 pietra +0 oro]  {+2 lampo}

- **colonna 1** (7.6): terreno fiume, produzione e roba mia 0.3, ci si puo' fare una mossa da 7.3
  - (la seconda era la 2 a 7.6)
- **Costruisci Cappella sopra in col 1** (7.3) perche': spinta della strategia lampo +3.2 · lampo subito +2.0 · Verticalita' della colonna +1.8 · Scavo suo +0.8 · costo -0.4
  - scartate: Costruisci Ospedale dei pellegrini sopra in col 1 7.2 · Costruisci Arsenale sopra in col 1 6.1 · Costruisci Mulino sopra in col 1 5.8

**Turno 16 · g0** — lavoratore in col 3 · Tempio: rudere -> rovina · Tempio sepolto · COSTRUISCE Borgo (col 3-3, liv 2)  {+2 lampo}

- **colonna 3** (4.6): terreno pianura, produzione e roba mia 1.4, ci si puo' fare una mossa da 3.2
  - (la seconda era la 2 a 4.5)
- **Costruisci Borgo sopra in col 3** (3.4) perche': costo -2.8 · lampo subito +2.0 · Verticalita' della colonna +1.8 · Scavo dei miei che vanno sotto +1.5 · continuita' di classe in colonna +1.5 · spinta della strategia rendita -1.5 · Scavo suo +0.5 · produzione +0.4
  - scartate: Costruisci Arsenale sopra in col 2 2.9 · Costruisci Mulino sopra in col 3 2.8 · Costruisci Ospedale dei pellegrini sopra in col 3 2.6

**Turno 17 · g1** — lavoratore in col 2 · Acquedotto sepolto · COSTRUISCE Mulino (col 2-2, liv 2)  [+0 pietra +1 oro]  {+1 lampo}

- **colonna 2** (6.1): terreno fiume, produzione e roba mia 0.3, ci si puo' fare una mossa da 5.8
  - (la seconda era la 3 a 2.8)
- **Costruisci Mulino sopra in col 2** (5.8) perche': Verticalita' della colonna +1.8 · spinta della strategia lampo +1.6 · continuita' di classe in colonna +1.5 · costo -1.4 · lampo subito +1.0 · produzione +0.8 · Scavo suo +0.5
  - scartate: Costruisci Ospedale dei pellegrini sopra in col 2 5.7 · Costruisci Conceria sopra in col 2 4.8 · Costruisci Mura sopra in col 2 3.5

**Turno 18 · g0** — seppellisce Mastro costruttore sotto Dolmen · Terme: rudere -> rovina · Teatro: rudere -> rovina · Torre civica: intatto -> rudere · Chiesa: intatto -> rovina · Cappella: intatto -> rovina · Borgo: intatto -> rudere · Mulino: intatto -> rudere · RECLUTA Mastro costruttore  [-2 pietra -1 oro]  {+12 rendita}

- **colonna 2** (4.5): terreno fiume, produzione e roba mia 1.1, ci si puo' fare una mossa da 3.4
  - (la seconda era la 0 a 3.6)
- **Recluta Mastro costruttore (ingegneria)** (3.4) perche': la sua abilita' (ingegneria) +2.4 · se lo seppellisco vale 3 +0.9 · un lavoratore in piu' +0.5 · costo -0.4
  - scartate: Potenzia con Merlatura 2.4 · Potenzia con Campanile 2.4 · Potenzia con Contrafforte 2.4

  > [E3] Mastro costruttore: +1 pietra +0 oro
  > [E3] Reclutato Mastro costruttore
  > [E3] Terme crolla in rovina
  > [E3] Teatro crolla in rovina
  > [E3] Torre civica diventa rudere
  > [E3] Chiesa crolla in rovina
  > [E3] Cappella crolla in rovina
  > [E3] Borgo diventa rudere
  > [E3] Mulino diventa rudere
  > [E3] Mastro costruttore sepolto sotto Dolmen
  > [E4] Inizia l'era 4. Evento: Controriforma

## Era 4 — evento: *Controriforma*

Ordine di turno: [1, 0].

*In cassa a inizio era:* g0: 0 pietra 5 oro, 27 PV | g1: 0 pietra 5 oro, 13 PV

**Turno 19 · g1** — lavoratore in col 1 · Cappella sepolto · COSTRUISCE Palazzo signorile (col 1-1, liv 3)  [+0 pietra -1 oro]  {+3 lampo, +5 monumenti}

- **colonna 1** (9.7): terreno fiume, produzione e roba mia 0.3, ci si puo' fare una mossa da 9.4
  - (la seconda era la 0 a 8.8)
- **Costruisci Palazzo signorile sopra in col 1** (12.8) perche': spinta della strategia lampo +4.8 · lampo subito +3.0 · Verticalita' della colonna +2.8 · costo -2.0 · Scavo dei miei che vanno sotto +1.5 · continuita' di classe in colonna +1.5 · Scavo suo +0.8 · produzione +0.5
  - scartate: Costruisci Accademia sopra in col 1 9.4 · Costruisci Banco sopra in col 1 9.2 · Costruisci Ponte monumentale sopra in col 0 8.4

  > [E4] Catacombe reclamato dal giocatore 1 (+5 PV)
**Turno 20 · g0** — lavoratore in col 4 · Chiesa sepolto · Borgo: rudere -> rovina · Borgo sepolto · COSTRUISCE Fortezza bastionata (col 3-4, liv 3)  [+1 pietra -2 oro]

- **colonna 4** (15.0): terreno collina, produzione e roba mia 2.2, il lavoratore salva Dolmen dall'evento (2.5), ci si puo' fare una mossa da 10.3
  - (la seconda era la 3 a 14.2)
- **Costruisci Fortezza bastionata sopra in col 3** (16.1) perche': rendite future +8.0 · Verticalita' della colonna +4.5 · spinta della strategia rendita +2.7 · Scavo dei miei che vanno sotto +2.5 · costo -2.1 · Scavo suo +0.5
  - scartate: Costruisci Piazza monumentale sopra in col 3 10.1 · Costruisci Banco sopra in col 4 5.0 · Costruisci Accademia sopra in col 4 5.0

**Turno 21 · g1** — lavoratore in col 0 · Torre civica: rudere -> rovina · Torre civica sepolto · COSTRUISCE Bottega d'artista (col 0-0, liv 3)  [+1 pietra -1 oro]  {+2 lampo}

- **colonna 0** (3.1): terreno pianura, produzione e roba mia 0.4, ci si puo' fare una mossa da 2.7
  - (la seconda era la 2 a 3.0)
- **Costruisci Bottega d'artista sopra in col 0** (7.8) perche': spinta della strategia lampo +3.2 · Verticalita' della colonna +2.8 · lampo subito +2.0 · costo -1.6 · Scavo dei miei che vanno sotto +1.0 · Scavo suo +0.5
  - scartate: Costruisci Banco sopra in col 0 7.7 · Costruisci Accademia sopra in col 0 7.4 · Costruisci Bottega d'artista a terra in col 0 4.1

**Turno 22 · g0** — lavoratore in col 2 · Mulino: rudere -> rovina · Mulino sepolto · COSTRUISCE Banco (col 2-2, liv 3)  [+0 pietra +1 oro]  {+2 lampo}

- **colonna 2** (4.7): terreno fiume, produzione e roba mia 1.3, ci si puo' fare una mossa da 3.4
  - (la seconda era la 0 a 3.8)
- **Costruisci Banco sopra in col 2** (3.4) perche': Verticalita' della colonna +2.8 · lampo subito +2.0 · costo -1.6 · continuita' di classe in colonna +1.5 · spinta della strategia rendita -1.5 · produzione +0.3
  - scartate: Costruisci Accademia sopra in col 2 3.4 · Recluta Mecenate (cultura) 2.6 · Recluta Artista di corte (cultura) 2.6

**Turno 23 · g1** — lavoratore in col 2 · COSTRUISCE Accademia (col 2-2, liv 0)  [+0 pietra -1 oro]  {+2 lampo}

- **colonna 2** (5.3): terreno fiume, produzione e roba mia 0.1, ci si puo' fare una mossa da 5.2
  - (la seconda era la 3 a 4.3)
- **Costruisci Accademia a terra in col 2** (5.2) perche': spinta della strategia lampo +3.2 · costo -2.3 · lampo subito +2.0 · continuita' di classe in colonna +1.5 · Scavo suo +0.8
  - scartate: Costruisci Loggia a terra in col 2 4.1 · Recluta Banchiere (commercio) 2.5 · Recluta Mecenate (cultura) 2.4

**Turno 24 · g0** — seppellisce Mecenate sotto Circolo di pietre · Palazzo signorile: intatto -> rudere · Bottega d'artista: intatto -> rovina · Banco: intatto -> rudere · Accademia: intatto -> rovina · RECLUTA Mecenate  [-1 pietra -3 oro]  {+17 rendita, +1 cultura}

- **colonna 0** (3.9): terreno pianura, produzione e roba mia 1.2, ci si puo' fare una mossa da 2.7
  - (la seconda era la 1 a 3.8)
- **Recluta Mecenate (cultura)** (2.5) perche': la sua abilita' (cultura) +2.0 · se lo seppellisco vale 2 +0.6 · costo -0.6 · un lavoratore in piu' +0.5
  - scartate: Recluta Artista di corte (cultura) 2.5 · Potenzia con Giardino pensile 1.7 · Potenzia con Affreschi 1.7

  > [E4] Mecenate: +1 cultura
  > [E4] Reclutato Mecenate
  > [E4] Palazzo signorile diventa rudere
  > [E4] Bottega d'artista crolla in rovina
  > [E4] Banco diventa rudere
  > [E4] Accademia crolla in rovina
  > [E4] Mecenate sepolto sotto Circolo di pietre
  > [E5] Inizia l'era 5. Evento: nessuno

## Era 5 — evento: *nessuno*

Ordine di turno: [0, 1].

*In cassa a inizio era:* g0: 0 pietra 5 oro, 47 PV | g1: 1 pietra 2 oro, 25 PV

**Turno 25 · g0** — lavoratore in col 4 · Fortezza bastionata: intatto -> rovina · Fortezza bastionata sepolto · COSTRUISCE Università (col 3-4, liv 4)  [+2 pietra -3 oro]  {+4 lampo}

- **colonna 4** (13.7): terreno collina, produzione e roba mia 3.0, il lavoratore salva Fortezza bastionata dall'evento (1.5), ci si puo' fare una mossa da 9.2
  - (la seconda era la 0 a 13.4)
- **Costruisci Università spianando Fortezza bastionata in col 3** (8.2) perche': Verticalita' della colonna +7.7 · lampo subito +4.0 · quel che perdo spianando -2.3 · costo -2.2 · continuita' di classe in colonna +1.5 · spinta della strategia rendita -1.5 · Scavo dei miei che vanno sotto +1.0
  - scartate: Costruisci Fondazione d'arte spianando Fortezza bastionata in col 4 4.1 · Costruisci Officina spianando Fortezza bastionata in col 4 3.8 · Costruisci Condominio spianando Fortezza bastionata in col 4 3.8

**Turno 26 · g1** — lavoratore in col 0 · Bottega d'artista sepolto · COSTRUISCE Fondazione d'arte (col 0-0, liv 4)  [+2 pietra -2 oro]  {+3 lampo}

- **colonna 0** (12.7): terreno pianura, produzione e roba mia 0.4, ci si puo' fare una mossa da 12.3
  - (la seconda era la 1 a 10.9)
- **Costruisci Fondazione d'arte sopra in col 0** (11.8) perche': spinta della strategia lampo +4.8 · Verticalita' della colonna +3.9 · lampo subito +3.0 · costo -2.3 · continuita' di classe in colonna +1.5 · Scavo dei miei che vanno sotto +1.0
  - scartate: Costruisci Officina sopra in col 0 10.4 · Costruisci Condominio sopra in col 0 10.4 · Costruisci Fondazione d'arte a terra in col 0 6.5

**Turno 27 · g0** — lavoratore in col 1 · Palazzo signorile: rudere -> rovina · Palazzo signorile sepolto · Banco: rudere -> rovina · Banco sepolto · COSTRUISCE Ponte in acciaio (col 1-2, liv 4)  [+0 pietra -1 oro]  {+4 lampo}

- **colonna 1** (9.5): terreno fiume, produzione e roba mia 1.3, il lavoratore salva Anfiteatro dall'evento (1.5), ci si puo' fare una mossa da 6.7
  - (la seconda era la 2 a 9.5)
- **Costruisci Ponte in acciaio sopra in col 1** (6.8) perche': Verticalita' della colonna +7.7 · lampo subito +4.0 · costo -3.4 · spinta della strategia rendita -1.5
  - scartate: Costruisci Biblioteca sopra in col 1 4.4 · Costruisci Officina sopra in col 1 2.7 · Costruisci Condominio sopra in col 1 2.7

**Turno 28 · g1** — lavoratore in col 3 · passa  [+2 pietra +0 oro]

- **colonna 3** (0.2): terreno pianura, produzione e roba mia 0.2
  - (la seconda era la 1 a 0.1)
  - nessuna mossa vale piu' di zero: passa

**Turno 29 · g0** — lavoratore in col 3 · COSTRUISCE Officina (col 3-3, liv 0)  [+1 pietra -1 oro]  {+2 lampo}

- **colonna 3** (4.2): terreno pianura, produzione e roba mia 2.2, il lavoratore salva Circolo di pietre dall'evento (1.5), ci si puo' fare una mossa da 0.5
  - (la seconda era la 2 a 2.8)
- **Costruisci Officina a terra in col 3** (0.4) perche': lampo subito +2.0 · costo -1.6 · continuita' di classe in colonna +1.5 · spinta della strategia rendita -1.5
  - scartate: Costruisci Condominio a terra in col 3 0.4 · Recluta Archeologo (cultura) 0.3 · Potenzia con Boutique 0.1

**Turno 30 · g1** — COSTRUISCE Condominio (col 1-1, liv 0)  {+2 lampo, +22 verticalita, +12 continuita, +14 scavo, +5 scheletri}

- **colonna 1** (0.1): terreno fiume, produzione e roba mia 0.1
  - (la seconda era la 2 a 0.1)
- **Costruisci Condominio a terra in col 1** (4.9) perche': spinta della strategia lampo +3.2 · lampo subito +2.0 · costo -1.8 · continuita' di classe in colonna +1.5
  - scartate: Recluta Archeologo (cultura) 3.1 · Recluta Soprintendente (ingegneria) 0.1

  > [E5] Eredita' Il Cronista soddisfatta dal giocatore 0 (+5 PV)
  > [E5] Università: +2 PV a giocatore 0

## Come è finita

```
FINE PARTITA (30 turni)
posto  chi   PV     Lampo  Cultura  RenditaMonumentiVerticaliContinuit    ScavoScheletri  Eredità    Carte   edifici  eredita'
   1   g0   148        14        1       55        0       49       12       10        0        5        2       6   Il Cronista
   2   g1    83        23        0        2        5       22       12       14        5        0        0       2   Il Restauratore
g0 · costruiti 13 (intatti 6, ruderi 0, rovine 0, sepolti 7) · potenziamenti 0 · personaggi 2 · dinastia no · resta 3 pietra 2 oro
g1 · costruiti 13 (intatti 2, ruderi 0, rovine 3, sepolti 8) · potenziamenti 0 · personaggi 1 · dinastia no · resta 5 pietra 0 oro
```


## Cosa hanno fatto, e perché g0 ha vinto 148 a 83

**g0 gioca Rendita e comincia comprando un motore.** Al primo turno il suo
valutatore dà al Dolmen **10,1 punti, di cui 9,0 di "rendite future"**: non sta
contando quel che il Dolmen frutta adesso, sta contando i censimenti che
incasserà se sopravvive - la funzione `rendite_future` li conta uno per uno,
fermandosi all'era in cui l'evento lo butterebbe giù. La Capanne accanto valeva
1,6. Non è una preferenza di stile: è la stessa carta vista da una strategia
che sa quanto durerà.

**g1 gioca Lampo e compra punti subito.** Capanne e Palafitte valgono 4,7 a
testa, e dentro quel numero il Lampo pesa 1,0 mentre la produzione ne pesa 3,2:
il bot Lampo sta comprando un punto e mezzo per turno più le risorse per il
turno dopo. Funziona - chiude con **23 punti Lampo contro i 14 di g0** - ma il
canale è piccolo.

**Il divario si apre al censimento.** I punti Rendita arrivano tutti insieme, a
fine era: +4 nell'era 1, +9 al turno 12, +12 al turno 18, +17 al turno 24, +13
alla fine. **55 contro 2.** g1 non ha perso il confronto sul suo canale, l'ha
perso perché il canale dell'altro paga cinque volte tanto.

**E la Verticalità segue chi resta in piedi.** 49 contro 22, e non perché g0 sia
salito di più: al turno 25 costruisce l'Università spianando la Fortezza
bastionata con un valore di 8,2, di cui **7,7 di sola Verticalità della
colonna** - il premio della colonna si prende per ogni casella che l'edificio
tocca, e chi sta in cima ne prende metà. g0 ci arriva in cima perché i suoi
edifici erano ancora vivi quando è stato il momento di salirci sopra: chiude con
**6 intatti contro 2**.

**Quello che il bot Lampo sbaglia, e si vede nei numeri.** Al turno 7 sceglie di
costruire l'Acquedotto spianando le sue stesse Palafitte: il valutatore gli
segna **+3,0 di Verticalità e +2,0 di Scavo dei suoi che vanno sotto**, e solo
**-0,5 per "quel che perdo spianando"**. Quella voce conta la rendita futura
persa moltiplicata per 0,6 - e le Palafitte di rendita ne facevano poca, quindi
spianarle costava quasi niente. È corretto per il bot Lampo, che dalla rendita
non prende nulla; è la firma di una strategia che non ha un motore da
proteggere.

**Dove questi bot sono più deboli di un giocatore vero.** Si vede nell'ordine in
cui decidono: prima scelgono la colonna - contando anche quanto varrebbe la
migliore mossa che ci si potrebbe fare - e solo *dopo*, piazzato il lavoratore,
convertono la pietra in oro. La colonna promette e la mossa mantiene qualcosa di
diverso: al turno 29 la colonna 3 valeva 4,2 contando una mossa da 0,5, e la
mossa che ne è uscita vale 0,4. È uno scarto piccolo qui, ma è strutturale, e
si somma al limite più grosso: **non pianificano**. Scelgono la mossa che vale
di più adesso, non quella che prepara il turno dopo - nessuno di loro tiene da
parte una colonna per salirci in era 5. Quando si legge una tabella di
diecimila partite va tenuto presente: le loro *preferenze* sono misurate bene,
la loro *strategia di lungo respiro* non esiste, e un tavolo di umani che
pianifica sposterebbe soprattutto la Verticalità e i Monumenti.

> Questa nota nasce da un difetto trovato scrivendo il documento: il racconto
> chiedeva la classifica al bot **prima** che piazzasse il lavoratore e
> convertisse la pietra, e finiva per spiegare una mossa diversa da quella
> fatta - il turno diceva "recluta" e il tabellone costruiva. Adesso è il bot a
> lasciare scritto cosa ha guardato nel momento in cui decide
> (`StrategyBot.taccuino`), e le due cose combaciano per costruzione.
