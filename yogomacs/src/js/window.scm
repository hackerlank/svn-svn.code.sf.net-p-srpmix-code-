(define-macro (define-menu selector . items)
  `(let1 f (menu-build (map (lambda (item)
			      (menu-build-item (car item) (cadr item)))
			    (list ,@items)))
     (add-hook find-file-post-hook
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
