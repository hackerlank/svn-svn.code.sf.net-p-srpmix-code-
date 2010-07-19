(define-module yogomacs.renderers.asis
  (export asis)
  (use yogomacs.access)
  (use yogomacs.error))
(select-module yogomacs.renderers.asis)

(define (asis src-path config)
  (if (readable? src-path)
      (values (call-with-input-file src-path
		(lambda (input-port)
		  (let* ((stat (sys-fstat input-port))
			 (size (ref stat 'size))
			 (data (read-block size input-port)))
		    data))
		:if-does-not-exist :error
		:element-type :binary)
	      (ref (sys-stat src-path) 'mtime))
      (not-found "File not found"
		 src-path)))

(provide "yogomacs/renderers/asis")