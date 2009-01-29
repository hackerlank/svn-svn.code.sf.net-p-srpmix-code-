Summary: A link from java-1.6.0-openjdk srpmix sources directory to java-1.6.0-openjdk--icedtea6 locpy directory
Name: java-1.6.0-openjdk--icedtea6-lcopy-link
Version: 0.0.13
Release: 0
License: GPL
Group: Development/Tools
URL: http://srpmix.org
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root
Buildarch: noarch
Autoreq: 0


%description
A link from java-1.6.0-openjdk srpmix sources directory to 
java-1.6.0-openjdk--icedtea6 locpy directory.

%prep
builddistdir=%{_builddir}/%{name}
rm -rf $builddistdir

%build
linkto=../../../../lcopy/sources/j/java-1.6.0-openjdk/icedtea6
builddistdir=%{_builddir}/%{name}/var/lib/srpmix/sources/j/java-1.6.0-openjdk
mkdir -p ${builddistdir}
ln -sf $linkto ${builddistdir}/\%icedtea6

%install
builddistdir=%{_builddir}/%{name}/var/lib/srpmix/sources/j/java-1.6.0-openjdk
intalldir=/var/lib/srpmix/sources/j/java-1.6.0-openjdk

rm -rf $RPM_BUILD_ROOT
mkdir -p $RPM_BUILD_ROOT/${intalldir}

rsync -va $builddistdir/* $RPM_BUILD_ROOT/${intalldir}

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,root,root,-)
/var/lib/srpmix/sources/j/java-1.6.0-openjdk/*

%changelog
* Thu Jan 29 2009 lcopy genspec <yamato@redhat.com> - lcopy-link
- Built automatically.

 
