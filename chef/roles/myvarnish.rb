name "varnishMygroup"
description "VarnishMyGroup"
run_list [
  "recipe[zabbix-aws::agent-varnishMyGroup]"
]

# it includes recipes like this:
#
# recipe[zabbix-aws::agent-varnishMyGroup] ->
#        recipe[zabbix-aws::agent-varnish] ->
#              recipe[zabbix::agent]


# soon
#
#   "recipe[zabbix-aws::agent-autoregister]",
#   ]
