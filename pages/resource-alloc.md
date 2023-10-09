[Contents](contents.html)

# Resource Allocation Problems

```lmt
domain colour { Red, Green, Blue }
domain node { N1, N2, N3, N4, N5 }

atom is_colour(n : node, c : colour)

define all_nodes_some_colour {
  forall(n : node) some(c : colour) is_colour(n, c)
}

define one_colour(n : node) {
  forall(c1 : colour)
    forall(c2 : colour)
      (c1 = c2 | ~is_colour(n,c1) | ~is_colour(n,c2))
}

// dump(all_nodes_some_colour)
// dump(one_colour(N1))

define conflict(n1 : node, n2 : node) {
  forall(c : colour) ~is_colour(n1, c) | ~is_colour(n2,c)
}

define main() {
    all_nodes_some_colour
  & (forall (n : node) one_colour(n))
  & conflict(N1,N2)
  & conflict(N2,N3)
  & conflict(N4,N5)
  & conflict(N1,N3)
  & conflict(N1,N5)
  & conflict(N5,N3)
//  & conflict(N5,N2)
}

ifsat(main)
  { for (n : node)
      n:[for (c : colour)
           if (is_colour(n,c))
             c
        ]
  }

```

---

[Contents](contents.html)
