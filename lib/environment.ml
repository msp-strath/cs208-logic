open Ast

type domain_info =
  { constructors : string list }

type defn =
  | Defined of
      { args : (name * name) list
      ; body : term
      }
  | Atom of
      { args : (name * name) list }

type environment =
  { domains : domain_info NameMap.t
  ; constructor_domains : (name * Location.t) NameMap.t
  ; defns   : defn NameMap.t
  }

let initial_global_env =
  { domains = NameMap.empty
  ; constructor_domains = NameMap.empty
  ; defns = NameMap.empty
  }

type command =
  | Dump_Clauses of environment * term
  | IfSat of environment * term * term
