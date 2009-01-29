Summary: A link from gnash srpmix sources directory to gnash--trunk locpy directory
Name: gnash--trunk-lcopy-link
Version: 0.0.14
Release: 0
License: GPL
Group: Development/Tools
URL: http://srpmix.org
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root
Buildarch: noarch
Autoreq: 0


%description
A link from gnash srpmix sources directory to 
gnash--trunk locpy directory.

%prep
builddistdir=%{_builddir}/%{name}
rm -rf $builddistdir

%build
linkto=../../../../lcopy/sources/g/gnash/trunk
builddistdir=%{_builddir}/%{name}/var/lib/srpmix/sources/g/gnash
mkdir -p ${builddistdir}
ln -sf $linkto ${builddistdir}/\%trunk

%install
builddistdir=%{_builddir}/%{name}/var/lib/srpmix/sources/g/gnash
intalldir=/var/lib/srpmix/sources/g/gnash

rm -rf $RPM_BUILD_ROOT
mkdir -p $RPM_BUILD_ROOT/${intalldir}

rsync -va $builddistdir/* $RPM_BUILD_ROOT/${intalldir}

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,root,root,-)
/var/lib/srpmix/sources/g/gnash/*

%changelog
* Thu Jan 29 2009 lcopy genspec <yamato@redhat.com> - lcopy-link
- Built automatically.

 
