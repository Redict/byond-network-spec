meta:
  id: frame_header
  title: BYOND NetMsg wire frame (transport header + payload)
  endian: be
  ks-version: 0.11
doc: |
  BYOND wire frame: transport header + payload.

  The header is BIG-ENDIAN (the only big-endian part of the protocol; message bodies
  are little-endian). Two forms:

    * short  (payload <= 0xFFFF):  [type:2 BE][len:2 BE][payload:len]
    * extended (payload > 0xFFFF): [0x00A0:2 BE][0x0006:2 BE][type:2 BE][len:4 BE][payload:len]

  The `0x00A0 / 0x0006` sentinel signals the extended 4-byte length field; a naive
  4-byte splitter otherwise reads it as a bogus "type=160 len=6" frame and desyncs on
  516 sessions that stream ~1 MB browser/resource payloads.

  Once sequence tracking is negotiated a 2-byte big-endian sequence prefix is added
  in BOTH directions, in front of either form; during the version handshake there is
  no sequence prefix. Presence of that prefix is the caller-supplied `has_sequence`
  param, never inferred from the bytes.

  This is the whole-buffer frame layout. A live streaming reader keeps an inline
  mirror of this header for incremental partial reads (a whole-buffer parser cannot
  express "insufficient bytes, resume later").
params:
  - id: has_sequence
    type: bool
    doc: True once sequence tracking is negotiated (adds the 2-byte BE seq prefix).
seq:
  - id: sequence
    type: u2
    if: has_sequence
    doc: Optional 2-byte big-endian sequence number (present iff has_sequence).
  - id: word0
    type: u2
    doc: Short-form message type, or 0x00A0 when the extended sentinel is present.
  - id: word1
    type: u2
    doc: Short-form payload length, or 0x0006 when the extended sentinel is present.
  - id: ext
    type: ext_header
    if: is_extended
    doc: The real [type:2][len:4] header, present only in the extended form.
  - id: payload
    size: 'is_extended ? ext.len : word1'
    doc: The payload bytes exactly as framed (still crypt-encoded if a key is set).
instances:
  is_extended:
    value: 'word0 == 0xa0 and word1 == 0x0006'
    doc: True when the 0x00A0/0x0006 extended-length sentinel leads the header.
  msg_type:
    value: 'is_extended ? ext.msg_type : word0'
    doc: The 16-bit message type, from either header form.
  length:
    value: 'is_extended ? ext.len : word1'
    doc: The payload length in bytes, from either header form.
types:
  ext_header:
    doc: Extended header body following the 0x00A0/0x0006 sentinel.
    seq:
      - id: msg_type
        type: u2
      - id: len
        type: u4
