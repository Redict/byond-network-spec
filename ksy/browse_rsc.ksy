meta:
  id: browse_rsc
  title: BYOND browse-rsc / server-pill window (NetMsg type 114)
  endian: le
  ks-version: 0.11
doc: |
  Browse-rsc / server-pill window (NetMsg type 114).

  Like server_config (type 59), a progressive length-terminated schedule: a mandatory
  prefix (world_name + host) then fields emitted only while the server has data, each
  read only while `cursor < msg_len`. The body is a byte-exact PREFIX of the full
  schedule. Atomic partners are grouped into sub-types so a gated group is present or
  absent as a unit (`if _io.pos < _io.size`).

  No `fourbyte` param: every field here is a fixed-width int or a cstring.
seq:
  # --- mandatory prefix ---
  - id: world_name
    type: net_string
  - id: host
    type: net_string
  # --- length-gated schedule ---
  - id: desc
    type: desc_block
    if: _io.pos < _io.size
  - id: token
    type: u4
    if: _io.pos < _io.size
  - id: is_default
    type: u1
    if: _io.pos < _io.size
  - id: package
    type: net_string
    if: _io.pos < _io.size
  - id: flag_byte
    type: u1
    if: _io.pos < _io.size
  - id: category
    type: net_string
    if: _io.pos < _io.size
  - id: build_block
    type: build_block
    if: _io.pos < _io.size
  - id: hash
    type: net_string
    if: _io.pos < _io.size
  - id: build2
    type: u4
    if: _io.pos < _io.size
types:
  net_string:
    doc: NUL-terminated BYOND byte string (local copy; browse_rsc imports nothing).
    seq:
      - id: value
        terminator: 0
  desc_block:
    doc: Atomic group - desc_html cstring + two u32 params.
    seq:
      - id: desc_html
        type: net_string
      - id: param_a
        type: u4
      - id: param_b
        type: u4
  build_block:
    doc: Atomic group - build u32 + kind u32 + subkind u32 (raw, unclamped).
    seq:
      - id: build
        type: u4
      - id: kind
        type: u4
      - id: subkind
        type: u4
