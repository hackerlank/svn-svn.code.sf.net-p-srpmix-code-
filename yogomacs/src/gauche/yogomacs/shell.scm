(define-module yogomacs.shell
  (export in-shell?
	  <shell>
	  define-shell
	  define-shell0
	  shell-ref)
  (use www.cgi)
  (use util.list))

(select-module yogomacs.shell)

(define (in-shell? params)
  (cgi-get-parameter "yogomacs" params  
		     :default #f))

(define-class <shell> ()
  ((name :init-keyword :name)
   (prompt :init-keyword :prompt)))

(define-macro (define-shell name object)
  `(define-shell0 (quote ,name) ,object))

(define-values (define-shell0 shell-ref)
  (let1 shells (list)
    (values
     (lambda (name shell-object)
       (set! shells (cons `(,name . ,shell-object) shells)))
     (lambda (name)
       (assq-ref shells name #f)))))

(provide "yogomacs/shell")