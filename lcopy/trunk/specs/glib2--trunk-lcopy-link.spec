Summary: A link from glib2 srpmix sources directory to glib2--trunk locpy directory
Name: glib2--trunk-lcopy-link
Version: 0.0.12
Release: 0
License: GPL
Group: Development/Tools
URL: http://srpmix.org
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root
Buildarch: noarch
Autoreq: 0


%description
A link from glib2 srpmix sources directory to 
glib2--trunk locpy directory.

%prep
builddistdir=%{_builddir}/%{name}
rm -rf $builddistdir

%build
linkto=../../../../lcopy/sources/g/glib2/trunk
builddistdir=%{_builddir}/%{name}/var/lib/srpmix/sources/g/glib2
mkdir -p ${builddistdir}
ln -sf $linkto ${builddistdir}/\%trunk

%install
builddistdir=%{_builddir}/%{name}/var/lib/srpmix/sources/g/glib2
intalldir=/var/lib/srpmix/sources/g/glib2

rm -rf $RPM_BUILD_ROOT
mkdir -p $RPM_BUILD_ROOT/${intalldir}

rsync -va $builddistdir/* $RPM_BUILD_ROOT/${intalldir}

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,root,root,-)
/var/lib/srpmix/sources/g/glib2/*

%changelog
* Mon Jan 26 2009 lcopy genspec <yamato@redhat.com> - lcopy-link
- Built automatically.

 
