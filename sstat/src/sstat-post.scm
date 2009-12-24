#!/bin/sh
#| -*- scheme -*- |#
:; exec gosh -- $0 "$@"

(debug-print-width #f)
(use gauche.net)
(use gauche.parseopt)
(use file.util)
(use srfi-1)
(use srfi-13)

;; input: --data-dir=DATADIR --output-dir=OUTPUTDIR --mapping-file=MAPPING
(define (print-usage prog port status)
  (format #t "Usage :\n")
  (format #t "	~a -h|--help\n" prog)
  (format #t "	~a [--debug] --data-dir=DATADIR --output-dir=OUTPUTDIR [--mapping-file=MAPPINGFILE]\n" prog) 
  (sys-exit status)
  )

(define (main args)
  (let-args (cdr args)
      ((help         "h|help"         => (cut print-usage (car args) (current-output-port) 0))
       (data-dir     "data-dir=s"     #f)
       (output-dir   "output-dir=s"   #f)
       (mapping-file "mapping-file=s" #f)
       (debug        "debug"          #f)
       . rest)

    ;; data-dir
    (unless data-dir
      (display "no --data-dir\n" (current-error-port))
      (print-usage (car args) (current-error-port) 1))
    (unless (file-is-directory? data-dir)
      (display "directory specified with--data-dir does not exist\n" (current-error-port))
      (print-usage (car args) (current-error-port) 1))

    ;; output-dir
    (unless output-dir
      (display "no --output-dir\n" (current-error-port))
      (print-usage (car args) (current-error-port) 1))
    (unless (file-is-directory? output-dir)
      (display "directory specified with --output-dir does not exist\n" (current-error-port))
      (print-usage (car args) (current-error-port) 1))
    ;; id mapping
    (when (and mapping-file
	       (not (file-is-readable? mapping-file)))
      (format (current-error-port) "cannot read mapping file: \n" mapping-file))
    ;;
    (let1 mapping (if mapping-file
		      (load-mapping mapping-file)
		      (make-hash-table 'eq?))
      (for-each (cut link data-dir <> output-dir mapping debug)
		(directory-fold data-dir
				(lambda (entry result)
				  (if (#/sstat-([0-9]+)\.es$/ entry)
				      (cons 
				       (substring entry (+ 1 (string-length data-dir)) -1)
				       result)
				      result))
				'())
		))))

(define (link data-dir entry output-dir mapping debug)
  (rxmatch-let (#/sstat-([0-9]+)\.es/ entry)
      (#f date)
    (let1 per-user-table
	(with-input-from-file (build-path data-dir entry)
	  (lambda ()
	    (let loop ((r (read))
		       (per-user-table (make-hash-table 'equal?)))
	      (if (eof-object? r)
		  per-user-table
		  (when (and (list? r)
			     (eq? (car r) 'nfsd-open-pre)
			     (eq? (length r) 7))
		    (let ((ip (cadr (memq :ip r)))
			  (time (cadr (memq :time r)))
			  (path (string-drop (cadr (memq :path r))
					     ;; should be inlined
					     (string-length "var/lib/srpmix/sources/"))))
		      (when (file-is-regular? (format "/srv/sources/sources/~a" path))
			(let1 user (hash-table-get mapping ip (inet-address->string ip AF_INET))
			  (let1 user-time (or (hash-table-get per-user-table user #f)
					      (let1 user-time (make-hash-table 'eq?)
						(hash-table-put! per-user-table user user-time)
						user-time))
			    (hash-table-push! user-time time `#(,date ,path)))
			  )))
		    (loop (read) per-user-table))))))
      (hash-table-for-each per-user-table
	(lambda (user user-time)
	  (hash-table-for-each user-time
	    (lambda (time vs)
	      (when (eq? (length vs) 1)
		(let1 v (car vs)
		  (let* ((date    (vector-ref v 0))
			 (path    (vector-ref v 1))
			 (basename (sys-basename path))
			 (dirname  (sys-dirname  path)))
		    (link:user->date->package output-dir user date dirname basename debug)
		    (link:package->user output-dir user date dirname basename debug)
		    ;;(link:date->user->package output-dir user date dirname basename debug)
		    ))))))))))


(define (date->directory date)
  (format "~a/~a/~a"
	  (substring date 0 4)
	  (substring date 4 6)
	  (substring date 6 -1)))
;; user->date->package
(define (link:user->date->package output-dir user date dirname basename debug)
  (let* ((new-dir-path-body (format "user->date->package/~a/~a/~a" 
				    user
				    (date->directory date)
				    (substring dirname 2 -1)))
	 (new-dir-path (format "~a/~a"
			       output-dir
			       new-dir-path-body))
	 (new-file-path (format "~a/~a" new-dir-path basename)))

    (unless debug
      (make-directory* new-dir-path)
      (sys-chdir new-dir-path))
    (unless (file-exists? new-file-path)
      (let1 original (format "~asources/~a/~a" 
			    (let1 n (+ 1 (string-count new-dir-path-body #\/))
			      (apply string-append (make-list n "../")))
			    dirname
			    basename)
	(when debug
	  (format #t "[user->date->package] ln -s ~s ~s\n" original new-file-path))
	(unless debug
	  (sys-symlink original new-file-path))))))

;; package->user
(define (link:package->user output-dir user date dirname basename debug)
  (let* ((new-dir-path-body  (format "package->user/~a/~a" dirname basename))
	 (new-dir-path       (format "~a/~a" output-dir new-dir-path-body))
	 (new-file-path-user (format "~a/~a" new-dir-path user))
	 )
    (unless debug
      (make-directory* new-dir-path)
      (sys-chdir new-dir-path))
    ;;
    (when (file-exists? new-file-path-user)
      (sys-unlink new-file-path-user))
    (let1 original-user (format "~auser->date->package/~a/~a/~a/~a"
				(let1 n (+ 1 (string-count new-dir-path-body #\/))
				  (apply string-append (make-list n "../")))
				user
				(date->directory date)
				(substring dirname 2 -1)
				basename)
	(when debug
	  (format #t
		  "[package->user] ln -s ~s ~s\n"
		  original-user 
		  new-file-path-user))
	(unless debug
	  (sys-symlink original-user new-file-path-user)))))

;; (sstat-mapping "host" "user")
(define (load-mapping mapping-file)
  (let1 ht (make-hash-table 'eq?)
    (with-input-from-file mapping-file
      (lambda ()
	(let loop ((r (read)))
	  (unless (eof-object? r)
	    (when (and (list? r) 
		       (eq? (car r) 'sstat-mapping)
		       (eq? (length r) 3))
	      (let ((host (cadr r))
		    (user (caddr r)))
		(for-each (cute hash-table-put! ht <> user)
			    (map inet-string->address 
				 (ref (sys-gethostbyname host) 'addresses)))
		))
	    (loop (read))))))
    ht))
