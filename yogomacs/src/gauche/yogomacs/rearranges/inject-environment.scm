(define-module yogomacs.rearranges.inject-environment
  (export inject-environment)
  (use yogomacs.util.sxml)
  (use util.list))

(select-module yogomacs.rearranges.inject-environment)


(define (inject-environment shtml kv-list)
  (apply install-meta shtml kv-list)
  )
(provide "yogomacs/rearranges/inject-environment")