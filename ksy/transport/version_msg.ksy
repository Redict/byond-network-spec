meta:
  id: version_msg
  title: BYOND client version message payload (NetMsg type 1, c2s)
  endian: le
  ks-version: 0.11
doc: |
  Client -> server version message payload (the type-1 body, without the transport
  frame header).

  Little-endian, like every message body (only the frame header is big-endian). Base
  layout:

    [version:4][build:4][seed:4][cert:2]

  `seed` is chosen so `seed = key - ((build << 16) + version)`; seed selection and key
  math live in the algorithm layer, not this layout.

  For `version >= 512` two more 4-byte fields are always appended: a minor build
  number and the client's timezone offset in hours as a float32. A 516 server requires
  their presence (it gates on message length) but does not validate their values; a
  503 server accepts the 14-byte form without them. The gate is the caller-supplied
  `version` param, never read from the body to decide layout.
params:
  - id: version
    type: u4
    doc: Negotiated client version; the >= 512 gate for the beta fields.
seq:
  - id: version_field
    type: u4
    doc: BYOND version number (e.g. 0x1F7 503, 0x204 516). Echoes the `version` param.
  - id: build
    type: u4
    doc: Build number (e.g. 276).
  - id: seed
    type: u4
    doc: Random seed = key - ((build << 16) + version); chosen by the algorithm layer.
  - id: cert
    size: 2
    doc: 2-byte certificate flag (raw; also seeds the c2s sequence counter, LE).
  - id: beta
    type: beta_fields
    if: version >= 512
    doc: The 515+ minor-build + timezone fields; present iff version >= 512.
types:
  beta_fields:
    doc: Fields appended for version >= 512; REQUIRED by 516 but values unvalidated.
    seq:
      - id: minor_build
        type: u4
        doc: Minor/beta build number (e.g. 1647/1684). Presence matters, not value.
      - id: tz_hours
        type: f4
        doc: (localtime - gmtime) / 3600 as float32. 0.0 is accepted.
