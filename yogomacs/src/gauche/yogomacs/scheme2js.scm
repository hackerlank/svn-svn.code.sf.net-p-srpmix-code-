(define-module yogomacs.scheme2js
  (export scm->js)
  (use gauche.process)
  )

(select-module yogomacs.scheme2js)

(define (scm->js . body)
  (receive (oport file) (sys-mkstemp "/tmp/scm->js") 
    (for-each
     (lambda (sexp)
       (write sexp oport)
       (newline oport))
     body)
    (close-output-port oport)
    (let1 js (call-with-input-process 
		 `(scheme2js -o - ,file)
	       port->string)
      (sys-unlink file)
      js)))

#;(display
 (scm->js
  (+ 1 1)))
#;(display
 (scm->js
 (define make-hash-table make-hashtable)
 (define-macro (let1 var val . body)
   `(let ((,var ,val))
      ,@body))

 (define (find-file url params)
   (let1 options (js-new Object)
     (set! options.method "get")
     (set! options.parameters params)
     (set! options.onFailure (lambda ()
			       (alert "An error occured")))
     (js-new Ajax.Updater
	     "buffer"
	     url
	     options)))))
#;(define url "a")
#;(define params "b")
#;(display 
 (scm->js
  `(let ((options (js-new Object)))
     (set! options.method "get")
     (set! options.parameters ,params)
     (set! options.onFailure (lambda ()
			       (alert "An error occured")))
     (js-new Ajax.Updater
	     "buffer"
	     ,url
	     options))))

(provide "yogomacs/scheme2js")