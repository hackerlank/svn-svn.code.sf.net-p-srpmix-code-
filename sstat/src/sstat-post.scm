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

(define (link data-dir entry output-dir mapping)
  (rxmatch-let (#/sstat-([0-9]+)\.es/ entry)
      (#f date)
    (with-input-from-file (build-path data-dir entry)
      (lambda ()
	(let loop ((r (read)))
	  (unless (eof-object? r)
	    (when (and (list? r)
		       (eq? (car r) 'nfsd-open-pre)
		       (eq? (length r) 7))
	      (let ((ip (cadr (memq :ip r)))
		    ;; TODO: time
		    (path (string-drop (cadr (memq :path r))
				       ;; should be inlined
				       (string-length "var/lib/srpmix/sources/"))))
		(let ((name (hash-table-get mapping ip (inet-address->string ip AF_INET)))
		      (basename (sys-basename path))
		      (dirname  (sys-dirname  path)))
		  (link-dates output-dir name date dirname basename)
		  (link-users output-dir name date dirname basename)
		  )))
	    (loop (read))
	    ))))))

(define (link-dates output-dir name date driname basename)
;  (make-directory* (format "~a/dates/~a/~a/"
;			   output-dir
;			   date
  )

(define (link-users output-dir name date dirname basename)
  (let* ((path (build-path output-dir "sources" dirname basename))
	 (regular? (file-is-regular? path)))
    (unless regular?
      (let ((dir (format "~a/users/~a/~a/~a"
			       output-dir
			       name
			       date
			       dirname)))
	(make-directory* dir)
	(sys-chdir dir)
	(sys-symlink (format "~a/sources/~a/~a" 
			     (let1 n (string-count (format "users/~a/~a" name date) #\/)
			       (apply string-append (make-list n "../")))
			     dirname
			     basename)
		     (format "~a/~a" dirname basename))))))

;; (sstat-mapping "host" "name")
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
		    (name (caddr r)))
		(for-each (cute hash-table-put! ht <> name)
			    (map inet-string->address 
				 (ref (sys-gethostbyname host) 'addresses)))
		))
	    (loop (read))))))
    ht))
