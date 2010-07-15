(use sxml.tree-trans)
(use srfi-1)
(use util.list)
(use srfi-11)
  (use sxml.serializer)


(define (replace-range beg-pred end-pred forest)
  (define (loop forest keep? new-forest)
    (if (null? forest) 
	(values (reverse new-forest) keep?)
	(let ((node (car forest))) 
	  (if keep? 
	      (cond 
	       ((beg-pred node) => (lambda (repl-branches) 
				     (loop (cdr forest) 
					   #f
					   (append (reverse repl-branches) new-forest))))
	       ((not (pair? node)) 
		(loop (cdr forest) keep? (cons node new-forest)))
	       (else (let*-values (((node?) (symbol? (car node))) 
				   ((new-kids keep?) (loop (if node? 
							       (cdr node)
							       node) #t '())))
		       (loop (cdr forest) keep? (cons (if node? 
							  (cons (car node) new-kids)
							  new-kids) 
						      new-forest))))) 
	      (cond ((end-pred node) => (lambda (repl-branches)
					  (loop (append repl-branches (cdr forest))
						#t
						new-forest)))
		    ((not (pair? node))
		     (loop (cdr forest) keep? new-forest))
		    (else (let*-values (((node?) (symbol? (car node)))
					((new-kids keep?) (loop (if node? 
								    (cdr node)
								    node) #f '()))) 
			    (loop (cdr forest) 
				  keep? 
				  (if (or keep? (pair? new-kids))
				      (cons (if node?
						(cons (car node) new-kids)
						new-kids) 
					    new-forest)
				      new-forest))))))))
    ) (let*-values (((new-forest keep?) (loop forest #t '()))) new-forest))



;; See /www.ac.cyberhome.ne.jp/~yakahaira/vimdoc/syntax.html
(define (vim->emacs class)
  (let1 mapping '(("lnr" . "linum")
		  ("Comment" . "comment")
		  ;;
		  ("Constant"       . "constant")
		  ("String"         . "string")
		  ("Character"      . "default")
		  ("Number"         . "default") 
		  ("Boolean"        . "default") 
		  ("Float"          . "default") 
		  ;;
		  ("Identifier"     .  "variable-name")
		  ("Function"       .  "function-name")
		  ;;
		  ("Statement"      .  "keyword")
		  ("Conditional"    .  "keyword")
		  ("Repeat"         .  "keyword")
		  ("Label"          .  "keyword")
		  ("Operator"       .  "default")
		  ("Keyword"        .  "keyword")
		  ("Exception"      .  "exception")
		  ;;
		  ("PreProc"        . "preprocessor")
		  ("Include"        . "preprocessor")
		  ("Define"         . "preprocessor")
		  ("Macro"          . "preprocessor")
		  ("PreCondit"      . "preprocessor")
		  ;;
		  ("Type"           . "type")
		  ("StorageClass"   . "keyword")
		  ("Structure"      . "keyword")
		  ("Typedef"        . "keyword")
		  ;;
		  ("Special"        . "warning") ;???
		  ("SpecialChar"    . "warning") ;???
		  ("Tag"            . "default")
		  ("Delimiter"      . "nagation-char")
		  ("SpecialComment" . "doc")
		  ("Debug"          . "default")
		  ;;
		  ("Underline"      . "default") ;???
		  ("Ignore"         . "default") ;???
		  ("Error"          . "warning") ;???
		  ("Todo"           . "doc") ;???
		  )
        (assoc-ref mapping class class)))
;;; http://okmij.org/ftp/Scheme/lib/SXML-tree-trans.scm
(define (built-in-links)
  (define (built-in-link title face)
    `(link (|@| (rel "stylesheet")
	    (type "text/css")
	    ;(href ,#`"file:///var/lib/yogomacs/local/css/,|face|--,|title|.css")
	    (href ,#`"file:///tmp/,|face|--,|title|.css")
	    (title ,title))))
  (let1 base-names '(default
		      font-lock-builtin-face
		      font-lock-comment-delimiter-face
		      font-lock-comment-face
		      font-lock-constant-face
		      font-lock-doc-face
		      font-lock-function-name-face
		      font-lock-keyword-face
		      font-lock-negation-char-face
		      font-lock-regexp-grouping-backslash
		      font-lock-regexp-grouping-construct
		      font-lock-string-face
		      font-lock-type-face
		      font-lock-variable-name-face
		      font-lock-warning-face
		      highlight
		      lfringe
		      linum
		      rfringe)
    (append
     (map
      (pa$ built-in-link "Default")
      base-names)
     (map
      (pa$ built-in-link "Invert")
      base-names))))

(define (replacex sxml)
  (replace-range 
   (lambda (b) 
     (and-let* (( (pair? b) )
		( (eq? (car b) 'span) )
		( (list? (ref b 1)) )
		( (eq? (car (ref b 1)) '|@|) )
		(attrs (cdr (ref b 1)))
		( (equal? (car (assoc-ref attrs 'class '(#f))) "linum"))
		(text (ref b 2))
		(id ((#/ *([0-9]+)/ text) 1))
		)
       `((span (|@| ,@(append attrs `((id ,id))))
	       (a (|@| (href ,#`"#,|id|"))
		  ,text))
	 (span (|@| 
		(class "lfringe")
		(id    ,#`"l/P:?/L:,|id|")
		" "))
	 (span (|@| 
		(class "rfringe")
		(id    ,#`"r/L:,|id|")
		" "))
	 )))
   (lambda (e) `(,e))
   sxml)
  )

(define (trx sxml)
  (replacex
   (pre-post-order sxml
		   `((head . ,(lambda (tag . rest)
				(cons tag (append
					   (reverse
					    (fold (lambda (kar kdr)
						    (cond
						     ((string? kar)
						      (cons kar kdr))
						     ((eq? (car kar) 'style)
						      kdr)
						     (else
						      (cons kar kdr))))
						  (list)
						  rest))
					   (built-in-links)
					   ))))
		     (span
		      ((class . ,(lambda (tag str)
				   (list tag (vim->emacs str))
				   ))) .
				       ,(lambda (tag attrs . rest)
					  (if (and (eq? (car attrs) '|@|)
						   (equal? (car (assoc-ref (cdr attrs) 'class '(#f)))
							   "linum"))
					      (let1 linum ((#/( *[0-9]+) / (car rest)) 1)
						(list tag attrs linum))
					      (cons* tag attrs rest))))
		     (*text* . ,(lambda (tag str) str))
		     (*default* . ,(lambda x x))
		     ))))

(let1 shtml (read)
  (write (srl:sxml->xml-noindent (trx shtml))))

