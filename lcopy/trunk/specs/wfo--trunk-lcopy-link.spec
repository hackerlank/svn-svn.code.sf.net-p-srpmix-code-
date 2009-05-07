Summary: A link from wfo srpmix sources directory to wfo--trunk locpy directory
Name: wfo--trunk-lcopy-link
Version: 0.0.16
Release: 0
License: GPL
Group: Development/Tools
URL: http://srpmix.org
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root
Buildarch: noarch
Autoreq: 0


%description
A link from wfo srpmix sources directory to 
wfo--trunk locpy directory.

%prep
builddistdir=%{_builddir}/%{name}
rm -rf $builddistdir

%build
linkto=../../../../lcopy/sources/w/wfo/trunk
builddistdir=%{_builddir}/%{name}/var/lib/srpmix/sources/w/wfo
mkdir -p ${builddistdir}
ln -sf $linkto ${builddistdir}/\%trunk

%install
builddistdir=%{_builddir}/%{name}/var/lib/srpmix/sources/w/wfo
intalldir=/var/lib/srpmix/sources/w/wfo

rm -rf $RPM_BUILD_ROOT
mkdir -p $RPM_BUILD_ROOT/${intalldir}

rsync -va $builddistdir/* $RPM_BUILD_ROOT/${intalldir}

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,root,root,-)
/var/lib/srpmix/sources/w/wfo/*

%changelog
* Thu Mar 12 2009 lcopy genspec <yamato@redhat.com> - lcopy-link
- Built automatically.

 
