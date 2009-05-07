Summary: A link from lava srpmix sources directory to lava--trunk locpy directory
Name: lava--trunk-lcopy-link
Version: 0.0.17
Release: 0
License: GPL
Group: Development/Tools
URL: http://srpmix.org
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root
Buildarch: noarch
Autoreq: 0


%description
A link from lava srpmix sources directory to 
lava--trunk locpy directory.

%prep
builddistdir=%{_builddir}/%{name}
rm -rf $builddistdir

%build
linkto=../../../../lcopy/sources/l/lava/trunk
builddistdir=%{_builddir}/%{name}/home/lcopy/srpmix/sources/l/lava
mkdir -p ${builddistdir}
ln -sf $linkto ${builddistdir}/\%trunk

%install
builddistdir=%{_builddir}/%{name}/home/lcopy/srpmix/sources/l/lava
intalldir=/home/lcopy/srpmix/sources/l/lava

rm -rf $RPM_BUILD_ROOT
mkdir -p $RPM_BUILD_ROOT/${intalldir}

rsync -va $builddistdir/* $RPM_BUILD_ROOT/${intalldir}

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,root,root,-)
/home/lcopy/srpmix/sources/l/lava/*

%changelog
* Mon Apr 20 2009 lcopy genspec <yamato@redhat.com> - lcopy-link
- Built automatically.

 
