Summary: A link from m4 srpmix sources directory to m4--trunk locpy directory
Name: m4--trunk-lcopy-link
Version: 0.0.12
Release: 0
License: GPL
Group: Development/Tools
URL: http://srpmix.org
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root
Buildarch: noarch
Autoreq: 0


%description
A link from m4 srpmix sources directory to 
m4--trunk locpy directory.

%prep
builddistdir=%{_builddir}/%{name}
rm -rf $builddistdir

%build
linkto=../../../../lcopy/sources/m/m4/trunk
builddistdir=%{_builddir}/%{name}/var/lib/srpmix/sources/m/m4
mkdir -p ${builddistdir}
ln -sf $linkto ${builddistdir}/\%trunk

%install
builddistdir=%{_builddir}/%{name}/var/lib/srpmix/sources/m/m4
intalldir=/var/lib/srpmix/sources/m/m4

rm -rf $RPM_BUILD_ROOT
mkdir -p $RPM_BUILD_ROOT/${intalldir}

rsync -va $builddistdir/* $RPM_BUILD_ROOT/${intalldir}

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,root,root,-)
/var/lib/srpmix/sources/m/m4/*

%changelog
* Wed Jan 28 2009 lcopy genspec <yamato@redhat.com> - lcopy-link
- Built automatically.

 
