(define-module yogomacs.dests.yarn
  (export yarn-dest
	  yarn-sink
	  yarn-route
	  yarn-route$
	  )
  (use www.cgi)  
  #;(use yogomacs.access)
  #;(use yogomacs.storages.yarn)
  #;(use srfi-1)
  (use file.util)
  (use yogomacs.yarn)
  (use yogomacs.path)
  (use yogomacs.reply)
  ;;
  (use rfc.uri)
  )

(select-module yogomacs.dests.yarn)

(define yarn-route "/web/yarn")
(define (yarn-route$ elt)
   (build-path yarn-route elt))

(define (yarn-dest path params config)
  (list (cgi-header :content-type "text/x-es")
	(with-output-to-string
	  (pa$ write (cons 'yarn-container
			   (collect-yarns-by-path 
			    (compose-path (cddr path))
			    params
			    config)))
	  )))

(define (yarn-sink lpath params config)
  (if-let1 encoded-string (params "stitch")
	   (let1 decode-string (uri-decode-string encoded-string :cgi-decode #t)
	     (if-let1 es (guard (e
				 (else #f))
				(read-from-string decode-string))
		      (begin 
			#?=es
			(make <empty-data>))
		      (bad-request "Broken Es expression" (write-to-string lpath))))
	   (bad-request "No stitch params" (write-to-string lpath))))

(provide "yogomacs/dests/yarn")