meta:
  id: rsc_index
  title: BYOND RSC file-index announcement (NetMsg type 159)
  endian: le
  ks-version: 0.11
doc: |
  RSC file-index announcement (NetMsg type 159).

  A fixed 16-byte head (content hash, all-ones marker, mode word, a constant) followed
  by the packed resource records - NUL-terminated names and gzip-compressed file
  blobs. Those records are opaque file data, not protocol fields, so the tail after
  the head is preserved verbatim (`size-eos`): the head is decoded, the file records
  are not.
seq:
  - id: hash
    type: u4
  - id: marker
    type: u4
  - id: mode
    type: u4
  - id: const
    type: u4
  - id: records
    size-eos: true
    doc: Opaque packed resource records (cstring names + gzip blobs); preserved raw.
