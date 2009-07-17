;; specs file are seriously broken.
(#/kernel-2\.4\.18-e\.[1-6].*/ "--target=ia64")

;; ia64 and ppc64 should be built, However, with these
;; targets, created swrfs becomes too large.
(#/kernel-2\.6\.18.*/ "--target=x86_64,i686"  )

;;
(#/kernel-2\.4\.9.*/  "--target=i686" )

;;
(#/yaboot-.*/ "--target=ppc")

;;
(#/s390utils-1\.5\.3-17\.el5/ "--target=s390x --keep-original")
(#/s390utils-.*/ "--target=s390")

;;
(#/dmraid-.*RHEL4.*/ "--target=i686")
(#/dmraid-.*/ "--keep-original")

(#/util-linux-2\.13-0\.44\.el5/ "--rearrange-spec-command={ echo \"%define rhel 1\";cat; }")

;; Avoids to run autoreconf.
(#/pam-0.99.6.*/ "--rearrange-spec-command={ sed -e \"s/^autoreconf//\"; }")

;; Don't run gcc_update --touch
(#/gcc-.*/ "--rearrange-spec-command={ sed -e \'s/^.*gcc_update --touch.*$//\'; }")

;; TEST
;; (#/SRPMIX-TEST/ "a" "b")

