(define-module yogomacs.util.range
  (export compile-range
	  parse-range)
  (use util.match)
  (use srfi-1))

(select-module yogomacs.util.range)

(define (parse-range0 str)
  (rxmatch-cond
    ((#/^([1-9][0-9]*)-([1-9][0-9]*)$/ str)
     (#f start-str end-str)
     (let ((start (string->number start-str))
	   (end (string->number end-str)))
       (if (<= start end)
	   (list start end)
	   (errorf "end(~d) is greater than start(~d): ~a" start end str))))
    ((#/^([1-9][0-9]*)-$/ str)
     (#f start-str)
     (list (string->number start-str) #t))
    ((#/^-([1-9][0-9]*)$/ str)
     (#f end-str)
     (list #t (string->number end-str)))
    ((#/^-$/ str)
     (#f)
     (list #t #t))
    (else
     (errorf "broken range specification: ~s" str))))

(define (parse-range str)
  (if (equal? str "")
      (list)
      (rxmatch-if (#/([^\,]+)\,(.*)/ str)
	  (#f elt rest)
	(cons (parse-range0 elt) (parse-range rest))
	(list (parse-range0 str)))))


(define compile-range0 (match-lambda*
		    ((#t #t) (lambda (i) #t))
		    ((#t e) (lambda (i) (< i e)))
		    ((b #t) (lambda (i) (<= b i)))
		    ((b #f) (lambda (i) (eq? b i)))
		    ((b e)  (lambda (i) (and (<= b i) (< i e))))))

(define (compile-range range-spec)
  (lambda (i)
    (any (cute <> i)
	 (map (pa$ apply compile-range0)
	      range-spec))))

(provide "yogomacs/util/range")