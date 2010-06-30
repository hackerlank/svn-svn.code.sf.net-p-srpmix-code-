(define-module yogomacs.dests.dir
  (export prepare-dired-faces
	  read-dentries+
	  dir-dest
	  path->head)
  (use srfi-1)
  (use www.cgi)  
  (use file.util)
  ;;
  (use yogomacs.dentry)
  (use yogomacs.dentries.fs)  
  (use yogomacs.renderers.dired)
  (use util.combinations)
  (use yogomacs.path)
  ;;
  (use yogomacs.render)
  (use yogomacs.caches.css)
  ;;
  (use util.match)
  (use yogomacs.dests.css)
  )
(select-module yogomacs.dests.dir)

(define (prepare-dired-faces config)
  (for-each
   (lambda (face-style)
     (prepare-css-cache config (car face-style) (cadr face-style) '(dired)))
   (cartesian-product `(,dired-faces
			,dired-styles))))

(define (make-make-make specs dname-of conv)
  (lambda (dentry-or-dname)
    (let1 dname (dname-of dentry-or-dname)
      (let loop ((specs specs))
	(if (null? specs)
	    #f
	    (let* ((spec (car specs))
		   (pattern (car spec)))
	      (cond
	       ((and (string? pattern)
		     (equal? pattern dname)) 
		(conv spec dentry-or-dname))
	       ((and (regexp? pattern)
		     (rxmatch pattern dname))
		(conv spec dentry-or-dname))
	       (else
		(loop (cdr specs))))))))))

(define (make-conv n)
  (lambda (spec dentry)
    (let1 maker (list-ref spec n #f)
      (cond
       ((string? maker)
	maker)
       ((not maker)
	#f)
       (else
	(maker dentry))))))

(define (make-make-url specs)
  (make-make-make specs 
		  dname-of
		  (make-conv 2)))

(define (make-make-symlink-to-dname specs)
  (make-make-make specs 
		  dname-of
		  (make-conv 3)))

(define (make-filter specs dname-of ref-spec)
  (make-make-make specs
		  dname-of
		  (lambda (spec dname) 
		    (let1 filter (ref-spec spec)
		      (cond
		       ((boolean? filter) filter)
		       (else (filter dname)))))))

;; read-dentries+
;; ( ( PATTERN PRE-FILTER MAKE-URL [MAKE-SYMLINK-TO-DNAME] [POST-FILTER]) ... )
;;  PATTERN: regex, string
;;  PRE-FILTER: #t, #f, (lambda (e) ) -> #t|#f
;;  MAKE-URL: string, #f, (lambda (e) ) -> string|#f
;;  MAKE-SYMLINK-TO-DNAME: string, #f, (lambda (e) ) -> string|#f
;;  POST-FILTER: #t, #f, (lambda (e) ) -> #t|#f
(define (read-dentries+ path specs)
  (define (id x) x)
  (let ((make-url (make-make-url specs))	      
	(make-symlink-to-dname (make-make-symlink-to-dname specs))
	(pre-filter (make-filter specs id cadr))
	(post-filter (make-filter specs dname-of (cute list-ref <> 4 #t))))
    (read-dentries path
		   make-url
		   make-symlink-to-dname
		   pre-filter
		   post-filter)))


(define dir-dest 
  (match-lambda*
   ((path params config extra)
    (let ((last (last path))
	  (head (path->head path)))
      (prepare-dired-faces config)
      (list
       (cgi-header)
       (render
	(dired (compose-path path)
	       (read-dentries+ (build-path (config 'real-sources-dir) head last)
			       (dir-spec (build-path "/" head) last extra))
	       css-route)))))
   ((path params config)
    (dir-dest path params config (list)))))

(define dir-spec
  (match-lambda*
   ((base last extra)
    `(("."  #t ,(build-path base last))
      (".." #t ,base)
      ,@extra
      (#/.*/ #t ,(lambda (fs-dentry) 
		   (build-path base 
			       last
			       (dname-of fs-dentry))) #f)))
   ((base last)
    (dir-spec base last (list)))))

(define (path->head path)
  (let1 l (reverse (cdr (reverse path)))
    (if (null? l)
	""
	(apply build-path l))))

(provide "yogomacs/dests/dir")
