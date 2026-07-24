meta:
  id: turf_grid
  title: BYOND turf-grid RLE fill (NetMsg types 20 / 32 / 97)
  endian: le
  ks-version: 0.11
  imports:
    - common/byond_common
doc: |
  Turf-grid fill (NetMsg types 20 / 32 / 97).

  Each paints a rectangle of the client map with turf/object references as a
  run-length-encoded `u2or4` token stream: a short fixed header, then reference tokens
  read UNTIL the trailer boundary. A token equal to the width sentinel (0xFFFFFFFF /
  0xFFFF) is a run marker followed by a 1-byte repeat count. The grid shape comes from
  the type-62 geometry (not this body), so this only replays the self-delimiting token
  stream.

  The three variants differ only in header/trailer byte counts, passed as params:
    * type 20: header 2 bytes, trailer 0    (offset variant)
    * type 32: header 0 bytes, trailer 2    (a [count:2]=0 block)
    * type 97: header 0 bytes, trailer 0    (clear variant)

  Unlike the length-terminated schedules, the token stream reads to a computed limit
  (`size - trailer_len`). The tokens are a substream of exactly that many bytes, so
  both parse and the exact-size serializer stop at the identical boundary.
params:
  - id: fourbyte
    type: bool
  - id: header_len
    type: u1
  - id: trailer_len
    type: u1
seq:
  - id: header
    size: header_len
    doc: Fixed header bytes (type 20 = 2 bytes; types 32/97 = 0).
  - id: tokens_raw
    size: (_io.size - header_len) - trailer_len
    type: token_stream(fourbyte)
    doc: The RLE token stream, bounded to exactly the bytes before the trailer.
  - id: trailer
    size: trailer_len
    doc: Trailing bytes captured raw (type 32 = a 2-byte count=0 block).
types:
  token_stream:
    doc: A substream of RLE tokens read until its own EOF (the trailer boundary).
    params:
      - id: fourbyte
        type: bool
    seq:
      - id: tokens
        type: token(fourbyte)
        repeat: until
        repeat-until: _io.eof
  token:
    doc: |
      One RLE token: a `u2or4` ref, and - only when it is the width sentinel - a
      1-byte run count repeating the previous ref. `is_run` drives the tail.
    params:
      - id: fourbyte
        type: bool
    seq:
      - id: ref
        type: 'byond_common::u2or4(fourbyte)'
      - id: run
        type: u1
        if: is_run
    instances:
      is_run:
        value: 'fourbyte ? (ref.value == 0xffffffff) : (ref.value == 0xffff)'
