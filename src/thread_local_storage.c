#include "caml/mlvalues.h"
#include "caml/memory.h"
#include "caml/version.h"

#include <pthread.h>

#include <assert.h>

static value sentinel;

value ocaml_tls__set_sentinel(value s)
{
  sentinel = s;
  caml_register_generational_global_root(&sentinel);
  return Val_unit;
}

value caml_thread_self(value unit);

#ifdef __GNUC__
#define CAMLunlikely(e) __builtin_expect(!!(e), 0)
#else
#define CAMLunlikely(e) (e)
#endif

value ocaml_tls__get_raw(value key)
{
  intnat index = Long_val(key);
  value th = caml_thread_self(Val_unit);
  value tls = Field(th, 1);
  if (CAMLunlikely(tls == Val_unit || index >= Wosize_val(tls)))
    return sentinel;
  return Field(tls, index);
}
