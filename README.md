# charm

A tiny, self-contained cryptography library, implementing authenticated
encryption and keyed hashing.

Charm uses the Xoodoo[12]([paper](https://tosc.iacr.org/index.php/ToSC/article/view/7359/6529),
[presentation](https://permutationbasedcrypto.org/2018/slides/Gilles_Van_Assche.pdf))
permutation (which can be replaced by AES-based [simpira384](https://github.com/jedisct1/simpira384)
or Gimli) in a duplex mode.

The Xoodoo implementations in Charm are [formally verified](https://github.com/jedisct1/charm/tree/master/verify) against a Cryptol specification.

Users:

- [dsvpn](https://github.com/jedisct1/dsvpn) a Dead Simple VPN, designed to address the most common use case for using a VPN.

Other implementations:

- [zig-charm](https://github.com/jedisct1/zig-charm) an implementation of Charm in the Zig language.
- [charm.js](https://github.com/jedisct1/charm.js) a JavaScript (TypeScript) implementation.
