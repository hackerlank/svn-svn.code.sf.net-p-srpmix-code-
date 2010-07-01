(define-module yogomacs.dentries.fs
  (export <fs-dentry>
	  <fs-symlink-dentry>
	  ;;
	  type-maker-of
	  dname-of
	  path-of
	  size-of
	  mtime-of
	  url-of
	  symlink-to-dname-of
	  ;;
	  read-dentries
	  glob-dentries)
  ;;
  (use yogomacs.dentry)
  (use file.util)
  (use rfc.uri)
  (use srfi-19))

(select-module yogomacs.dentries.fs)


(define-class <fs-dentry> (<dentry>)
  ((parent :init-keyword :parent)
   (entry :init-keyword :entry)
   (stat :init-keyword :stat)
   url
   ))

(define-class <fs-symlink-dentry> (<symlink-dentry> <fs-dentry>)
  (symlink-to-dname))


(define-method type-maker-of ((fs-dentry <dentry>))
  (case (ref (ref fs-dentry 'stat) 'type)
    ('symlink #\s)
    ('directory #\d)
    ('regular #\-)
    (else #\?)))

(define-method dname-of ((fs-dentry <fs-dentry>))
  (ref fs-dentry 'entry))

(define-method path-of ((fs-dentry <fs-dentry>))
  (build-path (ref fs-dentry 'parent)
	      (ref fs-dentry 'entry)))
(define-method size-of ((fs-dentry <fs-dentry>))
  (ref (ref fs-dentry 'stat) 'size))

(define-method mtime-of ((fs-dentry <fs-dentry>))
  (make-time time-utc
	     0 
	     (ref (ref fs-dentry 'stat) 'mtime)))

(define-method url-of ((fs-dentry <fs-dentry>))
  (ref fs-dentry 'url))

(define-method symlink-to-dname-of ((fs-symlink-dentry <fs-symlink-dentry>))
  (ref fs-symlink-dentry 'symlink-to-dname))


(define-method make-url-default ((fs-dentry <fs-dentry>))
  (uri-compose :scheme "file"
	       :path (sys-normalize-pathname (path-of fs-dentry)
					     :canonicalize #t
					     )))
(define-method make-url-default ((fs-symlink-dentry <fs-symlink-dentry>))
  (uri-compose :scheme "file"
		 :path (ref fs-dentry 'symlink-to-dname)))

(define (make-symlink-to-dname-default fs-dentry)
  (guard (e
	  (else #f))
    (sys-readlink (path-of fs-dentry))))

(define (const-proc value) (lambda rest value))
(define-macro (define-const-proc name value)
  `(define ,name ,(const-proc value)))

(define (read-dentries path 
		       make-url 
		       make-symlink-to-dname
		       pre-filter
		       post-filter)
  (define-const-proc accept #f)
  (define (make-conv conv accept-conv)
    (cond
     ((eq? conv #t) accept-conv)
     (conv conv)
     (else (const-proc #f))))

  (if (file-is-directory? path)
      (fold-right 
       (lambda (entry kdr)
	 (let* ((stat (sys-lstat (build-path path entry)))
		(dentry (make (if (eq? (ref stat 'type) 'symlink)
				  <fs-symlink-dentry>
				  <fs-dentry>)
			  :parent path
			  :entry entry
			  :stat stat)))
	   (when (symlink? dentry)
	     (set! (ref dentry 'symlink-to-dname) ((make-conv
						    make-symlink-to-dname
						    make-symlink-to-dname-default)
						   dentry)))
	   (set! (ref dentry 'url) ((make-conv
				     make-url
				     make-url-default)
				    dentry))
	   (if ((make-conv post-filter accept) dentry)
	       (cons dentry kdr)
	       kdr)))
       (list)
       (directory-list path
		       :add-path? #f 
		       :children? #f
		       :filter (make-conv pre-filter accept)))
      #f))

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

;; glob-dentries
;; ( ( PATTERN PRE-FILTER MAKE-URL [MAKE-SYMLINK-TO-DNAME] [POST-FILTER]) ... )
;;  PATTERN: regex, string
;;  PRE-FILTER: #t, #f, (lambda (e) ) -> #t|#f
;;  MAKE-URL: string, #f, (lambda (e) ) -> string|#f
;;  MAKE-SYMLINK-TO-DNAME: string, #f, (lambda (e) ) -> string|#f
;;  POST-FILTER: #t, #f, (lambda (e) ) -> #t|#f
(define (glob-dentries path globs)
  (define (id x) x)
  (let ((make-url (make-make-url globs))	      
	(make-symlink-to-dname (make-make-symlink-to-dname globs))
	(pre-filter (make-filter globs id cadr))
	(post-filter (make-filter globs dname-of (cute list-ref <> 4 #t))))
    (read-dentries path
		   make-url
		   make-symlink-to-dname
		   pre-filter
		   post-filter)))

(provide "yogomacs/dentries/fs")
