Summary: A link from libvirt srpmix sources directory to libvirt locpy directory
Name: libvirt-lcopy-link
Version: 0.0.11
Release: 0
License: GPL
Group: Development/Tools
URL: http://srpmix.org
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root
Buildarch: noarch
Autoreq: 0


%description
A link from libvirt srpmix sources directory to 
libvirt locpy directory.

%prep
builddistdir=%{_builddir}/%{name}
rm -rf $builddistdir

%build
linkto=../../../../lcopy/sources/libvirt
builddistdir=%{_builddir}/%{name}/var/lib/srpmix/sources/l/libvirt
mkdir -p ${builddistdir}
ln -sf $linkto ${builddistdir}/\%CURRENT

%install
builddistdir=%{_builddir}/%{name}/var/lib/srpmix/sources/l/libvirt
intalldir=/var/lib/srpmix/sources/l/libvirt

rm -rf $RPM_BUILD_ROOT
mkdir -p $RPM_BUILD_ROOT/${intalldir}

rsync -va $builddistdir/* $RPM_BUILD_ROOT/${intalldir}

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,root,root,-)
/var/lib/srpmix/sources/l/libvirt/*

%changelog
* Fri Jan 16 2009 lcopy genspec <yamato@redhat.com> - lcopy-link
- Built automatically.

 
