;;
;; Full screen mode
;;
(define full-screen-extra-elements '("header-line"
				     "modeline"
				     "modeline-control"
				     "minibuffer-shell"
					;"minibuffer"
				     "minibuffer-prompt-shell"
					;"minibuffer-prompt"
				     ))
(define full-screen-id "toggle-full-screen")

(define (full-screen-action new-status)
  (define (action 
	   new-status
	   indicator
	   top
	   bottom
	   position
	   z-index)
    (for-each (lambda (id)
		(let1 elt ($ id)
		  (elt.update (sxml->xhtml indicator))))
	      `(,full-screen-id))
    (for-each (lambda (id)
		(let1 elt ($ id)
		  (if new-status
		      (elt.show)
		      (elt.hide))))
	      full-screen-extra-elements)
    (let1 elt ($ "buffer")
      (elt.setStyle (alist->object `((top . ,top)
				     (bottom . ,bottom)
				     (position . ,position)
				     (z-index . ,z-index))))))
  (let ((on-params '(#t ">" "1.2em" "2.2em" "fixed" "0"))
	(off-params '(#f  "<" "0.0em" "0.0em" "static" "-1")))
    (let1 p (if new-status
		on-params 
		off-params)
      (apply action p))))

(define (full-screen-init minor-mode)
  (set! full-screen-mode (not (read-meta "full-screen-mode")))
  (toggle-full-screen-mode))
  
(define-minor-mode full-screen
  :update-cookie #t
  :action full-screen-action
  :init full-screen-init)
