(define-module yogomacs.rearranges.yogomacs-fragment
  (export yogomacs-fragment)
  (use srfi-1)
  (use sxml.sxpath)
  (use sxml.tree-trans)
  (use yogomacs.shell)
  (use yogomacs.shells.bscm)
  (use yogomacs.shells.ysh)
  (use yogomacs.access)
  )

(select-module yogomacs.rearranges.yogomacs-fragment)

(define (yogomacs-fragment shtml shell-name config)
  (let* ((title ((if-car-sxpath '(// html head title *text*)) shtml))
	 (frag ((if-car-sxpath '(// html body pre)) shtml))
	 (frag (pre-post-order
		frag 
		`(
		  (a . ,(lambda (tag attr a-text)
			  (list 
			   tag
			   (pre-post-order
			    attr
			    `((href . ,(lambda (tag text) 
					 (list tag
					       (cond
						((#/^#/ text) text)
						;; TOOD: THIS SHOULD BE SEPARATED REARRANGE?
						((and (equal? title "/")
						      (equal? a-text ".."))
						 "/"
						 )
						;; TOOD: THIS SHOULD BE SEPARATED REARRANGE.
						((and (equal? a-text ".")
						      (archivable?  (string-append
								     (config 'real-sources-dir)
								     title)
								    config))
						 #`"/commands/tar,|title|")
						((and-let* ((m (#/^\/(.+)/ text))
							    (entry (m 1))
							    ((member entry (map (cut ref <> 'name)
										(all-shells)))))
						   #t) text)
						((#/^http:.*/ text) text)
						((#/^ftp:.*/ text) text)
						(else (string-append #`"/,|shell-name|" text))))))
			      (*text* . ,(lambda (tag str) str))
			      (*default* . ,(lambda x x))
			      ))
			   a-text)))
		  (*text* . ,(lambda (tag str) str))
		  (*default* . ,(lambda x x))))))
    `(*TOP* (*PI* xml "version=\\"1.0\\" encoding=\\"UTF-8\\"")
	    ,(cons* 'pre `(|@| (class "contents") (id "contents"))
		    (cdr frag)))))
  
(provide "yogomacs/rearranges/yogomacs-fragment")
