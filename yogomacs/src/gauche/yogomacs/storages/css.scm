(define-module yogomacs.storages.css
  (export css-cache-dir
	  prepare-css-cache
	  call-with-input-css-file)
  (use file.util)
  ;;
  (use yogomacs.flserver)
  (use font-lock.flclient)
  (use yogomacs.face)
  ;;
  (use yogomacs.cache)
  )

(select-module yogomacs.storages.css)

(define (css-cache-dir config)
  (format "/var/lib/yogomacs/css/~a"
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

(define (css-file->face&style css-file)
  (let1 m (#/^(.*)--(.*)\.css$/ (sys-basename css-file))
    (values (m 1) (m 2))))
    
(define (call-with-input-file-with-inclusion path handler expand-path)
  (if (file-is-readable? path)
      (handler
       (open-input-string
	(apply string-append (map (lambda (line)
				    (string-append
				     (rxmatch-cond
				       ((#/@include\( *([^(),]+) *, *([^(),]+) *\)/ line)
					(#f face style)
					(or 
					 (call-with-input-file-with-inclusion (expand-path face style)
									      port->string
									      expand-path)
					 ""))
				       (else
					line)) "\n"))
				  (call-with-input-file path port->string-list)))))
      #f))

(define (call-with-input-css-file path handler config)
  (call-with-input-file-with-inclusion path handler
				       (pa$ css-cache-storage config)))

(provide "yogomacs/storages/css")
