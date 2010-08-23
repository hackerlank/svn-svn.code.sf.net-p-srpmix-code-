(define-module yogomacs.dests.annotations-dir
  (export annotations-dir-dest)
  (use yogomacs.path)
  (use yogomacs.route)
  (use yogomacs.renderers.dired)
  (use yogomacs.dests.css)
  (use yogomacs.dests.dir)
  (use yogomacs.reply)
  
  (use yogomacs.dentry)
  (use yogomacs.dentries.text)
  (use yogomacs.yarn)
  )

(select-module yogomacs.dests.annotations-dir)


(define (dest lpath params config)
  (let1 shtml (dired
	       (compose-path lpath)
	       (map
		(lambda (keyword)
		  (make <text-dentry>
		    :parent (compose-path lpath)
		    :dname (symbol->string keyword)
		    :text "XXX")
		  )
		(all-keywords params config))
	       css-route)
    (prepare-dired-faces config)
    (make <shtml-data>
      :params params
      :config config
      :data ((compose integrate-dired-face) shtml)
      :last-modification-time #f)))

(define (routing-table path params)
  `((#/^\/annotations$/ ,dest)))

(define (annotations-dir-dest lpath params config)
  (route (routing-table lpath params) (compose-path lpath) params config)
  )


(provide "yogomacs/dests/annotations-dir")