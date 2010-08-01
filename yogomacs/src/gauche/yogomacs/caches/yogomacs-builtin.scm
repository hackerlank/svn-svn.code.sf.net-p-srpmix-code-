;;
;; scheme level utilities
;;
(define (pa$ proc . args)
  (lambda rest (apply proc (append args rest))))

(define ($ elt)
  ((js-field *js* "$") elt))

;;
;; JS <-> Scheme interface
;;
(define (export var val)
  (js-field-set! *js* var val))

(define (run-hook hook)
  (for-each (lambda (proc) (proc)) hook))

;;
;; Yogomacs level
;;
;; (define find-file-pre-hook (list))
;; (export "run_find_file_pre_hook"
;; 	(lambda () (run-hook find-file-pre-hook)))
(define-hook find-file-pre-hook)
(define-hook toggle-full-screen-hook)


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
    (let ((elt ($ "buffer"))
	(style (js-new Object)))
    (set! style.top "0.0em")
    (set! style.bottom "0.0em")
    (set! style.position "static")
    (set! style.z-index "-1")
    (elt.setStyle style)
    )
  )
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
  (let ((elt ($ "buffer"))
	(style (js-new Object)))
    (set! style.top "1.2em")
    (set! style.bottom "2.2em")
    (set! style.position "fixed")
    (set! style.z-index "0")
    (elt.setStyle style)
    )
  )
;; TODO
;; - highlight
;; - cursor shape
;; - shell switching
