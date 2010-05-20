(define-module yogomacs.font-lock
  (use srfi-13)
  (use file.util)
  (use gauche.process)

  (use util.digest)
  (use rfc.md5)

  (use www.cgi)
  
  (use yogomacs.config)
  (use yogomacs.emacsclient)
  (use yogomacs.flserver)
  (export font-lock)
  )
(select-module yogomacs.font-lock)

(unless (file-is-readable? cache-timestamp-file)
  (touch-file cache-timestamp-file))
	 
(define (make-cache-file-name path)
  (build-path cache-dir
	      (substring (sys-realpath path) (+ (string-length prefix) 1) -1)
	      #;(digest-hexify (md5-digest-string path))))

(define (script-font-lock input output)
  (list 'flserver-xhtmlize 
	input
	output
	))

(define (deliver file content-type)
  (list
   (cgi-header :content-type content-type)
   (call-with-input-file file port->string)))



(define (font-lock input err-return)
  (let1 retry-jump (lambda (str)
		     (run-flserver)
		     (sys-sleep 5)
		     (font-lock0 input err-return))
	(font-lock0 input retry-jump)))

(define (font-lock0 input err-return)
  (if (< max-font-lock-size (file-size input))
      (deliver input "text/plain")
      (let1 output (make-cache-file-name input)
	(cond
	 ((and (file-is-readable? output)
	       (file-mtime<? input output)
	       (file-mtime<? cache-timestamp-file output)
	       )
	  (touch-file output)
	  (deliver output "text/html"))
	 (else
	  (sys-unlink output)
	  (make-directory* (sys-dirname output))
	  (let1 p (run-emacsclient socket-file
				   (script-font-lock input output)
				   #t)
	    (unless (eq? (process-exit-status p) 0)
	      (err-return "failed in font-lock"))
	    (unless (file-is-readable? output)
	      (err-return (format "failed in font-locking: ~s"
				  (string-drop input (string-length prefix)))))
	    (deliver output "text/html")))))))

(provide "yogomacs/font-lock")
