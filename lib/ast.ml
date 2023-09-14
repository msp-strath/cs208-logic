module Location = struct
  type t =
    | Source of { start : Lexing.position; endpos : Lexing.position }
    | Internal
  let mk start endpos = Source {start; endpos}
  let internal = Internal
  let to_string () = function
    | Source { start; _ } ->
       Printf.sprintf "line %d, column %d"
         start.pos_lnum
         (start.pos_cnum - start.pos_bol)
    | Internal ->
       "<internal>"
end

type 'a with_location =
  { detail : 'a
  ; location : Location.t
  }

type constructor_name = string
type name = string

module NameMap = Map.Make (String)

type term_detail =
  | Apply of name with_location * term list
  (* Constants *)
  | IntConstant of int
  | StrConstant of string
  | Constructor of string
  (* built-in atoms *)
  | Eq of term * term
  | Ne of term * term
  (* Logical operations on literals, clauses, and conjunctions of clauses *)
  | Neg of term
  | Or  of term list
  | And of term list
  | Implies of term * term
  | BigOr  of name * name with_location * term
  | BigAnd of name * name with_location * term
  (* JSON bits *)
  | JSONObject of term
  | JSONArray of term
  | For of name * name with_location * term
  | If of term * term
  | Sequence of term list
  | Assign of term * term

and term = term_detail with_location

let pp_name fmt name =
  Format.fprintf fmt "%s" name.detail

let rec pp_term fmt term = match term.detail with
  | Implies (t1, t2) ->
     Format.fprintf fmt "%a ==> %a"
       pp_connected_term t1
       pp_term t2
  | _ ->
     pp_connected_term fmt term
and pp_connected_term fmt term =
  match term.detail with
  | Or terms ->
     Format.fprintf fmt "@[<hov1>%a@]"
       (Format.pp_print_list
          ~pp_sep:(fun fmt () -> Format.fprintf fmt " |@ ")
          pp_quant_term)
       terms
  | And terms ->
     Format.fprintf fmt "@[<hv>%a@]"
       (Format.pp_print_list
          ~pp_sep:(fun fmt () -> Format.fprintf fmt " &@ ")
          pp_quant_term)
       terms
  | _ ->
     pp_quant_term fmt term
and pp_quant_term fmt term =
  match term.detail with
  | BigAnd (nm, domain, body) ->
     Format.fprintf fmt "forall(%s : %a) %a"
       nm
       pp_name domain
       pp_quant_term body
  | BigOr (nm, domain, body) ->
     Format.fprintf fmt "some(%s : %a) %a"
       nm
       pp_name domain
       pp_quant_term body
  | _ ->
     pp_eq_term fmt term
and pp_eq_term fmt term =
  match term.detail with
  | Eq (t1, t2) ->
     Format.fprintf fmt "@[<hv2>%a@ = %a@]"
       pp_base_term t1
       pp_base_term t2
  | Ne (t1, t2) ->
     Format.fprintf fmt "@[<hv2>%a@ != %a@]"
       pp_base_term t1
       pp_base_term t2
  | _ ->
     pp_base_term fmt term
and pp_base_term fmt term =
  match term.detail with
  | Apply (name, []) ->
     pp_name fmt name
  | Apply (name, args) ->
     Format.fprintf fmt "%a(@[<hov>%a@])"
       pp_name name
       (Format.pp_print_list ~pp_sep:(fun fmt () -> Format.fprintf fmt ",@ ")
          pp_term)
       args
  | IntConstant i ->
     Format.fprintf fmt "%d" i
  | Constructor cnm ->
     Format.fprintf fmt "%s" cnm
  | Neg t ->
     Format.fprintf fmt "~%a" pp_base_term t
  | StrConstant s ->
     Format.fprintf fmt "%S" s
  | _ -> (* FIXME: the JSON constructors *)
     Format.fprintf fmt "(%a)" pp_term term


(* Declarations that can appear at the top-level in a file *)
type declaration =
  | Definition  of name with_location * (name with_location * name with_location) list * term
  | Domain_decl of name with_location * constructor_name with_location list
  | Atom_decl of name with_location * (name with_location * name with_location) list
  | Dump of term
  | IfSat of term * term
