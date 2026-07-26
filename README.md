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

45 body specs + 3 transport specs. Every spec is exercised byte-for-byte against real
BYOND 516 capture vectors by the consumer's equivalence gate (see "Verification").

### Server → client bodies (47 message types)

| Spec | Type(s) | Meaning |
|------|---------|---------|
| `appearance` | 38 | CAppearance (the hottest body) |
| `animate` | 240 | Animate flick-chain |
| `cobj` / `cmob` | 7 / 8 | Object + mob updates (shared `object_update` tail) |
| `mob_list` | 241 | Mob/reference list update |
| `overlay_refresh` | 216 | Object/mob overlay refresh |
| `turf_grid` | 20, 32, 97 | Turf-grid RLE fills |
| `screen_refresh` | 51, 53 | Screen add / refresh |
| `cid_pair` | 9, 257 | CID pair clear |
| `cursor_refresh` / `client_image` | 56 / 57 | Cursor + client image |
| `view_resize` / `view_size` / `stat_format` | 62 / 200 / 33 | Screen + viewport geometry |
| `stats` / `stat_panel` / `cspell` | 106 / 10 / 17 | Stat panel, panel CIDs, verbs/spells |
| `sound` | 109 | Sound with 10 flag-gated blocks |
| `client_refs` | 118 | Client reference-list update |
| `id_list` | 52, 113 | Deref / single id lists |
| `tick_lag` / `turf_obj_flick` | 55 / 199 | Tick lag, turf/obj flick |
| `rsc_cache` / `rsc_name` / `rsc_index` | 14 / 254 / 159 | Resource cache, id→name, file index |
| `server_config` / `browse_rsc` | 59 / 114 | Progressive length-terminated schedules |
| `expansion_list` | 63 | Callback expansion strings |
| `input_prompt` / `flick_command` / `world_name` | 98 / 108 / 239 | String-bearing dialog bodies |
| `output_msg` / `winoutput_msg` / `browse_msg` / `skin_msg` | 167,168,177 / 169 / 132 / 175 | Winset / browser / skin output |
| `disconnect_body` / `empty_body` | 0 / 22, 24, 141, 205 | Control bodies |

### Client → server bodies (12 message types)

Kept separate: a game type NUMBER means a *different* message per direction.

| Spec | Type(s) | Meaning |
|------|---------|---------|
| `u4_list` | 11, 60 | Fixed-`u4` id lists |
| `client_tile_mode` | 13 | Tile mode |
| `prompt_response` | 99, 100 | Parse / expand prompt response |
| `id_list` | 115 | Appearance ack (reuses `u2or4`) |
| `topic` | 129 | Client topic |
| `winget_result` | 169 | Winget result |
| `client_verb_arg` | 98 | Verb/topic arg + context ref |
| `rsc_response` | 158, 159 | RSC flow control (same wire layout; the number selects completion) |
| `rsc_upload` | 257 | RSC file upload |

### Transport

`transport/frame_header` (short, extended `0xA0/6`, and optional sequence prefix),
`transport/version_msg` (client type-1), `transport/reply_msg` (server type-1 reply
incl. both padding groups + the fold word).

Not covered by these specs, by design: the stream cipher, the crypt-key
derivation/fold arithmetic, the incremental reader's partial-read handling, and
direction/state-dependent dispatch glue. Those are stateful algorithms, not layouts —
they stay per-language in the client.

## Verification

This repo's own CI gate is that every spec **compiles** with the pinned toolchain
(Python read-only + read-write, plus a Rust cross-language canary that catches
expression incompatibilities early).

**Byte-exactness is verified downstream**, in the reference consumer
[byond-net](https://github.com/byond-net/byond-net), whose `tools/equivalence_gate.py`
asserts over real 516 capture vectors that the generated codec round-trips every
captured body byte-for-byte and agrees with an independent imperative oracle. A spec
change should be validated there before it is considered done — compiling is necessary
but not sufficient.

## Not-yet-reversed frames

Tracked so the gap is visible rather than silently shipped as finished. These are the
BYOND **hub/pager** frames (`hub.byond.com:6001`, a separate sub-protocol from the game
channel). They are carried verbatim by consumers and are NOT `.ksy` candidates until
their field grammar is reversed:

| Type | Name | Status |
|------|------|--------|
| 161 | HubNews | opaque `78 9c` zlib blob after a fixed head |
| 94, 162, 163, 186, 218, 233, 236, 238 | HubControl family | short control frames, carried opaque |
| 164 | HubSessionTime | shape known (two LE u32), field MEANING unverified |
| 232, 72, 230 | hub cert requests | never observed on the wire |

All **game-channel** bodies observed in the reference 516 sessions are covered.
