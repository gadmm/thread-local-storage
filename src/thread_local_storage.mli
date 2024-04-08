(** Thread local storage *)

type 'a key
(** A TLS key for values of type ['a]. This allows the storage of a
    single value of type ['a] per thread. *)

val new_key : unit -> 'a key
(** Allocate a new, generative key.

    Keys are never deallocated and consume a word in each thread. As a
    general rule, this should only be called at toplevel to produce
    constants, do not use it in a loop. *)

val get : 'a key -> 'a
(** Get the value for the current thread. Can be used in asynchronous
    callbacks. Fails with a [Failure] exception if the TLS entry has
    not been initialised. *)

val get_with_default : default:'a -> 'a key -> 'a
(** Get the value for the current thread. Can be used in asynchronous
    callbacks. Returns the [default] argument if the TLS entry has not
    been initialised.  *)

val get_exn : 'a key -> 'a
(** Get the value for the current thread. Can be used in asynchronous
    callbacks. Raises [Not_found] if the TLS entry has not been
    initialised. *)

val get_opt : 'a key -> 'a option
(** Get the value for the current thread. Can be used in asynchronous
    callbacks. Returns None if the TLS entry has not been
    initialised. *)

val set : 'a key -> 'a -> unit
(** Set the value for the current thread. Cannot be used in
    asynchronous callbacks.*)
