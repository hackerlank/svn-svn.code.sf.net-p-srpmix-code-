(define-module yogomacs.dests.root-dir
  (export root-dir-dest)
  (use www.cgi) 
  (use file.util)
  ;;
  (use yogomacs.dentry)
  (use yogomacs.dentries.fs)
  (use yogomacs.renderers.dired)
  (use yogomacs.path)
  (use yogomacs.dests.css)
  (use yogomacs.dests.dir)
  ;;
  (use yogomacs.reply)
  )
(select-module yogomacs.dests.root-dir)

(define root-globs
  `(("."  #t "/")
    (".." #t "/")
    (#/^(?:packages|sources|dists)$/ #t ,(lambda (fs-dentry) 
					   (build-path "/"
						       (dname-of fs-dentry))))))

(define (root-dir-dest path params config)
  (let1 real-src-dir #?=(config 'real-sources-dir)
    (prepare-dired-faces config)
    (make <shtml-data>
      :params params
      :config config
      :data ((compose integrate-dired-face) (dired
					     (compose-path path)
					     (glob-dentries real-src-dir
							    root-globs)
					     css-route))
      :last-modification-time #f)))


(provide "yogomacs/dests/root-dir")