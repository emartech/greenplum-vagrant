#!/usr/bin/env bash

yum install -y mc expect ntp ed

MASTER_HOSTNAME=mokus

echo "127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4" > /etc/hosts
echo "::1         localhost localhost.localdomain localhost6 localhost6.localdomain6" >> /etc/hosts
echo "192.168.2.11 ${MASTER_HOSTNAME}.ett.local ${MASTER_HOSTNAME}" >> /etc/hosts

sed -i "s/HOSTNAME=.*/HOSTNAME=${MASTER_HOSTNAME}.ett.local/" /etc/sysconfig/network
hostname ${MASTER_HOSTNAME}.ett.local

/etc/init.d/network restart


adduser -m -U gpadmin

/usr/bin/expect<<EOF
spawn passwd gpadmin
expect "New password"
send "gpadmin\r"
expect "Retype new password"
send "gpadmin\r"
expect
EOF


ssh-keygen -t rsa -P "" -f ~/.ssh/id_rsa
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys

mv ~/.ssh /home/gpadmin/
chown -R gpadmin:gpadmin /home/gpadmin

su - gpadmin -c "ssh -o StrictHostKeyChecking=no localhost echo Added localhost to ~/.ssh/known_hosts 2>$1 >/dev/null"
su - gpadmin -c "ssh -o StrictHostKeyChecking=no ${MASTER_HOSTNAME} echo Added ${MASTER_HOSTNAME} to ~/.ssh/known_hosts"
su - gpadmin -c "ssh -o StrictHostKeyChecking=no ${MASTER_HOSTNAME}.ett.local echo Added ${MASTER_HOSTNAME}.ett.local to ~/.ssh/known_hosts"


cp -R /var/local/gpconfigs /home/gpadmin/
echo ${MASTER_HOSTNAME} > /home/gpadmin/gpconfigs/hostlist_singlenode

sed -i "s/###HOSTNAME###/${MASTER_HOSTNAME}/" /home/gpadmin/gpconfigs/gpinitsystem_config

cp /var/local/.bash_profile /home/gpadmin/
chown -R gpadmin:gpadmin /home/gpadmin


#echo "kernel.shmmax = 500000000" > /etc/sysctl.conf
#echo "kernel.shmmni = 4096" >> /etc/sysctl.conf
#echo "kernel.shmall = 4000000000" >> /etc/sysctl.conf
#echo "kernel.sem = 250 512000 100 2048" >> /etc/sysctl.conf
#echo "kernel.sysrq = 1" >> /etc/sysctl.conf
#echo "kernel.core_uses_pid = 1" >> /etc/sysctl.conf
#echo "kernel.msgmnb = 65536" >> /etc/sysctl.conf
#echo "kernel.msgmax = 65536" >> /etc/sysctl.conf
#echo "kernel.msgmni = 2048" >> /etc/sysctl.conf
#echo "net.ipv4.tcp_syncookies = 1" >> /etc/sysctl.conf
#echo "net.ipv4.conf.default.accept_source_route = 0" >> /etc/sysctl.conf
#echo "net.ipv4.tcp_tw_recycle = 1" >> /etc/sysctl.conf
#echo "net.ipv4.tcp_max_syn_backlog = 4096" >> /etc/sysctl.conf
#echo "net.ipv4.conf.all.arp_filter = 1" >> /etc/sysctl.conf
#echo "net.ipv4.ip_local_port_range = 1025 65535" >> /etc/sysctl.conf
#echo "net.core.netdev_max_backlog = 10000" >> /etc/sysctl.conf
#echo "net.ipv4.ip_forward = 0" >> /etc/sysctl.conf
#echo "vm.overcommit_memory = 2" >> /etc/sysctl.conf
#
#echo "*soft nofile 65536" >> /etc/security/limits.conf
#echo "*hard nofile 65536" >> /etc/security/limits.conf
#echo "*soft nproc  131072" >> /etc/security/limits.conf
#echo "*hard nproc  131072" >> /etc/security/limits.conf


source /usr/local/greenplum-db-4.2.6.1/greenplum_path.sh

#echo "${MASTER_HOSTNAME}" > hostfile_exkeys
#echo "${MASTER_HOSTNAME}" > hosts_gpcheck
#echo "${MASTER_HOSTNAME}" > host_file
#echo "smdw" >> hostfile_exkeys
#echo "sdw1" >> hostfile_exkeys
#echo "sdw2" >> hostfile_exkeys
#chmod 777 hostfile_exkeys
#gpseginstall -f hostfile_exkeys -u gpadmin -p changeme

cd /
mkdir gpdata1 gpdata2 gpmaster
chown gpadmin:gpadmin gpdata1 gpdata2 gpmaster



#sed -i 's/server 0.centos.pool.ntp.org/#server 0.centos.pool.ntp.org/g' /etc/ntp.conf
#sed -i 's/server 1.centos.pool.ntp.org/#server 0.centos.pool.ntp.org/g' /etc/ntp.conf
#sed -i 's/server 2.centos.pool.ntp.org/#server 0.centos.pool.ntp.org/g' /etc/ntp.conf
#echo "server 192.168.2.11" >> /etc/ntp.conf

/etc/init.d/ntpd start

#gpcheck -h ${MASTER_HOSTNAME}
#echo deadline > /sys/block/sr0/queue/scheduler
#/sbin/blockdev --setra 16385 /dev/sda1
#gpcheck -h ${MASTER_HOSTNAME}
#chmod 777 hosts_gpcheck
#gpcheck -f hosts_gpcheck
#chmod 777 host_file


service iptables save
service iptables stop
chkconfig iptables off



source /home/gpadmin/.bash_profile

su - gpadmin -c 'gpinitsystem -c gpconfigs/gpinitsystem_config -a'





