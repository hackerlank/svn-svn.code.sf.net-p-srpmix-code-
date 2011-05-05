;;
;; Menu
;;
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


;;
;; Header line
;; 
(define (header-line-init)
  (let1 hl ($ "header-line-role")
    (hl.update (read-meta "role-name")))
  (let1 hl ($ "header-line-user")
    (hl.update (read-meta "user-name")))
  )
  
;;
;; Highlight
;;
(define (highlight-choose-element target)
  (cond
   ((string? target) ($ target))
   ((not target) #f)
   (else target)))
(define (highlight target)
  (if-let1 elt (highlight-choose-element target)
	   (elt.addClassName "highlight")
	   #f))
(export "yhl" highlight)

(define (unhighlight target)
  (if-let1 elt (highlight-choose-element target)
	   (elt.removeClassName "highlight")
	   #f))
(export "yuhl" unhighlight)

;;
;; Positioning
;;
(define (line-number-at target) 
  (let1 elt ($ target)
    (let1 linum (elt.previous ".linum")
      (if (js-undefined? linum)
	  #f
	  (let1 id (linum.identify)
	    (if (string-prefix? "L:" id)
		(let1 id (substring id 2 (string-length id))
		  (string->number id))
		#f))))))
