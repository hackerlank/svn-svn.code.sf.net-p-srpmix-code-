(define major-mode #f)
(define smart-phone? #t)
(define user-agent #t)

(define (major-mode-init . any)
  (set! major-mode (read-meta "major-mode"))
  (set! smart-phone? (read-meta "smart-phone?"))
  (set! user-agent (read-meta "user-agent"))
  (set! role-name (read-meta "role-name"))
  (set! user-name (read-meta "user-name"))
  (when smart-phone?
    (enter-full-screen)))

(define major-mode-table (make-hashtable))
(define (make-major-mode-record major-mode 
				. rest)
  (cons major-mode rest))

(define-macro (define-major-mode major-mode . rest)
  (let ((major-mode (string->symbol (string-append (symbol->string major-mode) "-mode"))))
    `(hashtable-put! major-mode-table (quote ,major-mode)
		     (make-major-mode-record (quote ,major-mode)
					     ,@rest)))) 

(define (major-mode-of symbol)
  (define (major-mode-of0 symbol major-mode)
    (let1 key (string->keyword (symbol->string symbol))
      (let1 record (hashtable-get major-mode-table major-mode)
	(if record
	    (let1 val (kref (cdr record) key #f)
	      (if val 
		  val
		  #f))
	    #f))))
  (let1 val (major-mode-of0 symbol major-mode)
    (if (not (or val 
		 (eq? major-mode 'fundamental-mode)))
	(major-mode-of0 symbol 'fundamental-mode)
	val)))
