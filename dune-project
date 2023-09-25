(lang dune 3.7)
(using menhir 2.1)

(name traintor)

; (generate_opam_files true)

(source
 (github bobatkey/sat-widget))

(authors "Robert Atkey")

(maintainers "Robert Atkey")

(license GPL3)

(documentation https://url/to/documentation)

(package
 (name traintor)
 (synopsis "A tool for exploring logical modelling.")
 (description "A tools for exploting logical modelling.")
 (depends ocaml dune msat menhir fmt)
 (tags
  (topics "to describe" your project)))

; See the complete stanza docs at https://dune.readthedocs.io/en/stable/dune-files.html#dune-project
