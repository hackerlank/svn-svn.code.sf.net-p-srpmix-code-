(define-module yogomacs.caches.css
  (export css-cache-dir
	  prepare-css-cache)
  (use file.util)
  ;;
  (use yogomacs.flserver)
  (use font-lock.flclient)
  (use yogomacs.renderer)
  )

(select-module yogomacs.caches.css)

(define (css-cache-dir config)
  (format "/var/lib/yogomacs/~a/css"
	  (config 'spec-conf)))

(define (prepare-cache config file action)
  (if (file-exists? file)
      #t
      (flserver action config)))

(define (prepare-css-cache config face style requires)
  (let* ((dir (css-cache-dir config))
	 (entry (face->css-file face style))
	 (file (build-path dir entry))
	 (cssize (pa$ flclient-cssize face
		      dir
		      requires
		      ;;
		      :verbose (config 'client-verbose)
		      ;;
		      )))
    (prepare-cache config file cssize)))

(provide "yogomacs/caches/css")
