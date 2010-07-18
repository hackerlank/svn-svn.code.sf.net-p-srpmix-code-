(define-module yogomacs.fix
  (export fix)
  (use sxml.serializer)
  (use text.tree))
(select-module yogomacs.fix)

(define (fix sxml . rearrangers)
  (srl:sxml->xml-noindent 
   ((apply compose rearrangers) sxml)))

(provide "yogomacs/fix")
