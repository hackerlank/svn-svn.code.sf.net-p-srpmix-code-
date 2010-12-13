(define-module yogomacs.reels.stitch-es
  (export <stitch-es>)
  (use yogomacs.path)
  (use yogomacs.util.ebuf)
  (use file.util)
  (use util.combinations)
  (use srfi-13)
  (use srfi-1)
  (use gauche.sequence)
  (use yogomacs.reel)
  (use srfi-19)
  (use rfc.sha1)
  )

(select-module yogomacs.reels.stitch-es)



(define (make-es-provider file-name)
  (let1 port (open-input-file file-name :if-does-not-exist #f)
    (lambda () 
       (cond
	((not port) (eof-object))
	((port-closed? port) (eof-object))
	(else
	 (let1 r (read port)
	   (when (eof-object? r)
	     (close-input-port port))
	   r))))))

(define (not-given key)
  (error "Field not given:" key))

(define (find-the-best-lines lines line)
  (define (delta l) (abs (- l line)))
  (cadr (reduce
	 (lambda (a b)
	   (if (< (car a) (car b)) a b))
	 (list (delta (car lines)) (car lines))
	 (zip (map delta lines) lines))))

(define (find-line-transit file surround line)
  (let ((ebuf (make <ebuf>))
	(str  (apply string-append surround))
	(surround-size (string-count (car surround) #\newline)))
    (find-file! ebuf file)
    (let1 lines (let loop ((start-from 0)
			   (lines (list)))
		  (let1 n (search-forward ebuf str start-from)
		    (if n
			(loop (+ n 1) 
			      (cons (+ (line-for ebuf n) surround-size) lines))
			lines)))
      (if (null? lines)
	  #f
	  (find-the-best-lines lines line)))))
    
(define (targeted? path target config)
  (guard (e (else #f))
    (cond
     ((not (list? target)) #f)
     ((null?  target) #f)
     ((not (eq? (car target) 'target)) #f)
     (else
      (let1 type (get-keyword :type (cdr target))
	(cond
	 ((eq? type 'file)
	  (let-keywords (cdr target)
	      ((file (not-given :file))
	       (line (not-given :line))
	       (surround #f)
	       . rest)
	    (cond
	     ((equal? file path)
	      `(:target (file ,line)))
	     ;; TODO /srv/sources should taken from conf or something else
	     ((and (string-prefix? "/srv/sources" file)
		   ;; TODO: Use build-path
		   (equal? (string-append (config 'real-sources-dir) path) file))
	      `(:target (file ,line)))
	     ((and surround
		   (equal? (sys-basename file)
			   (sys-basename path))
		   ;; TODO
		   (file-is-readable? (string-append (config 'real-sources-dir) path)))
	      (let1 transited-line (find-line-transit (string-append (config 'real-sources-dir) path)
						      surround line)
		(if transited-line
		    `(:target 
		      (file ,transited-line) 
		      :transited (,(if (string-prefix? (config 'real-sources-dir) file)
				       (string-drop file (string-length (config 'real-sources-dir)))
				       file)
				  ,line))
		    #f)))
	     (else
	      #f))))
	 ((eq? type 'directory)
	  (let-keywords (cdr target)
	      ((directory (not-given :directory))
	       (item (not-given :item))
	       . rest)
	     (set! directory (directory-file-name directory))
	     (cond
	      ((equal? directory path)
	       `(:target (directory ,item)))
	      ;; TODO /srv/sources should taken from conf or something else
	      ((and (string-prefix? (config 'real-sources-dir) directory)
		    ;; TODO: Use build-path
		    (equal? (string-append (config 'real-sources-dir)
					   (if (equal? path "/") "" path))
			    directory))
	       `(:target (directory ,item)))
	      (else
	       #f))))
	 (else
	  #f)))))))

(define (make-annotation-yarn-frag annotation)
  (guard (e (else #f))
    (cond
     ((not (list? annotation)) #f)
     ((null? annotation) #f)
     ((not (eq? (car annotation) 'annotation)) #f)
     (else
      (let1 type (get-keyword :type (cdr annotation))
	(cond
	 ((or (eq? type 'text)
	      (eq? type 'oneline))
	  (let-keywords (cdr annotation)
	      ((data (not-given :date)) . rest)
	    `(:content (text ,data))))
	 (else
	  #f)))))))

(define (make-yarn target-yarn-frag
		   annotation
		   date
		   full-name
		   mailing-address
		   subjects)
  (let1 annotation-yarn-frag (make-annotation-yarn-frag annotation)
    (if annotation-yarn-frag
	(let1 y `(yarn
		  :version 0
		  ,@target-yarn-frag
		  ,@annotation-yarn-frag
		  :full-name ,full-name
		  :mailing-address ,mailing-address
		  :date ,date
		  :subjects ,subjects
		  )
	  (let1 sha1 (digest-hexify (digest-string <sha1> (write-to-string y)))
	    (reverse (cons* sha1 :id (reverse y)))
	    ))
	#f)))

(define (make-yarn-filter path config)
  (lambda (es to)
    (guard (e (else to))
      (cond
       ((not (list? es)) to)
       ((null? es) to)
       ((not (eq? (car es) 'stitch-annotation)) to)
       (else 
	(let-keywords (cdr es)
	    ((version (not-given :version))
	     (target-list (not-given :target-list))
	     (annotation-list (not-given :annotation-list))
	     (date (not-given :date))
	     (full-name (not-given :full-name))
	     (mailing-address (not-given :mailing-address))
	     (subjects :keywords (not-given :subjects))
	     . rest)
	  (let loop ((target*annotation (cartesian-product 
					 (list target-list annotation-list)))
		     (to to))
	    (if (null? target*annotation)
		to
		(let* ((target (car (car target*annotation)))
		       (annotation (cadr (car target*annotation)))
		       (target-yarn-frag (targeted? path target config)))
		  (if target-yarn-frag
		      (loop (cdr target*annotation)
			    (let1 yarn (make-yarn target-yarn-frag
						  annotation
						  date
						  full-name
						  mailing-address
						  subjects)
			      (if yarn
				  (cons yarn to)
				  to)))
		      (loop (cdr target*annotation)
			    to)))))))))))

(define (stitch-es->yarn es-file path params config)
  (port-fold (make-yarn-filter path config) 
	     (list)
	     (make-es-provider es-file)))


(define-class <stitch-es> (<reel>)
  ((es-file :init-keyword :es-file)
   )
  )

(define-method spin-for-path ((stitch-es <stitch-es>)
			      (path <string>))
  (stitch-es->yarn (ref stitch-es 'es-file)
		   path
		   (ref stitch-es 'params)
		   (ref stitch-es 'config)))

(define-method spin-of-author ((stitch-es <stitch-es>)
			       (author <string>))
  
  #f)

(define-method spin-about-subjects ((stitch-es <stitch-es>)
				    (subjects <list>))
  #f)

;; #(nlink size date)
;; "Thu Aug 12 09:53:13 2010"
(define (entry-date->utc date)
  (date->time-utc (string->date date 
				"~a ~b ~e ~H:~M:~S ~Y")))

(define (update-entry! entry size date)
  (let ((nlink (+ (ref entry 0) 1))
	(size (+ (ref entry 1) size))
	(utc  (let1 utc (entry-date->utc date)
		(if (time<? (ref entry 2) utc)
		    utc
		    (ref entry 2)))))
    (set! (ref entry 0) nlink)
    (set! (ref entry 1) size)
    (set! (ref entry 2) utc)))

(define (make-entry size date)
  (vector 1 size (entry-date->utc date)))

(define-method all-subjects ((stitch-es <stitch-es>))
  (hash-table-map
   (port-fold (lambda (es to)
	       (guard (e (else to))
		 (cond
		  ((not (list? es)) to)
		  ((null? es) to)
		  ((not (eq? (car es) 'stitch-annotation)) to)
		  (else
		   (let-keywords (cdr es)
		       ((subjects :keywords (not-given :subjects))
			;; "Thu Aug 12 09:53:13 2010"
			(size 0)
			(date (not-given :date))
			. rest)
		     (for-each (lambda (subj)
				 (let1 entry (hash-table-get to subj #f)
				   (if entry
				       (update-entry! entry size date)
				       (hash-table-put! to subj (make-entry size date)))))
			       subjects)
		     to)))))
	     (make-hash-table 'eq?)
	     (make-es-provider (ref stitch-es 'es-file)))
   (lambda (k v)
     (cons k v))))

(provide "yogomacs/reels/stitch-es")