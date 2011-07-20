#!/usr/bin/gosh				;
;; -*- scheme -*-
(use gauche.version)
(use file.util)


;; find /srv/sources/attic/repo -type f | gosh sbuild-repogc.scm
(define (main args)
  ;;
  (define htable (make-hash-table 'equal?))
  ;;
  (let loop ((l (read-line)))
    (unless (eof-object? l)
      (rxmatch-cond
	((rxmatch #/(.+-srpmix)-([0-9].*)\.noarch\.rpm/ l)
	 (file base version)
	 (hash-table-push! htable base (list file version))
	 (loop (read-line)))
	((rxmatch #/(.+-srpmix-archives)-([0-9].*)\.noarch\.rpm/ l)
	 (file base version)
	 (hash-table-push! htable base (list file version))
	 (loop (read-line)))
	((rxmatch #/(.+-srpmix-plugins)-([0-9].*)\.noarch\.rpm/ l)
	 (file base version)
	 (hash-table-push! htable base (list file version))
	 (loop (read-line)))
	;; NOTE TESTED: attachment
	((rxmatch #/(.+-srpmix-plugin-.+)-([0-9].*)\.noarch\.rpm/ l)
	 (file base version)
	 (hash-table-push! htable base (list file version))
	 (loop (read-line)))
	;;
	((rxmatch #/(.+srpmix-weakview-packages-[^-]+)-([0-9].*).noarch.rpm/ l)
	 (file base version)
	 (hash-table-push! htable base (list file version))
	 (loop (read-line)))
	((rxmatch #/(.+srpmix-weakview-dist-[^-]+)-([0-9].*).noarch.rpm/ l)
	 (file base version)
	 (hash-table-push! htable base (list file version))
	 (loop (read-line)))
	((rxmatch #/(.+srpmix-weakview-alias-[^-]+)-([0-9].*).noarch.rpm/ l)
	 (file base version)
	 (hash-table-push! htable base (list file version))
	 (loop (read-line)))
	(else
	 ;;(print l)
	 (loop (read-line))
	 ))))
  (hash-table-for-each htable 
		       (lambda (k v)
			 (let1 l (cdr (sort v 
					    (lambda (a b)
					      (version>? (cadr a) (cadr b)))))
			   (unless (null? l)
			     (remove-files (map (lambda (elt)
						  (let1 file (car elt)
						    (write `(gc-repo-srpmix-version ,file))
						    (newline)
						    file))
						l))
			     ;;(newline)
			     )))))
