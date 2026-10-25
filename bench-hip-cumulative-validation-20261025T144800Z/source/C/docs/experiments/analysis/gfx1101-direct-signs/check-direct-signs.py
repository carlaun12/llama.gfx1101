from pathlib import Path
import re
source = Path("ggml/src/ggml-common.h").read_text()
checks = 0
for name in ["iq3xxs_grid", "iq3s_grid"]:
    table = source.split(", " + name + ",", 1)[1].split("GGML_TABLE_END()", 1)[0]
    words = [int(x, 16) for x in re.findall(r"0x([0-9a-fA-F]+)", table)]
    for packed in range(256):
        if name == "iq3xxs_grid":
            old_signs = packed ^ ((packed.bit_count() & 1) << 7)
            raw = packed & 127
            new_signs = raw | ((raw.bit_count() & 1) << 7)
            assert old_signs == new_signs
        else:
            old_signs = new_signs = packed
        for shift in [0, 4]:
            nibble = (new_signs >> shift) & 15
            bits = (nibble * 0x00204081) & 0x01010101
            mask = bits * 255
            if name == "iq3xxs_grid":
                broadcast = old_signs * 0x01010101
                selector = 0x08040201 if shift == 0 else 0x80402010
                packed_test = broadcast & selector
            else:
                packed_test = (((packed & 3) << 7) | ((packed & 12) << 21)) if shift == 0 else (((packed & 48) << 3) | ((packed & 192) << 17))
            old_mask = sum((255 if ((packed_test >> (8*i)) & 255) != 0 else 0) << (8*i) for i in range(4))
            assert mask == old_mask
            for word in words:
                actual = ((word ^ mask) + bits) & 0xffffffff
                expected = sum((((-((word >> (8*i)) & 255)) if (old_signs >> (shift+i)) & 1 else ((word >> (8*i)) & 255)) & 255) << (8*i) for i in range(4))
                assert actual == expected
                checks += 1
print("PASS:", checks, "codebook/packed-sign/half combinations; host arithmetic only")
