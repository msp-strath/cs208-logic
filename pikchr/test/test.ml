(* Example picture from https://pikchr.org/home/doc/trunk/homepage.md *)

let input = {|
   arrow right 200% "Markdown" "Source"
   box rad 10px "Markdown" "Formatter" "(markdown.c)" fit
   arrow right 200% "HTML+SVG" "Output"
   arrow <-> down 70% from last box.s
   box same "Pikchr" "Formatter" "(pikchr.c)" fit
|}

let () =
  match Opikchr.pikchr ~src:input () with
  | Ok (text, width, height) ->
     Printf.printf "width = %d\nheight = %d\n%s\n" width height text
  | Error text ->
     Printf.printf "%s\n" text
