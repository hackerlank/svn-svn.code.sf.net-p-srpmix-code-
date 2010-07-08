(define-module yogomacs.renderer
  (export face->css-route
	  face->css-file
	  <renderer-error>))
(select-module yogomacs.renderer)

(define-condition-type <renderer-error> <error>
   #f
  (status))

(define (face->css-route face style css-prefix)
  (format "~a/~a" css-prefix (face->css-file face style)))
(define (face->css-file face style)
  (format "~a--~a.css" face style))


(provide "yogomacs/renderer")