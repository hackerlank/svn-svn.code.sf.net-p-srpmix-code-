(define-module yogomacs.yarns.stitch-es
  (export stitch-es->yarn)
  (use yogomacs.caches.yarn)
  (use file.util)
  (use util.combinations)
  (use srfi-13)
  )

(select-module yogomacs.yarns.stitch-es)

(define-constant stitch-es "stitch.es")

(define (make-es-provider file-name)
  (let1 port (open-input-file file-name :if-does-not-exist #f)
    (lambda () 
       (cond
	((not port) (eof-object))
	((port-closed? port) (eof-object))
	(else
	 (let1 r (read port)
	   (when (eof-object? r)
	     (close-input-port port))
	   r))))))

(define (not-given key)
  (error "Field not given:" key))

(define (targeted? path target)
  (guard (e (else #f))
    (cond
     ((not (list? target)) #f)
     ((null?  target) #f)
     ((not (eq? (car target) 'target)) #f)
     (else
      (let1 type (get-keyword :type (cdr target))
	(cond
	 ((eq? type 'file)
	  (let-keywords (cdr target)
	      ((file (not-given :file))
	       (line (not-given :line))
	       (surround (not-given :surround))
	       . rest)
	    (cond
	     ((equal? file path)
	      `((:target (file ,line))))
	     ;; TODO /srv/sources should taken from conf or something else
	     ((and (string-prefix? "/srv/sources" file)
		   (equal? (build-path "/srv/sources" path) file))
	      `((:target (file ,line))))
	     (else
	      #f))))))))))

(define (make-annotation-yarn-frag annotation)
  (guard (e (else #f))
    (cond
     ((not (list? annotation)) #f)
     ((null? annotation) #f)
     ((not (eq? (car annotation) 'annotation)) #f)
     (else
      (let1 type (get-keyword :type (cdr annotation))
	(cond
	 ((eq? type 'text)
	  (let-keywords (cdr annotation)
	      ((data (not-given :date)))
	    `((:content (text ,data)))))
	 (else
	  #f)))))))

(define (make-yarn target-yarn-frag
		   annotation
		   date
		   full-name
		   mailing-address
		   keywords)
  (let1 annotation-yarn-frag (make-annotation-yarn-frag annotation)
    (if annotation-yarn-frag
	`(yarn
	  :version 0
	  ,@target-yarn-frag
	  ,@annotation-yarn-frag
	  :date ,date
	  :keywords ,keywords)
	#f)))



(define (make-yarn-filter path)
  (lambda (es to)
    (guard (e (else to))
      (cond
       ((not (list? es)) to)
       ((null? es) to)
       ((not (eq? (car es) 'stitch-annotation)) to)
       (else 
	(let-keywords (cdr es)
	    ((version (not-given :version))
	     (target-list (not-given :target-list))
	     (annotation-list (not-given :annotation-list))
	     (date (not-given :date))
	     (full-name (not-given :full-name))
	     (mailing-address (not-given :mailing-address))
	     (keywords (not-given :keywords))
	     . rest)
	  (let loop ((target*annotation (cartesian-product 
					 (list target-list annotation-list)))
		     (to to))
	    (if (null? target*annotation)
		to
		(let* ((target (car (car target*annotation)))
		       (annotation (cadr (car target*annotation)))
		       (target-yarn-frag (targeted? path target)))
		  (if target-yarn-frag
		      (loop (cdr target*annotation)
			    (let1 yarn (make-yarn target-yarn-frag
						  annotation
						  date
						  full-name
						  mailing-address
						  keywords)
			      (if yarn
				  (cons yarn to)
				  to)))
		      (loop (cdr target*annotation)
			    to)))))))))))

(define (stitch-es->yarn path params config)
  (port-fold (make-yarn-filter path) 
	     (list)
	     (make-es-provider (build-path (yarn-cache-dir config) 
					   stitch-es))))

(provide "yogomacs/yarns/stitch-es")