# BYOND Network Specification

Language-neutral [Kaitai Struct](https://kaitai.io) specifications of the BYOND
NetMsg message-body wire formats. Compile them to parsers for any language.

Licensed under the MIT License (see `LICENSE`). These are independent
interoperability specifications of an observed wire format and are not affiliated
with or endorsed by BYOND Software.

These specs cover the plaintext message **body** only. The transport (key
derive/fold, sequence framing, the stream cipher, and the connection-global
`fourbyte` flag) is out of scope: it is stateful and stays per-language in the
client. What these `.ksy` files describe is the decoded body, nothing before it.

## Layout

    ksy/
      common/byond_common.ksy   shared idioms: u2or4, net_string
      common/object_update.ksy  shared S1..S10 tail + net_ref (types 7/8)
      transport/                frame header + version handshake payloads
      *.ksy                     one spec per message body
    tools/
      regen.ps1 / regen.sh      compile all specs into generated/ (gitignored)

## Toolchain

| Tool | Version | Install |
|------|---------|---------|
| kaitai-struct-compiler | 0.11 | `winget install Kaitai.StructCompiler` |
| JDK (for the compiler) | 21 LTS | `winget install EclipseAdoptium.Temurin.21.JDK` |
| kaitaistruct (Python runtime) | 0.11 | `pip install kaitaistruct==0.11` |

Kaitai serialization (writing) is Python/Java-only as of 0.11. Other languages
get parsers from these specs and supply a hand-written writer.

## Generate

The specs are the source of truth; parsers are generated on demand and not
tracked. Compile them with:

```powershell
pwsh tools/regen.ps1     # Windows
```
```bash
bash tools/regen.sh      # Linux
```

This writes read-only parsers to `generated/python/ro/` and parsers + serializers
to `generated/python/rw/`.

## Shared idioms

Body specs import the common idioms and reference them by qualified name:

```yaml
meta:
  imports:
    - common/byond_common
seq:
  - id: appearance_id
    type: 'byond_common::u2or4(fourbyte)'   # 2- or 4-byte int per the fourbyte flag
  - id: name
    type: 'byond_common::net_string'        # NUL-terminated byte string
```

`version`, `minor`, and `fourbyte` come from the negotiated handshake and are
passed in as params, never read from the body. Version-gated layouts are written
as `if version > ...` so no session state leaks into the wire model.

## Vendoring into another language

`ksy/` is self-contained. Copy it and compile for your target:

```sh
kaitai-struct-compiler -t rust  --import-path ksy ksy/*.ksy ksy/common/*.ksy
kaitai-struct-compiler -t go    --import-path ksy ksy/*.ksy ksy/common/*.ksy
```

You get parsers; supply the transport and a writer for your language.

## Covered message types

Bodies: appearance (38), animate (240), cmob (8), cobj (7), mob_list (241),
overlay_refresh (216), screen_refresh (51/53), stats (106), cspell (17),
server_config (59), browse_rsc (114), turf_grid (20/32/97), rsc_index (159),
expansion_list (63), and the smaller control/dialog/resource/client bodies.
Transport: the wire frame header and the type-1 version handshake payloads.
