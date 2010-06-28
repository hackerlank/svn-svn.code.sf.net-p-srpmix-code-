(define-module yogomacs.render
  (export render)
  (use sxml.serializer))
(select-module yogomacs.render)

(define (render sxml)
  (srl:sxml->xml-noindent sxml))

(provide "yogomacs/render")