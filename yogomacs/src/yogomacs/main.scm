(define-module yogomacs.main
  (use text.html-lite)
  (use www.cgi)
  (use yogomacs.sanitize)
  (use yogomacs.check)
  (use yogomacs.params)
  (export yogomacs-main))

(select-module yogomacs.main)

(define (make-reporter return)
  (lambda (string)
    (return (list (cgi-header)
		  (html-doctype)
		  (html:html 
		   (html:body 
		    (html:p 
		     (html-escape-string string))))))))

(define (yogomacs-main params)
  (let/cc return
    (let* ((report-error (make-reporter return))
	   (path    (sanitize-path (cgi-get-parameter "path" params :default "")))
	   (display (check-dir-display (cgi-get-parameter "display" params :default "font-lock") 
				       report-error)))
      
      (call-with-values (cute
			 params->path path report-error)
	(cute
	 path->html <> <> display report-error)))))

(provide "yogomacs/main")