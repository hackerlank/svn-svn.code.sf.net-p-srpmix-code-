(define-module callq.util)
(select-module callq.util)

(export when-let1)
(define-macro (when-let1 var expr . then)
  `(if-let1 ,var ,expr
     (begin ,@then)))

(export dbind)
(define-macro (dbind spec vals . body)
  `(apply (lambda ,spec
	    ,@body)
	  ,vals))

(export hash-table-get0)
(define-macro (hash-table-get0 ht key default)
  (let ((r (gensym))
	(d (gensym))
	(t (gensym)))
    `(let1 ,r (hash-table-get ,ht ,key ',d)
       (if (eq? ,r ',d)
	   (let1 ,t  ,default
	     (hash-table-put! ,ht ,key ,t)
	     ,t)
	   ,r))))

(export kref)
(define (kref klist keyword :optional (default #f))
  (if-let1 r (memq keyword klist)
    (cadr r)
    default))

(export kset!)
(define (kset! klist keyword value)
  (when-let1 r (memq keyword klist)
    (set! (ref cadr) value)))

;(dbind (a :key x y) '(3 :x 4 :y 5)
;       (list a x y))

(export map2)
(define (map2 proc seq last)
  (if (null? seq)
      seq
      (map proc
	   seq
	   (let1 r (reverse (cdr seq))
	     (reverse (cons (if (procedure? last)
				(last (car seq))
				last) r))))))


(export writeln)
(define (writeln x)
  (write x)
  (newline))


(provide "callq/util")
