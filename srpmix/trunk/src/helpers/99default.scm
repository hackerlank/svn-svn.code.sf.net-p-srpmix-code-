;; specs file are seriously broken.
(#/kernel-2\.4\.18-e\.[1-6].*/ "--target=ia64")

;; ia64 and ppc64 should be built, However, with these
;; targets, created swrfs becomes too large.
(#/kernel-2\.6\.18.*/ "--target=x86_64,i686"  )

;; Including i686 makes too large rpm.
(#/kernel-2\.6\.3[0-9].*/ "--target=x86_64"  )
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
(#/am-utils-6.*/       dont-run-autotools-and-configure-and-bootstrap)
(#/openib-1.*/         dont-run-configure )
(#/openmpi.*/          dont-run-configure )
(#/opensm-.*/          dont-run-configure )

(#/amanda-2.5.*/       dont-run-autotools)
;; TEST
;; (#/SRPMIX-TEST/ "a" "b")

;; MOCK
(#/ibutils-1.2-3.el4.*/ "--mock=epel-4")
(#/ibutils-1.2-4.el4.*/ "--mock=epel-4")
(#/am-utils-6.0.9-15.el4_5.1.*/ "--mock=epel-4")
(#/am-utils-6.0.9-15.RHEL4.*/ "--mock=epel-4")
(#/am-utils-6.0.9-16.RHEL4.*/ "--mock=epel-4")
(#/bcel-5.1-15.1.ep5.el4.*/ "--mock=epel-4")
(#/dmraid-1.0.0.rc5f-rhel4.1.*/ "--mock=epel-4")
(#/findutils-4.1.20-7.el4.1.*/ "--mock=epel-4")
(#/findutils-4.1.20-7.el4.3.*/ "--mock=epel-4")
(#/ghostscript-7.07-33.11.el4.*/ "--mock=epel-4")
(#/ghostscript-7.07-33.2.el4_6.1.*/ "--mock=epel-4")
(#/ghostscript-7.07-33.2.el4_7.5.*/ "--mock=epel-4")
(#/ghostscript-7.07-33.2.el4_7.8.*/ "--mock=epel-4")
(#/gtk-engines-0.12-6.el4.*/ "--mock=epel-4")
(#/HelixPlayer-1.0.4-1.1.EL4.2.*/ "--mock=epel-4")
(#/HelixPlayer-1.0.5-0.EL4.1.*/ "--mock=epel-4")
(#/HelixPlayer-1.0.6-0.EL4.1.*/ "--mock=epel-4")
(#/HelixPlayer-1.0.6-0.EL4.2.0.2.*/ "--mock=epel-4")
(#/HelixPlayer-1.0.6-1.el4_8.1.*/ "--mock=epel-4")
(#/ibutils-1.2-3.el4.*/ "--mock=epel-4")
(#/ibutils-1.2-4.el4.*/ "--mock=epel-4")
(#/infiniband-diags-1.4.4-1.el4.*/ "--mock=epel-4")
(#/kdegraphics-3.3.1-10.el4.*/ "--mock=epel-4")
(#/kdegraphics-3.3.1-13.el4.*/ "--mock=epel-4")
(#/kdegraphics-3.3.1-15.el4_8.2.*/ "--mock=epel-4")
(#/kdegraphics-3.3.1-17.el4_8.1.*/ "--mock=epel-4")
(#/kdegraphics-3.3.1-4.RHEL4.*/ "--mock=epel-4")
(#/kdegraphics-3.3.1-6.el4_5.*/ "--mock=epel-4")
(#/kdegraphics-3.3.1-9.el4_6.*/ "--mock=epel-4")
(#/kdenetwork-3.3.1-4.el4.*/ "--mock=epel-4")
(#/libapreq2-2.09-8.el4sat.*/ "--mock=epel-4")
(#/libibverbs-1.0.rc4-0.4265.2.EL4.*/ "--mock=epel-4")
(#/libmthca-1.0.rc4-0.4265.2.EL4.*/ "--mock=epel-4")
(#/libsdp-0.90-0.4265.2.EL4.*/ "--mock=epel-4")
(#/libsdp-1.1.99-11.el4.*/ "--mock=epel-4")
(#/mvapich2-1.2-0.p1.4.el4.*/ "--mock=epel-4")
(#/mysqlclient10-3.23.58-4.RHEL4.1.*/ "--mock=epel-4")
(#/mysqlclient14-4.1.14-4.el4s1.2.*/ "--mock=epel-4")
(#/mysqlclient14-4.1.22-1.el4s1.1.*/ "--mock=epel-4")
(#/ncurses-5.4-15.el4.*/ "--mock=epel-4")
(#/openmpi11-1.1.5-1.el4_7.*/ "--mock=epel-4")
(#/openmpi11-1.1.5-7.el4.*/ "--mock=epel-4")
(#/openmpi-1.2.5-5.el4.*/ "--mock=epel-4")
(#/openmpi-1.2.7-2.el4_7.*/ "--mock=epel-4")
(#/openmpi-1.2.8-4.el4.*/ "--mock=epel-4")
(#/opensm-3.2.5-1.el4.*/ "--mock=epel-4")
(#/ppp-2.4.2-6.4.RHEL4.*/ "--mock=epel-4")
(#/qperf-0.4.2-1.el4.*/ "--mock=epel-4")
(#/tomcat6-6.0.18-8.18.ep5.el4.*/ "--mock=epel-4")
(#/unixODBC-2.2.11-1.RHEL4.1.*/ "--mock=epel-4")
(#/unixODBC-2.2.11-7.el4s1.1.*/ "--mock=epel-4")
(#/unixODBC-2.2.12-1.el4s1.1.*/ "--mock=epel-4")
(#/unixODBC-2.2.12-6.el4s1.1.*/ "--mock=epel-4")
(#/usermode-1.74-2.el4.1.*/ "--mock=epel-4")
(#/xcin-2.5.3.pre3-27.el4.*/ "--mock=epel-4")
