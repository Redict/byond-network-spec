meta:
  id: rsc_upload
  title: BYOND client RSC file upload (c2s NetMsg type 257)
  endian: le
  ks-version: 0.11
doc: |
  Client->server resource file upload (c2s NetMsg type 257). Layout:

    [rsc_id:u4][cache_idx:u4]  then, only when cache_idx == 0x0000FFFF:
      [handle:u4][size:u4][payload: size bytes]

  `cache_idx` is the server's cache slot for the resource: a real index means the
  server already has it (short 8-byte form, no payload); 0xFFFF means "new, full upload
  follows". The `payload` is the raw resource file bytes (e.g. a PNG icon) - opaque by
  nature (a file, not a struct), modeled as a `size`-bounded byte blob.

  Note the `ff ff 00 00` bytes are the u4 `cache_idx` (0xFFFF), not a u2 discriminator
  plus pad.
seq:
  - id: rsc_id
    type: u4
  - id: cache_idx
    type: u4
    doc: Server cache slot; 0xFFFF = new resource, full upload follows.
  - id: handle
    type: u4
    if: cache_idx == 0xFFFF
  - id: len_payload
    type: u4
    if: cache_idx == 0xFFFF
    doc: Byte length of the upload payload (the resource file size).
  - id: payload
    size: len_payload
    if: cache_idx == 0xFFFF
    doc: Raw resource file bytes (opaque blob, e.g. a PNG icon).
