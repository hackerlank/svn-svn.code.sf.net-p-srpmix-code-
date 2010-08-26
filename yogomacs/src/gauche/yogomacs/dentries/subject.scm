(define-module yogomacs.dentries.subject
  (export <subject-dentry>)
  (use yogomacs.dentry)
  (use yogomacs.dentries.virtual))
  
(select-module yogomacs.dentries.subject)

(define-class <subject-dentry> (<virtual-dentry>)
  ((nlink :init-keyword :nlink)
   ))

(define-method url-of ((d <subject-dentry>))
  (path-of d))

(define-method nlink-of ((d <subject-dentry>))
  (ref d 'nlink)
  )

(provide "yogomacs/dentries/subject")