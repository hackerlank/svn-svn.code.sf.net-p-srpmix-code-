(define-module yogomacs.renderers.cache
   (export cache)
   (use rfc.md5)
   (use util.digest)
   (use file.util)
   (use yogomacs.renderer)
   (use yogomacs.access)
   (use yogomacs.compress)
   (use yogomacs.caches.shtml)
   (use gauche.process)
   (use yogomacs.cache))

(select-module yogomacs.renderers.cache)

(define (md5->cache-file md5 config)
  (let1 dir (md5->cache-dir md5 config)
    (build-path dir "xz")))

(define (md5->cache-dir md5 config)
   (let1 n 6
	 (apply format (apply build-path (shtml-cache-dir config)
			      (make-list (+ n 1) "~a"))
		(append
		 (map
		  (pa$ apply substring)
		  (zip (make-list n md5)
		       (iota n 0 2)
		       (iota n 2 2)))
		 (list  (substring md5 (* n 2) -1)))))))

(define-macro (ignore-exception . body)
  (let ((e (gensym)))
    `(guard (,e (else #f))
	    ,@body)))

(define (remove-safe file)
  (ignore-exception (sys-unlink  file)))

(define (cached? cache-file)
  (file-is-readable? cache-file))

(define (read-cache cache-file)
  (guard (e (<read-error> 
	     (remove-safe cache-file)
	     (internal-error "Broken Cache"
			     (format "~s (~a)" cache-file
				     (condition-ref e 'message))))
	    (<process-abnormal-exit>
	     (remove-safe cache-file)
	     (internal-error "Failed to Read Cache"
			     (format "~s (~a)" cache-file
				     (condition-ref e 'message))))
	    (else
	     (internal-error "Cache Lost"
			     (format "~s (~a)" 
				     cache-file
				     (condition-ref e 'message)))))
    (with-input-from-compressed-file cache-file
				     read)))
				    

(define (build-cache prepare-proc cache-file src-path)
  (let1 cache-dir (sys-dirname cache-file)
    (guard (e (else (internal-error "Failed to prepare cache directory"
				    (format "~s (~a)"
					    cache-dir
					    (condition-ref e 'message)))))
	   (make-directory* cache-dir))
    (let ((shtml (prepare-proc))
	  (tmp   (format "~a/.~a--~a" 
			 cache-dir 
			 (sys-basename cache-file)
			 (sys-getpid))))
      (with-output-to-file tmp
	(pa$ write shtml)
	:if-exists :supersede
	:if-does-not-exist :create)
      (ignore-exception 
       (compress tmp)
       (sys-rename (format "~a.xz" tmp) cache-file))
      (remove-safe tmp)
      (let1 back-ptr (digest-hexify (md5-digest-string src-path))
	(ignore-exception
	 (sys-symlink src-path (build-path cache-dir back-ptr))
	 ))
      ;; shtml
      cache-file)))

(define (newer-than? cache-file src-path)
  (file-mtime>? cache-file src-path))

(define (cache src-path prepare-proc config)
  (unless (readable? src-path)
    (not-found "File Not Found" src-path))
  (let* ((md5 (guard (e (else 
			  (not-found "Failed to prepare cache name"
				     src-path)))
		      (with-input-from-file src-path
			(compose digest-hexify md5-digest)
			:if-does-not-exist :error
			:element-type :binary)))
	 (cache-file (md5->cache-file md5 config)))
     ;;
     (cache-kernel (lambda ()
		      (if (and (cached? cache-file)
			       (newer-than? cache-file src-path))
			  cache-file
			  #f))
		   (pa$ (build-cache (pa$ prepare-proc src-path config) 
				     cache-file
				     src-path))
		   read-cache)))

(provide "yogomacs/renderers/cache")
