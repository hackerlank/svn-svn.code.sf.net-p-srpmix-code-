Summary: A link from libmt srpmix sources directory to libmt--trunk locpy directory
Name: libmt--trunk-lcopy-link
Version: 0.0.15
Release: 0
License: GPL
Group: Development/Tools
URL: http://srpmix.org
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root
Buildarch: noarch
Autoreq: 0


%description
A link from libmt srpmix sources directory to 
libmt--trunk locpy directory.

%prep
builddistdir=%{_builddir}/%{name}
rm -rf $builddistdir

%build
linkto=../../../../lcopy/sources/l/libmt/trunk
builddistdir=%{_builddir}/%{name}/var/lib/srpmix/sources/l/libmt
mkdir -p ${builddistdir}
ln -sf $linkto ${builddistdir}/\%trunk

%install
builddistdir=%{_builddir}/%{name}/var/lib/srpmix/sources/l/libmt
intalldir=/var/lib/srpmix/sources/l/libmt

rm -rf $RPM_BUILD_ROOT
mkdir -p $RPM_BUILD_ROOT/${intalldir}

rsync -va $builddistdir/* $RPM_BUILD_ROOT/${intalldir}

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,root,root,-)
/var/lib/srpmix/sources/l/libmt/*

%changelog
* Mon Mar  9 2009 lcopy genspec <yamato@redhat.com> - lcopy-link
- Built automatically.

 
