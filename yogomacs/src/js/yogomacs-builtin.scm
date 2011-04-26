;(define (prependClassName elt class-name)
;  (let1 original-class-name (js-field elt "className")
;    (js-field-set! elt "className" class-name)
;    (elt.addClassName original-class-name)))

(define (highlight id)
  (let1 elt ($ id)
    (elt.addClassName "highlight")))
(export "yhl" highlight)
(define (unhighlight id)
  (let1 elt ($ id)
    (elt.removeClassName "highlight")))
(export "yuhl" unhighlight)

(define (jump-lazy hash)
  (when (and (string? hash)
	     (< 0 (string-length hash))
	     (eq? (string-ref hash 0) #\#))
    (let* ((id (substring hash 1 (string-length hash)))
	   (elt ($ id)))
      ;; Not portable
      (elt.scrollIntoView))))

(define (load-lazy url params)
  (let1 options (alist->object `((method . "get")
				 (parameters . ,params)
				 (onFailure . ,(lambda ()
						 (alert "Eerror in load-lazy")))
				 (onComplete . ,(pa$ run-hook find-file-post-hook url params))))
    (js-new Ajax.Updater "buffer" url options)))

(define (focus) 
  (let1 elt ($ "minibuffer") 
    (elt.focus)
    (elt.select)))


