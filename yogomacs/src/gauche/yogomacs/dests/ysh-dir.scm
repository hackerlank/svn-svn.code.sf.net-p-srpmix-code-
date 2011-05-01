(define-module yogomacs.dests.ysh-dir
  (export ysh-dir-dest)
  (use yogomacs.reply)
  (use yogomacs.renderers.yogomacs)
  (use yogomacs.shell)
  (use yogomacs.shells.ysh)
  (use yogomacs.auth)
  (use yogomacs.path)
  )
(select-module yogomacs.dests.ysh-dir)

(define (ysh-dir-dest lpath params config)
  (if-let1 user+role (maybe-login params config)
	   (let ((params ((params "user" (car user+role)) "role" (cadr user+role)))
		 (next-path (compose-path (cdr lpath))))
	     (make <lazy-data>
	       :params params
	       :config config
	       :data (yogomacs next-path params (shell-ref 'ysh))
	       :last-modification-time #f
	       :shell 'ysh
	       :next-path next-path
	       :next-range (params "range")
	       :next-enum (params "enum")
	       ))
	   (unauthorized config)))


(provide "yogomacs/dests/ysh-dir")
