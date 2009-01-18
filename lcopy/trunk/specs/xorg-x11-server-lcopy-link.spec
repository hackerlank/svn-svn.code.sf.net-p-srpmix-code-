Summary: A link from xorg-x11-server srpmix sources directory to xorg-x11-server locpy directory
Name: xorg-x11-server-lcopy-link
Version: 0.0.11
Release: 0
License: GPL
Group: Development/Tools
URL: http://srpmix.org
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root
Buildarch: noarch
Autoreq: 0


%description
A link from xorg-x11-server srpmix sources directory to 
xorg-x11-server locpy directory.

%prep
builddistdir=%{_builddir}/%{name}
rm -rf $builddistdir

%build
linkto=../../../../lcopy/sources/xorg-x11-server
builddistdir=%{_builddir}/%{name}/var/lib/srpmix/sources/x/xorg-x11-server
mkdir -p ${builddistdir}
ln -sf $linkto ${builddistdir}/\%CURRENT

%install
builddistdir=%{_builddir}/%{name}/var/lib/srpmix/sources/x/xorg-x11-server
intalldir=/var/lib/srpmix/sources/x/xorg-x11-server

rm -rf $RPM_BUILD_ROOT
mkdir -p $RPM_BUILD_ROOT/${intalldir}

rsync -va $builddistdir/* $RPM_BUILD_ROOT/${intalldir}

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,root,root,-)
/var/lib/srpmix/sources/x/xorg-x11-server/*

%changelog
* Mon Jan 19 2009 lcopy genspec <yamato@redhat.com> - lcopy-link
- Built automatically.

 
