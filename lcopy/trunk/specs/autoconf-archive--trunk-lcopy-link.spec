Summary: A link from autoconf-archive srpmix sources directory to autoconf-archive--trunk locpy directory
Name: autoconf-archive--trunk-lcopy-link
Version: 0.0.12
Release: 0
License: GPL
Group: Development/Tools
URL: http://srpmix.org
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root
Buildarch: noarch
Autoreq: 0


%description
A link from autoconf-archive srpmix sources directory to 
autoconf-archive--trunk locpy directory.

%prep
builddistdir=%{_builddir}/%{name}
rm -rf $builddistdir

%build
linkto=../../../../lcopy/sources/a/autoconf-archive/trunk
builddistdir=%{_builddir}/%{name}/var/lib/srpmix/sources/a/autoconf-archive
mkdir -p ${builddistdir}
ln -sf $linkto ${builddistdir}/\%trunk

%install
builddistdir=%{_builddir}/%{name}/var/lib/srpmix/sources/a/autoconf-archive
intalldir=/var/lib/srpmix/sources/a/autoconf-archive

rm -rf $RPM_BUILD_ROOT
mkdir -p $RPM_BUILD_ROOT/${intalldir}

rsync -va $builddistdir/* $RPM_BUILD_ROOT/${intalldir}

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,root,root,-)
/var/lib/srpmix/sources/a/autoconf-archive/*

%changelog
* Wed Jan 28 2009 lcopy genspec <yamato@redhat.com> - lcopy-link
- Built automatically.

 
