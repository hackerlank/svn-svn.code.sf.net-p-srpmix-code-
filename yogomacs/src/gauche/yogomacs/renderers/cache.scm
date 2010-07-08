(define-module yogomacs.renderers.cache
   (export cache)
   (use rfc.sha1)
   (use util.digest)
   (use file.util)
   (use yogomacs.renderer)
   (use yogomacs.access))

(select-module yogomacs.renderers.cache)

(define (sha1->cache-file sha1 config)
  (let1 dir (sha1->cache-dir sha1 config)
    (values (build-path dir sha1)
	    dir)))

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

(define (cache src-path prepare-proc config)
  (define (e403)
    (error <renderer-error>
	   :status "403 Not Found"
	   "File Not Found"))
  (define (e500 msg)
    (error <renderer-error>
	   :status "500 Internal Error"
	   msg))
  (unless (readable? src-path)
    (e403))
  (let1 sha1 (guard (e (else 
			(e403)))
		    (with-input-from-file src-path
		      (compose digest-hexify sha1-digest)
		      :if-does-not-exist :error
		      :element-type :binary))
    (receive  (cache-file cache-dir) (sha1->cache-file sha1 config)
      (if (file-is-readable? cache-file)
	  (guard (e (<read-error> 
		     (unwind-protect (sys-unlink  cache-file) #t)
		     (e500 "Broken Cache"))
		    (<error>
		     (e500 "Cache Lost")))
		 (with-input-from-file cache-file
		   ;; TODO ungzip
		   read
		   :if-does-not-exist :error))
	  (begin
	    (guard (e (else e500))
		   (make-directory* cache-dir))
	    (let ((shtml (prepare-proc src-path config))
		  (tmp   (format "~a/.~a--~a" 
				 cache-dir 
				 (sys-basename cache-file)
				 (sys-getpid))))
	      (with-output-to-file tmp
		(pa$ write shtml)
		:if-exists :error
		:if-does-not-exist :create)
	      ;; TODO gzip
	      (sys-rename tmp cache-file)
	      shtml))))))
	  
      

(provide "yogomacs/renderers/cache")
