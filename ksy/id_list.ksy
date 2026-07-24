meta:
  id: id_list
  title: BYOND id list body (NetMsg types 52 deref-id-list, 113 single-id)
  endian: le
  ks-version: 0.11
  imports:
    - common/byond_common
doc: |
  A bare list of `u2or4` ids packed to the end of the body (no count prefix), shared
  by the type-52 (deref id list) and type-113 (single id) messages. The list is
  self-delimiting by body length; id width follows the negotiated `fourbyte` flag.
params:
  - id: fourbyte
    type: bool
    doc: Connection `fourbyte` flag - selects 4-byte (true) vs 2-byte id width.
seq:
  - id: ids
    type: 'byond_common::u2or4(fourbyte)'
    repeat: eos
