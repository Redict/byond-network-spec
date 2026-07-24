meta:
  id: mob_list
  title: BYOND mob/reference list update (NetMsg type 241)
  endian: le
  ks-version: 0.11
  imports:
    - common/byond_common
doc: |
  Mob/reference list update (NetMsg type 241).

  Wire shape: a 2-byte primary count, a block of that many 4-byte references, a
  PARALLEL id stream of `count` entries (each a `u2or4` id, or the run-length
  sentinel 0xFFFFFFFF/0xFFFF followed by a 1-byte run count repeating the previous
  id), then an optional 4-byte continuation word (0x09 in the captures).

  Each id-stream entry's shape depends on whether its id equals the width-dependent
  sentinel, so it is a discriminated record chosen by the parsed id value. `fourbyte`
  (id width / sentinel) is a caller-supplied param.
params:
  - id: fourbyte
    type: bool
    doc: Connection `fourbyte` flag - selects 4-byte vs 2-byte id width + sentinel.
seq:
  - id: count
    type: u2
  - id: refs
    type: u4
    repeat: expr
    repeat-expr: count
    doc: Primary reference block.
  - id: ids
    type: id_entry(fourbyte)
    repeat: expr
    repeat-expr: count
    doc: Parallel id stream, run-length aware (sentinel + run repeats previous id).
  - id: continuation
    type: u4
    if: not _io.eof
    doc: Terminating continuation word (0x09 in the captures); absent if the body
         ended after the id stream.
types:
  id_entry:
    doc: |
      One id-stream entry: a `u2or4` id, and - only when that id is the sentinel
      (all-ones for the negotiated width) - a 1-byte run count repeating the
      previous id. `is_sentinel` drives the discriminated tail.
    params:
      - id: fourbyte
        type: bool
    seq:
      - id: id
        type: 'byond_common::u2or4(fourbyte)'
      - id: run
        type: u1
        if: is_sentinel
    instances:
      is_sentinel:
        value: 'fourbyte ? (id.value == 0xffffffff) : (id.value == 0xffff)'
        doc: True when the id is the run-length sentinel for this width.
