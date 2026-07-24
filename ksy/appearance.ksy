meta:
  id: appearance
  title: BYOND CAppearance body (NetMsg type 38)
  endian: le
  ks-version: 0.11
  imports:
    - common/byond_common
doc: |
  CAppearance wire body (NetMsg type 38).

  A clean struct: a fixed field order with version-gated and flag-gated optional
  fields, u2or4 id refs, and three interleaved count+array runs. `version` and
  `fourbyte` are caller-supplied params (a 516 session uses version 0x204, fourbyte
  true).

  The trailing block (animate_time / blend / flags + flag-gated fields) is always
  present on the wire, so it is modeled unconditionally.
params:
  - id: version
    type: u2
    doc: Negotiated protocol version (516 == 0x204). Gates optional header fields.
  - id: fourbyte
    type: bool
    doc: Connection `fourbyte` flag - selects 4-byte (true) vs 2-byte id width.
seq:
  - id: appearance_id
    type: 'byond_common::u2or4(fourbyte)'
  - id: icon
    type: 'byond_common::net_string'
  - id: icon_state
    type: 'byond_common::net_string'
  - id: overlay_source_id
    type: 'byond_common::u2or4(fourbyte)'
  - id: name
    type: 'byond_common::net_string'
  - id: desc
    type: 'byond_common::net_string'
  # --- override-name block (version > 0x1ED) ---
  - id: override_name
    type: 'byond_common::net_string'
    if: version > 0x1ED
  - id: layer
    type: u2
    if: version > 0x1ED
  - id: plane
    type: u2
    if: version > 0x1ED
  - id: maptext_width
    type: u2
    if: version > 0x1FB
  - id: maptext_height
    type: u2
    if: version > 0x1FB
  - id: sight_flags
    type: u1
  # --- color block (version > 0x131): base color + three kind-gated refs ---
  - id: color
    type: u4
    if: version > 0x131
  - id: color_r_kind
    type: u1
    if: version > 0x131
  - id: color_r_ref
    type: 'byond_common::u2or4(fourbyte)'
    if: version > 0x131 and color_r_kind == 2
  - id: color_g_kind
    type: u1
    if: version > 0x131
  - id: color_g_ref
    type: 'byond_common::u2or4(fourbyte)'
    if: version > 0x131 and color_g_kind == 2
  - id: color_b_kind
    type: u1
    if: version > 0x131
  - id: color_b_ref
    type: 'byond_common::u2or4(fourbyte)'
    if: version > 0x131 and color_b_kind == 2
  - id: overlay_group_id
    type: 'byond_common::u2or4(fourbyte)'
  # --- interleaved count+array runs: overlays, underlays, filter ids ---
  # Overlay ids use a DIFFERENT width flag from the connection `fourbyte` (the same
  # 2-byte gate as the c2s keypress / type-17 spell_id), so they are u2 here.
  # underlay/filter ids below are always 4 bytes and stay u2or4(fourbyte).
  - id: overlay_count
    type: u2
  - id: overlay
    type: u2
    repeat: expr
    repeat-expr: overlay_count
  - id: underlay_count
    type: u2
  - id: underlay
    type: 'byond_common::u2or4(fourbyte)'
    repeat: expr
    repeat-expr: underlay_count
  - id: filter_id_count
    type: u2
  - id: filter_ids
    type: 'byond_common::u2or4(fourbyte)'
    repeat: expr
    repeat-expr: filter_id_count
  # --- trailing block (present on every captured type-38 body) ---
  - id: animate_time
    type: u4
  - id: blend
    type: 'byond_common::net_string'
  - id: flags
    type: ext_flags
  # --- flag-gated fields, in fixed order (flags.value bit tests) ---
  - id: mouse_opacity
    type: u1
    if: (flags.value & 0x001) != 0
  - id: pixel_z
    type: u1
    if: (flags.value & 0x002) != 0
  - id: glide_size
    type: u1
    if: (flags.value & 0x004) != 0
  - id: pixel_x
    type: u2
    if: (flags.value & 0x008) != 0
  - id: pixel_y
    type: u2
    if: (flags.value & 0x008) != 0
  - id: pixel_w
    type: u2
    if: (flags.value & 0x008) != 0 and version > 0x1FE
  - id: pixel_h
    type: u2
    if: (flags.value & 0x008) != 0
  - id: transform_id
    type: u4
    if: (flags.value & 0x010) != 0
  - id: transform_matrix
    type: u4
    repeat: expr
    repeat-expr: 6
    if: (flags.value & 0x020) != 0
  - id: render_source_id
    type: u4
    if: (flags.value & 0x040) != 0
  - id: blend_mode
    type: u1
    if: (flags.value & 0x100) != 0
  - id: render_flags
    type: u2
    if: (flags.value & 0x200) != 0
  - id: color_matrix
    type: u4
    repeat: expr
    repeat-expr: 20
    if: (flags.value & 0x400) != 0
  - id: vis_list
    type: named_list
    if: (flags.value & 0x800) != 0
  - id: render_target
    type: 'byond_common::net_string'
    if: (flags.value & 0x1000) != 0
  - id: screen_loc
    type: 'byond_common::net_string'
    if: (flags.value & 0x1000) != 0
  - id: appearance_flags
    type: u2
    if: (flags.value & 0x2000) != 0
  - id: filter_id
    type: u4
    if: (flags.value & 0x4000) != 0
