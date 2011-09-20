# accounts
# for now, dont delete the keys, only change as many as you need
# in that example, only the first is changed
default.zabbixaws[:account1][:name] = "account1"
default.zabbixaws[:account1][:key] = "mykey"
default.zabbixaws[:account1][:secret] = "mysecret"

default.zabbixaws[:account2][:name] = "myaccount2"
default.zabbixaws[:account2][:key] = "xxxxxxx"
default.zabbixaws[:account2][:secret] = "xxxxxxxx"

default.zabbixaws[:account3][:name] = "myaccount3"
default.zabbixaws[:account3][:key] = "xxxxxxx"
default.zabbixaws[:account3][:secret] = "xxxxxxx"

default.zabbixaws[:account4][:name] = "myaccount4"
default.zabbixaws[:account4][:key] = "xxxxxxxx"
default.zabbixaws[:account4][:secret] = "xxxxxxxx"

default.zabbixaws[:account5][:name] = "myaccount5"
default.zabbixaws[:account5][:key] = "xxxxxxxx"
default.zabbixaws[:account5][:secret] = "xxxxxxx"

#auto-register and deregister
default.zabbixaws[:auto][:jsonurl] = "zabbix.mydomain.com.br/zabbix/api_jsonrpc.php"
default.zabbixaws[:auto][:user] = "myuser"
default.zabbixaws[:auto][:password] = "mypassword"
## you can change both lines below to "hostname"
default.zabbixaws[:auto][:dnscommand] = "wget --tries=1 --timeout=15 -q -O- http://169.254.169.254/latest/meta-data/hostname"
default.zabbixaws[:auto][:isidcommand] = "wget --tries=1 --timeout=15 -q -O- http://169.254.169.254/latest/meta-data/instance-id"

#zabbix server to varnish send metrics
default.zabbixaws[:server][:hostname] = "zabbix.mydomain.com.br"
