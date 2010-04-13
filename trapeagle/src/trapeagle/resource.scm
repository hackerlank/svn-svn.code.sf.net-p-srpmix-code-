(define-module trapeagle.resource
  (export 
   <task>
   <process>
   <fd>
   <file>
   dump
   )
  )
(select-module trapeagle.resource)

(define-class <resource> ()
  ())


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

(define-class <file> (<fd>)
  ((open-info :init-keyword :open-info :init-value (vector-copy info-template))
   ))

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