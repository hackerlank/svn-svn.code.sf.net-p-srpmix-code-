(define-module yogomacs.dentries.text
  (export <text-dentry>
	  text-of)
  (use yogomacs.dentry)
  (use yogomacs.dentries.virtual)
  )
(select-module yogomacs.dentries.text)

(define-class <text-dentry> (<virtual-dentry>)
  ((text :init-keyword :text)
   ))

(define-method url-of ((d <text-dentry>))
  (escape-path-component-of-url
   (path-of d)))

(define-method text-of ((d <text-dentry>))
  (ref d 'text))

(provide "yogomacs/dentries/text")