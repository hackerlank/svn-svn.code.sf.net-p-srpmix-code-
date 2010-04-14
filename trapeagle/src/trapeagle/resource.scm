(define-module trapeagle.resource
  (export 
   <task>
   <process>
   <fd>
   <file>
   dump
   clone
   )
  )
(select-module trapeagle.resource)
(debug-print-width #f)


(define-class <resource> ()
  ())

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

(define info-template #(:start-index :end-index :start-time :end-time :xargs :xrvalue :xerrno))

(define-class <task> (<resource>)
  ((parent-tid :init-keyword :parent-tid :init-value #t)
   (tid :init-keyword :tid :init-value #f)
   (clone-info :init-form (vector-copy info-template) :init-keyword :clone-info)
   (children :init-form (list))
   (exit-status :init-value #f)
   (unfinished? :init-value #f)
   (fd-table :init-value #f :init-keyword :fd-table)))

(define-class <process> (<task>)
  ((execve-info  :init-keyword :execve-info :init-value (vector-copy info-template))
   (fd-table :init-form (make-hash-table 'eq?))))

(define-method dump ((task <task>))
  (format #t "ptid: ~s\n" (ref task 'parent-tid))
  (format #t "tid: ~s\n" (ref task 'tid))
  (format #t "children: ~s\n" 
	  (map 
	   (lambda (child) (ref child 'tid))
	   (sort (ref task 'children) 
		 (lambda (a b) (< (ref a 'tid) (ref b 'tid)))))))

(define-method dump ((process <process>))
  (next-method)
  (format #t "execve: ~s\n" (ref process 'execve-info))
  (for-each (lambda (elt) 
	      (format #t "fd: ~s\n" (car elt))
	      (dump (cdr elt)))
	    (let1 table (ref process 'fd-table)
	      (map
	       (lambda (fd) (cons fd (ref table fd)))
	       (sort (hash-table-keys table) <)))))

;(define-class <thread> (<task>)
;  ())

(define-class <fd> (<resource>)
  (
   (input-history :init-form (list))
   (output-history :init-form (list))
   (unfinished? :init-value #f)
   (closed? :init-form (list #f #f))	; for shutdown
   ))

(define-method clone ((fd0 <fd>))
  (clone-helper fd0 <fd> next-method))


(define-class <file> (<fd>)
  ((open-info :init-keyword :open-info :init-value (vector-copy info-template))
   ))

(define-method clone ((file0 <file>))
  (clone-helper file0 <file> next-method))

(define-class <socket> (<fd>)
  ((domain :init-keyword :domain)
   (type   :init-keyword :type)
   (protocol :init-keyword :protocol)
   (bind-index :init-value #f)
   (bind-args  :init-value #f)
   (bind-status? :init-value #f)
   (listen-index :init-value #f)
   (connect-index :init-value #f)
   (connect-args :init-value #f)
   ))

(define-method clone ((socket0 <socket>))
  (clone-helper socket0 <socket> next-method))

(define-class <pipe> (<fd>)
  ())

(define-method dump ((fd <fd>))
  (format #t "unfinished: ~s\n" (ref fd 'unfinished?))
  (format #t "closed?: ~s\n" (ref fd 'closed?))
  )
(define-method dump ((file <file>))
  (format #t "open-info: ~s\n" (ref file 'open-info))
  (next-method))

(provide "trapeagle/resource")