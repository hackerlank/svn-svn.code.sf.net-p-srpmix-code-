Name:		test-srpmix
Version:	0
Release:	0%{?dist}
Summary:	test package for srpmix

Group:          Development/Tools
License:	GPL
URL:		http://srpmix.org
Source0:	test-srpmix.c
BuildRoot:	%{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)

%description
test package for srpmix

%prep
%setup -c -T

%build
rm -rf $RPM_BUILD_ROOT
gcc -Wall $RPM_OPT_FLAGS -g %{SOURCE0} -o test-srpmix

%install
install -D -m 755 test-srpmix $RPM_BUILD_ROOT%{_bindir}/test-srpmix

%clean
rm -rf $RPM_BUILD_ROOT


%files
%defattr(-,root,root,-)
%{_bindir}/test-srpmix

%changelog
* Sun Jul 19 2009 Masatake YAMATO <yamato@redhat.com>
- Initial build
