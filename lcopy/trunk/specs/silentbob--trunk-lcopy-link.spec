Summary: A link from silentbob srpmix sources directory to silentbob--trunk locpy directory
Name: silentbob--trunk-lcopy-link
Version: 0.0.17
Release: 0
License: GPL
Group: Development/Tools
URL: http://srpmix.org
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root
Buildarch: noarch
Autoreq: 0


%description
A link from silentbob srpmix sources directory to 
silentbob--trunk locpy directory.

%prep
builddistdir=%{_builddir}/%{name}
rm -rf $builddistdir

%build
linkto=../../../../lcopy/sources/s/silentbob/trunk
builddistdir=%{_builddir}/%{name}/home/lcopy/srpmix/sources/s/silentbob
mkdir -p ${builddistdir}
ln -sf $linkto ${builddistdir}/\%trunk

%install
builddistdir=%{_builddir}/%{name}/home/lcopy/srpmix/sources/s/silentbob
intalldir=/home/lcopy/srpmix/sources/s/silentbob

rm -rf $RPM_BUILD_ROOT
mkdir -p $RPM_BUILD_ROOT/${intalldir}

rsync -va $builddistdir/* $RPM_BUILD_ROOT/${intalldir}

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,root,root,-)
/home/lcopy/srpmix/sources/s/silentbob/*

%changelog
* Thu May 14 2009 lcopy genspec <yamato@redhat.com> - lcopy-link
- Built automatically.

 
