(define-module yogomacs.css-cache
  (export css-cache-dir
	  prepare-css-cache)
  (use file.util)
  ;;
  (use font-lock.flclient)
  (use font-lock.harness)
  (use font-lock.flserver)
  ;;
  (use font-lock.harnesses.screen)
  (use font-lock.harnesses.xvnc)

  )

(select-module yogomacs.css-cache)

(define (css-cache-dir config)
  (format "/var/lib/yogomacs/~a/css_cache"
	  (cdr (assq 'spec-conf config))
	  )
  )

(define (prepare-css-cache config face style requires)
  (define (ping)
    (if (eq? (flclient-ping) 0) 
	#t
	#f))
  (define (launch-server)
    (let ((harness-object (choose-harness (cdr (assq 'harness config))))
	  (server-cmdline (emacs-cmdline #f #f #f)))
      (launch harness-object server-cmdline 
	      ;; TODO
	      '(:home "/var/www")
	      #t)))

  (let* ((dir (css-cache-dir config))
	 (entry (format "~a--~a.css" face style))
	 (file (build-path dir entry)))
    (define (cssize) (flclient-cssize face
				      dir
				      requires
				      ;;
				      :verbose (cdr (assq 'client-verbose config))
				      ;;
				      ))
    (if (file-exists? file)
	#t
	(let ((pong (ping)))
	  (unless pong (launch-server))
	  (let loop ((timeout (cdr (assq 'harness-timeout config)))
		     (pong (or pong (ping))))
	    (cond
	     (pong (cssize))
	     ((<= timeout 0) #f)
	     (else
	      (sys-sleep 1)
	      (loop (- timeout 1) (ping)))))))))

(provide "yogomacs/css-cache")