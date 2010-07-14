(define-module yogomacs.caches.shtml
  (export shtml-cache-dir))

(select-module yogomacs.caches.shtml)

(define (shtml-cache-dir config)
  "/var/cache/yogomacs/shtml")

(provide "yogomacs/caches/shtml")
