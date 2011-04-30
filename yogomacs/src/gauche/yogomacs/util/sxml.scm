(define-module yogomacs.util.sxml
  (export get-meta-from-shtml
	  no-touch
	  install-meta)
  (use util.list)
  (use sxml.sxpath)
  (use sxml.tree-trans)
  (use srfi-1)
  )

(select-module yogomacs.util.sxml)

(define (get-meta-from-shtml shtml var-name default)
  (read-from-string (or ((sxpath `(// html head meta |@| ,(lambda (node root vars)
							    (any (lambda (elt)
								   (and-let* ((attrs (cdr elt))
									      (name (car (assq-ref attrs 'name '(#f))))
									      ( (equal? name var-name) )
									      (content (car (assq-ref attrs 'content '(#f)))))
								     content)) node)))) shtml)
			(write-to-string default))))

(define no-touch `((*text* . ,(lambda (tag str) str))
		   (*default* . ,(lambda x x))))

(define (install-meta sxml . rest)
  (let1 metas (append-map (lambda (elt)
			    `((meta (|@|
				     (name ,(keyword->string (car elt)))
				     (content ,(write-to-string (cadr elt)))))
			      "	"
			      "\n"))
			  (slices rest 2))
    (pre-post-order sxml
		    `((head . ,(lambda (tag . rest)
				 (cons tag (append metas rest))))
		      ,@no-touch))))

(provide "yogomacs/util/sxml")
