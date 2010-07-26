(define-module yogomacs.caches.js
  (export js-cache-dir))

(select-module yogomacs.caches.js)

(define (js-cache-dir config)
   "/var/lib/yogomacs/js")

(provide "yogomacs/caches/js")
