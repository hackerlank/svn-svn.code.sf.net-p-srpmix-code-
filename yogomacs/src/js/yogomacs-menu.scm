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

(define-macro (define-menu selector . items)
  `(let1 f (menu-build (map (lambda (item)
			      (menu-build-item (car item) (cadr item)))
			    (list ,@items)))
     (add-hook find-file-post-hook
	       (lambda args
		 (f
		  (string-append "." (symbol->string ',selector)))))))
