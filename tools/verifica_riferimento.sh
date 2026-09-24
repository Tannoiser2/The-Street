#!/usr/bin/env bash
# Rigioca il lotto di riferimento della v1.5 e lo confronta con quello salvato
# in reference/lotto-v1.5/. Serve a provare che una modifica al motore non ha
# toccato il regolamento v1.5: le partite devono uscire IDENTICHE, riga per
# riga. E' la regola "manopola spenta = partite uguali a main" resa eseguibile.
#
#   tools/verifica_riferimento.sh            # usa `godot` nel PATH
#   GODOT=/percorso/godot tools/verifica_riferimento.sh
#
# Del torneo si confrontano i primi CAMPI campi (19: fino a `piano`), perche'
# le colonne nuove si aggiungono in fondo e non devono far fallire il confronto.
# Della vita delle carte si confrontano tutte le righe sulle colonne che il
# riferimento ha; l'intestazione delle regole puo' crescere di una voce (una
# manopola nuova, spenta) senza fallire.
set -u
GODOT="${GODOT:-godot}"
CAMPI="${CAMPI:-19}"
DIR="$(cd "$(dirname "$0")/.." && pwd)"
RIF="$DIR/reference/lotto-v1.5"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

# Un errore di parsing lascia appesa una scena headless senza messaggio: sempre
# con timeout, e si cerca SCRIPT ERROR sullo stderr.
gioca() {  # gioca MODO QUANTE SEME USCITA
	timeout 900 "$GODOT" --headless --path "$DIR" res://scenes/audit_partita.tscn -- \
		--players 3 "--$1" "$2" --seed "$3" 2> "$TMP/err.log" | grep -v -e '^Godot Engine' -e '^$' > "$4"
	if grep -q 'SCRIPT ERROR' "$TMP/err.log"; then
		echo "ERRORE di script rigiocando --$1:"; grep -A3 'SCRIPT ERROR' "$TMP/err.log"; exit 2
	fi
}

esito=0
gioca games 120 700000 "$TMP/torneo.csv"
if ! diff <(cut -d';' -f1-"$CAMPI" "$RIF/torneo.csv") <(cut -d';' -f1-"$CAMPI" "$TMP/torneo.csv") > "$TMP/torneo.diff"; then
	echo "TORNEO: DIVERSO dal riferimento ($(grep -c '^<' "$TMP/torneo.diff") righe cambiate)"
	head -20 "$TMP/torneo.diff"; esito=1
else
	echo "TORNEO: identico al riferimento (120 partite, seme 700000, primi $CAMPI campi)"
fi

gioca vita 120 100000 "$TMP/vita.csv"
# L'intestazione delle regole puo' solo CRESCERE: ogni manopola nuova aggiunge
# la sua voce in fondo (e' il metodo: una regola che non sta li' rende uguali
# due lotti diversi) e finche' e' spenta le partite non cambiano. Quindi ogni
# voce del riferimento deve esserci con lo stesso valore, e una voce in piu'
# si segnala soltanto. Le righe delle carte, invece, devono coincidere tutte.
rif_meta=$(grep -m1 '^# partite=' "$RIF/vita.csv")
new_meta=$(grep -m1 '^# partite=' "$TMP/vita.csv")
for kv in $rif_meta; do
	[ "$kv" = "#" ] && continue
	k=${kv%%=*}
	nv=$(tr ' ' '\n' <<< "$new_meta" | grep -m1 "^$k=" || true)
	if [ "$nv" != "$kv" ]; then
		echo "VITA: la regola '$kv' del riferimento e' diventata '${nv:-assente}'"; esito=1
	fi
done
for kv in $new_meta; do
	[ "$kv" = "#" ] && continue
	k=${kv%%=*}
	grep -q " $k=" <<< "$rif_meta " || echo "VITA: voce nuova nell'intestazione, assente nel riferimento: $kv"
done
# Le colonne nuove si aggiungono in coda anche qui: si confrontano solo
# quelle che il riferimento ha.
campi_vita=$(grep -m1 '^id;' "$RIF/vita.csv" | tr ';' '\n' | wc -l)
if ! diff <(grep -v '^# partite=' "$RIF/vita.csv" | cut -d';' -f1-"$campi_vita") <(grep -v '^# partite=' "$TMP/vita.csv" | cut -d';' -f1-"$campi_vita") > "$TMP/vita.diff"; then
	echo "VITA: DIVERSA dal riferimento ($(grep -c '^<' "$TMP/vita.diff") righe cambiate)"
	head -20 "$TMP/vita.diff"; esito=1
elif [ "$esito" = 0 ]; then
	echo "VITA: identica al riferimento (120 partite, seme 100000)"
fi
exit $esito
