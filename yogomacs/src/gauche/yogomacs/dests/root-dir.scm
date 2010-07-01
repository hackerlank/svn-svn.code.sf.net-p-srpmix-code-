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
  (use yogomacs.fix)
  )
(select-module yogomacs.dests.root-dir)

(define root-globs
  `(("."  #t "/")
    (".." #t "/")
    (#/^(?:packages|sources|dists)$/ #t ,(lambda (fs-dentry) 
					   (build-path "/"
						       (dname-of fs-dentry))))))

(define (root-dir-dest path params config)
  (prepare-dired-faces config)
  (list
   (cgi-header)
   (fix
    (dired (compose-path path)
	   (glob-dentries (config 'real-sources-dir) root-globs)
	   css-route))))

(provide "yogomacs/dests/root-dir")