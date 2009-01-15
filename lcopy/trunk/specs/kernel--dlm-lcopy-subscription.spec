%define lcopy_x_pkg kernel
%define lcopy_x_branch dlm
%define lcopy_x_vcs git
%define lcopy_x_vcs_pkg git
%define lcopy_x_repo git://git.kernel.org/pub/scm/linux/kernel/git/teigland/dlm.git

%define lcopy_branch_suffix %{?lcopy_x_branch:--%{lcopy_x_branch}}
%define lcopy_branch_doc    %{?lcopy_x_branch:(branch %{lcopy_x_branch}) }

%define lcopy_x_cmdline git clone git://git.kernel.org/pub/scm/linux/kernel/git/teigland/dlm.git kernel

%define lcopy_version 0.0.9
%define lcopy_release 0
%define lcopy_rootdir /var/lib/lcopy
%define lcopy_srcdir %{lcopy_rootdir}/sources



Summary: Subscribing %{lcopy_x_pkg}%{lcopy_branch_doc} source code via %{lcopy_x_vcs}
Name: %{lcopy_x_pkg}%{lcopy_branch_suffix}-lcopy-subscription
Version: %{lcopy_version}
Release: %{lcopy_release}
License: GPL
Group: Development/Tools
URL: http://srpmix.org
Requires: %{lcopy_x_vcs_pkg}
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root
Buildarch: noarch
Autoreq: 0


%description
Subscribing  source code via %{lcopy_x_vcs} from
%{lcopy_x_repo}.

%prep

%build

%install
mkdir -p $RPM_BUILD_ROOT
%clean
rm -rf $RPM_BUILD_ROOT

%post
cd %{lcopy_srcdir}
test -d %{lcopy_x_pkg}%{lcopy_branch_suffix} || lcopy --branch=dlm --no-spec %{lcopy_x_cmdline}

%postun
rm -rf %{lcopy_srcdir}/%{lcopy_x_pkg}%{lcopy_branch_suffix}

%files
%defattr(-,root,root,-)
%doc


%changelog
* Mon Dec 22 2008 lcopy genspec <yamato@redhat.com> - lcopy-subscription
- Built automatically.

 
