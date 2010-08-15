#!/bin/sh
#| -*- scheme -*- |#
:; exec gosh -- $0 "$@"

(use gauche.test)
(define *test-report-error* #t)
(test-start "Yogomacs range test")

(use yogomacs.utils.range)

(test* "range12"
       '((1 2))
       (parse-range "1-2"))

(test* "range1-"
       '((1 #t))
       (parse-range "1-"))

(test* "range-3"
       '((#t 3))
       (parse-range "-3"))

(test* "multiragen1"
       '((1 3) (4 9) (10 30))
       (parse-range "1-3;4-9;10-30"))
(test* "multiragen1;"
       '((1 3) (4 9) (10 30))
       (parse-range "1-3;4-9;10-30;"))
(test* "multiragen;1"
       '((1 3) (4 9) (10 30))
       (parse-range ";1-3;4-9;10-30"))
(test* "multiragen1#t"
       '((1 3) (4 #t) (10 30))
       (parse-range ";1-3;4-;10-30"))

(test* "make-range1"
                    '(#f #t #t #f)
       (let ((input '( 9 10 29 30))
	     (proc (compile-range (parse-range "10-30"))))
	 (map proc input)))

(test* "make-range2"
                    '(#f #t #t #f #f #f #t #f #f #t #t #f #t #t)
       (let ((input '( 0  1  2  3  4  6  7  8  9 10 29 30 33 39))
	     (proc (compile-range (parse-range ";1-3;7-8;10-30;33-"))))
	 (map proc input)))

(exit (if (zero? (test-end)) 0 1))