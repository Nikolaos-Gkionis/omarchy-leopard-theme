#!/usr/bin/env bash
# Build the six 4K wallpapers for the Leopard theme.
#
# A wallpaper here is a 3840x2160 picture (that size is called 4K).
# Omarchy looks in backgrounds/ and cycles them with:
#   omarchy theme bg next
#
# The first four are high-resolution photographs from Wikimedia Commons.
# The last two are print photographs from Flickr. They already fill the
# frame, so they are only cropped to 16:9. The grade on the first four
# is a light warm tint. The prints are left as the photographer shot them.

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SRC="$ROOT/sources"
OUT="$ROOT/backgrounds"
THUMBS="$ROOT/assets"
W=3840
H=2160

mkdir -p "$SRC" "$OUT" "$THUMBS"

UA="omarchy-leopard-theme/1.0 (wallpaper build; https://commons.wikimedia.org)"

download() {
  local dest="$1"
  local url="$2"
  if [[ -f $dest ]]; then
    return
  fi
  curl -fL --retry 3 -A "$UA" -o "$dest" "$url"
}

download "$SRC/juvenile.jpg" \
  "https://upload.wikimedia.org/wikipedia/commons/3/32/001_Juvenile_leopard_in_the_Serengeti_National_Park_Photo_by_Giles_Laurent.jpg"
download "$SRC/kruger.jpg" \
  "https://upload.wikimedia.org/wikipedia/commons/5/56/Leopard_%28Panthera_pardus_pardus%29_Kruger.jpg"
download "$SRC/kruger-2.jpg" \
  "https://upload.wikimedia.org/wikipedia/commons/2/29/Leopard_%28Panthera_pardus_pardus%29_Kruger_2.jpg"
download "$SRC/young.jpg" \
  "https://upload.wikimedia.org/wikipedia/commons/e/e6/Leopard_%28Panthera_pardus_pardus%29_young_female_Kruger_2.jpg"
# Light print: Becker1999, "leopard pattern", CC BY 2.0.
download "$SRC/light-print.jpg" \
  "https://live.staticflickr.com/3655/3554618621_a87b03daa5_o.jpg"
# Dark print: shaire productions, "Animal Print", CC BY 2.0.
download "$SRC/dark-print.jpg" \
  "https://live.staticflickr.com/4054/4250185244_887d274dfe_o.jpg"

# How far down a cover-crop should start, in percent, after the photo is
# scaled to 3840 pixels wide. Pass "center" to keep the middle band.
# A cover-crop fills the whole 16:9 frame. A tall photo loses a strip at
# the top or the bottom so the animal stays large.
crop_y() {
  local src="$1"
  local ypct="$2"
  local dims sw sh scaled y max
  dims="$(identify -format "%w %h" "$src")"
  sw="${dims%% *}"
  sh="${dims##* }"
  scaled=$((sh * W / sw))
  if [[ $ypct == center ]]; then
    y=$(((scaled - H) / 2))
  else
    y=$((scaled * ypct / 100))
  fi
  max=$((scaled - H))
  if ((y > max)); then y=$max; fi
  if ((y < 0)); then y=0; fi
  echo "$y"
}

# Shared finish: a light warm tint, a little extra contrast, and a sharp
# JPEG. 4:4:4 keeps the edges of the spots from smearing.
finish() {
  magick "$1" \
    -fill '#24180c' -colorize 5% \
    -modulate 97,112,100 \
    -brightness-contrast -2x7 \
    -unsharp 0x0.5+0.4+0.02 \
    -quality 93 -sampling-factor 4:4:4 -define jpeg:dct-method=float \
    "$2"
}

# Scale with Lanczos (a sharp resize filter), then keep one 4K slice.
# Pass "plain" as the fourth argument to skip the warm tint.
cover() {
  local src="$1"
  local dest="$2"
  local ypct="$3"
  local y tmp
  y="$(crop_y "$src" "$ypct")"
  tmp="$(mktemp --suffix=.jpg)"
  magick "$src" -filter Lanczos -resize ${W}x \
    -gravity north -crop ${W}x${H}+0+${y} +repage \
    "$tmp"
  if [[ ${4:-grade} == plain ]]; then
    magick "$tmp" \
      -quality 93 -sampling-factor 4:4:4 -define jpeg:dct-method=float \
      "$dest"
  else
    finish "$tmp" "$dest"
  fi
  rm -f "$tmp"
}

# 1. Serengeti tree. Start near the top so both ears stay in the frame.
cover "$SRC/juvenile.jpg" "$OUT/01-serengeti-tree.jpg" 2

# 2. Kruger stalk. Sit a little low so the front paw is not cut off.
cover "$SRC/kruger.jpg" "$OUT/02-kruger-stalk.jpg" 12

# 3. Kruger stride. The cat already sits in the middle band.
cover "$SRC/kruger-2.jpg" "$OUT/03-kruger-stride.jpg" center

# 4. Tree fork. A small step down from the top keeps the canopy and the cat.
cover "$SRC/young.jpg" "$OUT/04-tree-fork.jpg" 6

# 5. Light print. The photo is already the pattern, edge to edge.
#    Keep the middle band.
cover "$SRC/light-print.jpg" "$OUT/05-light-print.jpg" center plain

# 6. Dark print. Same idea: the cloth fills the picture.
cover "$SRC/dark-print.jpg" "$OUT/06-dark-print.jpg" center plain

rm -f "$OUT/05-gold-print.jpg" "$OUT/06-night-print.jpg" \
  "$OUT/05-shoulder-coat.jpg" "$OUT/06-gold-rosettes.jpg" \
  "$THUMBS/05-gold-print-thumb.jpg" "$THUMBS/06-night-print-thumb.jpg" \
  "$THUMBS/05-shoulder-coat-thumb.jpg" "$THUMBS/06-gold-rosettes-thumb.jpg"

# Small pictures for the README. The preview is a separate drawing.
for src in "$OUT"/*.jpg; do
  base="$(basename "$src" .jpg)"
  magick "$src" -filter Lanczos -resize 800x \
    -quality 82 -sampling-factor 4:2:0 \
    "$THUMBS/${base}-thumb.jpg"
done

python3 "$ROOT/scripts/make-preview.py"

identify "$OUT"/*.jpg
echo "Wallpapers written to $OUT"
