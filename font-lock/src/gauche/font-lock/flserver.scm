(define-module font-lock.flserver
  (export emacs-cmdline
	  config->config-file
	  )
  (use file.util)
  (use srfi-1)
  )
(select-module font-lock.flserver)

(define (emacs-cmdline emacs load-path config-file)
  `(,(or emacs "emacs")
    "-q" "--no-splash"			; -Q?
    ,@(if load-path `("-L" ,load-path) (list))
    "-l" "flserver-boot"
    "-l" "flserver-decl"
    ,@(if config-file `("-l" ,config-file) (list))
    "-l" "flserver-main"))

(define (config->config-file config)
  ;; TODO: handle in *.in
  (let1 config-file (build-path "/etc/font-lock/flserver" 
				(string-append config ".el"))
    (if (file-is-readable? config-file)
	config-file
	#f)))

(provide "font-lock/flserver")
