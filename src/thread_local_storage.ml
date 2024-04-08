(* see: https://discuss.ocaml.org/t/a-hack-to-implement-efficient-tls-thread-local-storage/13264 *)

(* sanity check *)
let () = assert (Obj.field (Obj.repr (Thread.self ())) 1 = Obj.repr ())

type 'a key = int (** Unique index for this key. *)

(** Counter used to allocate new keys *)
let counter = Atomic.make 0

(** Value used to detect a TLS slot that was not initialized yet.
    Because [counter] is private and lives forever, no other
    object the user can see will have the same address. *)
let sentinel_value_for_uninit_tls_ : Obj.t = Obj.repr counter

external c_set_sentinel_ : Obj.t -> unit = "ocaml_tls__set_sentinel"

let () = c_set_sentinel_ sentinel_value_for_uninit_tls_

let new_key () : _ key = Atomic.fetch_and_add counter 1

type thread_internal_state = {
  _id: int;  (** Thread ID (here for padding reasons) *)
  mutable tls: Obj.t;  (** Our data, stowed away in this unused field *)
  _other: Obj.t;
      (** Here to avoid lying to ocamlopt/flambda about the size of [Thread.t] *)
}
(** A partial representation of the internal type [Thread.t], allowing
  us to access the second field (unused after the thread
  has started) and stash TLS data in it. *)

external get_raw_ : 'a key -> 'a = "ocaml_tls__get_raw" [@@noalloc]

let[@inline never] tls_error () = failwith "TLS entry not initialised"

(* reference, poor codegen *)
let[@inline] _get_raw2_ index =
  let thread : thread_internal_state = Obj.magic (Thread.self ()) in
  let tls = thread.tls in
  if Obj.is_block tls then (
    let tls = (Obj.obj tls : Obj.t array) in
    if index < Array.length tls then
      Array.unsafe_get tls index
    else
      sentinel_value_for_uninit_tls_
  ) else
    sentinel_value_for_uninit_tls_

let[@inline] get key =
  let v = get_raw_ key in
  if v != sentinel_value_for_uninit_tls_ then
    Obj.obj v
  else
    tls_error ()

(* for codegen comparison *)
let[@inline] _get2_ key =
  let v = _get_raw2_ key in
  if v != sentinel_value_for_uninit_tls_ then
    Obj.obj v
  else
    tls_error ()

let[@inline] get_with_default ~default key =
  let v = get_raw_ key in
  if v != sentinel_value_for_uninit_tls_ then
    Obj.obj v
  else
    default

let[@inline] get_exn key =
  let v = get_raw_ key in
  if v != sentinel_value_for_uninit_tls_ then
    Obj.obj v
  else
    raise Not_found

let[@inline] get_opt key =
  let v = get_raw_ key in
  if v != sentinel_value_for_uninit_tls_ then
    Some (Obj.obj v)
  else
    None


(** Allocating and setting *)

let ceil_pow_2_minus_1 (n : int) : int =
  let n = n lor (n lsr 1) in
  let n = n lor (n lsr 2) in
  let n = n lor (n lsr 4) in
  let n = n lor (n lsr 8) in
  let n = n lor (n lsr 16) in
  if Sys.int_size > 32 then
    n lor (n lsr 32)
  else
    n

(** Grow the array so that [index] is valid. *)
let[@inline never] grow_tls (old : Obj.t array) (index : int) : Obj.t array =
  let new_length = ceil_pow_2_minus_1 (index + 1) in
  let new_ = Array.make new_length sentinel_value_for_uninit_tls_ in
  Array.blit old 0 new_ 0 (Array.length old);
  new_

let[@inline] tls_alloc_ (index : int) : Obj.t array =
  let thread : thread_internal_state = Obj.magic (Thread.self ()) in
  let tls = thread.tls in
  if Obj.is_int tls then (
    let new_tls = grow_tls [||] index in
    thread.tls <- Obj.repr new_tls;
    new_tls
  ) else (
    let tls = (Obj.obj tls : Obj.t array) in
    if index < Array.length tls then
      tls
    else (
      let new_tls = grow_tls tls index in
      thread.tls <- Obj.repr new_tls;
      new_tls
    )
  )

let[@inline] set index value : unit =
  let tls = tls_alloc_ index in
  Array.unsafe_set tls index (Obj.repr (Sys.opaque_identity value))
