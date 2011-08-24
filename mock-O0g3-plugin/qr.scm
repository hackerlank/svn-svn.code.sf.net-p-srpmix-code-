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
   #/^_start$/
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
  ;(write es)
  ;(newline)
  (print es)
  )
(define (writeln* ess)
  (for-each
   writeln
   ess))

(define (forward-reachable? from to ftable)
  (list #f))
(define (backward-reachable? from to ftable)
  (list #f))

(define (decorate name table interactive?)
  (if interactive?
      #`",(if (variable? name table) '= '|| ),|name|,(if (variable? name table) '|| '() )"
      name))

(define (callers* name rtable interactive? depth)
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
	    (let* ((xpath (cons caller path))
		   (v (hash-table-get total-callers caller #f)))
	      (unless (and v (member xpath v)) ; necessary
                (hash-table-push! total-callers caller 
				  xpath)
		(loop (map
		       (cute ref <> 1)
		       (find-callers caller rtable))
		      total-callers
		      xpath
		      (if (integer? depth) (- depth 1) depth)
		    )))))
	current-callers))
     total-callers)
   (lambda (a b)
     (cons (decorate a rtable interactive?)
	   (map
	    (lambda (x)
	      (map (cute decorate <> rtable interactive?) x))
	    b))
     )))

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
				  xpath)
		(loop (map
		       (cute ref <> 1)
		       (find-callees callee ftable))
		      total-callees
		      xpath
		      (if (integer? depth) (- depth 1) depth))))))
	current-callees))
     total-callees)
   (lambda (a b)
     (cons (decorate a ftable interactive?) 
	   (map
	    (lambda (x)
	      (map (cute decorate <> ftable interactive?)
		   x))
	    (map reverse b))))))

(define (reachable? from to rtable interactive? depth)
  (delete-duplicates 
   (or (let1 callers-from (callers* from rtable #f depth)
	     (if-let1 found (assoc-ref  callers-from to #f)
		      (map
		       (lambda (f)
			 (map (cute decorate <> rtable interactive?)
			      f))
		       found)
		      #f))
       (let1 callers-to (callers* to rtable #f depth)
	     (if-let1 found (assoc-ref  callers-to from #f)
		      (map
		       (lambda (f)
			 (map (cute decorate <> rtable interactive?)
			      f))
		       found)
		      #f))
       (list #f))))

(define (transit from to ftable rtable interactive? depth)
  (define (decorate* tree)
    (map (lambda (t) (map (cute decorate <> rtable interactive?) t)) 
	 tree))
  (delete-duplicates
   (let1 r (reachable? from to rtable #f depth)
	 (if (equal? r (list #f))
	     (let1 commons (append (let* ((callers-from (callers* from rtable #f depth))
					  (callers-to (callers* to rtable #f depth))
					  (common-callers (lset-intersection equal? 
									     (map car callers-from)
									     (map car callers-to))))
				     (if (null? common-callers)
					 (list)
					 (map
					  (lambda (common-caller)
					    `(common-caller ,common-caller
							    :from ,(decorate*
								    (delete-duplicates 
								     (assoc-ref callers-from common-caller)))
							    :to ,(decorate*
								  (delete-duplicates
								   (assoc-ref callers-to common-caller))))
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
							    :from ,(decorate*
								    (delete-duplicates
								     (assoc-ref callees-from common-callee)))
							    :to ,(decorate* 
								  (delete-duplicates
								   (assoc-ref callees-to common-callee))))
					    )
					  common-callees))))
		   (if (null? commons)
		       (list #f)
		       commons))
	     r))))

(define (variable? name table)
  (let1 entry (ref table name #f)
    (if entry
	(cadr (memq :variable? (car entry)))
	#f)))

(define (info name ftable)
  (ref ftable name (list #f)))

(define (search name ftable)
  (hash-table-fold ftable (lambda (k v kdr)
			    (if (string-scan k name)
				(cons k kdr)
				kdr))
		   (list)))

(define (qr-eval es env ftable rtable)
  (match es
   (('info (? string? name)) (info name ftable))
   (('? (? string? name)) (info name ftable))
   (('search (? string? name)) (search name ftable))
   (('dump-table) (rtable-dump rtable))
   ;;
   (('< (? string? name)) (callers* name rtable #t 1))
   (('callers (? string? name)) (callers* name rtable #t 1))
   (('< (? string? name) depth) (callers* name rtable #t depth))
   (('callers (? string? name) depth) 
    (callers* name rtable #t depth))
   ;;
   (('> (? string? name)) (callees* name ftable #t 1))
   (('callees (? string? name)) (callees* name ftable #t 1))
   (('> (? string? name) depth) (callees* name ftable #t depth))
   (('callees (? string? name) depth) 
    (callees* name ftable #t depth))
   ;;
   (('reachable? from to) (reachable? from to rtable #t 1))
   (('reachable? from to  depth) (reachable? from to rtable #t depth))
   (('transit from to) (transit from to ftable rtable #t #t))
   (('transit from to  depth) (transit from to ftable rtable #t depth))
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
					 (display #`"[,(sys-basename file)]? ")
					 (flush))))))))
