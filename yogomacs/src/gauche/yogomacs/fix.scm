(define-module yogomacs.fix
  (export fix)
  (use sxml.serializer))
(select-module yogomacs.fix)

(define (fix sxml)
  (srl:sxml->xml-noindent sxml))

(provide "yogomacs/fix")
