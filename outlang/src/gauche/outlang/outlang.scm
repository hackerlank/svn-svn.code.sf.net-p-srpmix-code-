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

(define (span-length span)
  (let1 elt (caddr span)
    (if (string? elt)
	(string-length elt)
	(error "Unknown span element for calculating the length" span))))
	
(define (line-prefix kar kdr order)
  (let ((result (car kdr))
	(line   (cadr kdr))
	(pos    (caddr kdr))
	(found-newline? (cadddr kdr))
	(newline? (equal? kar "\n"))
	(kar-len (cond
		  ((string? kar) (string-length kar))
		  ((and (list? kar) (equal? (car kar) 'span)) (span-length kar))
		  (else (error "Unknown element for calculating the length" kar)))))
    (if found-newline?
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
	      (if (equal? kar "\n")
		  (+ line 1)
		  line)
	      (+ pos kar-len)
	      (if newline?
		  #t
		  #f))
	(list (cons kar result)
	      (if newline?
		  (+ line 1)
		  line)
	      (+ pos kar-len)
	      (if newline?
		  #t
		  #f)))))

(define asis `((*text* . ,(lambda (tag str) str))
	       (*default* . ,(lambda x x))))

(define (trx sxml point-max count-lines links)
  (let1 order (+ (floor->exact (log (max count-lines 1) 10)) 1)
    (pre-post-order sxml
		    `((head . ,(lambda (tag . rest)
				 (cons tag (reverse 
					    (append links
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
							     (content ,(date->string (time-utc->date (current-time)) "~5"))))
						     "	"
						     (reverse rest)))))))
		      (pre . ,(lambda (tag . rest)
				(cons tag (reverse (car (fold
							 (cute line-prefix <> <> order)
							 (list (list) 1 1 #t)
							 rest))))))
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
  (let* ((point-max 1)
	 (count-lines 1)
	 (shtml (pre-post-order shtml
				`((span 
				   ((class . ,(lambda (attr val) (list attr 
								       (outlang-class->emacs-class val))))
				    ,@asis)
				   . ,(lambda (tag attrs . text)
					(let ((attrs (reverse (cons `(id ,#`"P:,|point-max|") (reverse attrs))))
					      (text (apply string-append text)))
					  (set! point-max (+ point-max (string-length text)))
					  (list tag attrs text)
					  )))
				  (pre 
				   ((*text* . ,(lambda (tag str) 
						 (set! point-max (+ point-max (string-length str)))
						 (set! count-lines (+ count-lines 1))
						 str))
				    (*default* . ,(lambda x x)))
				   . ,(lambda x x))
				  ,@asis
				  ))))
    (values shtml point-max count-lines)))

(define (outlang source-file . rest)
  (let-keywords rest ((no-link #f))
    (let* ((proc (run-process
		  `(source-highlight 
		    --tab=8
		    --doc
		    ,#`"--outlang-def=,|outlang-prefix|,|outlang-dir|yogomacs.outlang"
		    --infer-lang 
					; --line-number
		    ,#`"--input=,|source-file|"
		    "--output=STDOUT")
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
		(trx shtml point-max count-lines
		     (if no-link
			 (list)
			 (reverse (built-in-links)))))
	      #f))))))

(provide "outlang/outlang")
