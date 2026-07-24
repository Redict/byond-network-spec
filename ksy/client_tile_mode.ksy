meta:
  id: client_tile_mode
  title: BYOND client tile mode (c2s NetMsg type 13)
  endian: le
  ks-version: 0.11
doc: |
  Client->server tile/glitz mode (c2s NetMsg type 13): a single 2-byte little-endian
  mode word.
seq:
  - id: glitz_mode
    type: u2
