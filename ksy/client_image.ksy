meta:
  id: client_image
  title: BYOND client image (NetMsg type 57)
  endian: le
  ks-version: 0.11
doc: |
  Client image (NetMsg type 57): `[flag:u1][ref_a:u4][ref_b:u4]` (9 bytes).
seq:
  - id: flag
    type: u1
  - id: ref_a
    type: u4
  - id: ref_b
    type: u4
