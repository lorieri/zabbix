include_recipe "zabbix-aws::agent-varnish"


# remove heritage tag
untag("zabbix-Varnish")
untag("zabbix-Varnish-REGISTERED")

# added coorect tag
if not tagged?("zabbix-VarnishMyGroup-REGISTERED")
        tag('zabbix-VarnishMyGroup')
end

