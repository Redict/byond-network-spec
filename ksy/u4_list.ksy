meta:
  id: u4_list
  title: BYOND fixed 4-byte id list body (c2s NetMsg types 11, 60)
  endian: le
  ks-version: 0.11
doc: |
  A bare list of FIXED 4-byte little-endian ids packed to the end of the body (no
  count prefix), self-delimiting by body length. Used by the client->server del-image
  (type 11) and appearance-id list (type 60) messages, both of which emit 4-byte ids
  regardless of the connection `fourbyte` flag - unlike the s2c `id_list` (types
  52/113), whose ids follow the flag. Kept separate so each spec states the real
  on-wire width.
seq:
  - id: ids
    type: u4
    repeat: eos
