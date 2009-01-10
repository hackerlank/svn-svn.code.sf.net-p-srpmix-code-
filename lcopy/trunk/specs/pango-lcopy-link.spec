Summary: A link from pango srpmix sources directory to pango locpy directory
Name: pango-lcopy-link
Version: 0.0.9
Release: 0
License: GPL
Group: Development/Tools
URL: http://srpmix.org
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root
Buildarch: noarch
Autoreq: 0


%description
A link from pango srpmix sources directory to 
pango locpy directory.

%prep
builddistdir=%{_builddir}/%{name}
rm -rf $builddistdir

%build
linkto=../../../../lcopy/sources/pango
builddistdir=%{_builddir}/%{name}/var/lib/srpmix/sources/p/pango
mkdir -p ${builddistdir}
ln -sf $linkto ${builddistdir}/\%CURRENT

%install
builddistdir=%{_builddir}/%{name}/var/lib/srpmix/sources/p/pango
intalldir=/var/lib/srpmix/sources/p/pango

rm -rf $RPM_BUILD_ROOT
mkdir -p $RPM_BUILD_ROOT/${intalldir}

rsync -va $builddistdir/* $RPM_BUILD_ROOT/${intalldir}

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,root,root,-)
/var/lib/srpmix/sources/p/pango/*

%changelog
* Sun Jan 11 2009 lcopy genspec <yamato@redhat.com> - lcopy-link
- Built automatically.

 
