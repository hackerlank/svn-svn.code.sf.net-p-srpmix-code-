(define-module yogomacs.util.scheme2js
  (export scm->js scm->js*)
  (use gauche.process)
  )

(select-module yogomacs.util.scheme2js)

;; FIXMIE: THIS SHOULD NOT BE PART OF THIS MODULE.
(define yogomacs-macs "/usr/share/yogomacs/scheme2js/yogomacs-macs.scm")
(define (scm->js body)
  (receive (oport file) (sys-mkstemp "/tmp/scm->js") 
    (for-each
     (lambda (sexp)
       (write sexp oport)
       (newline oport))
     (append (call-with-input-file yogomacs-macs 
	       port->sexp-list)
	     body))
    (close-output-port oport)
    (dynamic-wind
	(lambda ())
	(lambda ()
	  (let1 js (call-with-input-process 
		       `(scheme2js -o - ,file)
		     port->string)
	    js))
	(pa$ sys-unlink file))))


(define (scm->js* . body)
  (apply scm->js body))

(provide "yogomacs/util/scheme2js")
