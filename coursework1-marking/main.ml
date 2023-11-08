(* Plan:

   - Load in the .answers file and the specimen solutions

   - For each question, do a parse of the answer, and then compare the output to the specimen

   - If the answer matches the specimen one, then

 *)

let read_answers_file filename =
  In_channel.with_open_text filename
    (fun ch ->
      Seq.of_dispenser
        (fun () -> In_channel.input_line ch)
      |> Seq.map
           (fun line ->
             Scanf.sscanf line "%s@:%S" (fun fieldname data -> fieldname, data))
      |> List.of_seq)


let () =
  let filename = Sys.argv.(1) in
  let details = read_answers_file filename in
  List.iter (fun (f,d) -> Printf.printf "%s = %S\n" f d) details
