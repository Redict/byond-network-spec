meta:
  id: byond_common
  title: BYOND NetMsg shared body idioms
  endian: le
  ks-version: 0.11
doc: |
  Field idioms shared by every BYOND message-body spec:
    * u2or4      - a 2- or 4-byte little-endian integer whose width follows the
                   connection-global `fourbyte` flag.
    * net_string - a NUL-terminated byte string.

  All body fields are little-endian; only the frame header (not covered here) is
  big-endian. Import this and reference the types by qualified name, e.g.
  `type: 'byond_common::u2or4(fourbyte)'`.
types:
  u2or4:
    doc: |
      A 2- or 4-byte little-endian integer: 4 bytes when `fourbyte` is set, else 2.
      Reads a low word and, only when fourbyte, a high word; `value` recombines
      them so callers see a single integer.

      A truncated body is treated as EOF here; callers that need the lenient
      zero-fill-on-underflow behaviour handle it themselves.
    params:
      - id: fourbyte
        type: bool
    seq:
      - id: lo
        type: u2
      - id: hi
        type: u2
        if: fourbyte
    instances:
      value:
        value: 'fourbyte ? (lo | (hi << 16)) : lo'
        doc: The recombined 2-or-4-byte little-endian integer.
  net_string:
    doc: |
      A NUL-terminated byte string. Kept as raw bytes (not decoded text) so every
      byte 0..255 round-trips losslessly; the terminator is consumed but not stored.
    seq:
      - id: value
        terminator: 0
        doc: The string bytes, excluding the NUL terminator.
