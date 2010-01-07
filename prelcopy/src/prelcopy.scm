#;(prelcopy :package "JBossEAP"
          :branch  "trunk"
          :command-line "svn checkout http://anonsvn.jboss.org/repos/jbossas/trunk"
	  :update #t
          :generated-by "svnweb+jbossas.prelcopy")

(define (main args)
  (let loop ((r (read)))
    (unless (eof-object? r)
      ...
      (loop (read)))))