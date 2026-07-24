meta:
  id: cid_pair
  title: BYOND id-pair clear / variant body (NetMsg types 9, 257)
  endian: le
  ks-version: 0.11
  imports:
    - common/byond_common
doc: |
  Id-pair refresh body, shared by the type-9 (clear) and type-257 (variant) messages.

  A flat struct: two `u2or4` ids (object + reference) whose width follows the
  negotiated `fourbyte` flag, then a single flag byte.
params:
  - id: fourbyte
    type: bool
    doc: Connection `fourbyte` flag - selects 4-byte (true) vs 2-byte id width.
seq:
  - id: obj_id
    type: 'byond_common::u2or4(fourbyte)'
  - id: ref_id
    type: 'byond_common::u2or4(fourbyte)'
  - id: flag
    type: u1
