Summary: A link from hal srpmix sources directory to hal--trunk locpy directory
Name: hal--trunk-lcopy-link
Version: 0.0.12
Release: 0
License: GPL
Group: Development/Tools
URL: http://srpmix.org
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root
Buildarch: noarch
Autoreq: 0


%description
A link from hal srpmix sources directory to 
hal--trunk locpy directory.

%prep
builddistdir=%{_builddir}/%{name}
rm -rf $builddistdir

%build
linkto=../../../../lcopy/sources/h/hal/trunk
builddistdir=%{_builddir}/%{name}/var/lib/srpmix/sources/h/hal
mkdir -p ${builddistdir}
ln -sf $linkto ${builddistdir}/\%trunk

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
* Mon Jan 26 2009 lcopy genspec <yamato@redhat.com> - lcopy-link
- Built automatically.

 
