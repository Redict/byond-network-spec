meta:
  id: empty_body
  title: BYOND zero-length control body (NetMsg types 22, 24, 141, 205)
  endian: le
  ks-version: 0.11
doc: |
  A control message whose body carries no fields at all - a pure signal keyed only by
  its message type. Types 22, 24, 141, 205 are all zero-length on the wire and share
  this one empty layout. There is nothing to parse, so `seq` is empty.
seq: []
