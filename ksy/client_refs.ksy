meta:
  id: client_refs
  title: BYOND client reference-list update (NetMsg type 118)
  endian: le
  ks-version: 0.11
  imports:
    - common/byond_common
    - common/object_update
doc: |
  Client reference-list update (NetMsg type 118).

  The body is a sequence of GROUPS read until the body is consumed. Each group is
  `[kind:1][end_offset:2 LE]` then elements until the read cursor reaches `end_offset`
  (an absolute byte position within the body, not an element count). The element run
  is modeled as a substream sized `end_offset - pos`, with elements repeated to
  end-of-substream. Elements decode by `kind`: kind 1 = `[id:4][value:2]`, kinds 2/3 =
  a shared `object_update::net_ref`.
params:
  - id: version
    type: u2
  - id: fourbyte
    type: bool
seq:
  - id: groups
    type: group(version, fourbyte)
    repeat: eos
types:
  group:
    params:
      - id: version
        type: u2
      - id: fourbyte
        type: bool
    seq:
      - id: kind
        type: u1
      - id: end_offset
        type: u2
      - id: body
        type: element_run(kind, version, fourbyte)
        size: end_offset - _io.pos
  element_run:
    doc: The elements of a group, filling a substream sized to the group's end_offset.
    params:
      - id: kind
        type: u1
      - id: version
        type: u2
      - id: fourbyte
        type: bool
    seq:
      - id: elements
        type: element(kind, version, fourbyte)
        repeat: eos
  element:
    params:
      - id: kind
        type: u1
      - id: version
        type: u2
      - id: fourbyte
        type: bool
    seq:
      # kind 1: [id:4][value:2]
      - id: id
        type: u4
        if: kind == 1
      - id: value
        type: u2
        if: kind == 1
      # kinds 2/3: a shared reference
      - id: ref
        type: 'object_update::net_ref(version, fourbyte)'
        if: kind == 2 or kind == 3