types:
  ext_flags:
    doc: |
      Appearance flag word: 1 byte, promoted to a 4-byte little-endian dword when the
      low byte has 0x80 set. `value` is the resolved flag word used by the gated fields.
    seq:
      - id: b0
        type: u1
      - id: b1
        type: u1
        if: (b0 & 0x80) != 0
      - id: b2
        type: u1
        if: (b0 & 0x80) != 0
      - id: b3
        type: u1
        if: (b0 & 0x80) != 0
    instances:
      value:
        value: '(b0 & 0x80) != 0 ? (b0 | (b1 << 8) | (b2 << 16) | (b3 << 24)) : b0'
  named_node:
    doc: |
      One 0x800 vis-list entry: a nested CAppearance reference. Layout: a `kind` byte,
      a version-gated header (sub_kind + id), a 0x80-promoted flag word, then a fixed
      field order gated by that flag - the same appearance-tail idiom as the outer
      body. The gated field values are opaque sub-appearance data (kept as fixed-size
      blobs); the structure is decoded.

      kind 0 is a null node (nothing follows).
    seq:
      - id: kind
        type: u1
      - id: sub_kind
        type: u1
        if: kind != 0
      - id: node_id
        type: u4
        if: kind != 0
      - id: flag
        type: promoted_flag
        if: kind != 0
      - id: f0001
        size: 4
        if: 'kind != 0 and (flag.value & 0x0001) != 0'
      - id: f0002
        size: 4
        if: 'kind != 0 and (flag.value & 0x0002) != 0'
      - id: f0004
        size: 4
        if: 'kind != 0 and (flag.value & 0x0004) != 0'
      - id: f0008
        size: 4
        if: 'kind != 0 and (flag.value & 0x0008) != 0'
      - id: f0010
        size: 4
        if: 'kind != 0 and (flag.value & 0x0010) != 0'
      - id: f0020
        size: 2
        if: 'kind != 0 and (flag.value & 0x0020) != 0'
      - id: f0040
        size: 4
        if: 'kind != 0 and (flag.value & 0x0040) != 0'
      - id: f0100
        size: 4
        if: 'kind != 0 and (flag.value & 0x0100) != 0'
      - id: name
        type: 'byond_common::net_string'
        if: 'kind != 0 and (flag.value & 0x0200) != 0'
      - id: matrix
        size: 80
        if: 'kind != 0 and (flag.value & 0x0400) != 0'
      - id: f0800
        size: 4
        if: 'kind != 0 and (flag.value & 0x0800) != 0'
      - id: f1000
        size: 4
        if: 'kind != 0 and (flag.value & 0x1000) != 0'
      - id: f2000
        size: 1
        if: 'kind != 0 and (flag.value & 0x2000) != 0'
      - id: ext_present
        type: u1
        if: 'kind != 0 and (flag.value & 0x4000) != 0'
      - id: ext
        size: 24
        if: 'kind != 0 and (flag.value & 0x4000) != 0 and ext_present != 0'
  promoted_flag:
    doc: |
      A flag word inside a vis node: 1 byte, promoted to a 4-byte little-endian dword
      when the low byte has 0x80 set. `value` is the resolved word used by the gated
      fields.
    seq:
      - id: b0
        type: u1
      - id: b1
        type: u1
        if: (b0 & 0x80) != 0
      - id: b2
        type: u1
        if: (b0 & 0x80) != 0
      - id: b3
        type: u1
        if: (b0 & 0x80) != 0
    instances:
      value:
        value: '(b0 & 0x80) != 0 ? (b0 | (b1 << 8) | (b2 << 16) | (b3 << 24)) : b0'
  named_list:
    doc: The 0x800 vis list - a 1-byte count then that many kind-tagged nodes.
    seq:
      - id: count
        type: u1
      - id: nodes
        type: named_node
        repeat: expr
        repeat-expr: count
