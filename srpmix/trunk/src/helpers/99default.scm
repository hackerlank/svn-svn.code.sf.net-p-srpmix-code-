;; specs file are seriously broken.
(#/kernel-2\.4\.18-e\.[1-6].*/ "--target=ia64")

;; ia64 and ppc64 should be built, However, with these
;; targets, created swrfs becomes too large.
(#/kernel-2\.6\.18.*/ "--target=x86_64,i686"  )

;;
(#/kernel-2\.4\.9.*/  "--target=i686" )

;;
(#/yaboot-/ "--target=ppc")


