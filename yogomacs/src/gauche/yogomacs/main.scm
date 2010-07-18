(define-module yogomacs.main
  (export yogomacs-cgi)
  (use www.cgi)
  ;;
  (use yogomacs.route)
  (use yogomacs.config)
  (use yogomacs.reply)
  (use yogomacs.error)
  ;;
  (use yogomacs.dests.root-dir)
  (use yogomacs.dests.sources-dir)
;  (use yogomacs.dests.dists-dir)
  (use yogomacs.dests.css)
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
  ;; config could be #f.
  (if config
      config
      config))

(define (yogomacs-cgi)
  (debug-print-width #f)
  (sys-putenv "HOME" "/var/www")
  (let1 config (install-constants (load-config))
    (cgi-main (cute yogomacs <> config)
	      :output-proc reply
	      :on-error    error-handler)))

(define (yogomacs params config)
  (let ((path (cgi-get-parameter "path" params :default "/")))
    (if config
	(route routing-table path params (config->proc config))
	(cgi-header :status "500 Internal server Error"))))

(provide "yogomacs/main")
