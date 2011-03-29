(define-module outlang.outlang
  (export outlang)
  (use outlang.htmlprag)
  (use gauche.process)
  (use sxml.tree-trans)
  (use srfi-1)
  (use srfi-11)
  (use srfi-13)
  (use srfi-19)
  ;;
  (use util.list)
  )
(select-module outlang.outlang)

(debug-print-width #f)


(define outlang-prefix "/usr")
(define outlang-dir "/share/outlang/")
;(define style-prefix "/tmp")
(define style-prefix "/usr/share/yogomacs/css")

(define (built-in-links)
  (define (built-in-link title face)
    `(link (|@| (rel "stylesheet")
	    (type "text/css")
	    (href ,#`"file://,|style-prefix|/,|face|--,|title|.css")
	    (title ,title))))
  (define (built-in-link0 title names)
    (apply
     append
     (map
      (lambda (face)
	(list "	" (built-in-link title face) "\n"))
      names)))
  (let1 base-names #;'(default
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
      '(file-font-lock)
    `(
      ,@(built-in-link0 "Default" base-names)
      ,@(built-in-link0 "Invert" base-names))))

(define (a-length a)
  (let1 elt (caddr a)
    (cond
     ((string? elt) (string-length elt))
     (else
      (error "Unknown a element for calculating the length" a)))))

(define (span-length span)
  (let1 elt (caddr span)
    (cond 
     ((string? elt) (string-length elt))
     ((and (list? elt) (eq? (car elt) 'a)) (a-length elt))
     (else
      (error "Unknown span element for calculating the length" span)))))
	
(define (line-prefix kar kdr order)
  ;; (result line pos found-newline? ref)
  (let* ((result (car kdr))
	 (line   (cadr kdr))
	 (pos    (caddr kdr))
	 (found-newline? (cadddr kdr))
	 (found-ref? (ref kdr 4))
	 (newline? (equal? kar "\n"))
	 (kar-len (cond
		  ((string? kar) (string-length kar))
		  ((and (list? kar) (eq? (car kar) 'span)) (span-length kar))
		  ((and (list? kar) (eq? (car kar) 'div)) #f)
		  (else (error "Unknown element for calculating the length" kar))))
	 (ref? (not (boolean kar-len))))
    (cond
     (ref?
      (list (cons kar result)
		line
		pos
		newline?
		ref?))
     ((or found-ref? found-newline?)
      (list (cons* kar
		       `(span (|@| 
			       (class "rfringe")
			       (id ,#`"r/L:,|line|"))
			      " ")
		       `(span (|@|
			       (class "lfringe")
			       (id ,#`"l/P:,|pos|/L:,|line|"))
			      " ")
		       `(span (|@|
			       (class "linum")
			       (id ,#`"L:,|line|"))
			      (a (|@|
				  (href ,#`"#L:,|line|"))
				 ,(format #`"~,(number->string order),,d" line)))
		       result)
		(+ line (if newline? 1 0))
		(+ pos kar-len)
		newline?
		#f))
     (else
      (list (cons kar result)
	      (+ line (if newline? 1 0))
	      (+ pos kar-len)
	      newline?
	      #f)))))

(define asis `((*text* . ,(lambda (tag str) str))
	       (*default* . ,(lambda x x))))

(define (group-div kar elts)
  (let* ((result (car elts))
	 (div  (cadr elts))
	 (group-id   (caddr elts)))
    (cond
     ((and (list? kar) (not (null? (car kar))) (eq? (car kar) 'a))
      (let1 id ((#/#A:(.*)\[/ (car (assq-ref (car (cdr kar)) 'id '(#f))) ) 1)
	       (if (equal? id group-id)
		   (list result
			 (if (null? div)
			     (list kar '(|@| 
					 (style "display:none")
					 (class "references"))'div)
			     (cons kar div))
			 group-id)
		   (list (if (null? div)
			     result
			     (cons (reverse div) result))
			 (list kar '(|@| 
				     (style "display:none")
				     (class "references")) 'div)
			 id))))
     ((equal? kar "\n")
      (if (null? div)
	  (list (cons kar result) div #f)
	  (list result (cons kar div) group-id)))
     ((null? div)
      (list (cons kar result) div #f))
     (else
      (list (cons* kar (reverse div) result) (list) #f)))))
      
(define (trx sxml point-max count-lines)
  (let ((order (+ (floor->exact (log (max count-lines 1) 10)) 1))
	(drop-dot (cute regexp-replace #/(.*)\.#A(.*)/ <> "\\1#A\\2")))
    (pre-post-order sxml
		    `((head . ,(lambda (tag . rest)
				 (cons tag (reverse 
					    (append (reverse (built-in-links))
						    (cons*
						     "\n"
						     `(meta (|@| 
							     (name "count-lines")
							     (content ,#`",|count-lines|")))
						     "	"
						     "\n"
						     `(meta (|@| 
							     (name "point-max")
							     (content ,#`",|point-max|")))
						     "	"
						     "\n"
						     `(meta (|@| 
							     (name "version")
							     (content "0.0.0")))
						     "	"
						     "\n"
						     `(meta (|@| 
							     (name "created-time")
							     (content ,(date->string 
									(time-utc->date (current-time))
									"~5"))))
						     "	"
						     (reverse rest)))))))
		      (pre
		       ((a 
			 ((href . ,(lambda (attr val)
				     (list attr (drop-dot val))
				     ))
			 ,@asis)
			 . ,(lambda x x)))
		       . ,(lambda (tag . rest)
			    (cons tag (reverse
				       (car
					(fold (cute line-prefix <> <> order)
					      (list (list) 1 1 #t #f)
					      (reverse (car (fold group-div
								  (list (list) (list) #f)
								  rest)))))))))
		      ,@asis
		      ))))

