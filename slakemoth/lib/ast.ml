module Location = Parser_util.Location

type 'a with_location =
  { detail : 'a
  ; location : Location.t
  }

type constructor_name = string

(* FIXME: distinguish constructor and domain/variable names. *)
type name = string
[@@deriving eq]

module NameMap = Map.Make (String)

type term_detail =
  (* References to atoms and defined data *)
  | Apply of name with_location * term list
  | Next of term * term
  (* Constants *)
  | StrConstant of string
  | Constructor of string
  (* built-in atoms *)
  | True
  | False
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
  | Sequence of term list
  | Assign of term * term
  | For of name * name with_location * term
  | If of term * term
  | The of name * name with_location * term

and term = term_detail with_location

type tuple = name with_location list
type table = tuple with_location list

type param_spec =
  (name with_location * name with_location) list

type definition =
  | Term of term
  | Table of table

(* Declarations that can appear at the top-level in a file *)
type declaration =
  | Definition  of name with_location * param_spec * definition
  | Domain_decl of name with_location * constructor_name with_location list
  | Atom_decl of name with_location * param_spec
  | Dump of term
  | IfSat of term * term
  | AllSat of term * term
  | Print of term

(* Pretty printing terms and declarations. *)
let pp_name fmt name =
  Format.fprintf fmt "%s" name.detail

let pp_comma fmt () =
  Format.fprintf fmt ",@ "

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
  | Sequence terms ->
     Format.fprintf fmt "@[<hv>%a@]"
       (Format.pp_print_list
          ~pp_sep:(fun fmt () -> Format.fprintf fmt ",@ ")
          pp_quant_term)
       terms
  | _ ->
     pp_quant_term fmt term
and pp_quant_term fmt term =
  match term.detail with
  | BigAnd (nm, domain, body) ->
     Format.fprintf fmt "@[<hov2>forall(%s : %a)@ %a@]"
       nm
       pp_name domain
       pp_quant_term body
  | BigOr (nm, domain, body) ->
     Format.fprintf fmt "@[<hov2>some(%s : %a)@ %a@]"
       nm
       pp_name domain
       pp_quant_term body
  | For (nm, domain, body) ->
     Format.fprintf fmt "@[<hov2>for(%s : %a)@ %a@]"
       nm
       pp_name domain
       pp_quant_term body
  | If (term1, term2) ->
     Format.fprintf fmt "@[<hov2>if(%a)@ %a@]"
       pp_term term1
       pp_quant_term term2
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
  | Assign (t1, t2) ->
     Format.fprintf fmt "@[<hv2>%a@ : %a@]"
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
       (Format.pp_print_list ~pp_sep:pp_comma pp_term)
       args
  | Constructor cnm ->
     Format.fprintf fmt "%s" cnm
  | Neg t ->
     Format.fprintf fmt "~%a" pp_base_term t
  | StrConstant s ->
     Format.fprintf fmt "%S" s
  | JSONObject t ->
     Format.fprintf fmt "{ @[<hv2>%a }@]"
       pp_term t
  | JSONArray t ->
     Format.fprintf fmt "[ @[<hv2>%a ]@]"
       pp_term t
  | True ->
     Format.fprintf fmt "true"
  | False ->
     Format.fprintf fmt "false"
  | _ ->
     Format.fprintf fmt "(%a)" pp_term term

let pp_arg fmt (nm1, nm2) =
  Format.fprintf fmt "%a : %a"
    pp_name nm1
    pp_name nm2

let pp_arg_spec =
  Format.pp_print_list
    ~pp_sep:pp_comma
    pp_arg

let pp_tuple fmt tuple =
  Format.fprintf fmt "(%a)"
    (Format.pp_print_list
       ~pp_sep:(fun fmt () -> Format.pp_print_string fmt ",")
       pp_name)
    tuple.detail

let pp_table =
  Format.pp_print_list pp_tuple

let pp_declaration fmt = function
  | Definition (name, [], Term body) ->
     Format.fprintf fmt
       "@[<v0>@[<v2>define %a {@ %a@]@,}@]@,"
       pp_name name
       pp_term body
  | Definition (name, arg_spec, Term body) ->
     Format.fprintf fmt
       "@[<v0>@[<v2>define %a(@[%a@]) {@ %a@]@,}@]@,"
       pp_name name
       pp_arg_spec arg_spec
       pp_term body
  | Definition (name, arg_spec, Table items) ->
     Format.fprintf fmt
       "@[<v0>@[<v2>define %a(@[%a@]) table {@ %a@]@,}@]@,"
       pp_name name
       pp_arg_spec arg_spec
       pp_table items
  | Domain_decl (name, constructors) ->
     Format.fprintf fmt "@[<hv0>domain %a @[<hv2>{@ %a@]@ }@]@,"
       pp_name name
       (Format.pp_print_list ~pp_sep:pp_comma pp_name) constructors
  | Atom_decl (name, []) ->
     Format.fprintf fmt "atom %a@,"
       pp_name name
  | Atom_decl (name, arg_spec) ->
     Format.fprintf fmt "atom %a(@[<hv>%a@])@,"
       pp_name name
       pp_arg_spec arg_spec
  | Dump t ->
     Format.fprintf fmt "@[<hv2>dump(%a)@]@," pp_term t
  | IfSat (t1, t2) ->
     Format.fprintf fmt "@[<v2>ifsat(%a)@ %a@]@,"
       pp_term t1
       pp_base_term t2
  | AllSat (t1, t2) ->
     Format.fprintf fmt "@[<v2>allsat(%a)@ %a@]@,"
       pp_term t1
       pp_base_term t2
  | Print t ->
     Format.fprintf fmt "@[<hv2>print(%a)@]@," pp_term t
