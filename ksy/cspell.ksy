meta:
  id: cspell
  title: BYOND verb/spell definition (NetMsg type 17)
  endian: le
  ks-version: 0.11
  imports:
    - common/byond_common
doc: |
  Verb/spell definition (NetMsg type 17).

  Note the id widths use two separate gates, distinct from the object-id `fourbyte`:
  `spell_id_wide` selects the `spell_id` width (2-byte on a 516 session), and
  `param_wide` selects the per-parameter id width (4-byte on 516). Reading `spell_id`
  at the wrong width shifts the first bytes of `name`.
params:
  - id: spell_id_wide
    type: bool
    doc: Gate for spell_id width (false = 2-byte on 516).
  - id: param_wide
    type: bool
    doc: Gate for per-parameter id width (true = 4-byte on 516).
seq:
  - id: spell_id
    type: 'byond_common::u2or4(spell_id_wide)'
  - id: name
    type: 'byond_common::net_string'
  - id: category
    type: 'byond_common::net_string'
  - id: desc
    type: 'byond_common::net_string'
  - id: icon
    type: u1
  - id: state
    type: u1
  - id: flags
    type: u1
  # flags & 0x80: extended cost/state block
  - id: ext
    type: u4
    if: (flags & 0x80) != 0
  - id: ext_state
    type: u1
    if: (flags & 0x80) != 0
  - id: param_count
    type: u1
  - id: params
    type: parameter(param_wide)
    repeat: expr
    repeat-expr: param_count
types:
  parameter:
    params:
      - id: param_wide
        type: bool
    seq:
      - id: param_id
        type: 'byond_common::u2or4(param_wide)'
      - id: param_type
        type: u1
      - id: param_flag
        type: u1
