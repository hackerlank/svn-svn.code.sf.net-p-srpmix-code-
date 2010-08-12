(define-module yogomacs.dests.bscm-dir
  (export bscm-dir-dest)
  (use yogomacs.reply)
  (use yogomacs.renderers.yogomacs)
  (use yogomacs.shell)
  (use yogomacs.shells.bscm)
  )
(select-module yogomacs.dests.bscm-dir)


(define (id x) x)
(define (bscm-dir-dest path params config)
  (let1 shtml (yogomacs (cdr path) params (shell-ref 'bscm))
    (make <shtml-data>
      :params params
      :config config
      :data ((compose id) shtml)
      :last-modification-time #f)))

(provide "yogomacs/dests/bscm-dir")