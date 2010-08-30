(define-module yogomacs.renderers.archive
  (export archive)
  (use yogomacs.access)
  (use yogomacs.error)
  ;;
  (use gauche.process)
  (use file.util)
  (use srfi-19)
  (use yogomacs.util.compress)
  )
(select-module yogomacs.renderers.archive)

(define bsize  (* 4096 100))

(define (tar-initial input filename-base output)
  (run-process `(tar 
		 --xform ,#`"s/^,(sys-basename input)\\(.*\\)/,|filename-base|\\1/"
		 --directory ,(sys-dirname input)
		 -cf ,output ,(sys-basename input)) :wait #t))

(define (tar-update base-archive cd file-to-add)
  (run-process `(tar
		 --directory ,cd
		 --add-file ,file-to-add
		 -uf ,base-archive)
	       :wait #t))

(define-macro (no-error . body)
  (let1 e (gensym)
    `(guard (,e (else #f))
       ,@body)))

(define (write-enclave-file enclave-file path)
  (with-output-to-file enclave-file
    (lambda ()
      (write ";; -*- scheme -*-")
      (newline)
      (write `(source-enclave
	       :version 0
	       :path ,path ;???
	       :date ,(date->string (time-utc->date (current-time))
				    "~b ~e ~H:~M ~Y")))
      (newline))
    :if-exists :error))
	 
(define (archive src-real-path src-web-path filename-base config)
  (if (readable? src-real-path)
      (values
       ;; TODO: Use unwind-protect
       (receive (oport file) (sys-mkstemp "/tmp/archive1")
	 (let* ((compressed-file #`",|file|.xz")
		(metadata-dir-base (build-path (temporary-directory)
					       #`"archive2-,(sys-getpid)"))
		(metadata-dir (build-path metadata-dir-base
					  filename-base))
		(metadata-file-base ".enclave")
		(metadata-file (build-path metadata-dir metadata-file-base)))
	   (guard (e (else 
		      (no-error
		       (sys-unlink file))
		      (no-error
		       (sys-unlink compressed-file))
		      (no-error
		       (remove-directory* metadata-dir-base))
		      (raise e)))
	     (let1 proc (tar-initial src-real-path filename-base file)
	       (close-output-port oport)
	       (unless (eq? (process-exit-status proc) 0)
		 (internal-error "" "inital tar failed")))

	     (make-directory* metadata-dir)
	     (write-enclave-file metadata-file src-web-path)

	     (let1 proc (tar-update file metadata-dir-base
				    (build-path filename-base metadata-file-base))
	       (remove-directory* metadata-dir-base)
	       (unless (eq? (process-exit-status proc) 0)
		 (internal-error "" "updating tar failed")))
	     (let1 proc (compress file)
	       (sys-unlink file)
	       (unless (eq? (process-exit-status proc) 0)
		 (internal-error "" "compressing tar file failed")))
	     (let1 iport (open-input-file compressed-file 
					  :if-does-not-exist :error
					  :element-type :binary)
	       (lambda ()
		 (let loop ((block (read-block bsize iport)))
		   (if (eof-object? block)
		       (begin (close-input-port iport)
			      (sys-unlink compressed-file))
		       (begin (display block)
			      (loop (read-block bsize iport))))))))))
       #f)
      (not-found "File not found"
		 src-real-path)))

(provide "yogomacs/renderers/archive")