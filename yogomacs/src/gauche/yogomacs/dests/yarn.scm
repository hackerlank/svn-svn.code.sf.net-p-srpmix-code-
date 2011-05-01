(define-module yogomacs.dests.yarn
  (export yarn-dest
	  yarn-sink
	  yarn-route
	  yarn-route$
	  )
  (use www.cgi)  
  #;(use yogomacs.access)
  #;(use yogomacs.storages.yarn)
  (use srfi-1)
  (use file.util)
  (use yogomacs.yarn)
  (use yogomacs.path)
  (use yogomacs.reply)
  ;;
  (use rfc.uri)
  (use yogomacs.error)
  (use yogomacs.auth)
  )

(select-module yogomacs.dests.yarn)

(define yarn-route "/web/yarn")
(define (yarn-route$ elt)
   (build-path yarn-route elt))

(define (yarn-dest path params config)
  (if-let1 user+role (maybe-login params config)
	   (let1 params ((params "user" (car user+role)) "role" (cadr user+role))
	     (list (cgi-header :content-type "text/x-es")
		   (with-output-to-string
		     (pa$ write (cons 'yarn-container
				      (collect-yarns-by-path 
				       (compose-path (cddr path))
				       params
				       config)))
		     )))
	   (unauthorized config)))

(define (verify-yarn yarn)
  (and-let* (( (list? yarn) )
	     ( (not (null? yarn)) )
	     ( (eq? (car yarn) 'yarn) ))
    yarn))

(define (record-es lpath es params config)
  (and-let* (( (list? es) )
	     ( (not (null? es)) )
	     ( (eq? (car es) 'yarn-container) )
	     (yarns (cdr es))
	     ( (every verify-yarn yarns) ))
    (cast-yarns-for-path
     (compose-path (cddr lpath))
     yarns
     params
     config)
    (make <empty-data>)))

(define (yarn-sink lpath params config)
  (if-let1 user+role (authorized? config)
	   (let1 params ((params "user" (car user+role)) "role" (cadr user+role))
	     (if-let1 encoded-string (params "stitch")
		      (let1 decode-string (uri-decode-string encoded-string :cgi-decode #t)
			(if-let1 es (guard (e
					    (else #f))
				      (read-from-string decode-string))
				 (record-es lpath es params config)
				 (bad-request "Broken Es expression" (write-to-string lpath))))
		      (bad-request "No stitch params" (write-to-string lpath))))
	   (unauthorized config)))

(provide "yogomacs/dests/yarn")