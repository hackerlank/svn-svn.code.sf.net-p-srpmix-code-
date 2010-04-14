(define-module trapeagle.clone
  (export clone)
  (use trapeagle.resource))

(select-module trapeagle.clone)

(define-method clone ((obj <top>))
  (errorf "clone is not defined for: ~s" (class-of obj)))
(define-method clone ((obj <null>))
  (list))
(define-method clone ((obj <boolean>))
  obj)
(define-method clone ((obj <pair>))
  (list-copy obj))
(define-method clone ((obj <vector>))
  (vector-copy obj))

(define-method clone ((obj <object>))
  (make <object>))

(define-method clone ((ht0 <hash-table>))
  (let1 ht1 (make-hash-table (hash-table-type ht0))
    (hash-table-for-each ht0
			 (lambda (key value)
			   (hash-table-put! ht1 key (clone value))))
    ht1))

(define (clone-helper obj0 cls next)
  (let1 obj1 (change-class (next) cls)
    (for-each (lambda (slot)
		(set! (ref obj1 slot) (clone (ref obj0 slot))))
	      (map slot-definition-name (class-direct-slots cls)))
    obj1))

(define-method clone ((obj0 <resource>))
  (make <resource>))

(define-method clone ((fd0 <fd>))
  (clone-helper fd0 <fd> next-method))

(define-method clone ((file0 <file>))
  (clone-helper file0 <file> next-method))

(define-method clone ((socket0 <socket>))
  (clone-helper socket0 <socket> next-method))

(provide "trapeagle/clone")