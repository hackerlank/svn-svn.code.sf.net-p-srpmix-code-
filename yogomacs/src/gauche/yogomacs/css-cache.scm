(define-module yogomacs.css-cache
  (export css-cache-dir
	  prepare-css-cache)
  (use file.util)
  ;;
  (use yogomacs.flserver)
  (use font-lock.flclient)
  )

(select-module yogomacs.css-cache)

(define (css-cache-dir config)
  (format "/var/lib/yogomacs/~a/css_cache"
	  (cdr (assq 'spec-conf config))
	  )
  )

(define (prepare-cache config file action)
  (if (file-exists? file)
      #t
      (flserver action config)))

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
    (prepare-cache config file cssize)))

(provide "yogomacs/css-cache")
