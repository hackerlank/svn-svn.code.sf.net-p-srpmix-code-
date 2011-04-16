(define-module yogomacs.dests.ysh-dir
  (export ysh-dir-dest)
  (use yogomacs.reply)
  (use yogomacs.renderers.yogomacs)
  (use yogomacs.shell)
  (use yogomacs.shells.ysh)
  (use yogomacs.auth)
  (use yogomacs.path)
  (use yogomacs.tag)
  (use yogomacs.tags)
  )
(select-module yogomacs.dests.ysh-dir)

(define (ysh-dir-dest path params config)
  (if-let1 user+role (authorized? config)
	   (let* ((params ((params "user" (car user+role)) "role" (cadr user+role)))
		  (shtml (yogomacs (cdr path) params (shell-ref 'ysh)))
		  (real-src-path (apply make-real-src-path config path)))
	     (make <shtml-data>
	       :params params
	       :config config
	       :data ((compose values) shtml)
	       :last-modification-time #f
	       ;; TODO: This should be provided by yogomacs-frgment.
	       :has-tag? (has-tag? real-src-path params config)))
	   (unauthorized config)))


(provide "yogomacs/dests/ysh-dir")
