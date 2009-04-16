#|
<div class="default" id="bs-console"></div>
<script src="file:///home/jet/workspace/biwascheme/lib/biwascheme.js">
 (load "file:///home/jet/workspace/srpmix/yogomacs/trunk/yogomacs.scm")
</script>
|#

;;
;; Utilities
;;
(define (js-len obj)
  (js-ref obj "length"))

(define (error msg)
  (let1 code (string-append "throw new Error(\"yogomacs: " 
			   msg
			   "\");")
    (js-eval code)))



;; biwascheme doesn't have format
(define (message msg)
  (display (string-append msg "\n")))


(define (string-prefix? s1 s2 . optional)
  ;; s1 => prefix, s2 => target
  (and (string? s1) (string? s2)
       (let ((prefix-length (string-length s1))
	     (target-length (string-length s2)))
	 (cond 
	  ((eq? prefix-length target-length)
	   (string= prefix-length target-length))
	  ((< prefix-length target-length)
	   (string= s1 (substring s2 0 prefix-length)))
	  (else
	   #f)))))
(define (string-rest s1 s2)
  (substring s2 (string-length s1) (string-length s2)))


;;
;; Accessor
;;
(define (node-type-of node)
  (let1 t (js-ref node "nodeType")
    (case t
      (1 'text)
      (2 'attribute)
      (3 'element)
      (9 'document)
      (else 'unknown))))

(define (node-text? node)
  (eq? (node-type-of node) 'text))
(define (node-element? node)
  (eq? (node-type-of node) 'element))

(define (element-id-of element)
  (if (node-element? element)
      (let1 id (element-read-attribute element "id")
	(if (js-null? id)
	    #f
	    id))
      #f))

(define (current-buffer) (js-eval "document"))
(define (doctype-of buffer)
  (js-ref (js-ref buffer "childNodes") "0"))
(define (html-of buffer)
  (js-ref (js-ref buffer "childNodes") "1"))

(define (head-of buffer) (js-ref (js-ref (html-of buffer) "childNodes") "0"))
(define (body-of buffer) (js-ref (js-ref (html-of buffer) "childNodes") "1"))
(define (primary-pre-of buffer)
  (let1 r (call/cc 
	   (lambda (found)
	     (let1 nodes (js-ref (body-of (current-buffer)) "childNodes")
	       (let1 len (js-len nodes)
		 (let loop ((i 0))
		   (if (< i len)
		       (let1 node (js-ref nodes (number->string i))
			 (when (and (node-element? node)
				    (equal? (js-ref node "nodeName") "PRE"))
			   (found node))
			 (loop (+ i 1)))
		       (found #f)))))))
    r))


;;
;; Initializer
;;
(define yogomacs-initialized? #f)
(define (init-yogomacs)
  (unless yogomacs-initialized?
    (set! yogomacs-initialized? #t)
    (let1 document (js-eval "document")
      (add-handler! document "keypress" dispatch-event))
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

(define (call-interactively cmd)
  (let1 r (apply cmd (make-interactive-args cmd))
    (handle-interactive-return cmd r)
    r))

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
	  ;(error "dispatch-event0: keyseq is undefined")
	  )
	 (else
	  (let1 r0 (call-interactively r)
	    (update-map! global-map)
	    r0)))))))

;; 
;; Interactive-Spec
;;
(define-macro (define-interactive proc-sign input-spec output-spec . body)
  `(begin
     (define ,proc-sign ,@body)
     (define-interactive-spec ',(car proc-sign) ,(car proc-sign) 
       ',input-spec 
       ;; Don't quote: output-spec is a function. 
       ,output-spec
       )))

(let ((prefix #f)
      (interactive-spec-table (list)))
  (define (define-interactive-spec name proc input-spec output-spec)
    (let1 cell (assoc proc interactive-spec-table)
      (if cell
	  (set-cdr! cell `((input-spec  . ,input-spec)
			   (output-spec . ,output-spec)))
	  (set! interactive-spec-table (cons (cons proc 
						   `((name        . ,name)
						     (input-spec  . ,input-spec)
						     (output-spec . ,output-spec)))
					     interactive-spec-table)))))
  (define (make-interactive-args proc)
    (let1 cell (assoc proc interactive-spec-table)
      (let1 r (if cell
		  (map (lambda (s) 
			 (cond
			  ((equal? s "P") prefix)
			  (else #f))
			 )
		       (cdr (assq 'input-spec (cdr cell))))
		  (list))
	(set! prefix #f)
	r)))
  (define (handle-interactive-return proc return)
    (let1 cell (assoc proc interactive-spec-table)
      (when cell
	(let1 output-spec (assq 'output-spec (cdr cell))
	  (when output-spec
	    (let1 func (cdr output-spec)
	      (when (procedure? func)
		(func return))))))))

  (define-interactive (universal-argument) () #f
    (set! prefix #t)
    ))



;;
;; Face
;;
(define (for-each-styleSheet proc)
  (let* ((styleSheets (js-ref (current-buffer) "styleSheets"))
	 (n-styleSheets (js-len styleSheets)))
    (let loop ((i 0))
      (when (< i n-styleSheets)
	(let1 styleSheet (js-ref styleSheets (number->string i))
	  (when styleSheets
	    (proc styleSheet)
	    (loop (+ i 1))))))))

(define (for-each-cssRule proc styleSheet)
  (let* ((cssRules (or 
		    (js-ref styleSheet "cssRules")
		    (js-ref styleSheet "rules")
		    ))
	 (n-cssRules (js-len cssRules))
	 )
    (let loop ((i 0))
      (when (< i n-cssRules)
	(let1 cssRule (js-ref cssRules (number->string i))
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

;; TODO: (defface ...)

;; http://wiki.bit-hive.com/tomizoo/pg/Javascript cssRules
(define-interactive (linum-mode p) ("P") #f
  (set-face-attribute 'linum  `((display . ,(if p "none" ""))))
  (set-face-attribute 'fringe `((display . ,(if p "none" "")))))




;; 
;; Walk
;; 
(define (walk-nodes initial-index-func
		    step-func
		    cont-func
		    action-func
		    no-action-result)
  (call/cc
   (lambda (found)
     (let1 nodes (js-ref (primary-pre-of (current-buffer)) "childNodes")
       (let1 len (js-len nodes)
	 (let loop ((i (initial-index-func len)))
	   (if (cont-func i len)
	       (let1 node (js-ref nodes (number->string i))
		 (when (node-element? node)
		   (action-func i node found))
		 (loop (step-func i)))
	       (no-action-result len found))))))))

(define (walk-nodes-fw action-func no-action-result)
  (walk-nodes 
   (lambda (len) 0)
   (lambda (i) (+ i 1))
   (lambda (i len) (< i len))
   action-func
   no-action-result))

(define (walk-nodes-bw action-func no-action-result)
  (walk-nodes 
   (lambda (len) (- len 1))
   (lambda (i) (- i 1))
   (lambda (i len) (< -1 i))
   action-func
   no-action-result))

;;
;; Point node
;;
(define (point-node-min)
  (walk-nodes-fw
   (lambda (i node return) 
     (when (point-node? node)
       (return node)))
   (lambda (len return) (return #f))))

(define (point-node-max)
  (walk-nodes-bw
   (lambda (i node return) 
     (when (point-node? node)
       (return node)))
   (lambda (len return) (return #f))))

(define (point-node? node)
  (let1 id (element-id-of node)
    (if id
	(cond
	 ((string-prefix? "point:" id)
	  (string->number 'point 
			  (string-rest "point:" id)))

	 ((string-prefix? "font-lock:" id)
	  (string->number 'font-lock 
			  (string-rest "font-lock:" id)))
	 (else
	  #f))
	#f)))


(define (point-node->point node)
  (let1 id (point-node? node)
    (if id
	(cadr id)
	#f)))

(define (point-node-text-length node)
  (let loop ((last node) 
	     (len 0))
    (let1 sibling (js-ref last "nextSibling")
      (if (and sibling (not (js-null? sibling)))
	  (cond
	   ((node-text? sibling)
	    (loop sibling
		  (+ len (string->number (js-ref sibling "length")))))
	   ((point-node? sibling)
	    ;; last
	    len)
	   (else
	    (loop sibling
		  len)))
	  ;; last
	  len))))

;;
;; Point
;;
(define-interactive (point-min) 
  () 
  (lambda (i) (message (if (number? i) (number->string i) "#f")))
  (let1 node (point-node-min)
    (if node
	(point-node->point node)
	node)))

(define-interactive (point-max) 
  ()
  (lambda (i) (message (if (number? i) (number->string i) "#f")))
  (let1 node (point-node-max)
    (if node
	(+ (point-node->point node)
	   (point-node-text-length node))
	node)))

(define-key global-map '(#\t)     linum-mode)
(define-key global-map '(#\u)     universal-argument)
(define-key global-map '((M #\<)) point-min)
(define-key global-map '((M #\>)) point-max)

(init-yogomacs)
;; format procedure? let-loop
