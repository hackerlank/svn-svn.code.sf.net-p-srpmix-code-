(define-module yogomacs.dests.text
  (export text-dest)
  (use yogomacs.reply)
  (use yogomacs.dentry)
  (use yogomacs.dentries.text)
  (use yogomacs.renderers.text)
  (use yogomacs.path)
  ;;
  (use yogomacs.dests.file)		;???? TODO
  ;;
  (use srfi-19)
  )

(select-module yogomacs.dests.text)

(define (text-dest dentry path params config)
  (let1 shtml (text (compose-path path) 
		    config
		    (text-of dentry)
		    (time-second (mtime-of dentry)))
    ;; TODO :     (prepare-file-faces config)
    (make <shtml-data>
      :params params
      :config config
      :data ((compose 
	      fix-css-href
	      integrate-file-face
	      ;; TODO: make url hyperlink
	      ;; TODO: text substitution
	      ) shtml)
      :last-modification-time #f)))

(provide "yogomacs/dests/text") 