(define-module yogomacs.reel
  (export <reel>
#;	  params
#;	  config
	  spin-for-path
	  spin-of-author
	  spin-about-keywords
	  all-keywords
	  )
  )


(select-module yogomacs.reel)

(define-class <reel> ()
  (
   (params :init-keyword :params)
   (config :init-keyword :config)
   ))

#;(define-method params ((reel <reel>)
		       (name <string>))
  ((ref reel 'params) name))

#;(define-method config ((reel <reel>)
		       (name <symbol>))
  ((ref reel 'cnofig) name))
   

(define-method spin-for-path ((reel <reel>)
			      (path <string>))
  #f)

(define-method spin-of-author ((reel <reel>)
			       (author <string>))
  #f)

(define-method spin-about-keywords ((reel <reel>)
				    (keywords <list>))
  #f)

(define-method all-keywords ((reel <reel>))
  #f)


(provide "yogomacs/reel")