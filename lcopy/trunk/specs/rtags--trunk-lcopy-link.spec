Summary: A link from rtags srpmix sources directory to rtags--trunk locpy directory
Name: rtags--trunk-lcopy-link
Version: 0.0.16
Release: 0
License: GPL
Group: Development/Tools
URL: http://srpmix.org
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root
Buildarch: noarch
Autoreq: 0


%description
A link from rtags srpmix sources directory to 
rtags--trunk locpy directory.

%prep
builddistdir=%{_builddir}/%{name}
rm -rf $builddistdir

%build
linkto=../../../../lcopy/sources/r/rtags/trunk
builddistdir=%{_builddir}/%{name}/var/lib/srpmix/sources/r/rtags
mkdir -p ${builddistdir}
ln -sf $linkto ${builddistdir}/\%trunk

%install
builddistdir=%{_builddir}/%{name}/var/lib/srpmix/sources/r/rtags
intalldir=/var/lib/srpmix/sources/r/rtags

rm -rf $RPM_BUILD_ROOT
mkdir -p $RPM_BUILD_ROOT/${intalldir}

rsync -va $builddistdir/* $RPM_BUILD_ROOT/${intalldir}

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,root,root,-)
/var/lib/srpmix/sources/r/rtags/*

%changelog
* Thu Mar 12 2009 lcopy genspec <yamato@redhat.com> - lcopy-link
- Built automatically.

 
