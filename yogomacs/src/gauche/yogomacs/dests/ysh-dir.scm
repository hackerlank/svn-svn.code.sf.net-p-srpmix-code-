(define-module yogomacs.dests.ysh-dir
  (export ysh-dir-dest)
  (use yogomacs.reply)
  (use yogomacs.renderers.yogomacs)
  (use yogomacs.shell)
  (use yogomacs.shells.ysh)
  (use yogomacs.auth)
  )
(select-module yogomacs.dests.ysh-dir)

(define (id x) x)
(define (ysh-dir-dest path params config)
  (if (authorized?)
      (let1 shtml (yogomacs (cdr path) params (shell-ref 'ysh))
	(make <shtml-data>
	  :params params
	  :config config
	  :data ((compose id) shtml)
	  :last-modification-time #f))
      (unauthorized config)))

(provide "yogomacs/dests/ysh-dir")
