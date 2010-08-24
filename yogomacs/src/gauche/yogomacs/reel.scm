(define-module yogomacs.reel
  (export <reel>
#;	  params
#;	  config
	  spin-for-path
	  spin-of-author
	  spin-about-subjects
	  all-subjects
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

(define-method spin-about-subjects ((reel <reel>)
				    (subjects <list>))
  #f)

(define-method all-subjects ((reel <reel>))
  #f)


(provide "yogomacs/reel")