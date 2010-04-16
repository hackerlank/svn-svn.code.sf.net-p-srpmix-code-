(define-module trapeagle.resource
  (export 
   <resource>
   <task>
   <process>
   <fd>
   <file>
   <socket>
   <request-socket>
   children-of
   dead?
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
   (exit-info :init-value #f)
   (unfinished? :init-value #f)
   (fd-table :init-value #f :init-keyword :fd-table)))

(define-method children-of ((task <task>))
  (ref task 'children))

(define-method dead? ((task <task>))
  (boolean (ref task 'exit-info )))

(define-class <process> (<task>)
  ((execve-info  :init-keyword :execve-info :init-value (vector-copy info-template))
   (fd-table :init-form (make-hash-table 'eq?))))

;(define-class <thread> (<task>)
;  ())

(define-class <fd> (<resource>)
  (
   (input-history :init-form (list))
   (output-history :init-form (list))
   (unfinished? :init-value #f :init-keyword :unfinished?)
   (closed? :init-form (list #f #f))	; for shutdown
   ))

(define-class <file> (<fd>)
  ((open-info :init-keyword :open-info :init-value (vector-copy info-template))
   ))

(define-class <socket> (<fd>)
  ((socket-info :init-keyword :socket-info)
   (bind-index :init-value #f)
   (bind-args  :init-value #f)
   (bind-status? :init-value #f)
   (listen-index :init-value #f)
   (connect-index :init-value #f)
   (connect-args :init-value #f)
   ))

(define-class <request-socket> (<fd>)
  ((accept-info :init-keyword :accept-info)))
  
(define-class <pipe> (<fd>)
  ())

(provide "trapeagle/resource")