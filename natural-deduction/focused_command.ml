open Focused

let valid_name str =
  let is_alpha = function 'A' .. 'Z' | 'a' .. 'z' | '_' -> true | _ -> false
  and is_alphanum = function
    | 'A' .. 'Z' | 'a' .. 'z' | '0' .. '9' | '-' | '_' -> true
    | _ -> false
  in
  String.length str > 0
  && is_alpha str.[0]
  &&
  try
    String.iter (fun c -> if not (is_alphanum c) then failwith "") str;
    true
  with Failure _ -> false

let of_string = function
  | "true" -> Ok Truth
  | "split" -> Ok Split
  | "left" -> Ok Left
  | "right" -> Ok Right
  | "apply" -> Ok Implies_elim
  | "first" -> Ok Conj_elim1
  | "second" -> Ok Conj_elim2
  | "false" -> Ok Absurd
  | "not-elim" -> Ok NotElim
  | "refl" | "reflexivity" -> Ok Refl
  | "rewrite->" -> Ok (Rewrite `ltr)
  | "rewrite<-" -> Ok (Rewrite `rtl)
  | "done" -> Ok Close
  | str -> (
      (* FIXME: this is very shonky *)
      try
        Scanf.sscanf str "use %s" (fun i ->
            if not (valid_name i) then Error "need a name" else Ok (Use i))
      with _ -> (
        try
          Scanf.sscanf str "introduce %s" (fun s ->
              if not (valid_name s) then Error "need a name"
              else Ok (Introduce s))
        with _ -> (
          try
            Scanf.sscanf str "cases %s %s" (fun x y ->
                if not (valid_name x && valid_name y) then
                  Error "need two names"
                else Ok (Cases (x, y)))
          with _ -> (
            try
              Scanf.sscanf str "inst %S" (fun x ->
                  match Fol_formula.Term.of_string x with
                  | None -> Error "term not parsable"
                  | Some t -> Ok (Instantiate t))
            with _ -> (
              try
                Scanf.sscanf str "exists %S" (fun x ->
                    match Fol_formula.Term.of_string x with
                    | None -> Error "term not parsable"
                    | Some t -> Ok (Exists t))
              with _ -> (
                try
                  Scanf.sscanf str "unpack %s %s" (fun x y ->
                      if not (valid_name x && valid_name y) then
                        Error "need a name"
                      else Ok (ExElim (x, y)))
                with _ -> (
                  try
                    Scanf.sscanf str "not-intro %s" (fun x ->
                        if not (valid_name x) then Error "need a name"
                        else Ok (NotIntro x))
                  with _ -> (
                    try
                      Scanf.sscanf str "subst %s %S" (fun x y ->
                          if not (valid_name x) then Error "need a name"
                          else
                            match Fol_formula.Formula.of_string y with
                            | Error _ ->
                                Error "pattern not parsable"
                                (* FIXME: better error message *)
                            | Ok f -> Ok (Subst (x, f)))
                    with _ -> (
                      try
                        Scanf.sscanf str "induction %s" (fun s ->
                            if not (valid_name s) then Error "need a name"
                            else Ok (Induction s))
                      with _ ->
                        Error (Printf.sprintf "command '%s' not understood" str)))))))))
      )
