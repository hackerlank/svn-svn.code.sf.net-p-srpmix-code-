(define-module yogomacs.overlays
  (extend yogomacs.overlay)

  (use yogomacs.overlays.text-file)
  (use yogomacs.overlays.not-implemented)
  )

(select-module yogomacs.overlays)

(provide "yogomacs/overlays")
