meta:
  id: input_prompt
  title: BYOND input prompt (NetMsg type 98)
  endian: le
  ks-version: 0.11
  imports:
    - common/byond_common
doc: |
  Input prompt (NetMsg type 98): three NUL-terminated strings (title/subtitle/default),
  then id/input_type/flags and a trailing word. The id is a fixed 4-byte value.
seq:
  - id: title
    type: 'byond_common::net_string'
  - id: subtitle
    type: 'byond_common::net_string'
  - id: default
    type: 'byond_common::net_string'
  - id: id
    type: u4
  - id: input_type
    type: u1
  - id: flags
    type: u1
  - id: tail
    type: u4
