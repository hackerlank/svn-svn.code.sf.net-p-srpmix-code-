(use file.util)
(use gauche.process)
;; (strap :pattern GLOB-PATTERN :mail-to (...) :subject "...")

;; "store" ROOT-DIR TMP-DIR 
;; "diff"  ROOT-DIR ORIGINAL-DIR
(define (print-usage prog status)
  (format #t "Usage: \n")
  (format #t "	~a store ROOT-DIR TMP-DIR\n" prog)
  (format #t "	~a diff  ROOT-DIR ORIGINAL-DIR\n" prog)
  (exit status))

(define (do-store tmp-dir req)
  (let-keywords req ((pattern #f) . req)
		(when (and pattern (string? pattern))
		  (for-each
		   (lambda (f)
		     (when (file-exists? f)
		       (let1 to (build-path tmp-dir ;;#?=(substring f 1 -1)
					    f
					    )
			 (make-directory* (sys-dirname to))
			 (copy-directory* f to))))
		   (glob pattern)))))

(define (do-mail mail-to subject file)
  (with-output-to-process `(mailx -s ,(format "[strap] ~a" subject) ,@mail-to)
    (lambda ()
      (with-input-from-file file
	(lambda ()
	  (let loop ((l (read-line)))
	    (unless (eof-object? l)
	      (display l)
	      (newline)
	      (loop (read-line)))))))))

(define (do-diff root-dir original-dir req)
  (let-keywords req ((pattern #f)
		     (mail-to #f)
		     (subject #f))
		(when (and pattern (string? pattern)
			   mail-to (list? mail-to) (string? (car mail-to))
			   subject (string? subject))
		  (receive (port file) (sys-mkstemp "strap")
		    (for-each
		     (lambda (f)
		       (let ((new (build-path root-dir f))
			     (old (build-path original-dir f)))
			 (with-input-from-process `(diff -ruN ,old ,new)
						  (lambda ()
						    (let loop ((l (read-line)))
						      (unless (eof-object? l)
							(display l port)
							(newline port)
							(loop (read-line)))))
						  :on-abnormal-exit (lambda (stat)
								      (close-output-port port)
								      (when (< 0 (file-size file))
									(do-mail mail-to subject file))
								      (delete-files (list file))))))
		     (glob pattern))
		    ))))


(define (main args)
  (when (< (length args) 2)
    (with-output-to-port (current-error-port)
      (cute print-usage (car args) 1)))
  (let1 action (cadr args)
    (cond
     ((equal? action "store")
      (unless (eq? (length args) 4)
	(print-usage (car args) 1))
      (let ((root-dir (caddr args))
	    (tmp-dir  (cadddr args)))
	(unless (file-is-directory? root-dir)
	  (format (current-error-port) "~a is not directory\n" root-dir)
	  (exit 1))
	(unless (file-is-directory? tmp-dir)
	  (format (current-error-port) "~a is not directory\n" tmp-dir)
	  (exit 1))
	(current-directory root-dir)
	(let loop ((r (read)))
	  (unless (eof-object? r)
	    (do-store tmp-dir (cdr r))
	    (loop (read))
	    ))))
     ((equal? action "diff")
      (unless (eq? (length args) 4)
	(print-usage (car args) 1))
      (let ((root-dir (caddr args))
	    (original-dir  (cadddr args)))
	(unless (file-is-directory? root-dir)
	  (format (current-error-port) "~a is not directory\n" root-dir)
	  (exit 1))
	(unless (file-is-directory? original-dir)
	  (format (current-error-port) "~a is not directory\n" original-dir)
	  (exit 1))
	(current-directory root-dir)
	(let loop ((r (read)))
	  (unless (eof-object? r)
	    (do-diff root-dir original-dir (cdr r))
	    (loop (read))
	    ))))
     (else
      (print-usage (car args) 1)))))
