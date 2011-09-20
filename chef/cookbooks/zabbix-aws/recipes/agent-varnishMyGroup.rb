include_recipe "zabbix::agent"

expected_tag = "REGISTERED"

if not tagged?("zabbix-VarnishMyGroup-#{expected_tag}")
        if not tagged?("zabbix-VarnishMyGroup")
                tag('zabbix-VarnishMyGroup')
        end
end


# your agentd must be include the directory below
directory "/etc/zabbix/agentd.d" do
  owner "zabbix"
  group "root"
  mode "0750"
  action :create
  recursive true
  notifies :restart, resources(:service => "zabbix-agent" ), :delayed
end


template "/etc/zabbix/agentd.d/varnish.conf" do
  source "varnish/varnish.conf.erb"
  owner "zabbix"
  group "root"
  mode "0750"
  notifies :restart, resources(:service => "zabbix-agent" ), :delayed
end
