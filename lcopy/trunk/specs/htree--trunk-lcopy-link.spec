Summary: A link from htree srpmix sources directory to htree--trunk locpy directory
Name: htree--trunk-lcopy-link
Version: 0.0.16
Release: 0
License: GPL
Group: Development/Tools
URL: http://srpmix.org
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root
Buildarch: noarch
Autoreq: 0


%description
A link from htree srpmix sources directory to 
htree--trunk locpy directory.

%prep
builddistdir=%{_builddir}/%{name}
rm -rf $builddistdir

%build
linkto=../../../../lcopy/sources/h/htree/trunk
builddistdir=%{_builddir}/%{name}/var/lib/srpmix/sources/h/htree
mkdir -p ${builddistdir}
ln -sf $linkto ${builddistdir}/\%trunk

%install
builddistdir=%{_builddir}/%{name}/var/lib/srpmix/sources/h/htree
intalldir=/var/lib/srpmix/sources/h/htree

rm -rf $RPM_BUILD_ROOT
mkdir -p $RPM_BUILD_ROOT/${intalldir}

rsync -va $builddistdir/* $RPM_BUILD_ROOT/${intalldir}

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,root,root,-)
/var/lib/srpmix/sources/h/htree/*

%changelog
* Thu Mar 12 2009 lcopy genspec <yamato@redhat.com> - lcopy-link
- Built automatically.

 
