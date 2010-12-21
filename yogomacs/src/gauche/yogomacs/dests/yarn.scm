(define-module yogomacs.dests.yarn
  (export yarn-dest
	  yarn-sink
	  yarn-route
	  yarn-route$
	  )
  (use www.cgi)  
  #;(use yogomacs.access)
  #;(use yogomacs.storages.yarn)
  (use srfi-1)
  (use file.util)
  (use yogomacs.yarn)
  (use yogomacs.path)
  (use yogomacs.reply)
  ;;
  (use rfc.uri)
  (use srfi-19)
  (use yogomacs.error)
  (use yogomacs.auth)
  (use yogomacs.storages.yarn)
  (use gauche.fcntl)
  )

(select-module yogomacs.dests.yarn)

(define yarn-route "/web/yarn")
(define (yarn-route$ elt)
   (build-path yarn-route elt))

(define (yarn-dest path params config)
  (list (cgi-header :content-type "text/x-es")
	(with-output-to-string
	  (pa$ write (cons 'yarn-container
			   (collect-yarns-by-path 
			    (compose-path (cddr path))
			    params
			    config)))
	  )))
#|
lpath
    ("web" "yarn" "dists")
es
    (yarn-container (yarn :version 0 :target (directory . "cs4u4") :content (text "asfasfasdf") :subjects ("*DRAFT*")))
(stitch-annotation :version 0 :target-list ((target :type file :file "/srv/sources/sources/c/cman/2.0.98-1.el5_3.8/pre-build/cman-2.0.98/fence/fenced/main.c" :point 2424 :coding-system undecided-unix :line 106 :surround ("
" "" "	if (comline.clean_start_opt == FALSE) {
		str = NULL;") :which-func "setup_ccs")) :annotation-list ((annotation :type text :data "優先順位: コマンドライン, ローカルで動作するccsd(cluster.conf)、ハードコードされている値(0)")) :date "Tue Aug 10 22:31:21 2010" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (reading-fenced-clean-start))
|#

(define (verify-yarn yarn)
  (and-let* (( (list? yarn) )
	     ( (not (null? yarn)) )
	     ( (eq? (car yarn) 'yarn) ))
    yarn))

(define (record-es lpath es params config)
  (and-let* (( (list? es) )
	     ( (not (null? es)) )
	     ( (eq? (car es) 'yarn-container) )
	     (yarns (cdr es))
	     ( (every verify-yarn yarns) ))
    (cast-yarns-for-path
     (compose-path (cddr lpath))
     yarns
     params
     config)
    (make <empty-data>)))

(define (cast-yarn-for-path path yarn params config)
  (let-keywords (cdr yarn) ((src-version :version (error #f))
			    (src-target :target (error #f))
			    (src-content :content (error #f))
			    (src-subjects :subjects (error #f)))
		(unless (eq? src-version 0) (error #f))
		(unless (and (pair? src-target)
			     (not (null? src-target))
			     (memq (car src-target) '(directory file))
			     (not (null? (cdr src-target)))
			     (string? (cdr src-target)))
		  (error #f))
		(unless (and (list? src-content)
			     (not (null? src-content))
			     (eq? (car src-content) 'text)
			     (not (null? (cdr src-content)))
			     (string? (cadr src-content)))
		  (error #f))
		(let ((dst-version src-version)
		      (dst-target  `(target :type ,(car src-target)
					    ,@(cond
					       ((eq? (car src-target) 'directory)
						(list :directory (string-append "/srv/sources" path)
						      :item (cdr src-target)))
					       ((eq? (car src-target) 'file)
						(list :file (string-append "/srv/sources" path)
						      :line (cdr src-target))))))
		      (dst-annotation `(annotation :type text :data ,(cadr src-content)))
		      (dst-date (date->string (current-date) "~a ~b ~e ~H:~M:~S ~Y"))
		      (dst-full-name (ref (params "user") 'real-name))
		      (dst-mailing-address (ref (params "user") 'name))
		      (dst-keywords (map string->symbol src-subjects)))
		  
		  (and-let* ((user (params "user"))
			     (file-name (build-path (yarn-cache-dir config) 
						    #`",(ref user 'name).es")))
		    (let ((port (open-output-file file-name
						  :if-exists :append
						  :if-does-not-exist :create))
			  (lk (make <sys-flock> :type F_WRLCK :whence SEEK_SET :start 0 :len 0)))
		      (sys-fcntl port F_SETLKW lk)
		      (write
		       `(stitch-annotation :version ,dst-version
					   :target-list (,dst-target)
					   :annotation-list (,dst-annotation)
					   :date ,dst-date
					   :full-name ,dst-full-name
					   :mailing-address ,dst-mailing-address
					   :keywords ,dst-keywords)
		       port)
		      (newline port)
		      (set! (ref lk 'type) F_UNLCK)
		      (sys-fcntl port F_SETLKW lk)
		      (close-input-port port)
		      ))))
  #;(guard (e
  (else (bad-request "Broken Yarn expression" yarn)))
  ))

(define (cast-yarns-for-path path yarns params config)
  (for-each
   (cute cast-yarn-for-path path <> params config)
   yarns))

(define (yarn-sink lpath params config)
  (if-let1 user+role (authorized? config)
	   (let1 params ((params "user" (car user+role)) "role" (cadr user+role))
	     (if-let1 encoded-string (params "stitch")
		      (let1 decode-string (uri-decode-string encoded-string :cgi-decode #t)
			decode-string
			(if-let1 es (guard (e
					    (else #f))
					   (read-from-string decode-string))
				 (record-es lpath es params config)
				 (bad-request "Broken Es expression" (write-to-string lpath))))
		      (bad-request "No stitch params" (write-to-string lpath))))
	   (unauthorized config)))

(provide "yogomacs/dests/yarn")