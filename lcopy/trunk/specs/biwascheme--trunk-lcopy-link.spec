Summary: A link from biwascheme srpmix sources directory to biwascheme--trunk locpy directory
Name: biwascheme--trunk-lcopy-link
Version: 0.0.16
Release: 0
License: GPL
Group: Development/Tools
URL: http://srpmix.org
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root
Buildarch: noarch
Autoreq: 0


%description
A link from biwascheme srpmix sources directory to 
biwascheme--trunk locpy directory.

%prep
builddistdir=%{_builddir}/%{name}
rm -rf $builddistdir

%build
linkto=../../../../lcopy/sources/b/biwascheme/trunk
builddistdir=%{_builddir}/%{name}/var/lib/srpmix/sources/b/biwascheme
mkdir -p ${builddistdir}
ln -sf $linkto ${builddistdir}/\%trunk

%install
builddistdir=%{_builddir}/%{name}/var/lib/srpmix/sources/b/biwascheme
intalldir=/var/lib/srpmix/sources/b/biwascheme

rm -rf $RPM_BUILD_ROOT
mkdir -p $RPM_BUILD_ROOT/${intalldir}

rsync -va $builddistdir/* $RPM_BUILD_ROOT/${intalldir}

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,root,root,-)
/var/lib/srpmix/sources/b/biwascheme/*

%changelog
* Mon Mar 30 2009 lcopy genspec <yamato@redhat.com> - lcopy-link
- Built automatically.

 
