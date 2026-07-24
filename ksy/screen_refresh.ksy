meta:
  id: screen_refresh
  title: BYOND screen add / refresh (NetMsg types 51, 53)
  endian: le
  ks-version: 0.11
  imports:
    - common/byond_common
    - common/object_update
doc: |
  Screen-object add (type 51) / refresh (type 53): `[obj_id:u2or4][ref_id:u2or4]
  [flag:u1][ref:u4]` then the shared overlay-id list (`overlay_list` in object_update).
params:
  - id: fourbyte
    type: bool
seq:
  - id: obj_id
    type: 'byond_common::u2or4(fourbyte)'
  - id: ref_id
    type: 'byond_common::u2or4(fourbyte)'
  - id: flag
    type: u1
  - id: ref
    type: u4
  - id: overlays
    type: 'object_update::overlay_list'
