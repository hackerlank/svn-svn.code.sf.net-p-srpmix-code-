#|
<div class="default" id="bs-console"></div>
<script src="file:///home/jet/workspace/biwascheme/lib/biwascheme.js">
(load "file:///home/jet/workspace/srpmix/yogomacs/trunk/yogomacs.scm")
</script>
|#

;;
;; Utilities
;;
(define (error msg)
  (let1 code (string-append "throw new Error(\"yogomacs: " 
			   msg
			   "\");")
    (js-eval code)))

;; biwascheme doesn't have format
(define (message msg)
  (display (string-append msg "\n")))


(define (current-buffer) (js-eval "document"))


;;
;; ???
;;
(define (elements-of-class-of pat) 
  (let1 code (string-append "$$('" pat "').to_list();")
    (js-eval code)))

;;
;; Initializer
;;
(define yogomacs-initialized? #f)
(define (init-yogomacs)
  (unless yogomacs-initialized?
    (set! yogomacs-initialized? #t)
    (let1 document (js-eval "document")
      (add-handler! document "keypress" dispatch-event))
    
    ;(linum-mode #t)
    (display "")
    ))

;;		    
;; Keymap
;;
(define (make-keymap name) 
  (list 'keymap name  (list)))

(define (keymap? keymap) 
  (and
   (list? keymap)
   (not (null? keymap))
   (eq? (car keymap) 'keymap)))

(define (lookup-key keymap key)
  (unless (keymap? keymap)
    (error (string-append "lookup-key: broken KEYMAP")))
  (let1 r (assoc key (caddr keymap))
    (if r
	(cdr r)
	#f)))

(define (define-key kmap kseq proc)
  (unless (keymap? kmap)
    (error (string-append "define-key: broken KEYMAP")))
  (unless (list? kseq)
    (error (string-append "define-key: broken kseq")))
  (when (null? kseq)
    (error (string-append "define-key: KSEQ is empty")))
  (define-key0 kmap (car kseq) (cdr kseq) proc))

(define (define-key0 kmap key rest proc)
  (let1 key (if (list? key) key (list key))
    (if (null? rest)
	(let1 slot (assoc key (caddr kmap))
	  (if slot
	      (set-cdr! slot proc)
	      (set-car! (cddr kmap)
			(cons
			 (cons key proc)
			 (caddr kmap)))))
	(let1 submap (make-keymap #f)
	  (define-key0 kmap key (list) submap)
	  (define-key0 submap (car rest) (cdr rest) proc)))))

(define global-map (make-keymap "global-map"))


;;
;; Event
;;
(let ((current-state-map global-map))
  (define (dispatch-event e)
    (define (update-current-state-map! map)
      (set! current-state-map map))
    (dispatch-event0 e 
		     current-state-map
		     update-current-state-map!)))

(define (dispatch-event0 e root-map update-map!)
  ;; http://js.halaurum.googlepages.com/sample_key_event.html
  ;; C-M-x
  (let ((charCode->char (lambda (charCode)
			  (integer->char charCode)))
	(keydown-event-ref (lambda (event slot)
			     (js-ref event (symbol->string slot)))))
    (let* ((c (charCode->char (keydown-event-ref e 'charCode)))
	   (M (keydown-event-ref e 'altKey))
	   (C (keydown-event-ref e 'ctrlKey))
	   (keyseq (list c)))
      (when M
	(set! keyseq (cons 'M keyseq)))
      (when C
	(set! keyseq (cons 'C keyseq)))
      (let1 r (lookup-key root-map keyseq)
	(cond
	 ((keymap? r)
	  (update-map! r))
	 ((not r)
	  (update-map! global-map)
	  (error "dispatch-event0: keyseq is undefined"))
	 (else
	  (let1 r0 (apply r (make-interactive-args r))
	    (update-map! global-map)
	    r0)))))))

;; 
;; Interactive-Spec
;;
(define-macro (define-interactive proc-sign interactive-spec body)
  `(begin
     (define ,proc-sign ,@body)
     (define-interactive-spec ,(car proc-sign) ',interactive-spec)))

(let ((prefix #f)
      (interactive-spec-table (list)))
  (define (define-interactive-spec proc interactive-spec)
    (let1 cell (assoc proc interactive-spec-table)
      (if cell
	  (set-cdr! cell interactive-spec)
	  (set! interactive-spec-table (cons (cons proc 
						   interactive-spec)
					     interactive-spec-table)))))
  (define (make-interactive-args proc)
    (let1 cell (assoc proc interactive-spec-table)
      (let1 r (if cell
		  (map (lambda (s) 
			 (cond
			  ((equal? s "P") prefix)
			  (else #f))
			 )
		       (cdr cell))
		  (list))
	(set! prefix #f)
	r)))

  (define-interactive (universal-argument) ()
    (
     (set! prefix #t)
     )))



;;
;; Face
;;
(define (for-each-styleSheet proc)
  (let* ((styleSheets (js-ref (current-buffer) "styleSheets"))
	 (n-styleSheets (js-ref styleSheets "length")))
    (let loop ((i 0))
      (when (< i n-styleSheets)
	(let1 styleSheet (js-ref styleSheets i)
	  (when styleSheets
	    (proc styleSheet)
	    (loop (+ i 1))))))))

(define (for-each-cssRule proc styleSheet)
  (let* ((cssRules (or 
		    (js-ref styleSheet "cssRules")
		    (js-ref styleSheet "rules")
		    ))
	 (n-cssRules (js-ref cssRules "length"))
	 )
    (let loop ((i 0))
      (when (< i n-cssRules)
	(let1 cssRule (js-ref cssRules i)
	  (when cssRule
	    (proc cssRule)
	    (loop (+ i 1))))))))

(define (face-of name)
  (let1 text (string-append "." (symbol->string name))
    (let1 r (call/cc 
	     (lambda (return)
	       (for-each-styleSheet
		(lambda (styleSheet)
		  (for-each-cssRule 
		   (lambda (cssRule)
		     (when (equal? (js-ref cssRule "selectorText") text)
		       (return cssRule)))
		   styleSheet)))
	       #f))
      ;; This line is needed to avoid broken intermediate codes.
      (display "")
      r
      )))

(define (set-face-attribute name alist)
  (let1 face (face-of name)
    (if face
	(for-each (lambda (pair)
		    (js-set! (js-ref face "style")
			     (symbol->string (car pair))
			     (cdr pair)))
		  alist))))

;; http://wiki.bit-hive.com/tomizoo/pg/Javascript cssRules
(define-interactive (linum-mode p) ("P")
  (
   (set-face-attribute 'linum  `((display . ,(if p "none" ""))))
   (set-face-attribute 'fringe `((display . ,(if p "none" ""))))
   ))

;;
;; Stitch
;;

(define-key global-map '(#\t) linum-mode)
(define-key global-map '(#\u) universal-argument)
;(define-key global-map '((#\<)) linum-mode)
;(define-key global-map '((#\>)) linum-mode)

(init-yogomacs)
;; format procedure? let-loop
