(define-module yogomacs.dentries.text
  (export <text-dentry>
	  text-of)
  (use yogomacs.dentry)
  (use file.util)
  )
(select-module yogomacs.dentries.text)

(define-class <text-dentry> (<dentry>)
  ((parent :init-keyword :parent)
   (dname :init-keyword :dname)
   (text :init-keyword :text)
   (size :init-keyword :size :init-value 0)
   (mtime :init-keyword :mtime :init-value (current-time))
   ))

(define-method executable? ((d <text-dentry>)) #t)
(define-method type-maker-of ((d <text-dentry>)) #\x)
(define-method dname-of ((d <text-dentry>))
  (ref d 'dname))
(define-method path-of ((d <text-dentry>))
  (build-path (ref d 'parent)
	      (ref d 'dname)))

(define-method size-of ((d <text-dentry>))
  (ref d 'size))

(define-method mtime-of ((d <text-dentry>)) 
  (ref d 'mtime))

(define-method url-of ((d <text-dentry>))
  (path-of d))

(define-method text-of ((d <text-dentry>))
  (ref d 'text))

(provide "yogomacs/dentries/text")