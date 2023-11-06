(lang dune 3.7)
(using menhir 2.1)

(name slakemoth)

; (generate_opam_files true)

(source
 (github bobatkey/interactive-logic-course))

(authors "Robert Atkey")

(maintainers "Robert Atkey")

(license GPL3)

(documentation https://url/to/documentation)

(package
 (name slakemoth))
 ; (synopsis "A tool for exploring logical modelling.")
 ; (description "A tools for exploting logical modelling.")
 ; (depends ocaml dune msat menhir fmt)
 ; (tags
 ;  (topics "to describe" your project)))

(package
  (name fol_formula))

(package
  (name parser_util))

(package
  (name pikchr))

; See the complete stanza docs at https://dune.readthedocs.io/en/stable/dune-files.html#dune-project
