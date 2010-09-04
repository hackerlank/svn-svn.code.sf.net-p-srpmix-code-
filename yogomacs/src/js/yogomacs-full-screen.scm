(define full-screen #f)
(define (full-screen?)  full-screen)
(define extra-elements '("header-line"
			 "modeline"
			 "modeline-control"
			 "minibuffer-shell"
			 ;"minibuffer"
			 "minibuffer-prompt-shell"
			 ;"minibuffer-prompt"
			 ))
(define (toggle-full-screen)
  (if full-screen
      (leave-full-screen)
      (enter-full-screen)))

(define (enter-full-screen)
  (set! full-screen #t)
  (for-each (lambda (id)
	      (let1 elt ($ id)
		(elt.update (sxml->xhtml "<"))))
	    '("toggle-full-screen"))
  (for-each (lambda (id)
	      (let1 elt ($ id)
		(elt.hide)))
	    extra-elements)
  (let1 elt ($ "buffer")
    (elt.setStyle (alist->object '((top . "0.0em")
				   (bottom . "0.0em")
				   (position . "static")
				   (z-index . "-1"))))))

(define (leave-full-screen)
  (set! full-screen #f)
  (for-each (lambda (id)
	      (let1 elt ($ id)
		(elt.update (sxml->xhtml ">"))))
	    '("toggle-full-screen"))
  (for-each (lambda (id)
	      (let1 elt ($ id)
		(elt.show)))
	    extra-elements)
  (let1 elt ($ "buffer")
    (elt.setStyle (alist->object '((top . "1.2em")
				   (bottom . "2.2em")
				   (position . "fixed")
				   (z-index . "0"))))))
