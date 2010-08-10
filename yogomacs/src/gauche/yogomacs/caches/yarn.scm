(define-module yogomacs.caches.yarn
  (export yarn-cache-dir))

(select-module yogomacs.caches.yarn)

(define (yarn-cache-dir config)
   "/var/lib/yogomacs/yarn")

(provide "yogomacs/caches/yarn")
