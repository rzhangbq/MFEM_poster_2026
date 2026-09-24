#!/usr/bin/env bash
# Export MFEM_PIC_POSTER.md (18x24 portrait) to HTML and PDF.
# Usage: ./export_marp.sh
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
SRC="$ROOT/MFEM_PIC_POSTER.md"

if command -v marp >/dev/null 2>&1; then
  marp_cmd=(marp)
else
  marp_cmd=(npx --yes @marp-team/marp-cli)
fi

common=(--html --allow-local-files --theme-set "$ROOT/poster-wide.css")

echo "HTML: $ROOT/MFEM_PIC_POSTER.html"
"${marp_cmd[@]}" "${common[@]}" "$SRC" -o "$ROOT/MFEM_PIC_POSTER.html"

echo "PDF:  $ROOT/MFEM_PIC_POSTER.pdf"
"${marp_cmd[@]}" "${common[@]}" --pdf --pdf-outlines "$SRC" -o "$ROOT/MFEM_PIC_POSTER.pdf"

echo "Done."
