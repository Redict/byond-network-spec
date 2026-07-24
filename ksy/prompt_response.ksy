meta:
  id: prompt_response
  title: BYOND client prompt response (c2s NetMsg types 99, 100)
  endian: le
  ks-version: 0.11
  imports:
    - common/byond_common
doc: |
  Client->server prompt response (c2s NetMsg types 99, 100):
  `[text:cstr][id:u4][ref:u2or4]`. The trailing `ref` width follows the connection
  `fourbyte` flag (4 bytes in the captures).
params:
  - id: fourbyte
    type: bool
    doc: Connection `fourbyte` flag - selects 4-byte (true) vs 2-byte `ref` width.
seq:
  - id: text
    type: 'byond_common::net_string'
  - id: id
    type: u4
  - id: ref
    type: 'byond_common::u2or4(fourbyte)'
