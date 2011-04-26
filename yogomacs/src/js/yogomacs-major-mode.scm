(define major-mode #f)
(define has-tag? #f)

;(define-major-mode c-mode
;  :is-separator (lambda (c) ...)
;  :symbol-at (lambda (event) ...)
;  :...)

(define major-mode-table (make-hashtable))
(define (make-major-mode-record major-mode 
				symbol-at)
  (list major-mode symbol-at))
				
(define-macro (define-major-mode major-mode symbol-at)
  `(hashtable-put! major-mode-table (quote ,major-mode) 
		   (make-major-mode-record (quote ,major-mode)
					   ,symbol-at)))

(define (setup-major-mode . any)
  (define (read-meta name)
    (let* ((elt ($ name))
	   (data (read-from-string elt.innerHTML)))
      (elt.remove)
      data))
  (set! major-mode (read-meta "major-mode"))
  (set! has-tag? (read-meta "has-tag?"))
  (when has-tag?
    (let* ((Event (js-field *js* "Event"))
	   (window (js-field *js* "window")))
      (Event.observe window "click" find-tag)

      )))

(define built-in-classes '(
			   "header-line"
			   "header-line-user"
			   "header-line-role"
			   "header-line-control"
			   "buffer"
			   "contents"
			   "linum"
			   "lfringe"
			   "rfringe"
			   ))

(define (wrong-tag-target? target)
  (let1 elt ($ target)
    (or (any (lambda (class)
	       (target.hasClassName class))
	     built-in-classes)
	(equal? target.tagName "A")
	(equal? target.tagName "a")
	(target.hasClassName "comment")
	(not (js-undefined? (elt.up "yarn-div")))
	)))

(define (symbol-at target offset-rate)
  (let1 str target.innerHTML
    (let* ((separators '(#\space #\tab))
	   (split-pos (inexact->exact (ceiling (* offset-rate 
						  (string-length str)))))
	   (before (substring str 0 split-pos))
	   (after (substring str split-pos (string-length str)))
	   (before-filtered (let loop ((before (reverse (string->list before)))
				       (result (list)))
			      (cond
			       ((null? before)
				(list->string result))
			       ((member (car before) separators)
				(loop (list) result))
			       (else
				(loop (cdr before) (cons (car before) result))))))
	   (after-filtered (let loop ((after (string->list after))
				      (result (list)))
			     (cond
			      ((null? after)
			       (list->string (reverse result)))
			      ((member (car after) separators)
			       (loop (list) result))
			      (else
			       (loop (cdr after) (cons (car after) result)))))))
      (let1 result (string-append before-filtered after-filtered)
	(if (equal? result "")
	    #f
	    result)))))

(define (find-tag event)
  (let1 target event.target
    (let* ((point-px event.pageX)
	   (elt ($ target))
	   (offset-px (let1 o (elt.viewportOffset)
			o.left))
	   (width-px (elt.getWidth))
	   (offset-rate (/ (* 1.0 (- point-px offset-px))
			   width-px)))
      (unless (wrong-tag-target? target)
	(event.stop)
	(let ((symbol (symbol-at target offset-rate))
	      (url (contents-url)))
	  (if symbol
	      (require-tag url symbol major-mode target)
	      (alert "No symbol under point")
	  ))))))

(define (contents-url)
  (let* ((location (js-field *js* "location"))
	 (pathname (js-field location "pathname")))
    (substring pathname
	       (string-length shell-dir)
	       (string-length pathname))))
