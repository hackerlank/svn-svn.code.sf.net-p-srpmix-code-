(define-module yogomacs.util.enum
  (export compile-enum
	  parse-enum)
  (use srfi-1)
  )

(select-module yogomacs.util.enum)

(define (parse-enum str)
  (delete "" (string-split str #\,)))

(define (compile-enum enum-spec)
  (lambda (elt)
    (member elt enum-spec)))

(provide "yogomacs/util/enum")