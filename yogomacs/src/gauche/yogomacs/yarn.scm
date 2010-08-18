(define-module yogomacs.yarn
  (export collect-yarns-by-target)
  (use yogomacs.yarns.stitch-es)
  )


(select-module yogomacs.yarn)

(define (collect-yarns-by-target path params config)
  (cons 'yarn-container
	(append
	 (stitch-es->yarn path params config)
	 )))

(define (collect-yarns-by-author author params config)
  #f)

(define (collect-yarns-by-keywords keywords params config)
  #f)



(provide "yogomacs/yarn")