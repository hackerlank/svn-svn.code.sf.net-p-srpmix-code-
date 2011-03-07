(define-module outlang.outlang
  (export outlang)
  (use outlang.htmlprag)
  (use gauche.process)
  (use sxml.tree-trans)
  (use srfi-1)
  (use srfi-13)
  (use srfi-11)
  ;;
  (use util.list)
  )
(select-module outlang.outlang)

(define prefix "/usr")
(define dir "/share/outlang/")

(debug-print-width #f)

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
			     (class "rfrindge")
			     (id ,#`"r/L:,|line|"))
			    " ")
		     `(span (|@|
			     (class "lfrindge")
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

;(define (trx sxml point-max count-lines) sxml)
(define (trx sxml point-max count-lines)
  (pre-post-order sxml
		  `((pre . ,(lambda (tag . rest)
			      (cons tag (reverse (car (fold
						       (cute line-prefix <> <> 
							     (+ (floor->exact (log (max count-lines 1) 10))
								1))
						       (list (list) 1 1 #t)
						       rest))))))
		    (*text* . ,(lambda (tag str) str))
		    (*default* . ,(lambda x x))
		    )))

(define class-map
  `(("normal" . "default")))

(define (outlang-class->emacs-class val)
  (assoc-ref class-map val val))

(define (buffer-info shtml)
  (let* ((point-max 1)
	 (count-lines 1)
	 (shtml (pre-post-order shtml
				`((span 
				   ((class . ,(lambda (attr val) (list attr 
								       (outlang-class->emacs-class val))))
				    (a . ,(lambda x x))
				    (*text* . ,(lambda (tag str) str))
				    (*default* . ,(lambda x x)))
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
				  (*text* . ,(lambda (tag str) str))
				  (*default* . ,(lambda x x))))))
    (values shtml point-max count-lines)
    ))

(define (outlang source-file)
  (let* ((proc (run-process
		`(source-highlight 
		  --tab=8
		  --doc
		  ,#`"--outlang-def=,|prefix|,|dir|yogomacs.outlang"
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
	      (trx shtml point-max count-lines))
	    #f)))))

(provide "outlang/outlang")