(define class-map
  `(("normal" . "default")
    ("function" . "function-name")
    ("preproc" . "preprocessor")
    ("variable" . "variable-name")
    ("usertype" . "type")
    ;; regex
    ;; specialchar
    ;; number
    ;; symbol
    ;; cbracket
    ("todo" . "warning")
    ;; code
    ("predef_var" . "constant")
    ("predef_func" . "builtin")
    ("classname" . "type")
    ("url" . "doc")
    ;; date
    ;; time
    ;; file
    ;; ip
    ;; name
    ("argument" . "variable-name")
    ("optionalargument" . "variable-name")
    ("oldfile" . "diff-file-header")
    ("newfile" . "diff-file-header")
    ;; ("difflines" . "")
    ("selector" . "function-name")
    ("property" . "variable-name")
    ("value" . "default")
    ("path" . "doc")
    ("label" . "constant")
    ("error" . "warning")
    ))

(define (outlang-class->emacs-class val)
  ;; #?=val
  (assoc-ref class-map val val))

(define (buffer-info shtml)
  (let* ((len-in-a #f)
	 (point-max 1)
	 (count-lines 1)
	 (shtml (pre-post-order shtml
				`((span 
				   ((class . ,(lambda (attr val) (list attr 
								       (outlang-class->emacs-class val))))
				    (a . ,(lambda (tag attr val)
					    (set! len-in-a (string-length val))
					    (list tag attr val)
					    ))
				    ,@asis)
				   . ,(lambda (tag attrs . text)
					(let ((attrs (reverse (cons `(id ,#`"P:,|point-max|") (reverse attrs)))))
					  (set! point-max (+ point-max
							     (if len-in-a
								 len-in-a
								 (string-length 
								  (apply string-append text)))))
					  (set! len-in-a #f)
					  (cons* tag attrs text))))
				  (pre 
				   ((a *preorder* . ,(lambda x 
						       ;; Decrement for the newline of ref
						       ;; Quite dirty
						       (set! point-max (- point-max 1))
						       (set! count-lines (- count-lines 1))
						       x))
				    (*text* . ,(lambda (tag str) 
						 (set! point-max (+ point-max (string-length str)))
						 (set! count-lines (+ count-lines 1))
						 str))
				    (*default* . ,(lambda x x)))
				   . ,(lambda x x))
				  ,@asis
				  ))))
    (values shtml point-max count-lines)))

(define (outlang source-file . rest)
  (let-keywords rest ((ctags #f))
    (let* ((proc (run-process
		  `(source-highlight 
		    --tab=8
		    --doc
		    ,#`"--outlang-def=,|outlang-prefix|,|outlang-dir|yogomacs.outlang"
		    --infer-lang 
		    ;; --line-number
		    ,#`"--input=,|source-file|"
		    "--output=STDOUT"
		    ,@(if ctags
			  `(--gen-references=inline --ctags= ,#`"--ctags-file=,ctags")
			  ())
		    )
		  :output :pipe))
	   (output (process-output proc)))
      (let1 shtml (guard (e (else #f)) (html->shtml output))
	(let1 r (cond
		 ((not shtml) #f)
		 ((equal? shtml '(*TOP*)) #f)
		 (else
		  shtml))
	  ;; TODO: Nohung
	  (process-wait proc)
	  (if (eq? (process-exit-status proc) 0)
	      (let*-values (((shtml point-max count-lines) (buffer-info shtml)))
		(trx shtml point-max count-lines))
	      #f))))))

(provide "outlang/outlang")
;; TODO
;; - rewrite STDOUT link
;; - toggle div block
