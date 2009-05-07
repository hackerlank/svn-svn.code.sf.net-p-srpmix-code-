Summary: A link from kernel srpmix sources directory to kernel--rt locpy directory
Name: kernel--rt-lcopy-link
Version: 0.0.14
Release: 0
License: GPL
Group: Development/Tools
URL: http://srpmix.org
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root
Buildarch: noarch
Autoreq: 0


%description
A link from kernel srpmix sources directory to 
kernel--rt locpy directory.

%prep
builddistdir=%{_builddir}/%{name}
rm -rf $builddistdir

%build
linkto=../../../../lcopy/sources/k/kernel/rt
builddistdir=%{_builddir}/%{name}/var/lib/srpmix/sources/k/kernel
mkdir -p ${builddistdir}
ln -sf $linkto ${builddistdir}/\%rt

%install
builddistdir=%{_builddir}/%{name}/var/lib/srpmix/sources/k/kernel
intalldir=/var/lib/srpmix/sources/k/kernel

rm -rf $RPM_BUILD_ROOT
mkdir -p $RPM_BUILD_ROOT/${intalldir}

rsync -va $builddistdir/* $RPM_BUILD_ROOT/${intalldir}

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,root,root,-)
/var/lib/srpmix/sources/k/kernel/*

%changelog
* Mon Mar  9 2009 lcopy genspec <yamato@redhat.com> - lcopy-link
- Built automatically.

 
