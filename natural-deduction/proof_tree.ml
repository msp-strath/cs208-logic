open Sexplib0.Sexp_conv

include Proof_tree_intf

module Make (Calculus : CALCULUS) (Hole : HOLE)
 : PROOF_TREE with module Calculus = Calculus
               and module Hole     = Hole
= struct
  module Calculus = Calculus
  module Hole = Hole

  type prooftree = {
      formula : Calculus.goal;
      status : status;
    }

  and status =
    | Hole of { content : Hole.t }
    | Rule of { rule : Calculus.rule; children : proofbox list }

  and proofbox = {
      subtree : prooftree;
      assumptions : (string * Calculus.assumption) list;
    }

  type t = proofbox

  let init ?content ?(assumptions = []) goal =
    let content = match content with None -> Hole.empty | Some h -> h in
    {
      subtree = { formula = goal; status = Hole { content } };
      assumptions = assumptions;
    }

  let root_goal { subtree = { formula; _ }; _ } =
    formula

  let root_assumptions { assumptions; _ } =
    List.rev assumptions

  (* A tree 'turned inside out' to expose a particular point *)
  type steps =
    | Step of {
        formula : Calculus.goal;
        rule : Calculus.rule;
        before : proofbox list;
        assumptions : (string * Calculus.assumption) list;
        after : proofbox list;
        rest : steps;
      }
    | End of { assumptions : (string * Calculus.assumption) list }

  type point = {
    pt_formula : Calculus.goal;
    pt_context : steps;
    pt_assumptions : (string * Calculus.assumption) list;
    pt_status : status;
  }

  let up { pt_formula; pt_context; pt_assumptions; pt_status } =
    match pt_context with
    | End _ -> None
    | Step { formula; rule; before; assumptions; after; rest } ->
        let rec drop xs ys =
          match (xs, ys) with
          | [], ys -> ys
          | _ :: xs, _ :: ys -> drop xs ys
          | _, [] -> []
        in
        let box =
          {
            assumptions;
            subtree = { formula = pt_formula; status = pt_status };
          }
        in
        Some
          {
            pt_formula = formula;
            pt_context = rest;
            pt_assumptions = drop assumptions pt_assumptions;
            pt_status =
              Rule { rule; children = List.rev_append before (box :: after) };
          }

  let goal { pt_formula; _ } =
    pt_formula

  let assumptions { pt_assumptions; _ } =
    pt_assumptions

  let fold f_hole f_rule f_box t =
    let rec fold context hered_assumps { formula; status } =
      let here =
        {
          pt_formula = formula;
          pt_status = status;
          pt_context = context;
          pt_assumptions = hered_assumps;
        }
      in
      match status with
      | Hole { content } ->
         f_hole here content
      | Rule { rule; children } ->
         let rec fold_children before after accum =
           match after with
           | [] -> List.rev accum
           | ({ assumptions; subtree } as box) :: after ->
              let steps =
                Step
                  {
                    formula;
                    rule;
                    before;
                    assumptions;
                    after;
                    rest = context;
                  }
              in
              let hered_assumps = List.rev_append assumptions hered_assumps in
              let result = fold steps hered_assumps subtree in
              let result = f_box assumptions result in
              fold_children (box :: before) after (result :: accum)
         in
         let sub_results = fold_children [] children [] in
         f_rule here rule sub_results
    in
    let { assumptions; subtree } = t in
    let steps = End { assumptions } in
    let result = fold steps (List.rev assumptions) subtree in
    f_box assumptions result

  (**********************************************************************)
  (* unchecked trees *)

  type tree =
    | Hole of Hole.t
    | Rule of Calculus.rule * tree list
  [@@deriving sexp]

  let rec tree_of_status : status -> tree = function
    | Hole { content } -> Hole content
    | Rule { rule; children } ->
       Rule
         ( rule,
           List.map (fun { subtree; _ } ->
               tree_of_status subtree.status)
             children
         )

  let subtree_of_point { pt_status; _ } = tree_of_status pt_status

  let to_tree { assumptions = _; subtree = { formula = _; status } } =
    tree_of_status status

  let ( let* ) x f = match x with Ok x -> f x | Error _ as e -> e
  let lift_err = function Ok _ as x -> x | Error e -> Error (`RuleError e)

  (**********************************************************************)
  (* Tree updates *)

  let on_snd f (x, y) = (x, f y)

  (* Propagating updates through the tree *)
  let rec update_proofbox update { subtree; assumptions } =
    {
      subtree = update_prooftree update subtree;
      assumptions =
        List.map (on_snd (Calculus.update_assumption update)) assumptions;
    }

  and update_prooftree update { formula; status } =
    {
      formula = Calculus.update_goal update formula;
      status =
        (match status with
         | Hole { content } ->
            (* FIXME: update the hole's content too *)
            Hole { content }
         | Rule { rule; children } ->
            Rule { rule; children = List.map (update_proofbox update) children });
    }

  (* Focus rules:
     - at most one hole is focused.
     - Setting a hole's state focuses that hole, and unfocuses all the other holes
     - The fold tells the client if we are on the focused path?
  *)

  let reconstruct formula status update context =
    let rec reconstruct_steps subtree = function
      | Step { formula; rule; before; assumptions; after; rest } ->
         let formula = Calculus.update_goal update formula in
         let before = List.map (update_proofbox update) before in
         let assumptions =
           List.map (on_snd (Calculus.update_assumption update)) assumptions
         in
         let after = List.map (update_proofbox update) after in
         let box = { assumptions; subtree } in
         let children = List.rev_append before (box :: after) in
         let status : status = Rule { rule; children } in
         reconstruct_steps { formula; status } rest
      | End { assumptions } -> { subtree; assumptions }
    in
    reconstruct_steps { formula; status } context

  (* FIXME: return an identifier for the new hole so we can focus it *)
  let apply rule { pt_formula; pt_status = _; pt_context; pt_assumptions } =
    match Calculus.apply pt_assumptions rule pt_formula with
    | Ok (premises, update) ->
       let formula = Calculus.update_goal update pt_formula in
       let children =
         List.map
           (fun (assumptions, goal) ->
             let status : status =
               Hole { content = Hole.empty }
             in
             { assumptions; subtree = { formula = goal; status } })
           premises
       in
       Ok (reconstruct formula (Rule { rule; children }) update pt_context)
    | Error err ->
       Error (`RuleError err)


  let rec of_tree update context goal = function
    | Hole h ->
       let goal = Calculus.update_goal update goal in
       Ok ({ formula = goal; status = Hole { content = h } },
           update)
    | Rule (rule, children) ->
       let* subgoals, update' = lift_err (Calculus.apply context rule goal) in
       let update = Calculus.combine_update update update' in
       let* children, update = of_trees update context subgoals children in
       let goal = Calculus.update_goal update goal in
       Ok ({ formula = goal; status = Rule { rule; children } }, update)

  and of_trees update context goals trees =
    match (goals, trees) with
    | [], [] -> Ok ([], update)
    | (assumptions, goal) :: goals, tree :: trees ->
       let goal = Calculus.update_goal update goal in
       (* FIXME: update assumptions too *)
       let* subtree, update = of_tree update (List.rev_append assumptions context) goal tree in
       let* boxes, update = of_trees update context goals trees in
       Ok ({ subtree; assumptions } :: boxes, update)
    | _, [] | [], _ -> Error `LengthMismatch

  let insert_tree tree { pt_formula; pt_status = _; pt_context; pt_assumptions } =
    let* { status; _}, update =
      of_tree Calculus.empty_update pt_assumptions pt_formula tree
    in
    Ok (reconstruct pt_formula status update pt_context)

  let of_tree assumptions goal tree =
    let* prooftree, update =
      of_tree Calculus.empty_update (List.rev assumptions) goal tree
    in
    (* Propagate upadtes backwards *)
    let prooftree = update_prooftree update prooftree in
    Ok { assumptions; subtree = prooftree }

  let set_hole content { pt_formula; pt_context; _ } =
    let status : status = Hole { content } in
    reconstruct pt_formula status Calculus.empty_update pt_context
end
