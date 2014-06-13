#!/usr/bin/env bash

yum install -y mc ntp ed

MASTER_HOSTNAME=gpdb
MASTER_DOMAINNAME=localdomain

echo "127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4" > /etc/hosts
echo "::1         localhost localhost.localdomain localhost6 localhost6.localdomain6" >> /etc/hosts
echo "192.168.2.11 ${MASTER_HOSTNAME}.${MASTER_DOMAINNAME} ${MASTER_HOSTNAME}" >> /etc/hosts

sed -i "s/HOSTNAME=.*/HOSTNAME=${MASTER_HOSTNAME}.${MASTER_DOMAINNAME}/" /etc/sysconfig/network
hostname ${MASTER_HOSTNAME}.${MASTER_DOMAINNAME}

/etc/init.d/network restart


adduser -m -U -p "$(openssl passwd -1 'gpadmin')" gpadmin

ssh-keygen -t rsa -P "" -f ~/.ssh/id_rsa
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys

mv ~/.ssh /home/gpadmin/
chown -R gpadmin:gpadmin /home/gpadmin

su - gpadmin -c "ssh -o StrictHostKeyChecking=no localhost echo Added localhost to ~/.ssh/known_hosts" 2>&1 >/dev/null
su - gpadmin -c "ssh -o StrictHostKeyChecking=no ${MASTER_HOSTNAME} echo Added ${MASTER_HOSTNAME} to ~/.ssh/known_hosts" 2>&1 >/dev/null
su - gpadmin -c "ssh -o StrictHostKeyChecking=no ${MASTER_HOSTNAME}.${MASTER_DOMAINNAME} echo Added ${MASTER_HOSTNAME}.${MASTER_DOMAINNAME} to ~/.ssh/known_hosts" 2>&1 >/dev/null


cp -R /vagrant/remote/gpconfigs /home/gpadmin/

echo ${MASTER_HOSTNAME} > /home/gpadmin/gpconfigs/hostlist_singlenode
sed -i "s/###HOSTNAME###/${MASTER_HOSTNAME}/" /home/gpadmin/gpconfigs/gpinitsystem_config

cp /vagrant/remote/.bash_profile /home/gpadmin/

mkdir /gpdata1 /gpdata2 /gpmaster

chown -R gpadmin:gpadmin /home/gpadmin /gpdata1 /gpdata2 /gpmaster


echo "kernel.shmmax = 500000000" > /etc/sysctl.conf
echo "kernel.shmmni = 4096" >> /etc/sysctl.conf
echo "kernel.shmall = 4000000000" >> /etc/sysctl.conf
echo "kernel.sem = 250 512000 100 2048" >> /etc/sysctl.conf
echo "kernel.sysrq = 1" >> /etc/sysctl.conf
echo "kernel.core_uses_pid = 1" >> /etc/sysctl.conf
echo "kernel.msgmnb = 65536" >> /etc/sysctl.conf
echo "kernel.msgmax = 65536" >> /etc/sysctl.conf
echo "kernel.msgmni = 2048" >> /etc/sysctl.conf
echo "net.ipv4.tcp_syncookies = 1" >> /etc/sysctl.conf
echo "net.ipv4.conf.default.accept_source_route = 0" >> /etc/sysctl.conf
echo "net.ipv4.tcp_tw_recycle = 1" >> /etc/sysctl.conf
echo "net.ipv4.tcp_max_syn_backlog = 4096" >> /etc/sysctl.conf
echo "net.ipv4.conf.all.arp_filter = 1" >> /etc/sysctl.conf
echo "net.ipv4.ip_local_port_range = 1025 65535" >> /etc/sysctl.conf
echo "net.core.netdev_max_backlog = 10000" >> /etc/sysctl.conf
echo "net.ipv4.ip_forward = 0" >> /etc/sysctl.conf
echo "vm.overcommit_memory = 2" >> /etc/sysctl.conf

echo "*soft nofile 65536" >> /etc/security/limits.conf
echo "*hard nofile 65536" >> /etc/security/limits.conf
echo "*soft nproc  131072" >> /etc/security/limits.conf
echo "*hard nproc  131072" >> /etc/security/limits.conf

sysctl -p

service iptables save
service iptables stop
chkconfig iptables off

/etc/init.d/ntpd start

su - gpadmin -c 'gpinitsystem -c gpconfigs/gpinitsystem_config -a'

cp /vagrant/remote/init.d/* /etc/init.d/
chmod 755 /etc/init.d/{greenplum,gpfdist}

chkconfig --add greenplum
chkconfig --add gpfdist
chkconfig greenplum on
chkconfig gpfdist on

# service greenplum start
service gpfdist start




