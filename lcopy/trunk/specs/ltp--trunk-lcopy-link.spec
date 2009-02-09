Summary: A link from ltp srpmix sources directory to ltp--trunk locpy directory
Name: ltp--trunk-lcopy-link
Version: 0.0.14
Release: 0
License: GPL
Group: Development/Tools
URL: http://srpmix.org
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root
Buildarch: noarch
Autoreq: 0


%description
A link from ltp srpmix sources directory to 
ltp--trunk locpy directory.

%prep
builddistdir=%{_builddir}/%{name}
rm -rf $builddistdir

%build
linkto=../../../../lcopy/sources/l/ltp/trunk
builddistdir=%{_builddir}/%{name}/var/lib/srpmix/sources/l/ltp
mkdir -p ${builddistdir}
ln -sf $linkto ${builddistdir}/\%trunk

%install
builddistdir=%{_builddir}/%{name}/var/lib/srpmix/sources/l/ltp
intalldir=/var/lib/srpmix/sources/l/ltp

rm -rf $RPM_BUILD_ROOT
mkdir -p $RPM_BUILD_ROOT/${intalldir}

rsync -va $builddistdir/* $RPM_BUILD_ROOT/${intalldir}

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,root,root,-)
/var/lib/srpmix/sources/l/ltp/*

%changelog
* Thu Feb  5 2009 lcopy genspec <yamato@redhat.com> - lcopy-link
- Built automatically.

 
