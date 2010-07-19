(define-module yogomacs.face
  (export face->css-route
	  face->css-file))
(select-module yogomacs.face)

(define (face->css-route face style css-prefix)
  (format "~a/~a" css-prefix (face->css-file face style)))
(define (face->css-file face style)
  (format "~a--~a.css" face style))

(provide "yogomacs/face")