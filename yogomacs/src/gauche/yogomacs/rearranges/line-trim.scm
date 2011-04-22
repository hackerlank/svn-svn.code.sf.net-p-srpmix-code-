(define-module yogomacs.rearranges.line-trim
  (export make-line-trimmer)
  (use srfi-1)
  (use yogomacs.util.sxml))

(select-module yogomacs.rearranges.line-trim)

(define (tree-delete object tree . rest)
  (let1 elt= (if (null? rest) 
		 equal?
		 (car rest))
    (let loop ((tree tree))
      (cond 
       ((null? tree) ())
       ((list? tree) (map loop (delete object tree 
				       elt=)))
       (else tree)))))

(define (make-line-trimmer candidate? trim?)
  (let1 *hidden* (gensym)
    (let1 rules (let* ((hide #f))
		  `(
		    (span *preorder* . ,(lambda (tag . all)
					  (let1 l (candidate? all)
					    (if l
						(if (trim? l)
						    (begin
						      (set! hide #f)
						      (cons tag all))
						    (begin
						      (set! hide #t)
						      *hidden*))
						(if hide 
						    *hidden*
						    (cons tag all))
						))))
		    (*text* . ,(lambda (tag str) 
				 (if hide *hidden* str)))
		    (*default* . ,(lambda x 
				    (if hide *hidden* x)))
		    ))
      `(
	(body . ,(lambda (tag . all)
		   (cons tag (tree-delete *hidden* all eq?))))
	(pre ,rules . ,list)
	,@no-touch
	))))

(provide "yogomacs/rearranges/line-trim")