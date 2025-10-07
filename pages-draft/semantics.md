## Widget test:

```model-checker
vocab DocumentsVocab {
  person/1,
  book/1,
  authorOf/2
}

axioms Documents for DocumentsVocab {

}
```

### Plan:

1. Model checking example
2. Model generation:
3. preorder vs partial order
4. less-than, where adding symmetry breaks it

### “Less than or equal to”

```model-checker
vocab V1 {le/2}

axioms A for V1 {
  refl : "all x. le(x,x)",
  trans : "all x. all y. all z. le(x,y) -> le(y,z) -> le(x,z)"
  //antisym: "all x. all y. le(x,y) -> le(y,x) -> x = y"
}

synth A size 4
```

### “Less than”

```model-checker
vocab V {
  path/2
}

axioms A for V {
  trans       : "all x.all y. all z. path(x,y) -> path(y,z) -> path(x,z)",
  irreflexive : "all x. ¬(path(x,x))",

  symmetry    : "all x. all y. path(x,y) -> path(y,x)"
//  step        : "all x. ex y. path(x,y)"
}

synth A size 4
```

### Monoid

```model-checker
vocab V { op/3, unit/1 }

axioms MONOID for V {
  defined : "all x. all y. ex z. op(x,y,z)",
  functional :
    "all x. all y. all z1. all z2.
       op(x,y,z1) -> op(x,y,z2) -> z1 = z2",
  commutative : "all x. all y. all z. op(x,y,z) -> op(y,x,z)",
  unit_defined : "ex x. unit(x)",
  unit_unique : "all x. all y. unit(x) -> unit(y) -> x = y",
  unit : "all x. all y. all z. unit(y) -> op(x,y,z) -> x = z",
  assoc1 : "all a. all b. all c. all d.
    (ex ab. op(a,b,ab) /\ op(ab,c,d)) ->
    (ex bc. op(b,c,bc) /\ op(a,bc,d))",
  assoc2 : "all a. all b. all c. all d.
    (ex bc. op(b,c,bc) /\ op(a,bc,d)) ->
    (ex ab. op(a,b,ab) /\ op(ab,c,d))",

  idem : "(all x. op(x,x,x))"
}

synth MONOID size 4
```
