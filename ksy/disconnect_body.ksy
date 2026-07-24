meta:
  id: disconnect_body
  title: BYOND server disconnect body (NetMsg type 0)
  endian: le
  ks-version: 0.11
doc: |
  Server->client disconnect (NetMsg type 0). The body is a short opaque status payload
  (the captured vector is 2 bytes, `00 00`). Its internal field semantics beyond "a
  status word" are unresolved, so the whole payload is carried as opaque bytes for a
  byte-exact round-trip.
seq:
  - id: status
    size-eos: true
    doc: Opaque disconnect status payload (2 bytes on the reference vector).
