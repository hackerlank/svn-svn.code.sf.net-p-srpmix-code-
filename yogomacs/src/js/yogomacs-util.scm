;;
;; scheme level utilities
;;
(define (pa$ proc . args)
  (lambda rest (apply proc (append args rest))))
(define (paste thunk)
  (lambda rest (thunk)))

(define (fold proc initial lst)
  (if (null? lst)
      initial
      (let1 result (proc (car lst) initial)
	(fold proc result (cdr lst)))))

(define (any proc lst)
  (let loop ((lst lst))
    (if (null? lst)
	#f
	(let1 r (proc (car lst))
	  (if r
	      r
	      (loop (cdr lst)))))))

(define (tree->string tree)
  (cond
   ((null? tree)
    "")
   ((pair? tree)
    (string-append (tree->string (car tree))
		   (tree->string (cdr tree))))
   ((string? tree)
    tree)
   (else
    (error "wrong type given to tree->string"))))

(define (read-from-string string)
  (with-input-from-string string
    read))
(define (write-to-string exp)
  (with-output-to-string (pa$ write exp)))

;; This is workaround for brkoken scheme2js read proc.
(define (keyword->symbol key)
  (string->symbol 
   (string-append ":" 
		  (keyword->string key))))

;;(define-method ref ((list <list>) (keyword <keyword>))
;;  (get-keyword ...)
(define (kref klist key default)
  (cond
   ((null? klist) default)
   ((eq? (car klist) key) (cadr klist))
   ((and (keyword? key) 
	 (eq? (keyword->symbol key) 
	      (car klist)))
    (cadr klist))
   (else (kref (cddr klist) key default))))
