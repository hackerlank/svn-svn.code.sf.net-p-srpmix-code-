(define (sxml->xhtml0 sxml)
  (cond
   ((string? sxml) (html-escape-string sxml))
   ((eq? '|@| (car sxml)) (map
			   (lambda (elt)
			      (let ((prop (car elt))
				    (val  (cadr elt)))
				 (list " " (symbol->string prop)
				       "=" (write-to-string
					    (html-escape-string val)))
				 ))
			   (cdr sxml)))
   (else 
    (let* ((tag (symbol->string (car sxml)))
	   (attrs (if (and (pair? (cdr sxml))
			   (pair? (cadr sxml))
			   (eq? (car (cadr sxml)) '|@|))
		     (cadr sxml)
		     #f))
	   (body (if attrs
		     (cddr sxml)
		     (cdr sxml))))
      (if (null? body)
	  (list "<" tag (if attrs (sxml->xhtml0 attrs) "") "/>")
	  (list "<" tag (if attrs (sxml->xhtml0 attrs) "") ">"
		(map sxml->xhtml0 body)
		"</" tag ">"))))))

(define (sxml->xhtml sxml)
  (tree->string (sxml->xhtml0 sxml)))
