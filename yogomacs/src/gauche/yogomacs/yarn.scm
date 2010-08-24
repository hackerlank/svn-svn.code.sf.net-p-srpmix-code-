(define-module yogomacs.yarn
  (export collect-yarns-by-path
	  collect-yarns-of-author
	  collect-yarns-about-subjects
	  all-subjects
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
  (append-map (cute spin-for-path <> path)
	      (all-reals params config)))


(define (collect-yarns-of-author author params config)
  #f)

(define (collect-yarns-about-subjects subjects params config)
  #f)

;(subject n-annotations last-modified)
(define-method all-subjects (params config)
  (apply
   lset-union
   eq?
   (map all-subjects
	(all-reals params config))))

(provide "yogomacs/yarn")