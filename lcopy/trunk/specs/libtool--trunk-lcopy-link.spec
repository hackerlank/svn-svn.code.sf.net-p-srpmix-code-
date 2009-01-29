Summary: A link from libtool srpmix sources directory to libtool--trunk locpy directory
Name: libtool--trunk-lcopy-link
Version: 0.0.12
Release: 0
License: GPL
Group: Development/Tools
URL: http://srpmix.org
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root
Buildarch: noarch
Autoreq: 0


%description
A link from libtool srpmix sources directory to 
libtool--trunk locpy directory.

%prep
builddistdir=%{_builddir}/%{name}
rm -rf $builddistdir

%build
linkto=../../../../lcopy/sources/l/libtool/trunk
builddistdir=%{_builddir}/%{name}/var/lib/srpmix/sources/l/libtool
mkdir -p ${builddistdir}
ln -sf $linkto ${builddistdir}/\%trunk

%install
builddistdir=%{_builddir}/%{name}/var/lib/srpmix/sources/l/libtool
intalldir=/var/lib/srpmix/sources/l/libtool

rm -rf $RPM_BUILD_ROOT
mkdir -p $RPM_BUILD_ROOT/${intalldir}

rsync -va $builddistdir/* $RPM_BUILD_ROOT/${intalldir}

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,root,root,-)
/var/lib/srpmix/sources/l/libtool/*

%changelog
* Wed Jan 28 2009 lcopy genspec <yamato@redhat.com> - lcopy-link
- Built automatically.

 
