(use file.util)
(use gauche.process)
;; (strap :pattern GLOB-PATTERN :mail-to (...) :subject "...")

;; "store" ROOT-DIR TMP-DIR 
;; "diff"  ROOT-DIR ORIGINAL-DIR
(define (print-usage prog status)
  (format #t "Usage: \n")
  (format #t "	~a store ROOT-DIR TMP-DIR\n" prog)
  (format #t "	~a diff  ROOT-DIR ORIGINAL-DIR\n" prog)
  (exit store))

(define (do-store tmp-dir req)
  (let-keywords req ((pattern #f))
    (when (and pattern (string? pattern))
      (for-each
       (lambda (f)
	 (copy-directory* f (build-path tmp-dir f)))
       (glob pattern)))))

(define (do-mail mail-to subject file)
  (with-output-to-process `(mailx -s ,subject ,@mail-to)
			    (lambda ()
			      (with-input-from-file file
				(lambda ()
				  (let loop ((l (read-line)))
				    (display l)))))))

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
	     (with-input-process `(diff -ruN old new)
	       (lambda ()
		 (let loop ((l (read-line)))
		   (unless (eof-object? l)
		     (display l port)))))))
	 (glob pattern))
	(close-output-port port)
	(when (< 0 (file-size file))
	  (do-mail mail-to subject file))
	(delete-files (list file))))))


(define (main args)
  (when (< (lengt args) 2)
    (with-output-to-port (current-error-port)
      (cute print-usage (car args) 1)))
  (let1 action (cadr args)
    (cond
     ((equal? action "store")
      (unless (eq? (lengt args) 4)
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
	    (do-store tmp-dir r)
	    (loop (read))
	    ))))
     ((equal? action "diff")
      (unless (eq? (lengt args) 4)
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
	    (do-diff root-dir original-dir r)
	    (loop (read))
	    ))))
     (else
      (print-usage (car args) 1)))))
