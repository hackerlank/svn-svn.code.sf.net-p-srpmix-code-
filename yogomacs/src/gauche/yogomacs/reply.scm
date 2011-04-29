(define-module yogomacs.reply
  (export reply
	  <asis-data>
	  <shtml-data>
	  <empty-data>
	  <checkout-data>
	  )
  (use www.cgi)
  (use sxml.serializer)
  (use text.tree)
  (use srfi-19)
  (use yogomacs.util.range)
  (use yogomacs.rearranges.range)
  (use yogomacs.util.enum)
  (use yogomacs.rearranges.enum)
  (use yogomacs.rearranges.yogomacs-fragment)
  (use yogomacs.rearranges.eof-line)
  (use yogomacs.rearranges.inject-environment)
  (use yogomacs.shell)
  (use yogomacs.error)
  ;;
  (use text.html-lite)
  (use srfi-1)
  (use util.list)
  )

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
   (mime-type :init-keyword :mime-type)
   (has-tag? :init-value #f 
	     :init-keyword :has-tag?)))



(define-class <empty-data> ()
  ())
(define-method reply ((empty <empty-data>))
  (write-tree (cgi-header :status "204 No Content")))

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
  ((mime-type :init-value "text/html")
   (client-enviroment :init-value `((slot :has-tag? has-tag? ,boolean)
				    (params :role-name "role" ,values)
				    (env :user-agent "HTTP_USER_AGENT" ,values)
				    (env :smart-phone? "HTTP_USER_AGENT"
					 ,(lambda (user-agent)
					    (boolean (any (cute <> user-agent) 
							  '(
							    ;; doesn't have real keyboard.
							    #/HTCX06HT/
							    #/HTC Magic/
							    #/GT-P1000/
							    #/iPhone OS 4/
							    ;; has real keyboard....
							    #/Android Dev Phone 1/
							    #/IS01 Build\/S8040/
							    )))))
				    (params :user-name "user" ,(lambda (val)
								 (if val
								     (ref val 'name)
								     #f)))
				    (params :user-real-name "user" ,(lambda (val)
								      (if val
									  (ref val 'real-name)
									  #f)))
				    )
		      :allocation :class)
   ))


(define (make-client-environment shtml)
  (define (type-handler-for type)
    (case type
      ('slot ref)
      ('params (lambda (shtml key) ((ref shtml 'params) key)))
      ('env (lambda (shtml key) (assoc-ref (sys-environ->alist) key)))
      ))
  (append-map (apply$
	       (lambda (type client-var slot-name value-converter)
		 (list client-var
		       (value-converter
			((type-handler-for type)
			 shtml
			 slot-name)))))
	      (ref shtml 'client-enviroment)))

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

;; TODO: THIS SHOULD NOT BE HERE. THIS SHOULE BE AT REARRANGES.
(define (make-narrow-down params)
  (or (and-let* ((range-string (params "range"))
		 (range (guard (e (else #f)) 
			  (parse-range range-string))))
	(cute rearrange-range <> range))
      (and-let* ((enum-string (params "enum"))
		 (enum (guard (e (else #f)) 
			 (parse-enum enum-string))))
	(cute rearrange-enum <> enum))
      (lambda (shtml) shtml)))

(define-method  reply ((shtml <shtml-data>))
  (let* ((params (ref shtml 'params))
	 (config (ref shtml 'config))
	 (narrow-down (make-narrow-down params))
	 (shell-name (in-shell? params))
	 (rearrange (compose
		     (if shell-name
			 (cute yogomacs-fragment <> shell-name) 
			 values)
		     (cute inject-environment <> (make-client-environment shtml))
		     narrow-down
		     eof-line))
	 (mime-type (if shell-name 
			"text/xml"
			(ref shtml 'mime-type))))
    (reply-xhtml (make <shtml-data>
		   :data (rearrange (ref shtml 'data))
		   :params params
		   :config config
		   :last-modification-time (ref shtml 'last-modification-time)
		   :mime-type mime-type))))

(define-class <checkout-data> (<data>)
  ((filename :init-keyword :filename)
  ))

(define-method reply ((checkout <checkout-data>))
  (write-tree (apply cgi-header 
		     :content-type (ref checkout 'mime-type)
		     :content-disposition #`"attachment; filename=\",(ref checkout 'filename)\""
		     (if (ref checkout 'last-modification-time)
			 (list :last-modified  (rfc822 (ref checkout 'last-modification-time)))
			 (list))))
  ((ref checkout 'data)))

(define-method reply ((e <yogomacs-error>))
  (reply (list
	  (cgi-header :status (condition-ref e 'status))
	  (html-doctype)
	  (html:html
	   (html:head (html:title "Error"))
	   (html:body (html:pre (html-escape-string (slot-ref e 'message))))))))

(define-method reply ((e <error>))
  (reply (list
	  (cgi-header :status "502 Bad Gateway"))))

(define-method reply ((e <condition>))
  (reply (list
	  (cgi-header :status "500 Internal Server Error"))))

(provide "yogomacs/reply")
