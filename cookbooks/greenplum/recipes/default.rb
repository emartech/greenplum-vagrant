%w[mc ed].each { |pkg| package pkg }

template "/etc/hosts" do
  source "hosts.erb"
end

user "gpadmin" do
  password "$1$MggNOwGP$yNkCngMEiXSixlZS33H3E." # gpadmin
end

execute "generate ssh key" do
  user "gpadmin"
  creates "/home/gpadmin/.ssh/id_rsa.pub"
  command "ssh-keygen -t rsa -q -f /home/gpadmin/.ssh/id_rsa -P '' &&
            cat /home/gpadmin/.ssh/id_rsa.pub >> /home/gpadmin/.ssh/authorized_keys &&
            for i in localhost.localdomain localhost #{node['hostname']} #{node['fqdn']}; do
              ssh-keyscan -t rsa ${i} >> /home/gpadmin/.ssh/known_hosts;
            done"
end

cookbook_file "/tmp/greenplum-installer.bin" do
  source "greenplum-db-#{node['greenplum']['version']}-build-1-RHEL5-x86_64.bin"
end

execute "extract greenplum" do
  creates "/usr/local/greenplum-db-#{node['greenplum']['version']}/greenplum_path.sh"

  command "mkdir -p /usr/local/greenplum-db-#{node['greenplum']['version']}
            SKIP=`awk '/^__END_HEADER__/ {print NR + 1; exit 0; }' /tmp/greenplum-installer.bin`;
            tail -n +${SKIP} /tmp/greenplum-installer.bin | tar -xzf - -C /usr/local/greenplum-db-#{node['greenplum']['version']}"
end

execute "set GP_HOME to the correct path" do
  command "sed -i 's/^GPHOME=.*/GPHOME=\\/usr\\/local\\/greenplum-db-#{node['greenplum']['version']}/' /usr/local/greenplum-db-#{node['greenplum']['version']}/greenplum_path.sh"
  not_if "grep '^GPHOME=/usr/local/greenplum-db-#{node['greenplum']['version']}$' /usr/local/greenplum-db-#{node['greenplum']['version']}/greenplum_path.sh"
end

%w[/gpmaster /gpdata1 /gpdata2].each do |dir|
  directory dir do
    owner "gpadmin"
    group "gpadmin"
  end
end

%w[gpinitsystem_config hostlist_singlenode .bash_profile].each do |filename|
  template "/home/gpadmin/#{filename}" do
    source "#{filename}.erb"
  end
end

execute "gpinitsystem" do
  creates "/gpmaster/gpsne-1"
  command "su -l gpadmin -c 'source /usr/local/greenplum-db-#{node['greenplum']['version']}/greenplum_path.sh &&
            gpinitsystem -c /home/gpadmin/gpinitsystem_config -a -q'"
  returns 1 # sadly gpinitsystem outputs some warnings :(
end

execute "allow password auth from anywhere" do
  command 'echo -e "\nhost\tall\tall\t0.0.0.0/0\tmd5\n" >> /gpmaster/gpsne-1/pg_hba.conf'
  not_if 'grep "host.*all.*all.*0\.0\.0\.0/0.*md5" /gpmaster/gpsne-1/pg_hba.conf'

  notifies :restart, 'service[greenplum]'
end

%w[greenplum gpfdist].each do |filename|
  cookbook_file "/etc/init.d/#{filename}" do
    source filename
    mode "0755"
  end

  service filename do
    action [:start, :enable]
  end
end

service "iptables" do
  action [:stop, :disable]
end




