name "varnishMygroup"
description "VarnishMyGroup"

override_attributes "zabbixaws" => {
        "server" => {
                "hostname" => "zabbix.mydomain.com.br"
        }
}

run_list [
  "recipe[zabbix-aws::agent-varnishMyGroup]"
]

# it includes recipes like this:
#
# recipe[zabbix-aws::agent-varnishMyGroup] ->
#        recipe[zabbix-aws::agent-varnish] ->
#              recipe[zabbix::agent]

#   and "recipe[zabbix-aws::agent-autoregister]"
