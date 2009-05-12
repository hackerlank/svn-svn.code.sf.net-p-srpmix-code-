Summary: A link from openssl srpmix sources directory to openssl--trunk locpy directory
Name: openssl--trunk-lcopy-link
Version: 0.0.17
Release: 0
License: GPL
Group: Development/Tools
URL: http://srpmix.org
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root
Buildarch: noarch
Autoreq: 0


%description
A link from openssl srpmix sources directory to 
openssl--trunk locpy directory.

%prep
builddistdir=%{_builddir}/%{name}
rm -rf $builddistdir

%build
linkto=../../../../lcopy/sources/o/openssl/trunk
builddistdir=%{_builddir}/%{name}/var/lib/srpmix/sources/o/openssl
mkdir -p ${builddistdir}
ln -sf $linkto ${builddistdir}/\%trunk

%install
builddistdir=%{_builddir}/%{name}/var/lib/srpmix/sources/o/openssl
intalldir=/var/lib/srpmix/sources/o/openssl

rm -rf $RPM_BUILD_ROOT
mkdir -p $RPM_BUILD_ROOT/${intalldir}

rsync -va $builddistdir/* $RPM_BUILD_ROOT/${intalldir}

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,root,root,-)
/var/lib/srpmix/sources/o/openssl/*

%changelog
* Mon Mar 30 2009 lcopy genspec <yamato@redhat.com> - lcopy-link
- Built automatically.

 