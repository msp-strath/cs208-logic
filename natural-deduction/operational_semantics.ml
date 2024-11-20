open Sexplib0.Sexp_conv

(*
  Rules look like:

     E1 ==> v1, E2 ==> v2 ---> E1 + E2 ==> $(v1 + v2)

  Logical framework:
  - expr : type
  - num  : int -> expr
  - add  : expr -> expr -> expr
  - mul  : expr -> expr -> expr
  - if0  : expr -> expr -> expr -> expr
  - eval : expr -> int -> prop

  - e-add : (e1 e2 : expr)(v1 v2 : int) ->
            eval e1 v1 ->
            eval e2 v2 ->
            eval (add e1 e2) (+ v1 v2)
      where e1, e2, v1, v2 all get filled in via unification

  should be able to just write these rules and have the rest generated.
 *)

module Calculus = struct
  type exp =
    | ENumber of int
    | EAdd of exp * exp
    | EMul of exp * exp
    | EIf0 of exp * exp * exp
  [@@deriving sexp]

  let rec string_of_exp = function
    | ENumber i -> string_of_int i
    | EAdd (e1, e2) -> "(" ^ string_of_exp e1 ^ "+" ^ string_of_exp e2 ^ ")"
    | EMul (e1, e2) -> "(" ^ string_of_exp e1 ^ "×" ^ string_of_exp e2 ^ ")"
    | EIf0 (e1, e2, e3) ->
        Printf.sprintf "(if %s == 0 then %s else %s)" (string_of_exp e1)
          (string_of_exp e2) (string_of_exp e3)

  module Exp = struct
    type t = exp

    let number i = ENumber i
    let add e1 e2 = EAdd (e1, e2)
    let mul e1 e2 = EMul (e1, e2)
    let if0 e1 e2 e3 = EIf0 (e1, e2, e3)
    let if0' e1 (e2, e3) = EIf0 (e1, e2, e3)
  end

  type value = int
  type goal = Eval of exp * int [@@deriving sexp]

  module Goal = struct
    type t = goal

    let to_string (Eval (exp, v)) = string_of_exp exp ^ " ⇓ " ^ string_of_int v
    let is_number = function Eval (ENumber _, _) -> true | _ -> false
  end

  type assumption = { impossible : 'a. 'a }

  module Assumption = struct
    type t = assumption

    let to_string a = a.impossible
    let encode a = a.impossible
    let decode _ = None
  end

  type update = unit

  let empty_update = ()
  let update_goal () g = g
  let update_assumption () a = a

  type rule =
    | Add of int * int
    | Mul of int * int
    | IfTrue
    | IfFalse of int
    | Literal
  [@@deriving sexp]

  let assumption _ = failwith "no assumptions possible!"

  type error = [ `Msg of string ]

  let error s = Error (`Msg s)

  let apply _assumps rule goal =
    match (rule, goal) with
    | Literal, Eval (ENumber i, j) ->
        if i = j then Ok ([], ())
        else error "Applying 'Literal': numbers can only evaluate to themselves"
    | Literal, Eval _ -> error "Applying 'Literal': expression is not a number"
    | Add (v1, v2), Eval (EAdd (e1, e2), v) ->
        if v1 + v2 = v then Ok ([ ([], Eval (e1, v1)); ([], Eval (e2, v2)) ], ())
        else error (Printf.sprintf "Applying 'Add': %d + %d is not %d" v1 v2 v)
    | Add _, Eval _ -> error "Applying 'Add': expression is not an addition"
    | Mul (v1, v2), Eval (EMul (e1, e2), v) ->
        if v1 * v2 = v then Ok ([ ([], Eval (e1, v1)); ([], Eval (e2, v2)) ], ())
        else error (Printf.sprintf "Applying 'Mul': %d * %d is not %d" v1 v2 v)
    | Mul _, Eval _ ->
        error "Applying 'Mul': expression is not a multiplication"
    | IfTrue, Eval (EIf0 (e, e1, _e2), v) ->
        Ok ([ ([], Eval (e, 0)); ([], Eval (e1, v)) ], ())
    | IfFalse 0, Eval (EIf0 _, _) ->
        error "Applying 'IfFalse': result of test cannot be 0"
    | IfFalse v', Eval (EIf0 (e, _e1, e2), v) ->
        Ok ([ ([], Eval (e, v')); ([], Eval (e2, v)) ], ())
    | IfTrue, Eval _ -> error "Applying 'IfTrue': expression is a not an 'if'"
    | IfFalse _, Eval _ ->
        error "Applying 'IfFalse': expression is a not an 'if'"
end

module Partials = struct
  module Calculus = Calculus
  open Calculus

  let name_of_rule = function
    | Add _ -> "Add"
    | Mul _ -> "Mul"
    | Literal -> "Literal"
    | IfTrue -> "IfTrue"
    | IfFalse _ -> "IfFalse"

  let left_label_of_rule _ = None

  type partial =
    | PAdd of exp * string * exp * string * int
    | PMul of exp * string * exp * string * int
    | PIfFalse of exp * string * exp * int
  [@@deriving sexp]

  let name_of_partial = function
    | PAdd _ -> "Add"
    | PMul _ -> "Mul"
    | PIfFalse _ -> "IfFalse"

  type rule_selector =
    | Immediate of rule
    | Disabled of string
    | Partial of partial

  type selector_group = { group_name : string; rules : rule_selector list }

  let rule_selection _assumps goal =
    [
      {
        group_name = "Rules";
        rules =
          [
            (if Goal.is_number goal then Immediate Literal
            else Disabled "Literal");
            (match goal with
            | Eval (EAdd (e1, e2), v) -> Partial (PAdd (e1, "", e2, "", v))
            | _ -> Disabled "Add");
            (match goal with
            | Eval (EMul (e1, e2), v) -> Partial (PMul (e1, "", e2, "", v))
            | _ -> Disabled "Mul");
            (match goal with
            | Eval (EIf0 _, _) -> Immediate IfTrue
            | _ -> Disabled "IfTrue");
            (match goal with
            | Eval (EIf0 (e, _e1, e2), v) -> Partial (PIfFalse (e, "", e2, v))
            | _ -> Disabled "IfFalse");
          ];
      };
    ]

  let elim_assumption ~conclusion:_ ~assumption ~idx:_ = assumption.impossible

  module Part_type = struct
    type t = unit

    let placeholder () = "<number>"
    let class_ () = "formulainput"
  end

  type partial_formula_part =
    | T of string
    | I of { value : string; typ : Part_type.t; update : string -> partial }
    | F of Calculus.goal

  type partial_premise = {
    premise_formula : partial_formula_part list;
    premise_assumption : string option;
  }

  type partial_presentation = {
    premises : partial_premise list;
    apply : Calculus.rule option;
  }

  let update_1 partial a1 =
    match partial with
    | PAdd (e1, _, e2, a2, v) -> PAdd (e1, a1, e2, a2, v)
    | PMul (e1, _, e2, a2, v) -> PMul (e1, a1, e2, a2, v)
    | PIfFalse (e1, _, e2, v) -> PIfFalse (e1, a1, e2, v)

  let update_2 partial a2 =
    match partial with
    | PAdd (e1, a1, e2, _, v) -> PAdd (e1, a1, e2, a2, v)
    | PMul (e1, a1, e2, _, v) -> PMul (e1, a1, e2, a2, v)
    | PIfFalse (e1, a1, e2, v) -> PIfFalse (e1, a1, e2, v)

  let present_partial _goal = function
    | (PAdd (e1, a1, e2, a2, v) | PMul (e1, a1, e2, a2, v)) as partial -> (
        let premises =
          [
            {
              premise_formula =
                [
                  T (string_of_exp e1);
                  T " ⇓ ";
                  I { value = a1; typ = (); update = update_1 partial };
                ];
              premise_assumption = None;
            };
            {
              premise_formula =
                [
                  T (string_of_exp e2);
                  T " ⇓ ";
                  I { value = a2; typ = (); update = update_2 partial };
                ];
              premise_assumption = None;
            };
          ]
        in
        match (int_of_string a1, int_of_string a2) with
        | exception _ -> { premises; apply = None }
        | v1, v2 ->
            let apply =
              match partial with
              | PAdd _ when v1 + v2 = v -> Some (Add (v1, v2))
              | PMul _ when v1 * v2 = v -> Some (Mul (v1, v2))
              | _ -> None
            in
            { premises; apply })
    | PIfFalse (e, a, e2, v) as partial -> (
        let premises =
          [
            {
              premise_formula =
                [
                  T (string_of_exp e);
                  T " ⇓ ";
                  I { value = a; typ = (); update = update_1 partial };
                ];
              premise_assumption = None;
            };
            {
              premise_formula =
                [ T (string_of_exp e2); T " ⇓ "; T (string_of_int v) ];
              premise_assumption = None;
            };
          ]
        in
        match int_of_string a with
        | exception _ -> { premises; apply = None }
        | 0 -> { premises; apply = None }
        | v -> { premises; apply = Some (IfFalse v) })
end
