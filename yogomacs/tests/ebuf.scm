#!/bin/sh
#| -*- scheme -*- |#
:; exec gosh -- $0 "$@"

(use gauche.test)
(define *test-report-error* #t)
(test-start "Yogomacs ebuf test")

(use yogomacs.ebuf)
(define ebuf0 (make <ebuf>))
(insert! ebuf0 "abc\ndef\nghi\n")

(define-macro (v->c x) `(receive (a b) ,x (list a b)))
(test* "ebuf-0" '(#f #f) (v->c (line-for ebuf0 0)))
(test* "ebuf-a" '(1 0) (v->c (line-for ebuf0 1)))
(test* "ebuf-b" '(1 1) (v->c (line-for ebuf0 2)))
(test* "ebuf-c" '(1 2) (v->c (line-for ebuf0 3)))
(test* "ebuf-N0" '(2 0) (v->c (line-for ebuf0 4)))
(test* "ebuf-d" '(2 1) (v->c (line-for ebuf0 5)))
(test* "ebuf-e" '(2 2) (v->c (line-for ebuf0 6)))
(test* "ebuf-f" '(2 3) (v->c (line-for ebuf0 7)))

(test* "ebuf-N1" '(3 0) (v->c (line-for ebuf0 8)))
(test* "ebuf-g" '(3 1) (v->c (line-for ebuf0 9)))
(test* "ebuf-h" '(3 2) (v->c (line-for ebuf0 10)))
(test* "ebuf-i" '(3 3) (v->c (line-for ebuf0 11)))
;;
(test* "ebuf-N2" '(4 0) (v->c (line-for ebuf0 12)))
;; ???
(test* "ebuf-O" '(4 1) (v->c (line-for ebuf0 13)))
(test* "ebuf-OO" '(#f #f) (v->c (line-for ebuf0 14)))

(insert! ebuf0 "abc\ndef\nabc\n")
(test* "ebuf-search1" 1 (let1 i (search-forward ebuf0 "abc" 0) 
			 (line-for ebuf0 (+ i 1))))
(test* "ebuf-search2" 2 (let1 i (search-forward ebuf0 "def" 0)
			 (line-for ebuf0 (+ i 1))))
(test* "ebuf-search11" 3 (let1 i (search-forward ebuf0 "abc" 0)
			   (let1 j (search-forward ebuf0 "abc" (+ i 1))
			     (line-for ebuf0 (+ j 1)))))
(test* "ebuf-search111" #f (let1 i (search-forward ebuf0 "abc" 0)
			 (let1 j (search-forward ebuf0 "abc" (+ i 1))
			   (let1 h (search-forward ebuf0 "abc" (+ j 1))
			     h))))
(test* "ebuf-search111_" #f (let1 i (search-forward ebuf0 "abc" 0)
			     (let1 j (search-forward ebuf0 "abc" (+ i 1))
			       (let1 h (search-forward ebuf0 "abc" (+ j 1))
				 ;; DIRTY
				 (line-for ebuf0 h)))))

(test* "ebuf-search_" #f (let1 i (search-forward ebuf0 "xxx" 0)
			   ;; DIRTY
			   (line-for ebuf0 i)))
			 
(exit (if (zero? (test-end)) 0 1))