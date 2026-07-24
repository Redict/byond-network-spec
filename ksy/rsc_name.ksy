meta:
  id: rsc_name
  title: BYOND RSC id->name announcement (NetMsg type 254)
  endian: le
  ks-version: 0.11
  imports:
    - common/byond_common
doc: |
  RSC id->name announcement (NetMsg type 254): `[id:4 LE][name:cstring]`.
seq:
  - id: id
    type: u4
  - id: name
    type: 'byond_common::net_string'
