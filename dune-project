(lang dune 3.7)
(using menhir 2.1)

(name cs208-logic)

; (generate_opam_files true)

(source
 (github msp-strath/cs208-logic))

(authors "Robert Atkey")

(maintainers "Robert Atkey")

(license GPL3)

(documentation https://url/to/documentation)

(package
 (name slakemoth))
 ; (synopsis "A tool for exploring logical modelling.")
 ; (description "A tools for exploting logical modelling.")
 ; (depends ocaml dune msat menhir)
 ; (tags
 ;  (topics "to describe" your project)))

(package
  (name site_gen))

(package
  (name frontend))

; See the complete stanza docs at https://dune.readthedocs.io/en/stable/dune-files.html#dune-project
