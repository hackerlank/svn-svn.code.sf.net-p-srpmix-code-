(define-module yogomacs.reply
  (export reply
	  <asis-data>
	  <shtml-data>
	  <empty-data>
	  <checkout-data>
	  <redirect-data>
	  <lazy-data>
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
  (use yogomacs.util.sxml)
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
	     :init-keyword :has-tag?
	     :client `(has-tag? ,boolean)
	     )))



(define-class <empty-data> ()
  ())

(define-class <asis-data> (<data>)
  ())

(define-class <redirect-data> (<data>)
  ((location :init-keyword :location)))

(define-method reply ((empty <empty-data>))
  (write-tree (cgi-header :status "204 No Content")))

(define-method reply ((redirect <redirect-data>))
  (write-tree (cgi-header :status "302 Moved Temporarily"
			  :location (ref redirect 'location))))

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


(define smart-phones '(
		       ;; doesn't have real keyboard.
		       #/HTCX06HT/
		       #/HTC Magic/
		       #/GT-P1000/
		       #/iPhone OS 4/
		       ;; has real keyboard....
		       #/Android Dev Phone 1/
		       #/IS01 Build\/S8040/
		       ))

(define-class <shtml-data> (<data>)
  ((mime-type :init-value "text/html")
   (client-enviroment :init-value `((params :role-name "role" ,values)
				    (env :user-agent "HTTP_USER_AGENT" ,values)
				    (env :smart-phone? "HTTP_USER_AGENT"
					 ,(lambda (user-agent)
					    (and user-agent
						 (boolean (any (cute <> user-agent) 
							       smart-phones)))))
				    (params :user-name "user" ,(lambda (val)
								 (if val
								     (ref val 'name)
								     #f)))
				    (params :user-real-name "user" ,(lambda (val)
								      (if val
									  (ref val 'real-name)
									  #f)))
				    (meta :major-mode "major-mode" ,values)
				    )
		      :allocation :class
		      )))

(define-class <lazy-data> (<shtml-data>)
  ((shell :init-keyword :shell 
	  :client #t)
   (next-path :init-keyword :next-path
	      :client #t)
   (next-range :init-keyword :next-range
	       :init-value #f
	       :client #t)
   (next-enum :init-keyword :next-enum
	       :init-value #f 
	       :client #t)
   ))


(define-method make-client-environment ((shtml <shtml-data>))
  (define (gather-client-slots shtml)
    (fold (lambda (slot kdr) 
	    (if-let1 client? (slot-definition-option slot :client #f)
		     (cons (list 'slot
				 (make-keyword (symbol->string (if (eq? client? #t)
								   (car slot)
								   (car client?))))
				 (car slot)
				 (if (eq? client? #t)
				     values
				     (cadr client?)))
			   kdr)
		     kdr))
	  (list)
	  (class-slots (class-of shtml))))
  (define (type-handler-for type)
    (case type
      ('slot ref)
      ('params (lambda (shtml key) ((ref shtml 'params) key)))
      ('env (lambda (shtml key) (assoc-ref (sys-environ->alist) key)))
      ('meta (lambda (shtml key) (get-meta-from-shtml (ref shtml 'data) key #f)))
      ))
  (append-map (apply$
	       (lambda (type client-var slot-name value-converter)
		 (list client-var
		       (value-converter
			((type-handler-for type)
			 shtml
			 slot-name)))))
	      (append (gather-client-slots shtml)
		      (ref shtml 'client-enviroment))))

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
		     (cute inject-environment <> shell-name (make-client-environment shtml))
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
