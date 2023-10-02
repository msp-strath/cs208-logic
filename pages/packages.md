[Contents](contents.html)

# Package Installation Problem

We now look at a more realistic example of logical modelling: using logic to solve the problem of computing correct installations of packages on a computer system.

We have to take into account that multiple versions of the same software package cannot be installed at the same time, and that installing some packages may require other packages to be installed. By expressing these constraints as logical formulas, we can make sure that all satisfying valuations represent feasible installations.

## Video

The following video introduces the Package Installation Problem, and shows how to encode it in logic:

```youtube
uNVSbLVh_kM
```

[The slides for this video](week02-slides.pdf) (mixed in with the SAT solver slides for now).

## Example

Let's do the following example:

1. We have two programs `progA` and `progB`, where `progA` comes in two versions `1` and `2` and `progB` has one version. We declare these as atoms using code like this:

   ```
   atom progA1
   atom progA2
   atom progB
   ```

2. There are two libraries `libC` and `libD`, where `libC` comes in two version `1` and `2` and `libD` has one version. This means that we have three more atoms:

   ```
   atom libC1
   atom libC2
   atom libD
   ```

3. We encode the fact that the two version of `progA` and `libC` are incompatible by using a "not both of these" constraint, as we saw in the [patterns](patterns.html):

   ```
   define incompatibilities {
      (~progA1 | ~progA2) & (~libC1 | ~libC2)
   }
   ```

   This says two constraints must hold:

   1. We cannot have both `progA1` and `progA2`
   2. We cannot have both `libC1` and `libC2`

4. We assume the following dependencies:

   1. `progA1` depends on `libC1`
   2. `progA2` depends on `libC2`
   3. `progB` depends on `libC2`
   4. `libC2` depends on `libD`

   Each of these is encoded as an "if this then that" [pattern](patterns.html) by saying that either the thing isn't installed, or the thing it depends on is:

   ```
   define dependencies {
	   (~progA1 | libC1) // progA1 depends on libC1
	 & (~progA2 | libC2)
	 & (~progB  | libC2)
	 & (~libC2  | libD)
   }
   ```

5. Finally, we have some requirements, we must install some version of `progA` and `progB`. This uses the "at least one" [pattern](patterns.html) to encode "at least one version of `progA`". (There is only one version of `progB`, so we just add the constraint that it must be true.)

   ```
   define requirements {
     (progA1 | progA2) & progB
   }
   ```

The computer's job is to find out whether or not there is a set of packages to install that satisfies all the above constraints. It does this by finding out whether or not the formula `conflicts & dependencies & requirements` is satisfiable. If there it, then we know that there is a package installation plan such that (a) no conflicting packages will be installed; (b) all packages' dependencies will be met; and (c) all the required packages are installed.

### Putting it all together

Let us put all the above constraints together in a script, and add a command to get the computer to check whether or not there is a solution to the above constraints:

```lmt
atom progA1
atom progA2
atom progB
atom libC1
atom libC2
atom libD

define incompatibilities {
    (~progA1 | ~progA2)
  & (~libC1 | ~libC2)
}

define dependencies {
    (~progA1 | libC1) // progA1 depends on libC1
  & (~progA2 | libC2)
  & (~progB  | libC2)
  & (~libC2  | libD)
}

define requirements {
    (progA1 | progA2)
  & progB
}

ifsat (incompatibilities &
       dependencies &
       requirements)
{
  "progA1": progA1,
  "progA2": progA2,
  "progB": progB,
  "libC1": libC1,
  "libC2": libC2,
  "libD": libD
}
```

Have a go at changing the above constraints to see whether or not it is possible to solve the problem if we insist on installing version `1` of `progA`. You can do this by ANDing (`&`) the constraint `progA1` to the requirements. Why is it not possible to solve the problem in this case?

## Further reading

1. The original source for logical modelling of the Package Installation Problem is the paper "[OPIUM: Optimal Package Install/Uninstall Manager](http://cseweb.ucsd.edu/~lerner/papers/opium.pdf)" by Tucker, Shuffelton, Jhala, and Lerner. The paper also describes some refinements, such as how to minimise solutions in terms of number of packages or size of downloads. Some experimental results are also given.

2. The post [Version SAT](https://research.swtch.com/version-sat) by Russ Cox, a member of the Google Go team, explains how to encode *any* NP problem (see [SAT Solver](sat.html) for what NP means) into a package installation problem. This means that solving a package installation problem may be very hard indeed (for the computer) in the general case.

---

[Contents](contents.html)
