open! Generalities

module Make () = struct

  let solver =
    Msat_sat.create ~store_proof:false ()

  let next_var = ref 1
  let gen () =
    let v = !next_var in
    incr next_var;
    Msat_sat.Int_lit.make v

  module Ops = struct
    type t = Msat_sat.Int_lit.t

    let neg = Msat_sat.Int_lit.neg

    let conj vs =
      let x = gen () in
      Msat_sat.assume solver
	((x :: List.map neg vs) :: List.map (fun v -> [ neg x; v ]) vs)
	();
      x

    let disj vs =
      let x = gen () in
      Msat_sat.assume solver
	((neg x :: vs) :: List.map (fun v -> [ x; neg v ]) vs)
	();
      x
  end

  include Boolean_algebra.PartialEval (Ops)

  let add_assert = function
    | True ->
      ()
    | False ->
      let v = gen () in
      Msat_sat.assume solver [ [ v ]; [ Ops.neg v ] ] ()
    | Indet v ->
      Msat_sat.assume solver [ [ v ] ] ()

  let solve () =
    match Msat_sat.solve solver with
    | Msat_sat.Unsat _ ->
      None
    | Msat_sat.Sat { eval; _ } ->
      (* Arbitrarily decide that undecided literals are false *)
      let eval v = try eval v with Msat_sat.UndecidedLit -> false in
      Some eval
end
