from pathlib import Path
import re
s = Path("ggml/src/ggml-common.h").read_text()
count = 0
for name in ["iq3xxs_grid", "iq3s_grid"]:
    text = s.split(", " + name + ",", 1)[1].split("GGML_TABLE_END()", 1)[0]
    words = [int(x, 16) for x in re.findall(r"0x([0-9a-fA-F]+)", text)]
    values = {(word >> shift) & 255 for word in words for shift in [0, 8, 16, 24]}
    assert all(0 < value < 128 for value in values)
    print(name, "entries", len(words), "byte values", sorted(values))
    for word in words:
        for signs in range(16):
            mask = sum((255 if signs & (1 << i) else 0) << (8*i) for i in range(4))
            expected = sum((((-((word >> (8*i)) & 255)) if signs & (1 << i) else ((word >> (8*i)) & 255)) & 255) << (8*i) for i in range(4))
            actual = ((word ^ mask) + (mask & 0x01010101)) & 0xffffffff
            generic_a = word ^ mask
            generic = (((generic_a | 0x80808080) - (mask & 0x7f7f7f7f)) ^ ((generic_a ^ (~mask & 0xffffffff)) & 0x80808080)) & 0xffffffff
            assert actual == expected == generic
            count += 1
print("PASS:", count, "codebook/sign combinations; host arithmetic only, no GPU execution")
