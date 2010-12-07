(define-module yogomacs.user
  (export user?))
(select-module yogomacs.user)

(define (user? user passwd)
  #t)

(provide "yogomacs/user")