# Thread-local storage for OCaml (async-safe)

The classic threading utility: have variables that have a value for
each thread.

This fork of `thread-local-storage` has a different API such that
reading TLS inside async callbacks (e.g. memprof callbacks) is safe.

See
https://discuss.ocaml.org/t/a-hack-to-implement-efficient-tls-thread-local-storage/13264
for the initial implementation by @polytypic.

See https://github.com/c-cube/thread-local-storage for the
`thread-local-storage` package with a different API.

## License

Distributed under the LGPL v3 with linking exception.

Incorporates work covered by the MIT license.

SPDX-License-Identifier: LGPL-3.0-only WITH LGPL-3.0-linking-exception
