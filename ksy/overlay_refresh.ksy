meta:
  id: overlay_refresh
  title: BYOND object/mob overlay refresh (NetMsg type 216)
  endian: le
  ks-version: 0.11
  imports:
    - common/object_update
doc: |
  Object/mob overlay refresh (NetMsg type 216). `[count:u2]` then that many entries,
  each `[kind:u1]` then, for kind==1, a position/appearance refresh
  `[x:u2][y:u2][z:u2][ref:u4][tail:u2]`, else `[id:u4]`; each entry ends with the
  shared overlay-id list (`object_update::overlay_list`).

  Every captured entry uses kind==2 (id + overlay list); the kind==1 refresh layout is
  never seen on the wire and is exercised only by synthetic vectors.
seq:
  - id: count
    type: u2
  - id: entries
    type: entry
    repeat: expr
    repeat-expr: count
types:
  entry:
    seq:
      - id: kind
        type: u1
      # kind == 1: position/appearance refresh (never captured)
      - id: x
        type: u2
        if: kind == 1
      - id: y
        type: u2
        if: kind == 1
      - id: z
        type: u2
        if: kind == 1
      - id: ref
        type: u4
        if: kind == 1
      - id: tail
        type: u2
        if: kind == 1
      # else: reference by id
      - id: id
        type: u4
        if: kind != 1
      - id: overlays
        type: 'object_update::overlay_list'
