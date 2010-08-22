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
		    (equal? (string-append (config 'real-sources-dir) path) directory))
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
		   keywords)
  (let1 annotation-yarn-frag (make-annotation-yarn-frag annotation)
    (if annotation-yarn-frag
	`(yarn
	  :version 0
	  ,@target-yarn-frag
	  ,@annotation-yarn-frag
	  :full-name ,full-name
	  :mailing-address ,mailing-address
	  :date ,date
	  :keywords ,keywords)
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
	     (keywords (not-given :keywords))
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
						  keywords)
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

(define-method spin-about-keywords ((stitch-es <stitch-es>)
				    (keywords <list>))
  #f)

(define-method all-keywords ((stitch-es <stitch-es>))
  (port-fold (lambda (es to)
	       (guard (e (else to))
		 (cond
		  ((not (list? es)) to)
		  ((null? es) to)
		  ((not (eq? (car es) 'stitch-annotation)) to)
		  (else
		   (let-keywords (cdr es)
		       ((keywords (not-given :keywords))
			. rest)
		     (lset-union eq? keywords to)
		     )))))
	     (list)
	     (make-es-provider (ref stitch-es 'es-file))))

(provide "yogomacs/reels/stitch-es")