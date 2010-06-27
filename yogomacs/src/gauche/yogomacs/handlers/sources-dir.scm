(define-module yogomacs.handlers.sources-dir
  (export sources-dir)
  (use text.html-lite)
  (use www.cgi)  
  ;;
  (use yogomacs.dentries.fs)
  (use yogomacs.dired)
  (use yogomacs.path)
  ;;
  (use sxml.serializer)
  ;;
  )
(select-module yogomacs.handlers.sources-dir)

(define (sources-dir-make-url fs-dentry)
  (cond
   ((equal? "." (dname-of fs-dentry)) "/sources")
   ((equal? ".." (dname-of fs-dentry)) "/")
   (else (string-append "/sources/" (dname-of fs-dentry)))))

(define (sources-dir path params)
  (list
   (cgi-header)
   (srl:sxml->xml-noindent 
	(dired (compose-path path)
	       (read-dentries "/srv/sources/sources"
			      sources-dir-make-url
			      #f
			      #f)
	       "/web/css")
	)))

(provide "yogomacs/handlers/sources-dir")