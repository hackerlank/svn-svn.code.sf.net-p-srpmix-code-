(define minor-mode-table (make-hashtable))
(define (make-minor-mode-record minor-mode 
				toggle-proc
				status-proc
				. rest)
  (cons* minor-mode 
	 :toggle toggle-proc
	 :status status-proc
	 rest))

(define (symbol->minor-mode symbol)
  (string->symbol (string-append (symbol->string symbol)
				 "-mode")))


(define-macro (define-minor-mode minor-mode . rest)
  (define (symbol->minor-mode symbol)
    (string->symbol (string-append (symbol->string symbol)
				   "-mode")))
  (define (symbol->minor-mode-toggle-proc symbol)
    (string->symbol (string-append "toggle-"
				   (symbol->string symbol)
				   "-mode"
				   )))
  (define (symbol->minor-mode-status-proc symbol)
  (string->symbol (string-append 
				 (symbol->string symbol)
				 "-mode?"
				 )))
  (let ((current-status (gensym))
	(mm (gensym))
	(new-status (gensym)))
    `(begin
       (define ,(symbol->minor-mode minor-mode) #f)
       (define (,(symbol->minor-mode-toggle-proc minor-mode) . ,new-status)
	 (let ((,current-status ,(symbol->minor-mode minor-mode))
	       (,mm (symbol->minor-mode ',minor-mode)))
	   (cond
	    ((or (null? ,new-status)
		 (not (eq? (car ,new-status)
			   ,current-status)))
	     (when-let1 action (minor-mode-of ,mm 'action)
			(action (not ,current-status)))
	     (set! ,(symbol->minor-mode minor-mode) (not ,current-status))
	     (when-let1 update-cookie (minor-mode-of ,mm 'update-cookie)
			(cookie-set! (symbol->string ,mm) (not ,current-status)))))))
       (define (,(symbol->minor-mode-status-proc minor-mode))
	 ,(symbol->minor-mode minor-mode)
	 )
       (let ((,mm (symbol->minor-mode ',minor-mode)))
	 (hashtable-put! minor-mode-table ,mm
			 (make-minor-mode-record ,mm
						 ,(symbol->minor-mode-toggle-proc minor-mode)
						 ,(symbol->minor-mode-status-proc minor-mode)
						 ,@rest)))
       )))

(define (minor-mode-of minor-mode symbol)
  (let1 key (symbol->keyword symbol)
    (let1 record (hashtable-get minor-mode-table minor-mode)
      (if record
	  (kref (cdr record) key #f)
	  #f))))

(define (minor-modes-init major-mode)
  (hashtable-for-each minor-mode-table
		      (lambda (k record)
			(when-let1 init (minor-mode-of k 'init)
				   (init k)))))
;;
(define (minor-mode-toggle minor-mode status)
  ((minor-mode-of minor-mode 'toggle) status))

(define (minor-mode-status minor-mode)
  ((minor-mode-of minor-mode 'status)))

