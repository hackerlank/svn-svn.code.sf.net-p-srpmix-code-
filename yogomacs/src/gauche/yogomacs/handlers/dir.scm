(define-module yogomacs.handlers.dir
  (export prepare-dired-faces)
  (use yogomacs.dired)
  (use yogomacs.css-cache)
  (use util.combinations)
  )
(select-module yogomacs.handlers.dir)

(define (prepare-dired-faces config)
  (for-each
   (lambda (face-style)
     (prepare-css-cache config (car face-style) (cadr face-style) '(dired)))
   (cartesian-product `(,dired-faces
			,dired-styles))))


;; ( (#/pattern0/ make-url) (#/pattern1/ #f) )

(provide "yogomacs/handlers/dir")