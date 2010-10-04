(define-module yogomacs.dests.absentees-dir
  (export absentees-dir-dest)
  (use srfi-1)
  (use gauche.collection)
  (use util.list)
  (use file.util)
  (use yogomacs.path)
  (use yogomacs.route)
  (use yogomacs.renderers.dired)
  (use yogomacs.dests.css)
  (use yogomacs.dests.dir)
  (use yogomacs.reply)
  (use yogomacs.dentries.redirect)
  (use yogomacs.dests.file)
  (use yogomacs.error)
  )

(select-module yogomacs.dests.absentees-dir)

(define (dest lpath params config)
  (let1 shtml (dired
	       (compose-path lpath)
	       (cons*
		(current-directory-dentry lpath)
		(parent-directory-dentry lpath)
		(map
		 (lambda (c)
		   (make <redirect-dentry>
		     :parent (compose-path lpath)
		     :dname (x->string c)))
		 "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
		))
	       css-route)
    (prepare-dired-faces config)
    (make <shtml-data>
      :params params
      :config config
      :data ((compose integrate-dired-face) shtml)
      :last-modification-time #f)))

(define (absentees config)
  (let1 absentees (glob (build-path (config 'real-sources-dir) "attic/cradles/*/sbuild/blacklist.d/*"))
    (zip (map sys-basename absentees)
	 (map (lambda (a)
		(sys-basename (sys-dirname (sys-dirname (sys-dirname a)))))
		absentees)
	 absentees
	 )))

(define (dhash-char-dest lpath params config)
  (let* ((dhash-char (last lpath))
	 (shtml (dired
		 (compose-path lpath)
		 (cons*
		  (current-directory-dentry lpath)
		  (parent-directory-dentry lpath)
		  (fold (lambda (kar kdr)
			  (if (equal? (substring (car kar) 0 1) dhash-char)
			      (cons
			       (make <redirect-dentry>
				 :parent (compose-path lpath)
				 :dname  (car kar)
				 :show-arrowy-to (cadr kar)
				 )
			       kdr)
			      kdr)
			  )
			(list)
			(absentees config)))
		 css-route)))
    (prepare-dired-faces config)
    (make <shtml-data>
      :params params
      :config config
      :data ((compose integrate-dired-face) shtml)
      :last-modification-time #f)))
  
(define (log-dest lpath params config)
  (let ((absentees (absentees config))
	(file (last lpath)))
    (let1 path (cadr (assoc-ref absentees file '(#f #f)))
      (if path
	  (file-dest lpath params (config 'mode 'read-only)
		     :real-src-file path
		     )
	  (not-found #`"Cannot find ,(compose-path lpath)" 
		     #`"Not found in assoc")))))

(define (routing-table path params)
  `((#/^\/absentees\/?$/ ,dest)
    (#/^\/absentees\/[0-9a-zA-Z]\/?$/ ,dhash-char-dest)
    (#/^\/absentees\/[0-9a-zA-Z]\/[^\/]+$/ ,log-dest)
    ))

(define (absentees-dir-dest lpath params config)
  (route (routing-table lpath params) (compose-path lpath) params config))

(provide "yogomacs/dests/absentees-dir")