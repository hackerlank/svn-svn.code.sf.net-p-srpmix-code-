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
  (format #t "	~a --data-dir=DATADIR --output-dir=OUTPUTDIR [--mapping-file=MAPPINGFILE]\n")
  (sys-exit status)
  )

(define (main args)
  (let-args (cdr args)
      ((help         "h|help"         => (cut print-usage (car args) (current-output-port) 0))
       (data-dir     "data-dir=s"     #f)
       (output-dir   "output-dir=s"   #f)
       (mapping-file "mapping-file=s" #f)
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
      (for-each (cut link data-dir <> output-dir mapping)
		(directory-list data-dir 
				:children? #t 
				:add-path? #f 
				:filter #/^sstat-([0-9]+)\.es$/)
		))))

(define delta 1)
(define (link data-dir entry output-dir mapping)
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
			(let1 uesr (hash-table-get mapping ip (inet-address->string ip AF_INET))
			  (hash-table-push! per-user-table user `#(time date path)))))
		    (loop (read) per-user-table))))))
      
      (hash-table-for-each per-user-table
	(lambda (user vs)
	  (let1 last-time 0
	    (for-each
	     (lambda (v)
	       (let* ((time    (vector-ref v 0))
		      (date    (vector-ref v 1))
		      (path    (vector-ref v 2))
		      (basename (sys-basename path))
		      (dirname  (sys-dirname  path)))
		 (when (> (- time last-time) delta)
		   (set! last-time time)
		   (link-dates output-dir user date dirname basename)
		   (link-users output-dir user date dirname basename))))
	     (reverse vs))))))))

;; /srv/sources/dates/$date/$user/[a-z]/$pkg...
(define (link-dates output-dir user date dirname basename)
  (let* ((new-dir-path (format "~a/dates/~a/~a/~a"
			       output-dir
			       date
			       user
			       dirname))
	 (new-file-path (format "~a/~a" new-dir-path basename)))
    (make-directory* new-dir-path)
    (sys-chdir new-dir-path)
    (unless (file-exists? new-file-path)
      (sys-symlink (format "~asources/~a/~a" 
			   (let1 n (+ 1 (string-count 
					 (format "dates/~a/~a/~a" date user dirname)
					 #\/))
			     (apply string-append (make-list n "../")))
			   dirname
			   basename)
		   new-file-path))))

;; /srv/sources/users/$user/[a-z]/$pkg...
(define (link-users output-dir user date dirname basename)
  (let* ((new-dir-path (format "~a/users/~a/~a"
			       output-dir
			       user
			       dirname))
	 (new-file-path (format "~a/~a" new-dir-path basename)))
    (make-directory* new-dir-path)
    (sys-chdir new-dir-path)
    (unless (file-exists? new-file-path)
      (sys-symlink (format "~asources/~a/~a" 
			   (let1 n (+ 1 (string-count 
					 (format "users/~a/~a" user dirname)
					 #\/))
			     (apply string-append (make-list n "../")))
			   dirname
			   basename)
		   new-file-path))))

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
