Summary: A link from gstreamer srpmix sources directory to gstreamer locpy directory
Name: gstreamer-lcopy-link
Version: 0.0.9
Release: 0
License: GPL
Group: Development/Tools
URL: http://srpmix.org
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root
Buildarch: noarch
Autoreq: 0


%description
A link from gstreamer srpmix sources directory to 
gstreamer locpy directory.

%prep
builddistdir=%{_builddir}/%{name}
rm -rf $builddistdir

%build
linkto=../../../../lcopy/sources/gstreamer
builddistdir=%{_builddir}/%{name}/var/lib/srpmix/sources/g/gstreamer
mkdir -p ${builddistdir}
ln -sf $linkto ${builddistdir}/\%CURRENT

%install
builddistdir=%{_builddir}/%{name}/var/lib/srpmix/sources/g/gstreamer
intalldir=/var/lib/srpmix/sources/g/gstreamer

rm -rf $RPM_BUILD_ROOT
mkdir -p $RPM_BUILD_ROOT/${intalldir}

rsync -va $builddistdir/* $RPM_BUILD_ROOT/${intalldir}

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,root,root,-)
/var/lib/srpmix/sources/g/gstreamer/*

%changelog
* Thu Dec 25 2008 lcopy genspec <yamato@redhat.com> - lcopy-link
- Built automatically.

 
