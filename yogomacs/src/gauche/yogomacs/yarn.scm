(define-module yogomacs.yarn
  (export collect-yarns-by-path
	  collect-yarns-of-author
	  collect-yarns-about-keywords
	  all-keywords
	  )
  (use file.util)
  (use yogomacs.reel)
  (use yogomacs.reels.stitch-es)
  (use yogomacs.caches.yarn)
  )

(select-module yogomacs.yarn)


(define-constant stitch-es "stitch.es")

(define (collect-yarns-by-path path params config)
  (let ((stitch-es (make <stitch-es> 
		     :es-file (build-path (yarn-cache-dir config) 
					  stitch-es)
		     :params params
		     :config config)))
    (cons 'yarn-container
	  (append
	   (spin-for-path stitch-es path)
	   ))))

(define (collect-yarns-of-author author params config)
  #f)

(define (collect-yarns-about-keywords keywords params config)
  #f)

(define-method all-keywords (params config)
  #f)

(provide "yogomacs/yarn")