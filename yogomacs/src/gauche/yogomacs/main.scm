(define-module yogomacs.main
  (export yogomacs)
  (use yogomacs.route)
  (use yogomacs.config)
  (use www.cgi)
  ;;
  (use yogomacs.dests.root-dir)
  (use yogomacs.dests.sources-dir)
;  (use yogomacs.dests.dists-dir)
  ;;
  (use yogomacs.dests.css)
  ;;
  (use yogomacs.dests.debug)
  ;;
  )
(select-module yogomacs.main)

(define routing-table
  `((#/^\/$/ ,root-dir-dest)
    (#/^\/sources(?:\/.+)?$/ ,sources-dir-dest)
    ;; (#/^\/dists[\/]$/ ,dists-dir)
    ;; (#/^\/dists\// ,dists-dir)
    ;;
    (#/^\/web\/css\/[^\/]+.css/ ,css-dest)
    ;;
    (#/^\/debug\/metavariables$/ ,print-metavariables)
    (#/^\/debug\/config$/ ,print-config)
    ;;
    (#/^.*$/ ,print-path)
    ))

(define (install-constants config)
  config)

(define (init)
  (sys-putenv "HOME" "/var/www")
  (debug-print-width #f))

(define (yogomacs argv params)
  (init)
  (let ((path (cgi-get-parameter "path" params :default "/"))
	(config (load-config)))
    (if config
	(route routing-table path params 
	       (config->proc (install-constants config)))
	(cgi-header :status "500 Internal server Error")
	)))

(provide "yogomacs/main")
