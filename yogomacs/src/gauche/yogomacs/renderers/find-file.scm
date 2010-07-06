(define-module yogomacs.renderers.find-file
  (export find-file-faces
	  ;find-file
	  )
  (use yogomacs.flserver)
  (use font-lock.flclient))

(select-module yogomacs.renderers.find-file)

(define find-file-faces
  '(
    default 
    font-lock-comment-delimiter-face
    font-lock-comment-face
    font-lock-constant-face
    font-lock-doc-face
    font-lock-function-name-face
    font-lock-keyword-face
    font-lock-negation-char-face
    font-lock-preprocessor-face
    font-lock-string-face
    font-lock-type-face
    font-lock-variable-name-face
    highlight
    lfringe
    linum
    rfringe
    ))

;; ...

(provide "yogomacs/renderers/find-file")