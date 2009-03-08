Summary: A link from gauche-mode srpmix sources directory to gauche-mode--trunk locpy directory
Name: gauche-mode--trunk-lcopy-link
Version: 0.0.15
Release: 0
License: GPL
Group: Development/Tools
URL: http://srpmix.org
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root
Buildarch: noarch
Autoreq: 0


%description
A link from gauche-mode srpmix sources directory to 
gauche-mode--trunk locpy directory.

%prep
builddistdir=%{_builddir}/%{name}
rm -rf $builddistdir

%build
linkto=../../../../lcopy/sources/g/gauche-mode/trunk
builddistdir=%{_builddir}/%{name}/var/lib/srpmix/sources/g/gauche-mode
mkdir -p ${builddistdir}
ln -sf $linkto ${builddistdir}/\%trunk

%install
builddistdir=%{_builddir}/%{name}/var/lib/srpmix/sources/g/gauche-mode
intalldir=/var/lib/srpmix/sources/g/gauche-mode

rm -rf $RPM_BUILD_ROOT
mkdir -p $RPM_BUILD_ROOT/${intalldir}

rsync -va $builddistdir/* $RPM_BUILD_ROOT/${intalldir}

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,root,root,-)
/var/lib/srpmix/sources/g/gauche-mode/*

%changelog
* Mon Mar  9 2009 lcopy genspec <yamato@redhat.com> - lcopy-link
- Built automatically.

 
