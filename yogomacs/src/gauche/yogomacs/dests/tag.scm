(define-module yogomacs.dests.tag
  (export tag-dest)
  (use www.cgi)  
  (use yogomacs.tag)
  (use yogomacs.path)
  ;;
  )

(select-module yogomacs.dests.tag)

(define (tag-dest lpath params config)
  (list (cgi-header :content-type "text/x-es")
	(with-output-to-string
	  (pa$ write (cons 'tag-container
			   (collect-tags-by-path 
			    (apply make-real-src-path config (cddr lpath))
			    params
			    config)))
	  )))

(provide "yogomacs/dests/tag")