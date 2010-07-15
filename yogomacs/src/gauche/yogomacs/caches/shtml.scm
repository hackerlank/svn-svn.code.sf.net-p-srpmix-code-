(define-module yogomacs.caches.shtml
  (export do-shtml-cache)
  (use srfi-1)
  (use rfc.md5)
  (use util.digest)
  (use file.util)
  (use yogomacs.compress)
  (use gauche.process)
  (use yogomacs.cache)
  ;; TODO
  (use yogomacs.renderer)
  )

(select-module yogomacs.caches.shtml)

(define (shtml-cache-dir namespace config)
  (format
   "/var/cache/yogomacs/~a"
   namespace))

(define (md5->cache-file namespace md5 config)
  (let1 dir (md5->cache-dir namespace md5 config)
    (build-path dir "xz")))

(define (md5->cache-dir namespace md5 config)
  (let1 n 6
    (apply format (apply build-path (shtml-cache-dir namespace config)
			 (make-list (+ n 1) "~a"))
	   (append
	    (map
	     (pa$ apply substring)
	     (zip (make-list n md5)
		  (iota n 0 2)
		  (iota n 2 2)))
	    (list  (substring md5 (* n 2) -1))))))

(define (newer-than? cache-file src-path)
  (file-mtime>? cache-file src-path))

(define-macro (ignore-exception . body)
  (let ((e (gensym)))
    `(guard (,e (else #f))
       ,@body)))

(define (remove-safe file)
  (ignore-exception (sys-unlink  file)))

(define (cached? cache-file)
  (file-is-readable? cache-file))

(define (deliver cache-file)
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

(define (do-shtml-cache src-path prepare-thunk namespace config)
  (let* ((md5 (guard (e (else 
			 (not-found "Failed to prepare cache name"
				    src-path)))
		(with-input-from-file src-path
		  (compose digest-hexify md5-digest)
		  :if-does-not-exist :error
		  :element-type :binary)))
	 (cache-file (md5->cache-file namespace md5 config)))

    (cache-kernel
     (lambda ()
       (if (and (cached? cache-file)
		(newer-than? cache-file src-path))
	   cache-file
	   #f))
     (pa$ build-cache prepare-thunk 
	  cache-file
	  src-path)
     deliver)))

(provide "yogomacs/caches/shtml")
