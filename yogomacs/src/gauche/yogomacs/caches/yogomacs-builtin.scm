;;
;; scheme level utilities
;;
(define (pa$ proc . args)
  (lambda rest (apply proc (append args rest))))

(define ($ elt)
  ((js-field *js* "$") elt))
(define (-> elt)
  ((js-field *js* "$F") elt))
(define (<- elt val)
  (let1 field ($ elt)
    (field.setValue val)))


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
		(elt.update "<")))
	    '("header-line-control"
	      "modeline-control"))
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
		(elt.update ">")))
	    '("header-line-control"
	      "modeline-control"))
  (for-each (lambda (id)
	      (let1 elt ($ id)
		(elt.show)))
	    extra-elements)
  (let1 elt ($ "buffer")
    (elt.setStyle (alist->object '((top . "1.2em")
				   (bottom . "2.2em")
				   (position . "fixed")
				   (z-index . "0"))))))

(define (bscm-eval str)
  (let1 sexp (with-input-from-string str read)
    (let1 result (cond
		  ((eof-object? sexp) "")
		  ((null? sexp) '())
		  ((pair? sexp) (with-output-to-string (write (pa$ apply (car sexp) (cdr sexp)))))
		  (else (with-output-to-string (lambda () (write sexp)))))
      result)))

(define (bscm-interpret)
  (let1 str (-> "minibuffer")
    (let1 result (bscm-eval str)
	;; (alert result)
	(<- "minibuffer" (string-append ";; " result)))))

(add-hook read-from-minibuffer-hook bscm-interpret)
;; TODO
;; - highlight
;; - shell switching
