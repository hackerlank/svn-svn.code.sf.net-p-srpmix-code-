(define-module yogomacs.dests.stitch
  (export stitch-dest
	  stitch-route
	  stitch-route$)
  (use www.cgi)  
  #;(use yogomacs.access)
  #;(use yogomacs.caches.stitch)
  #;(use srfi-1)
  (use file.util)
  )

(select-module yogomacs.dests.stitch)

(define stitch-route "/web/stitch")
(define (stitch-route$ elt)
   (build-path stitch-route elt))

#;(define payload
  '(stitch-container
    (annotation
     :version 0
     :target (file 215)
     :annotation (text
		  "ここでキューに入れる。トークンが回ってきて送信許可を得たときに送信できる(orf_token_mcast)。")
     :date "Mon Nov 16 01:18:35 2009"
     :full-name "Masatake YAMATO"
     :mailing-address "yamato@redhat.com"
     :keywords (reading-corosync))
    (annotation
     :version 0
     :target (file 205)
     :annotation (text
		  "ここでキューに入れる。トークンが回ってきて送信許可を得たときに送信できる(orf_token_mcast)。")
     :date "Mon Nov 16 01:18:35 2009"
     :full-name "Masatake YAMATO"
     :mailing-address "yamato@redhat.com"
     :keywords (reading-corosync))
    (annotation
     :version 0
     :target (file 195)
     :annotation (text
		  "ここでキューに入れる。トークンが回ってきて送信許可を得たときに送信できる(orf_token_mcast)。")
     :date "Mon Nov 16 01:18:35 2009"
     :full-name "Masatake YAMATO"
     :mailing-address "yamato@redhat.com"
     :keywords (reading-corosync))))
(define payload
  '(stitch-container
    (annotation
     :version 0
     :target (directory "..")
     :annotation (text "親ディレクトリへ行く。")
     :date "Mon Nov 16 01:18:35 2009"
     :full-name "Masatake YAMATO"
     :mailing-address "yamato@redhat.com"
     :keywords (reading-corosync))))

(define (stitch-dest path params config)
  (list (cgi-header :content-type "text/x-es")
	(with-output-to-string
	   (pa$ write payload))))

(provide "yogomacs/dests/stitch")