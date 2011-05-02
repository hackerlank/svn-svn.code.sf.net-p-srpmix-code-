(define-macro (define-menu selector . items)
  `(let1 f (menu-build (map (lambda (item)
			      (menu-build-item (car item) (cadr item)))
			    (list ,@items)))
     (add-hook! find-file-post-hook
		(lambda args
		  (f
		   (string-append "." (symbol->string ',selector)))))))

(define (menu-build-item name callback)
  (alist->object `((name . ,name) (callback . ,callback))))

(define (menu-build items)
  (let ((template (js-new Array (length items))))
    (let loop ((i 0)
	       (items items))
      (unless (null? items)
	(js-field-set! template i (car items))
	(loop (+ i 1) (cdr items))))
    (lambda (selector)
      (js-new Proto.Menu (alist->object
			  `((selector . ,selector)
			    (className . "menu desktop")
			    (menuItems . ,template)))))))



(define (lfringe-prepare-draft-text-box e)
  (stitch-prepare-draft-text-box (e.findElement ".lfringe")))

(define-menu lfringe 
  `("Make Text Annotation" ,lfringe-prepare-draft-text-box)
  )


(define (header-line-init)
  (let1 hl ($ "header-line-role")
    (hl.update (read-meta "role-name")))
  (let1 hl ($ "header-line-user")
    (hl.update (read-meta "user-name")))
  )
  
;;
;; Full screen mode
;;
(define full-screen-mode-var "full-screen-mode")
(define full-screen-mode #f)
(define (full-screen-mode?)  full-screen-mode)
(define full-screen-extra-elements '("header-line"
				     "modeline"
				     "modeline-control"
				     "minibuffer-shell"
					;"minibuffer"
				     "minibuffer-prompt-shell"
					;"minibuffer-prompt"
				     ))
(define toggle-full-screen-id "toggle-full-screen")
(define (toggle-full-screen-mode . new-status)
  (define (toggle-full-screen-mode0 
	   new-status
	   indicator
	   top
	   bottom
	   position
	   z-index)
    (set! full-screen-mode new-status)
    (cookie-set! full-screen-mode-var full-screen-mode)
    (for-each (lambda (id)
		(let1 elt ($ id)
		  (elt.update (sxml->xhtml indicator))))
	      `(,toggle-full-screen-id))
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
    (let1 p (if (if (null? new-status) 
		    (not full-screen-mode)
		    (car new-status))
		on-params 
		off-params)
      (apply toggle-full-screen-mode0 p))))
