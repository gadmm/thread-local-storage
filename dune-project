(lang dune 2.0)
(name thread-local-storage_async-safe)
(version 0.2)
(generate_opam_files true)

(source
 (github gadmm/thread-local-storage))
(authors "Vesa Karvonen" "Simon Cruanes" "Guillaume Munch-Maccagnoni")
(maintainers "Guillaume Munch-Maccagnoni <guillaume.munch-maccagnoni@inria.fr")
(license "LGPL-3.0-only WITH LGPL-3.0-linking-exception")

(package
 (name thread-local-storage_async-safe)
 (synopsis "Efficient thread local storage for OCaml (async-safe)")
 (depends (ocaml (>= 4.12)) (dune (>= 2.0)))
 (description "Thread-local storage for OCaml

This is a fork of the thread-local-storage package with an
incompatible API, more suitable for projects where async-callback
safety (e.g. memprof callbacks) is a concern.")

 (tags
  (topics threads tls)))

; See the complete stanza docs at https://dune.readthedocs.io/en/stable/dune-files.html#dune-project
