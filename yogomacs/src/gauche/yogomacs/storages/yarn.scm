(define-module yogomacs.storages.yarn
  (export yarn-cache-dir))

(select-module yogomacs.storages.yarn)

(define (yarn-cache-dir config)
   "/var/lib/yogomacs/yarn")

(provide "yogomacs/storages/yarn")
