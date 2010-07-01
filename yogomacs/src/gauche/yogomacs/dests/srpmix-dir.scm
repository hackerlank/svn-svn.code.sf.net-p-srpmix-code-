(define-module yogomacs.dests.srpmix-dir
  (export srpmix-dir-dest)
  (use yogomacs.route)
  (use yogomacs.path)
  (use yogomacs.dests.fs)
  (use yogomacs.dests.dir)
  (use yogomacs.access)
  (use srfi-1)
  ;;
  (use file.util)
  (use www.cgi)
  (use yogomacs.dests.debug)
  (use yogomacs.caches.css)
  (use yogomacs.fix)
  (use yogomacs.dests.css)
  )
(select-module yogomacs.dests.srpmix-dir)

(define (dest path params config)
  (dir-dest path params config
	       '((#/^plugins$/ #f #f)
		 (#/^vanilla$/ #f #f))))

(define routing-table
  `((#/^\/sources\/[a-zA-Z0-9]\/[^\/]+\/([^^\/]+)$/               ,dest)
    (#/^\/sources\/[a-zA-Z0-9]\/[^\/]+\/([^^\/]+)\/pre-build$/    ,dir-dest)
    (#/^\/sources\/[a-zA-Z0-9]\/[^\/]+\/([^^\/]+)\/pre-build\/.*/ ,fs-dest)
    (#/^\/sources\/[a-zA-Z0-9]\/[^\/]+\/([^^\/]+)\/archives$/     ,dir-dest)
    (#/^\/sources\/[a-zA-Z0-9]\/[^\/]+\/([^^\/]+)\/archives\/.*/  ,fs-dest)
    ;; (#/^\/sources\/[a-zA-Z0-9]\/[^\/]+/([^^\/]+)\/vanilla$/ ,dir-dest)
    ))

(define (srpmix-dir-dest path params config)
  (route routing-table (compose-path path) params config))

(provide "yogomacs/dests/srpmix-dir")