(define-module yogomacs.dests.annotation
  (export annotation-dest
	  annotation-route
	  annotation-route$)
  (use www.cgi)  
  #;(use yogomacs.access)
  #;(use yogomacs.caches.annotation)
  #;(use srfi-1)
  (use file.util)
  )

(select-module yogomacs.dests.annotation)

(define annotation-route "/web/annotation")
(define (annotation-route$ elt)
   (build-path annotation-route elt))

#;(define payload
  '(annotation-container
    (annotation
     :version 0
     :target (file 215)
     :content (text
		  "ここでキューに入れる。トークンが回ってきて送信許可を得たときに送信できる(orf_token_mcast)。")
     :date "Mon Nov 16 01:18:35 2009"
     :full-name "Masatake YAMATO"
     :mailing-address "yamato@redhat.com"
     :keywords (reading-corosync))
    (annotation
     :version 0
     :target (file 205)
     :content (text
		  "ここでキューに入れる。トークンが回ってきて送信許可を得たときに送信できる(orf_token_mcast)。")
     :date "Mon Nov 16 01:18:35 2009"
     :full-name "Masatake YAMATO"
     :mailing-address "yamato@redhat.com"
     :keywords (reading-corosync))
    (annotation
     :version 0
     :target (file 195)
     :content (text
		  "ここでキューに入れる。トークンが回ってきて送信許可を得たときに送信できる(orf_token_mcast)。")
     :date "Mon Nov 16 01:18:35 2009"
     :full-name "Masatake YAMATO"
     :mailing-address "yamato@redhat.com"
     :keywords (reading-corosync))))
(define payload
  '(annotation-container
    (annotation
     :version 0
     :target (directory "..")
     :content (text "親ディレクトリへ行く。")
     :date "Mon Nov 16 01:18:35 2009"
     :full-name "Masatake YAMATO"
     :mailing-address "yamato@redhat.com"
     :keywords (reading-corosync))))

(define (annotation-dest path params config)
  (list (cgi-header :content-type "text/x-es")
	(with-output-to-string
	   (pa$ write payload))))

(provide "yogomacs/dests/annotation")