(define-module yogomacs.reply
  (export reply
	  <asis-data>
	  <shtml-data>
	  )
  (use www.cgi)
  (use sxml.serializer)
  (use text.tree)
  (use srfi-19))

(select-module yogomacs.reply)

(define-generic reply)

(define-method  reply ((obj <top>))
  (cgi-header :status "500 Internal server Error"))
(define-method  reply ((text-tree <list>))
  (write-tree text-tree))

(define-class <data> ()
  ((data :init-keyword :data)
   (last-modification-time :init-keyword :last-modification-time 
			   :init-value #f)
   (mime-type :init-keyword :mime-type)))

(define-class <asis-data> (<data>)
  ())

(define-method  reply ((asis <asis-data>))
  (write-tree (cgi-header :content-type (ref asis 'mime-type)))
  (display (ref asis 'data)))

(define-class <shtml-data>(<data>)
  ;; TODO: xml?
  ((mime-type :init-value "text/html")))

(define-method  reply ((shtml <shtml-data>))
  (write-tree
   (list
    (cgi-header :content-type (ref asis 'mime-type))
    (srl:sxml->xml-noindent  (ref shtml 'data)))))

(provide "yogomacs/reply")
