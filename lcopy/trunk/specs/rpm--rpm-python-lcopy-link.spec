Summary: A link from rpm srpmix sources directory to rpm--rpm-python locpy directory
Name: rpm--rpm-python-lcopy-link
Version: 0.0.14
Release: 0
License: GPL
Group: Development/Tools
URL: http://srpmix.org
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root
Buildarch: noarch
Autoreq: 0


%description
A link from rpm srpmix sources directory to 
rpm--rpm-python locpy directory.

%prep
builddistdir=%{_builddir}/%{name}
rm -rf $builddistdir

%build
linkto=../../../../lcopy/sources/r/rpm/rpm-python
builddistdir=%{_builddir}/%{name}/var/lib/srpmix/sources/r/rpm
mkdir -p ${builddistdir}
ln -sf $linkto ${builddistdir}/\%rpm-python

%install
builddistdir=%{_builddir}/%{name}/var/lib/srpmix/sources/r/rpm
intalldir=/var/lib/srpmix/sources/r/rpm

rm -rf $RPM_BUILD_ROOT
mkdir -p $RPM_BUILD_ROOT/${intalldir}

rsync -va $builddistdir/* $RPM_BUILD_ROOT/${intalldir}

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,root,root,-)
/var/lib/srpmix/sources/r/rpm/*

%changelog
* Fri Jan 30 2009 lcopy genspec <yamato@redhat.com> - lcopy-link
- Built automatically.

 
