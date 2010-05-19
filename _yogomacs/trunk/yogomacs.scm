;;
;; Utilities
;;
(define (js-len obj)
  (js-ref obj "length"))
(define (js-data obj)
  (js-ref obj "data"))

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
	   (string=? prefix-length target-length))
	  ((< prefix-length target-length)
	   (string=? s1 (substring s2 0 prefix-length)))
	  (else
	   #f)))))

(define (string-rest s1 s2)
  (substring s2 (string-length s1) 
	     (string-length s2)))

;;
;; Accessors
;;
(define (node-type-of node)
  (let1 t (js-ref node "nodeType")
    (case t
      ((1) 'element)
      ((2) 'attribute)
      ((3) 'text)
      ((9) 'document)
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
(define (parent-of elt)
  (js-ref elt "parentNode"))
(define (next-sibling-of elt)
  (js-ref elt "nextSibling"))
(define (previous-sibling-of elt)
  (js-ref elt "previousSibling"))


(define (current-buffer) (js-eval "document"))
(define (doctype-of buffer)
  (js-ref (js-ref buffer "childNodes") "0"))
(define (html-of buffer)
  (js-ref (js-ref buffer "childNodes") "1"))

(define (head-of buffer)
  (js-ref (js-ref (html-of buffer) "childNodes") "0"))
(define (body-of buffer)
  (js-ref (js-ref (html-of buffer) "childNodes") "1"))
(define (buffer-tree buffer)
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
(define-macro (define-interactive proc-sign input-spec output-spec desc . body)
  `(begin
     (define ,proc-sign ,@body)
     (define-interactive-spec ',(car proc-sign) ,(car proc-sign) 
       ',input-spec 
       ;; Don't quote: output-spec is a function. 
       ,output-spec
       ,desc
       )))

(let ((prefix #f)
      (interactive-spec-table (list)))
  (define (define-interactive-spec name proc input-spec output-spec desc)
    (let1 cell (assoc proc interactive-spec-table)
      (if cell
	  (set-cdr! cell `((input-spec  . ,input-spec)
			   (output-spec . ,output-spec)))
	  (set! interactive-spec-table (cons 
					(cons proc 
					      `((name        . ,name)
						(input-spec  . ,input-spec)
						(output-spec . ,output-spec)
						(desc        . ,desc)))
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

  (define-interactive (universal-argument) 
    () 
    #f 
    "Give universal arguments"
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

(define (set-face-attribute name-or-face alist)
  (let1 face (if (symbol? name-or-face)
		 (face-of name-or-face)
		 name-or-face)
    (when face
	(for-each (lambda (pair)
		    (js-set! (js-ref face "style")
			     (symbol->string (car pair))
			     (cdr pair)))
		  alist))))

(define (allocate-face! name)
  (let* ((styleSheets (js-ref (current-buffer) "styleSheets"))
	 (sheet (js-ref styleSheets "0")))
    (let ((addRule (js-ref sheet "addRule"))
	  (insertRule (js-ref sheet "insertRule")))
      (cond
       ((not (js-undefined? addRule))
	(js-invoke sheet
		   "addRule" 
		   (string-append "." (symbol->string name))
		   ""))
       ((not (js-undefined? insertRule))
	(js-invoke sheet
		   "insertRule" 
		   (string-append "." (symbol->string name) "{}")
		   0
		   ))
       (else
	(display "[yogomacs] noway to allocate face\n"))))
    (face-of name)
    ))

(define-macro (define-face face specs)
  `(set-face-attribute (or (face-of ',face) (allocate-face! ',face))
		       ',specs))
  
;; http://wiki.bit-hive.com/tomizoo/pg/Javascript cssRules
(define-interactive (linum-mode p) 
  ("P") 
  #f 
  "Turn on/off linum-mode"
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
     (let1 nodes (js-ref (buffer-tree (current-buffer)) "childNodes")
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
  (walk-nodes (lambda (len) (- len 1))
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
	  (list 'point
		(string->number (string-rest "point:" id))))
	 ((string-prefix? "font-lock:" id)
	  (list 'font-lock 
		(string->number (string-rest "font-lock:" id))))
	 (else
	  #f))
	#f)))

(js-load "./point-nodes.js" "PointNodes")
(define js-point-nodes-func (js-eval "point_nodes"))
(let ((*point-nodes* #f))
  (define (point-nodes)
    (if *point-nodes*
	*point-nodes*
	(let1 nodes (js-call 
		     js-point-nodes-func
		     (buffer-tree (current-buffer)))
	  (set! *point-nodes* nodes)
	  *point-nodes*))))

(define (point-node->start node)
  (let1 id (point-node? node)
    (if id
	(cadr id)
	#f)))
(define (point-node->length node)
  (+ (point-node-holding-text-length node)
     (point-node-trailing-text-length node)))
(define (point-node->range node)
  (let1 start (point-node->start node)
    (if start
	(list start (+ start (point-node->length node)))
	#f)))


(define (point-node->prefix node)
  (let1 id (point-node? node)
    (if id
	(car id)
	#f)))

(define (walk-point-node pnode starting-from action-func return-func param-init) 
  (let loop ((last pnode)
	     (starting-from starting-from)
	     (param param-init))
    (let1 sibling (js-ref last starting-from)
      (if (and sibling (not (js-null? sibling)))
	  (cond
	   ((node-text? sibling)
	    (action-func param sibling 
		  (lambda (p) 
		    (loop sibling "nextSibling" p))))
	   ((point-node? sibling)
	    (return-func param sibling))
	   ((node-element? sibling)
	    (loop sibling "nextSibling" param))
	   (else
	    (loop sibling "nextSibling" param)))
	  (return-func param sibling)))))

(define (point-node-text-length node starting-from)
  (walk-point-node node
		   starting-from
		   (lambda (p sibling loop)
		     (loop (+ p (string->number (js-len sibling)))))
		   (lambda (p sibling)
		     p)
		   0))

(define (point-node-trailing-text-length node)
  (point-node-text-length node "nextSibling"))

(define (point-node-holding-text-length node)
  (case (point-node->prefix node)
    ((point) 0)
    ((font-lock) 
     (point-node-text-length node "firstChild"))
    ;; TODO: Error
    (else 0)
    ))

;;
;; Point
;;
(define-interactive (point-min) 
  () 
  (lambda (i) (message (if (number? i) 
			   (string-append "Min point: " (number->string i))
			   "#f")))
  "Return (and show if called interactive) min point of buffer"
  (let1 node (point-node-min)
    (if node
	(point-node->start node)
	node)))

(define-interactive (point-max) 
  ()
  (lambda (i) (message (if (number? i) 
			   (string-append "Max point: " (number->string i))
			   "#f")))
  "Return (and show if called interactive) max point of buffer"
  (let1 node (point-node-max)
    (if node
	(+ 
	 (point-node->start node)
	 (point-node->length node)
	 )
	node)))

(define (point-node-for pos)
  (call/cc
   (lambda (found)
     (let1 nodes (point-nodes)
       (let1 len (vector-length nodes)
	 (let loop ((part (round (/ len 2)))
		    (quantum (round (/ len 2))))
	   ;;(display (list quantum part))
	   (let1 node (vector-ref nodes part)
		 (let1 range (point-node->range node)
		   (cond
		    ((< pos (car range))
		     (loop (- part (round (/ quantum 2)))
			   (round (/ quantum 2))))
		    ((< (cadr range) pos)
		     (loop (+ part (round (/ quantum 2)))
			   (round (/ quantum 2))))
		    (else
		     (found node)))))))))))

;;
;; Stitch
;;
(define (stitch-at-point pos obj)
  (let1 pnode (point-node-for pos)
    (if pnode
	(let1 offset (- pos (point-node->start pnode))
	  (let1 tlen (point-node-holding-text-length pnode)
	    (display (list tlen offset))
	    (cond
	     ((< offset tlen)
	      (stitch-on-point-node pnode 
					  offset 
					  "firstChild" 
					  obj ))
	     ((eq? tlen 0)
	      (stitch-after-node pnode obj))
	     (else
	      (stitch-on-point-node pnode 
				    (- offset tlen) 
				    "nextSibling"
				    obj))))
	  #t)
	#f)))

(define (make-text-node s)
  (js-invoke (current-buffer) "createTextNode" s))
(define (insert-before at obj)
  (js-invoke (parent-of at) "insertBefore" obj at))
(define (remove-node node)
  (js-invoke (parent-of at) "removeChild" node))

(define (stitch-on-point-node node offset starting-from obj)
  (walk-point-node node starting-from 
		   (lambda (o sibling loop)
		     (let1 len (string->number (js-len sibling))
		       (if (< o len)
			   (stitch-on-text sibling o obj)
			   (loop (- o len)))))
		   (lambda (o sibling) #f)
		   offset))

(define (stitch-after-node pnode obj)
  (let1 sibling (next-sibling-of pnode)
    (if (and sibling (not (js-null? sibling)))
	(insert-before pnode obj)
	(display "????? TODO"))
    #t))

(define (stitch-on-text text-node offset obj)
  (let* ((data (js-data text-node))
	 (len  (string-length data)))
    (let ((s0 (substring data 0 offset))
	  (s1 (substring data offset len)))
      (let ((n0 (make-text-node s0))
	    (n1 (make-text-node s1)))
	(insert-before text-node n0)
	(insert-before text-node obj)
	(insert-before text-node n1)
	(remove-node   text-node)
	)))
  #t)

;(stitch-at-point 1 (make-text-node "CAT\n"))
;(stitch-at-point 9 (make-text-node "DOG\n"))
(define (linum-node-for linum)
  ;; TODO: Use format
  (let1 lnode ($ (string-append "linum:" (number->string linum)))
    (if (and lnode (not (js-null? lnode)))
	lnode
	#f)))

(define (stitch-at-line linum obj)
  (let1 lnode (linum-node-for linum)
    (if lnode
	(let* ((at (parent-of lnode)))
	  (insert-before at obj))
	#f)))
;(stitch-at-line 10 (make-text-node "\n     HACK\n\n"))

(define (name-node-for name)
  (let1 nnode ($ (string-append "name:" name))
    (if (and nnode (not (js-null? nnode)))
	nnode
	#f)))

(define (stitch-at-name name obj)
  (let1 nnode (name-node-for name)
    (if nnode
	(let* ((at (previous-sibling-of nnode)))
	  (insert-before at obj)))))


(define-face stitch (
		     (foreground . "white")
		     (background . "gray")
		     ))

(define (make-element tag str face)
  (let ((elt (js-invoke (current-buffer) "createElement" tag))
	(attr (js-invoke (current-buffer) "createAttribute" "class"))
	(text (make-text-node str)))
    (let1 attributes (js-ref elt "attributes")
      (js-invoke attributes "setNamedItem" attr)
      (js-invoke elt "setAttribute" "class" (symbol->string face)))
    (js-invoke elt "appendChild" text)
    elt))


;(stitch-at-name "." (make-text-node "\n     srpmix.org is a library of source codes\n\n"))
(stitch-at-name "." (make-element "div"
				  "\n     srpmix.org is a library of source codes\n\n"
				  'stitch
				  ))

;;
;; Key bindings
;;
(define-key global-map '(#\t)     linum-mode)
(define-key global-map '(#\u)     universal-argument)
(define-key global-map '((M #\<)) point-min)
(define-key global-map '((M #\>)) point-max)

(init-yogomacs)
;; format procedure? let-loop
