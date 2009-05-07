Summary: A link from emacs srpmix sources directory to emacs--trunk locpy directory
Name: emacs--trunk-lcopy-link
Version: 0.0.14
Release: 0
License: GPL
Group: Development/Tools
URL: http://srpmix.org
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root
Buildarch: noarch
Autoreq: 0


%description
A link from emacs srpmix sources directory to 
emacs--trunk locpy directory.

%prep
builddistdir=%{_builddir}/%{name}
rm -rf $builddistdir

%build
linkto=../../../../lcopy/sources/e/emacs/trunk
builddistdir=%{_builddir}/%{name}/var/lib/srpmix/sources/e/emacs
mkdir -p ${builddistdir}
ln -sf $linkto ${builddistdir}/\%trunk

%install
builddistdir=%{_builddir}/%{name}/var/lib/srpmix/sources/e/emacs
intalldir=/var/lib/srpmix/sources/e/emacs

rm -rf $RPM_BUILD_ROOT
mkdir -p $RPM_BUILD_ROOT/${intalldir}

rsync -va $builddistdir/* $RPM_BUILD_ROOT/${intalldir}

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,root,root,-)
/var/lib/srpmix/sources/e/emacs/*

%changelog
* Wed Mar 11 2009 lcopy genspec <yamato@redhat.com> - lcopy-link
- Built automatically.

 
