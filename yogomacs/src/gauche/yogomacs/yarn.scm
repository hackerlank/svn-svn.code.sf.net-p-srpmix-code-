(define-module yogomacs.yarn
  (export collect-yarns-by-path
	  collect-yarns-of-author
	  collect-yarns-about-subjects
	  cast-yarns-for-path
	  all-subjects
	  )
  (use file.util)
  (use srfi-1)
  (use srfi-19)
  (use yogomacs.reel)
  (use yogomacs.reels.stitch-es)
  (use yogomacs.storages.yarn)
  ;;
  (use gauche.fcntl)
  (use yogomacs.storages.yarn)
  )

(select-module yogomacs.yarn)


(define-constant stitch-es "stitch.es")

(define (reel-for-user params config)
  (and-let* ((user (params "user")))
    (make <stitch-es> 
      :es-file (build-path (yarn-cache-dir config) 
			   #`",(ref user 'name).es")
      :params params
      :config config)))

(define (all-reals params config)
  (delete
   #f 
   (list
    (reel-for-user params config)
    (make <stitch-es> 
      :es-file (build-path (yarn-cache-dir config) 
			   stitch-es)
      :params params
      :config config)
    )))

(define (collect-yarns-by-path path params config)
  (append-map (cute spin-for-path <> path)
	      (all-reals params config)))


(define (collect-yarns-of-author author params config)
  #f)

(define (collect-yarns-about-subjects subjects params config)
  #f)

(define (merge-entry! htable old-entry new-entry)
  (let ((old-props (cdr old-entry))
	(new-props (cdr new-entry)))
    (set! (ref  old-props 0) (+ (ref old-props 0) 
				(ref (cdr new-props) 0)))
    (set! (ref old-props 1) (+ (ref old-props 1) 
			       (ref new-props 1) 
			       ))
    (set! (ref old-props 2) (if (time<? (ref old-props 2) 
					(ref new-props 2) )
				(ref new-props 2)
				(ref old-props 2)))))

(define-method all-subjects (params config)
  (hash-table-map
   (fold
    (lambda (reel htable)
      (for-each
       (lambda (new-entry)
	 ;; (subject . #(nlink size utc))
	 (let1 old-entry (hash-table-get htable (car new-entry) #f)
	   (if old-entry
	       (merge-entry! htable old-entry new-entry)
	       (hash-table-put! htable (car new-entry) (cdr new-entry)))))
       (all-subjects reel))
      htable)
    (make-hash-table 'eq?)
    (all-reals params config))
   (lambda (k v)
     (cons k v))
   ))

(define (cast-yarn-for-path path yarn params config)
  (if (params "user")
      (wind-for-path (reel-for-user params config) path yarn)
      ;; TODO
      #f))


(define (cast-yarns-for-path path yarns params config)
  (for-each
   (cute cast-yarn-for-path path <> params config)
   yarns))


(provide "yogomacs/yarn")