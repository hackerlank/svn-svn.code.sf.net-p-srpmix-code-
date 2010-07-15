(define-module yogomacs.caches.css
  (export css-cache-dir
	  prepare-css-cache)
  (use file.util)
  ;;
  (use yogomacs.flserver)
  (use font-lock.flclient)
  (use yogomacs.renderer)
  ;;
  (use yogomacs.cache)
  )

(select-module yogomacs.caches.css)

(define (css-cache-dir config)
  (format "/var/lib/yogomacs/~a/css"
	  (config 'spec-conf)))

(define (css-cache-storage config face style)
    (let* ((dir (css-cache-dir config))
	   (entry (face->css-file face style))
	   (file (build-path dir entry)))
      file))

(define (css-cache-avaiable? face style config)
    (file-exists? (css-cache-storage config face style)))

(define (css-cache-prepare! face style requires config)
  (let1 cssize (pa$ flclient-cssize face
		      (css-cache-dir config)
		      requires
		      ;; THIS SHOULD BE MERGEDTO fserver.
		      :verbose (config 'client-verbose)
		      :socket-name (config 'client-socket-name)
		      ;;
		      )
      (flserver cssize config)))

(define (prepare-css-cache config face style requires)
  (cache-kernel (pa$ css-cache-avaiable? face style config)
		(pa$ css-cache-prepare! face style requires config)
		#f))

(provide "yogomacs/caches/css")
