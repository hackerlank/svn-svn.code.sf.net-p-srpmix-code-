(define (header-line-prepare)
  (let1 hl ($ "header-line-role")
    (hl.update (role-name)))
  (let1 hl ($ "header-line-user")
    (hl.update (user-name)))
  )
  