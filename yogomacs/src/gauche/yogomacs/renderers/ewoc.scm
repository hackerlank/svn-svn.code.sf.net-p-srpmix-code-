(define-module yogomacs.renderers.ewoc
  (export <ewoc>
	  render-entries
	  title-of
	  meta-tags-of
	  faces-and-styles-of
	  render-entries
	  render-entry
	  href-id-of
	  )
  (use yogomacs.entry)
  (use yogomacs.face)
  ;;
  (use srfi-1)
  (use gauche.sequence)
  )


(select-module yogomacs.renderers.ewoc)


(define-class <ewoc> ()
  (
   ))

(define-method title-of ((ewoc <ewoc>))
  "NO TITLE"
  )

(define-method meta-tags-of ((ewoc <ewoc>))
  (list))

(define-method faces-and-styles-of ((ewoc <ewoc>))
  (list))

(define-method href-id-of ((ewoc <ewoc>) 
			   (entry <entry>)
			   (index <integer>))
  "?"
  )

(define-method render-prefix ((ewoc <ewoc>)
			      (entry <entry>)
			      (index <integer>)
			      (linum-column <integer>))
  (let1 linum (+ index 1)
    (let1 id (href-id-of ewoc entry linum)
      `((span (|@| (class "linum") (id ,id))
	      (a (|@| (href ,#`"#,|id|"))
		 ,(format #`"~,(number->string linum-column),,d" linum)))
	(span (|@| (class "lfringe") (id ,#`"l/,|id|")) " ")
	(span (|@| (class "rfringe") (id ,#`"r/,|id|")) " ")))))

(define-method render-entry ((ewoc <ewoc>)
			     (entry <entry>))
  
  )

(define-method render-entries ((ewoc <ewoc>)
			       (entries <list>)
			       (css-prefix <string>))
  (let* ((n-dentries (length entries))
	 (linum-column (if (eq? n-dentries 0) 
			   1
			   (+ (floor->exact (log n-dentries 10)) 1))))
    `(*TOP*
      (*PI* xml "version=\"1.0\" encoding=\"UTF-8\"") "\n"
      (*DECL* DOCTYPE html PUBLIC 
	      "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd") "\n"
	      (html (|@| (xmlns "http://www.w3.org/1999/xhtml") (xml:lang "en") (lang "en"))
		    "\n"
		    (head 
		     "\n"
		     "	" (title ,(title-of ewoc)) "\n"
		     ,@(append-map
			(lambda (elt)
			  (list "	"
				`(meta (|@|
					(name ,(car elt))
					(content ,(cdr elt))))
				"\n"))
			(meta-tags-of ewoc))
		     ,@(reverse
			(fold
			 (lambda (face-style result)
			   (cons "\n" (cons `(link (|@| 
						    (rel "stylesheet")
						    (type "text/css")
						    (href ,(face->css-route (car face-style) 
									    (cadr face-style)
									    css-prefix))
						    (title ,(x->string (cadr face-style)))
						    ))
					    (cons "	" result))))
			 (list)
			 (faces-and-styles-of ewoc))))
		    "\n"
		    (body
		     "\n"
		     (pre
		      ,@(reverse (fold-with-index (lambda (index entry result)
						    (append (reverse
							     (append
							      (render-prefix ewoc
									     entry
									     index
									     linum-column)
							      '( 
								;; ewoc-marker
								" " ; Slot for marking: TODO
								" " ; Just space
							       )
							      (render-entry ewoc
									    entry)))
							    result))
						  (list)
						  entries))
		      )
		     "\n"
		     )))))

(provide "yogomacs/renderers/ewoc")
