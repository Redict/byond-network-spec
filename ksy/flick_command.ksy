meta:
  id: flick_command
  title: BYOND flick command (NetMsg type 108)
  endian: le
  ks-version: 0.11
  imports:
    - common/byond_common
doc: |
  Flick command (NetMsg type 108):
  `[lead:u1][name:cstr][kind:u1][ref_a:u4][ref_b:u4][word:u2]`.
seq:
  - id: lead
    type: u1
  - id: name
    type: 'byond_common::net_string'
  - id: kind
    type: u1
  - id: ref_a
    type: u4
  - id: ref_b
    type: u4
  - id: word
    type: u2
