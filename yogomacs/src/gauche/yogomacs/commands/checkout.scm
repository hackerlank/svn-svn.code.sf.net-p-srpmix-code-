(define-module yogomacs.commands.checkout
  (export checkout-dest)
  (use yogomacs.command)
  (use yogomacs.access)
  (use text.html-lite)
  (use www.cgi)
  (use srfi-1)
  (use srfi-13)
  (use yogomacs.error)
  (use yogomacs.reply)
  (use yogomacs.renderers.archive)
  (use yogomacs.path)
  )

(select-module yogomacs.commands.checkout)

(define (input->filename-base input)
  (string-join (delete "" (string-split input #\/)) "--"))


(define (checkout-dest lpath params config)
  (or (and-let* (( (list? lpath ) )
		 ( (< 2 (length lpath)) )
		 (input-web (compose-path (cdr (cdr lpath))))
		 (input-local (string-append (config 'real-sources-dir) 
					     input-web))
		 ( (archivable? input-local config) )
		 (filename-base (input->filename-base input-web))
		 )
	(receive (data last-modified-time) (archive input-local
						    input-web
						    filename-base
						    config)
	  (make <checkout-data>
	    :mime-type "application/x-tar"
	    :filename (string-append filename-base ".tar.xz")
	    :data data
	    :last-modification-time last-modified-time)))
      (bad-request "Cannot checkout" (write-to-string lpath))))

(provide "yogomacs/commands/checkout")