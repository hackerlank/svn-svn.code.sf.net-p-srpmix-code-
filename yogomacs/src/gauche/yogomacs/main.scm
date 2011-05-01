(define-module yogomacs.main
  (export yogomacs-cgi
	  yogomacs)
  (use www.cgi)
  ;;
  (use yogomacs.route)
  (use yogomacs.config)
  (use yogomacs.reply)
  (use yogomacs.error)
  (use yogomacs.params)
  (use yogomacs.overlay)
  (use yogomacs.overlays)
  ;;
  (use yogomacs.dests.root-dir)
  (use yogomacs.dests.css)
  (use yogomacs.dests.js)
  (use yogomacs.dests.tag)
  (use yogomacs.dests.yarn)
  (use yogomacs.dests.subjects)
  (use yogomacs.dests.debug)
  )
(select-module yogomacs.main)

(define (install-overlays base overlays)
  (fold (lambda (kar kdr) 
	  (if-let1 r (overlay->route kar)
		   (cons r kdr)
		   kdr))
	base overlays))
	

(define (routing-table config)
  (let1 base `((#/^\/$/ ,root-dir-dest)
	       (#/^\/web\/css\/[^\/]+\.css/ ,css-dest)
	       (#/^\/web\/js\/[^\/]+\.js/ ,js-dest)
	       (#/^\/web\/tag(?:\/.+)?$/ ,tag-dest)
	       (#/^\/web\/yarn(?:\/.+)?$/ ,yarn-dest ,yarn-sink)
	       (#/^\/web\/subjects$/ ,subjects-dest)
	       ;;
	       (#/^\/debug\/metavariables$/ ,print-metavariables)
	       (#/^\/debug\/config$/ ,print-config)
	       ;;
	       (#/^\/.*/ ,root-dir-dest)
	       ;; TODO: 403
	       ;; (#/^.*$/ ,print-path)
	       )
    (if-let1 overlays (config 'overlays)
	     (install-overlays base overlays)
	     base)))

(define (install-constants config)
  ;; config could be #f.
  (if config
      (cons `(version . "version") config)
      config))

(define (yogomacs-cgi)
  (debug-print-width #f)
  (sys-putenv "HOME" "/var/www")
  (set! (port-buffering (current-error-port)) :line)
  (let1 config (install-constants (load-config #f))
    (cgi-main (cute yogomacs <> config)
	      :output-proc reply
	      :on-error    (pa$ error-handler config)
	      :merge-cookies #t
	      )))

(define default-params `(("path"     . ,(or (cgi-get-metavariable "YOGOMACS_PATH") 
					    "/"))
			 ("range"    . #f)
			 ("enum"     . #f)
			 ("shell" .    #f)))

(define (yogomacs params config)
  params
  (let1 params (params->proc params default-params)
    (let1 path (params "path")
      (if config
	  (let1 config  (config->proc config)
	    (route (routing-table config)
		   path
		   params
		   config))
	  (cgi-header :status "500 Internal Server Error")))))

(provide "yogomacs/main")
