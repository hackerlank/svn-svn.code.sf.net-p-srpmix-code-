(define-module yogomacs.config
  (use file.util)
  (use www.cgi)
  (export host
	  prefix 
	  dists-prefix
	  sources-prefix
	  top-entries
	  emacsclient 
	  emacs
	  max-font-lock-size
	  socket-file
	  cache-dir
	  css-dir
	  css-url
	  cache-timestamp-file
	  flserver-prog-dir
	  ))

(select-module yogomacs.config)

(define host (cgi-get-metavariable "SERVER_NAME"))
(define port (cgi-get-metavariable "SERVER_PORT"))


(define prefix "/srv/sources")
(define dists-prefix "/srv/sources/dists")
(define sources-prefix "/srv/sources/sources")

(define top-entries '("sources" "dists" "packages" "plugins" "sstat"))
(define emacsclient "/usr/bin/emacsclient")
(define emacs "/usr/bin/emacs")
(define max-font-lock-size (* 1024 1024))

(define cache-dir "/var/run/yogomacs/flserver/flcache")
(define socket-file "/var/run/yogomacs/flserver/.flserver")
(define cache-timestamp-file "/var/run/yogomacs/flserver/.timestamp")
(define flserver-prog-dir "/usr/libexec/yogomacs/flserver")

(define css-dir #f)
(define css-url #f)

(define (configure config-file)
  (with-input-from-file config-file
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
		('emacs
		 (set! emacs value))
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
		('host
		 (set! host value))
		('css-dir
		 (set! css-dir value))
		('css-url
		 (set! css-url value))
		('cache-timestamp-file
		 (set! cache-timestamp-file value))
		('flserver-prog-dir
		 (set! flserver-prog-dir value))
		;;
		)))
	  (loop (read)))))))

(let1 config-file "/etc/yogomacs/config.es"
  (when (file-is-readable? config-file)
    (configure config-file)))


(provide "yogomacs/config")
