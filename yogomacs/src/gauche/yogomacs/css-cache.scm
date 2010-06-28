(define-module yogomacs.css-cache
  (export css-cache-dir
	  prepare-css-cache)
  (use file.util)
  ;;
  (use font-lock.flclient)
  )

(select-module yogomacs.css-cache)

(define (css-cache-dir config)
  (format "/var/lib/yogomacs/~a/css_cache"
	  (cdr (assq 'spec-conf config))
	  )
  )

(define (prepare-css-cache config face style requires)
  (let* ((dir (css-cache-dir config))
	 (entry (format "~a--~a.css" face style))
	 (file (build-path dir entry))
	 (cssize (lambda ()
		   (flclient-cssize face
				    dir
				    requires
				    ;;
				    :verbose (cdr (assq 'client-verbose config))
				    ;;
				    ))))
    (if (file-exists? file)
	#t
	(flserver cssize config))))

(provide "yogomacs/css-cache")