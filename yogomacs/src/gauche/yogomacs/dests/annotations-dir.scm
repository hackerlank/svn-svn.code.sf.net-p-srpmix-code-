(define-module yogomacs.dests.annotations-dir
  (export annotations-dir-dest)
  (use srfi-1)
  (use yogomacs.path)
  (use yogomacs.route)
  (use yogomacs.renderers.dired)
  (use yogomacs.dests.css)
  (use yogomacs.dests.dir)
  (use yogomacs.reply)
  
  (use yogomacs.dentry)
  (use yogomacs.dentries.subject)
  (use yogomacs.dentries.redirect)
  (use yogomacs.yarn)
  )

(select-module yogomacs.dests.annotations-dir)


(define (dest lpath params config)
  (let1 shtml (dired
	       (compose-path lpath)
	       (list
		(current-directory-dentry lpath)
		(parent-directory-dentry lpath)
		(make <redirect-dentry>
		  :parent (compose-path lpath)
		  :dname "subjects" 
		  :url (compose-path* lpath "subjects"))
		)
	       css-route)
    (prepare-dired-faces config)
    (make <shtml-data>
      :params params
      :config config
      :data ((compose integrate-dired-face) shtml)
      :last-modification-time #f)))

(define (subjects-dest lpath params config)
  (let1 shtml (dired
	       (compose-path lpath)
	       (cons*
		(current-directory-dentry lpath)
		(parent-directory-dentry lpath)
		(map
		 (lambda (subject-entry)
		   (make <subject-dentry>
		     :parent (compose-path lpath)
		     :dname (symbol->string (car subject-entry))
		     :nlink (ref (cdr subject-entry) 0)
		     :size (ref (cdr subject-entry) 1)
		     :mtime (ref (cdr subject-entry) 2))
		   )
		 (all-subjects params config)))
	       css-route)
    (prepare-dired-faces config)
    (make <shtml-data>
      :params params
      :config config
      :data ((compose integrate-dired-face) shtml)
      :last-modification-time #f)))

(define (routing-table path params)
  `((#/^\/annotations$/ ,dest)
    (#/^\/annotations\/subjects$/ ,subjects-dest)
    ))

(define (annotations-dir-dest lpath params config)
  (route (routing-table lpath params) (compose-path lpath) params config)
  )


(provide "yogomacs/dests/annotations-dir")