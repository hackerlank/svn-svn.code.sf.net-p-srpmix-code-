(define-module yogomacs.user
  (export user?))
(select-module yogomacs.user)

(define-class <user> ()
  ((name :init-keyword :name)
   (real-name :init-keyword :real-name)
   (shell :init-keyword :shell :init-value 'nologin)
   ))

(define (make-guest)
  (make <user>
    :name "guest"
    :real-name "Guest"
    :shell 'nologin))

(define (user? user passwd)
  (if (and (equal? user "yamato@redhat.com")
	   (equal? passwd "password")) 
      (make <user>
	:name user 
	:real-name "Masatake YAMATO"
	:shell 'ysh)
      (make-guest)))


(provide "yogomacs/user")