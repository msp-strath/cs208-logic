module type PRESENTATION = sig
  module Calculus : Proof_tree.CALCULUS

  val latex_of_sequent :
    (string * Calculus.assumption) list * Calculus.goal -> string

  val name_of_rule : Calculus.rule -> string
end

module Make
         (PT : Proof_tree.PROOF_TREE)
         (Presentation : PRESENTATION with module Calculus = PT.Calculus) :
sig
  val render : Format.formatter -> PT.t -> unit
end = struct
  let render_hole point _hole _last fmt =
    let assumps = PT.assumptions point in
    let formula = PT.goal point in
    Format.fprintf fmt "@[<h>%s@]"
      (Presentation.latex_of_sequent (assumps, formula))

  let render_box _assumps rendered_subtree = rendered_subtree

  let render_premises fmt = function
    | [] -> Format.pp_print_string fmt " "
    | [ x ] -> x true fmt
    | xs ->
        let rec loop fmt = function
          | [] -> ()
          | [ x ] -> x true fmt
          | x :: xs ->
              Format.fprintf fmt "%t\\\\@ " (x false);
              loop fmt xs
        in
        Format.fprintf fmt "@[<v>%a@]" loop xs

  let render_rule_application point rule rendered_premises last fmt =
    Format.fprintf fmt "@[<v>\\inferrule* [%sight=%s]@,{%a}@,{%s}@]@,"
      (if last then "R" else "r")
      (Presentation.name_of_rule rule)
      render_premises rendered_premises
      (Presentation.latex_of_sequent (PT.assumptions point, PT.goal point))

  let render fmt tree =
    PT.fold render_hole render_rule_application render_box tree false fmt
end
