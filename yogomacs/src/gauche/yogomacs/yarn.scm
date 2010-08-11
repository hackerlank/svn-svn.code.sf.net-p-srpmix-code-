(define-module yogomacs.yarn
  (export yarn-for)
  (use yogomacs.yarns.stitch-es)
  )


(select-module yogomacs.yarn)

(define (yarn-for path params config)
  (cons 'yarn-container
	(append
	 (stitch-es->yarn path params config))))

(provide "yogomacs/yarn")