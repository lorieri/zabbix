include_recipe "zabbix::agent"

# your agentd must be include the directory below
directory "/etc/zabbix/agentd.d" do
  owner "zabbix"
  group "root"
  mode "0750"
  action :create
  recursive true
  notifies :restart, resources(:service => "zabbix-agent" ), :delayed
end


cookbook_file "/etc/zabbix/agentd.d/varnish.conf" do
  source "varnish/varnish.conf"
  owner "zabbix"
  group "root"
  mode "0750"
  notifies :restart, resources(:service => "zabbix-agent" ), :delayed
end
