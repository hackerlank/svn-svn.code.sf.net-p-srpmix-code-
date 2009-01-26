Summary: A link from man-pages srpmix sources directory to man-pages locpy directory
Name: man-pages-lcopy-link
Version: 0.0.9
Release: 0
License: GPL
Group: Development/Tools
URL: http://srpmix.org
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root
Buildarch: noarch
Autoreq: 0


%description
A link from man-pages srpmix sources directory to 
man-pages locpy directory.

%prep
builddistdir=%{_builddir}/%{name}
rm -rf $builddistdir

%build
linkto=../../../../lcopy/sources/man-pages
builddistdir=%{_builddir}/%{name}/var/lib/srpmix/sources/m/man-pages
mkdir -p ${builddistdir}
ln -sf $linkto ${builddistdir}/\%CURRENT

%install
builddistdir=%{_builddir}/%{name}/var/lib/srpmix/sources/m/man-pages
intalldir=/var/lib/srpmix/sources/m/man-pages

rm -rf $RPM_BUILD_ROOT
mkdir -p $RPM_BUILD_ROOT/${intalldir}

rsync -va $builddistdir/* $RPM_BUILD_ROOT/${intalldir}

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,root,root,-)
/var/lib/srpmix/sources/m/man-pages/*

%changelog
* Mon Dec 22 2008 lcopy genspec <yamato@redhat.com> - lcopy-link
- Built automatically.

 
