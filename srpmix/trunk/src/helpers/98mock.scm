;; for v in 4 5; do for x in rhel$v*/packages/*/*; do ls -l $x/specs.spec>/dev/null 2>&1 || echo "(#/"$(basename $x)-$(basename $(readlink $x))"/ \"--mock=epel-$v\")"; done; done >~/BROKEN

(#/amanda-2.5.0p2-4/ "--mock=epel-5")
(#/amanda-2.5.0p2-8.el5/ "--mock=epel-5")
(#/amanda-2.5.0p2-8.el5.*/ "--mock=epel-5")
(#/am-utils-6.0.9-10/ "--mock=epel-4")
(#/am-utils-6.0.9-15.el4_5.1.*/ "--mock=epel-4")
(#/am-utils-6.0.9-15.RHEL4.*/ "--mock=epel-4")
(#/am-utils-6.0.9-16.RHEL4.*/ "--mock=epel-4")
(#/anthy-7900-4.el5/ "--mock=epel-5")
(#/anthy-7900-4.el5.*/ "--mock=epel-5")
(#/aspell-es-0.50-10/ "--mock=epel-4")
(#/aspell-es-0.50-13.2.2/ "--mock=epel-5")
(#/aspell-no-0.50.1-7/ "--mock=epel-4")
(#/aspell-no-0.50.1-9.2.2/ "--mock=epel-5")
(#/aspell-pt-0.50-10.2.2/ "--mock=epel-5")
(#/aspell-pt-0.50-8/ "--mock=epel-4")
(#/bcel-5.1-15.1.ep5.el4.*/ "--mock=epel-4")
;(#/comps-4AS-0.20051001/ "--mock=epel-4")
;(#/comps-4DESKTOP-0.20050107/ "--mock=epel-4")
;(#/comps-4Desktop-0.20070421/ "--mock=epel-4")
;(#/comps-4ES-0.20050525/ "--mock=epel-4")
;(#/comps-4ES-0.20060803/ "--mock=epel-4")
;(#/comps-4ES-0.20071108/ "--mock=epel-4")
;(#/comps-4WS-0.20060303/ "--mock=epel-4")
;(#/comps-4WS-0.20080711/ "--mock=epel-4")
;(#/comps-4WS-0.20090504/ "--mock=epel-4")
(#/dmraid-1.0.0.rc5f-rhel4.1/ "--mock=epel-4")
(#/dmraid-1.0.0.rc5f-rhel4.1.*/ "--mock=epel-4")
(#/eclipse-3.2.1-18.el5/ "--mock=epel-5")
(#/eclipse-3.2.1-18.el5.*/ "--mock=epel-5")
(#/eclipse-3.2.1-19.el5/ "--mock=epel-5")
(#/eclipse-3.2.1-19.el5.*/ "--mock=epel-5")
(#/etherboot-5.4.4-10.el5/ "--mock=epel-5")
(#/etherboot-5.4.4-10.el5.*/ "--mock=epel-5")
(#/findutils-4.1.20-7.el4.1.*/ "--mock=epel-4")
(#/findutils-4.1.20-7.el4.3.*/ "--mock=epel-4")
(#/findutils-4.1.20-7/ "--mock=epel-4")
(#/frysk-0.0.1.2007.06.21.rh2-4.el5/ "--mock=epel-5")
(#/frysk-0.0.1.2007.06.21.rh2-4.el5.*/ "--mock=epel-5")
(#/ghostscript-7.07-33.11.el4/ "--mock=epel-4")
(#/ghostscript-7.07-33.11.el4.*/ "--mock=epel-4")
(#/ghostscript-7.07-33.2.el4_6.1/ "--mock=epel-4")
(#/ghostscript-7.07-33.2.el4_6.1.*/ "--mock=epel-4")
(#/ghostscript-7.07-33.2.el4_7.5.*/ "--mock=epel-4")
(#/ghostscript-7.07-33.2.el4_7.8.*/ "--mock=epel-4")
(#/ghostscript-7.07-33/ "--mock=epel-4")
(#/gmp-4.1.4-10.el5/ "--mock=epel-5")
(#/gmp-4.1.4-10.el5.*/ "--mock=epel-5")
(#/gmp-4.1.4-3/ "--mock=epel-4")
(#/gnome-bluetooth-0.7.0-10.2.el5/ "--mock=epel-5")
(#/gnome-bluetooth-0.7.0-10.2.el5.*/ "--mock=epel-5")
(#/gnome-panel-2.16.1-6.el5/ "--mock=epel-5")
(#/gnome-panel-2.16.1-6.el5.*/ "--mock=epel-5")
(#/gstreamer-0.8.7-4.EL.0/ "--mock=epel-4")
(#/gtk+-1.2.10-33/ "--mock=epel-4")
(#/gtk+-1.2.10-36/ "--mock=epel-4")
(#/gtk-engines-0.12-5/ "--mock=epel-4")
(#/gtk-engines-0.12-6.el4/ "--mock=epel-4")
(#/gtk-engines-0.12-6.el4.*/ "--mock=epel-4")
(#/HelixPlayer-1.0.1.gold-8EL/ "--mock=epel-4")
(#/HelixPlayer-1.0.4-1.1.EL4.2/ "--mock=epel-4")
(#/HelixPlayer-1.0.4-1.1.EL4.2.*/ "--mock=epel-4")
(#/HelixPlayer-1.0.5-0.EL4.1.*/ "--mock=epel-4")
(#/HelixPlayer-1.0.6-0.EL4.1/ "--mock=epel-4")
(#/HelixPlayer-1.0.6-0.EL4.1.*/ "--mock=epel-4")
(#/HelixPlayer-1.0.6-0.EL4.2.0.2/ "--mock=epel-4")
(#/HelixPlayer-1.0.6-0.EL4.2.0.2.*/ "--mock=epel-4")
(#/HelixPlayer-1.0.6-1.el4_8.1.*/ "--mock=epel-4")
(#/ibutils-1.0-3.el5/ "--mock=epel-5")
(#/ibutils-1.0-3.el5.*/ "--mock=epel-5")
(#/ibutils-1.0-4/ "--mock=epel-4")
(#/ibutils-1.2-10.el5/ "--mock=epel-5")
(#/ibutils-1.2-10.el5.*/ "--mock=epel-5")
(#/ibutils-1.2-1/ "--mock=epel-4")
(#/ibutils-1.2-2.el5/ "--mock=epel-5")
(#/ibutils-1.2-2.el5.*/ "--mock=epel-5")
(#/ibutils-1.2-3.el4.*/ "--mock=epel-4")
(#/ibutils-1.2-3.el5/ "--mock=epel-5")
(#/ibutils-1.2-3.el5.*/ "--mock=epel-5")
(#/ibutils-1.2-4.el4.*/ "--mock=epel-4")
(#/ibutils-1.2-9.el5/ "--mock=epel-5")
(#/ibutils-1.2-9.el5.*/ "--mock=epel-5")
(#/infiniband-diags-1.4.4-1.el4/ "--mock=epel-4")
(#/infiniband-diags-1.4.4-1.el4.*/ "--mock=epel-4")
(#/inn-2.3.5-12/ "--mock=epel-4")
(#/iscsi-initiator-utils-6.2.0.871-0.12.el5_4.1.*/ "--mock=epel-5")
(#/java-1.6.0-ibm-1.6.0.4-1jpp.1.el5.*/ "--mock=epel-5")
(#/jboss-microcontainer-1.0.2-4.1.el5.*/ "--mock=epel-5")
(#/kdeadmin-3.3.1-2/ "--mock=epel-4")
(#/kdegraphics-3.3.1-10.el4/ "--mock=epel-4")
(#/kdegraphics-3.3.1-10.el4.*/ "--mock=epel-4")
(#/kdegraphics-3.3.1-13.el4/ "--mock=epel-4")
(#/kdegraphics-3.3.1-13.el4.*/ "--mock=epel-4")
(#/kdegraphics-3.3.1-15.el4_8.2.*/ "--mock=epel-4")
(#/kdegraphics-3.3.1-17.el4_8.1.*/ "--mock=epel-4")
(#/kdegraphics-3.3.1-2/ "--mock=epel-4")
(#/kdegraphics-3.3.1-3.3/ "--mock=epel-4")
(#/kdegraphics-3.3.1-3.4/ "--mock=epel-4")
(#/kdegraphics-3.3.1-3.7/ "--mock=epel-4")
(#/kdegraphics-3.3.1-3.9/ "--mock=epel-4")
(#/kdegraphics-3.3.1-4.RHEL4/ "--mock=epel-4")
(#/kdegraphics-3.3.1-4.RHEL4.*/ "--mock=epel-4")
(#/kdegraphics-3.3.1-6.el4_5.*/ "--mock=epel-4")
(#/kdegraphics-3.3.1-9.el4_6.*/ "--mock=epel-4")
(#/kdemultimedia-3.3.1-2/ "--mock=epel-4")
(#/kdenetwork-3.3.1-2.3/ "--mock=epel-4")
(#/kdenetwork-3.3.1-2/ "--mock=epel-4")
(#/kdenetwork-3.3.1-4.el4/ "--mock=epel-4")
(#/kdenetwork-3.3.1-4.el4.*/ "--mock=epel-4")
(#/kdenetwork-3.5.4-4.fc6/ "--mock=epel-5")
(#/kdenetwork-3.5.4-8.el5/ "--mock=epel-5")
(#/kdenetwork-3.5.4-8.el5.*/ "--mock=epel-5")
(#/kdenetwork-3.5.4-9.el5/ "--mock=epel-5")
(#/kdenetwork-3.5.4-9.el5.*/ "--mock=epel-5")
(#/kernel-rt-2.6.24.7-161.el5rt.*/ "--mock=epel-5")
(#/krbafs-1.2.2-6/ "--mock=epel-4")
(#/libapreq2-2.09-8.el4sat.*/ "--mock=epel-4")
(#/libapreq2-2.09-8.el5sat.*/ "--mock=epel-5")
(#/libbtctl-0.6.0-9.2.el5/ "--mock=epel-5")
(#/libbtctl-0.6.0-9.2.el5.*/ "--mock=epel-5")
(#/libibverbs-1.0.rc4-0.4265.2.EL4/ "--mock=epel-4")
(#/libibverbs-1.0.rc4-0.4265.2.EL4.*/ "--mock=epel-4")
(#/libmthca-1.0.rc4-0.4265.2.EL4/ "--mock=epel-4")
(#/libmthca-1.0.rc4-0.4265.2.EL4.*/ "--mock=epel-4")
(#/libsdp-0.90-0.4265.2.EL4/ "--mock=epel-4")
(#/libsdp-0.90-0.4265.2.EL4.*/ "--mock=epel-4")
(#/libsdp-1.1.99-11.el4.*/ "--mock=epel-4")
(#/libspe2-2.2.80.121-4.el5/ "--mock=epel-5")
(#/libspe2-2.2.80.121-4.el5.*/ "--mock=epel-5")
(#/libspe2-2.3.0.135-3.el5/ "--mock=epel-5")
(#/libspe2-2.3.0.135-3.el5.*/ "--mock=epel-5")
(#/libusb-0.1.12-5.1/ "--mock=epel-5")
(#/lilo-21.4.4-26.1/ "--mock=epel-4")
(#/lsof-4.72-1.1/ "--mock=epel-4")
(#/lsof-4.72-1.4/ "--mock=epel-4")
(#/lsof-4.72-1/ "--mock=epel-4")
(#/lsof-4.78-3/ "--mock=epel-5")
(#/mtools-3.9.9-9/ "--mock=epel-4")
(#/mvapich2-1.2-0.p1.3.el5/ "--mock=epel-5")
(#/mvapich2-1.2-0.p1.3.el5.*/ "--mock=epel-5")
(#/mvapich2-1.2-0.p1.4.el4/ "--mock=epel-4")
(#/mvapich2-1.2-0.p1.4.el4.*/ "--mock=epel-4")
(#/mvapich2-1.4-1.el5/ "--mock=epel-5")
(#/mvapich2-1.4-1.el5.*/ "--mock=epel-5")
(#/mx4j-3.0.1-6jpp.4/ "--mock=epel-5")
(#/mysql-5.0.84-2.el5s2.*/ "--mock=epel-5")
(#/mysqlclient10-3.23.58-4.RHEL4.1.*/ "--mock=epel-4")
(#/mysqlclient14-4.1.14-4.el4s1.2.*/ "--mock=epel-4")
(#/mysqlclient14-4.1.22-1.el4s1.1.*/ "--mock=epel-4")
(#/mysqlclient14-4.1.22-1.el5s2.*/ "--mock=epel-5")
(#/ncurses-5.4-13/ "--mock=epel-4")
(#/ncurses-5.4-15.el4/ "--mock=epel-4")
(#/ncurses-5.4-15.el4.*/ "--mock=epel-4")
(#/ncurses-5.5-24.20060715/ "--mock=epel-5")
(#/NetworkManager-0.6.4-6.el5/ "--mock=epel-5")
(#/NetworkManager-0.6.4-6.el5.*/ "--mock=epel-5")
(#/openais-0.80.3-7.el5/ "--mock=epel-5")
(#/openais-0.80.3-7.el5.*/ "--mock=epel-5")
(#/openib-1.0-1/ "--mock=epel-4")
(#/openib-1.1-5.el5/ "--mock=epel-5")
(#/openib-1.1-5.el5.*/ "--mock=epel-5")
(#/openib-1.1-7/ "--mock=epel-4")
(#/openib-mstflint-1.3-3.el4/ "--mock=epel-4")
(#/openib-perftest-1.2-13.el4/ "--mock=epel-4")
(#/openib-tvflash-0.9.2-8.el4/ "--mock=epel-4")
(#/openmpi11-1.1.5-1.el4_7.*/ "--mock=epel-4")
(#/openmpi11-1.1.5-7.el4.*/ "--mock=epel-4")
(#/openmpi-1.1.1-5.el5/ "--mock=epel-5")
(#/openmpi-1.1.1-5.el5.*/ "--mock=epel-5")
(#/openmpi-1.1.1-8/ "--mock=epel-4")
(#/openmpi-1.2.3-1/ "--mock=epel-4")
(#/openmpi-1.2.3-4.el5/ "--mock=epel-5")
(#/openmpi-1.2.3-4.el5.*/ "--mock=epel-5")
(#/openmpi-1.2.5-5.el4.*/ "--mock=epel-4")
(#/openmpi-1.2.5-5.el5/ "--mock=epel-5")
(#/openmpi-1.2.5-5.el5.*/ "--mock=epel-5")
(#/openmpi-1.2.7-2.el4_7.*/ "--mock=epel-4")
(#/openmpi-1.2.7-6.el5/ "--mock=epel-5")
(#/openmpi-1.2.7-6.el5.*/ "--mock=epel-5")
(#/openmpi-1.2.8-4.el4.*/ "--mock=epel-4")
(#/openmpi-1.3.2-2.el5/ "--mock=epel-5")
(#/openmpi-1.3.2-2.el5.*/ "--mock=epel-5")
(#/openoffice.org-3.1.1-19.5.el5.*/ "--mock=epel-5")
(#/opensm-3.2.2-3.el5/ "--mock=epel-5")
(#/opensm-3.2.2-3.el5.*/ "--mock=epel-5")
(#/opensm-3.2.5-1.el4.*/ "--mock=epel-4")
(#/opensm-3.2.6-2.el5/ "--mock=epel-5")
(#/opensm-3.2.6-2.el5.*/ "--mock=epel-5")
(#/opensm-3.3.3-1.el5/ "--mock=epel-5")
(#/opensm-3.3.3-1.el5.*/ "--mock=epel-5")
(#/pax-3.4-1.2.2/ "--mock=epel-5")
(#/pax-3.4-2.el5/ "--mock=epel-5")
(#/pax-3.4-2.el5.*/ "--mock=epel-5")
(#/pm-utils-0.19-3/ "--mock=epel-5")
(#/ppp-2.4.2-6.4.RHEL4/ "--mock=epel-4")
(#/ppp-2.4.2-6.4.RHEL4.*/ "--mock=epel-4")
(#/ppp-2.4.4-1.el5/ "--mock=epel-5")
(#/ppp-2.4.4-1.el5.*/ "--mock=epel-5")
(#/ppp-2.4.4-2.el5/ "--mock=epel-5")
(#/ppp-2.4.4-2.el5.*/ "--mock=epel-5")
(#/pvm-3.4.4-21/ "--mock=epel-4")
(#/pvm-3.4.5-7.fc6.1/ "--mock=epel-5")
(#/python-pyblock-0.25-1/ "--mock=epel-5")
(#/python-pyblock-0.26-1.el5/ "--mock=epel-5")
(#/python-pyblock-0.26-1.el5.*/ "--mock=epel-5")
(#/qperf-0.4.2-1.el4/ "--mock=epel-4")
(#/qperf-0.4.2-1.el4.*/ "--mock=epel-4")
(#/rhpl-0.148.2-1/ "--mock=epel-4")
(#/rhpl-0.148.3-1/ "--mock=epel-4")
(#/rhpl-0.148.5-1/ "--mock=epel-4")
(#/rhpl-0.148.6-1/ "--mock=epel-4")
(#/rhpl-0.194.1-1/ "--mock=epel-5")
(#/rpmdb-redhat-4-0.20050107/ "--mock=epel-4")
(#/rpmdb-redhat-4-0.20050525/ "--mock=epel-4")
(#/rpmdb-redhat-4-0.20051001/ "--mock=epel-4")
(#/rpmdb-redhat-4-0.20060303/ "--mock=epel-4")
(#/rpmdb-redhat-4-0.20060803/ "--mock=epel-4")
(#/rpmdb-redhat-4-0.20070421/ "--mock=epel-4")
(#/rpmdb-redhat-4-0.20071108/ "--mock=epel-4")
(#/rpmdb-redhat-4-0.20080711/ "--mock=epel-4")
(#/rpmdb-redhat-4-0.20090504/ "--mock=epel-4")
(#/s390utils-1.5.3-17.el5/ "--mock=epel-5")
(#/s390utils-1.5.3-17.el5.*/ "--mock=epel-5")
(#/star-1.5a25-6/ "--mock=epel-4")
(#/star-1.5a25-8/ "--mock=epel-4")
(#/system-config-boot-0.2.13-1.el5/ "--mock=epel-5")
(#/system-config-boot-0.2.13-1.el5.*/ "--mock=epel-5")
(#/system-config-boot-0.2.7-1/ "--mock=epel-4")
(#/systemtap-0.5.12-1.el5/ "--mock=epel-5")
(#/systemtap-0.5.12-1.el5.*/ "--mock=epel-5")
(#/termcap-5.4-3/ "--mock=epel-4")
(#/termcap-5.5-1.20060701.1/ "--mock=epel-5")
(#/tomcat6-6.0.18-8.18.ep5.el4.*/ "--mock=epel-4")
(#/unixODBC-2.2.11-1.RHEL4.1/ "--mock=epel-4")
(#/unixODBC-2.2.11-1.RHEL4.1.*/ "--mock=epel-4")
(#/unixODBC-2.2.11-7.1/ "--mock=epel-5")
(#/unixODBC-2.2.11-7.el4s1.1.*/ "--mock=epel-4")
(#/unixODBC-2.2.12-1.el4s1.1.*/ "--mock=epel-4")
(#/unixODBC-2.2.12-1.el5s2.*/ "--mock=epel-5")
(#/unixODBC-2.2.12-6.el4s1.1.*/ "--mock=epel-4")
(#/unixODBC-2.2.12-8.el5s2.*/ "--mock=epel-5")
(#/usermode-1.74-1/ "--mock=epel-4")
(#/usermode-1.74-2.el4.1/ "--mock=epel-4")
(#/usermode-1.74-2.el4.1.*/ "--mock=epel-4")
(#/usermode-1.74-2/ "--mock=epel-4")
(#/xcin-2.5.3.pre3-24/ "--mock=epel-4")
(#/xcin-2.5.3.pre3-25/ "--mock=epel-4")
(#/xcin-2.5.3.pre3-27.el4/ "--mock=epel-4")
(#/xcin-2.5.3.pre3-27.el4.*/ "--mock=epel-4")
(#/xdoclet-1.2.3-7jpp.2/ "--mock=epel-5")
(#/xorg-x11-drv-ati-6.6.3-3.13.el5/ "--mock=epel-5")
(#/xorg-x11-drv-ati-6.6.3-3.13.el5.*/ "--mock=epel-5")
(#/xorg-x11-drv-ati-6.6.3-3.22.el5/ "--mock=epel-5")
(#/xorg-x11-drv-ati-6.6.3-3.22.el5.*/ "--mock=epel-5")
(#/xorg-x11-drv-i810-1.6.5-9.13.el5/ "--mock=epel-5")
(#/xorg-x11-drv-i810-1.6.5-9.13.el5.*/ "--mock=epel-5")
(#/xorg-x11-drv-i810-1.6.5-9.21.el5/ "--mock=epel-5")
(#/xorg-x11-drv-i810-1.6.5-9.21.el5.*/ "--mock=epel-5")
(#/xorg-x11-drv-nv-2.1.12-3.el5/ "--mock=epel-5")
(#/xorg-x11-drv-nv-2.1.12-3.el5.*/ "--mock=epel-5")
(#/xorg-x11-drv-nv-2.1.6-6.el5/ "--mock=epel-5")
(#/xorg-x11-drv-nv-2.1.6-6.el5.*/ "--mock=epel-5")
(#/xorg-x11-drv-summa-1.1.0-1.1/ "--mock=epel-5")

;;
(#/ghostscript-7.07-33.2.*/ "--mock-epel-4")
(#/HelixPlayer-1.0.3-1.*/ "--mock-epel-4")
(#/kdegraphics-3.3.1-3.6.*/ "--mock-epel-4")
(#/ypbind-1.17.2-14.*/ "--mock-epel-4")

;;
(#/xorg-x11-drv-i810-1.6.5-9.13.el5.*/ "--mock=epel-5")
