# charm

A tiny, self-contained cryptography library, implementing authenticated
encryption and keyed hashing.

Charm uses the [Xoodoo[12]](https://permutationbasedcrypto.org/2018/slides/Gilles_Van_Assche.pdf) permutation (which can be replaced by
[simpira384](https://github.com/jedisct1/simpira384)) in a duplex mode.
