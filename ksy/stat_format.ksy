meta:
  id: stat_format
  title: BYOND stat-format header (NetMsg type 33)
  endian: le
  ks-version: 0.11
doc: |
  Stat-panel format header (NetMsg type 33): a run of little-endian words followed
  by a single trailing pad byte.

  The word count is NOT fixed. It was originally modelled as exactly ten because the
  reference captures happened to contain a single 21-byte sample; a DM conformance
  world (`conformance/conformance.dme`, driving a real 516 server) emits a 19-byte
  body - nine words + pad - which the fixed layout could not parse
  ("requested 2 bytes, but only 1 bytes available"). Both observed lengths are odd,
  i.e. `2*n + 1`, so the body is read as words until a single byte remains.
seq:
  - id: words
    type: u2
    repeat: until
    repeat-until: _io.size - _io.pos <= 1
    doc: Format words; count varies with the panel layout the server sends.
  - id: pad
    type: u1
    doc: Single trailing byte after the word run.
