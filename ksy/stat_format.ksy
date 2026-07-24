meta:
  id: stat_format
  title: BYOND stat-format header (NetMsg type 33)
  endian: le
  ks-version: 0.11
doc: |
  Stat-panel format header (NetMsg type 33): ten little-endian words followed by a
  single pad byte (21 bytes total).
seq:
  - id: words
    type: u2
    repeat: expr
    repeat-expr: 10
  - id: pad
    type: u1
