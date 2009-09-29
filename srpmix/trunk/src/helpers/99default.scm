;; specs file are seriously broken.
(#/kernel-2\.4\.18-e\.[1-6].*/ "--target=ia64")

;; ia64 and ppc64 should be built, However, with these
;; targets, created swrfs becomes too large.
(#/kernel-2\.6\.18.*/ "--target=x86_64,i686"  )

;;
(#/kernel-2\.4\.9.*/  "--target=i686" )
(#/kernel-2\.4\.21.*/ "--target=i686")

;;
(#/yaboot-.*/ "--target=ppc")

;;
(#/s390utils-1\.5\.3-17\.el5/ "--target=s390x" "--keep-original")
(#/s390utils-.*/ "--target=s390")

;;
(#/dmraid-.*RHEL4.*/ "--target=i686")
(#/dmraid-.*/ "--keep-original")

(#/util-linux-2\.13-0\.44\.el5/ "--rearrange-spec-command={ echo \"%define rhel 1\";cat; }")

;; Avoids to run autoreconf.
(#/pam-0.99.6.*/     "--rearrange-spec-command={ sed -e \"s/^autoreconf//\"; }")
(#/shadow-utils-.*/  "--rearrange-spec-command={ sed -e \"s/^libtoolize -f$\\|^aclocal$\\|^autoheader$\\|^automake -a$\\|^autoconf$//\"; }")
(#/mysql-.*/         dont-run-autotools)
(#/mysqlclient.*/   "--rearrange-spec-command={ sed -e \"s/^libtoolize --force$\\|^aclocal$\\|^autoheader$\\|^automake$\\|^autoconf$//\"; }")


;; Don't run gcc_update --touch
(#/gcc-.*/ "--rearrange-spec-command={ sed -e \'s/^.*gcc_update --touch.*$//\'; }")


;; libtool/config.* are now at libtool/config/config.*.
(#/openldap.*/ "--rearrange-spec-command={ sed -e \'s|cp %{_datadir}/libtool/config\.{sub,guess} build/||\'; }"
	       "--keep-original")
(#/nss_ldap-.*/ "--rearrange-spec-command={ sed -e \'s#cp -f /usr/share/libtool/config\.{guess,sub} \.##\' -e \'s/^aclocal$\\|^automake$\\|^autoheader$\\|^autoconf$//\' -e \'s#cp %{_datadir}/libtool/config.{sub,guess} nss_ldap-%{version}/##\' -e\'s#cp %{_datadir}/libtool/config.{sub,guess} pam_ldap-%{pam_ldap_version}/##\' ; }")
(#/star-.*/     "--rearrange-spec-command={ sed -e \'s|cp -f /usr/share/libtool/config\.sub conf/config\.sub||\'; }")

;; TEST
(#/ghostscript-.*/     "--keep-original")
(#/net-snmp-5.1.2-1.*/ "--keep-original")
(#/pciutils-2.1.8-.*/ "--rearrange-spec-command={ sed -e \'s/^make OPT=\"$RPM_OPT_FLAGS\"$//\'; }")
(#/gnupg-.*/          dont-run-autotools)
(#/findutils-.*/      dont-run-autotools)

(#/ibutils-1.*/        dont-run-configure)
(#/clumanager-1.0.*/   "--rearrange-spec-command={ sed -e \'s#^\./autogen\.sh$\\|^\./configure$##\'; }")
(#/am-utils-6.*/       dont-run-autotools-and-configure)
(#/openib-1.*/         dont-run-configure )
(#/openmpi.*/          dont-run-configure )
(#/opensm-.*/          dont-run-configure )

;; TEST
;; (#/SRPMIX-TEST/ "a" "b")

