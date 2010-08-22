(define-module yogomacs.yarn
  (export collect-yarns-by-path
	  collect-yarns-of-author
	  collect-yarns-about-keywords
	  all-keywords
	  )
  (use file.util)
  (use srfi-1)
  (use yogomacs.reel)
  (use yogomacs.reels.stitch-es)
  (use yogomacs.caches.yarn)
  )

(select-module yogomacs.yarn)


(define-constant stitch-es "stitch.es")

(define (all-reals params config)
  (list
   (make <stitch-es> 
     :es-file (build-path (yarn-cache-dir config) 
			  stitch-es)
     :params params
     :config config)))

(define (collect-yarns-by-path path params config)
  (cons 'yarn-container
	(append-map (cute spin-for-path <> path)
		    (all-reals params config))))


(define (collect-yarns-of-author author params config)
  #f)

(define (collect-yarns-about-keywords keywords params config)
  #f)

(define-method all-keywords (params config)
  (list 'yarn-keywords
	(apply
	 lset-union
	 eq?
	 (map all-keywords
	      (all-reals params config)))))

(provide "yogomacs/yarn")