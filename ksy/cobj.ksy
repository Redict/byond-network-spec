meta:
  id: cobj
  title: BYOND cobj update body (NetMsg type 7)
  endian: le
  ks-version: 0.11
  imports:
    - common/byond_common
    - common/object_update
doc: |
  Cobj update (NetMsg type 7). The larger sibling of cmob: a flag-gated header
  (position/loc words, an eye/perspective refresh block, skip words, an optional eye
  reference, and a second extra-flags sub-block) followed by the SAME shared
  object-update tail.

  Modern path only (version 0x204, minor 0x694, fourbyte true); the legacy header
  branches (version <= 0x154, minor <= 0x610) are out of scope. version/minor/fourbyte
  are caller-supplied params.
params:
  - id: version
    type: u2
  - id: minor
    type: u2
  - id: fourbyte
    type: bool
seq:
  - id: flag
    type: u1
  - id: step_words
    type: u2
    repeat: expr
    repeat-expr: 2
    if: (flag & 2) != 0
  - id: loc_words
    type: u2
    repeat: expr
    repeat-expr: 2
    if: (flag & 4) != 0
  - id: refresh
    type: refresh_block(version)
    if: (flag & 6) != 0
  - id: skip_bit3
    type: u2
    if: (flag & 8) != 0
  - id: skip_bit4
    type: u2
    if: (flag & 0x10) != 0
  - id: show_popups
    type: u1
    if: (flag & 0x20) != 0
  - id: eye
    type: 'object_update::net_ref(version, fourbyte)'
    if: (flag & 0x40) != 0
  - id: extra
    type: extra_block(version)
    if: (flag & 0x80) != 0
  - id: tail
    type: 'object_update::tail(version, fourbyte)'
types:
  refresh_block:
    doc: |
      Eye/perspective refresh. When moved==0 an eye kind/ref id pair is present;
      client_dir_next is gated version > 0x201.
    params:
      - id: version
        type: u2
    seq:
      - id: moved
        type: u1
      - id: eye_kind
        type: u1
        if: moved == 0
      - id: eye_ref
        type: u4
        if: moved == 0
      - id: perspective
        type: u1
      - id: client_dir
        type: u4
      - id: client_dir_next
        type: u4
        if: version > 0x201
      - id: eye_offset
        type: u4
      - id: eye_offset_next
        type: u4
      - id: view_x
        type: u2
      - id: view_y
        type: u2
  extra_block:
    doc: |
      Second (bit 0x80) flag byte; each set bit pulls in a fixed group of
      little-endian fields. loc_block's 3rd word is gated version > 0x1FE.
    params:
      - id: version
        type: u2
    seq:
      - id: flags
        type: u1
      # &0x01 sight (u1)
      - id: sight
        type: u1
        if: (flags & 0x01) != 0
      # &0x02 sight_flags (u1)
      - id: sight_flags
        type: u1
        if: (flags & 0x02) != 0
      # &0x04 see_in_dark (u4)
      - id: see_in_dark
        type: u4
        if: (flags & 0x04) != 0
      # &0x08 loc_block: u2, u2, [u2 if ver>0x1FE], u2
      - id: loc_block_0
        type: u2
        if: (flags & 0x08) != 0
      - id: loc_block_1
        type: u2
        if: (flags & 0x08) != 0
      - id: loc_block_2
        type: u2
        if: (flags & 0x08) != 0 and version > 0x1FE
      - id: loc_block_3
        type: u2
        if: (flags & 0x08) != 0
      # &0x10 step_block: u2, u2
      - id: step_block_0
        type: u2
        if: (flags & 0x10) != 0
      - id: step_block_1
        type: u2
        if: (flags & 0x10) != 0
      # &0x20 screen_block: u2 x4
      - id: screen_block_0
        type: u2
        if: (flags & 0x20) != 0
      - id: screen_block_1
        type: u2
        if: (flags & 0x20) != 0
      - id: screen_block_2
        type: u2
        if: (flags & 0x20) != 0
      - id: screen_block_3
        type: u2
        if: (flags & 0x20) != 0
      # &0x40 bound_block: u2 x4
      - id: bound_block_0
        type: u2
        if: (flags & 0x40) != 0
      - id: bound_block_1
        type: u2
        if: (flags & 0x40) != 0
      - id: bound_block_2
        type: u2
        if: (flags & 0x40) != 0
      - id: bound_block_3
        type: u2
        if: (flags & 0x40) != 0
