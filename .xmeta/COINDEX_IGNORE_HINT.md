# CoIndex Ignore Hint

If CoIndex or related tooling uses manifest files to decide which repos
to index, X should **not** be added to those manifests by default.

X is intended as a special-purpose lab space with its own indexing
strategy (see gib/ and harness/). Any integration with CoIndex should
be explicit and opt in.

This file is only a hint for humans and future automation. It does not
provide security or privacy.

