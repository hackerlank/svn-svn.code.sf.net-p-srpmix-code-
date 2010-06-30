(define-module yogomacs.dests.sources-dir
  (export sources-dir-dest)
  ;;
  (use yogomacs.route)
  (use yogomacs.path)
  (use yogomacs.dests.dir)
  (use yogomacs.dests.pkg-dir)
  ;;
  )
(select-module yogomacs.dests.sources-dir)

(define routing-table
  `(
    (#/^\/sources$/ ,dir-dest)
    (#/^\/sources\/[a-zA-Z0-9]$/ ,dir-dest)
    (#/^\/sources\/[a-zA-Z0-9]\// ,pkg-dir-dest)))

(define (sources-dir-dest path params config)
  (route routing-table (compose-path path) params config))

(provide "yogomacs/dests/sources-dir")