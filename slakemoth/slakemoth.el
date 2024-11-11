;; based on: http://ergoemacs.org/emacs/elisp_syntax_coloring.html

;; define several class of keywords
(setq slakemoth-keywords  '("define" "table"
			    "domain"
			    "atom"
			    "print" "ifsat" "allsat" "dump"
			    "forall" "some" "next"
			    "for" "the" "if"))
(setq slakemoth-equality  '())
(setq slakemoth-operators '("==>" "&" "|" "!" "~" "=" "!=" ))
(setq slakemoth-types     '())

;; create the regex string for each class of keywords
(setq slakemoth-keywords-regexp  (regexp-opt slakemoth-keywords  'words))
(setq slakemoth-equality-regexp  (regexp-opt slakemoth-equality 'words))
(setq slakemoth-operators-regexp (regexp-opt slakemoth-operators))
(setq slakemoth-types-regexp     (regexp-opt slakemoth-types     'words))

;; clear memory
(setq slakemoth-keywords  nil)
(setq slakemoth-equality  nil)
(setq slakemoth-operators nil)
(setq slakemoth-types     nil)

;; create the list for font-lock.
;; each class of keyword is given a particular face
(setq slakemoth-font-lock-keywords
  `(
    (,slakemoth-types-regexp     . font-lock-type-face)
    (,slakemoth-equality-regexp  . font-lock-keyword-face)
    (,slakemoth-operators-regexp . font-lock-builtin-face)
    (,slakemoth-keywords-regexp  . font-lock-keyword-face)
))

;; syntax table
(defvar slakemoth-syntax-table nil "Syntax table for `slakemoth-mode'.")
(setq slakemoth-syntax-table
  (let ((synTable (make-syntax-table)))

    ;; Java/C++ style '//' comments
    (modify-syntax-entry ?/ ". 12b" synTable)
    (modify-syntax-entry ?\n "> b" synTable)

    ;; Symbols
    (modify-syntax-entry ?_ "w" synTable)
    (modify-syntax-entry ?- "w" synTable)

    synTable))

;; define the mode
(define-derived-mode slakemoth-mode fundamental-mode
  "Slakemoth mode"
  ;; handling comments
  :syntax-table slakemoth-syntax-table
  (setq-local comment-start "//")
  (setq-local comment-end "")
  ;; code for syntax highlighting
  (setq font-lock-defaults '((slakemoth-font-lock-keywords)))
  (setq mode-name "slakemoth")
  ;; clear memory
  (setq slakemoth-keywords-regexp nil)
  (setq slakemoth-types-regexp nil)
)

(provide 'slakemoth-mode)
