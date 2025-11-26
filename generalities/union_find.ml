type 'a class_data =
  | Root of { rank : int; value : 'a }
  | Node of 'a point

and 'a point =
  'a class_data ref

let make_class value =
  ref (Root { rank = 0; value })

let rec get_root point =
  match !point with
  | Root { rank; value } ->
     (point, rank, value)
  | Node parent ->
     let root, rank, value = get_root parent in
     point := (Node root);
     (root, rank, value)

let find point =
  let _, _, a = get_root point
  in a

let union f x y =
  let x_root, x_rank, x_value = get_root x in
  let y_root, y_rank, y_value = get_root y in
  let value = f x_value y_value in
  if x_rank > y_rank then
    (y_root := (Node x_root);
     x_root := (Root { rank = x_rank; value }))
  else if x_rank < y_rank then
    (x_root := (Node y_root);
     y_root := (Root { rank = y_rank; value }))
  else if x_root != y_root then
    (y_root := (Node x_root);
     x_root := (Root { rank = x_rank + 1; value }))
  else
    (x_root := (Root { rank = x_rank; value }))

let update f x =
  let root, rank, value = get_root x in
  root := (Root { rank; value = f value })

let equal x y =
  let x_root, _, _ = get_root x in
  let y_root, _, _ = get_root y in
  x_root == y_root
