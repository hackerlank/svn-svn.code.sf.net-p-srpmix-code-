(define (header-line-init)
  (let1 hl ($ "header-line-role")
    (hl.update (read-meta "role-name")))
  (let1 hl ($ "header-line-user")
    (hl.update (read-meta "user-name")))
  )
  