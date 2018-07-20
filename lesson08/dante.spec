Name:           dante
Version:        1.4.2
Release:        1%{?dist}
Summary:        Dante socks proxy server

License:        BSD-type
URL:            http://www.inet.no/dante/
Source0:        dante-1.4.2.tar.gz

BuildRequires:  pam-devel bison flex

%description
Dante socks proxy server package with systemd config.


%prep
%setup -q

%{__cat} >sockd.systemd.conf <<'EOF'
CONFIG_FILE=/etc/dante/sockd.conf
PROC_NUMBERS=10
EOF

%{__cat} >sockd.service <<'EOF'
[Unit]
Description=Dante Socks Proxy Server
After=network.target
Documentation=man:sockd(5)
Documentation=man:sockd(8)

[Service]
Type=simple
EnvironmentFile=/etc/sysconfig/sockd
ExecStart=/usr/sbin/sockd -f ${CONFIG_FILE} -N ${PROC_NUMBERS}
ExecReload=/bin/kill -HUP $MAINPID

[Install]
WantedBy=multi-user.target
EOF

%build
%configure \
--disable-client \
--disable-pidfile \
--disable-clientdl \
--with-socks-conf=/etc/dante/socks.conf \
--with-sockd-conf=/etc/dante/sockd.conf \
--without-glibc-secure \
%{_extraflags}

make %{?_smp_mflags}


%install
rm -rf $RPM_BUILD_ROOT
%make_install

%{__install} -d ${RPM_BUILD_ROOT}/%{_sysconfdir}/dante
%{__install} -m 0644 example/socks-simple.conf ${RPM_BUILD_ROOT}/%{_sysconfdir}/dante/socks.conf
%{__install} -m 0644 example/sockd.conf ${RPM_BUILD_ROOT}/%{_sysconfdir}/dante/
%{__install} -d ${RPM_BUILD_ROOT}/%{_sysconfdir}/sysconfig
%{__install} -m 0644 sockd.systemd.conf ${RPM_BUILD_ROOT}/%{_sysconfdir}/sysconfig/sockd
%{__install} -d ${RPM_BUILD_ROOT}/%{_sysconfdir}/systemd/system
%{__install} -m 0644 sockd.service ${RPM_BUILD_ROOT}/%{_sysconfdir}/systemd/system/
rm -f sockd.service ${RPM_BUILD_ROOT}/%{_bindir}/socksify
rm -f sockd.service ${RPM_BUILD_ROOT}/%{_mandir}/man1/socksify.1*
rm -f sockd.service ${RPM_BUILD_ROOT}/%{_includedir}/socks.h

%files
%defattr(-, root, root, 0755)
%doc BUGS CREDITS NEWS README SUPPORT doc/README* example/socks.conf example/socks-simple-withoutnameserver.conf example/sockd.conf example/socks-simple.conf
%config %{_sysconfdir}/dante/socks.conf
%config %{_sysconfdir}/dante/sockd.conf
%config %{_sysconfdir}/sysconfig/sockd
%config %{_sysconfdir}/systemd/system/sockd.service
%{_sbindir}/sockd
%{_mandir}/man5/socks.conf.5*
%{_mandir}/man5/sockd.conf.5*
%{_mandir}/man8/sockd.8*