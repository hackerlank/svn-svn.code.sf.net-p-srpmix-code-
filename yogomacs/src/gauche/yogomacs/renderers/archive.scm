(define-module yogomacs.renderers.archive
  (export archive)
  (use yogomacs.access)
  (use yogomacs.error)
  ;;
  (use gauche.process)
  )
(select-module yogomacs.renderers.archive)

(define bsize  (* 4096 100))

(define (tar input filename-base output)
  (run-process `(tar 
		 --xform ,#`"s/^,(sys-basename input)\\(.*\\)/,|filename-base|\\1/"
		 --directory ,(sys-dirname input)
		 -jcf ,output ,(sys-basename input)) :wait #t))

(define (archive src-path filename-base config)
  (if (readable? src-path)
      (values
       (receive (oport file) (sys-mkstemp "/tmp/archive")
	 (let1 proc (tar src-path filename-base file)
	   (unless (eq? (process-exit-status proc) 0)
	     (internal-error "" "tar failed")
	     ))
	 (close-output-port oport)
	 (let1 iport (open-input-file file 
				      :if-does-not-exist :error
				      :element-type :binary)
	   (lambda ()
	     (let loop ((block (read-block bsize iport)))
	       (if (eof-object? block)
		   (begin (close-input-port iport)
			  (sys-unlink file))
		   (begin (display block)
			  (loop (read-block bsize iport))))))))
       #f)
      (not-found "File not found"
		 src-path)))

(provide "yogomacs/renderers/archive")