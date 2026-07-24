meta:
  id: turf_obj_flick
  title: BYOND turf/obj flick (NetMsg type 199)
  endian: le
  ks-version: 0.11
doc: |
  Turf/object flick (NetMsg type 199): `[kind:u1][ref:u4][word:u2][ref2:u4]`
  (11 bytes).
seq:
  - id: kind
    type: u1
  - id: ref
    type: u4
  - id: word
    type: u2
  - id: ref2
    type: u4
