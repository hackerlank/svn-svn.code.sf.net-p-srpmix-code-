(define-module yogomacs.params
  (export params->proc
	  )
  (use www.cgi)
  (use util.list)
  (use util.match)
  )

(select-module yogomacs.params)

(define (params->proc+ base-lookup key value)
  (let1 lookup (lambda (key0)
		     (if (equal? key0 key)
			 value
			 (base-lookup key0)))
		 
  (match-lambda*
   ((key0)
    (lookup key0))
   ((key0 value0)
    (params->proc+ lookup key0 value0)))))

(define (params->proc params defaults)
  (let1 lookup (lambda (key) 
		 (cgi-get-parameter key
				    params
				    :default (assoc-ref defaults
							key
							#f)))
    (match-lambda*
     ((key)
      (lookup key))
     ((key value)
      (params->proc+ lookup key value) )
     )))
(provide "yogomacs/params")