
# 0.1

initial release

# 0.2+gadmm

Simplified version meant to be async-callback-safe.

- Incompatible API change.

- Bumped OCaml version to 4.12.

- Renamed to `thread-local-storage_async-safe`.

- The `get` functions have optimised codegen and can be used in async
  callbacks (e.g. memprof callbacks).

- Changes are licensed under LGPLv3 with linking exception.
