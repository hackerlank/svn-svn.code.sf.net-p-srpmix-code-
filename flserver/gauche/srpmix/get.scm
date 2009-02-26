(define-module srpmix.get
  (use www.cgi)
  (use srfi-11)
  (use srpmix)
  (export srpmix-get-main))
(select-module srpmix.get)



;; ---------------------------------------------------------------------
;; http://srpmix.org/api/file.cgi?package=kernel&dist=f10&stage=pre-build&file=kernel-2.6.27/linux-2.6.27.x86_64/kernel/sched.c
;; http://srpmix.org/api/file.cgi?package=kernel&dist=f10&stage=pre-build&file=kernel-2.6.27/linux-2.6.27.x86_64/kernel/sched.c&range=100-120&display=font-lock

;; ---------------------------------------------------------------------
(define (srpmix-get-main)
  (cgi-main
   (lambda (params)
     (let/cc return
       (let* ((report-error (make-reporter return))
	      (package (check-package (cgi-get-parameter "package" params :default #f) report-error))
	      ;;
	      (dist    (cgi-get-parameter "dist" params :default #f))
	      (version (cgi-get-parameter "version" params :default #f))
	      ;;
	      (stage   (check-stage (cgi-get-parameter "stage" params :default "pre-build") report-error))
	      ;;
	      (file    (cgi-get-parameter "file" params :default #f))
	      ;;
	      (line    (check-line (cgi-get-parameter "line" params :default #f) report-error))
	      (range   (check-range (cgi-get-parameter "range" params :default #f) report-error))
	      ;;
	      (display (check-file-display (cgi-get-parameter "display" params :default "raw") report-error)))
	 (call-with-values (cute 
			    params->path dist version package stage file report-error)
	   (cute 
	    path->html <> <> line range display report-error)))))))

(provide "srpmix/get")