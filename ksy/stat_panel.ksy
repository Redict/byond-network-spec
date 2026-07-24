meta:
  id: stat_panel
  title: BYOND stat-panel CID lists (NetMsg type 10)
  endian: le
  ks-version: 0.11
  imports:
    - common/byond_common
doc: |
  Stat-panel CID update (NetMsg type 10): four count-prefixed sections in order - an
  id list (added ids), a pair list (added id/value), an id list (removed ids), and a
  pair list (removed id/value). Each count is a u2; ids/values use the `u2or4` width
  flag.
params:
  - id: fourbyte
    type: bool
seq:
  - id: add_ids
    type: id_section(fourbyte)
  - id: add_pairs
    type: pair_section(fourbyte)
  - id: del_ids
    type: id_section(fourbyte)
  - id: del_pairs
    type: pair_section(fourbyte)
types:
  id_section:
    params:
      - id: fourbyte
        type: bool
    seq:
      - id: count
        type: u2
      - id: ids
        type: 'byond_common::u2or4(fourbyte)'
        repeat: expr
        repeat-expr: count
  pair_section:
    params:
      - id: fourbyte
        type: bool
    seq:
      - id: count
        type: u2
      - id: pairs
        type: id_value(fourbyte)
        repeat: expr
        repeat-expr: count
  id_value:
    params:
      - id: fourbyte
        type: bool
    seq:
      - id: id
        type: 'byond_common::u2or4(fourbyte)'
      - id: value
        type: 'byond_common::u2or4(fourbyte)'
