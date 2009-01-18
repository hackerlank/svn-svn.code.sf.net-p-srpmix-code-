Summary: A link from hal srpmix sources directory to hal locpy directory
Name: hal-lcopy-link
Version: 0.0.11
Release: 0
License: GPL
Group: Development/Tools
URL: http://srpmix.org
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root
Buildarch: noarch
Autoreq: 0


%description
A link from hal srpmix sources directory to 
hal locpy directory.

%prep
builddistdir=%{_builddir}/%{name}
rm -rf $builddistdir

%build
linkto=../../../../lcopy/sources/hal
builddistdir=%{_builddir}/%{name}/var/lib/srpmix/sources/h/hal
mkdir -p ${builddistdir}
ln -sf $linkto ${builddistdir}/\%CURRENT

%install
builddistdir=%{_builddir}/%{name}/var/lib/srpmix/sources/h/hal
intalldir=/var/lib/srpmix/sources/h/hal

rm -rf $RPM_BUILD_ROOT
mkdir -p $RPM_BUILD_ROOT/${intalldir}

rsync -va $builddistdir/* $RPM_BUILD_ROOT/${intalldir}

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,root,root,-)
/var/lib/srpmix/sources/h/hal/*

%changelog
* Mon Jan 19 2009 lcopy genspec <yamato@redhat.com> - lcopy-link
- Built automatically.

 
