(define-module yogomacs.dentry
  (export <dentry>
	  <symlink-dentry>
	  symlink?
	  executable?
	  type-maker-of
	  dname-of
	  path-of
	  size-of
	  mtime-of
	  url-of
	  symlink-to-dname-of
	  symlink-to-url-of
	  dentry-for
	  )
  (use yogomacs.entry)
  (use srfi-1))
 
(select-module yogomacs.dentry)

(define-class <dentry> (<entry>)
  ())

(define-class <symlink-dentry> (<dentry>)
  ())


(define-method symlink? ((d <dentry>)) #f)
(define-method symlink? ((d <symlink-dentry>)) #t)

(define-method executable? ((d <dentry>)) #f)

(define-method type-maker-of ((d <dentry>)))
(define-method dname-of ((d <dentry>)))
(define-method path-of ((d <dentry>)))
(define-method size-of ((d <dentry>)))
(define-method mtime-of ((d <dentry>)))
(define-method url-of ((d <dentry>)))

(define-method symlink-to-dname-of ((d <symlink-dentry>)))
(define-method symlink-to-url-of ((d <symlink-dentry>)))


(define (dentry-for dentries dname)
  (find (lambda (dentry)
	  (equal? (dname-of dentry) dname))
	dentries))

(provide "yogomacs/dentry")