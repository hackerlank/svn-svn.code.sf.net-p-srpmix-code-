(define ($ elt)
  ((js-field *js* "$") elt))
(define ($$ elt)
  ((js-field *js* "$$") elt))
(define (<- elt)
  ((js-field *js* "$F") elt))
(define (-> val elt)
  (let1 field ($ elt)
    (field.setValue val)))

(define (html-escape-string str)
  (str.escapeHTML))

(define (classes-of target)
  (let1 elt ($ target)
    (let1 str (elt.readAttribute "class")
      (cond
       ((not str) (list))
       ((js-undefined? str) (list))
       (else
	(string-split str " 	"))))))
    