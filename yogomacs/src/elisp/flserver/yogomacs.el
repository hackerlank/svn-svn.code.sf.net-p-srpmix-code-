(setq shtmlize-predefined-face-css-func (lambda (title)
					  `("    " (link (|@| (rel "stylesheet")
							      (type "text/css")
							      (href ,(format "%s/file-font-lock--%s.css"
									     xhtmlize-external-css-base-url
									     title))
							      (title ,title)))
					    "\n")))

(setq xhtmlize-external-css-predefined-faces 
      '(
	 default 
	 font-lock-comment-delimiter-face
	 font-lock-comment-face
	 font-lock-constant-face
	 font-lock-doc-face
	 font-lock-function-name-face
	 font-lock-keyword-face
	 font-lock-negation-char-face
	 font-lock-preprocessor-face
	 font-lock-string-face
	 font-lock-type-face
	 font-lock-variable-name-face
	 highlight
	 lfringe
	 linum
	 rfringe
	 ))

