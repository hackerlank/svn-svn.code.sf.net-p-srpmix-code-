(define-module yogomacs.batch
  (export yogomacs-batch)
  (use yogomacs.main)
  (use yogomacs.config)
  (use gauche.parameter)
  (use www.cgi)
  (use util.list)
  (use srfi-13)
  )
(select-module yogomacs.batch)

(define (install-constants config)
  (map
   (lambda (entry)
     (if (eq? (car entry) 'mode)
	 '(mode . cache-build)
	 entry))
   config))

(define (yogomacs-batch path conf-name)
  (debug-print-width #f)
  (let1 apache-home "/var/www"
    (sys-putenv "HOME" apache-home)
    (sys-chdir apache-home))
  (let1 config (install-constants (load-config #`"yogomacs-,|conf-name|.cgi"))
    (let1 prefix (assq-ref config 'real-sources-dir)
      (let1 path (if (string-prefix? prefix path)
		     (substring path (string-length prefix) -1)
		     path)
	(parameterize ((cgi-metavariables `(("REQUEST_METHOD" "get")
					    ("QUERY_STRING" ,#`"path=,|path|"))))
	  (cgi-main (cute yogomacs <> config)))))))

(provide "yogomacs/batch")
