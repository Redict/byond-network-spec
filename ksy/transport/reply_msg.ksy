meta:
  id: reply_msg
  title: BYOND server version reply payload (NetMsg type 1, s2c)
  endian: le
  ks-version: 0.11
doc: |
  Server -> client version reply, decoded plaintext payload (the type-1 reply body
  without the transport frame header or the trailing checksum byte).

  Little-endian. An 11-byte stable prefix, then random padding emitted in two groups
  around a single fold word:

    [version:4][build:4][port:1][cert:1][dmb:1]     <- 11-byte stable prefix
    pad1: emit words until (w + 1908237103) & 0x4008000 == 0
    fold_word: u4                                   <- folded into the session key
    pad2: emit words until (s + 400242403)  & 0x402000  == 0

  Each group emits words and stops on (and includes) the first word satisfying its
  `& == 0` condition. Kaitai `repeat-until` stops when its expression is true and
  includes the breaking element, which matches the wire.

  The fold word is a named structural field, not a hunted offset. pad2 words are the
  cumulative running sum on the wire, so each word's break condition tests that word
  directly; pad2 is modeled as a parametric sub-type carrying the prior sum via
  `_index-1` so `running` is an explicit named field.

  The post-handshake session key is `(base_key + fold_word) & 0xFFFFFFFF`; that
  addition lives in the algorithm layer, not this layout.
seq:
  - id: version
    type: u4
    doc: Server version (e.g. 0x1F7 503, 0x204 516).
  - id: build
    type: u4
    doc: Server build (e.g. 490).
  - id: port
    type: u1
  - id: cert
    type: u1
  - id: dmb
    type: u1
    doc: 1, or 3 when the message uses 4-byte dmb refs.
  - id: pad1
    type: u4
    repeat: until
    repeat-until: '((_ + 1908237103) & 0x4008000) == 0'
    doc: |
      Stateless random padding group 1. Each word is emitted; the group ends on (and
      includes) the first word for which `(w + 1908237103) & 0x4008000` is zero.
  - id: fold_word
    type: u4
    doc: The fold word, added into the session key by both sides.
  - id: pad2
    type: 'sum_word((_index == 0 ? 0 : pad2[_index - 1].running))'
    repeat: until
    repeat-until: '((_.running + 400242403) & 0x402000) == 0'
    doc: |
      Running-sum random padding group 2. Each wire word is the cumulative sum; the
      group ends on (and includes) the first element whose running sum satisfies
      `(s + 400242403) & 0x402000 == 0`.
types:
  sum_word:
    doc: One pad2 element - a random word plus the running sum carried from _index-1.
    params:
      - id: prev
        type: u4
        doc: The running sum of all prior pad2 elements (0 for the first).
    seq:
      - id: word
        type: u4
        doc: The wire word, which is itself the running sum (see below).
    instances:
      running:
        value: 'word'
        doc: |
          The running sum after this element. The accumulated sum is emitted directly
          on the wire, so the wire word IS the running sum; `prev` is threaded only to
          document the carried state.
