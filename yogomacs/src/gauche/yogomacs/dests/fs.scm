(define-module yogomacs.dests.fs
  (export fs-dest
	  fs-dest-read-only)
  (use srfi-1)
  (use file.util)
  (use www.cgi)
  (use yogomacs.access)
  (use yogomacs.path)
  (use yogomacs.dests.file)
  (use yogomacs.dests.dir)
  (use yogomacs.error))

(select-module yogomacs.dests.fs)

(define (fs-dest path params config)
  (let* ((last (last path))
	 (head (path->head path))
	 (real-src-dir (make-real-src-path config head)))
    (if (readable? real-src-dir last)
	(if (directory? real-src-dir last)
	    (dir-dest path params config)
	    (file-dest path params config))
	(not-found #`"Cannot find ,(compose-path path)"
		   #`",|real-src-dir| for ,(compose-path path)"))))

(define (fs-dest-read-only path params config)
  (fs-dest path params (config 'mode 'read-only)))


(provide "yogomacs/dests/fs")