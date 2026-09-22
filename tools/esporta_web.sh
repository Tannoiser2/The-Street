#!/usr/bin/env bash
# Costruisce l'export web in build/web/, pronto da servire come pagina statica.
#
# Due cose non ovvie, e sono il motivo per cui questo script esiste:
#
# 1. Si usa il template SENZA THREAD (`variant/thread_support=false` nel
#    preset). Quello con i thread pretende SharedArrayBuffer, che il browser
#    concede solo se il server manda le intestazioni COOP/COEP - e GitHub
#    Pages non le manda e non si possono aggiungere. Col template nothreads
#    la pagina gira su qualunque hosting statico.
# 2. Nel pacchetto entra `assets/sagome/`, non tutto `assets/`: le carte
#    estratte dai PDF pesano 71 MB e nessuno le carica a runtime. Con loro il
#    .pck usciva da 66 MB, senza da 10.
#
# Uso:  tools/esporta_web.sh [cartella]     (default: build/web)
set -euo pipefail

RADICE="$(cd "$(dirname "$0")/.." && pwd)"
DEST="${1:-$RADICE/build/web}"
VERSIONE="$(godot --version | cut -d. -f1-3)"   # es. 4.7.stable
TEMPLATES="${HOME}/.local/share/godot/export_templates/${VERSIONE}"

if [ ! -f "${TEMPLATES}/web_nothreads_release.zip" ]; then
  echo "manca il template web per ${VERSIONE}; lo scarico"
  TPZ="$(mktemp -d)/templates.tpz"
  curl -sSLf -o "$TPZ" \
    "https://github.com/godotengine/godot/releases/download/${VERSIONE%.stable}-stable/Godot_v${VERSIONE%.stable}-stable_export_templates.tpz"
  mkdir -p "$TEMPLATES"
  unzip -o -j "$TPZ" "templates/web_nothreads_*.zip" -d "$TEMPLATES" >/dev/null
  rm -rf "$(dirname "$TPZ")"
fi

# Senza le sagome la plancia si disegna lo stesso (scatole colorate), ma
# tanto vale pubblicarla con le illustrazioni.
if [ ! -d "$RADICE/assets/sagome/colore" ]; then
  echo "assets/ non c'e': lo rigenero dai PDF"
  python3 "$RADICE/tools/estrai_grafica.py"
fi

cd "$RADICE"
godot --headless --import >/dev/null
rm -rf "$DEST" && mkdir -p "$DEST"
godot --headless --export-release "Web" "$DEST/index.html"
# GitHub Pages passa tutto per Jekyll, che scarta i file che iniziano per
# underscore. Qui non ce ne sono, ma il giorno che Godot ne generasse uno il
# difetto sarebbe muto: la pagina caricherebbe a meta'.
touch "$DEST/.nojekyll"
du -sh "$DEST"
echo "fatto: $DEST"
