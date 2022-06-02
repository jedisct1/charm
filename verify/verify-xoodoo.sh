#!/usr/bin/env bash

# This script formally verifies that the charm.c implementation of the Xoodoo permutation matches
# the spec. The spec is implemented in Cryptol, a domain-specific language for cryptography, and
# includes some properties about the spec itself that can optionally be proved. The Software
# Analysis Workbench (SAW) builds formal models of the Cryptol specification, and the LLVM bitcode
# generated from charm.c, and proves them equivalent using the ABC verification tool.
#
# I've tried to make the script check for dependencies, but you'll need clang between versions 3.6
# and 7.x, and a distribution of SAW from https://saw.galois.com/downloads.html (you can build your
# own if you don't mind setting up Haskell).
#
# If `saw` and `cryptol` aren't on your path, you can point to their installed directory with the
# `SAW_BIN` environment variable. Likewise, you can specify a clang to use with the `CLANG`
# environment variable.

# Preliminary setup

set -e

[ -f verify-xoodoo.sh ] || (
    echo "Must be run in the /verify directory"
    exit 1
)

if [ -x "${SAW_BIN}/saw" ]; then
    echo "Using SAW executable at: ${SAW_BIN}/saw"
    SAW="${SAW_BIN}/saw"
elif [ -x "$(command -v saw)" ]; then
    echo "Using SAW executable from PATH"
    SAW="saw"
else
    echo "SAW not found in PATH or in the SAW_BIN=\"${SAW}\" directory" >&2
    echo "You can get SAW at https://saw.galois.com/downloads.html" >&2
    exit 1
fi

if [ -x "${SAW_BIN}/cryptol" ]; then
    echo "Using Cryptol executable at: ${SAW_BIN}/cryptol"
    CRYPTOL="${SAW_BIN}/cryptol"
elif [ -x "$(command -v cryptol)" ]; then
    echo "Using Cryptol executable from PATH"
    CRYPTOL="cryptol"
else
    echo "Cryptol not found in PATH or in the SAW_BIN=\"${CRYPTOL}\" directory" >&2
    echo "You can get Cryptol as part of the SAW distribution at https://saw.galois.com/downloads.html" >&2
    exit 1
fi

if [ -x "${CLANG}" ]; then
    echo "Using clang-7 executable at: ${CLANG}"
elif [ -x "$(command -v clang-7)" ]; then
    echo "Using clang-7 executable from PATH"
    CLANG="clang-7"
else
    echo "clang-7 not found in PATH or in environment variable CLANG=${CLANG}" >&2
    exit 1
fi

cleanup() {
    # always clean up the bitcode files generated for verification
    rm -f charm*.bc
}
trap cleanup EXIT

# Cryptol spec proof or random test, depending on whether Yices is installed

if [ -x "$(command -v yices)" ]; then
    echo "yices found in PATH; proving properties defined in the Cryptol spec"
    ${CRYPTOL} xoodoo.cry -c ":set prover=yices" -c ":prove"
else
    echo "yices not found in PATH; running randomized property tests on the Cryptol spec"
    echo "(to prove properties instead, install yices from https://yices.csl.sri.com/"
    ${CRYPTOL} xoodoo.cry -c ":set tests=1000" -c ":check"
fi

# Build LLVM bitcodes from C implementation (-O2 seems to produce bitcode with a GEP instruction SAW
# doesn't like)

echo "Building unoptimized LLVM bitcode from charm.c"
${CLANG} -g -c ../src/charm.c -emit-llvm -o charm.bc

echo "Building -O1 optimized LLVM bitcode from charm.c"
${CLANG} -g -c ../src/charm.c -emit-llvm -O1 -o charm-opt.bc

# And finally run the equivalence proofs

echo "Running SAW proof script"
${SAW} xoodoo.saw
