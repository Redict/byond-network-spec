meta:
  id: winget_result
  title: BYOND client winget result (c2s NetMsg type 169)
  endian: le
  ks-version: 0.11
  imports:
    - common/byond_common
doc: |
  Client->server winget/winexists result (c2s NetMsg type 169): `[value:cstr][id:u4]`.
seq:
  - id: value
    type: 'byond_common::net_string'
  - id: id
    type: u4
