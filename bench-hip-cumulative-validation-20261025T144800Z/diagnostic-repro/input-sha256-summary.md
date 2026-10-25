# SHA-256 of matched IQ3_XXS diagnostic inputs

Each A/B/C input buffer was fetched from its backend and saved before graph execution. Plain MUL_MAT reproductions have no bias tensors; their IQ3_XXS weight and activation hashes match the corresponding fused case.

## fused, seed 17, K=256

| Tensor | A SHA-256 | B SHA-256 | C SHA-256 |
| --- | --- | --- | --- |
| leaf_0 | `ca3a25e1f1d2c658761ca674015b1624b101c711ae9ccf4376ec4c9df000a24d` | `ca3a25e1f1d2c658761ca674015b1624b101c711ae9ccf4376ec4c9df000a24d` | `ca3a25e1f1d2c658761ca674015b1624b101c711ae9ccf4376ec4c9df000a24d` |
| leaf_1 | `c38b328a337f15d5076b620b2ff8dd1af28bab19254f8ea62e6918cda6f52434` | `c38b328a337f15d5076b620b2ff8dd1af28bab19254f8ea62e6918cda6f52434` | `c38b328a337f15d5076b620b2ff8dd1af28bab19254f8ea62e6918cda6f52434` |
| leaf_2 | `ed2336940e568775d0c84c0f3952483b59321f0bc4e5b7777bddc997d9647cc8` | `ed2336940e568775d0c84c0f3952483b59321f0bc4e5b7777bddc997d9647cc8` | `ed2336940e568775d0c84c0f3952483b59321f0bc4e5b7777bddc997d9647cc8` |
| leaf_3 | `1999e8a884829f47147637f7a03769ea114c4eb171e6eebdcd44d5265460db59` | `1999e8a884829f47147637f7a03769ea114c4eb171e6eebdcd44d5265460db59` | `1999e8a884829f47147637f7a03769ea114c4eb171e6eebdcd44d5265460db59` |

## plain-k256, seed 17, K=256

| Tensor | A SHA-256 | B SHA-256 | C SHA-256 |
| --- | --- | --- | --- |
| leaf_0 | `ca3a25e1f1d2c658761ca674015b1624b101c711ae9ccf4376ec4c9df000a24d` | `ca3a25e1f1d2c658761ca674015b1624b101c711ae9ccf4376ec4c9df000a24d` | `ca3a25e1f1d2c658761ca674015b1624b101c711ae9ccf4376ec4c9df000a24d` |
| leaf_1 | `c38b328a337f15d5076b620b2ff8dd1af28bab19254f8ea62e6918cda6f52434` | `c38b328a337f15d5076b620b2ff8dd1af28bab19254f8ea62e6918cda6f52434` | `c38b328a337f15d5076b620b2ff8dd1af28bab19254f8ea62e6918cda6f52434` |
| leaf_2 | `not present in plain MUL_MAT graph` | `not present in plain MUL_MAT graph` | `not present in plain MUL_MAT graph` |
| leaf_3 | `not present in plain MUL_MAT graph` | `not present in plain MUL_MAT graph` | `not present in plain MUL_MAT graph` |

## fused, seed 25025, K=5120

| Tensor | A SHA-256 | B SHA-256 | C SHA-256 |
| --- | --- | --- | --- |
| leaf_0 | `5e874c62309719a4e66e32a1c4c2db8f17eb1976551f4b530ba2b561ece508ce` | `5e874c62309719a4e66e32a1c4c2db8f17eb1976551f4b530ba2b561ece508ce` | `5e874c62309719a4e66e32a1c4c2db8f17eb1976551f4b530ba2b561ece508ce` |
| leaf_1 | `406a3eca8b20296914b36d2321e9e41f68c7233c97b9978853ade5a02b2ada49` | `406a3eca8b20296914b36d2321e9e41f68c7233c97b9978853ade5a02b2ada49` | `406a3eca8b20296914b36d2321e9e41f68c7233c97b9978853ade5a02b2ada49` |
| leaf_2 | `c6867fa96912c2dc92ebae235b688dccc7816cc63bc844e20ec54b7a9ddad214` | `c6867fa96912c2dc92ebae235b688dccc7816cc63bc844e20ec54b7a9ddad214` | `c6867fa96912c2dc92ebae235b688dccc7816cc63bc844e20ec54b7a9ddad214` |
| leaf_3 | `38caec87936668391b0362e0d669958e5a8ed67ca5d5b3c897f16241f1cfcbd9` | `38caec87936668391b0362e0d669958e5a8ed67ca5d5b3c897f16241f1cfcbd9` | `38caec87936668391b0362e0d669958e5a8ed67ca5d5b3c897f16241f1cfcbd9` |

## plain-k5120, seed 25025, K=5120

| Tensor | A SHA-256 | B SHA-256 | C SHA-256 |
| --- | --- | --- | --- |
| leaf_0 | `5e874c62309719a4e66e32a1c4c2db8f17eb1976551f4b530ba2b561ece508ce` | `5e874c62309719a4e66e32a1c4c2db8f17eb1976551f4b530ba2b561ece508ce` | `5e874c62309719a4e66e32a1c4c2db8f17eb1976551f4b530ba2b561ece508ce` |
| leaf_1 | `406a3eca8b20296914b36d2321e9e41f68c7233c97b9978853ade5a02b2ada49` | `406a3eca8b20296914b36d2321e9e41f68c7233c97b9978853ade5a02b2ada49` | `406a3eca8b20296914b36d2321e9e41f68c7233c97b9978853ade5a02b2ada49` |
| leaf_2 | `not present in plain MUL_MAT graph` | `not present in plain MUL_MAT graph` | `not present in plain MUL_MAT graph` |
| leaf_3 | `not present in plain MUL_MAT graph` | `not present in plain MUL_MAT graph` | `not present in plain MUL_MAT graph` |

