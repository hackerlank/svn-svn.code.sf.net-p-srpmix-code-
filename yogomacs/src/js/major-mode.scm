(define major-mode #f)
(define smart-phone? #t)
(define user-agent #t)

(define (major-mode-init . any)
  (set! major-mode (read-meta "major-mode"))
  (set! smart-phone? (read-meta "smart-phone?"))
  (set! user-agent (read-meta "user-agent"))
  (set! role-name (read-meta "role-name"))
  (set! user-name (read-meta "user-name"))
  (when-let1 proc (major-mode-of 'init)
    (proc major-mode))
  (run-hook major-mode-init-hook major-mode))

(define major-mode-table (make-hashtable))
(define (make-major-mode-record major-mode 
				. rest)
  (cons major-mode rest))

(define (symbol->major-mode symbol)
  (string->symbol (string-append (symbol->string symbol) "-mode")))

(define-macro (define-major-mode major-mode . rest)
  (let ((m (gensym)))
    `(let1 ,m (symbol->major-mode ',major-mode)
       (hashtable-put! major-mode-table ,m
		       (make-major-mode-record ,m
					       ,@rest))))) 

(define (major-mode-of symbol)
  (define (id x) x)
  (define (major-mode-of0 symbol major-mode)
    (let1 key (symbol->keyword symbol)
      (let1 record (hashtable-get major-mode-table major-mode)
	(if record
	    (kref (cdr record) key #f)
	    #f))))
  (define (try-parent symbol major-mode)
    (let loop ((parent (major-mode-of0 'parent major-mode)))
      (if parent
	  (or (major-mode-of0 symbol parent)
	      (loop (major-mode-of0 'parent parent)))
	  #f)))
  (let1 val (major-mode-of0 symbol major-mode)
    (cond
     (val val)
     ((try-parent symbol major-mode)
      => id)
     ((not (eq? major-mode 'fundamental-mode))
      (major-mode-of0 symbol 'fundamental-mode))
     (else #f)
     )))
