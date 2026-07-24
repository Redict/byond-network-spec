meta:
  id: rsc_response
  title: BYOND RSC download flow-control (c2s NetMsg types 158, 159)
  endian: le
  ks-version: 0.11
doc: |
  Client->server resource-download flow-control message (c2s NetMsg types 158 / 159).
  Layout:

    [rsc_id:u4][xlate:u4][op:u1]  then, only when op == 0:  [ack:u4]

  `op` is a flow-control selector on the transfer entry keyed by (msg_type, rsc_id,
  xlate):
    op 0  ACK      set the ack offset; if ack >= current packet -> send next chunk
    op 1  ACCEPT   mark the transfer received (begin/confirm)
    op 2  CANCEL   tear down the transfer entry

  Types 158 and 159 share this identical wire layout; the number only selects the
  completion semantics (158 = persistent resource-cache install; 159 = transient
  on-demand fetch).

  Captured type-159 frames are all the op==0 branch (13 bytes). The op==1/op==2
  branches (9 bytes) and any type-158 frame are exercised by synthetic round-trip
  vectors.
seq:
  - id: rsc_id
    type: u4
  - id: xlate
    type: u4
    doc: Translation / cache id; 0xFFFFFFFF = "not cached / no translation".
  - id: op
    type: u1
    doc: Flow-control selector; 0 = ack (send more), 1 = accept, 2 = cancel.
  - id: ack
    type: u4
    if: op == 0
    doc: Received-up-to offset; present only for op == 0.
