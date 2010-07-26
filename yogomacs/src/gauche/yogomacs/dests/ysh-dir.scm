(define-module yogomacs.dests.ysh-dir
  (export ysh-dir-dest)
  (use yogomacs.reply)
  (use yogomacs.renderers.yogomacs)
  (use yogomacs.dests.file)
  (use yogomacs.dests.dir))
(select-module yogomacs.dests.ysh-dir)


(define (ysh-dir-dest path params config)
  (let1 shtml (yogomacs (cdr path) params "ysh" " <ysh")
    (make <shtml-data>
      :params params
      :config config
      :data ((compose fix-css-href
		      integrate-file-face
		      integrate-dired-face) shtml)
      :last-modification-time #f)))

(provide "yogomacs/dests/ysh-dir")
