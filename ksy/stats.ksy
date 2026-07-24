meta:
  id: stats
  title: BYOND stat panel update (NetMsg type 106)
  endian: le
  ks-version: 0.11
  imports:
    - common/byond_common
    - common/object_update
doc: |
  Stat panel update (NetMsg type 106).

  A flags byte then a server-gated secondary byte (`has_secondary`), four flag-gated
  header fields (bit 0 CID ref, bit 1 panel-name list, bit 2 current panel, bit 3
  location ref - the two refs are shared `object_update::net_ref`), a stat list
  (`[name:cstr][value:net_ref][id:u2]`), and a delete-id list.
params:
  - id: version
    type: u2
  - id: fourbyte
    type: bool
  - id: has_secondary
    type: bool
seq:
  - id: flags
    type: u1
  - id: secondary
    type: u1
    if: has_secondary
  # flags & 0x01: stat CID reference
  - id: stat_cid
    type: 'object_update::net_ref(version, fourbyte)'
    if: (flags & 0x01) != 0
  # flags & 0x02: panel-name list
  - id: panels
    type: panel_list
    if: (flags & 0x02) != 0
  # flags & 0x04: current panel id
  - id: cur_panel
    type: u2
    if: (flags & 0x04) != 0
  # flags & 0x08: stat-location reference
  - id: stat_loc
    type: 'object_update::net_ref(version, fourbyte)'
    if: (flags & 0x08) != 0
  # AddStat list
  - id: stat_count
    type: u2
  - id: stats
    type: stat_entry(version, fourbyte)
    repeat: expr
    repeat-expr: stat_count
  # DelStat list
  - id: delete_count
    type: u2
  - id: deletes
    type: u2
    repeat: expr
    repeat-expr: delete_count
types:
  panel_list:
    seq:
      - id: count
        type: u2
      - id: names
        type: 'byond_common::net_string'
        repeat: expr
        repeat-expr: count
  stat_entry:
    params:
      - id: version
        type: u2
      - id: fourbyte
        type: bool
    seq:
      - id: name
        type: 'byond_common::net_string'
      - id: value
        type: 'object_update::net_ref(version, fourbyte)'
      - id: id
        type: u2
