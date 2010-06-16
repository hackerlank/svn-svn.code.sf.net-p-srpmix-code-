(define-module font-lock.rearrange.range
  (export rearrange-range
	  parse-range)
  (use sxml.tree-trans)
  (use srfi-1)
  (use util.match))
(select-module font-lock.rearrange.range)

(define (id . args) args)

(define (linum-of line)
  (and-let* (( (not (null? line)) )
	     (attrs (car line))
	     ( (not (null? attrs)) )
	     ( (eq? (car attrs) '|@|) )
	     (class-value (assq 'class (cdr attrs)))
	     ( (equal? "linum" (cadr class-value)) )
	     (id-value (assq 'id (cdr attrs)))
	     (match (#/^L:([0-9])+/ (cadr id-value)))
	     (line-str (match 1)))
    (string->number line-str)))

(define (delete* object tree . rest)
  (let1 elt= (if (null? rest) 
		 equal?
		 (car rest))
    (let loop ((tree tree))
      (cond 
       ((null? tree) ())
       ((list? tree) (map loop (delete object tree 
				       elt=)))
       (else tree)))))

(define (make-trimmer range)
  (let1 rules (let* ((hide #f))
		`(
		  (span *preorder* . ,(lambda (tag . all)
					(let1 l (linum-of all)
					  (if l
					      (if (range l)
						  (begin
						    (set! hide #f)
						    (cons tag all))
						  (begin
						    (set! hide #t)
						    '*hidden*))
					      (if hide 
						  '*hidden*
						  (cons tag all))
					      ))))
		  (*text* . ,(lambda (tag str) 
			       (if hide '*hidden* str)))
		  (*default* . ,(lambda x 
				  (if hide '*hidden* x)))
		  ))
    `(
      (body . ,(lambda (tag . all)
		 (cons tag (delete* '*hidden* all eq?))))
      (pre ,rules . ,id)
      (*text* . ,(lambda (tag str) str))
      (*default* . ,id)
      )))

(define make-range (match-lambda*
		    ((#t #t) (lambda (i) #t))
		    ((#t e) (lambda (i) (< i e)))
		    ((b #t) (lambda (i) (<= b i)))
		    ((b #f) (lambda (i) (eq? b i)))
		    ((b e)  (lambda (i) (and (<= b i) (< i e))))))

(define (rearrange-range sxml-tree start end)
  (pre-post-order sxml-tree (make-trimmer (make-range start end))))

(define (parse-range str)
  (rxmatch-cond
    ((#/^([1-9][0-9]*)-([1-9][0-9]*)$/ str)
     (#f start-str end-str)
     (let ((start (string->number start-str))
	   (end (string->number end-str)))
       (if (<= start end)
	   (cons start end)
	   (errorf "end(~d) is greater than start(~d): ~a" start end str))))
    ((#/^([1-9][0-9]*)-$/ str)
     (#f start-str)
     (cons (string->number start-str) #t))
    ((#/^-([1-9][0-9]*)$/ str)
     (#f end-str)
     (cons #t (string->number end-str)))
    ((#/^-$/ str)
     (#f)
     (cons #t #t))
    (else
     (errorf "broken range specification: ~s" str))))
    
(provide "font-lock/rearrange/range")
