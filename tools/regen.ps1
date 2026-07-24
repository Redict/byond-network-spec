<#
.SYNOPSIS
    Compile the Python parsers/serializers from the BYOND .ksy specs.

.DESCRIPTION
    Pinned toolchain (see README): kaitai-struct-compiler 0.11 + JDK 21.
    Compiles every ksy/*.ksy spec to generated/python/, in BOTH modes:
      * read-only  -> generated/python/ro/   (parsers)
      * read-write -> generated/python/rw/   (parsers + serializers; Python-only,
                       Kaitai serialization is Python/Java-only in 0.11)

    generated/ is not tracked - produce it on demand.

.NOTES
    Common idioms in ksy/common are imported by body specs via their qualified
    names, e.g. type: 'byond_common::u2or4(fourbyte)'.
#>
param(
    [string]$Ksc = "kaitai-struct-compiler"
)
$ErrorActionPreference = "Stop"
$root   = Split-Path -Parent $PSScriptRoot
$ksyDir = Join-Path $root "ksy"
$outRo  = Join-Path $root "generated/python/ro"
$outRw  = Join-Path $root "generated/python/rw"
$import = "$ksyDir"

# Body specs live at ksy/*.ksy; common idioms at ksy/common/*.ksy and transport
# layouts at ksy/transport/*.ksy are compiled too (common is also imported by id).
$specs = Get-ChildItem -Path $ksyDir -Filter *.ksy -File | ForEach-Object { $_.FullName }
$common = Get-ChildItem -Path (Join-Path $ksyDir "common") -Filter *.ksy -File | ForEach-Object { $_.FullName }
$transport = Get-ChildItem -Path (Join-Path $ksyDir "transport") -Filter *.ksy -File -ErrorAction SilentlyContinue | ForEach-Object { $_.FullName }
$all = @($specs) + @($common) + @($transport)

Write-Host "kaitai-struct-compiler:" (& $Ksc --version)
New-Item -ItemType Directory -Force -Path $outRo, $outRw | Out-Null

# NOTE: use --outdir, not -d. The launcher script intercepts -d as its own
# --debug flag and swallows it, so the output dir would be treated as an input.
Write-Host "== read-only (parsers) =="
& $Ksc -t python --import-path "$import" --outdir "$outRo" @all
if ($LASTEXITCODE -ne 0) { throw "read-only compile failed" }

Write-Host "== read-write (parsers + serializers, Python-only) =="
& $Ksc -t python --read-write --import-path "$import" --outdir "$outRw" @all
if ($LASTEXITCODE -ne 0) { throw "read-write compile failed" }

Write-Host "Done. Generated:"
Get-ChildItem -Recurse $outRo, $outRw -File -Filter *.py |
    ForEach-Object { "  " + $_.FullName.Substring($root.Length + 1) }
