Summary: A link from spacewalk srpmix sources directory to spacewalk--trunk locpy directory
Name: spacewalk--trunk-lcopy-link
Version: 0.0.17
Release: 0
License: GPL
Group: Development/Tools
URL: http://srpmix.org
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root
Buildarch: noarch
Autoreq: 0


%description
A link from spacewalk srpmix sources directory to 
spacewalk--trunk locpy directory.

%prep
builddistdir=%{_builddir}/%{name}
rm -rf $builddistdir

%build
linkto=../../../../lcopy/sources/s/spacewalk/trunk
builddistdir=%{_builddir}/%{name}/home/lcopy/srpmix/sources/s/spacewalk
mkdir -p ${builddistdir}
ln -sf $linkto ${builddistdir}/\%trunk

%install
builddistdir=%{_builddir}/%{name}/home/lcopy/srpmix/sources/s/spacewalk
intalldir=/home/lcopy/srpmix/sources/s/spacewalk

rm -rf $RPM_BUILD_ROOT
mkdir -p $RPM_BUILD_ROOT/${intalldir}

rsync -va $builddistdir/* $RPM_BUILD_ROOT/${intalldir}

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,root,root,-)
/home/lcopy/srpmix/sources/s/spacewalk/*

%changelog
* Thu May  7 2009 lcopy genspec <yamato@redhat.com> - lcopy-link
- Built automatically.

 
