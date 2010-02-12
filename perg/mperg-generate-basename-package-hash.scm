(use util.list)
(define (add-to-tables iport p vr 
		       ;basename->paths
		       ;path->packages
		       basename->packages)
  (let loop ((r (read-line iport)))
    (unless (eof-object? r)
      (rxmatch-let 
	  (#/(.*),(file|symlink|directory)$/ r)
	  (#f file type)
	(unless (equal? type "directory")
	  (let* ((basename (sys-basename file))
		 (slot     (hash-table-get basename->packages basename (list)))
		 (pvr      (list p vr)))
	    (unless (member pvr slot)
	      (hash-table-push! basename->packages basename (list p vr)))
	    )
	  ))
      (loop (read-line iport)))))

(define (main args)
  (let (;(basename->paths (make-hash-table 'equal?))
	;(path->packages  (make-hash-table 'equal?))
	(basename->packages (make-hash-table 'equal?)))
    (let loop ((r (read-line)))
      (unless (eof-object? r)
	(rxmatch-let
	    (#/^.*\/packages\/([^\/]+)\/[^\/]+\/([^\/]+)\/([^\/]+)\/[^\/]+\/files/ r)
	    (#f package version release)
	  (call-with-input-file r
	    (cute add-to-tables <> package (string-append version "-" release)
		  ;basename->paths
		  ;path->packages
		  basename->packages)))
	(loop (read-line))))

    (write '(define basename->packages (make-hash-table 'equal?)))
    (newline)

    (hash-table-for-each basename->packages
			 (lambda (k v)
			   (write `(hash-table-put! basename->packages ,k (quote ,v)))
			   (newline)))
    (newline)
    ))