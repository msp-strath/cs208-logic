[Contents](contents.html)

# How to handle bigger problems?

So far, we have defined our logical modelling problems in terms of three parts:

1. Atoms, which are used to name the true/false values used to represent solutions:

   ```
   atom a
   atom b
   atom c
   ```

2. Definitions, which are used to name constraints:

   ```
   define my_constraint {
     a | b | c
   }
   ```

3. Commands, which are used to get the computer to find solutions to the constraints we give it. Either we ask for one solution:

   ```
   ifsat (my_constraint) { "a" : a, "b" : b, "c": c }
   ```

   Or all solutions:

   ```
   allsat (my_constraint) { "a" : a, "b" : b, "c" : c }
   ```

## Can we do large problems?

*Theoretically*, the above parts are enough for us to describe any problem that a SAT solver can solve, and to present the results. *Practically*, however, it is difficult to write out any problems that are larger than the small example we used for the [package installations](package.html].

There are three main problems that get in the way of doing larger examples:

1. For larger problems the number of atoms becomes unmanagable because we have to list them all out. What happens if we have
2. Partly because there are so many atoms, the constraints we define become very repetitive if we have to list them all out. For example, if a package has `15` versions, none of which can be installed simultaneously, then we need to write out at least `120` clauses to express this constraint.

We will solve these problems by allowing atoms and constraint definitions to be parameterised by values we use to represent elements of the problem domain.

## Domains

The first new feature we add is **domains**. A domain is a collection of values, similar to `enum` or `Enumeration` types in programming languages. Each value in a domain starts with a capital letter (this is so that the tool can distinguish names for domain values from variable and definition names).

For example, we could list all the package/version pairs for a particular instance of the package installation problem like this:

```
domain package_with_version { ProgA1, ProgA2, ProgB, LibC1, LibC2, libD1, libD2, libE }
```

Or we could separately list the individual package names:

```
domain package { ProgA, ProgB, LibC, LibD, LibE }
```

and the possible version numbers:

```
domain version { V1, V2 }
```

## Parameterised Atoms

Once we have declared some domains, we can use them to parameterise our atoms and definitions. This way, we can make one atom declaration where before we had to make many.

For the package installation problem, we declare a parameterised atom `installed`, which takes the package and version as parameters:

```
atom installed(p : package, v : version)
```

This is effectively the same as if we had defined many atoms `installed(ProgA, V1)`, `installed(ProgA,V2)`, `installed(ProgB,V1)`, `installed(ProgB,V2)`, ... . Except now, it is easier to extend with more packages and possible versions.

It is important to keep in mind that we have not increased the power of the modelled tool by doing this, only the ease by which we can define large amounts of atoms. It is always possible to expand out any parameterised declaration or definition to their non-parameterised counterparts.

## Parameterised Definitions

Just as we can parameterise atom declarations, we can also parameterise constraint definitions. This allows us to use meaningful names for patterns of constraints that we use over and over again.

For example, for any package-with-version, we can declare its dependency on another package-with-version like so by using the following definition that is parameterised by the two package/version pairs involved:

```
define depends(p : package, v : version, p2 : package, v2 : version) {
  ~installed(p, v) | installed(p2, v2)
}
```

By itself, this definition doesn't define any constraints. We do so by calling it with concrete values, like so:

```
define dependencies() {
  depends(ProgA, V1, LibC, V1) &
  depends(ProgA, V2, LibC, V2) &
  depends(ProgB, V1, LibC, V2) &
  depends(LibC,  V2, LibD, V1)
}
```

This is the same as if we had written out all the constraints by hand, as we did before:

```
define dependencies() {
  (~installed(ProgA, V1) | installed(LibC, V1)) &
  (~installed(ProgA, V2) | installed(LibC, V2)) &
  (~installed(ProgB, V1) | installed(LibC, V2)) &
  (~installed(libC,  V2) | installed(LibD, V1))
}
```

## Definitions with Quantifiers

Parameterising definitions also allows us to use *quantifiers* to generate large constraints by `|`ing or `&`ing together other constraints.

### For some...

The first quantifier is `some(x : domainname) P`. This is a constraint that states that "for *some* value `x` of the domain `domainname`, the formula `P` must be true". An expression like this is expanded into a number of formulas all `|`d together: exactly expressing "some" to mean "at least one".

For example, we can say that some version of `ProgA` should be installed by the following definition:

```
define requirements {
  some(v : version)
    installed(ProgA, v)
}
```

is the same as writing:

```
define requirements {
  installed(ProgA, V1) | installed(ProgA, V2)
}
```

with the additional benefit that if we extended the domain of possible version numbers (to add `V3`, for example), then the list of literals `|`d together will be automatically extended.

### For all...

The complementary quantifier to `some` is `forall`.

The expression `forall(x : domainname) P` means "for *all* values `x` of the domain `domainname`, the formula `P` must be true". An expression like this is expanded into a number of formulas all `&`d together: exactly expressing "forall" to mean "this and this and this and ...".

For example, we could define a constraint that says we want all packages to be installed, each at some version:

```
define allpackages {
  forall(p : package) some(v : version) installed(p,v)
}
```

This expands to:

```
define allpackages {
  (installed(ProgA, V1) | installed(ProgA, V2)) &
  (installed(ProgB, V1) | installed(ProgB, V2)) &
  ...
}
```

A more complex example is a definition that defines the constraint that no package is installed at two different versions:

```
define incompatibilities {
  forall(p : package)
    forall(v1 : version)
      forall(v2 : version)
        v1 = v2 | ~installed(p, v1) | ~installed(p, v2)
}
```

In words: for all packages `p`, and all version pairs `v1`, `v2`, either `v1` and `v2` are equal, or `v1` is not installed, or `v2` is not installed. Try to convince yourself that this gives the right definitions in the end.

## Outputs

Finally, we need a way of printing out the solutions to the constraints. The `ifsat` and `allsat` commands all the use of `for(x : domainname)` to

```
ifsat(dependencies & requirements & incompatibilities)
  { for(packageName : package)
     packageName :
       [ for(v : version)
          if(installed(packageName,v))
            v
       ]
  }
```

We read this as, if the constraints are satisfiable:

1. Create a record `{` ... `}`, containing:
2. for each `packageName` in `packages`, a field with name `packageName` and value:
3. a list `[` ... `]` containing:
4. the version `v` for which `installed(packageName,v)` is true.

## Putting it all together

The following script puts everything above together to show how to use domains, parameters, and quantifiers to define larger scale problems with less repetition:

```lmt {id=packages-with-domains}
domain package { ProgA, ProgB, LibC, LibD, LibE }

domain version { V1, V2 }

atom installed(p : package, v : version)

define depends(p : package, v : version, p2 : package, v2 : version) {
  ~installed(p, v) | installed(p2, v2)
}

define dependencies() {
  depends(ProgA, V1, LibC, V1) &
  depends(ProgA, V2, LibC, V2) &
  depends(ProgB, V1, LibC, V2) &
  depends(LibC,  V2, LibD, V1)
}

define requirements {
  some(v : version)
    installed(ProgA, v)
}

define incompatibilities {
  forall(p : package)
    forall(v1 : version)
      forall(v2 : version)
        v1 = v2 | ~installed(p, v1) | ~installed(p, v2)
}

ifsat(dependencies & requirements & incompatibilities)
  { for(packageName : package)
     packageName :
       [ for(v : version)
          if(installed(packageName,v))
            v
       ]
  }
```

---

[Contents](contents.html)
