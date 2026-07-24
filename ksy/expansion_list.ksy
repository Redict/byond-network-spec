meta:
  id: expansion_list
  title: BYOND verb-panel expansion list (NetMsg type 63)
  endian: le
  ks-version: 0.11
  imports:
    - common/byond_common
doc: |
  Verb-panel expansion list (NetMsg type 63): a 2-byte count followed by that many
  NUL-terminated verb/command names.
seq:
  - id: num_names
    type: u2
  - id: names
    type: 'byond_common::net_string'
    repeat: expr
    repeat-expr: num_names
