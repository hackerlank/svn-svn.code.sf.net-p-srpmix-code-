(define-module yogomacs.render
  (export render)
  (use sxml.serializer)
  (use util.combinations))
(select-module yogomacs.render)

(define (render sxml)
  (srl:sxml->xml-noindent sxml))

(provide "yogomacs/render")