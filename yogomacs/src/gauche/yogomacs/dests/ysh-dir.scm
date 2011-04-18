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
  (let1 lpath (cdr lpath)
    (if-let1 user+role (authorized? config)
	     (let* ((params ((params "user" (car user+role)) "role" (cadr user+role)))
		    (shtml (yogomacs lpath params (shell-ref 'ysh)))
		    (real-src-path (apply make-real-src-path config lpath)))
	       (make <shtml-data>
		 :params params
		 :config config
		 :data ((compose values) shtml)
		 :last-modification-time #f
		 ))
	     (unauthorized config))))


(provide "yogomacs/dests/ysh-dir")
