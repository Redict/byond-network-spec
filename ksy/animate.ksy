meta:
  id: animate
  title: BYOND CAnimation flick-chain body (NetMsg type 240)
  endian: le
  ks-version: 0.11
doc: |
  Animate / CAnimation flick-chain body (NetMsg type 240).

  A stateful, expression-heavy layout: the per-frame records form a state machine
  where frame N's layout depends on a matrix-carry bit (0x8) of frame N-1's flag
  word. The carry is passed into the next frame as a param, computed in the repeat
  type-args from `_index` and the in-progress `frames` list.

  `version` and `minor` are caller-supplied params (a 516 session uses version 0x204,
  minor 0x694). `base_time`/`time` are float32 on the wire but read as raw u4 for a
  byte-exact round-trip (values not interpreted).
params:
  - id: version
    type: u2
    doc: Negotiated protocol version (516 == 0x204).
  - id: minor
    type: u2
    doc: Negotiated minor build (516 session == 0x694); gates per-frame easing.
seq:
  - id: kind
    type: u1
    doc: Animate target kind (1 atom, 2 turf, 3 area, 4 client, 5 global, 13 image).
  - id: target
    type: u4
  - id: aux
    type: u2
  - id: base_time
    type: u4
    doc: float32 base time, read raw for byte-exactness.
  - id: header_easing
    type: u2
    if: version > 0x201 and minor <= 0x619
    doc: Absent on the 516 session (minor 0x694 > 0x619).
  - id: flags
    type: u1
    doc: bit0 = loop/append.
  - id: frame_count
    type: u2
  - id: end_id
    type: u4
    if: target != 0 and frame_count != 0
  - id: frames
    type: 'frame(_index == 0 ? false : frames[_index - 1].carry_out, flags, version, minor)'
    repeat: expr
    repeat-expr: frame_count
types:
  frame:
    doc: |
      One CAnimation frame. `prev_carry` is the matrix-carry bit of the previous
      frame (false for the first), supplied by the parent so this frame's optional
      transform/easing fields decode correctly.
    params:
      - id: prev_carry
        type: bool
      - id: hdr_flags
        type: u1
      - id: version
        type: u2
      - id: minor
        type: u2
    seq:
      - id: icon
        type: u4
      - id: icon_state
        type: u4
      - id: time
        type: u4
        doc: float32 frame time, read raw for byte-exactness.
      - id: loop_count
        type: u4
      - id: easing
        type: u1
      - id: flags_low
        type: u1
        if: version > 0x1FC
      - id: flags_high
        type: u2
        if: version > 0x1FC and (flags_low & 0x80) != 0 and version > 0x201
      # branch A (frame_flags & 0x40000004) or branch B (carry): transform_time
      - id: transform_time
        type: u4
        if: (frame_flags & 0x40000004) != 0 or prev_carry
      # branch A only: transform_time_end
      - id: transform_time_end
        type: u4
        if: (frame_flags & 0x40000004) != 0
      # branch A (ver>0x201), branch B (ver>0x201), or branch C (minor gate)
      - id: frame_easing
        type: u2
        if: >-
          ((frame_flags & 0x40000004) != 0 and version > 0x201)
          or (prev_carry and (frame_flags & 0x40000004) == 0 and version > 0x201)
          or ((frame_flags & 0x40000004) == 0 and not prev_carry
              and (minor > 0x619 or (hdr_flags != 0 and minor > 0x609)))
      - id: matrix_element
        type: u4
        if: (frame_flags & 8) != 0
    instances:
      frame_flags:
        doc: |
          Resolved frame flag word: low byte, extended to 3 bytes (low | high<<16)
          when the high bit is set on a version > 0x201 stream; 0 when the flag
          byte itself is absent (version <= 0x1FC).
        value: >-
          version > 0x1FC
            ? ((flags_low & 0x80) != 0 and version > 0x201
                ? (flags_low | (flags_high << 16))
                : flags_low)
            : 0
      carry_out:
        doc: Matrix-carry bit (0x8) propagated to the next frame.
        value: '(frame_flags & 8) != 0'
