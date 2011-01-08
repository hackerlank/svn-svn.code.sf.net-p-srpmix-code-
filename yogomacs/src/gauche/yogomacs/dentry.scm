(define-module yogomacs.dentry
  (export <dentry>
	  <arrowy-dentry>
	  type-marker-of
	  unknown?
	  regular?
	  directory?
	  arrowy?
	  symlink?
	  virtual?
	  external?
	  input-marker-of
	  output-marker-of
	  delete-marker-of
	  command-marker-of

	  dname-of
	  path-of
	  parent-path-of
	  nlink-of
	  size-of
	  mtime-of
	  url-of

	  arrowy-to-dname-of
	  arrowy-to-url-of

	  dentry-for
	  )
  (use yogomacs.entry)
  (use srfi-1))
 
(select-module yogomacs.dentry)

(define-class <dentry> (<entry>)
  ())

(define-class <arrowy-dentry> (<dentry>)
  ())


;; 1 234 5
;; 1: type? - Help user understanding what 
(define-method type-marker-of ((d <dentry>)))
(define-method type-marker-eq? ((d <dentry>)
				 (c <char>))
  (eq? (type-marker-of d) c))
  

;;            happens if one clicks the entry.
;;    ?   unknown(e.g. char dev, block dev)
(define-method unknown? ((d <dentry>))
  (type-marker-eq? d #\?))

;;    -   regular file
(define-method regular? ((d <dentry>))
  (type-marker-eq? d #\-))
;;    d   directory
(define-method directory? ((d <dentry>))
  (type-marker-eq? d #\d))

;;        (arrowy?)
(define-method arrowy? ((d <dentry>)) #f)
(define-method arrowy? ((d <arrowy-dentry>)) #t)
;;    l   symlink (server side)

(define-method symlink? ((d <dentry>))
  (type-marker-eq? d #\l))
;;    v   HTTP redirection to the sources  page(virtual)
(define-method virtual? ((d <dentry>))
  (type-marker-eq? d #\v))
;;    x   HTTP redirection to the external page(external)
(define-method external? ((d <dentry>))
  (type-marker-eq? d #\x))

;;  23: What kind of IO redirection is permitted
;;
;;  2 : input?
;;  r     GET
;;  R     Raw GET
;;  -     Cannot GET
(define-method input-marker-of ((d <dentry>)) #\r)

;;   3: output?
;;   a    POST
;;   w    PUT
;;   A    PUT & POST
;;   -    Cannot PUT nor POST
(define-method output-marker-of ((d <dentry>)) #\-)

;;    4:  deletable?
;;    d   DELETE
;;    -   Cannot DELETE 
;;
(define-method delete-marker-of ((d <dentry>)) #\-)


;;     5: command?
;;     x  Invokable from the current shell
;;     -  Non.
(define-method command-marker-of ((d <dentry>)) #\-)

(define-method dname-of ((d <dentry>)))
(define-method path-of ((d <dentry>)))
(define-method parent-path-of ((d <dentry>)))
(define-method nlink-of ((d <dentry>)) 1)
(define-method size-of ((d <dentry>)))
(define-method mtime-of ((d <dentry>)))
(define-method url-of ((d <dentry>)))

(define-method arrowy-to-dname-of ((d <arrowy-dentry>)) #f)
(define-method arrowy-to-url-of ((d <arrowy-dentry>))   #f)

(define (dentry-for dentries dname)
  (find (lambda (dentry)
	  (equal? (dname-of dentry) dname))
	dentries))

(provide "yogomacs/dentry")