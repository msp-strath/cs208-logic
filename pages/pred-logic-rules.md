# Proof rules for Predicate Logic

[Slides for the videos below (PDF)](week07-slides.pdf)

## Proof rules for “for all”

### Introduction

```
FIXME: CS208-W7P3.mp4
```

### Using the Proof Editor

```
FIXME: CS208-W7P5.mp4
```

## Proof rules for “exists”

### Introduction

```
FIXME: CS208-W7P4.mp4
```

### Using the Proof Editor

```
FIXME: CS208-W7P6.mp4
```

## Exercises

FIXME: Proof commands

From tutorial 7:
```
          li
            (nd
               F.(
                 all "x"
                   ((Atom ("p", [ Var "x" ]) && Atom ("q", [ Var "x" ]))
                   @-> Atom ("p", [ Var "x" ]))));
          li
            (nd
               F.(
                 Atom ("p", [ Fun ("a", []) ])
                 @-> ex "x" (Atom ("p", [ Var "x" ]))));
          li
            (nd
               F.(
                 all "x" (Atom ("p", [ Var "x" ]))
                 @-> Atom ("p", [ Fun ("a", []) ])));
          li
            (nd
               F.(
                 all "x" (Atom ("p", [ Var "x" ]) && Atom ("q", [ Var "x" ]))
                 @-> all "y" (Atom ("p", [ Var "y" ]))));
          li
            (nd
               F.(
                 ex "x" (Atom ("p", [ Var "x" ]) && Atom ("q", [ Var "x" ]))
                 @-> ex "z" (Atom ("p", [ Var "z" ]))));
          li
            (nd
               F.(
                 all "x"
                   (Atom ("p", [ Var "x" ])
                   @-> ex "y" (Atom ("r", [ Var "x"; Var "y" ])))
                 @-> Atom ("p", [ Fun ("a", []) ])
                 @-> ex "z" (Atom ("r", [ Fun ("a", []); Var "z" ]))))]
```

Tutorial 8
```
          li
            (nd
               F.(
                 all "x" (Not (Atom ("P", [ Var "x" ])))
                 @-> Not (ex "y" (Atom ("P", [ Var "y" ])))));
          li
            (nd
               F.(
                 ex "x" (Not (Atom ("P", [ Var "x" ])))
                 @-> Not (all "y" (Atom ("P", [ Var "y" ])))));
          li
            (nd
               F.(
                 all "x" (all "y" (Atom ("R", [ Var "x"; Var "y" ])))
                 @-> all "x" (all "y" (Atom ("R", [ Var "y"; Var "x" ])))))]
```

FIXME: some more interesting questions using a simple axiomatisation.
