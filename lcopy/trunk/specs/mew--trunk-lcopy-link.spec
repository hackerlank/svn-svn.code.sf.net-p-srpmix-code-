Summary: A link from mew srpmix sources directory to mew--trunk locpy directory
Name: mew--trunk-lcopy-link
Version: 0.0.17
Release: 0
License: GPL
Group: Development/Tools
URL: http://srpmix.org
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root
Buildarch: noarch
Autoreq: 0


%description
A link from mew srpmix sources directory to 
mew--trunk locpy directory.

%prep
builddistdir=%{_builddir}/%{name}
rm -rf $builddistdir

%build
linkto=../../../../lcopy/sources/m/mew/trunk
builddistdir=%{_builddir}/%{name}/home/lcopy/srpmix/sources/m/mew
mkdir -p ${builddistdir}
ln -sf $linkto ${builddistdir}/\%trunk

%install
builddistdir=%{_builddir}/%{name}/home/lcopy/srpmix/sources/m/mew
intalldir=/home/lcopy/srpmix/sources/m/mew

rm -rf $RPM_BUILD_ROOT
mkdir -p $RPM_BUILD_ROOT/${intalldir}

rsync -va $builddistdir/* $RPM_BUILD_ROOT/${intalldir}

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,root,root,-)
/home/lcopy/srpmix/sources/m/mew/*

%changelog
* Fri Apr 17 2009 lcopy genspec <yamato@redhat.com> - lcopy-link
- Built automatically.

 
