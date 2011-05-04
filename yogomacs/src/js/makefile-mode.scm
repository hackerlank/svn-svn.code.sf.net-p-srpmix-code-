(define-major-mode makefile
  :indicator "Makefile"
  :separators '(#\space #\tab #\$ #\( #\) #\+ #\= #\\
		#\? #\: #\;
		)
  :parent 'fundamental-mode
  )

		