(define-module yogomacs.commands.checkout
  (export checkout-dest)
  (use yogomacs.access)
  (use text.html-lite)
  (use www.cgi)
  (use srfi-13)
  (use yogomacs.error)
  (use yogomacs.reply)
  )

(select-module yogomacs.commands.checkout)

(define (input->filename input)
  ...)

(define (checkout-dest lpath params config)
  (or (and-let* (( (list? lpath ) )
		 ( (< 2 (length lpath)) )
		 (input (compose-path (cdr (cdr lpath))))
		 ( (archivable? input config) )
		 (filename (input->filename input))
		 )
	(make <checkout-data>
	  :mime-type "application/x-bzip2"
	  :filename filename
	  :data (tar input filename config)))
      (bad-request "Cannot checkout" (write-to-string lpath))
      ))

(provide "yogomacs/commands/checkout")