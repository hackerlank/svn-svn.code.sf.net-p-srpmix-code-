(define ($ elt)
  ((js-field *js* "$") elt))
(define ($$ elt)
  ((js-field *js* "$$") elt))
(define (<- elt)
  ((js-field *js* "$F") elt))
(define (-> val elt)
  (let1 field ($ elt)
    (field.setValue val)))

(define (html-escape-string str)
  (str.escapeHTML))

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

(define meta-variables (make-hashtable))
(define (read-meta name)
  (cond
   ((hashtable-contains? meta-variables name)
    (hashtable-get meta-variables name))
   ((null? ($ name))
    (let1 metas (vector->list ($$ "meta"))
      (let loop ((metas metas))
	(if (null? metas)
	    #f
	    (if (equal? (js-field (car metas) "name") name)
		(let1 data (read-from-string (js-field (car metas) "content"))
		  (begin
		    (hashtable-put! meta-variables name data)
		    data))
		(loop (cdr metas)))))))
   (else
    (let1 elt ($ name)
      (let* ((data (read-from-string elt.innerHTML)))
	(hashtable-put! meta-variables name data)
	(elt.remove)
	data)))))

(define (contents-url)
  (let* ((location (js-field *js* "location"))
	 (pathname (js-field location "pathname")))
    (substring pathname
	       (string-length shell-dir)
	       (string-length pathname))))