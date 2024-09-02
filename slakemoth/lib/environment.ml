open Ast
open Kinding

type domain_info =
  { constructors : string list }

module DomainInfo = struct
  let equal di1 di2 =
    List.equal String.equal di1.constructors di2.constructors
end

type defn =
  | Defined of
      { args : (name * name) list
      ; body : term
      ; kind : kind
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
  | AllSat of environment * term * term
  | Print of environment * term
