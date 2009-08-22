#!/usr/bin/gosh				;
;; -*- scheme -*-
(use srfi-1)

#|
(srpmix-wrap name 
	     :target-srpm "mailcap-2.1.29-3.fc12.src.rpm"
	     :package "mailcap" 
	     :version "2.1.29"
	     :release "3.fc12"
	     :wrapped-name "mailcap-2.1.29-3.fc12-srpmix")
(in-repo :name "mailcap-2.1.29-3.fc12-srpmix"
	 :file "/tmp/mailcap-2.1.29-3.fc12-srpmix-3.noarch.rpm")
(in-repo :name "mailcap-2.1.29-3.fc12-srpmix-plugins"
	 :file "/tmp/mailcap-2.1.29-3.fc12-srpmix-plugins-3.noarch.rpm")


(in-repo :name "mailcap-2.1.29-3.fc11-srpmix"
	 :file "/tmp/mailcap-2.1.29-3.fc11-srpmix-3.noarch.rpm")
(in-repo :name "mailcap-2.1.29-2.fc12-srpmix-plugins"
	 :file "/tmp/mailcap-2.1.29-2.fc12-srpmix-plugins-3.noarch.rpm")
(in-repo :name "mailcap-2.1.20-3.fc12-srpmix-archives"
	 :file "/tmp/mailcap-2.1.20-3.fc12-srpmix-archives-3.noarch.rpm")

(in-repo :name "mailcap-2.1.29-3.fc12-srpmix-archives"
	 :file "/tmp/mailcap-2.1.29-3.fc12-srpmix-archives-3.noarch.rpm")
|#
#|
/tmp/mailcap-2.1.29-3.fc11-srpmix-3.noarch.rpm
/tmp/mailcap-2.1.29-2.fc12-srpmix-plugins-3.noarch.rpm
/tmp/mailcap-2.1.20-3.fc12-srpmix-archives-3.noarch.rpm
|#
(define (main args)
  (define htable (make-hash-table 'equal?))
  (let loop ((es (read)))
    (unless (eof-object? es)
      (cond
       ((and (eq? (car es)  'srpmix-wrap)
	     (eq? (cadr es) 'name))
	(let1 plist (drop es 2)
	  (let1 wrapped-name (cadr (memq :wrapped-name plist))
	    (hash-table-put! htable wrapped-name #t))))
       ((eq? (car es) 'in-repo)
	(let ((name (cadr (memq :name (cdr es))))
	      (file (cadr (memq :file (cdr es))))
	      (pat  #/(.+-srpmix)-(archives|plugins)$/)
             )
	  (let1 name (rxmatch-if (pat name) (#f body #f) body name)
              (unless (hash-table-get htable name #f)
		(print file))))))
      (loop (read)))))
