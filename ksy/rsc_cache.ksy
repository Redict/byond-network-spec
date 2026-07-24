meta:
  id: rsc_cache
  title: BYOND RSC cache preload list (NetMsg type 14)
  endian: le
  ks-version: 0.11
doc: |
  RSC cache preload list (NetMsg type 14): a packed array of `[id:4][flags:1]` records
  with no count prefix (runs to end-of-message). `filetype = flags & 0x7F`.
seq:
  - id: records
    type: ccache_record
    repeat: eos
types:
  ccache_record:
    doc: One RSC cache entry - a 4-byte id and a 1-byte flags word (filetype in low 7 bits).
    seq:
      - id: id
        type: u4
      - id: flags
        type: u1
    instances:
      filetype:
        value: 'flags & 0x7f'
