#recomended to use it together agent-script

package "python-boto" do
  options "--force-yes"
end

# your agentd must be include the directory below
directory "/etc/zabbix/agentd.d" do
  owner "zabbix"
  group "root"
  mode "0750"
  action :create
  recursive true
end

#de-register scripts
#even though some files are static, I put all together
template "/usr/local/bin/zabbix_deregister.sh" do
  source "deregister/zabbix_deregister.sh"
  mode 0750
  owner "zabbix"
  group "root"
  notifies :restart, resources(:service=> "zabbix-agent"), :delayed
end

template "/usr/local/bin/zabbix_get_instances.py" do
  source "deregister/zabbix_get_instances.py.erb"
  mode 0750
  owner "zabbix"
  group "root"
  notifies :restart, resources(:service=> "zabbix-agent"), :delayed
end

template "/etc/zabbix/agentd.d/deregister.conf" do
  source "deregister/deregister.conf.erb"
  mode 0750
  owner "zabbix"
  group "root"
  notifies :restart, resources(:service=> "zabbix-agent"), :delayed
end
