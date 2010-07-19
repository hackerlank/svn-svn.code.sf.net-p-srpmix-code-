(define-module yogomacs.reply
  (export reply
	  <asis-data>
	  )
  (use www.cgi)
  (use text.tree))

(select-module yogomacs.reply)

(define-generic reply)

(define-method  reply ((obj <top>))
  (cgi-header :status "500 Internal server Error"))
(define-method  reply ((text-tree <list>))
  (write-tree text-tree))

(define-class <asis-data> ()
  ((mime-type :init-keyword :mime-type)
   (data :init-keyword :data)))

(define-method  reply ((asis <asis-data>))
  (write-tree (cgi-header :content-type (ref asis 'mime-type)))
  (display (ref asis 'data)))

(provide "yogomacs/reply")
