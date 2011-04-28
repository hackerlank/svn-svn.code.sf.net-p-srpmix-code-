(define-module yogomacs.rearranges.tag-integrates
  (export tag-integrates)
  (use yogomacs.util.sxml)
  )

(select-module yogomacs.rearranges.tag-integrates)

(define (tag-integrates sxml has-tag?)
  (install-meta sxml :has-tag? (boolean has-tag?)))

(provide "yogomacs/rearranges/tag-integrates")