(define-module yogomacs.rearranges.face-integrates
   (export face-integrates)
   (use yogomacs.dests.css)
   (use yogomacs.renderer)
   (use yogomacs.rearranges.css-integrates))

(select-module yogomacs.rearranges.face-integrates)

(define (link-face-css base-name style)
  `(link (|@|
	  (rel "stylesheet") 
	  (type "text/css")
	  (href ,(face->css-route base-name style css-route))
	  (title ,style))))

(define (href-for-faces? href faces)
  ((apply any-pred
	  (map (lambda (x) 
		 (string->regexp 
		  (string-append "/"
				 (symbol->string x)  
				 "--(?:Default|Invert)\.css$")))
	       faces))
   href))

(define (face-integrates sxml base-name faces)
  (css-integrates sxml
		  `("\n" "    "
		    ,(link-face-css base-name "Default")
		    "\n" "    "
		    ,(link-face-css base-name "Invert"))
		  (cute href-for-faces? <> faces)))

(provide "yogomacs/rearranges/face-integrates")