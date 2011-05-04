(define (login-init major-mode)
  (set! login-mode (read-meta "login-mode")))
  
(define (login-action new-status)
  (message "~a..." (if login-mode "logout" "login"))
  (reload))
  
(define-minor-mode login
  :update-cookie #t
  :action login-action
  :init login-init)
