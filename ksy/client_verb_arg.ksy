meta:
  id: client_verb_arg
  title: BYOND client verb/topic arg (c2s NetMsg type 98)
  endian: le
  ks-version: 0.11
  imports:
    - common/byond_common
doc: |
  Client->server verb/topic argument send (c2s NetMsg type 98): a single tagged arg
  value followed by a trailing `[ctx:u4]` context reference. The arg union is the same
  encoding the type-2 input envelope emits; a leading `arg_type` byte selects the arm:

    arg_type 0  cid/null   [cid_type:u1][cid_ref:u4]
    arg_type 1  number     [value:u4]
    arg_type 2  string     [name:cstr]
    arg_type 3  resource   [w0:u2][w1:u2][name:cstr]
    arg_type 4  string     [name:cstr]   (expr arm)

  Captured frames all use the cid arm (arg_type 0); the other arms are exercised by
  synthetic round-trip vectors.
seq:
  - id: arg
    type: msg_arg
  - id: ctx
    type: u4
    doc: Trailing 4-byte context reference after the arg.
types:
  msg_arg:
    doc: |
      One tagged arg value: a leading `arg_type` byte selecting the arm, then the
      arm-specific body. Flat `if`-gated fields (only one arm's fields are present per
      value).
    seq:
      - id: arg_type
        type: u1
      # arm 0: cid / null reference
      - id: cid_type
        type: u1
        if: arg_type == 0
      - id: cid_ref
        type: u4
        if: arg_type == 0
      # arm 1: number
      - id: num_value
        type: u4
        if: arg_type == 1
      # arm 3: resource header (two words) preceding the string
      - id: res_w0
        type: u2
        if: arg_type == 3
      - id: res_w1
        type: u2
        if: arg_type == 3
      # arms 2 / 3 / 4: NUL-terminated name string
      - id: str_value
        type: 'byond_common::net_string'
        if: arg_type == 2 or arg_type == 3 or arg_type == 4
