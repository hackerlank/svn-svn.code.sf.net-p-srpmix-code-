(define-module yogomacs.user
  (export user?))
(select-module yogomacs.user)

(define-class <user> ()
  ((name :init-keyword :name)
   (real-name :init-keyword :real-name)
   ))

(define (user? user passwd)
  (if (and (equal? user "yamato@redhat.com")
	   (equal? passwd "password")) 
      (make <user>
	:name user 
	:real-name "Masatake YAMATO")
      #f))

(provide "yogomacs/user")