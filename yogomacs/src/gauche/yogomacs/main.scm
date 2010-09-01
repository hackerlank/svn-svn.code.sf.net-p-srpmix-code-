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
  ;;
  (use yogomacs.dests.root-dir)
  (use yogomacs.dests.css)
  (use yogomacs.dests.js)
  (use yogomacs.dests.yarn)
  (use yogomacs.dests.subjects)
  (use yogomacs.dests.debug)
  ;;
  )
(select-module yogomacs.main)

(define routing-table
  `((#/^\/$/ ,root-dir-dest)
    (#/^\/web\/css\/[^\/]+\.css/ ,css-dest)
    (#/^\/web\/js\/[^\/]+\.js/ ,js-dest)
    (#/^\/web\/yarn(?:\/.+)?$/ ,yarn-dest)
    (#/^\/web\/subjects$/ ,subjects-dest)
    ;;
    (#/^\/debug\/metavariables$/ ,print-metavariables)
    (#/^\/debug\/config$/ ,print-config)
    ;;
    (#/^\/.*/ ,root-dir-dest)
    ;; TODO: 403
    (#/^.*$/ ,print-path)
    ))

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
	      :on-error    (pa$ error-handler config))))

(define default-params '(("path" . "/")
			 ("range" . #f)
			 ("enum"  . #f)
			 ("yogomacs" . #f)))

(define (yogomacs params config)
  (let1 params (params->proc params default-params)
    (let1 path (params "path")
      (if config
	  (route routing-table path params (config->proc config))
	  (cgi-header :status "500 Internal server Error")))))

(provide "yogomacs/main")
