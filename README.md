# CS208 Logic

This repository contains the sources for the course materials for the Logic part of the course CS208 *Logic and Algorithms*. The sources comprise the [markdown sources](pages/), the [site generator](site_gen/main.ml), LaTeX Beamer [sources for the lecture slides](slides/), and OCaml code for the interactive theorem prover and sat solver widgets.

A live version of the course is hosted at [https://personal.cis.strath.ac.uk/robert.atkey/cs208/contents.html](https://personal.cis.strath.ac.uk/robert.atkey/cs208/contents.html). See there for more information about the course content.

## Building the site

The easiest way to build the complete site is to use Nix, with `flakes` and `nix-command` enabled. Then you should be able to use this command to build a complete copy of the site as a set of HTML pages ready to be served:

```shell
$ nix build github:msp-strath/cs208-logic#site
```

The generated site will be in a directory linked to as `result` in the current working directory.

If you have not enabled `flakes` and `nix-command` in your Nix installation, you can temporarily enable them for this command with extra argument to the `nix` command like so:

```shell
$ nix --extra-experimental-features nix-command --extra-experimental-features flakes build github:msp-strath/cs208-logic#site
```

## Developing the site

If you wish to contribute to the development of the site, or just to see how it works, you can also use `nix` to set up a complete development enivronment. Cloning the repository, `cd`ing into the directory, and issuing the command:

```shell
$ nix develop
```

ought to set up a development environment with OCaml, all the required OCaml libraries, enough TeXLive to build the slides, and the OCaml Language Server and Utop. Once the development environment is set up, you can use `make` to build a local copy of the site in the `_site` directory.
