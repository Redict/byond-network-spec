#!/usr/bin/env bash
# Compile the Python parsers/serializers from the BYOND .ksy specs.
#
# Pinned toolchain (see README): kaitai-struct-compiler 0.11 + JDK 21. Compiles
# every ksy/*.ksy spec (importing ksy/common/*.ksy) to generated/python/, in BOTH
# modes:
#   * read-only  -> generated/python/ro/   (parsers)
#   * read-write -> generated/python/rw/   (parsers + serializers, Python-only)
#
# generated/ is not tracked - produce it on demand. The PowerShell twin
# tools/regen.ps1 is kept in sync for local Windows dev.
set -euo pipefail

KSC="${KSC:-kaitai-struct-compiler}"
root="$(cd "$(dirname "$0")/.." && pwd)"
ksy_dir="$root/ksy"
out_ro="$root/generated/python/ro"
out_rw="$root/generated/python/rw"

specs=("$ksy_dir"/*.ksy "$ksy_dir"/common/*.ksy "$ksy_dir"/transport/*.ksy)

echo "kaitai-struct-compiler: $("$KSC" --version)"
mkdir -p "$out_ro" "$out_rw"

# NOTE: use --outdir, not -d. The launcher script intercepts -d as its own
# --debug flag and swallows it, so the output dir would be treated as an input.
echo "== read-only (parsers) =="
"$KSC" -t python --import-path "$ksy_dir" --outdir "$out_ro" "${specs[@]}"

echo "== read-write (parsers + serializers, Python-only) =="
"$KSC" -t python --read-write --import-path "$ksy_dir" --outdir "$out_rw" "${specs[@]}"

echo "Done. Generated:"
find "$out_ro" "$out_rw" -name '*.py' | sort | sed "s|$root/|  |"
