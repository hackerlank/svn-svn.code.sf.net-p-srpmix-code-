(define-module srpmix.config
  (export prefix 
	  dist-prefix
	  sources-prefix
	  top-entries
	  emacsclient 
	  max-font-lock-size
	  socket-file
	  cache-dir
	  ))
(select-module srpmix.config)


(define config-file "/home/masatake/var/flserver/config.es")

(define prefix #f)
(define dist-prefix #f)
(define sources-prefix #f)

(define top-entries '("sources" "dists" "packages"))
(define emacsclient #f)
(define max-font-lock-size #f)
(define socket-file #f)
(define cache-dir #f)

(call-with-input-file config-file
  (lambda ()
    (let loop ((r (read)))
      (unless (eof-object? r)
	(when (and (list? r)
		   (eq? (car r) 'conf))
	  (let ((key (cadr r))
		(value (caddr r)))
	    (case key
	      ('web-dir
	       (set! prefix value))
	      ('emacsclient
	       (set! emacsclient value))
	      ('max-font-lock-size
	       (set! max-font-lock-size value))
	      ('socket-file
	       (set! socket-file value))
	      ('cache-dir
	       (set! cache-dir value))
	      ('dist-dir
	       (set! dist-prefix value))
	      ('sources-dir
	       (set! sources-prefix value))
	      ;;
	      )))))))
		
(provide "srpmix/config")
