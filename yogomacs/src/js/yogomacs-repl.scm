;;
;; Repl
;;
(define shell-dir #f)
(define (message str)
  (-> str "minibuffer"))
(define (repl eval output-prefix)
  (let1 str (<- "minibuffer")
    (let1 result (with-error-handler 
		   write-to-string
		   (pa$ eval str))
      (-> (string-append output-prefix result) "minibuffer")))
  (let1 elt ($ "minibuffer")
    (elt.focus)
    (elt.select)))

(define bscm #f)
(define bscm-dir "/bscm")
(define ysh #f)
(define ysh-dir "/ysh")

(define (initialize-bscm bscm shell-dir)
  (for-each 
   (pa$ scm->scm bscm)
   `((define (normalize-path path)
       (let1 len (string-length path)
	 (cond 
	  ((eq? len 0) "")
	  ((equal? (substring path (- len 1) len) "/") 
	   (normalize-path (substring path 0 (- len 1))))
	  (else path))))
     (define (exit . rest)
       (let* ((location (js-eval "location"))
	      (pathname (js-ref location "pathname")))
	 (js-set! location "pathname" (substring
				       (normalize-path pathname)
				       (string-length ,shell-dir)
				       (string-length pathname)))))
     (define (bscm . rest)
       (let* ((location (js-eval "location"))
	      (pathname (js-ref location "pathname")))
	 (js-set! location "pathname" (string-append ,bscm-dir
						     (substring
						      (normalize-path pathname)
						      (string-length ,shell-dir)
						      (string-length pathname))))))
     (define (ysh . rest)
       (let* ((location (js-eval "location"))
	      (pathname (js-ref location "pathname")))
	 (js-set! location "pathname" (string-append ,ysh-dir
						     (substring
						      (normalize-path pathname)
						      (string-length ,shell-dir)
						      (string-length pathname))))))
     (define (find-file entry) 
       (let* ((location (js-eval "location"))
	      (pathname (js-ref location "pathname"))
	      (entry (normalize-path entry))
	      (len (string-length entry)))
	 (cond
	  ((or (and (< 0 len)
		    (eq? (string-ref entry 0) #\/))
	       (eq? len 0))
	   (js-set! location "pathname" (string-append ,shell-dir
						       entry)))
	  (else
	   (js-set! location "pathname" (string-append 
					 (normalize-path pathname)
					 "/"
					 entry)))
	  )))
     (define (pwd . rest)
       (let* ((location (js-eval "location"))
	      (pathname (js-ref location "pathname")))
	 pathname))
     (define cd find-file)
     (define less find-file)
     (define lv find-file)))
  bscm)

(define (new-bscm shell-dir)
  (initialize-bscm (js-new BiwaScheme.Interpreter)
		     shell-dir))

(define (bscm-initializer)
  (set! shell-dir bscm-dir))
(define (bscm-eval str)
  (unless bscm
    (set! bscm (new-bscm bscm-dir)))
  (let1 result #f
    (bscm.evaluate str
		   (lambda (r) 
		     (set! result (BiwaScheme.to_write r))))
    result))

(define (bscm-interpret)
  (repl bscm-eval ";; "))


(define (ysh-initializer)
  (set! shell-dir ysh-dir))
(define (ysh-eval str)
  (unless ysh
    (set! ysh (new-bscm ysh-dir)))
  (let1 str
      (let1 exp (read-from-string
		 (string-append "(" str ")") )
	(write-to-string (cons (car exp)
			       (map (lambda (elt)
				      (cond 
				       ((number? elt) (number->string elt))
				       ((symbol? elt) (symbol->string elt))
				       (else "")))
				    (cdr exp))) 
			 ))
    (let1 result #f
      (ysh.evaluate str
		    (lambda (r) 
		      (set! result (BiwaScheme.to_write r))))
      result)))

(define (ysh-interpret)
  (repl ysh-eval "# "))

(define (nologin-initializer)
  (set! shell-dir ""))
(define (nologin-interpret)
  #f)
