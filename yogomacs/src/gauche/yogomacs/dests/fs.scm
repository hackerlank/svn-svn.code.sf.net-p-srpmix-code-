(define-module yogomacs.dests.fs
  (export fs-dest)
  (use srfi-1)
  (use file.util)
  (use www.cgi)
  (use yogomacs.access)
  (use yogomacs.path)
  (use yogomacs.dests.file)
  (use yogomacs.dests.dir))

(select-module yogomacs.dests.fs)

(define (fs-dest path params config)
  (let* ((last (last path))
	 (head (path->head path))
	 (real-src-dir (build-path (config 'real-sources-dir) head)))
    (if (readable? real-src-dir last)
	(if (directory? real-src-dir last)
	    (dir-dest path params config)
	    (file-dest path params config))
	(cgi-header :status "404 Not Found"))))

(provide "yogomacs/dests/fs")