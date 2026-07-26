# BYOND Network Specification

## Purpose

Language-neutral [Kaitai Struct](https://kaitai.io) `.ksy` specifications of the BYOND
NetMsg wire **layouts**. This repo is the **single source of truth for message-body
layouts** — every consumer, in every language, gets the layout from here. It ships
specs only; parsers are generated on demand and are not tracked.

Reverse-engineering evidence (captures, IDA analysis, confidence tiers) lives in the
reference consumer [byond-net](https://github.com/byond-net/byond-net), not here. A
`.ksy` states *what the bytes are*; that repo records *how sure we are and why*.

## Ownership

| Path | Scope |
|------|-------|
| `ksy/*.ksy` | One spec per message body (45 specs, 47 s2c + 12 c2s message types) |
| `ksy/common/byond_common.ksy` | Shared idioms: `u2or4`, `net_string`. Reuse these; never re-derive per file |
| `ksy/common/object_update.ksy` | Shared S1..S10 tail + recursive `net_ref` (types 7/8 and friends) |
| `ksy/transport/` | Frame header + the type-1 version message and reply |
| `tools/regen.ps1` / `regen.sh` | Compile every spec into `generated/` (gitignored). Keep the two in sync |
| `.github/workflows/spec-ci.yml` | Compile gate: Python (ro + rw) + a Rust cross-language canary |

## Local Contracts

- **Bodies only.** These specs describe the decoded message **body**, nothing before
  it. The transport ALGORITHMS — the stream cipher, the crypt key derive/fold, the
  incremental reader's partial-read handling, and the connection-global `fourbyte`
  flag — are stateful and stay per-language in the client. The transport *layouts*
  (frame header, version message, reply) ARE specs, under `ksy/transport/`.
- **All body fields are little-endian** (`meta: endian: le`). Only the framing header
  is big-endian.
- **Session state is passed in as `params`, never read from the body.** `version`,
  `minor`, and `fourbyte` come from the negotiated handshake. Version-gated layouts
  are written as `if version > ...` so no session state leaks into the wire model.
- **Target is BYOND 516.** 503 is reference-only.
- **Pinned toolchain:** `kaitai-struct-compiler` **0.11** + JDK 21, and the
  `kaitaistruct` **0.11** Python runtime. Generated code must be reproducible from the
  spec — never hand-edit anything under `generated/`.
- Kaitai **serialization is Python/Java-only** as of 0.11. Other languages get parsers
  from these specs and supply a hand-written writer.
- A spec must compile in BOTH modes (read-only and read-write). The read-write mode is
  the strict one; bodies with `size-eos` or bounded substreams need an exact-size write
  buffer on the consumer side.
- `generated/` is **not tracked**. Produce it with `tools/regen.*`.

## Work Guidance

Adding or changing a body layout:

1. **Reverse the handler first.** Prefer the named 503 decompilation for semantics,
   then confirm version-gated field widths against a 516 capture / the 516 binary.
   That evidence lives in byond-net (`docs/`, `src/byond/proto/AGENTS.md`).
2. Add/edit `ksy/<name>.ksy`. Reuse `common/byond_common` (`u2or4`, `net_string`) and
   `common/object_update` where the handler does. Put `version`/`minor`/`fourbyte` in
   `params`.
3. Write a real `doc:` block — the type number(s), the field meanings, and the IDA/
   source anchor. The spec is the layout documentation.
4. Regenerate: `pwsh tools/regen.ps1` (Windows) or `bash tools/regen.sh`.
5. **Verify downstream.** Map the generated class into byond-net's
   `kaitai_bodies.py` and run `uv run python tools/equivalence_gate.py` there.

Do not model a runtime *decision* ("pick a sub-codec by a flag") in a `.ksy` — Kaitai
models a byte layout. Keep that dispatch glue imperative in the consumer and delegate
each concrete body to its spec.

## Verification

- **Here (necessary, not sufficient):** `spec-ci.yml` — every spec compiles with the
  pinned compiler to Python read-only + read-write, plus a Rust compile canary that
  surfaces expression incompatibilities early.
- **Downstream (the real gate):** byond-net's `tools/equivalence_gate.py` asserts,
  over real 516 capture vectors, that the generated codec round-trips every captured
  body byte-for-byte and agrees with an independent imperative oracle. Current
  coverage: 47 s2c types / 657 vectors, 11 c2s types / 460 vectors, 9 transport checks.

A spec change that compiles but was never run through the downstream gate is
**unverified** — say so rather than implying it is done.

## Not-yet-reversed

Tracked in `README.md` → "Not-yet-reversed frames": the hub/pager `HubNews` (161),
the short hub control family, `HubSessionTime` (164, shape-only), and the never-observed
hub cert requests (232/72/230). All game-channel bodies observed in the reference 516
sessions are covered. Do not ship a guessed layout as a finished spec — an unreversed
body stays tracked and opaque until there is evidence.
