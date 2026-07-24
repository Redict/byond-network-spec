meta:
  id: view_resize
  title: BYOND map/viewport resize (NetMsg type 62)
  endian: le
  ks-version: 0.11
doc: |
  Map/viewport resize (NetMsg type 62): the map extent (`max_x`/`max_y`), four
  screen-block view words, then any trailing viewport words (a second outer/inner
  block) to end-of-body.
seq:
  - id: max_x
    type: u2
  - id: max_y
    type: u2
  - id: view
    type: u2
    repeat: expr
    repeat-expr: 4
  - id: rest
    type: u2
    repeat: eos
