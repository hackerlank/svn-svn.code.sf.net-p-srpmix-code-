(use gauche.process)
#;(prelcopy :package "JBossEAP"
          :branch  "trunk"
          :command-line "svn checkout http://anonsvn.jboss.org/repos/jbossas/trunk"
	  :update #f
          :generated-by "svnweb+jbossas.prelcopy")

; lcopy-genconf --output-dir=OUTPUT-DIR --no-update --generated-by=svnweb+jbossas.prelcopy JBossEAP,trunk svn checkout http://anonsvn.jboss.org/repos/jbossas/trunk 
(define (prelcopy kar kdr output-dir)
  (let-keywords* kdr ((package #f)
		      (branch  #f)
		      (command-line #f)
		      (update #f)
		      (generated-by #f))
    (let1 cmd/args `(lcopy-genconf ,@(if output-dir 
					 (list (format "--output-dir=~a" output-dir))
					 (list))
				   ,@(if update
					 (list)
					 (list "--no-update"))
				   ,@(if generated-by
					 (list (format "--generated-by=~a" generated-by))
					 (list))
				   ,(format "~a,~a" package branch)
				   ,@(string-split command-line 
						   (lambda (c) 
						     (or (eq? c #\ )  (eq? c #\tab ) )
						     )))
      (run-process cmd/args :wait #t)
      )))


(define (main args)
  (let1 output-dir (if (eq? (length (cdr args)) 1)
		       (cadr args)
		       #f)
    (let loop ((r (read)))
      (unless (eof-object? r)
	(when (and (list? r)
		   (eq? 'prelcopy (car r)))
	  (prelcopy (car r) (cdr r) output-dir))
	(loop (read))))))