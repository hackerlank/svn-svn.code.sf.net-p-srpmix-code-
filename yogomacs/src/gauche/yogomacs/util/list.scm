(define-module yogomacs.util.list 
  (export snoc
	  drop-after)
  (use srfi-1))

(select-module yogomacs.util.list)


(define (snoc rdc rac)
  (reverse (cons rac (reverse rdc))))

;; gosh> (drop-after (pa$ eq? 1) '(3 2 1 5 6))
;; (3 2 1)
(define (drop-after pred clist)
  (receive (before after) (break pred clist)
    (if (null? after)
	before
	(snoc before (car after)))))
		   
(provide "yogomacs/util/list")