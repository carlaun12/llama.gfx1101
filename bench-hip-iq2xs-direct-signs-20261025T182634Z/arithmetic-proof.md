# IQ2_XS direct sign arithmetic

The IQ2_XS index has 9 bits, so it selects one of 512 `iq2xs_grid` entries. The packed sign field has 7 bits; `unpack_ksigns` adds the parity-derived eighth sign. That E helper is unchanged. The two selectors select one sign bit in each byte of the low or high four-lane grid half.

The table contains 4,096 magnitude bytes. Direct enumeration gives only `0x08`, `0x19`, and `0x2b`, all positive and below 128.

For each selected byte, `signs & selector` is either zero or a one-hot value in `[1, 128]`. Adding `0x7f` gives 127 for zero and a value in `[128, 255]` for a selected sign. No byte carries into the next byte. Shifting by 7 then masking with `0x01010101` yields one bit per byte exactly when its selected sign is nonzero.

Let each byte of `m` be `m_i` in `{0,1}`. The byte borrow recurrence for `(m << 8) - m` starts with borrow `m_0`; for each lane `i`, the result byte is `m_(i-1) - m_i - m_(i-1)`, or `-m_i mod 256`, and the outgoing borrow is `m_i`. Thus it makes `0xff` in each selected lane and zero elsewhere.

For a selected negative magnitude `g`, `(g ^ 0xff) + 1 = 256 - g`. Since `g` is one of 8, 25, or 43, the result is 248, 231, or 213 and cannot carry out of its byte. Unselected bytes have `m_i=0` and remain unchanged. This proof applies only to the IQ2_XS table domain above, not arbitrary packed words.

The exhaustive GPU check covers all 512 table indices, all 128 valid stored sign patterns (including their parity-reconstructed eighth sign), and both four-byte halves: 131,072 cases. It compares the E byte-SIMD operation, candidate uint32 arithmetic, and a lane-by-lane reference.
