;;
;; scheme level utilities, no prefix
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

(define (fold2 proc initial lst)
  (if (null? lst)
      initial
      (let1 result (proc (car lst) (cdr lst) initial)
	(fold2 proc result (cdr lst)))))

(define (intersperse item lst)
  (fold2 (lambda (kar kdr result)
	   (if (null? kdr)
	       (reverse (cons kar result))
	       (cons* item kar result)))
	 (list)
	 lst))

(define (any proc lst)
  (let loop ((lst lst))
    (if (null? lst)
	#f
	(let1 r (proc (car lst))
	  (if r
	      r
	      (loop (cdr lst)))))))

(define (every proc lst)
  (let loop ((lst lst))
    (if (null? lst)
	#t
	(let1 r (proc (car lst))
	  (if r
	      (loop (cdr lst))
	      r)))))

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
(define (symbol->keyword sym)
  (string->keyword (symbol->string sym)))

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
