meta:
  id: view_size
  title: BYOND view-size (NetMsg type 200)
  endian: le
  ks-version: 0.11
doc: |
  View size (NetMsg type 200): a bare list of little-endian words to end-of-body
  (three on the captured vector).
seq:
  - id: words
    type: u2
    repeat: eos
