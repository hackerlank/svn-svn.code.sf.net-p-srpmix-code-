(define-module yogomacs.dests.yarn
  (export yarn-dest
	  yarn-route
	  yarn-route$
	  yarn-for)
  (use www.cgi)  
  #;(use yogomacs.access)
  #;(use yogomacs.caches.yarn)
  #;(use srfi-1)
  (use file.util)
  (use yogomacs.yarn)
  (use yogomacs.path)
  )

(select-module yogomacs.dests.yarn)

(define yarn-route "/web/yarn")
(define (yarn-route$ elt)
   (build-path yarn-route elt))

#;(define payload
  '(yarn-container
    (yarn
     :version 0
     :target (file 215)
     :content (text
		  "ここでキューに入れる。トークンが回ってきて送信許可を得たときに送信できる(orf_token_mcast)。")
     :date "Mon Nov 16 01:18:35 2009"
     :full-name "Masatake YAMATO"
     :mailing-address "yamato@redhat.com"
     :keywords (reading-corosync))
    (yarn
     :version 0
     :target (file 205)
     :content (text
		  "ここでキューに入れる。トークンが回ってきて送信許可を得たときに送信できる(orf_token_mcast)。")
     :date "Mon Nov 16 01:18:35 2009"
     :full-name "Masatake YAMATO"
     :mailing-address "yamato@redhat.com"
     :keywords (reading-corosync))
    (yarn
     :version 0
     :target (file 195)
     :content (text
		  "ここでキューに入れる。トークンが回ってきて送信許可を得たときに送信できる(orf_token_mcast)。")
     :date "Mon Nov 16 01:18:35 2009"
     :full-name "Masatake YAMATO"
     :mailing-address "yamato@redhat.com"
     :keywords (reading-corosync))))
(define payload
  '(yarn-container
    (yarn
     :version 0
     :target (directory "..")
     :content (text "親ディレクトリへ行く。")
     :date "Mon Nov 16 01:18:35 2009"
     :full-name "Masatake YAMATO"
     :mailing-address "yamato@redhat.com"
     :keywords (reading-corosync))))

(define (yarn-dest path params config)
  (list (cgi-header :content-type "text/x-es")
	(with-output-to-string
	  (pa$ yarn-for (compose-path path) params config)
	  )))

(provide "yogomacs/dests/yarn")