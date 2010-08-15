(define-module yogomacs.rearranges.range
  (export rearrange-range)
  (use sxml.tree-trans)
  (use srfi-1)
  (use yogomacs.utils.range))

(select-module yogomacs.rearranges.range)

(define (id . args) args)

(define linum-regex #/L:([0-9]+)/)
(define (linum-of line)
  (and-let* (( (not (null? line)) )
	     (attrs (car line))
	     ( (not (null? attrs)) )
	     ( (eq? (car attrs) '|@|) )
	     (class-value (assq 'class (cdr attrs)))
	     ( (equal? "linum" (cadr class-value)) )
	     (id-value (assq 'id (cdr attrs)))
	     (match (linum-regex (cadr id-value)))
	     (line-str (match 1)))
    (string->number line-str)))

(define (delete* object tree . rest)
  (let1 elt= (if (null? rest) 
		 equal?
		 (car rest))
    (let loop ((tree tree))
      (cond 
       ((null? tree) ())
       ((list? tree) (map loop (delete object tree 
				       elt=)))
       (else tree)))))

(define (make-trimmer range)
  (let1 rules (let* ((hide #f))
		`(
		  (span *preorder* . ,(lambda (tag . all)
					(let1 l (linum-of all)
					  (if l
					      (if (range l)
						  (begin
						    (set! hide #f)
						    (cons tag all))
						  (begin
						    (set! hide #t)
						    '*hidden*))
					      (if hide 
						  '*hidden*
						  (cons tag all))
					      ))))
		  (*text* . ,(lambda (tag str) 
			       (if hide '*hidden* str)))
		  (*default* . ,(lambda x 
				  (if hide '*hidden* x)))
		  ))
    `(
      (body . ,(lambda (tag . all)
		 (cons tag (delete* '*hidden* all eq?))))
      (pre ,rules . ,id)
      (*text* . ,(lambda (tag str) str))
      (*default* . ,id)
      )))

(define (rearrange-range sxml-tree range-spec)
  (pre-post-order sxml-tree (make-trimmer (compile-range range-spec))))


	      
(provide "yogomacs/rearranges/range")
