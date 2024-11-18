module Make (C : Proof_tree.CALCULUS with type update = unit) = struct

  type goal_item =
    { assumptions : (string * C.assumption) list
    ; goal        : C.goal
    }

  type stack = goal_item list

  let is_empty = function
    | []   -> true
    | _::_ -> false

  let init assumptions goal =
    [ { assumptions; goal } ]

  let apply rule : stack -> _ = function
    | [] ->
       Error `Empty_goal_stack
    | { assumptions; goal } :: tail ->
       (match C.apply assumptions rule goal with
        | Error rule_error ->
           Error (`Rule_error rule_error)
        | Ok (subgoals, ()) ->
           (* FIXME: propagate updates through the tail *)
           let subgoals =
             List.map
               (fun (new_assumps, goal) ->
                 { assumptions = List.rev_append new_assumps assumptions
                 ; goal
               })
               subgoals
           in
           Ok (subgoals @ tail))

  let pop : stack -> _ = function
    | [] ->
       Error `Empty_goal_stack
    | g::goals ->
       Ok (g, goals)

end
