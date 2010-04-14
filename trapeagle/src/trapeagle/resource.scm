(define-module trapeagle.resource
  (export 
   <resource>
   <task>
   <process>
   <fd>
   <file>
   <socket>
   )
  )
(select-module trapeagle.resource)
(debug-print-width #f)


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

(provide "trapeagle/resource")