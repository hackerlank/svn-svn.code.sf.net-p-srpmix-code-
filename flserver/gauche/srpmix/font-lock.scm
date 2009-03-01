(define-module srpmix.font-lock
  (use file.util)
  (use gauche.process)

  (use util.digest)
  (use rfc.md5)

  (use www.cgi)
  
  (use srpmix.config)
  (use srpmix.emacs)
  (export font-lock)
  )
(select-module srpmix.font-lock)

(define socket-dir "/home/masatake/tmp")
(define output-dir "/home/masatake/tmp/flcache")

(define (make-cache-file-name path)
  (build-path output-dir
	      (digest-hexify (md5-digest-string path))))

(define (script-font-lock input output range)
  (list 'flserver-htmlize 
	input
	output
	(list 'quote (if range 
			 (list (car range)
			       (last range))
			 'nil))))

(define (font-lock input err-return)
  ;; INPUT as OUTPUT if the file is too large.
  (let1 output (if (< max-font-lock-size
		      (file-size input))
		   input
		   (make-cache-file-name input))
    (when (and (not (eq? input output))
	       (file-is-readable? output))
      (touch-file output))
    (unless (file-is-readable? output)
      (let1 p (run-emacs (build-path socket-dir ".flserver")
			 (script-font-lock input output #f)
			 #t)
	(unless (eq? (process-exit-status p) 0)
	  (err-return "failed in font-lock"))))
    (list 
     (cgi-header :content-type (if (eq? input output) "text/plain" "text/html"))
     (call-with-input-file output port->string))))

(provide "srpmix/font-lock")