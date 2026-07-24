meta:
  id: cmob
  title: BYOND cmob update body (NetMsg type 8)
  endian: le
  ks-version: 0.11
  imports:
    - common/byond_common
    - common/object_update
doc: |
  Cmob update (NetMsg type 8). A small header - a flag byte plus up to two gated `u2`
  skip words - followed by the shared object-update ten-sublist tail
  (`object_update::tail`).

  The skip words (flag bits 1/2) carry no meaning but are on the wire, so they are
  preserved verbatim for a byte-exact round-trip. version/fourbyte are caller-supplied
  params.
params:
  - id: version
    type: u2
  - id: fourbyte
    type: bool
seq:
  - id: flag
    type: u1
  - id: skip_bit1
    type: u2
    if: (flag & 2) != 0
  - id: skip_bit2
    type: u2
    if: (flag & 4) != 0
  - id: tail
    type: 'object_update::tail(version, fourbyte)'
