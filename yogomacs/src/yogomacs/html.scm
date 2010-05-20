(define-module yogomacs.html
  (export path->html)
  (use util.match)
  (use file.util )
  (use www.cgi)
  (use yogomacs.config)
  (use yogomacs.dired)
  (use yogomacs.font-lock)
  )

(select-module yogomacs.html)

(define path->html (match-lambda*
		    ((path type line range display err-return)
		     (case display
		       ('raw
			(path->html-as-raw path type line range err-return)
			)
		       ('font-lock
			(path->html-as-font-lock path type line range err-return)
			)))
		    ((path type display err-return)
		     (path->html path type #f #f display err-return))))

(define (path->html-as-raw path type line range err-return)
  (case type
    ('file
     (file->html-as-raw path line range err-return)
     )
    ('dir
     (dir->html-as-raw path err-return)
     )))

(define (file->html-as-raw path line range err-return)
  (let1 head (cgi-header :content-type "text/plain")
    (call-with-input-file path
      (lambda (iport)
	(cond 
	 (line
	  (let1 contents (port->string-list iport)
	    (list head (if (<= line (length contents))
			   (list (list-ref contents (- line 1)) "\n")
			   (err-return "Line: out of range")))))
	 (range
	  (let* ((contents (port->string-list iport))
		 (len      (length contents)))
	    `(,head ,@(map (lambda (i)
			     (if (<= i len)
				 (list (list-ref contents (- i 1)) "\n")
				 (err-return "Range: out of range")
				 ))
			   range))
	    ))
	 (else
	  (list head (port->string iport))))))))

(define (dir->html-as-raw path err-return)
  (cons (cgi-header :content-type "text/plain")
	(map (lambda (elt) (list elt "\n"))
	     (directory-list path :add-path? #f :children? #t
			     :filter  (lambda (e) 
					(and (not (equal? e ".htaccess"))
					     (if (equal? path prefix)
						 (member e top-entries)
						 #t)))))))

(define (path->html-as-font-lock path type line range err-return)
  (case type
    ('file 
     (if line
	 (path->html-as-font-lock path type #f (list line (+ 1 line)) err-return)
	 (file->html-as-font-lock path range err-return)))
    ('dir
     (dir->html-as-font-lock path err-return))))

(define (file->html-as-font-lock path range err-return)
  ;(debug-print 'file->html-as-font-lock)
  (font-lock path err-return))

(define (dir->html-as-font-lock path err-return)
  ;(debug-print 'dir->html-as-font-lock)
  (run-dired path err-return))

(provide "yogomacs/html")
