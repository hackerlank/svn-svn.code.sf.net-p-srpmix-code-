#!/bin/sh
#| -*- scheme -*- |#
:; exec gosh -- $0 "$@"

(use gauche.test)
(define *test-report-error* #t)
(test-start "Yogomacs enum test")

(use yogomacs.util.enum)

(test* "parse enum"
       '("ax" "by" "." "..")
       (parse-enum "ax,by,.,.."))

(test* "compile enum"
       '(#t #t #t #t #f)
       (let1 proc (compile-enum (parse-enum "ax,by,.,.."))
	 (map boolean
	      (list (proc "ax") (proc "by")  (proc ".")  (proc "..")  (proc "cz")))))

(exit (if (zero? (test-end)) 0 1))