(define-module yogomacs.handlers.dir
  (export prepare-dired-faces
	  read-dentries+
	  dir-handler)
  (use srfi-1)
  (use www.cgi)  
  (use file.util)
  ;;
  (use yogomacs.dentry)
  (use yogomacs.dentries.fs)  
  (use yogomacs.dired)
  (use util.combinations)
  (use yogomacs.path)
  ;;
  (use yogomacs.render)
  (use yogomacs.css-cache)
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


(define (dir-handler path params config)
  (let ((last (last path))
	(head (path->head path)))
    (prepare-dired-faces config)
    (list
     (cgi-header)
     (render
      (dired (compose-path path)
	     (read-dentries+ (build-path "/srv/sources" head last)
			     (dir-spec (build-path "/" head) last))
	     "/web/css")))))

(define (dir-spec base last)
  `(("." ,(build-path base last))
    (".." ,base)
    (#/.*/ ,(lambda (fs-dentry) 
	      (build-path base 
			  last
			  (dname-of fs-dentry))))))

(define (path->head path)
  (let1 l (reverse (cdr (reverse path)))
    (if (null? l)
	""
	(apply build-path l))))

(provide "yogomacs/handlers/dir")