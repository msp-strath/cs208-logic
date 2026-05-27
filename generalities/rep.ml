(* Codes for types

   These codes are only intended for 'serialisable' types, whose
   values can be converted to a textual form and back again.
 *)

(* see also: https://github.com/ocamllibs/refl *)

type (_,_) var =
  | X : ('ctx * 'a, 'a) var
  | S : ('ctx, 'a) var -> ('ctx * 'b, 'a) var

type ('ctx, 'a) rep =
  | Var     : ('ctx, 'a) var -> ('ctx, 'a) rep
  | Fix     : ('ctx * 'a, 'a) rep -> ('ctx, 'a) rep
  | Weaken  : ('ctx, 'a) rep -> ('ctx * _, 'a) rep
  | Unit    : ('ctx, unit) rep
  | Int     : ('ctx, int) rep
  (* | Char    : ('ctx, char) rep *)
  | String  : ('ctx, string) rep
  | Float   : ('ctx, float) rep
  | List    : ('ctx, 'a) rep -> ('ctx, 'a list) rep
  | Array   : ('ctx, 'a) rep -> ('ctx, 'a array) rep
  | Tuple2  : ('ctx, 'a) rep * ('ctx, 'b) rep -> ('ctx, 'a * 'b) rep
  | Variant : { variant: 'x. ('ctx, 'a, 'x) variant_bits } -> ('ctx, 'a) rep
  | Record  : { rep : ('ctx, 'a, 'b) record; construct : 'a } -> ('ctx, 'b) rep

and ('ctx, 'a, 'b) record =
  | End   : ('ctx, 'a, 'a) record
  | Field : { name    : string
            ; rep     : ('ctx, 'a) rep
            ; project : ('c -> 'a)
            ; rest    : ('ctx, 'b, 'c) record
            } -> ('ctx, 'a -> 'b, 'c) record

and ('ctx, 'a, 't, 'x) cases =
  | EndCase : ('ctx, 't -> 'x, 't, 'x) cases
  | Case : { name : string
           ; rep  : ('ctx, 'a) rep (* FIXME: should be a sequence *)
           ; inject : 'a -> 't
           ; project : 't -> 'a option
           ; rest   : ('ctx, 'b, 't, 'x) cases
           } -> ('ctx, ('a -> 'x) -> 'b, 't, 'x) cases

and ('ctx, 't, 'x) variant_bits =
  VariantBits : { elim : 'e; cases : ('ctx, 'e, 't, 'x) cases }
                -> ('ctx, 't, 'x) variant_bits

(******************************************************************************)
module Env (Elt : sig type 'a t end) = struct
  type 'ctx env =
    | Emp : unit env
    | Ext : 'ctx env * 'a Elt.t -> ('ctx * 'a) env

  let rec lookup : type ctx a. (ctx, a) var -> ctx env -> a Elt.t =
    fun x env ->
    match x, env with
    | X,   Ext (_, f)   -> f
    | S x, Ext (env, _) -> lookup x env

  type ('ctx, 'a) func = ('ctx, 'a) rep -> 'ctx env -> 'a Elt.t
end

(******************************************************************************)
module PP = struct
  type 'a fmt = Format.formatter -> 'a -> unit

  module Elt = struct type 'a t = string end
  open Env (Elt)

  let rec pp_open : type ctx a. (ctx, a) rep -> ctx env -> Format.formatter -> unit =
    fun rep ctx fmt ->
      match rep with
      | Var x ->
	let x_nm = lookup x ctx in
	Format.pp_print_string fmt x_nm
      | Fix rep ->
	(* FIXME: generate better names *)
	Format.fprintf fmt "mu 'x. %t"
	  (pp_open rep (Ext (ctx, "'x")))
      | Weaken rep ->
	(match ctx with
	| Ext (ctx, _) -> pp_open rep ctx fmt)
      | Unit ->
	Format.pp_print_string fmt "unit"
      | Int ->
	Format.pp_print_string fmt "int"
      | String ->
	Format.pp_print_string fmt "string"
      | Float ->
	Format.pp_print_string fmt "float"
      | List rep ->
	Format.fprintf fmt "list(%t)"
	  (pp_open rep ctx)
      | Array rep ->
	Format.fprintf fmt "array(%t)" (pp_open rep ctx)
      | Tuple2 (rep1, rep2) ->
	Format.fprintf fmt "(%t * %t)" (pp_open rep1 ctx) (pp_open rep2 ctx)
      | Variant { variant = VariantBits { elim = _; cases } } ->
	Format.fprintf fmt "@[<hv0>[%t]@]" (pp_cases cases ctx)
      | Record { rep; construct=_ } ->
	Format.fprintf fmt "{%t}" (pp_fields rep ctx)

and pp_cases : type ctx e t x. (ctx, e, t, x) cases -> ctx env -> Format.formatter -> unit =
  fun cases ctx fmt ->
    match cases with
    | EndCase -> ()
    | Case { name; rep; inject=_; project=_; rest=EndCase } ->
      Format.fprintf fmt " %s : %t "
	name
	(pp_open rep ctx)
    | Case { name; rep; inject=_; project=_; rest } ->
      Format.fprintf fmt " %s : %t@ |%t"
	name
	(pp_open rep ctx)
	(pp_cases rest ctx)

and pp_fields : type ctx c t. (ctx, c, t) record -> ctx env -> Format.formatter -> unit =
  fun fields ctx fmt ->
    match fields with
    | End -> ()
    | Field { name; rep; project=_; rest } ->
      Format.fprintf fmt "%s : %t; %t"
	name
	(pp_open rep ctx)
	(pp_fields rest ctx)

  let pp fmt rep =
    pp_open rep Emp fmt

end

(******************************************************************************)
module Equal = struct
  type 'a equality_test = 'a -> 'a -> bool

  module Elt = struct type 'a t = 'a equality_test end
  open Env (Elt)

  let rec equal : type ctx a. (ctx, a) func =
    fun rep env x y ->
    match rep, x, y with
    | Var v, x, y -> lookup v env x y
    | Fix rep, x, y -> let rec f x y = equal rep (Ext (env, f)) x y in f x y
    | Weaken rep, x, y -> (match env with Ext (env, _) -> equal rep env x y)

    | Unit, (), () -> true
    | String, s1, s2  -> String.equal s1 s2
    | Int, i1, i2     -> Int.equal i1 i2
    | Float, f1, f2   -> Float.equal f1 f2
    | List r, l1, l2 ->
       List.equal (equal r env) l1 l2
    | Array r, a1, a2 ->
       Array.length a1 = Array.length a2 && Array.for_all2 (equal r env) a1 a2
    | Tuple2 (r1, r2), (x1, x2), (y1, y2) ->
       equal r1 env x1 y1 && equal r2 env x2 y2
    | Variant { variant = VariantBits { elim; cases } }, x, y ->
       let rec build_elim : type e. e -> (ctx, e, a, bool) cases -> a -> bool =
         fun f ->
         function
         | EndCase -> f
         | Case { name = _; rep; inject = _; project; rest } ->
            let check x =
              match project y with
              | None -> false
              | Some y -> equal rep env x y
            in
            build_elim (f check) rest
       in
       build_elim elim cases x
    | Record { rep; construct = _ }, x, y ->
       let rec check_fields : type c. (ctx, c, a) record -> bool =
         function
         | End -> true
         | Field { name = _; rep; project; rest } ->
            equal rep env (project x) (project y) && check_fields rest
       in
       check_fields rep

  let equal rep = equal rep Emp
end

(* TODO: compare, hash *)

(******************************************************************************)
(* Example *)
let list rep_a =
  let variant =
    VariantBits
      { elim = (fun c1 c2 x -> match x with [] -> c1 () | x::xs -> c2 (x,xs))
      ; cases =
          Case {
              name = "Nil";
              rep = Unit;
              inject = (fun () -> []);
              project = (function [] -> Some () | _::_ -> None);
              rest = Case {
                         name = "Cons";
                         rep = Tuple2 (Weaken rep_a, Var X);
                         inject = (fun (x, xs) -> x::xs);
                         project = (function x::xs -> Some (x,xs) | [] -> None);
                         rest = EndCase
                       }
            }
      }
  in
  Fix (Variant { variant })

(******************************************************************************)
(* Pretty printing in an OCaml-style syntax *)
type 'a fmt = Format.formatter -> 'a -> unit

type 'ctx pp_env =
  | Emp : unit pp_env
  | Ext : 'ctx pp_env * 'a fmt -> ('ctx * 'a) pp_env

let rec lookup : type ctx a. (ctx, a) var -> ctx pp_env -> a fmt =
  fun x env ->
  match x, env with
  | X,   Ext (_, f)   -> f
  | S x, Ext (env, _) -> lookup x env

let rec pp_open : type ctx a. (ctx, a) rep -> ctx pp_env -> a fmt =
  fun rep env fmt ->
  match rep with
  | Unit    -> fun () -> Format.pp_print_string fmt "()"
  (* | Char    -> Format.fprintf fmt "%C" *)
  | String  -> Format.fprintf fmt "%S"
  | Float   -> Format.pp_print_float fmt
  | Int     -> Format.pp_print_int fmt
  | List rep ->
     Format.fprintf fmt
       "[%a]"
       (Format.pp_print_list
          ~pp_sep:(fun fmt () -> Format.pp_print_string fmt "; ")
          (pp_open rep env))
  | Array rep ->
     Format.fprintf fmt
       "[|%a|]"
       (Format.pp_print_array
          ~pp_sep:(fun fmt () -> Format.pp_print_string fmt "; ")
          (pp_open rep env))
  | Fix rep ->
     let rec f fmt x = pp_open rep (Ext (env, f)) fmt x in
     f fmt
  | Var v ->
     lookup v env fmt
  | Weaken rep ->
     (match env with Ext (env,_) -> pp_open rep env fmt)
  | Tuple2 (rep_a, rep_b) ->
     fun (a,b) -> Format.fprintf fmt "(%a,%a)" (pp_open rep_a env) a (pp_open rep_b env) b
  | Variant { variant = VariantBits { elim; cases } } ->
     let rec try_cases : type e. e -> (ctx, e, a, unit) cases -> a -> unit =
       fun f ->
       function
       | EndCase -> f
       | Case { name; rep; inject = _; project = _; rest } ->
          try_cases (f (Format.fprintf fmt "%s (%a)" name (pp_open rep env))) rest
     in
     try_cases elim cases
  | Record { rep; _ } ->
     fun value ->
     let rec fields : type b. (ctx, b, a) record -> unit = function
       | End -> ()
       | Field { name; rep; project; rest } ->
          Format.fprintf fmt "@ %s = %a;"
            name
            (pp_open rep env) (project value);
          fields rest
     in
     Format.fprintf fmt "@[<hov0>@[<hov2>{";
     fields rep;
     Format.fprintf fmt "@]@ }@]"

let pp : type a. (unit, a) rep -> a fmt =
  fun rep fmt a -> pp_open rep Emp fmt a

(*
module Sexp_encoder = struct
  type sexp = Sexplib.Type.t = Atom of string | List of sexp list

  type 'a encoder = 'a -> sexp list
  module Elt = struct type 'a t = 'a encoder end
  open Env (Elt)

  (* How should this work?

     Records:
     (<fieldname> data...) (<fieldname> data...)

     Variants:
     (<variant-name> data...)

     For records, arrays, lists, if this is the last one then it is
     left inline, else nest inside another List.



   *)

  let rec encode : type ctx a. (ctx, a) rep -> ctx env -> a encoder =
    fun rep env value ->
    match rep with
    | Var x ->
       lookup x env value
    | Fix rep ->
       let rec f value = encode rep (Ext (env, f)) value in
       f value
    | Weaken rep ->
       (match env with Ext (env, _) -> encode rep env value)
    | Unit ->
       []
    | Int ->
       [Atom (string_of_int value)]
    | String ->
       [Atom value]
    | Float ->
       [Atom (string_of_float value)]
    | List rep ->
       List.map (fun sexps -> List sexps) (List.map (encode rep env) value)
    |
end
 *)

(* JSON deserialiser *)
module Json_dec = struct
  type 'a reader = Json.t -> ('a, string) result

  module Elt = struct type 'a t = 'a reader end
  open Env (Elt)

  let rec read_open : type ctx a. (ctx, a) rep -> ctx env -> a reader =
    fun rep env json ->
    match rep, json with
    | Var x, json ->
       lookup x env json
    | Fix rep, json ->
       let rec f json = read_open rep (Ext (env, f)) json in
       f json
    | Weaken rep, json ->
       (match env with Ext (env,_) -> read_open rep env json)
    | Unit, Json.JNull -> Ok ()
    | Unit, _          -> Error "Expecting 'null'"
    | Int, Json.JInt i -> Ok i
    | Int, _           -> Error "Expecting a number"
    | Float, Json.JInt i -> Ok (float_of_int i)
    | Float, _           -> Error "Expecting a number"
    | String, Json.JString s -> Ok s
    | String, _              -> Error "Expecting a string"
    | Array _rep, Json.JArray _a ->
       Ok [||] (* FIXME: scan the array *)
    | List _rep, Json.JArray _a ->
       Ok [] (* FIXME: scan the array *)
    | (Array _ | List _), _ ->
       Error "Expecting an array"
    | Tuple2 (rep1, rep2), Json.JArray [json1;json2] ->
       Result.bind (read_open rep1 env json1)
       @@ fun v1 ->
          Result.bind (read_open rep2 env json2)
          @@ fun v2 ->
             Ok (v1, v2)
    | Tuple2 _, _ ->
       Error "Expecting an array of length 2"
    | Variant { variant = VariantBits { elim = _; cases } }, Json.JArray [Json.JString tag; json] ->
       let rec search : type e. (ctx, e, a, a reader) cases -> (a, string) result = function
         | EndCase ->
            Error (Printf.sprintf "Tag %S not valid here" tag)
         | Case { name; rep; inject; project = _; rest } ->
            if String.equal name tag then
              Result.bind (read_open rep env json) @@ fun v -> Ok (inject v)
            else
              search rest
       in
       search cases
    | Variant _, _ ->
       Error "Expecting a variant representation"
    | Record { rep; construct }, Json.JObject assoc ->
       let rec build : type c. (ctx, c, a) record -> c -> (a, string) result =
         fun rep c ->
         match rep with
         | End ->
            Ok c
         | Field { name; rep; project = _; rest } ->
            (match List.assoc_opt name assoc with
            | None -> Error (Printf.sprintf "Missing %S field" name)
            | Some json ->
               Result.bind (read_open rep env json)
               @@ fun v -> build rest (c v))
       in
       build rep construct
    | Record _, _ ->
       Error "Expecting an object"

  let read rep value = read_open rep Emp value

end

module type Coder = sig
  type t

  val unit : unit -> t
  val int : int -> t
  val float : float -> t
  val string : string -> t
  val array : ('a -> t) -> 'a array -> t
  val tuple2 : t -> t -> t
  val record : (string * t) list -> t
  val tagged : string -> t -> t
end

module type Decoder = sig
  type t

  val unit : t -> unit option
  val int : t -> int option
  val float : t -> float option
  val string : t -> string option
  val array : (t -> 'a) -> t -> 'a array option
  val tuple2 : t -> (t * t) option
  val field : t -> string -> t option
  val tagged : t -> (string * t) option
end

module Json_cod = struct

  type 'a writer = 'a -> Json.t

  module Elt = struct type 'a t = 'a writer end
  open Env (Elt)

  let rec write_open : type ctx a. (ctx, a) rep -> ctx env -> a writer =
    fun rep env value ->
    match rep, value with
    | Var x, value ->
       lookup x env value
    | Fix rep, value ->
       let rec f x = write_open rep (Ext (env, f)) x in
       f value
    | Weaken rep, value ->
       (match env with Ext (env,_) -> write_open rep env value)
    | Unit, () -> Json.JNull
    | Int, i   -> Json.JInt i
    | Float, _f -> failwith "UNIMPLEMENTED: float"
    | String, s -> Json.JString s
    | Array rep, a ->
       Json.JArray (a |> Array.to_seq |> Seq.map (write_open rep env) |> List.of_seq)
    | List rep, a ->
       Json.JArray (List.map (write_open rep env) a)
    | Tuple2 (rep1, rep2), (x, y) ->
       Json.JArray [ write_open rep1 env x; write_open rep2 env y ]
    | Variant { variant = VariantBits { elim; cases } }, value ->
       let rec analyse : type e. e -> (ctx, e, a, Json.t) cases -> Json.t =
         fun elim ->
         function
         | EndCase -> elim value
         | Case { name; rep; inject = _; project = _; rest } ->
            analyse (elim (fun x -> Json.JArray [JString name; write_open rep env x])) rest
       in
       analyse elim cases
    | Record { rep; construct = _ }, value ->
       let rec build : type x. (ctx, x, a) record -> (string * Json.t) list =
         function
         | End -> []
         | Field { name; rep; project; rest } ->
            let json = write_open rep env (project value) in
            (name, json) :: build rest
       in
       Json.JObject (build rep)

  let write rep value = write_open rep Emp value

end

type test = { a : int; b : string }

let test =
  Record
    { rep = Field {
        name = "a"
      ; rep = Int
      ; project = (fun x -> x.a)
      ; rest = Field {
	  name = "b"
	; rep = String
	; project = (fun x -> x.b)
	; rest = End }}
    ; construct = (fun a b -> {a;b})
    }

let option rep =
  let variant =
    VariantBits
      { elim = (fun c1 c2 x -> match x with None -> c1 () | Some x -> c2 x)
      ; cases = Case { name = "None";
                       rep = Unit;
                       inject = (fun () -> None);
                       project = (function None -> Some () | Some _ -> None);
                       rest = Case { name = "Some";
                                     rep = rep;
                                     inject = (fun x -> Some x);
                                     project = Fun.id;
                                     rest = EndCase
                                }
                  }
      }
  in
  Variant {variant}

let impossible =
  let variant = VariantBits { cases = EndCase; elim = Impossible.elim } in
  Variant {variant}

(******************************************************************************)
type expr =
  | Var of int
  | Lam of string * expr
  | App of expr * expr

let expr =
  let variant =
    VariantBits
      { elim = (fun v l a -> function Var idx -> v idx
                                    | Lam (nm,e) -> l (nm,e)
                                    | App (e1,e2) -> a (e1,e2))
      ; cases =
          Case {
              name = "Var";
              rep = Int;
              inject = (fun i -> Var i);
              project = (function Var i -> Some i | _ -> None);
              rest =
                Case {
                    name = "Lam";
                    rep = Tuple2 (String, Var X);
                    inject = (fun (s,e) -> Lam (s,e));
                    project = (function Lam (nm,e) -> Some (nm,e) | _ -> None);
                    rest = Case {
                               name = "app";
                               rep = Tuple2 (Var X, Var X);
                               inject = (fun (e1,e2) -> App (e1,e2));
                               project = (function App (e1, e2) -> Some (e1,e2) | _ -> None);
                               rest = EndCase
                             }
                  }
            }
      }
  in
  Fix (Variant {variant})

      (******************************************************************************)
