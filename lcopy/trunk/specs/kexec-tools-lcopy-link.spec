Summary: A link from kexec-tools srpmix sources directory to kexec-tools locpy directory
Name: kexec-tools-lcopy-link
Version: 0.0.11
Release: 0
License: GPL
Group: Development/Tools
URL: http://srpmix.org
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root
Buildarch: noarch
Autoreq: 0


%description
A link from kexec-tools srpmix sources directory to 
kexec-tools locpy directory.

%prep
builddistdir=%{_builddir}/%{name}
rm -rf $builddistdir

%build
linkto=../../../../lcopy/sources/kexec-tools
builddistdir=%{_builddir}/%{name}/var/lib/srpmix/sources/k/kexec-tools
mkdir -p ${builddistdir}
ln -sf $linkto ${builddistdir}/\%CURRENT

%install
builddistdir=%{_builddir}/%{name}/var/lib/srpmix/sources/k/kexec-tools
intalldir=/var/lib/srpmix/sources/k/kexec-tools

rm -rf $RPM_BUILD_ROOT
mkdir -p $RPM_BUILD_ROOT/${intalldir}

rsync -va $builddistdir/* $RPM_BUILD_ROOT/${intalldir}

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,root,root,-)
/var/lib/srpmix/sources/k/kexec-tools/*

%changelog
* Mon Jan 19 2009 lcopy genspec <yamato@redhat.com> - lcopy-link
- Built automatically.

 
