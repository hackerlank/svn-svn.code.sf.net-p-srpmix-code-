(define-module srpmix.browse
  (use www.cgi)
  (use srfi-11)
  (use srpmix)
  (export srpmix-browse-main))
(select-module srpmix.browse)

;; ---------------------------------------------------------------------
(debug-print-width #f)
(define (srpmix-browse-main)
  (cgi-main
   (lambda (params)
     (let/cc return
       (let* ((report-error (make-reporter return))
	      (path     (cgi-get-parameter "path" params :default ""))
	      (display (check-dir-display (cgi-get-parameter "display" params :default "font-lock") 
					  report-error)))
	 ;(debug-print path)
	 (call-with-values (cute
			    params->path path report-error)
	   (cute
	    path->html <> <> display report-error)))))))

(provide "srpmix/browse")