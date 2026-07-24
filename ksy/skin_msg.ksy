meta:
  id: skin_msg
  title: BYOND skin definition (NetMsg type 175)
  endian: le
  ks-version: 0.11
  imports:
    - common/byond_common
doc: |
  Skin definition (NetMsg type 175): `[control:cstr][payload:cstr]` then an OPTIONAL
  trailing word (present iff bytes remain).
seq:
  - id: control
    type: 'byond_common::net_string'
  - id: payload
    type: 'byond_common::net_string'
  # optional trailing word (present iff bytes remain); modeled as a size-eos blob
  # so the serializer stays exact - the caller interprets 0/2 bytes.
  - id: rest
    size-eos: true
