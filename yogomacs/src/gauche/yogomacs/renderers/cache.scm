(define-module yogomacs.renderers.cache
   (export cache)
   (use rfc.sha1)
   (use util.digest)
   (use file.util)
   (use yogomacs.renderer)
   (use yogomacs.access)
   (use yogomacs.compress)
   (use gauche.process))

(select-module yogomacs.renderers.cache)

(define (sha1->cache-file sha1 config)
  (let1 dir (sha1->cache-dir sha1 config)
    (build-path dir sha1)))

(define (sha1->cache-dir sha1 config)
  (format "/var/cache/yogomacs/~a/shtml/~a/~a/~a/~a/~a/~a"
		    (config 'spec-conf)
		    (substring sha1 0 2)
		    (substring sha1 2 4)
		    (substring sha1 4 6)
		    (substring sha1 6 8)
		    (substring sha1 8 10)
		    (substring sha1 10 12)
		    ))

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
				    

(define (build-cache prepare-proc cache-file)
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
	:if-exists :error
	:if-does-not-exist :create)
      (ignore-exception 
       (compress tmp)
       (sys-rename (format "~a.xz" tmp) cache-file))
      shtml)))

(define (newer-than? cache-file src-path)
  (file-mtime>? cache-file src-path))

(define (cache src-path prepare-proc config)
  (unless (readable? src-path)
    (not-found "File Not Found" src-path))
  (let* ((sha1 (guard (e (else 
			  (not-found "Failed to prepare cache name"
				     src-path)))
		      (with-input-from-file src-path
			(compose digest-hexify sha1-digest)
			:if-does-not-exist :error
			:element-type :binary)))
	 (cache-file (sha1->cache-file sha1 config)))
    (if (and (cached? cache-file)
	     (newer-than? cache-file src-path))
	(read-cache cache-file)
	(build-cache (pa$ prepare-proc src-path config) 
		     cache-file))))

(provide "yogomacs/renderers/cache")
