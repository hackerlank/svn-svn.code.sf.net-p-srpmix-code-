#!/bin/sh
#| -*- scheme -*- |#
:; exec gosh -- $0 "$@"

(use srfi-1)
(use srfi-13)
(use util.match)
(use util.list)

(debug-print-width #f)
(define (load-entries file)
  (with-input-from-file file
    (lambda ()
      (let ((rtable (make-hash-table 'equal?))
	    (ftable (make-hash-table 'equal?)))
	(let loop ((es (read)))
	  (if (eof-object? es)
	      (values ftable rtable)
	      (if (and (eq? (car es) 'objdump-dcall)
		       (eq? (cadr es) 'entry))
		  (begin (for-each
			  (cute hash-table-push! rtable <> es)
			  (map
			   (cute ref <> 2)
			   (delete-duplicates (cadr (memq :connections es)))))
			 (hash-table-push! ftable (ref es 3) es)
			 (loop (read)))
		  (loop (read)))))))))

(define (find-callers sym table)
  (define (build kar l)
    `(,kar ,(ref l 3)
	   :file ,(cadr (memq :file l)) 
	   :line ,(cadr (memq :line l))))
  (cond
   ((ref table sym #f) => (cute map (cute build 'match <>) <>))
   (else
    (let1 sym-len (string-length sym)
	  (hash-table-fold table (lambda (k v kdr)
				   k
				   v
				   (if (and (string-prefix? sym k)
					    (memq (string-ref k sym-len)
						  '(#\@ #\.)))
				       (append (map (cute build 'fuzzy <>) v) kdr)
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
				       `(match ,(ref callee-es 3)
					       :file ,(cadr (memq :file callee-es))
					       :line ,(cadr (memq :line callee-es))
					       :caller (,(ref es 2) 
							:file ,(cadr (memq :file es))
							:line ,(cadr (memq :line es)))))
				     callee-ess)
				    `(fuzzy ,name)))
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

(define (all-callers name rtable)
  (hash-table-map
   (let loop ((current-callers (map
				(cute ref <> 1)
				(find-callers name rtable)))
	      (total-callers (make-hash-table 'equal?))
	      (path (list name)))
     (for-each
      (lambda (caller)
	(unless (member caller path)
		(hash-table-push! total-callers caller 
				 (cons caller path))
		(loop (map
		       (cute ref <> 1)
		       (find-callers caller rtable))
		      total-callers
		      (cons caller path))))
      current-callers)
     total-callers)
   cons))

(define (all-callees name ftable)
  (hash-table-map
   (let loop ((current-callees (map
				(cute ref <> 1)
				(find-callees name ftable)))
	      (total-callees (make-hash-table 'equal?))
	      (path (list name)))
     (for-each
      (lambda (callee)
	(unless (member callee path)
		(hash-table-push! total-callees callee 
				 (cons callee path))
		(loop (map
		       (cute ref <> 1)
		       (find-callees callee ftable))
		      total-callees
		      (cons callee path))))
      current-callees)
     total-callees)
   (lambda (a b)
     (cons a (map reverse b)))))

(define (reachable? from to rtable)
  (or (let1 callers-from (all-callers from rtable)
	    (if-let1 found (assoc-ref  callers-from to #f)
		     (map
		      (lambda (f)
			f)
		      found)
		     #f))
      (let1 callers-to (all-callers to rtable)
	    (if-let1 found (assoc-ref  callers-to from #f)
		     (map
		      (lambda (f)
			f)
		      found)
		     #f))
      (list #f)))
(define (transit from to ftable rtable)
  (delete-duplicates
   (let1 r (reachable? from to rtable)
	 (if (equal? r (list #f))
	     (let1 commons (append (let* ((callers-from (all-callers from rtable))
					  (callers-to (all-callers to rtable))
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
				   (let* ((callees-from (all-callees from ftable))
					  (callees-to (all-callees to ftable))
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



(define (qr-eval es env ftable rtable)
  (match es
   ((? string? name) (ref ftable name (list #f)))
   ((? symbol? name) (ref ftable (x->string name) (list #f)))
   (('callers (? string? name)) (find-callers name rtable))
   (('callees (? string? name)) (find-callees name ftable))
   (('dump-table) (rtable-dump rtable))
   (('all-callers (? string? name)) (all-callers name rtable))
   (('all-callees (? string? name)) (all-callees name ftable))
   (('reachable? from to) (delete-duplicates (reachable? from to rtable)))
   (('transit from to) (transit from to ftable rtable))
   (else
    (list #f)
    )))

(define (rtable-dump table)
  (apply append (hash-table-map table (lambda (k v)
					(map
					 (lambda (v0) 
					   `(=> ,k ,(ref v0 3)))
					 (delete-duplicates v))
					))))
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
