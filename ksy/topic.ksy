meta:
  id: topic
  title: BYOND client topic send (c2s NetMsg type 129)
  endian: le
  ks-version: 0.11
  imports:
    - common/byond_common
doc: |
  Client->server topic string send (c2s NetMsg type 129): a single NUL-terminated byte
  string (`?src=[0x..];key=value`).
seq:
  - id: topic
    type: 'byond_common::net_string'
