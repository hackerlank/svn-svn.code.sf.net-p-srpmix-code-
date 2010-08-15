(define-module yogomacs.rearranges.enum
  (export rearrange-enum)
  (use sxml.tree-trans)
  (use srfi-1)
  (use yogomacs.util.enum)
  (use yogomacs.rearranges.line-trim)
  )

(select-module yogomacs.rearranges.enum)

(define linum-regex #/N:(.+)/)
(define (name-of line)
  (and-let* (( (not (null? line)) )
	     (attrs (car line))
	     ( (not (null? attrs)) )
	     ( (eq? (car attrs) '|@|) )
	     (class-value (assq 'class (cdr attrs)))
	     ( (equal? "linum" (cadr class-value)) )
	     (id-value (assq 'id (cdr attrs)))
	     (match (linum-regex (cadr id-value))))
    (match 1)))

(define (rearrange-enum sxml-tree enum-spec)
  (pre-post-order sxml-tree (make-line-trimmer name-of
					       (compile-enum enum-spec))))

(provide "yogomacs/rearranges/enum")
