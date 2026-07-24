meta:
  id: server_config
  title: BYOND server-config body (NetMsg type 59)
  endian: le
  ks-version: 0.11
  imports:
    - common/byond_common
doc: |
  Server-config / policy body (NetMsg type 59).

  A progressive length-terminated schedule: every field past the mandatory 3-byte
  prefix is emitted only while the server still has data, and read only while
  `cursor < msg_len`. The body is therefore a byte-exact PREFIX of the full schedule,
  truncated at a group boundary.

  The full schedule lives in the spec, and each length-gated group is an optional
  sub-type guarded by `_io.pos < _io.size`. Grouping the atomic partners (e.g.
  preload_flag + preload_id) into a sub-type means a value-gated partner (status_ext
  on bit 31, menu_clear on an empty menu_name) never references an absent field.
params:
  - id: fourbyte
    type: bool
    doc: Connection `fourbyte` flag - selects 4-byte vs 2-byte preload_id width.
seq:
  # --- mandatory 3-byte prefix ---
  - id: flags_a
    type: u1
  - id: flags_b
    type: u1
  - id: mob_dir
    type: u1
  # --- length-gated schedule (each present only while body bytes remain) ---
  - id: setting3
    type: u1
    if: _io.pos < _io.size
  - id: setting4
    type: u1
    if: _io.pos < _io.size
  - id: setting5
    type: u1
    if: _io.pos < _io.size
  - id: invert6
    type: u1
    if: _io.pos < _io.size
  - id: preload
    type: preload_pair(fourbyte)
    if: _io.pos < _io.size
  - id: status
    type: status_block
    if: _io.pos < _io.size
  - id: screen
    type: screen_pair
    if: _io.pos < _io.size
  - id: pane
    type: pane_pair
    if: _io.pos < _io.size
  - id: menu_url
    type: 'byond_common::net_string'
    if: _io.pos < _io.size
  - id: menu
    type: menu_block
    if: _io.pos < _io.size
  - id: verb_panel
    type: u1
    if: _io.pos < _io.size
  - id: map_id
    type: u4
    if: _io.pos < _io.size
  - id: map_format
    type: u4
    if: _io.pos < _io.size
types:
  preload_pair:
    doc: Atomic pair - a flag byte then a u2or4 preload id.
    params:
      - id: fourbyte
        type: bool
    seq:
      - id: preload_flag
        type: u1
      - id: preload_id
        type: 'byond_common::u2or4(fourbyte)'
  status_block:
    doc: |
      Status flags u32, plus a value-gated extension read only when bit 31 is set.
    seq:
      - id: status_flags
        type: u4
      - id: status_ext
        type: u4
        if: (status_flags & 0x80000000) != 0
  screen_pair:
    doc: Atomic pair - screen width then height.
    seq:
      - id: screen_w
        type: u2
      - id: screen_h
        type: u2
  pane_pair:
    doc: Atomic pair - two pane bytes.
    seq:
      - id: pane_a
        type: u1
      - id: pane_b
        type: u1
  menu_block:
    doc: |
      Menu name, plus a value-gated clear byte read only when the name decoded to the
      empty string.
    seq:
      - id: menu_name
        type: 'byond_common::net_string'
      - id: menu_clear
        type: u1
        if: menu_name.value.size == 0
