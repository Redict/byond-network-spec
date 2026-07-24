meta:
  id: browse_msg
  title: BYOND browse output (NetMsg type 132)
  endian: le
  ks-version: 0.11
  imports:
    - common/byond_common
doc: |
  Browse output (NetMsg type 132): `[control:cstr][payload:cstr]` then an OPTIONAL flag
  byte (present iff trailing bytes remain).
seq:
  - id: control
    type: 'byond_common::net_string'
  - id: payload
    type: 'byond_common::net_string'
  # optional trailing flag byte (present iff bytes remain); modeled as a size-eos
  # blob so the serializer stays exact - the caller interprets 0/1 bytes.
  - id: rest
    size-eos: true
