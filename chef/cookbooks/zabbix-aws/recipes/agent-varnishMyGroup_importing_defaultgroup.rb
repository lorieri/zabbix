include_recipe "zabbix-aws::agent-varnish"


# remove heritage tag
untag("zabbix-Varnish")
untag("zabbix-Varnish-#{expected_tag}")

# added coorect tag
if not tagged?("zabbix-VarnishMyGroup-#{expected_tag}")
	if not tagged?("zabbix-VarnishMyGroup")
	        tag('zabbix-VarnishMyGroup')
	end
end

include_recipe "zabbix-aws::agent-autoregister"
