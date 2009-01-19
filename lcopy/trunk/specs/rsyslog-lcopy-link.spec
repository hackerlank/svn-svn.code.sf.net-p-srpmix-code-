Summary: A link from rsyslog srpmix sources directory to rsyslog locpy directory
Name: rsyslog-lcopy-link
Version: 0.0.11
Release: 0
License: GPL
Group: Development/Tools
URL: http://srpmix.org
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root
Buildarch: noarch
Autoreq: 0


%description
A link from rsyslog srpmix sources directory to 
rsyslog locpy directory.

%prep
builddistdir=%{_builddir}/%{name}
rm -rf $builddistdir

%build
linkto=../../../../lcopy/sources/rsyslog
builddistdir=%{_builddir}/%{name}/var/lib/srpmix/sources/r/rsyslog
mkdir -p ${builddistdir}
ln -sf $linkto ${builddistdir}/\%CURRENT

%install
builddistdir=%{_builddir}/%{name}/var/lib/srpmix/sources/r/rsyslog
intalldir=/var/lib/srpmix/sources/r/rsyslog

rm -rf $RPM_BUILD_ROOT
mkdir -p $RPM_BUILD_ROOT/${intalldir}

rsync -va $builddistdir/* $RPM_BUILD_ROOT/${intalldir}

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,root,root,-)
/var/lib/srpmix/sources/r/rsyslog/*

%changelog
* Mon Jan 19 2009 lcopy genspec <yamato@redhat.com> - lcopy-link
- Built automatically.

 
