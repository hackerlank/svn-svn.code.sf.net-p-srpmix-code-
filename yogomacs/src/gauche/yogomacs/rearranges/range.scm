(define-module yogomacs.rearranges.range
  (export rearrange-range)
  (use sxml.tree-trans)
  (use srfi-1)
  (use yogomacs.util.range)
  (use yogomacs.rearranges.line-trim)
  )

(select-module yogomacs.rearranges.range)

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

(define (rearrange-range sxml-tree range-spec)
  (pre-post-order sxml-tree (make-line-trimmer linum-of
					       (compile-range range-spec))))

(provide "yogomacs/rearranges/range")
