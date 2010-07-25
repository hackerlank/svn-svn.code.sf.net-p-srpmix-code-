(define-module yogomacs.dentries.virtual
  (export <virtual-dentry>)
  (use yogomacs.dentry)
  (use file.util))
(select-module yogomacs.dentries.virtual)

(define-class <virtual-dentry> (<dentry>)
  ((parent :init-keyword :parent)
   (dname :init-keyword :dname)
   (size :init-keyword :size :init-value 0)
   (mtime :init-keyword :mtime :init-value (current-time))))

(define-method executable? ((d <virtual-dentry>)) #t)
(define-method type-maker-of ((d <virtual-dentry>)) #\x)

(define-method dname-of ((d <virtual-dentry>))
  (ref d 'dname))
(define-method path-of ((d <virtual-dentry>))
  (build-path (ref d 'parent)
	      (ref d 'dname)))

(define-method size-of ((d <virtual-dentry>))
  (ref d 'size))

(define-method mtime-of ((d <virtual-dentry>)) 
  (ref d 'mtime))

(provide "yogomacs/dentries/virtual")