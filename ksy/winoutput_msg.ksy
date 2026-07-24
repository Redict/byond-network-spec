meta:
  id: winoutput_msg
  title: BYOND winoutput (NetMsg type 169)
  endian: le
  ks-version: 0.11
  imports:
    - common/byond_common
doc: |
  Winoutput (NetMsg type 169): `[control:cstr][payload:cstr][id:u4]` then an OPTIONAL
  flag byte (present iff trailing bytes remain).
seq:
  - id: control
    type: 'byond_common::net_string'
  - id: payload
    type: 'byond_common::net_string'
  - id: id
    type: u4
  # optional trailing flag byte (present iff bytes remain); modeled as a size-eos
  # blob so the serializer stays exact - the caller interprets 0/1 bytes.
  - id: rest
    size-eos: true
