(define-module yogomacs.flserver
  (export flserver)
  (use font-lock.flclient)
  (use font-lock.harness)
  (use font-lock.flserver)
  ;;
  (use font-lock.harnesses.screen)
  (use font-lock.harnesses.xvnc))

(select-module yogomacs.flserver)

(define (flserver action config)
  (define (ping) (eq? (flclient-ping
		       :verbose (config 'client-verbose)
		       :socket-name (config 'client-socket-name)) 0))
  (define (launch-server)
    (let ((harness-object (choose-harness (config 'harness)))
	  (server-cmdline (emacs-cmdline (config 'emacs)
					 #f
					 (config->config-file (config 'config)))))
      (launch harness-object server-cmdline 
	      ;; TODO
	      (list)
	      #t)))
  (let ((pong (ping)))
    (unless pong (launch-server))
    (let loop ((timeout (config 'harness-timeout))
	       (pong (or pong (ping))))
      (cond
       (pong (action))
       ((<= timeout 0) #f)
       (else
	(sys-sleep 1)
	(loop (- timeout 1) (ping)))))))

(provide "yogomacs/flserver")