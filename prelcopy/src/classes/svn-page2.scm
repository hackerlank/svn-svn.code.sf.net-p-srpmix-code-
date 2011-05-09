(use gauche.process)
(use sxml.ssax)
(use sxml.sxpath)
(use syntax.htmlprag)
(use srfi-1)

(define jboss-svn-page2 "http://anonsvn.jboss.org/repos/svn-page2.html")
(define inaccessible-projects '("teiiddesigner" "installer" "repository.jboss.org"))
(define (svn-page2-top droppers)
  (let1 sxml (call-with-input-process
		 `(wget -q -O - ,jboss-svn-page2)
	       (cute html->shtml <>))
    (let1 urls ((sxpath `(// html body div div div div div table tr td a
			     ,(lambda (node root vars)
				((sxml:filter
				  (lambda (node)
				    (equal? (last node) "Anonymous")
				    )) 
				 node))
			     @
			     href
			     *text*
			     ))
		sxml)
      (map
       (lambda (url)
	 (cons (sys-basename url) url)
	 )
       (filter
	(lambda (elt)
	  (not (member (sys-basename elt) droppers)))
	urls))
      )))

(define (svn-page2-project-dump url)
  (let1 sxml (call-with-input-process
		 `(wget -q -O - ,url)
	       (cute html->shtml <>))
    ((sxpath '(// html body ul li a *text*)) sxml)))

(for-each
   (lambda (top)
     (let ((project (car top))
	   (url (cdr top)))
       (let1 dirs (svn-page2-project-dump url)
	 #;(format #t "~a -> ~a\n" project url)
	 (format #t "time svn checkout ~a ~a\n" url project)
	 #;(for-each 
	  (lambda (dir)
	    (when (#/\/$/ dir)
	      (format #t "	~a -> ~a/~a\n" dir url dir)))
	  dirs)
	 )
       ))
   (svn-page2-top inaccessible-projects))
    
  
;; ((branch "NAME" "SVN-SPEC-URL")...(tag "NAME" "SVN-SPEC-URL")...)
(define (svn-page2-project url)
  
  )


