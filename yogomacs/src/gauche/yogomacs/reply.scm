(define-module yogomacs.reply
  (export reply
	  <asis-data>
	  <shtml-data>
	  )
  (use www.cgi)
  (use sxml.serializer)
  (use text.tree)
  (use srfi-19)
  (use yogomacs.rearranges.ysh-fragment))

(select-module yogomacs.reply)

(define-generic reply)

(define-method  reply ((obj <top>))
   (cgi-header :status "500 Internal server Error"))

(define-method  reply ((text-tree <list>))
  (write-tree text-tree))

(define-class <data> ()
  ((data :init-keyword :data)
   (params :init-keyword :params)
   (config :init-keyword :config)
   (last-modification-time :init-keyword :last-modification-time 
			   :init-value #f)
   (mime-type :init-keyword :mime-type)))

(define-class <asis-data> (<data>)
  ())

;; Sun, 06 Nov 1994 08:49:37 GMT  ; RFC 822, updated by RFC 1123
(define (rfc822 t)
  (date->string (time-utc->date (make-time 'time-utc 0 t))
		"~a, ~d ~b ~Y ~T ~z"))
		
(define-method  reply ((asis <asis-data>))
  (write-tree (apply cgi-header :content-type (ref asis 'mime-type)
		     (if (ref asis 'last-modification-time)
			 (list :last-modified  (rfc822 (ref asis 'last-modification-time)))
			 (list))))
  (display (ref asis 'data)))

(define-class <shtml-data> (<data>)
  ((mime-type :init-value "text/html")))

(define-method  reply-xhtml ((shtml <shtml-data>))
  (write-tree
   (list
    (apply cgi-header :content-type (ref shtml 'mime-type)
	   (if (ref shtml 'last-modification-time)
	       (list :last-modified  (rfc822 (ref shtml 'last-modification-time)))
	       (list)))
    (let1 data (ref shtml 'data)
      (let1 result (srl:sxml->xml-noindent  data)
	#;(with-output-to-file "/tmp/data"
	(pa$ write data))
	#;(with-output-to-file "/tmp/result"
	(pa$ write result))
	result)))))

(define-method  reply ((shtml <shtml-data>))
  (if (cgi-get-parameter "ysh" (ref shtml 'params)  :default #f)
      (let1 new (make <shtml-data>
		  :data (ysh-fragment (ref shtml 'data))
		  :params (ref shtml 'params)
		  :config (ref shtml 'config)
		  :last-modification-time (ref shtml 'last-modification-time)
		  :mime-type "text/xml")
	(reply-xhtml new))
      (reply-xhtml shtml)))

(provide "yogomacs/reply")
