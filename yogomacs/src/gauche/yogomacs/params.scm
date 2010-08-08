(define-module yogomacs.params
  (export params->proc
	  )
  (use www.cgi)
  (use util.list)
  )

(select-module yogomacs.params)

(define (params->proc params defaults)
  (lambda (key)
    (cgi-get-parameter key params
		       :default (assoc-ref defaults
					   key
					   #f))))
(provide "yogomacs/params")