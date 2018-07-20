FROM centos:7

RUN yum -y install http://80.211.97.226/CentOS/7/os/x86_64/dante-1.4.2-1.el7.centos.x86_64.rpm

COPY sockd.conf /etc/dante/sockd.conf

EXPOSE 1080/TCP

CMD /usr/sbin/sockd -N 5