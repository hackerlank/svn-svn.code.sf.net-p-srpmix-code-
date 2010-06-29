(define-module yogomacs.handlers.dir
  (export prepare-dired-faces
	  read-dentries+)
  (use yogomacs.dired)
  (use yogomacs.css-cache)
  (use util.combinations)
  ;;
  (use yogomacs.dentries.fs)
  )
(select-module yogomacs.handlers.dir)

(define (prepare-dired-faces config)
  (for-each
   (lambda (face-style)
     (prepare-css-cache config (car face-style) (cadr face-style) '(dired)))
   (cartesian-product `(,dired-faces
			,dired-styles))))


;; ( (#/pattern0/ make-url) (#/pattern1/ #f) )

(define (make-make-make specs dname-of conv)
  (lambda (dentry-or-dname)
    (let1 dname (dname-of dentry-or-dname)
      (let loop ((specs specs))
	(if (null? specs)
	    #f
	    (let1 spec (car specs)
	      (cond
	       ((and (string? (car spec))
		     (equal? (car spec) dname)) 
		(conv spec dentry-or-dname))
	       ((and (regexp? (car spec))
		     (rxmatch (car spec) dname))
		(conv spec dentry-or-dname))
	       (else
		(loop (cdr specs))))))))))

(define (make-make-url specs)
  (make-make-make specs 
		  dname-of
		  (lambda (spec dentry)
		    (let1 conv (cadr spec)
		      (cond
		       ((string? conv) conv)
		       (else
			(conv dentry)))))))

(define (make-make-symlink-to-dname specs)
  (make-make-make specs 
		  dname-of
		  (lambda (spec dentry)
		    (if (null? (list-tail spec 2))
			#f
			(let1 conv (caddr spec)
			  (cond
			   ((string? conv) conv)
			   (else 
			    (conv dentry))))))))

				   
(define (make-filter specs)
  (make-make-make specs
		  (lambda (e) e)
		  (lambda (spec dentry) #t)))

(define (read-dentries+ path specs)
  (let ((make-url (make-make-url specs))	      
	(make-symlink-to-dname (make-make-symlink-to-dname specs))
	(filter (make-filter specs)))
    (read-dentries path
		   make-url
		   make-symlink-to-dname
		   filter)))

(provide "yogomacs/handlers/dir")