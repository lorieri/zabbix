# requires zabbix-agent, I will not explicit it here

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

template "/etc/zabbix/agentd.d/cloudwatch.conf" do
  source "cloudwatch/cloudwatch.conf.erb"
  owner "zabbix"
  group "root"
  mode 0600
  notifies :restart, resources(:service => "zabbix-agent"), :delayed
end


template "/usr/local/bin/zabbix-cloudwatch.py" do
  source "cloudwatch/zabbix-cloudwatch.py.erb"
  mode 0750
  owner "zabbix"
  group "root"
  notifies :restart, resources(:service => "zabbix-agent" ), :delayed
end

# you may want to use the recipe agent-deregister too
