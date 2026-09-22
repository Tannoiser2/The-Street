#!/usr/bin/env bash
# Disegna una plancia vera in un PNG, cosi' l'interfaccia si guarda invece di
# immaginarla. Serve un display: su una macchina senza schermo usa xvfb-run,
# che questo script mette da solo se lo trova.
#
#   tools/scatta.sh [FILE.png] [-- --players 3 --seed 7 --era 4]
#
# Godot in modalita' --headless NON disegna (driver dummy): per avere
# un'immagine serve un display vero o virtuale.
set -euo pipefail
FUORI="${1:-/tmp/strada.png}"; shift || true
[ "${1:-}" = "--" ] && shift || true
LANCIA=(godot --display-driver x11 --rendering-driver opengl3
        --write-movie "$FUORI" --quit-after 3 res://scenes/scatta.tscn --)
if [ -z "${DISPLAY:-}" ] && command -v xvfb-run >/dev/null; then
  xvfb-run -a "${LANCIA[@]}" "$@"
else
  "${LANCIA[@]}" "$@"
fi
# Movie Maker numera i fotogrammi: teniamo l'ultimo e buttiamo il resto.
BASE="${FUORI%.png}"
ULTIMO=$(ls "${BASE}"*.png 2>/dev/null | tail -1 || true)
if [ -n "$ULTIMO" ]; then
  mv "$ULTIMO" "$FUORI"
  rm -f "${BASE}"[0-9]*.png "${BASE}.wav"
  echo "scattata: $FUORI"
fi
