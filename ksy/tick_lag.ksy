meta:
  id: tick_lag
  title: BYOND tick lag (NetMsg type 55)
  endian: le
  ks-version: 0.11
doc: |
  Tick lag (NetMsg type 55): a numerator/denominator pair of u4 words (8 bytes).
seq:
  - id: numerator
    type: u4
  - id: denominator
    type: u4
