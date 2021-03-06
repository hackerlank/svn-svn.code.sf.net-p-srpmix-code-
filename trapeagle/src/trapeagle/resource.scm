(define-module trapeagle.resource
  (export 
   <resource>
   <task>
   <process>
   <fd>
   <file>
   <socket>
   <request-socket>
   <pipe>
   children-of
   dead?
   closed?
   async?
   io
   )
  )
(select-module trapeagle.resource)
(debug-print-width #f)


(define-class <resource> ()
  ())



(define-class <task> (<resource>)
  ((parent-tid :init-keyword :parent-tid :init-value #t)
   (tid :init-keyword :tid :init-value #f)
   (clone-info :init-value #f)
   (children :init-form (list))
   (execve-info :init-value #f)
   (exit-info :init-value #f)
   (unfinished-syscall :init-value #f)
   (fd-table :init-value #f :init-keyword :fd-table)))

(define-method children-of ((task <task>))
  (ref task 'children))

(define-method dead? ((task <task>))
  (boolean (ref task 'exit-info)))

(define-class <process> (<task>)
  (
   (fd-table :init-form (make-hash-table 'eq?))))

;(define-class <thread> (<task>)
;  ())



(define-class <fd> (<resource>)
  (
   (open-info :init-value #f)
   (close-info :init-form #f)
   (unfinished-syscall :init-value #f)
   (close-on-exec? :init-value #f)
   (async? :init-value #f)
   (io :init-form (list))
   ))

(define-method closed? ((fd <fd>))
  (ref fd 'close-info))

(define-method async? ((fd <fd>))
  (ref fd 'async?))

(define-method io ((fd <fd>) e)
  (slot-push! fd 'io e))

(define-method io ((fd <fd>))
  (ref fd 'io)
  )

(define-class <file> (<fd>)
  ())

(define-class <socket> (<fd>)
  ((bind-info :init-value #f)
   (listen-info :init-value #f)
   (connect-info :init-value #f)
   (input-shutdown-info :init-value #f)
   (close-shutdown-info :init-value #f)
   ))

(define-class <request-socket> (<fd>)
  ())
  
(define-class <pipe> (<fd>)
  (peer))

(provide "trapeagle/resource")