(define-module yogomacs.shell
  (export in-shell?
	  <shell>
	  define-shell
	  define-shell0
	  shell-ref
	  all-shells
	  url-of
	  dest-for
	  entry-for)
  (use util.list)
  (use www.cgi)
  (use yogomacs.dentries.redirect))

(select-module yogomacs.shell)

(define (in-shell? params)
  (params "yogomacs"))

(define-class <shell> ()
  ((name :init-keyword :name)
   (prompt :init-keyword :prompt)
   (url :init-value #f :init-keyword :url)
   (interpreter :init-keyword :interpreter)
   (initializer :init-keyword :initializer)
   ))

(define-method url-of ((shell <shell>))
  (if-let1 url (ref shell 'url)
	   url
	   (string-append "/" (ref shell 'name))))
(define-method dest-for ((shell <shell>) path params config)
  (list
   (cgi-header :status "302 Moved Temporarily"
	       :location (url-of shell))))
(define-method entry-for ((shell <shell>) parent-path)
  (make <redirect-dentry>
    :parent "/commands" :dname (ref shell 'name) :url (url-of shell)))

(define-macro (define-shell name object)
  `(define-shell0 (quote ,name) ,object))

(define-values (define-shell0 shell-ref all-shells)
  (let1 shells (list)
    (values
     (lambda (name shell-object)
       (set! shells (cons `(,name . ,shell-object) shells)))
     (lambda (name)
       (assq-ref shells name #f))
     (lambda ()
       (map cdr shells)))))

(provide "yogomacs/shell")