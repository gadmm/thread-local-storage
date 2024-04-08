(** Thread local storage *)

type 'a key
(** A TLS key for values of type ['a]. This allows the storage of a
    single value of type ['a] per thread. *)

val new_key : default:'a -> 'a key
(** Allocate a new, generative key. When the key is used for the first
    time on a thread, the function is called to produce it.

    Keys are never deallocated and consume a word in each thread. As a
    general rule, this should only be called at toplevel to produce
    constants, do not use it in a loop. *)

val get : 'a key -> 'a
(** Get the value for the current thread. Can be used in asynchronous
    callbacks. *)

val set : 'a key -> 'a -> unit
(** Set the value for the current thread. Cannot be used in
    asynchronous callbacks.*)
