#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"

echo "== Image optimization starting in: $ROOT_DIR =="

if ! command -v sips >/dev/null 2>&1; then
  echo "Error: 'sips' not found. On macOS this should exist. Aborting." >&2
  exit 1
fi

has_cwebp=0
if command -v cwebp >/dev/null 2>&1; then
  has_cwebp=1
  echo "- Using cwebp for WebP output"
else
  echo "- 'cwebp' not found; skipping WebP generation (JPEGs will still be optimized)"
fi

thumb_out="optimized-thumbs"
mkdir -p "$thumb_out"

opt_thumb() {
  local in="$1"; shift
  local base
  base=$(basename "$in")
  local name="${base%.*}"  # project-01
  local jpg_out="$thumb_out/${name}-800w.jpg"
  local webp_out="$thumb_out/${name}-800w.webp"

  # Create 800px wide high-quality JPEG
  sips -s format jpeg -s formatOptions 70 -Z 800 "$in" --out "$jpg_out" >/dev/null
  echo "  • thumb: $jpg_out"

  # Optional WebP
  if [ $has_cwebp -eq 1 ]; then
    cwebp -q 75 "$jpg_out" -o "$webp_out" >/dev/null
    echo "    webp: $webp_out"
  fi
}

echo "- Optimizing homepage thumbnails -> $thumb_out"
shopt -s nullglob
for f in project-*.jpg project-*.jpeg project-*.png; do
  [ -e "$f" ] || continue
  opt_thumb "$f"
done

echo "- Optimizing gallery images per project"
for dir in projects/project-*; do
  [ -d "$dir" ] || continue
  out_dir="$dir/optimized"
  mkdir -p "$out_dir"
  for img in "$dir"/*.{jpg,JPG,jpeg,JPEG,png,PNG}; do
    [ -e "$img" ] || continue
    base=$(basename "$img")
    name="${base%.*}"
    jpg_out="$out_dir/${name}-1600w.jpg"
    webp_out="$out_dir/${name}-1600w.webp"
    # Create max 1600px JPEG (quality 70)
    sips -s format jpeg -s formatOptions 70 -Z 1600 "$img" --out "$jpg_out" >/dev/null
    echo "  • $(basename "$dir")/$(basename "$jpg_out")"
    if [ $has_cwebp -eq 1 ]; then
      cwebp -q 75 "$jpg_out" -o "$webp_out" >/dev/null
      echo "    webp: $(basename "$webp_out")"
    fi
  done
done

echo "== Done. Thumbs in $thumb_out; per-project in projects/*/optimized =="

