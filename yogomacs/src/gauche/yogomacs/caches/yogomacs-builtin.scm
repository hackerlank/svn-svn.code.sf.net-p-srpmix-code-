;;
;; scheme level utilities
;;
(define (pa$ proc . args)
  (lambda rest (apply proc (append args rest))))
(define (paste thunk)
  (lambda rest (thunk)))

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

(define (read-from-string string)
  (with-input-from-string string
    read))
(define (write-to-string exp)
  (with-output-to-string (pa$ write exp)))

;; This is workaround for brkoken scheme2js read proc.
(define (keyword->symbol key)
  (string->symbol 
   (string-append ":" 
		  (keyword->string key))))

;; TODO: Report 
;;(define-method ref ((list <list>) (keyword <keyword>))
;;  (get-keyword ...)
(define (kref klist key default)
  (cond
   ((null? klist) default)
   ((eq? (car klist) key) (cadr klist))
   ((and (keyword? key) 
	 (eq? (keyword->symbol key) 
	      (car klist)))
    (cadr klist))
   (else (kref (cddr klist) key default))))

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

(define (read-from-response response)
  (read-from-string response.responseText))


;;
;; Scheme2js -> Biwascheme
;;
(define (scm->scm bscm exp)
  (let1 str (write-to-string exp)
    (bscm.evaluate str)))

;;
;; Yogomacs level
;;
;; TODO alist->params ;;


(define-hook find-file-pre-hook)
(define-hook toggle-full-screen-hook)
(define-hook read-from-minibuffer-hook)


(add-hook find-file-pre-hook (lambda ()  
			       (let1 elt ($ "minibuffer") 
				 (elt.focus)
				 (elt.select))))


;;
;; Stitch
;;
(define (stitch-make-insertion-proc type)
  (cond
   ((eq? type 'file) (lambda (posinfo frag) 
		       (let1 id (string-append "L:" (number->string posinfo))
			 (let1 elt ($ id)
			   (when elt
			     (elt.insert (alist->object `((before . ,frag)))))))))
   ((eq? type 'directory) (lambda (posinfo frag) 
		       (let1 id (string-append "N:" posinfo)
			 (let1 elt ($ id)
			   (when elt
			     (elt.insert (alist->object `((before . ,frag)))))))))
   (else (lambda (posinfo frag) #f))))

(define (stitch-make-render-proc type)
  (cond
   ((eq? type 'text)  (lambda (text date full-name mailing-address keywords)
			(sxml->xhtml 
			 `(div (|@|
				(class "annotation-div")
				;(id ...)
				)
			   "\n"
			   (span (|@| 
				  (class "annotation-date-face"))
				 ,date)
			   "  "
			   (span  (|@| (class "annotation-name"))
				  ,full-name)
			   "  "
			   "<"
			   (span  (|@| (class "annotation-email"))
				  ,mailing-address)
			   ">"
			   "\n"
			   "\n"
			   (span  (|@| (class "annotation-text"))
				  ,text)
			   "\n"
			   "\n")
			 )))
   (else (lambda (content date full-name mailing-address keywords)
	   #f))))

(define (stitch-annotation elt)
  (let1 elt (cdr elt)
    (let* ((target (kref elt :target #f))
	   (content (kref elt :content #f))
	   (date (kref elt :date #f))
	   (full-name (kref elt :full-name #f))
	   (mailing-address (kref elt :mailing-address #f))
	   (keywords (kref elt :keywords (list))))
      (let ((insertion-proc (stitch-make-insertion-proc (car target)))
	    (render-proc (stitch-make-render-proc (car content)))
	    ;;(filter-proc (stitch-make-filter-proc keywords))
	    )
	(let1 frag  (render-proc (cadr content)
				 date
				 full-name
				 mailing-address
				 keywords)
	  (insertion-proc (cadr target)
			  frag))))))

(define (stitch-annotations annotations)
  (cond 
   ((eq? (car annotations) 'annotation-container)
    (for-each
     (lambda (elt)     
       (cond
	((eq? (car elt) 'annotation)
	 (stitch-annotation elt))))
     (cdr annotations)
     ))))


(define (require-annotations url params)
  (let1 options (alist->object `((method . "get")
				 (parameters . ,params)
				 (onSuccess . ,(lambda (response)
						 (stitch-annotations
						  (read-from-response response))
						 ))))
    (js-new Ajax.Request
	    (string-append "/web/annotation" url)
	    options)))

(define (load-lazy url params)
  (let1 options (alist->object `((method . "get")
				 (parameters . ,params)
				 (onFailure . ,(lambda ()
						 (alert "An error occured")))
				 (onComplete . ,(lambda ()
						  (require-annotations url params)))
				 ))
    (js-new Ajax.Updater "buffer" url options)))
			       



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

;;
;; Repl
;;
(define (repl eval output-prefix)
  (let1 str (<- "minibuffer")
    (let1 result (with-error-handler 
		   write-to-string
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
      (let1 exp (read-from-string
		 (string-append "(" str ")") )
	(write-to-string (cons (car exp)
			       (map symbol->string (cdr exp))) 
			 ))
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
