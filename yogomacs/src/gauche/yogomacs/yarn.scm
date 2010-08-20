(define-module yogomacs.yarn
  (export collect-yarns-by-path
	  collect-yarns-by-author
	  collect-yarns-by-keywords
	  all-keywords
	  )
  (use yogomacs.reels.stitch-es)
  )


(select-module yogomacs.yarn)

(define (collect-yarns-by-path path params config)
  (cons 'yarn-container
	(append
	 (stitch-es->yarn path params config)
	 )))

(define (collect-yarns-by-author author params config)
  #f)

(define (collect-yarns-by-keywords keywords params config)
  #f)

(define (all-keywords params config)
  #f)


(provide "yogomacs/yarn")