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
	  read-dentries)
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
  (symlink-to-dname
   ))


(define-method type-maker-of ((fs-dentry <dentry>))
  (case (ref (ref fs-dentry 'stat) 'type)
    ('symlink #\s)
    ('directory #\d)
    ('regular #\-)
    (else #\?)))

(define-method dname-of ((fs-dentry <fs-dentry>))
  (ref fs-dentry 'entry))

(define-method path-of ((fs-entry <fs-dentry>))
  (build-path (ref fs-dentry 'parent)
	      (ref fs-dentry 'entry)))
(define-method size-of ((fs-entry <fs-dentry>))
  (ref (ref fs-entry 'stat) 'size))

(define-method mtime-of ((fs-entry <fs-dentry>))
  (make-time time-utc
	     0 
	     (ref (ref fs-entry 'stat) 'mtime)))

(define-method url-of ((fs-entry <fs-dentry>))
  (ref fs-entry 'url))

(define-method symlink-to-dname-of ((fs-symlink-dentry <fs-symlink-dentry>))
  (ref fs-symlink-dentry 'symlink-to-dname))


(define-method make-url-default ((fs-dentry <fs-dentry>))
  (uri-compose :scheme "file"
	       :path (path-of fs-dentry)))
(define-method make-url-default ((fs-symlink-dentry <fs-symlink-dentry>))
  (uri-compose :scheme "file"
		 :path (ref fs-dentry 'symlink-to-dname)))

(define (make-symlink-to-dname-default fs-dentry)
  (sys-readlink (path-of fs-dentry)))

(define (read-dentries path 
		       make-url 
		       make-symlink-to-dname
		       filter)
  (if (file-is-directory? path)
      (map (lambda (entry)
	     (let* ((stat (sys-stat (build-path path entry)))
		    (dentry (make (if (eq? (ref (ref dentry 'stat) 'type) 'symlink)
				      <fs-dentry>
				      <fs-symlink-dentry>)
			      :parent path
			      :entry entry
			      :stat stat)))
	       (when (symlink? dentry)
		 (set! (ref dentry 'symlink-to-dname) ((or make-symlink-to-dname
							   make-symlink-to-dname-default)
						       dentry)))
	       (set! (ref dentry 'url) ((or make-url make-url-default)
					dentry))))
	   (directory-list path
			   :add-path? #f 
			   :children? #f
			   :filter (if filter
				       filter
				       (lambda (e) #t))))
      #f))

(provide "yogomacs/dentries/fs")