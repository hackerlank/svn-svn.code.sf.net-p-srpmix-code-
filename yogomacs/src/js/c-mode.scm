(define-major-mode c
  :indicator "C"
  :separators '(#\space #\tab
		#\! #\% #\% #\^ #\& #\* #\( #\) #\- #\+ #\= #\|
		#\> #\< #\. #\, #\/ #\? #\[ #\]  #\{ #\} #\~
		#\: #\; #\\
		)
  :parent 'fundamental-mode
  )

		