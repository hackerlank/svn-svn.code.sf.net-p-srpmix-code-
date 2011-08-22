#!/bin/sh
#| -*- scheme -*- |#
:; exec gosh -- $0 "$@"

(use srfi-1)
(use srfi-13)
(use util.match)
(use util.list)

(debug-print-width #f)
(define blacklist 
  (list
   #/^__dso_handle.*/			;???
   #/^__FUNCTION__\..*/
   #/^__PRETTY_FUNCTION__\..*/
   #/^__libc_csu_init$/
   #/^__do_global_ctors_aux$/
   #/^_start$/
   #/^call_gmon_start$/
   #/^__do_global_dtors_aux$/
   #/^frame_dummy$/
   ))

(define (load-entries file)
  (define (acceptable? entry)
    (not (any (lambda (r) (r entry)) blacklist)))
  (define (wash! es)
    (let1 connections (fold-right 
		       (lambda (entry0 kdr)
			 (let1 entry (ref entry0 2)
			   (if (acceptable? entry)
			       (cons entry0 kdr)
			       kdr)))
		       (list)
		       (delete-duplicates 
			(cadr (memq :connections es))))
      (set! (cadr (memq :connections es)) connections)))
  (with-input-from-file file
    (lambda ()
      (let ((rtable (make-hash-table 'equal?))
	    (ftable (make-hash-table 'equal?)))
	(let loop ((es (read)))
	  (if (eof-object? es)
	      (values ftable rtable)
	      (if (and (eq? (car es) 'objdump-dcall)
		       (eq? (cadr es) 'entry))
		  (begin 
		    (wash! es)
		    (for-each
		     (lambda (entry)
		       (hash-table-push! rtable entry es))
		     (delete-duplicates
		      (map
		       (cute ref <> 2)
		       (cadr (memq :connections es)))))
		    (when (acceptable? (ref es 3))
		      (hash-table-push! ftable (ref es 3) es))
		    (loop (read)))
		  (loop (read)))))))))

(define (find-callers sym table)
  (define (build kar l)
    `(,(if kar 
	   kar
	   (if (cadr (memq :variable? l))
	       'v
	       'f))
	   ,(ref l 3)
	   :file ,(cadr (memq :file l)) 
	   :line ,(cadr (memq :line l))
	   ))
  (cond
   ((ref table sym #f) => (cute map (cute build #f <>) <>))
   (else
    (let1 sym-len (string-length sym)
	  (hash-table-fold table (lambda (k v kdr)
				   (if (and (string-prefix? sym k)
					    (memq (string-ref k sym-len)
						  '(#\@ #\.)))
				       (append (map (cute build 'x <>) v) kdr)
				       kdr))
			   (list))))))

(define (find-callees sym table)
  (if-let1 ess (ref table sym #f)
	   (append-map
	    (lambda (es)
	      (let1 connections (cadr (memq :connections es))
		(map (lambda (name)
		       (if-let1 callee-ess (ref table name #f)
				(append-map
				 (lambda (callee-es)
				   `(,(if (cadr (memq :variable? callee-es))
					  'v
					  'f) 
				     ,(ref callee-es 3)
				     :file ,(cadr (memq :file callee-es))
				     :line ,(cadr (memq :line callee-es))
				     #;:caller #;(,(ref es 2) 
					      :file ,(cadr (memq :file es))
					      :line ,(cadr (memq :line es))))
				   )
				 callee-ess)
				`(x ,name)))
		     (map (cute ref <> 2) connections))))
	    ess)
	   (list)))

(define (writeln es)
  (write es)
  (newline))
(define (writeln* ess)
  (for-each
   writeln
   ess))

(define (forward-reachable? from to ftable)
  (list #f))
(define (backward-reachable? from to ftable)
  (list #f))

(define (callers* name rtable depth)
  (hash-table-map
   (let loop ((current-callers (map
				(cute ref <> 1)
				(find-callers name rtable)))
	      (total-callers (make-hash-table 'equal?))
	      (path (list name))
	      (depth depth))
     (when (or (and (boolean? depth) depth)
	       (and (integer? depth) (< 0 depth)))
       (for-each
	(lambda (caller)
	  (unless (member caller path)
	    ;; ...TODO
	    (hash-table-push! total-callers caller 
			      (cons caller path))
	    (loop (map
		   (cute ref <> 1)
		   (find-callers caller rtable))
		  total-callers
		  (cons caller path)
		  (if (integer? depth) (- depth 1) depth)
		  )))
	current-callers))
     total-callers)
   cons))

(define (callees* name ftable interactive? depth)
  (hash-table-map
   (let loop ((current-callees (map
				(cute ref <> 1)
				(find-callees name ftable)))
	      (total-callees (make-hash-table 'equal?))
	      (path (list name))
	      (depth depth))
     (when (or (and (boolean? depth) depth)
	       (and (integer? depth) (< 0 depth)))
       (for-each
	(lambda (callee)
	  (unless (member callee path)
	    (let* ((xpath (cons callee path))
		   (v (hash-table-get total-callees callee #f)))
	      (unless (and v (member xpath v))
		(hash-table-push! total-callees callee 
				  (cons callee path))
		(loop (map
		       (cute ref <> 1)
		       (find-callees callee ftable))
		      total-callees
		      (cons callee path)
		      (if (integer? depth) (- depth 1) depth))))))
	current-callees))
     total-callees)
   (lambda (a b)
     (cons (if interactive?
	       (if interactive?
		   `(,(if (variable?-forward a ftable) 'v 'f) ,a)
		   a)
	       a)
	   (map
	    (lambda (x)
	      ;#`",|a|<,(if (variable?-forward a ftable) 'v 'f )>"
	      (map (lambda (a)
		     (if interactive?
			 `(,(if (variable?-forward a ftable) 'v 'f) ,a)
			 a))
		   x))
	    (map reverse b))))))

(define (reachable? from to rtable depth)
  (or (let1 callers-from (callers* from rtable depth)
	    (if-let1 found (assoc-ref  callers-from to #f)
		     (map
		      (lambda (f)
			f)
		      found)
		     #f))
      (let1 callers-to (callers* to rtable depth)
	    (if-let1 found (assoc-ref  callers-to from #f)
		     (map
		      (lambda (f)
			f)
		      found)
		     #f))
      (list #f)))

(define (transit from to ftable rtable depth)
  (delete-duplicates
   (let1 r (reachable? from to rtable depth)
	 (if (equal? r (list #f))
	     (let1 commons (append (let* ((callers-from (callers* from rtable depth))
					  (callers-to (callers* to rtable depth))
					  (common-callers (lset-intersection equal? 
									     (map car callers-from)
									     (map car callers-to))))
				     (if (null? common-callers)
					 (list)
					 (map
					  (lambda (common-caller)
					    `(common-caller ,common-caller
							    :from ,(delete-duplicates 
								    (assoc-ref callers-from common-caller))
							    :to ,(delete-duplicates
								  (assoc-ref callers-to common-caller)))
					    )
					  common-callers)))
				   (let* ((callees-from (callees* from ftable #f depth))
					  (callees-to (callees* to ftable #f depth))
					  (common-callees (lset-intersection equal? 
									     (map car callees-from)
									     (map car callees-to))))
				     (if (null? common-callees)
					 (list)
					 (map
					  (lambda (common-callee)
					    `(common-callee ,common-callee
							    :from ,(delete-duplicates
								    (assoc-ref callees-from common-callee))
							    :to ,(delete-duplicates
								  (assoc-ref callees-to common-callee)))
					    )
					  common-callees))))
		   (if (null? commons)
		       (list #f)
		       commons))
	     r))))

(define (variable?-forward name ftable)
  (let1 entry (ref ftable name #f)
    (if entry
	(cadr (memq :variable? (car entry)))
	#f)))

(define (qr-eval es env ftable rtable)
  (match es
   ((? string? name) (ref ftable name (list #f)))
   ((? symbol? name) (ref ftable (x->string name) (list #f)))
   (('callers (? string? name)) (find-callers name rtable))
   (('callees (? string? name)) (find-callees name ftable))
   (('dump-table) (rtable-dump rtable))
   (('callers* (? string? name)) (callers* name rtable #t))
   (('callers* (? string? name) ':depth depth) 
    (callers* name rtable depth))
   (('callees* (? string? name)) (callees* name ftable #t #t))
   (('callees* (? string? name) ':depth depth) 
    (callees* name ftable #t depth))
   (('reachable? from to) (delete-duplicates (reachable? from to rtable #t)))
   (('reachable? from to ':depth depth) 
    (delete-duplicates (reachable? from to rtable depth)))
   (('transit from to) (transit from to ftable rtable #t))
   (('transit from to ':depth depth) (transit from to ftable rtable depth))
   (else
    (print #`";; unknown command: ,(car es)")
    (list #f)
    )))

(define (rtable-dump table)
  (apply append (hash-table-map table (lambda (k v)
					(map
					 (lambda (v0) 
					   `(=> ,k ,(ref v0 3)))
					 (delete-duplicates v))
					))))

;; timeout, plugin output routine, plugin input
(define (main args)
  (let* ((file (if (null? (cdr args)) #f (cadr args))))
    (receive (ftable rtable) 
	     (load-entries file)
	     (read-eval-print-loop read
				   (cute qr-eval <> <> ftable rtable)
				   writeln*
				   (lambda () 
				     (with-output-to-port (current-error-port)
				       (lambda ()
					 (display "ree? ")
					 (flush))))))))
