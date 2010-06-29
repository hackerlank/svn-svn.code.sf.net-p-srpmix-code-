(define-module yogomacs.main
  (export yogomacs)
  (use yogomacs.route)
  (use yogomacs.config)
  (use www.cgi)
  ;;
  (use yogomacs.handlers.root-dir)
  (use yogomacs.handlers.sources-dir)
;  (use yogomacs.handlers.dists-dir)
  ;;
  (use yogomacs.handlers.deliver-css)
  ;;
  (use yogomacs.handlers.debug)
  ;;
  )
(select-module yogomacs.main)

(define routing-table
  `((#/^\/$/ ,root-dir-handler)
    (#/^\/sources(?:\/.+)?$/ ,sources-dir-handler)
    ;; (#/^\/dists[\/]$/ ,dists-dir)
    ;; (#/^\/dists\// ,dists-dir)
    ;;
    (#/^\/web\/css\/[^\/]+.css/ ,deliver-css-handler)
    ;;
    (#/^\/web\/debug\/metavariables$/ ,print-metavariables)
    (#/^\/web\/debug\/config$/ ,print-config)
    (#/^.*$/ ,print-path)
    ))

(define (yogomacs params)
  (sys-putenv "HOME" "/var/www")
  (let ((path (cgi-get-parameter "path" params :default "/"))
	(config (load-config)))
    (if config
	(route routing-table path params config)
	(cgi-header :status "500 Internal server Error")
	)))

(provide "yogomacs/main")
