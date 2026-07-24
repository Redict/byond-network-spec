meta:
  id: cursor_refresh
  title: BYOND cursor refresh (NetMsg type 56)
  endian: le
  ks-version: 0.11
  imports:
    - common/byond_common
doc: |
  Cursor refresh (NetMsg type 56): an object id then up to two trailing `[x:u2][y:u2]`
  coordinate pairs (read to end-of-body).
params:
  - id: fourbyte
    type: bool
seq:
  - id: obj_id
    type: 'byond_common::u2or4(fourbyte)'
  - id: pairs
    type: coord_pair
    repeat: eos
types:
  coord_pair:
    seq:
      - id: x
        type: u2
      - id: y
        type: u2
