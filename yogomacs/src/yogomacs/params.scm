(define-module yogomacs.params
  (export
   params->path)
  (use file.util)
  (use util.match)
  (use yogomacs.config)
  (use yogomacs.check)
  (use yogomacs.font-lock)
  )

(select-module yogomacs.params)

(define (cgi-encode path)
  (if (string? path)
      (regexp-replace-all #/ / path "+")
      path))
(define params->path (match-lambda*
		      ((dist version package stage file err-return)
		       (let1 file (cgi-encode file)
			 (if dist
			     (params->path-via-dists dist package stage file err-return)
			     (params->path-via-sources package version stage file err-return))))
		      ((dir err-return)
		       (let1 dir (cgi-encode dir)
			 (let1 path (check-dir dir err-return)
			   (cond
			    ((not (file-is-readable? path))
			     (err-return (format "Target unreadable: ~s" dir)))
			    ((file-is-directory? path)
			     (values path 'dir))
			    ((file-is-regular? path)
			     (values path 'file))
			    (else
			     (err-return (format "No handler for: ~s" dir)))))))))


(define (params->path-via-package package-dir stage file err-return)
  (let1 stage-object (string-append package-dir "/" stage)
    (cond
     ((and (file-is-regular? stage-object)
	   (file-is-readable? stage-object))
      (values file 'file))
     (else
      (check-file file err-return)
      (let1 file-object (string-append stage-object "/" file)
	(cond 
	 ((and (file-is-regular? file-object)
	       (file-is-readable? file-object))
	  (values file-object 'file))
	 ((and (file-is-directory? file-object)
	       (file-is-readable? file-object))
	  (values file-object 'dir))
	 (else
	  (err-return (format "Target unreadable: ~s" file-object)))))))))

(define (params->path-via-dists dist package stage file err-return)
  (let ((dists (directory-list dists-prefix :children? #t
			       :filter (lambda (e) (not (equal? e ".htaccess")))
			       )))
    (unless (member dist dists)
      (err-return (format "Unknown dist: ~s" dist))) 
    (let1 dist-dir (string-append dists-prefix "/" dist)
      (let1 package-dir (string-append dist-dir "/" 
				       "packages" "/"
				       (substring package 0 1) "/"
				       package)
	(unless (file-is-directory? package-dir)
	  (err-return (format "No directory for package: ~s" package)))
	(params->path-via-package package-dir stage file err-return)))))
(define (params->path-via-sources package version stage file err-return)
  (let1 package-dir (string-append sources-prefix "/"
				   (substring package 0 1) "/"
				   package)
    (unless (file-is-directory? package-dir)
      (err-return (format "No directory for package: ~s" package)))
    (check-version version err-return)
    (let1 version-dir (string-append package-dir "/"
				     version)
      (unless (file-is-directory? version-dir)
	(err-return (format "No directory for version: ~s" version)))
      (params->path-via-package version-dir stage file err-return))))


(provide "yogomacs/params")