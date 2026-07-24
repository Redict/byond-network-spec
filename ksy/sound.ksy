meta:
  id: sound
  title: BYOND Sound (NetMsg type 109)
  endian: le
  ks-version: 0.11
  imports:
    - common/byond_common
doc: |
  Sound (NetMsg type 109): `[sound_id:u2or4][status:u1]` then, while bytes remain, a
  mixer header `[repeat:u1][channel:u1][wait:u2]` and a `flags:u1` word selecting the
  optional blocks. The eax reverb arrays (flags 0x04/0x08) are read to end-of-body
  clamped at 18/23 floats.

  The presence of the mixer header + flags region depends on remaining body length,
  which the read-write serializer cannot express via `_io.eof`. The whole post-status
  region is therefore carried as a size-eos `tail` blob and decoded by the caller,
  which owns the flag-gated structure; this spec fixes the header and frames the tail.
params:
  - id: fourbyte
    type: bool
seq:
  - id: sound_id
    type: 'byond_common::u2or4(fourbyte)'
  - id: status
    type: u1
  - id: tail
    size-eos: true
    doc: |
      The optional mixer header + flags + flag-gated blocks, present iff bytes remain.
      Decoded by the caller (flag-gated, eos-clamped eax arrays), kept opaque here so
      the layout stays byte-exact through the serializer.
