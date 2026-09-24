#!/usr/bin/env bash
# Export the 2-page 16:9 poster and the single 3:2 wide poster.
# Usage: ./export_marp.sh
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"

if command -v marp >/dev/null 2>&1; then
  marp_cmd=(marp)
else
  marp_cmd=(npx --yes @marp-team/marp-cli)
fi

common=(--html --allow-local-files --theme-set "$ROOT/poster-wide.css")

export_one() {
  local src="$1"
  local stem
  stem="$(basename "${src%.md}")"
  echo "HTML: $ROOT/${stem}.html"
  "${marp_cmd[@]}" "${common[@]}" "$src" -o "$ROOT/${stem}.html"
  echo "PDF:  $ROOT/${stem}.pdf"
  "${marp_cmd[@]}" "${common[@]}" --pdf --pdf-outlines "$src" -o "$ROOT/${stem}.pdf"
}

export_one "$ROOT/MFEM_PIC_POSTER.md"
export_one "$ROOT/MFEM_PIC_POSTER_WIDE.md"

echo "Done."
