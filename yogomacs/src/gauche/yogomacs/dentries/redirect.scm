(define-module yogomacs.dentries.redirect
  (export <redirect-dentry>
	  )
  (use yogomacs.dentry)
  (use yogomacs.dentries.virtual)
  )
(select-module yogomacs.dentries.redirect)

(define-class <redirect-dentry> (<virtual-dentry>)
  ((url :init-keyword :url :init-value #f)))

(define-method url-of ((redirect <redirect-dentry>))
  (or (ref redirect 'url)
      (path-of redirect)))

(provide "yogomacs/dentries/redirect")
