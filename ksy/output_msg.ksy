meta:
  id: output_msg
  title: BYOND output / winset / winclone (NetMsg types 167, 168, 177)
  endian: le
  ks-version: 0.11
  imports:
    - common/byond_common
doc: |
  Output/winset/winclone passthrough (NetMsg types 167, 168, 177): two NUL-terminated
  strings - a control/target id and a payload (winset params or HTML), carried
  verbatim.
seq:
  - id: control
    type: 'byond_common::net_string'
  - id: payload
    type: 'byond_common::net_string'
