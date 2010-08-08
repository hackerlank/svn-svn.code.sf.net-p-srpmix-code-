;;
;; scheme level utilities
;;
(define (pa$ proc . args)
  (lambda rest (apply proc (append args rest))))
(define (fold proc initial lst)
  (if (null? lst)
      initial
      (let1 result (proc (car lst) initial)
	(fold proc result (cdr lst)))))
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


(define ($ elt)
  ((js-field *js* "$") elt))
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
				       "=" (with-output-to-string 
					     (pa$ write 
						  (html-escape-string val))))
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

;;
;; JS <-> Scheme interface
;;
(define (export var val)
  (js-field-set! *js* var val))

(define (run-hook hook . args)
  (for-each (lambda (proc) (apply proc args)) hook))

(define (alist->object a)
  (let1 o (js-new Object)
    (for-each
     (lambda (elt)
       (js-field-set! o 
		      (let1 key (car elt)
			(if (string? key)
			    key
			    (symbol->string key)))
		      (cdr elt)))
     a)
    o))

;;
;; Scheme2js -> Biwascheme
;;
(define (scm->scm bscm exp)
  (let1 str (with-output-to-string (pa$ write exp))
    (bscm.evaluate str)))

;;
;; Yogomacs level
;;
(define-hook find-file-pre-hook)
(define-hook toggle-full-screen-hook)
(define-hook read-from-minibuffer-hook)


(add-hook find-file-pre-hook (lambda ()  
			       (let1 elt ($ "minibuffer") 
				 (elt.focus)
				 (elt.select))))

;; TODO alist->params
(define (stitch stitches)
  (alert (apply string-append stitches)))

(define (require-stitches url params)
  (let1 options (alist->object `((method . "get")
				 (parameters . ,params)
				 (onSuccess . ,(lambda (response)
						 (stitch
						  (with-input-from-string response.responseText
						    read))
						 ))))
    (js-new Ajax.Request
	    "/web/stitch/x/y/y"
	    options)))

(define (load-lazy url params)
  (let1 options (alist->object `((method . "get")
				 (parameters . ,params)
				 (onFailure . ,(lambda ()
						 (alert "An error occured")))
				 (onComplete . ,(lambda ()
						  (require-stitches url params)))
				 ))
    (js-new Ajax.Updater
		"buffer"
		url
		options)))
			       

(define full-screen #f)
(define (full-screen?)  full-screen)
(define extra-elements '("header-line"
			 "modeline"
			 "modeline-control"
			 "minibuffer-shell"
			 ;"minibuffer"
			 "minibuffer-prompt-shell"
			 ;"minibuffer-prompt"
			 ))
(define (toggle-full-screen)
  (if full-screen
      (leave-full-screen)
      (enter-full-screen)))

(define (enter-full-screen)
  (set! full-screen #t)
  (for-each (lambda (id)
	      (let1 elt ($ id)
		(elt.update (sxml->xhtml "<"))))
	    '("toggle-full-screen"))
  (for-each (lambda (id)
	      (let1 elt ($ id)
		(elt.hide)))
	    extra-elements)
  (let1 elt ($ "buffer")
    (elt.setStyle (alist->object '((top . "0.0em")
				   (bottom . "0.0em")
				   (position . "static")
				   (z-index . "-1"))))))

(define (leave-full-screen)
  (set! full-screen #f)
  (for-each (lambda (id)
	      (let1 elt ($ id)
		(elt.update (sxml->xhtml ">"))))
	    '("toggle-full-screen"))
  (for-each (lambda (id)
	      (let1 elt ($ id)
		(elt.show)))
	    extra-elements)
  (let1 elt ($ "buffer")
    (elt.setStyle (alist->object '((top . "1.2em")
				   (bottom . "2.2em")
				   (position . "fixed")
				   (z-index . "0"))))))

(define (repl eval output-prefix)
  (let1 str (<- "minibuffer")
    (let1 result (with-error-handler 
		   (lambda (e) (with-output-to-string (pa$ write e)))
		   (pa$ eval str))
      (-> (string-append output-prefix result) "minibuffer")))
  (let1 elt ($ "minibuffer")
    (elt.focus)
    (elt.select)))

(define bscm #f)
(define bscm-dir "/bscm")
(define ysh #f)
(define ysh-dir "/ysh")

(define (new-bscm shell-dir)
  (let1 bscm (js-new BiwaScheme.Interpreter)
    (scm->scm bscm
	      ;; Handle ...
	      `(define (normalize-path path)
		 (let1 len (string-length path)
		   (cond 
		    ((eq? len 0) "")
		    ((equal? (substring path (- len 1) len) "/") 
		     (normalize-path (substring path 0 (- len 1))))
		    (else path)))))
    ;; TODO... command should be appeared on plugins dir.
    (scm->scm bscm
	      `(define (exit . rest)
		 (let* ((location (js-eval "location"))
			(pathname (js-ref location "pathname")))
		   (js-set! location "pathname" (substring
						 (normalize-path pathname)
						 (string-length ,shell-dir)
						 (string-length pathname))))))
    (scm->scm bscm
	      `(define (bscm . rest)
		 (let* ((location (js-eval "location"))
			(pathname (js-ref location "pathname")))
		   (js-set! location "pathname" (string-append ,bscm-dir
							       (substring
								(normalize-path pathname)
								(string-length ,shell-dir)
								(string-length pathname)))))))
    (scm->scm bscm
	      `(define (ysh . rest)
		 (let* ((location (js-eval "location"))
			(pathname (js-ref location "pathname")))
		   (js-set! location "pathname" (string-append ,ysh-dir
							       (substring
								(normalize-path pathname)
								(string-length ,shell-dir)
								(string-length pathname)))))))
    (scm->scm bscm
	      `(define (find-file entry) 
		 (let* ((location (js-eval "location"))
			(pathname (js-ref location "pathname"))
			(entry (normalize-path entry))
			(len (string-length entry)))
		   (cond
		    ((or (and (< 0 len)
			      (eq? (string-ref entry 0) #\/))
			 (eq? len 0))
		     (js-set! location "pathname" (string-append ,shell-dir
								 entry)))
		    (else
		     (js-set! location "pathname" (string-append 
						   (normalize-path pathname)
						   "/"
						   entry)))
		       ))))
    (scm->scm bscm '(define cd find-file))
    (scm->scm bscm '(define less find-file))
    (scm->scm bscm '(define lv find-file))
    bscm))

(define (bscm-eval str)
  (unless bscm
    (set! bscm (new-bscm bscm-dir)))
  (let1 result #f
    (bscm.evaluate str
		   (lambda (r) 
		     (set! result (BiwaScheme.to_write r))))
    result))

(define (bscm-interpret)
  (repl bscm-eval ";; "))

(define (ysh-eval str)
  (unless ysh
    (set! ysh (new-bscm ysh-dir)))
  (let1 str
      (let1 exp (with-input-from-string 
		    (string-append "(" str ")") 
		  read)
	(with-output-to-string 
	  (pa$ write
	       (cons (car exp)
		     (map symbol->string (cdr exp))))))
    (let1 result #f
      (ysh.evaluate str
		    (lambda (r) 
		      (set! result (BiwaScheme.to_write r))))
      result)))

(define (ysh-interpret)
  (repl ysh-eval "# "))

(define (highlight id)
  (let1 elt ($ id)
    (elt.addClassName "highlight")))
(export "highlight" highlight)
(define (unhighlight id)
  (let1 elt ($ id)
    (elt.removeClassName "highlight")))
(export "unhighlight" unhighlight)
