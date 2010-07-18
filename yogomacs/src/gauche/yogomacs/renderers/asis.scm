(define-module yogomacs.renderers.asis
  (export asis)
  (use yogomacs.access)
  (use yogomacs.error)
  (use text.tree)
  (use www.cgi)
  )
(select-module yogomacs.renderers.asis)

(define (asis src-path mime-type config)
  (if (readable? src-path)
      (call-with-input-file src-path
	(lambda (input-port)
	  (let* ((stat (sys-fstat input-port))
		 (size (ref stat 'size))
		 (data (read-block size input-port)))
	    data))
	:if-does-not-exist :error
	:element-type :binary)
      (not-found "File not found"
		 src-path)))

(provide "yogomacs/renderers/asis")