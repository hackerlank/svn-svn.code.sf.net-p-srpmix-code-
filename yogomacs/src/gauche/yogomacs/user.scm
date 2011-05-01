(define-module yogomacs.user
  (export user? make-guest)
  )
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
    :shell 'ysh))

(define (user? user passwd)
  (if (and (equal? user "yamato@redhat.com")
	   (equal? passwd "password")) 
      (make <user>
	:name user 
	:real-name "Masatake YAMATO"
	:shell 'ysh
	)
      #f))


(provide "yogomacs/user")