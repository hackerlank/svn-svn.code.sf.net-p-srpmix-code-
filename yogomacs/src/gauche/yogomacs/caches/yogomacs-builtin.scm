;;
;; scheme level utilities
;;
(define (pa$ proc . args)
  (lambda rest (apply proc (append args rest))))

(define ($ elt)
  ((js-field *js* "$") elt))
(define (<- elt)
  ((js-field *js* "$F") elt))
(define (-> val elt)
  (let1 field ($ elt)
    (field.setValue val)))

;; TODO (sxml->xhtml), (html-escape)
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
;; Yogomacs level
;;
(define-hook find-file-pre-hook)
(define-hook toggle-full-screen-hook)
(define-hook read-from-minibuffer-hook)


(define (load-lazy url params)
      (let ((options (js-new Object)))
	(set! options.method "get")
	(set! options.parameters params)
	(set! options.onFailure (lambda ()
				  (alert "An error occured")))
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
		;; (elt.update (sxml->html (a (|@| (href "#")) "<<<")))
		(elt.update "<a href=\"#\">&lt;&lt;&lt;</a>")))
	    '("header-line-control"))
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
		(elt.update "<a href=\"#\">&gt;&gt;&gt;</a>")))
	    '("header-line-control"))
  (for-each (lambda (id)
	      (let1 elt ($ id)
		(elt.show)))
	    extra-elements)
  (let1 elt ($ "buffer")
    (elt.setStyle (alist->object '((top . "1.2em")
				   (bottom . "2.2em")
				   (position . "fixed")
				   (z-index . "0"))))))

(define (common-interpret eval output-prefix)
  (let1 str (<- "minibuffer")
    (let1 result (with-error-handler 
		   (lambda (e) (with-output-to-string (pa$ write e)))
		   (pa$ eval str))
      (-> (string-append output-prefix result) "minibuffer")))
  (let1 elt ($ "minibuffer")
    (elt.focus)
    (elt.select)))

(define (scm->scm bscm exp)
  (let1 str (with-output-to-string (pa$ write exp))
    (bscm.evaluate str)))

(define bscm #f)
(define (new-bscm)
  (let1 bscm (js-new BiwaScheme.Interpreter)
    (scm->scm bscm
	      '(define (cd entry) 
		 (let* ((location (js-eval "location"))
			(pathname (js-ref location "pathname")))
		   (js-set! location "pathname" (string-append pathname "/" entry)))))
    (scm->scm bscm
	      '(define less cd))
    (scm->scm bscm
	      '(define lv cd))
    bscm))

(define (bscm-eval str)
  (unless bscm
    (set! bscm (new-bscm)))
  (let1 result #f
    (bscm.evaluate str
		   (lambda (r) 
		     (set! result (BiwaScheme.to_write r))))
    result))

(define (bscm-interpret)
  (common-interpret bscm-eval ";; "))

(define (ysh-eval str)
  str)
(define (ysh-interpret)
  (common-interpret ysh-eval "# "))

;; TODO
;; - highlight
;; - shell switching
