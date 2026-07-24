meta:
  id: object_update
  title: BYOND shared object-update tail (NetMsg types 7 + 8)
  endian: le
  ks-version: 0.11
  imports:
    - byond_common
doc: |
  Shared machinery for the object-update bodies (type 7 cobj / type 8 cmob). Both
  end with the SAME ten-sublist tail + trailer; only their leading header differs.

  Structure (fourbyte true):
    * Ten sublists S1..S10, each a 1-byte count then that many elements.
    * S1..S5 are mandatory; S6..S10 are a length-gated prefix (read only while body
      bytes remain), with S9 gated version > 0x1FF and S10 version > 0x201.
    * A trailing 1-byte flag, present only when S1..S10 were all consumed and body
      bytes still remain.

  Each element is a `u2or4` id, an optional `u2` aux (version > 0x1BE), then that
  section's fixed tail fields. S9 (overlays) carries the small overlay-id list
  (count + kind/ref pairs), not a full appearance embed. Same progressive-prefix
  shape as server_config: length gates use `if _io.pos < _io.size`, and the trailer
  is the terminal gated field.

  Also owns `net_ref`, the kind-dispatched reference reader used by the cobj header
  (recursive on kind 15).
types:
  # --- kind-dispatched reference (recursive on kind 15) ---
  net_ref:
    doc: |
      A reference: a 1-byte kind then a per-kind payload. version/fourbyte are
      params (aux on kinds 2/3 gated version > 0x1BE; the kind-15 list is gated
      version > 0x1FA and recurses into more net_refs).
    params:
      - id: version
        type: u2
      - id: fourbyte
        type: bool
    seq:
      - id: kind
        type: u1
      # kind 1: a=u4, b=u2or4
      - id: k1_a
        type: u4
        if: kind == 1
      - id: k1_b
        type: 'byond_common::u2or4(fourbyte)'
        if: kind == 1
      # kinds 2/3: a=u2or4, [aux=u2 if ver>0x1BE], b=u2or4
      - id: k23_a
        type: 'byond_common::u2or4(fourbyte)'
        if: kind == 2 or kind == 3
      - id: k23_aux
        type: u2
        if: (kind == 2 or kind == 3) and version > 0x1BE
      - id: k23_b
        type: 'byond_common::u2or4(fourbyte)'
        if: kind == 2 or kind == 3
      # kind 4: a=u2or4, b=u2or4
      - id: k4_a
        type: 'byond_common::u2or4(fourbyte)'
        if: kind == 4
      - id: k4_b
        type: 'byond_common::u2or4(fourbyte)'
        if: kind == 4
      # kind 6: NUL-terminated string
      - id: k6_s
        type: 'byond_common::net_string'
        if: kind == 6
      # kind 12: a=u4
      - id: k12_a
        type: u4
        if: kind == 12
      # kind 15: [count=u2 + count*net_ref] if ver>0x1FA
      - id: k15
        type: net_ref_list(version, fourbyte)
        if: kind == 15 and version > 0x1FA
      # kind 42: a=u4
      - id: k42_a
        type: u4
        if: kind == 42
  net_ref_list:
    doc: kind-15 payload - a u2 count then that many recursive net_refs.
    params:
      - id: version
        type: u2
      - id: fourbyte
        type: bool
    seq:
      - id: count
        type: u2
      - id: items
        type: net_ref(version, fourbyte)
        repeat: expr
        repeat-expr: count

  # --- overlay-id list (S9 element tail) ---
  overlay_entry:
    seq:
      - id: kind
        type: u1
      - id: ref
        type: u4
  overlay_list:
    seq:
      - id: count
        type: u2
      - id: entries
        type: overlay_entry
        repeat: expr
        repeat-expr: count

  # --- one element of a given sublist (section index picks the tail fields) ---
  element:
    params:
      - id: section
        type: u1
      - id: version
        type: u2
      - id: fourbyte
        type: bool
    seq:
      - id: id
        type: 'byond_common::u2or4(fourbyte)'
      - id: aux
        type: u2
        if: version > 0x1BE
      # S2 position: x(u2 >0x1CE), y(u2 >0x1CE), z(u2 >0x1FF)
      - id: pos_x
        type: u2
        if: section == 1 and version > 0x1CE
      - id: pos_y
        type: u2
        if: section == 1 and version > 0x1CE
      - id: pos_z
        type: u2
        if: section == 1 and version > 0x1FF
      # S3 loc: loc_id (u2or4)
      - id: loc_id
        type: 'byond_common::u2or4(fourbyte)'
        if: section == 2
      # S4 direction: dir (u1)
      - id: dir
        type: u1
        if: section == 3
      # S5 step: step_id (u2or4)
      - id: step_id
        type: 'byond_common::u2or4(fourbyte)'
        if: section == 4
      # S6 screen: screen_x, screen_y, screen_w(>0x1FE), screen_h
      - id: screen_x
        type: u2
        if: section == 5
      - id: screen_y
        type: u2
        if: section == 5
      - id: screen_w
        type: u2
        if: section == 5 and version > 0x1FE
      - id: screen_h
        type: u2
        if: section == 5
      # S7 coords: pixel_x, pixel_y, pixel_w, pixel_h
      - id: pixel_x
        type: u2
        if: section == 6
      - id: pixel_y
        type: u2
        if: section == 6
      - id: pixel_w
        type: u2
        if: section == 6
      - id: pixel_h
        type: u2
        if: section == 6
      # S8 bounds: bound_x, bound_y, bound_size(u4 >0x1FE)
      - id: bound_x
        type: u2
        if: section == 7
      - id: bound_y
        type: u2
        if: section == 7
      - id: bound_size
        type: u4
        if: section == 7 and version > 0x1FE
      # S9 overlays: overlay-id list
      - id: overlay_list
        type: overlay_list
        if: section == 8
      # S10 filters: filter_id (u4 head)
      - id: filter_id
        type: u4
        if: section == 9
  sublist:
    params:
      - id: section
        type: u1
      - id: version
        type: u2
      - id: fourbyte
        type: bool
    seq:
      - id: count
        type: u1
      - id: elements
        type: element(section, version, fourbyte)
        repeat: expr
        repeat-expr: count
  tail:
    doc: |
      The shared S1..S10 tail + trailer. S1..S5 mandatory; S6..S10 length-gated
      (S9 needs version > 0x1FF, S10 needs version > 0x201); trailer is the terminal
      gated byte. Same progressive-prefix mechanism as server_config.
    params:
      - id: version
        type: u2
      - id: fourbyte
        type: bool
    seq:
      - id: s1
        type: sublist(0, version, fourbyte)
      - id: s2
        type: sublist(1, version, fourbyte)
      - id: s3
        type: sublist(2, version, fourbyte)
      - id: s4
        type: sublist(3, version, fourbyte)
      - id: s5
        type: sublist(4, version, fourbyte)
      - id: s6
        type: sublist(5, version, fourbyte)
        if: _io.pos < _io.size
      - id: s7
        type: sublist(6, version, fourbyte)
        if: _io.pos < _io.size
      - id: s8
        type: sublist(7, version, fourbyte)
        if: _io.pos < _io.size
      - id: s9
        type: sublist(8, version, fourbyte)
        if: version > 0x1FF and _io.pos < _io.size
      - id: s10
        type: sublist(9, version, fourbyte)
        if: version > 0x201 and _io.pos < _io.size
      - id: trailer
        type: u1
        if: _io.pos < _io.size
