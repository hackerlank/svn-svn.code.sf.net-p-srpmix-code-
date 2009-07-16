#!/usr/bin/gosh
;; -*- scheme -*-
(use gauche.version)

;; find /srv/sources/attic/repo -type f | gosh sbuild-repogc.scm
(define (main args)
  ;;
  (define htable (make-hash-table 'equal?))
  ;;
  (let loop ((l (read-line)))
    (unless (eof-object? l)
      (rxmatch-cond
	((rxmatch #/(.+-srpmix)-([0-9].*)/ l)
	 (file base version)
	 (hash-table-push! htable base file)
	 (loop (read-line)))
	((rxmatch #/(.+-srpmix-archives)-([0-9].*)/ l)
	 (file base version)
	 (hash-table-push! htable base file)
	 (loop (read-line)))
	((rxmatch #/(.+-srpmix-plugins)-([0-9].*)/ l)
	 (file base version)
	 (hash-table-push! htable base file)
	 (loop (read-line)))
	(else
	 (print l)
	 (loop (read-line))
	 ))))
  (hash-table-for-each htable 
		       (lambda (k v)
			 ;; 
			 (let1 l (cdr (sort v version>?))
			   (unless (null? l)
			     (write l) 
			     (newline)
			 )))))
