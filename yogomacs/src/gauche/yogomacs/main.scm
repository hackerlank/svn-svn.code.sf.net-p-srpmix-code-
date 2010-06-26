(define-module yogomacs.main
  (export yogomacs)
  (use yogomacs.route)
  (use text.html-lite)
  (use www.cgi)
  ;;
  (use yogomacs.handlers.root-dir)
;  (use yogomacs.handlers.sources-dir)
;  (use yogomacs.handlers.dists-dir)
  ;;
  (use yogomacs.handlers.deliver-css)
  ;;
  (use yogomacs.handlers.print-path)
  ;;
  )
(select-module yogomacs.main)

(define routing-table
  `(
    ;;
    (#/^\/$/ ,root-dir)
;    (#/^\/sources[\/]$/ ,soruces-dir)
;    (#/^\/sources\// ,soruces-dir)
;    (#/^\/dists[\/]$/ ,dists-dir)
;    (#/^\/dists\// ,dists-dir)
    ;;
    (#/^\/web\/css\/[^\/]+.css/ ,deliver-css)
    ;;
    (#/^.*$/ ,print-path)
    ))

(define (yogomacs params)
  (let1 path (cgi-get-parameter "path" params :default "/")
    (route routing-table path params)))

(provide "yogomacs/main")
