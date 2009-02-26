(define-module srpmix.browse
  (use www.cgi)
  (use srfi-11)
  (use srpmix)
  (export srpmix-browse-main))
(select-module srpmix.browse)

;; ---------------------------------------------------------------------
(define (srpmix-browse-main)
  (cgi-main
   (lambda (params)
     (let/cc return
       (let* ((report-error (make-reporter return))
	      (dir     (cgi-get-parameter "path" params :default ""))
	      (display (check-dir-display (cgi-get-parameter "display" params :default "font-lock") 
					  report-error)))
	 (call-with-values (cute
			    params->path dir report-error)
	   (cute
	    path->html <> <> display report-error)))))))

(provide "srpmix/browse")