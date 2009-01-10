Summary: A link from gauche srpmix sources directory to gauche locpy directory
Name: gauche-lcopy-link
Version: 0.0.9
Release: 0
License: GPL
Group: Development/Tools
URL: http://srpmix.org
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root
Buildarch: noarch
Autoreq: 0


%description
A link from gauche srpmix sources directory to 
gauche locpy directory.

%prep
builddistdir=%{_builddir}/%{name}
rm -rf $builddistdir

%build
linkto=../../../../lcopy/sources/gauche
builddistdir=%{_builddir}/%{name}/var/lib/srpmix/sources/g/gauche
mkdir -p ${builddistdir}
ln -sf $linkto ${builddistdir}/\%CURRENT

%install
builddistdir=%{_builddir}/%{name}/var/lib/srpmix/sources/g/gauche
intalldir=/var/lib/srpmix/sources/g/gauche

rm -rf $RPM_BUILD_ROOT
mkdir -p $RPM_BUILD_ROOT/${intalldir}

rsync -va $builddistdir/* $RPM_BUILD_ROOT/${intalldir}

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,root,root,-)
/var/lib/srpmix/sources/g/gauche/*

%changelog
* Sun Jan 11 2009 lcopy genspec <yamato@redhat.com> - lcopy-link
- Built automatically.

 
