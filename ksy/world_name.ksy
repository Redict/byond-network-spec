meta:
  id: world_name
  title: BYOND world name (NetMsg type 239)
  endian: le
  ks-version: 0.11
  imports:
    - common/byond_common
doc: |
  World name (NetMsg type 239): `[ref:u4][name:cstr][word:u2]`.
seq:
  - id: ref
    type: u4
  - id: name
    type: 'byond_common::net_string'
  - id: word
    type: u2
