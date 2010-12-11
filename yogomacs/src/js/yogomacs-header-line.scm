(define (header-line-prepare)
  (let1 hl ($ "header-line-role")
    (hl.update (role-name))))
  