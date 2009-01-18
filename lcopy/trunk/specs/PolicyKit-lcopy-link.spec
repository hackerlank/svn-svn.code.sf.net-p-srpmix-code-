Summary: A link from PolicyKit srpmix sources directory to PolicyKit locpy directory
Name: PolicyKit-lcopy-link
Version: 0.0.11
Release: 0
License: GPL
Group: Development/Tools
URL: http://srpmix.org
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root
Buildarch: noarch
Autoreq: 0


%description
A link from PolicyKit srpmix sources directory to 
PolicyKit locpy directory.

%prep
builddistdir=%{_builddir}/%{name}
rm -rf $builddistdir

%build
linkto=../../../../lcopy/sources/PolicyKit
builddistdir=%{_builddir}/%{name}/var/lib/srpmix/sources/P/PolicyKit
mkdir -p ${builddistdir}
ln -sf $linkto ${builddistdir}/\%CURRENT

%install
builddistdir=%{_builddir}/%{name}/var/lib/srpmix/sources/P/PolicyKit
intalldir=/var/lib/srpmix/sources/P/PolicyKit

rm -rf $RPM_BUILD_ROOT
mkdir -p $RPM_BUILD_ROOT/${intalldir}

rsync -va $builddistdir/* $RPM_BUILD_ROOT/${intalldir}

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,root,root,-)
/var/lib/srpmix/sources/P/PolicyKit/*

%changelog
* Mon Jan 19 2009 lcopy genspec <yamato@redhat.com> - lcopy-link
- Built automatically.

 
