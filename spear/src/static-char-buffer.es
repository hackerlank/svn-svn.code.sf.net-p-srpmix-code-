;; -*- scheme -*-
(spear-def static-char-buffer
	   "Lines statically defined char tyepd buffer"
	   :acceptable-package-pattern ".*"
	   :find-name "*.[ch]"
	   :grep-pattern "char[^)]\+\[[0-9]\+\]"
	   )
