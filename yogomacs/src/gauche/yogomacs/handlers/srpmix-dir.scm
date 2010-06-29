(define-module yogomacs.handlers.srpmix-dir
  (export srpmix-dir-handler)
  (use yogomacs.route)
  (use yogomacs.path)
  (use yogomacs.handlers.dir)
  )
(select-module yogomacs.handlers.srpmix-dir)

(define (handler path params config)
  (dir-handler path params config
	       '((#/^plugins$/ #f #f)
		 (#/^vanilla$/ #f #f))))

(define routing-table
  `((#/^\/sources\/[a-zA-Z0-9]\/[^\/]+\/([^^\/]+)$/ ,handler)
    (#/^\/sources\/[a-zA-Z0-9]\/[^\/]+\/([^^\/]+)\/pre-build$/ ,dir-handler)
    (#/^\/sources\/[a-zA-Z0-9]\/[^\/]+\/([^^\/]+)\/archives$/ ,dir-handler)
    ;; (#/^\/sources\/[a-zA-Z0-9]\/[^\/]+/([^^\/]+)\/vanilla$/ ,dir-handler)
    ))

(define (srpmix-dir-handler path params config)
  (route routing-table (compose-path path) params config))

(provide "yogomacs/handlers/srpmix-dir")