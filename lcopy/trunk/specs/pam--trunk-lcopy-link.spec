Summary: A link from pam srpmix sources directory to pam--trunk locpy directory
Name: pam--trunk-lcopy-link
Version: 0.0.17
Release: 0
License: GPL
Group: Development/Tools
URL: http://srpmix.org
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root
Buildarch: noarch
Autoreq: 0


%description
A link from pam srpmix sources directory to 
pam--trunk locpy directory.

%prep
builddistdir=%{_builddir}/%{name}
rm -rf $builddistdir

%build
linkto=../../../../lcopy/sources/p/pam/trunk
builddistdir=%{_builddir}/%{name}/var/lib/srpmix/sources/p/pam
mkdir -p ${builddistdir}
ln -sf $linkto ${builddistdir}/\%trunk

%install
builddistdir=%{_builddir}/%{name}/var/lib/srpmix/sources/p/pam
intalldir=/var/lib/srpmix/sources/p/pam

rm -rf $RPM_BUILD_ROOT
mkdir -p $RPM_BUILD_ROOT/${intalldir}

rsync -va $builddistdir/* $RPM_BUILD_ROOT/${intalldir}

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,root,root,-)
/var/lib/srpmix/sources/p/pam/*

%changelog
* Fri Apr 10 2009 lcopy genspec <yamato@redhat.com> - lcopy-link
- Built automatically.

 
