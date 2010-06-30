(define-module yogomacs.handlers.sources-dir
  (export sources-dir-handler)
  ;;
  (use yogomacs.route)
  (use yogomacs.path)
  (use yogomacs.handlers.dir)
  (use yogomacs.handlers.pkg-dir)
  ;;
  )
(select-module yogomacs.handlers.sources-dir)

(define routing-table
  `(
    (#/^\/sources$/ ,dir-handler)
    (#/^\/sources\/[a-zA-Z0-9]$/ ,dir-handler)
    (#/^\/sources\/[a-zA-Z0-9]\// ,pkg-dir-handler)))

(define (sources-dir-handler path params config)
  (route routing-table (compose-path path) params config))

(provide "yogomacs/handlers/sources-dir")