(define-module yogomacs.major-mode
  (export normalize-major-mode
	  )
  (use srfi-13)
  (use util.list)
  (use sxml.sxpath)
  (use yogomacs.util.sxml)
  )

(select-module yogomacs.major-mode)

(define (normalize-major-mode major-mode)
  (let1 major-mode (string-downcase major-mode)
    (assoc-ref '(
		 ("cpp-mode"  . "c++-mode")
		 ("spec-mode" . "rpm-spec-mode")
		 ("yacc-mode" . "bison-mode")
		 ("lex-mode"  . "flex-mode")
		 ("make-mode" . "makefile-mode")
		 )
	       major-mode
	       major-mode)))

(provide "yogomacs/major-mode")
