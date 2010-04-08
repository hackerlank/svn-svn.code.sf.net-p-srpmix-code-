(define-module trapeagle.resource
  (export 
   )
  )
(select-module trapeagle.resource)

(define-class <resource> ()
  ())

(define-class <task> (<resource>)
  ((parent-tid  :init-value :parent-tid :init-value #f)
   (tid :init-keyword :tid :init-value #f)
   (clone-unfinished-index :init-keyword :clone-start-index :init-value #f)
   (clone-resumed-index :init-keyword :clone-resumed-index   :init-value #f)
   (children :init-form (list))
   (exit-status :init-value #f)
   (unfinished :init-value #f)))

(define-class <process> (<task>)
  ((execve-args :init-keyword :execve-args :init-value  #f)
   (execve-index :init-keyword :execve-args :init-value #f)
   (fd-table :init-form (make-hash-table 'eq?))))

;(define-class <thread> (<task>)
;  ())

(define-class <fd> (<resource>)
  ((opened-by  :init-keyword :opened-by )
   (open-unfinished-index :init-keyword :open-unfinished-index)
   (open-resumed-index :init-keyword :open-resumed-index :init-value #f)
   (open-status? :init-value #f)
   (input-history :init-form (list))
   (output-history :init-form (list))
   (unfinished :init-value #f)
   (closed? :init-form (#f #f))	; for shutdown
   ))

(define-class <file> (<fd>)
  ((file-name :init-keyword :file-name)))

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