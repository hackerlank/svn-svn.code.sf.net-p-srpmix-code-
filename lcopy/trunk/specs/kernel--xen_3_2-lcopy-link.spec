Summary: A link from kernel srpmix sources directory to kernel--xen_3_2 locpy directory
Name: kernel--xen_3_2-lcopy-link
Version: 0.0.12
Release: 0
License: GPL
Group: Development/Tools
URL: http://srpmix.org
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root
Buildarch: noarch
Autoreq: 0


%description
A link from kernel srpmix sources directory to 
kernel--xen_3_2 locpy directory.

%prep
builddistdir=%{_builddir}/%{name}
rm -rf $builddistdir

%build
linkto=../../../../lcopy/sources/k/kernel/xen_3_2
builddistdir=%{_builddir}/%{name}/var/lib/srpmix/sources/k/kernel
mkdir -p ${builddistdir}
ln -sf $linkto ${builddistdir}/\%xen_3_2

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
* Mon Jan 26 2009 lcopy genspec <yamato@redhat.com> - lcopy-link
- Built automatically.

 
